defmodule KucoinPump.Repo.Migrations.UpdateComputePriceDiffFunction do
  use Ecto.Migration

  def change do
    execute("""
    --CREATE EXTENSION IF NOT EXISTS "unaccent";
    DROP FUNCTION compute_price_diff(integer);
    """)

    execute("""
    CREATE OR REPLACE FUNCTION compute_price_diff(time_interval_in_minutes int)
    RETURNS TABLE(
        sym character varying,
        rsi double precision,
        pch double precision,
        np bigint,
        lp double precision,
        tpch double precision,
        rpch double precision,
        t timestamp
        )
        LANGUAGE 'plpgsql'
        COST 100
        VOLATILE PARALLEL UNSAFE
        ROWS 1000

    AS $$
    BEGIN
      RETURN query

      WITH price_diff AS (
        SELECT
        symbol,
        last_price - LAG(last_price) OVER (PARTITION BY symbol ORDER BY last_event_time) AS price_change,
        LAST_VALUE(last_price) OVER (PARTITION BY symbol ORDER BY last_event_time) AS last_price,
        LAST_VALUE(total_price_change) OVER (PARTITION BY symbol ORDER BY last_event_time) AS total_price_change,
        LAST_VALUE(relative_price_change) OVER (PARTITION BY symbol ORDER BY last_event_time) AS relative_price_change,
        LAST_VALUE(last_event_time) OVER (PARTITION BY symbol ORDER BY last_event_time) AS last_event_time
        FROM
        price_groups
        WHERE last_event_time > (now() AT time zone 'utc' - interval '1 minutes' * time_interval_in_minutes)
      ),
      price_sums AS (
        SELECT
        price_diff.symbol AS symbol,
        SUM(CASE WHEN price_change > 0 THEN price_change ELSE 0 END) AS positive_sum,
        SUM(CASE WHEN price_change < 0 THEN ABS(price_change) ELSE 0 END) AS negative_sum,
        SUM(price_change) AS price_change,
        MAX(last_price) AS last_price,
        MAX(total_price_change) AS total_price_change,
        MAX(relative_price_change) AS relative_price_change,
        MAX(last_event_time) AS last_event_time,
        SUM(1) AS nb
        FROM
        price_diff
        GROUP BY
        price_diff.symbol
      ),
      rsiy AS (
        SELECT
          price_sums.symbol AS symbol,
          CASE WHEN negative_sum != 0 THEN
            100 - (100 / (1 + (positive_sum / negative_sum)))
          ELSE 0
          END AS rsix,
          price_change / (last_price - price_change) * 100 AS pch,
          nb,
        last_price,
        total_price_change,
        relative_price_change,
        last_event_time
        FROM
          price_sums
      )
      SELECT
        rsiy.symbol,
        rsiy.rsix,
        rsiy.pch,
        rsiy.nb,
        rsiy.last_price,
        rsiy.total_price_change,
        rsiy.relative_price_change,
        rsiy.last_event_time
      FROM rsiy
      WHERE rsiy.rsix != 0 --AND nb > 10
      ORDER BY rsiy.rsix DESC;
    END;
    $$;
    """)
  end
end
