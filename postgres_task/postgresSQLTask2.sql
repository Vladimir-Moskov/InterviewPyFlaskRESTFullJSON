-- TASK DESCRIPTION
-- Given the transactions table and table containing exchange rates:

--1. Write down a query that gives us a breakdown of spend in GBP by each user. Use the
--exchange rate with the largest timestamp .
--2. Write down the same query, but this time, use the latest exchange rate smaller or equal
--then the transaction timestamp . The solution should have the two columns: user_id ,
--total_spent_gbp , ordered by user_id

-- explain analyze

-- ************** GIVEN DB SCHEMA AND TEST DATA *************************
drop table if exists exchange_rates;
create table exchange_rates(
ts timestamp without time zone,
from_currency varchar(3),
to_currency varchar(3),
rate numeric
);

truncate table exchange_rates;
insert into exchange_rates
values
('2018-04-01 00:00:00', 'USD', 'GBP', '0.71'),
('2018-04-01 00:00:05', 'USD', 'GBP', '0.82'),
('2018-04-01 00:01:00', 'USD', 'GBP', '0.92'),
('2018-04-01 01:02:00', 'USD', 'GBP', '0.62'),

('2018-04-01 02:00:00', 'USD', 'GBP', '0.71'),
('2018-04-01 03:00:05', 'USD', 'GBP', '0.82'),
('2018-04-01 04:01:00', 'USD', 'GBP', '0.92'),
('2018-04-01 04:22:00', 'USD', 'GBP', '0.62'),

('2018-04-01 00:00:00', 'EUR', 'GBP', '1.71'),
('2018-04-01 01:00:05', 'EUR', 'GBP', '1.82'),
('2018-04-01 01:01:00', 'EUR', 'GBP', '1.92'),
('2018-04-01 01:02:00', 'EUR', 'GBP', '1.62'),

('2018-04-01 02:00:00', 'EUR', 'GBP', '1.71'),
('2018-04-01 03:00:05', 'EUR', 'GBP', '1.82'),
('2018-04-01 04:01:00', 'EUR', 'GBP', '1.92'),
('2018-04-01 05:22:00', 'EUR', 'GBP', '1.62'),

('2018-04-01 05:22:00', 'EUR', 'HUF', '0.062')
;


-- Transactions

drop table if exists transactions;
create table transactions (
ts timestamp without time zone,
user_id int,
currency varchar(3),
amount numeric
);

truncate table transactions;
insert into transactions
values
('2018-04-01 00:00:00', 1, 'EUR', 2.45),
('2018-04-01 01:00:00', 1, 'EUR', 8.45),
('2018-04-01 01:30:00', 1, 'USD', 3.5),
('2018-04-01 20:00:00', 1, 'EUR', 2.45),

('2018-04-01 00:30:00', 2, 'USD', 2.45),
('2018-04-01 01:20:00', 2, 'USD', 0.45),
('2018-04-01 01:40:00', 2, 'USD', 33.5),
('2018-04-01 18:00:00', 2, 'EUR', 12.45),

('2018-04-01 18:01:00', 3, 'GBP', 2),

('2018-04-01 00:01:00', 4, 'USD', 2),
('2018-04-01 00:01:00', 4, 'GBP', 2)
;

-- ***************** THE SOLUTION 2 **************

SELECT  trans_tbl.user_id
       ,SUM(trans_tbl.amount * COALESCE(rates_tbl.rate, 1)) as total_spent_gbp
FROM transactions  trans_tbl
LEFT JOIN LATERAL (
   SELECT DISTINCT ON(from_currency, to_currency)
          from_currency
         ,to_currency
         ,rate
         ,ts
   FROM exchange_rates
   WHERE ts <= trans_tbl.ts
   ORDER BY from_currency, to_currency, ts DESC
) rates_tbl ON trans_tbl.currency = rates_tbl.from_currency
AND rates_tbl.to_currency = 'GBP'
GROUP BY trans_tbl.user_id
ORDER BY trans_tbl.user_id
;

-- Query result

--user_id 	total_spent_gbp
--  1 	    24.7780
--  2 	    43.4720
--  3 	    2
--  4 	    3.84

--
-- Executing query with EXPLAIN ANALYZE
--QUERY PLAN
--GroupAggregate  (cost=20479.29..20490.99 rows=200 width=36) (actual time=0.322..0.329 rows=4 loops=1)
--  Group Key: trans_tbl.user_id
--  ->  Sort  (cost=20479.29..20481.59 rows=920 width=68) (actual time=0.297..0.299 rows=11 loops=1)
--        Sort Key: trans_tbl.user_id
--        Sort Method: quicksort  Memory: 25kB
--        ->  Nested Loop Left Join  (cost=22.16..20434.00 rows=920 width=68) (actual time=0.078..0.272 rows=11 loops=1)
--              ->  Seq Scan on transactions trans_tbl  (cost=0.00..19.20 rows=920 width=60) (actual time=0.006..0.010 rows=11 loops=1)
--              ->  Subquery Scan on rates_tbl  (cost=22.16..22.18 rows=1 width=48) (actual time=0.022..0.023 rows=1 loops=11)
--                    Filter: ((trans_tbl.currency)::text = (rates_tbl.from_currency)::text)
--                    Rows Removed by Filter: 1
--                    ->  Unique  (cost=22.16..22.17 rows=1 width=72) (actual time=0.020..0.022 rows=2 loops=11)
--                          ->  Sort  (cost=22.16..22.16 rows=1 width=72) (actual time=0.020..0.021 rows=8 loops=11)
--                                Sort Key: exchange_rates.from_currency, exchange_rates.ts DESC
--                                Sort Method: quicksort  Memory: 25kB
--                                ->  Seq Scan on exchange_rates  (cost=0.00..22.15 rows=1 width=72) (actual time=0.004..0.007 rows=8 loops=11)
--                                      Filter: ((ts <= trans_tbl.ts) AND ((to_currency)::text = 'GBP'::text))
--                                      Rows Removed by Filter: 9
--Planning time: 0.536 ms
--Execution time: 0.436 ms

