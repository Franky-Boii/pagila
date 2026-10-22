-- Pagila SQL tutorial: solutions
-- Run with: psql -h localhost -p 5434 -U postgres -d pagila -f solutions.sql
SET timezone = 'UTC';

\echo '--- Q1: How many customers are there?'
SELECT COUNT(*) AS customer_count FROM customer;

\echo '--- Q2: How many unique customer email addresses are there?'
SELECT COUNT(DISTINCT email) AS unique_emails FROM customer;

\echo '--- Q3: Store with the most DVDs in stock (non-unique) (a) and how many (b)'
SELECT store_id, COUNT(*) AS total_dvds
FROM inventory
GROUP BY store_id
ORDER BY total_dvds DESC
LIMIT 1;

\echo '--- Q4: Store with the most unique films in stock (a) and how many (b)'
SELECT store_id, COUNT(DISTINCT film_id) AS unique_films
FROM inventory
GROUP BY store_id
ORDER BY unique_films DESC
LIMIT 1;

\echo '--- Q5: Does anyone ever rent more than one DVD on a given day?'
SELECT COUNT(*) > 0 AS yes_someone_does, COUNT(*) AS customer_days
FROM (
    SELECT 1
    FROM rental
    GROUP BY customer_id, rental_date::date
    HAVING COUNT(*) > 1
) t;

\echo '--- Q6: Day with the most DVDs returned (a) and how many (b)'
SELECT return_date::date AS return_day, COUNT(*) AS returned
FROM rental
WHERE return_date IS NOT NULL
GROUP BY return_date::date
ORDER BY returned DESC
LIMIT 3;

\echo '--- Q7: Average number of rentals per customer'
SELECT ROUND(AVG(cnt), 2) AS avg_rentals_per_customer
FROM (
    SELECT customer_id, COUNT(*) AS cnt
    FROM rental
    GROUP BY customer_id
) t;

\echo '--- Q8: Average number of rentals per customer in store 2'
SELECT ROUND(AVG(cnt), 2) AS avg_rentals_per_customer_store_2
FROM (
    SELECT c.customer_id, COUNT(r.rental_id) AS cnt
    FROM customer c
    JOIN rental r ON r.customer_id = c.customer_id
    WHERE c.store_id = 2
    GROUP BY c.customer_id
) t;

\echo '--- Q9: Longest time a DVD is rented'
SELECT MAX(return_date - rental_date) AS longest_rental
FROM rental
WHERE return_date IS NOT NULL;

\echo '--- Q10: Most common special feature'
SELECT feature, COUNT(*) AS occurrences
FROM film, UNNEST(special_features) AS feature
GROUP BY feature
ORDER BY occurrences DESC
LIMIT 3;

\echo '--- Q11: Customer who spent the most in February (a) and how much (b)'
SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount) AS total_spent
FROM payment p
JOIN customer c ON c.customer_id = p.customer_id
WHERE EXTRACT(MONTH FROM p.payment_date) = 2
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 3;