/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: *****
Password: *****

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */


 SELECT * 
FROM Facilities
WHERE (
membercost !=0
)

/* Q2: How many facilities do not charge a fee to members? */

SELECT * 
FROM Facilities
WHERE (
membercost =0
)

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT DISTINCT name
FROM Facilities
WHERE membercost / monthlymaintenance <= 0.2

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
select distinct name from Facilities where facid in (1,5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
select name, monthlymaintenance, 
case when monthlymaintenance<= 100 then 'cheap' else 'expensive' end as cheap_exp
from Facilities 

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

select a.firstname, a.surname, joindate from Members a
where a.joindate = (select max(b.joindate) from Members b)


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

select distinct concat(a.firstname, ' ', a.surname) as Full_name, 
(select c.name from Facilities c where c.facid = b.facid) as Facility_name
from Members a join Bookings b on b.memid = a.memid
where b.facid in (0,1)
order by 1


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT concat(m.firstname, ' ', m.surname) as Full_name, b.memid, f.name, b.slots * f.membercost as day_cost FROM Bookings b
join Facilities f on f.facid = b.facid
join Members m on m.memid = b.memid
WHERE left(starttime, 10) = '2012-09-14'
and b.memid > 0
and b.slots * f.membercost > 30
UNION
SELECT concat(m.firstname, ' ', m.surname) as Full_name,b.memid, f.name, b.slots * f.guestcost as day_cost FROM Bookings b
join Facilities f on f.facid = b.facid
join Members m on m.memid = b.memid
WHERE left(starttime, 10) = '2012-09-14'
and b.memid = 0
and b.slots * f.guestcost > 30
order by 4 desc

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

select sub.* from
(SELECT concat(m.firstname, ' ', m.surname) as Full_name, b.memid, f.name, b.slots * f.membercost as day_cost FROM Bookings b
join Facilities f on f.facid = b.facid
join Members m on m.memid = b.memid
WHERE left(starttime, 10) = '2012-09-14'
and b.memid > 0

UNION
SELECT concat(m.firstname, ' ', m.surname) as Full_name,b.memid, f.name, b.slots * f.guestcost as day_cost FROM Bookings b
join Facilities f on f.facid = b.facid
join Members m on m.memid = b.memid
WHERE left(starttime, 10) = '2012-09-14'
and b.memid = 0
order by 4 desc) sub
where sub.day_cost > 30

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

select sub2.*
from
(select sub.name, sum(cost) as total_cost
from
(SELECT b.facid, f.name, b.slots,  b.slots * f.membercost as cost FROM `Bookings` b 
JOIN Facilities f on f.facid = b.facid
where b.memid > 0
UNION
SELECT b.facid, f.name, b.slots,  b.slots * f.guestcost as cost FROM `Bookings` b 
JOIN Facilities f on f.facid = b.facid
where b.memid = 0) sub
group by 1
order by 2 desc) sub2
where sub2.total_cost < 1000
