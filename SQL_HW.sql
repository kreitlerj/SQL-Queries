-- select db to be used
USE sakila;

-- 1a. Display the first and last names of all the actors from the table "actor"
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single colunm in upper
-- case letters.  Name the column "Actor Name"
SELECT UPPER(CONCAT(first_name, ' ', last_name)) AS "Actor Name" FROM actor;

-- 2a. Find the ID number, first name, and last name of an actor that only the
-- first name, "Joe", is known.
SELECT actor_id, first_name, last_name FROM actor
WHERE first_name = "Joe";

-- 2b. Find all the actors whose last name contain the letters "GEN".
SELECT first_name, last_name FROM actor
WHERE last_name LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters "LI".
-- Rows ordered by last name and first name
SELECT first_name, last_name FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name, first_name ASC;

-- 2d. Using IN, display the "country_id" and "country" coluns of the 
-- following countries: Afghanistan, Bangladesh, and China
SELECT country_id, country FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- 3a. Add a column in the table "actor" name "description" and use the data type "BLOB"
ALTER TABLE actor
ADD COLUMN description BLOB;

-- 3b. Delete the newly created "description" column from the table "actor"
ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) FROM actor
GROUP BY last_name;

-- 4b. List the last names of actors and the number of actors who have 
-- that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) FROM actor
GROUP BY last_name
HAVING COUNT(*) > 1;

-- 4c. The actor "HARPO WILLIAMS" was accidentally entered in the "actor" table
-- as "GROUCHO WILLIAMS", correct the mistake.
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO"
AND last_name = "WILLIAMS";

-- 4d. Turns out that GROUCHO was the correct name after all. In a single query, 
-- if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO"
AND last_name = "WILLIAMS";

-- 5a. Cannot locate the schema of the address table. Use a query to re-create it.
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address,
-- of each staff member. Use the tables staff and address.
SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.
SELECT staff.first_name, staff.last_name, SUM(payment.amount) AS "Total Payments"
FROM staff
INNER JOIN payment ON staff.staff_id = payment.staff_id
GROUP BY staff.last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables 
-- film_actor and film. Use inner join.
SELECT film.title, COUNT(film_actor.actor_id) AS "Number of Actors"
FROM film
INNER JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY film.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system.
SELECT film.title, COUNT(inventory.film_id) AS "Number of Copies"
FROM film
INNER JOIN inventory ON film.film_id = inventory.film_id
GROUP BY film.title
HAVING film.title = "Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name.
SELECT customer.first_name, customer.last_name, SUM(payment.amount) AS "Total Payments"
FROM customer
INNER JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY customer.last_name
ORDER BY customer.last_name, first_name ASC;

-- 7a. Use subqueries to display the titles of movies starting with the letters K and Q 
-- whose language is English.
SELECT title
FROM film
WHERE language_id IN
    (
     SELECT language_id
     FROM language
     WHERE name = "English"
    )
    AND title LIKE 'K%' 
        OR 'Q%';

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
    (
     SELECT actor_id
     FROM film_actor
     WHERE film_id IN
        (
         SELECT film_id
         FROM film
         WHERE title IN ("Alone Trip")
        )
    );

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the 
-- names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT customer.email
FROM customer
INNER JOIN address ON customer.address_id = address.address_id
INNER JOIN city ON address.city_id = city.city_id
INNER JOIN country ON city.country_id = country.country_id
WHERE country.country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family 
-- movies for a promotion. Identify all movies categorized as family films.
SELECT film.title
FROM film
INNER JOIN film_category ON film.film_id = film_category.film_id
INNER JOIN category ON film_category.category_id = category.category_id
WHERE category.name = "Family";

-- 7e. Display the most frequently rented movies in descending order.
SELECT film.title, COUNT(rental.rental_id) AS "Number of Times Rented"
FROM film
INNER JOIN inventory ON film.film_id = inventory.film_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
GROUP BY film.title
ORDER BY COUNT(rental.rental_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, SUM(payment.amount) AS "Revenue"
FROM store
INNER JOIN staff ON store.store_id = staff.store_id
INNER JOIN payment ON staff.staff_id = payment.staff_id
GROUP BY store.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country
FROM store
INNER JOIN address ON store.address_id = address.address_id
INNER JOIN city ON address.city_id = city.city_id
INNER JOIN country ON city.country_id = country.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT category.name, SUM(payment.amount) AS "Gross Revenue"
FROM category
INNER JOIN film_category ON category.category_id = film_category.category_id
INNER JOIN inventory ON film_category.film_id = inventory.film_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
INNER JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY category.name
ORDER BY SUM(payment.amount) DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing 
-- the Top five genres by gross revenue.
CREATE VIEW top_five_genres AS
SELECT category.name, SUM(payment.amount) AS "Gross Revenue"
FROM category
INNER JOIN film_category ON category.category_id = film_category.category_id
INNER JOIN inventory ON film_category.film_id = inventory.film_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
INNER JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY category.name
ORDER BY SUM(payment.amount) DESC
LIMIT 5;

-- 8b. Display the newly created view
SELECT * FROM top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres;