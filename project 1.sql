--Q1:Who is the senior most employee based on job title?
select * from employee
order by levels desc
limit 1
--Answer: Madan Mohan

--Q2:Which countries have the most invoices?
select count(*) as c,billing_country 
from invoice 
group by billing_country
order by c desc
--Answer: USA

--Q3:What are the top 3 values of total invoice?
select total from invoice 
order by total desc
limit 3
--Answer: 23.76, 19.8,19.8

--Q4:Which city has the best customers? We would like to throw a
--promotional Music Festival in the city we made the most money. Write a
--query that returns one city that has the highest sum of invoice totals.
--Return both the city name & sum of all invoice totals
select sum(total)as t, billing_city
from invoice
group by billing_city
order by t desc
--Answer: Prague, 273.24

--Q5:Who is the best customer? The customer who has spent the most
--money will be declared the best customer. Write a query that returns
--the person who has spent the most money.
select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total)as total
from customer
join invoice on customer.customer_id=invoice.customer_id
group by customer.customer_id
order by total desc
limit 1


--Q6:Write query to return the email, first name, last name, & Genre
--of all Rock Music listeners. Return your list ordered alphabetically
--by email starting with A.
select distinct email, first_name, last_name
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
where track_id in(
    select track_id from track
	join genre on track.genre_id=genre.genre_id
	where genre.name like 'Rock'
)
order by email


--Q7:Let's invite the artists who have written the most rock music in
--our dataset. Write a query that returns the Artist name and total
--track count of the top 10 rock bands.
select artist.artist_id, artist.name, count (artist.artist_id) AS number_of_songs
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
Join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10


--Q8:Return all the track names that have a song length longer than
--the average song length. Return the Name and Milliseconds for
--each track. Order by the song length with the longest songs listed
--first.
select name, milliseconds
from track
where milliseconds > (
select avg(milliseconds) as avg_track_length
from track)
order by milliseconds desc


--Q9:Find how much amount spent by each customer on artists? Write 
--a query to return customer name, artist name and total spent.
with best_selling_artist as( 
SELECT artist.artist_id AS artist_id, artist.name AS artist_name,
SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
FROM invoice_line
JOIN track ON track.track_id = invoice_line.track_id
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
GROUP BY 1
ORDER BY 3 DESC
LIMIT 1
 )
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name,
SUM (il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;


--Q10:We want to find out the most popular music genre for each country
--We determine the most popular genre as the genre with the highest
--amount of purchases. Write a query that returns each country along with
--the top genre. For countries where the maximum number of purchases is shared among all genres.
with popular_genre as 
(
 select count(invoice_line.quantity)as purchases, customer.country, genre.name, genre.genre_id,
 row_number()over(partition by customer.country order by count(invoice_line.quantity)desc)
 as RowNo
 from invoice_line
 join invoice on invoice.invoice_id=invoice_line.invoice_id
 join customer on customer.customer_id=invoice.customer_id
 join track on track.track_id=invoice_line.track_id
 join genre on genre.genre_id=track.genre_id
 group by 2,3,4
 order by 2 asc, 1 desc
	)
select * from popular_genre where RowNo<=1


--Q11:Write a query that determines the customer that has spent the most on music for each country.
--Write a query that returns the country along with the top customer and how much they spent.
--For countries where the top amount spent is shared, provide all customers who spent this amount.
with customer_with_country as (
select customer.customer_id,first_name,last_name,billing_country,sum(total)as total_spending,
	row_number() over (partition by billing_country order by sum(total)desc)as RowNo
	from invoice
	join customer on customer.customer_id=invoice.customer_id
	group by 1,2,3,4
	order by 4 asc,5 desc)
select*from customer_with_country where RowNo<=1	

	
				  
