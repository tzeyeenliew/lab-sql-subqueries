USE sakila;
### 1.How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT film_id, COUNT(inventory_id) AS total_copies # I'm assuming that each copy has a unique inventory ID and not grouped under a singular one
FROM inventory
WHERE film_id IN (SELECT film_id FROM film WHERE title= 'Hunchback Impossible')
GROUP BY film_id;

### 2.List all films whose length is longer than the average of all the films.

SELECT film_id, title, length AS length_of_film
FROM film
WHERE length > (SELECT AVG(length) from film);

### 3.Use subqueries to display all actors who appear in the film Alone Trip.


SELECT a.actor_id, CONCAT(a.first_name,' ',a.last_name) as name
FROM actor AS a
JOIN film_actor AS B
ON a.actor_id = b.actor_id
WHERE film_id IN (SELECT film_id
                  FROM film 
                  WHERE title = 'Alone Trip');


### 4.Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.


SELECT  DISTINCT name, category_id # To determine the exact category name for family films, which wasn't specified in the question (It's 'family', ID=8)
FROM category;

SELECT film_id, title AS family_films
FROM film
WHERE film_id IN (SELECT film_id 
                  FROM film_category 
                  WHERE category_id = '8');

### 5.Get name and email from customers from Canada using subqueries. Do the same with joins. 

### Via subqueries ...not sure if the city name was necessary

SELECT city, city_id, country_id
FROM city 
WHERE country_id IN (SELECT country_id 
					FROM country 
					WHERE country ='Canada');


SELECT customer_id, CONCAT(first_name, ' ', last_name) AS name, email
FROM customer
WHERE address_id IN (SELECT address_id 
                     FROM address
                     WHERE city_id in (565, 430, 383, 313, 300, 196, 179 ));
                     

                     
### Using Joins


SELECT a.customer_id, CONCAT(a.first_name,' ', a.last_name) AS name, a.email
FROM customer AS A
JOIN address AS B
USING (address_id)
JOIN city AS C
USING (city_id)
JOIN country as D
USING (country_id)
WHERE country = 'Canada';




### 6.Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
### First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

SELECT actor_id, COUNT(film_id) as film_count
FROM film_actor
GROUP BY actor_id
ORDER BY COUNT(film_id) DESC
LIMIT 1;

# Actor_ID 107 has starred in a total of 42 films. RANK function used to tally numer of films, just to crosscheck

SELECT c.actor_id, CONCAT(c.first_name, ' ', c.last_name) AS name, a.film_id, a.title, RANK () OVER (ORDER BY a.film_id ASC) AS film_tally
FROM film AS a 
JOIN film_actor AS b
USING (film_id)
JOIN actor AS C
USING (actor_id)
WHERE a.film_id IN (SELECT a.film_id 
				    FROM film_actor 
                    WHERE b.actor_id = 107); # Actor_ID 107 has starred in a total of 42 films. RANK function used to tally numer of films, just to crosscheck
                    

### 7.Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer 


SELECT customer_id, CONCAT('$', sum(amount)) AS total_payments #The most profitable customer's id is 526, who has spent a total of $221.55 on rentals
FROM payment
GROUP BY customer_id
ORDER BY sum(amount) DESC
LIMIT 1;

SELECT title
FROM rental AS A 
JOIN inventory AS B
USING (inventory_id)
JOIN film AS C
USING (film_id)
WHERE a.customer_id= 526;

-------------------------------------------------------------
### ALTERNATIVE METHOD, but I prefer the first one because it's more readable

SELECT title
FROM film as A
JOIN inventory AS B
USING (film_id)
JOIN rental AS C
USING (inventory_id)
WHERE customer_id IN (SELECT customer_id 
                      FROM
                      (SELECT customer_id, sum(amount) 
                      AS total_amount
                      FROM payment
				      GROUP BY customer_id
                      ORDER BY total_amount DESC
					  LIMIT 1) AS subtable);


### 8.Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.

SELECT CONCAT('$', ' ', ROUND(AVG(total_amount), 2)) AS average_amount  #So that I have the average amount as rewference
FROM (SELECT customer_id, sum(amount) as total_amount
      FROM payment
	GROUP BY customer_id) AS subtable;

SELECT customer_id, CONCAT('$', ' ', SUM(amount)) AS total_amount_spent
FROM payment
GROUP BY customer_id
HAVING sum(amount) > (SELECT AVG(total_amount)
                     FROM 
                     (SELECT customer_id, sum(amount) AS total_amount
                      FROM payment
                      GROUP BY customer_id)
                      AS subtable)
ORDER BY total_amount_spent ASC;

