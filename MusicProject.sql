--Who is the senior most employee based on the job title ?

select * from employee 
order by levels desc 
limit 1;

--Which countries have the most invoices 
select billing_country, count(*) as c from invoice 
group by billing_country
order by c desc

--What are top 3 values of total invoice
select total from invoice
order by total desc limit 3

--which city has the best customers
select customer.city,sum(invoice.total) as total_spent from customer
join invoice on invoice.customer_id = customer.customer_id
group by customer.city
order by total_spent desc
limit 1;

--Who is the best customer
select concat(customer.first_name,' ',customer.last_name) as customer_name,
sum(invoice.total) as money_spent
from customer join invoice on
invoice.customer_id=customer.customer_id
group by customer_name
order by money_spent desc limit 1;
 --write query to return the email, first name, last name, genre of all rock music listeners
 --Return your list ordered alphabetically by email starting  with A

 select distinct email,first_name,last_name from customer
 join invoice on invoice.customer_id = customer.customer_id
 join invoice_line on invoice_line.invoice_id= invoice.invoice_id
 where track_id IN (select track_id from track
 		join genre on genre.genre_id=track.genre_id
		 where genre.name like 'Rock')
 order by email

-- Write a query that returns 
-- the Artist name and total total track count of the  top 10 rock bands 

SELECT 
    artist.artist_id,artist.name,
    COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album 
    ON album.album_id = track.album_id
JOIN artist 
    ON artist.artist_id = album.artist_id
JOIN genre 
    ON genre.genre_id = track.genre_id
WHERE genre.name ILIKE 'rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;

-- Return all the track names that have a song length longer than the average song length
-- Return the name and miliseconds for each track .Order by song length with the longest 
-- Order by song length with the longest song listed first 
select * from track
select name ,milliseconds from track
where milliseconds > (select avg(milliseconds) as avg_track_length
from track )
order by milliseconds DESC;

-- Find how much amount spent by each customers on artists ? write query to return customer 
--name,artist name and total spent

with best_selling_artist as (
select artist.artist_id as artist_id, artist.name as artist_name,
sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
from invoice_line
Join track on track.track_id = invoice_line.track_id
Join album on album.album_id = track.album_id 
Join artist on artist.artist_id =album.artist_id
group by 1
order by 3 desc 
limit 1)
select c.customer_id,c.first_name,c.last_name, bsa.artist_name, sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
Join track t on t.track_id = il.track_id
Join album alb on alb.album_id = t.album_id
Join best_selling_artist bsa on bsa .artist_id = alb.artist_id
group by 1,2,3,4
order by 5 Desc;

-- Find Most popular music Genre for each country country.
--(we determine the most popular genre as the genre with the highest amount )

With popular_genre as 
(select count(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id,
row_number() over(partition by customer.country order by count(invoice_line.quantity) DESC) as Rowno
from invoice_line 
Join invoice on invoice.invoice_id = invoice_line.invoice_id
Join customer on customer.customer_id =invoice.customer_id
Join track on track.track_id = invoice_line.track_id
Join genre on genre.genre_id = track.genre_id
group by 2,3,4
Order by 2 asc,1 desc
)

select * from popular_genre 
where rowno <=1

-- Write a query that determines the customer that has spent most on the music for each country.
-- Write a query that returns the country along withn the top customer and how much they spent.
-- For countries where top amount is shared, provide all customers who spent this amount

WITH customer_with_country AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        i.billing_country,
        SUM(i.total) AS total_spending
    FROM invoice i
    JOIN customer c ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, i.billing_country
),
country_max_spending AS (
    SELECT 
        billing_country, 
        MAX(total_spending) AS max_spending
    FROM customer_with_country
    GROUP BY billing_country
)
SELECT 
    cc.billing_country, 
    cc.total_spending, 
    cc.first_name, 
    cc.last_name, 
    cc.customer_id
FROM customer_with_country cc
JOIN country_max_spending ms
  ON cc.billing_country = ms.billing_country
 AND cc.total_spending = ms.max_spending 
ORDER BY cc.billing_country;





