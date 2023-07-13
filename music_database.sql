create database music_database;

-- Q1: who is the senior most employee based on job title?

select * from employee
order by levels desc
limit 1;


-- Q2: Which countries have the most Invoices?


select count(*), billing_country from invoice 
group by billing_country
order by count(*) desc;


-- Q3: What are top 3 values of total invoice?


select *  from invoice 
order by total desc
limit 3;


-- Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money.
-- Write a query that returns one city that has the highest sum of invoice totals. 
-- Return both the city name & sum of all invoice totals


select billing_city, sum(total)  as invoice_total from invoice
group by billing_city 
order by invoice_total desc 
limit 1;


-- Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money.

select c.customer_id , c.first_name , c.last_name , sum(i.total) as total_spending
from customer c 
join invoice i 
on c.customer_id = i.customer_id 
group by c.customer_id , c.first_name , c.last_name
order by total_spending desc
limit 1;


-- Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A.


select distinct c.email , c.first_name , c.last_name , g.name 
from customer c 
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id 
join track t on il.track_id = t.track_id 
join genre g on t.genre_id = g.genre_id
where g.name like('rock')
order by email asc ;



-- Q7: Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands.


select a.artist_id , a.name , count(a.artist_id) as track_count
from artist a 
join album2 al on a.artist_id = al.artist_id 
join track t on al.album_id = t.album_id
join genre g on t.genre_id = g.genre_id
where g.name like('rock')
group by a.artist_id, a.name
order by track_count desc
limit 10;



-- Q8: Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.


select name , milliseconds 
from track 
where milliseconds > 
(
select avg(milliseconds) as avg_song_length from track )
order by milliseconds;


-- Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album2 ON album2.album_id = track.album_id
	JOIN artist ON artist.artist_id = album2.artist_id
	GROUP BY 1,2
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album2 alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;



-- Q10: We want to find out the most popular music Genre for each country.
-- Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres.



WITH country_genre_sales AS (
    SELECT c.country, g.name AS genre, SUM(il.quantity) AS total_purchases,
	RANK() OVER (PARTITION BY c.country ORDER BY SUM(il.quantity) DESC) AS genre_rank      
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    GROUP BY c.country, g.name
)
SELECT country, genre
FROM country_genre_sales
where genre_rank = 1
ORDER BY country;
