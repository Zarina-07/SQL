create database customer_transaction;
update customer_info set Gender = null where Gender = '';
update customer_info set Age = null where Age = '';
alter table customer_info modify Age int null;

select * from TRANSACTIONS;

create table TRANSACTIONS
(date_new date,
Id_check int,
ID_client int,
Count_products decimal(10,3),
Sum_payment decimal(10,2));

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/TRANSACTIONS.csv'
INTO TABLE TRANSACTIONS
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


SHOW VARIABLES LIKE 'secure_file_priv';

# Соеденим 2 таблицы
SELECT *
FROM TRANSACTIONS t
JOIN customer_info c
    ON t.ID_client = c.Id_client;

#количество операции клиента
SELECT
    t.ID_client,
    COUNT(t.Id_check) AS count_operations
FROM TRANSACTIONS t
JOIN customer_info c
    ON t.ID_client = c.Id_client
GROUP BY t.ID_client;

#средний чек за весь период
SELECT
    t.ID_client,
    AVG(t.Sum_payment) AS average_check,
    COUNT(t.Id_check) AS count_operations
FROM TRANSACTIONS t
JOIN customer_info c
    ON t.ID_client = c.Id_client
GROUP BY t.ID_client
ORDER BY t.ID_client;

#средняя сумма покупок за месяц
SELECT
    t.ID_client,
    MONTH(t.date_new) AS month,
    AVG(t.Sum_payment) AS avg_sum
FROM TRANSACTIONS t
JOIN customer_info c
    ON t.ID_client = c.Id_client
GROUP BY
    t.ID_client,
    MONTH(t.date_new)
ORDER BY
    t.ID_client,
    month;

#средняя сумма чека за месяц
SELECT
    MONTH(t.date_new) AS month,
    AVG(t.Sum_payment) AS average_check
FROM TRANSACTIONS t
JOIN customer_info c
    ON t.ID_client = c.Id_client
GROUP BY MONTH(t.date_new)
ORDER BY MONTH(t.date_new);

#среднее количество операций в месяц
SELECT
    COUNT(Id_check) / 12 AS avg_operations
FROM TRANSACTIONS;

#среднее количество клиентов, которые совершали операции;
SELECT
    MONTH(date_new) AS month,
    COUNT(DISTINCT ID_client) AS clients
FROM TRANSACTIONS
GROUP BY MONTH(date_new)
ORDER BY MONTH(date_new);

#долю от общего количества операций за год и долю в месяц от общей суммы операций;
SELECT
    MONTH(date_new) AS month,
    ROUND(
        COUNT(Id_check) / (
            SELECT COUNT(Id_check)
            FROM TRANSACTIONS
        ) * 100, 2
    ) AS operations_count,
    ROUND(
        SUM(Sum_payment) / (
            SELECT SUM(Sum_payment)
            FROM TRANSACTIONS
        ) * 100, 2
    ) AS payment_sum
FROM TRANSACTIONS
GROUP BY MONTH(date_new)
ORDER BY MONTH(date_new);

#вывести % соотношение M/F/NA в каждом месяце с их долей затрат;
SELECT
    MONTH(t.date_new) AS month,
    c.Gender,
    SUM(t.Sum_payment) AS total_payment,
    SUM(t.Sum_payment) / SUM(SUM(t.Sum_payment)) OVER (
        PARTITION BY MONTH(t.date_new)
    ) * 100 AS payment_share
FROM TRANSACTIONS t
JOIN customer_info c
    ON t.ID_client = c.Id_client
GROUP BY
    MONTH(t.date_new),
    c.Gender
ORDER BY
    MONTH(t.date_new),
    c.Gender;

#возрастные группы
SELECT
    CASE
        WHEN c.Age IS NULL THEN 'NA'
        WHEN c.Age < 20 THEN 'до 20'
        WHEN c.Age < 30 THEN '20-29'
        WHEN c.Age < 40 THEN '30-39'
        WHEN c.Age < 50 THEN '40-49'
        WHEN c.Age < 60 THEN '50-59'
        WHEN c.Age < 70 THEN '60-69'
        WHEN c.Age < 80 THEN '70-79'
        ELSE '80+'
    END AS age_group,

    SUM(t.Sum_payment) AS total_payment,
    COUNT(t.Id_check) AS operations

FROM TRANSACTIONS t

JOIN customer_info c
    ON t.ID_client = c.Id_client

GROUP BY
    CASE
        WHEN c.Age IS NULL THEN 'NA'
        WHEN c.Age < 20 THEN 'до 20'
        WHEN c.Age < 30 THEN '20-29'
        WHEN c.Age < 40 THEN '30-39'
        WHEN c.Age < 50 THEN '40-49'
        WHEN c.Age < 60 THEN '50-59'
        WHEN c.Age < 70 THEN '60-69'
        WHEN c.Age < 80 THEN '70-79'
        ELSE '80+'
    END

ORDER BY age_group;

#квартал
SELECT
    QUARTER(t.date_new) AS quarter,

    CASE
        WHEN c.Age IS NULL THEN 'NA'
        WHEN c.Age < 20 THEN 'до 20'
        WHEN c.Age < 30 THEN '20-29'
        WHEN c.Age < 40 THEN '30-39'
        WHEN c.Age < 50 THEN '40-49'
        WHEN c.Age < 60 THEN '50-59'
        WHEN c.Age < 70 THEN '60-69'
        WHEN c.Age < 80 THEN '70-79'
        ELSE '80+'
    END AS age_group,

    AVG(t.Sum_payment) AS average_check,
    AVG(t.Count_products) AS average_products,
    COUNT(t.Id_check) AS operations,
    SUM(t.Sum_payment) AS total_payment

FROM TRANSACTIONS t

JOIN customer_info c
    ON t.ID_client = c.Id_client

GROUP BY
    QUARTER(t.date_new),
    CASE
        WHEN c.Age IS NULL THEN 'NA'
        WHEN c.Age < 20 THEN 'до 20'
        WHEN c.Age < 30 THEN '20-29'
        WHEN c.Age < 40 THEN '30-39'
        WHEN c.Age < 50 THEN '40-49'
        WHEN c.Age < 60 THEN '50-59'
        WHEN c.Age < 70 THEN '60-69'
        WHEN c.Age < 80 THEN '70-79'
        ELSE '80+'
    END

ORDER BY
    quarter,
    age_group;



