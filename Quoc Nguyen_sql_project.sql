/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

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


/* Q2: How many facilities do not charge a fee to members? */


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */


/* Q9: This time, produce the same result as in Q8, but using a subquery. */


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name AS 
names FROM  `Facilities` 
WHERE  `membercost` != 0.0
LIMIT 0 , 30

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT( name ) AS no_fee
FROM  `Facilities` 
WHERE  `membercost` = 0.0


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT  `facid` ,  `name` ,  `membercost` ,  `monthlymaintenance` 
FROM  `Facilities` 
WHERE  `membercost` != 0.0
AND  `membercost` <  `monthlymaintenance` * 0.2
LIMIT 0 , 30


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT * 
FROM  `Facilities` 
WHERE  `facid` 
IN ( 1, 5 ) 
LIMIT 0 , 30


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT  `name` ,  `monthlymaintenance` , 
CASE WHEN  `monthlymaintenance` > 100.00
THEN  'expensive'
ELSE  'cheap'
END AS label
FROM  `Facilities` 



/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT surname,firstname FROM `Members`
WHERE joindate IN (SELECT MAX(joindate) FROM `Members`)


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT o.court_name AS Court,
       CONCAT(m.surname,' ',m.firstname) AS Name
FROM `Members` m
JOIN (SELECT bk.memid AS memid,
	   ten.facid AS facid,
       ten.name AS court_name
FROM `Bookings` bk
JOIN (SELECT f.facid,f.name FROM `Facilities` f WHERE f.name LIKE 'tennis%') ten
ON bk.facid = ten.facid) o
ON m.memid = o.memid
GROUP BY 1,2
ORDER BY 2


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f.name AS Court_name, CONCAT(m.surname,' ',m.firstname) AS Name, 
	   CASE WHEN m.memid = 0 THEN b.slots*f.guestcost ELSE b.slots*f.membercost END AS Total_cost
FROM `Members` m
JOIN `Bookings` b
ON m.memid = b.memid
JOIN `Facilities` f
ON b.facid = f.facid
WHERE LEFT(b.starttime,10) = '2012-09-14' AND (CASE WHEN m.memid = 0 THEN b.slots*f.guestcost ELSE b.slots*f.membercost END) > 30.0
ORDER BY Total_cost DESC


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT o.court_name, CONCAT(m.surname,' ',m.firstname) AS Name, 
	   CASE WHEN m.memid = 0 THEN o.slots*o.guestcost ELSE o.slots*o.membercost END AS Total_cost
FROM `Members` m
JOIN (SELECT b.memid as memid,
 		f.name AS court_name,
      	b.starttime AS starttime,
      	b.slots as slots,
        f.guestcost as guestcost,
 		f.membercost as membercost
FROM `Bookings` b
JOIN `Facilities` f
ON b.facid = f.facid) o
ON m.memid = o.memid
WHERE LEFT(o.starttime,10) = '2012-09-14' AND (CASE WHEN m.memid = 0 THEN o.slots*o.guestcost ELSE o.slots*o.membercost END) > 30.0
ORDER BY Total_cost DESC


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT *
FROM (SELECT sub.Court_name AS Facility,
	   sum(sub.Total_cost) AS Revenue
FROM (SELECT f.name AS Court_name, CONCAT(m.surname,' ',m.firstname) AS Name, 
	   CASE WHEN m.memid = 0 THEN b.slots*f.guestcost ELSE b.slots*f.membercost END AS Total_cost
FROM `Members` m
JOIN `Bookings` b
ON m.memid = b.memid
JOIN `Facilities` f
ON b.facid = f.facid
ORDER BY Total_cost DESC) sub
group by 1) o
WHERE o.Revenue < 1000.0