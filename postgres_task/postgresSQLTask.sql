-- TASK DESCRIPTION
-- Given the transactions table and table containing exchange rates:

-- 1. Write down a query that gives us a breakdown of spend in GBP by each user.
-- Use the exchange rate with largest timestamp less or equal then transaction timestamp.

-- explain analyze

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

/*
SELECT user_id
       ,SUM(amount) as total
FROM transactions
GROUP BY user_id
ORDER BY user_id
;*/
/*
SELECT   DISTINCT ON(from_currency, to_currency)
          from_currency
         ,to_currency
         ,rate
         ,ts
   FROM exchange_rates
   ORDER BY from_currency, to_currency, ts DESC
;
 */

/*
SELECT  trans_tbl.user_id
       ,trans_tbl.currency
       ,trans_tbl.amount
       ,COALESCE(rates_tbl.rate, 1) as rate
       ,trans_tbl.amount * COALESCE(rates_tbl.rate, 1) as value_GBP
FROM transactions  trans_tbl
LEFT JOIN (
   SELECT DISTINCT ON(from_currency, to_currency)
          from_currency
         ,to_currency
         ,rate
         ,ts
   FROM exchange_rates
   ORDER BY from_currency, to_currency, ts DESC
) rates_tbl ON trans_tbl.currency = rates_tbl.from_currency
AND rates_tbl.to_currency = 'GBP'

ORDER BY user_id
;
*/
/* TASK 1*/
/*
SELECT  trans_tbl.user_id
       ,SUM(trans_tbl.amount * COALESCE(rates_tbl.rate, 1)) as total_spent_gbp
FROM transactions  trans_tbl
LEFT JOIN (
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
*/

/* TASK 2*/


/*
SELECT  trans_tbl.user_id
       ,trans_tbl.ts as time_trans
       ,trans_tbl.currency
       ,trans_tbl.amount
       ,COALESCE(rates_tbl.rate, 1) as rate
       ,trans_tbl.amount * COALESCE(rates_tbl.rate, 1) as value_GBP
       ,rates_tbl.ts as time_rate
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

ORDER BY user_id
;
*/


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


/* TASK 3*/

/*
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
*/
/*
SELECT  DISTINCT ON(trans_tbl.user_id, trans_tbl.currency, trans_tbl.amount, trans_tbl.ts)

        trans_tbl.user_id
       ,trans_tbl.currency
       ,trans_tbl.amount
       ,trans_tbl.ts as time_trans
       ,rates_tbl.ts as time_rate
       ,rates_tbl.rate
FROM transactions  trans_tbl
LEFT JOIN exchange_rates rates_tbl ON trans_tbl.currency = rates_tbl.from_currency
AND rates_tbl.to_currency = 'GBP'
AND rates_tbl.ts <= trans_tbl.ts
ORDER BY trans_tbl.user_id, trans_tbl.currency, trans_tbl.amount,  trans_tbl.ts, rates_tbl.ts DESC

*/

/*
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
LIMIT 1
WHERE 1 =1
AND rates_tbl.to_currency = 'GBP'
AND rates_tbl.ts <= trans_tbl.ts LIMIT 1
ORDER BY trans_tbl.user_id,
trans_tbl.currency,
trans_tbl.amount,
trans_tbl.ts,
rates_tbl.ts DESC
) summary
GROUP BY summary.user_id*/


SELECT
        trans_tbl.user_id
       ,trans_tbl.currency
       ,trans_tbl.amount
       ,trans_tbl.ts as time_trans
       ,rates_tbl.ts as time_rate
       ,COALESCE(rates_tbl.rate, 1) as rate
FROM transactions  trans_tbl
LEFT JOIN exchange_rates rates_tbl ON trans_tbl.currency = rates_tbl.from_currency
AND rates_tbl.to_currency = 'GBP'
AND rates_tbl.ts = (
          SELECT MAX(rate2.ts) FROM exchange_rates rate2
          WHERE rate2.to_currency = 'GBP'
          AND  trans_tbl.currency = rate2.from_currency
          AND rate2.ts<= trans_tbl.ts
      )
ORDER BY trans_tbl.user_id
/*,trans_tbl.currency
,trans_tbl.amount,
,trans_tbl.ts,*/
-- rates_tbl.ts DESC
;
