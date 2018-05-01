## Homework Assignment
use sakila;

# 1a. You need a list of all the actors who have Display the first and last names of all actors from the table `actor`. 
select distinct first_name,last_name from actor

# 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`. 
select concat(upper(first_name),' ',upper(last_name)) as 'Actor Name' from actor

# 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id,first_name,last_name from actor where first_name = 'joe'

# 2b. Find all actors whose last name contain the letters `GEN`:
select * from actor where last_name like '%g%' and last_name like '%e%' and last_name like '%n%'
  	
# 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
select first_name, last_name from actor where last_name like '%l%' and last_name like '%i%' order by first_name, last_name

# 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id,country from country where country in ('Afghanistan','Bangladesh','China')

# 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.
ALTER TABLE `sakila`.`actor` 
ADD COLUMN `middle_name` VARCHAR(45) NULL AFTER `first_name`;
  	
# 3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.
ALTER TABLE `sakila`.`actor` 
CHANGE COLUMN `middle_name` `middle_name` BLOB NULL DEFAULT NULL ;

# 3c. Now delete the `middle_name` column.
ALTER TABLE `sakila`.`actor` 
DROP COLUMN `middle_name`;

# 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(distinct actor_id) as actors from actor group by 1
  	
# 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(distinct actor_id) as actors from actor group by 1 having actors>1 actor
 	
# 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
#SELECT * FROM ACTOR WHERE FIRST_NAME='GROUCHO' AND LAST_NAME='WILLIAMS'
UPDATE actor SET first_name = 'HARPO' WHERE first_name = 'GROUCHO'
#SELECT * FROM ACTOR WHERE FIRST_NAME='HARPO' AND LAST_NAME='WILLIAMS'
  	
# 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)
UPDATE actor SET first_name = 'GROUCHO' WHERE first_name = 'HARPO'

# 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ADDRESS'

# 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
select distinct first_name,last_name,address
from staff s
inner join address a
	on s.address_id = a.address_id

# 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`. 
select s.staff_id ,first_name ,last_name
	,sum(amount) as total_amt
from staff s
inner join payment p
	on s.staff_id = p.staff_id
where payment_date between '2005-08-01' and '2005-08-31'
group by 1,2,3

# 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select title, count(distinct actor_id) as actors
from film f
inner join film_actor fa
	on f.film_id = fa.film_id
group by 1

# 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select count(distinct inventory_id) as copies
from film f
inner join inventory i
on f.film_id = i.film_id
where title = 'Hunchback Impossible'

# 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
select last_name, sum(amount) as ttl_payment
from customer c
inner join payment p
on c.customer_id = p.customer_id
group by 1
order by 1

# 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English. 
select distinct title
from film  f
inner join language l
	on f.language_id =l.language_id
where l.name = 'English'
and (f.title like 'q%' or f.title like 'k%')

# 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select distinct first_name, last_name
from actor
where actor_id in 
(select distinct actor_id from film_actor fa inner join film f on fa.film_id = f.film_id where title = 'Alone Trip')
   
# 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select customer_id, email
from customer
where customer_id in
(select distinct customer_id
from customer c
inner join address a
on c.address_id = a.address_id
inner join city ci
	on a.city_id = ci.city_id
inner join country co
	on ci.country_id = co.country_id
where country = 'canada')

# 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.

select distinct title from film where film_id in 
	(select film_id from film_category where film_id in 
		(select category_id from category where name = 'family')
	)

# 7e. Display the most frequently rented movies in descending order.

select title,sum(rentals) as rentals
from
	(select inventory_id,count(rental_id) as rentals from rental group by 1) as r
inner join inventory i
on r.inventory_id = i.inventory_id
inner join film f
on i.film_id = f.film_id
group by 1
order by 2 desc

# 7f. Write a query to display how much business, in dollars, each store brought in.

select store_id,sum(sales) as sales from staff s
inner join 
(select staff_id,sum(amount) as sales from payment group by 1) as p
on s.staff_id = p.staff_id
group by 1

# 7g. Write a query to display for each store its store ID, city, and country.

select store_id,city,country
from store s
inner join address a
	on s.address_id = a.address_id
inner join city c
	on a.city_id = c.city_id
inner join country co
	on c.country_id = co.country_id

# 7h. List the top five genres in gross revenue in descending order. (##Hint##: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

  	
# 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
  	
# 8b. How would you display the view that you created in 8a?

# 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
