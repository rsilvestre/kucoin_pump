select
  symbol,
  regr_slope(
    relative_price_change,
    extract(epoch from last_event_time)
  ) as slope,
  regr_intercept(relative_price_change, extract(epoch from last_event_time)),
  max(relative_price_change) as max_relative_price,
  min(relative_price_change) as min_relative_price,
  sum(case when relative_price_change > 0 then 1 else -1 end) nb_positive,
  sum(1) nb,
  max(tick_count) as max_tick
from price_groups
where last_event_time > (now() at time zone 'utc' - interval '15 minutes')
group by symbol
order by sum(1) desc
;

--select current_time - interval '2 hours 15 minutes';

--select last_event_time > (now()  at time zone 'utc' - interval '5 minutes') from price_groups order by last_event_time desc limit 1;

--select now()  at time zone 'utc', current_time  at time zone 'utc';