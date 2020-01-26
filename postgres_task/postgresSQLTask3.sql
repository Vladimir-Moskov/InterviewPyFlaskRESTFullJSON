-- TASK DESCRIPTION
-- Given the transactions table and table containing exchange rates:

--1. Write down a query that gives us a breakdown of spend in GBP by each user. Use the
--exchange rate with the largest timestamp .
--2. Write down the same query, but this time, use the latest exchange rate smaller or equal
--then the transaction timestamp . The solution should have the two columns: user_id ,
--total_spent_gbp , ordered by user_id
--3. Bonus for Postgres superstars: Consider the same schema, but now let’s add some
--random data, to simulate real scale:
--https://dbfiddle.uk/?rdbms=postgres_9.6&fiddle=231257838892f0198c58bb5f46fb0d5d
--Write a solution for the previous task. Please ensure It executes within 5 seconds.
--(You are allowed to make minor changes in the schema itself like building indexes,
--creating types, etc.)
-- explain analyze

-- ************** GIVEN DB SCHEMA AND TEST DATA *************************
-- explain analyze


drop table if exists exchange_rates;
create table exchange_rates(
ts timestamp without time zone,
from_currency varchar(3),
to_currency varchar(3),
rate numeric
);

CREATE INDEX idx_exchange_rates_ts
ON exchange_rates(ts);
/*
CREATE INDEX idx_exchange_rates_from_currency
ON exchange_rates(from_currency);

CREATE INDEX idx_exchange_rates_to_currency
ON exchange_rates(to_currency);
*/
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

-- For volumes of data close to real, run this:
insert into exchange_rates (
select ts, from_currency, to_currency, rate from (
select date_trunc('second', dd + (random() * 60) * '1 second':: interval) as ts, case when random()*2 < 1 then 'EUR' else 'USD' end as from_currency,
'GBP' as to_currency, (200 * random():: int )/100 as rate
FROM generate_series
        ( '2018-04-01'::timestamp
        , '2018-04-02'::timestamp
        , '1 minute'::interval) dd
     ) a
where ts not in (select ts from exchange_rates)
order by ts
)
;

-- Transactions

drop table if exists transactions;
create table transactions (
ts timestamp without time zone,
user_id int,
currency varchar(3),
amount numeric
);



CREATE INDEX idx_transactions_ts
ON transactions(ts);
/*
CREATE INDEX idx_transactions_currency
ON transactions(currency);
*/
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

-- For volumes of data close to real, run this:
insert into transactions (
SELECT dd + (random()*5) * '1 second'::interval as ts, (random() * 1000)::int as user_id,
case when random()*2 < 1 then 'EUR' else 'USD' end as currency,
(random() * 10000) :: int / 100 as amount
FROM generate_series
        ( '2018-04-01'::timestamp
        , '2018-04-02'::timestamp
        , '1 second'::interval) dd
)        ;


-- ***************** THE SOLUTION 3 **************
-- I did some attempt to optimize query, but unfortunately had not enough time to finish it

-- EXPLAIN ANALYZE
EXPLAIN ANALYZE
SELECT
        summary.user_id
       ,SUM(summary.amount * summary.rate) as total_spent_gbp
FROM
(
    SELECT  DISTINCT ON(trans_tbl.user_id
                        ,trans_tbl.currency
                        ,trans_tbl.amount
                        ,trans_tbl.ts
                        )
            trans_tbl.user_id
           ,trans_tbl.currency
           ,trans_tbl.amount
           ,trans_tbl.ts as time_trans
           ,rates_tbl.ts as time_rate
           ,COALESCE(rates_tbl.rate, 1) as rate
    FROM transactions  trans_tbl
    LEFT JOIN exchange_rates rates_tbl ON trans_tbl.currency = rates_tbl.from_currency
    AND rates_tbl.to_currency = 'GBP'
    AND rates_tbl.ts <= trans_tbl.ts
    ORDER BY trans_tbl.user_id,
            trans_tbl.currency,
            trans_tbl.amount,
            trans_tbl.ts,
            rates_tbl.ts DESC
    ) summary
GROUP BY summary.user_id
ORDER BY summary.user_id
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
--GroupAggregate  (cost=88.34..105.84 rows=200 width=36) (actual time=0.167..0.181 rows=4 loops=1)
--  Group Key: trans_tbl.user_id
--  ->  Unique  (cost=88.34..99.84 rows=200 width=100) (actual time=0.136..0.156 rows=11 loops=1)
--        ->  Sort  (cost=88.34..90.64 rows=920 width=100) (actual time=0.136..0.141 rows=38 loops=1)
--              Sort Key: trans_tbl.user_id, trans_tbl.currency, trans_tbl.amount, trans_tbl.ts, rates_tbl.ts DESC
--              Sort Method: quicksort  Memory: 27kB
--              ->  Hash Left Join  (cost=20.18..43.05 rows=920 width=100) (actual time=0.047..0.069 rows=38 loops=1)
--                    Hash Cond: ((trans_tbl.currency)::text = (rates_tbl.from_currency)::text)
--                    Join Filter: (rates_tbl.ts <= trans_tbl.ts)
--                    Rows Removed by Join Filter: 36
--                    ->  Seq Scan on transactions trans_tbl  (cost=0.00..19.20 rows=920 width=60) (actual time=0.005..0.006 rows=11 loops=1)
--                    ->  Hash  (cost=20.12..20.12 rows=4 width=56) (actual time=0.022..0.022 rows=16 loops=1)
--                          Buckets: 1024  Batches: 1  Memory Usage: 9kB
--                          ->  Seq Scan on exchange_rates rates_tbl  (cost=0.00..20.12 rows=4 width=56) (actual time=0.010..0.014 rows=16 loops=1)
--                                Filter: ((to_currency)::text = 'GBP'::text)
--                                Rows Removed by Filter: 1
--Planning time: 0.179 ms
--Execution time: 0.253 ms