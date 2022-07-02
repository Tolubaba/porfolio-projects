SELECT * FROM  dbo.donation_data
SELECT * FROM  dbo.donor_datav2

SELECT * FROM dbo.Donation_Data dd JOIN dbo.Donor_Datav2 dv
ON 
dd.id=dv.id
--to view the total number of donors that donated and the total donations gotten from the chairty
 SELECT COUNT(dv.id) AS donors,SUM(donation) AS total_donations
 FROM Donation_Data dd JOIN
 Donor_Datav2 dv ON 
 dd.id=dv.id
WHERE donation_frequency!='Never'

-- to view gender count ratio of actual donors and total donations
SELECT gender, COUNT(DISTINCT(dv.id)) AS number_of_donors, SUM(donation) AS total_donations
FROM Donation_Data dd JOIN Donor_Datav2 dv  
ON dd.id=dv.id 
WHERE donation_frequency != 'Never'
GROUP BY gender
ORDER BY 2 DESC

-- to view the gender count ratio of donors that pledge to donate but never did 
SELECT gender, COUNT(DISTINCT(dv.id)) AS nuumber_of_donors,
SUM (donation) AS total_donations
FROM Donation_Data dd JOIN Donor_Datav2 dv
ON dd.id=dv.id
WHERE donation_frequency ='Never'
GROUP BY gender
ORDER BY 2

-- to view all the states with donors
SELECT DISTINCT state FROM Donation_Data
-- to  view the total number of the states
SELECT COUNT(DISTINCT (state)) AS total_number_of_states FROM Donation_Data
-- to view the number of  donors and total donation per state in descedning order
SELECT state, COUNT(DISTINCT(dv.id)) AS number_of_donors, SUM(donation) AS total_donations
FROM donation_data  dd
JOIN
donor_datav2 dv
ON dd.id=dv.id
WHERE donation_frequency !='Never'
 GROUP BY state 
ORDER BY 3 DESC

-- to view number of donors and total donation per job field in  descending order
SELECT job_field, COUNT( DISTINCT (dv.id)) AS number_of_donors, SUM(donation) AS total_donations
FROM donation_data dd
JOIN
donor_datav2 dv
ON
dd.id=dv.id
WHERE donation_frequency !='Never'
GROUP BY job_field
ORDER BY 3 DESC

-- to  view the total number of donors and total donation per frequency in descending order
SELECT donation_frequency, COUNT(DISTINCT( dv.id)) AS number_of_donors, SUM(donation) AS total_donations
FROM Donation_Data dd
JOIN
Donor_Datav2 dv
ON
dd.id=dv.id
GROUP BY donation_frequency
ORDER BY 2 DESC
-- Using subqueries to view donors and their total donations after further grouping the frequency of donations into 2 categories 'frequent' and 'less frequent'
SELECT T1.frequency, COUNT(T2.id) AS number_of_donors,SUM(T2.donation) AS total_donations
FROM (SELECT job_field,dv.id AS id, donation,donation_frequency,
CASE
WHEN donation_frequency ='Never'
OR donation_frequency='Once'
OR donation_frequency='Seldom'
OR donation_frequency='Yearly' THEN 'less frequent'
ELSE 'frequent'
END AS frequency
FROM Donation_Data dd
JOIN
Donor_Datav2 dv
ON dd.id=dv.id)	T1

JOIN
(SELECT job_field,dv.id AS id, donation,donation_frequency,
CASE
WHEN donation_frequency ='Never'
OR donation_frequency='Once'
OR donation_frequency='Seldom'
OR donation_frequency='Yearly' THEN 'less frequent'
ELSE 'frequent'
END AS frequency
FROM Donation_Data dd
JOIN
Donor_Datav2 dv
ON dd.id=dv.id)	T2
ON T1.id=T2.id
GROUP BY T1.frequency
ORDER BY 3 DESC



-- To view the gender ratio of frequent and less frequent donors and total donations 
SELECT T1.gender, T1. frequency, COUNT(T2.id) AS number_of_donors, SUM(T2.donation) AS total_donations
FROM( SELECT gender, dv.id as id, donation, donation_frequency,
CASE
WHEN donation_frequency ='Never'
OR donation_frequency='Once'
OR donation_frequency='Seldom'
OR donation_frequency='Yearly' THEN 'less frequent'
ELSE 'frequent'
END AS frequency
FROM Donation_Data dd
JOIN
Donor_Datav2 dv
ON
dd.id=dv.id)T1
JOIN
(SELECT gender, dv.id as id, donation, donation_frequency,
CASE
WHEN donation_frequency ='Never'
OR donation_frequency='Once'
OR donation_frequency='Seldom'
OR donation_frequency='Yearly' THEN 'less frequent'
ELSE 'frequent'
END AS frequency
FROM Donation_Data dd
JOIN
Donor_Datav2 dv
ON
dd.id=dv.id)T2
ON
T1.id=T2.id
GROUP BY T1.gender,T1.frequency
ORDER BY T1.gender


-- To view the number of frequent and less frequent donors and total donations from the different job fields
SELECT T1.job_field, T1.frequency, COUNT(T2.id) AS number_of_donors , SUM(T2.donation) total_donation
FROM ( SELECT job_field, dv.id as id, donation, donation_frequency,
CASE
WHEN donation_frequency ='Never'
OR donation_frequency='Once'
OR donation_frequency='Seldom'
OR donation_frequency='Yearly' THEN 'less frequent'
ELSE 'frequent'
END AS frequency
FROM Donation_Data dd
JOIN 
Donor_Datav2 dv
ON dd.id=dv.id) T1

JOIN
( SELECT job_field, dv.id as id, donation, donation_frequency,
CASE
WHEN donation_frequency ='Never'
OR donation_frequency='Once'
OR donation_frequency='Seldom'
OR donation_frequency='Yearly' THEN 'less frequent'
ELSE 'frequent'
END AS frequency
FROM Donation_Data dd
JOIN 
Donor_Datav2 dv
ON dd.id=dv.id) T2
ON
T1.id=T2.id
GROUP BY T1.job_field,T1.frequency
ORDER BY T1.job_field

-- To get information on the top 10 frequent donors based on the value of their donation
SELECT  TOP 10 T2.id  AS id,  
		T1.name, 
		T1.gender, 
		T1.state, 
		T1.university, 
		T1.job_field, 
		T1.frequency, 
		T2.donation AS donation
FROM (SELECT job_field, CONCAT(first_name,' ', last_name) AS name,
		dv.id AS id,
		gender,
		state,
		university,
		donation,
		donation_frequency,
		CASE
WHEN donation_frequency ='Never'
OR donation_frequency='Once'
OR donation_frequency='Seldom'
OR donation_frequency='Yearly' THEN 'less frequent'
ELSE 'frequent'
END AS frequency
FROM Donation_Data dd
JOIN
Donor_Datav2 dv
ON
dd.id=dv.id) T1

JOIN

(SELECT  job_field, CONCAT(first_name,' ', last_name) AS name,
		dv.id AS id,
		donation,
		donation_frequency,
CASE
WHEN donation_frequency ='Never'
OR donation_frequency='Once'
OR donation_frequency='Seldom'
OR donation_frequency='Yearly' THEN 'less frequent'
ELSE 'frequent'
END AS frequency
FROM Donation_Data dd
JOIN
Donor_Datav2 dv
ON
dd.id=dv.id) T2
ON
T1.id=T2.id
WHERE T1.frequency='frequent'
ORDER BY T1.frequency

--- to view information on donors that pledge to donate but never did
SELECT T2.id AS id, 
			T1.name,
			T1.gender,
			T1.email,
			T2.state,
			T2.university,
			T2.job_field,
			T1.donation
FROM (SELECT dv.id as id, CONCAT( first_name,' ',last_name) AS name,
				gender,
				email,
				donation,
				donation_frequency
		FROM Donation_Data dd
		JOIN
		Donor_Datav2 dv
		ON
		dd.id=dv.id)T1
JOIN

(SELECT dv.id as id,state,university, job_field
		FROM Donation_Data dd
		JOIN
		Donor_Datav2 dv
		ON
		dd.id=dv.id)T2
		ON T1.id=T2.id
WHERE T1.donation_frequency='Never'
ORDER BY T1.name

--To view the gender count ratio of donors that pledged to donate but never did but acquired a tertiary education.

SELECT T1.gender,COUNT(T1.university) AS number_of_donors, SUM(T1.donation) AS total_donations
FROM (SELECT job_field,gender,university,dv.id, donation,donation_frequency
FROM Donation_Data dd
JOIN
Donor_Datav2 dv
ON
dd.id=dv.id
WHERE university is NOT NULL) T1

JOIN
(SELECT job_field,gender,university,
		dv.id as id,
		donation,
		donation_frequency
		FROM donation_data dd
		JOIN
		donor_datav2 dv
		ON
		dd.id=dv.id
		WHERE university is NOT NULL) T2
		ON
		T1.id =T2.id
		WHERE T1.donation_frequency='Never'
	GROUP BY T1.gender







		


