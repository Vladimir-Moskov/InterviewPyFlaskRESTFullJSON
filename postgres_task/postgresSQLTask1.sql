-- TASK DESCRIPTION
-- Given the transactions table and table containing exchange rates:

-- Exchange rate timestamps
--are rounded to second, transaction timestamps are rounded up to the millisecond. We have only
--data for one day, 1st of April, 2018. Please note there are no exchange rates from GBP to GBP
--as it is always 1
--1. Write down a query that gives us a breakdown of spend in GBP by each user. Use the
--exchange rate with the largest timestamp .
-- The solution should have the two columns: user_id ,
--total_spent_gbp , ordered by user_id


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


-- ***************** THE SOLUTION 1 **************

--EXPLAIN ANALYZE
SELECT  trans_tbl.user_id
       ,SUM(trans_tbl.amount * COALESCE(rates_tbl.rate, 1)) as total_spent_gbp
FROM transactions  trans_tbl
--  TABLE with transactions joined with currency rates
LEFT JOIN (
-- sub query with currency rates ordered by timestamp in order to have latest rate for each transaction
   SELECT DISTINCT ON(from_currency, to_currency)
          from_currency
         ,to_currency
         ,rate
         ,ts
   FROM exchange_rates
   ORDER BY from_currency, to_currency, ts DESC
) rates_tbl ON trans_tbl.currency = rates_tbl.from_currency
AND rates_tbl.to_currency = 'GBP'
GROUP BY trans_tbl.user_id
ORDER BY trans_tbl.user_id
;

--
-- Executing query with EXPLAIN ANALYZE
--QUERY PLAN
--Sort  (cost=60.15..60.65 rows=200 width=36) (actual time=0.163..0.164 rows=4 loops=1)
--  Sort Key: trans_tbl.user_id
--  Sort Method: quicksort  Memory: 25kB
--  ->  HashAggregate  (cost=50.01..52.51 rows=200 width=36) (actual time=0.148..0.149 rows=4 loops=1)
--        Group Key: trans_tbl.user_id
--        ->  Hash Left Join  (cost=20.28..43.11 rows=920 width=68) (actual time=0.117..0.124 rows=11 loops=1)
--              Hash Cond: ((trans_tbl.currency)::text = (rates_tbl.from_currency)::text)
--              ->  Seq Scan on transactions trans_tbl  (cost=0.00..19.20 rows=920 width=52) (actual time=0.007..0.009 rows=11 loops=1)
--              ->  Hash  (cost=20.23..20.23 rows=4 width=48) (actual time=0.086..0.086 rows=2 loops=1)
--                    Buckets: 1024  Batches: 1  Memory Usage: 9kB
--                    ->  Subquery Scan on rates_tbl  (cost=20.16..20.23 rows=4 width=48) (actual time=0.072..0.076 rows=2 loops=1)
--                          ->  Unique  (cost=20.16..20.19 rows=4 width=72) (actual time=0.071..0.074 rows=2 loops=1)
--                                ->  Sort  (cost=20.16..20.18 rows=4 width=72) (actual time=0.071..0.072 rows=16 loops=1)
--                                      Sort Key: exchange_rates.from_currency, exchange_rates.ts DESC
--                                      Sort Method: quicksort  Memory: 26kB
--                                      ->  Seq Scan on exchange_rates  (cost=0.00..20.12 rows=4 width=72) (actual time=0.009..0.016 rows=16 loops=1)
--                                            Filter: ((to_currency)::text = 'GBP'::text)
--                                            Rows Removed by Filter: 1
--Planning time: 0.631 ms
--Execution time: 0.300 ms





