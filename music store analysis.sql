

select * from album;
select * from artist;
select * from customer;
select * from employee;
select * from genre;
select * from invoice;
select * from invoice_line;
select * from media_type;
select * from playlist;
select * from playlist_track;
select * from track;


-- Q1 Who is the senior most employee based on job title? 
select employee_id,first_name,last_name,title
from employee
order by levels desc
limit 1;

-- Q2 Which countries have the most Invoices? */
select billing_country
from invoice
group by 1
order by count(*) desc;

-- Q3: What are top 3 values of total invoice? *
select  invoice_id
from invoice
order by total desc
limit 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select billing_city as city,sum(total)as total
from invoice
group by 1
order by total desc
limit 1;

-- 
/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select customer.customer_id,customer.first_name,customer.last_name,sum(total) as total
from invoice
join customer on invoice.customer_id=customer.customer_id
group by 1,2,3
order by total desc 
limit 1;

-- /* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners .
   -- Return your list ordered alphabetically by email starting with A. */
   
   select distinct email as email, a.customer_id,first_name,last_name
   from customer a
   join invoice b
   on a.customer_id=b.customer_id 
   join invoice_line c
   on b.invoice_id=c.invoice_id
   join track d
   on c.track_id=d.track_id
   join genre e
   on d.genre_id=e.genre_id
   where e.name='rock'
   order by email 
   ;
   
   
   
   -- /* Q7: Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands.

select  (a.name)as name,count(playlist_id) as cnt
from artist a
join album b
on a.artist_id=b.artist_id
join track c
on b.album_id=c.album_id
join playlist_track d
on c.track_id=d.track_id
join genre e
on c.genre_id=e.genre_id
where e.name='rock'
group by 1
order by cnt desc
limit 10;


-- /* Q8: Return all the track names that have a song length longer than the average song length. 
 -- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
select name,milliseconds
from track
where milliseconds>(select avg(milliseconds)
                     from track)
                     order by milliseconds desc;
                           
/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

select concat(a.first_name,' ',a.last_name)as name,f.name,SUM(c.unit_price * c.quantity) as total_spent
from customer a
left join invoice b
on a.customer_id=b.customer_id
left  join invoice_line c
on b.invoice_id=c.invoice_id
left join track d
on c.track_id=d.track_id
join album e
on e.album_id=d.album_id
join artist f
on e.artist_id=f.artist_id
group by 1,2
order by total_spent desc;



-- /* Q10: Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount. */

with recursive cte as(
select country,first_name,last_name,sum(total) as total
from customer
join invoice on customer.customer_id=invoice.customer_id
group by 1,2,3
),
cte2 as(
select country,max(total) as max_total
from cte
group by 1
)
select cte.country,cte.first_name,last_name,total
from cte
join cte2
on cte.country=cte2.country and cte.total=max_total
order by 1 ;

-- /* Q11: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
-- with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
-- the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */


with cte as(
select invoice.billing_country as country,genre.name as genre_name,count(invoice_line.quantity)as purchases,
row_number()over(partition by invoice.billing_country order by count(invoice_line.quantity) desc)as rn
FROM invoice_line
		JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN genre ON genre.genre_id = track.genre_id
group by 1,2
order by 3 desc,2,1)
select *
from cte 
where rn<=1