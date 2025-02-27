defmodule KucoinPump.Repo.Migrations.CreateComputePriceDiffFunction do
  use Ecto.Migration

  def change do
    execute("""
    DROP FUNCTION IF EXISTS compute_price_diff(integer);
    """)

    execute("""
    CREATE OR REPLACE FUNCTION compute_price_diff(time_interval_in_minutes int)
    RETURNS TABLE(
        sym character varying,
        rsi double precision,
        rpch double precision,
        np bigint
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
        relative_price_change,
        last_price - LAG(last_price) OVER (PARTITION BY symbol ORDER BY last_event_time) AS price_change,
        LAST_VALUE(last_price) OVER (PARTITION BY symbol ORDER BY last_event_time) AS last_price
        FROM
        price_groups
        WHERE last_event_time > (now() AT time zone 'utc' - interval '1 minutes' * time_interval_in_minutes)
      ),
      price_sums AS (
        SELECT
        symbol,
        SUM(CASE WHEN price_change > 0 THEN price_change ELSE 0 END) AS positive_sum,
        SUM(CASE WHEN price_change < 0 THEN ABS(price_change) ELSE 0 END) AS negative_sum,
        SUM(price_change) AS price_change,
        MAX(last_price) AS last_price,
        SUM(1) AS nb
        FROM
        price_diff
        GROUP BY
        symbol
      ),
      rsi AS (
        SELECT
          symbol,
          CASE WHEN negative_sum != 0 THEN
            100 - (100 / (1 + (positive_sum / negative_sum)))
          ELSE 0
          END AS rsi,
          price_change / (last_price - price_change) * 100 AS rpch,
          nb
        FROM
          price_sums
      )
      SELECT
        rsi.symbol,
        rsi.rsi,
        rsi.rpch,
        rsi.nb
      FROM rsi
      WHERE rsi.rsi != 0 --AND nb > 10
      ORDER BY rsi DESC;
    END;
    $$;
    """)
  end
end
