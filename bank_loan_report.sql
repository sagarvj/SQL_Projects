SELECT * FROM bank_loan


--Total loan application
SELECT COUNT(id) AS Total_Loan_Applications 
FROM bank_loan

--Total loan application (Month-to-Date)
SELECT COUNT(id) AS MTD_Total_Loan_Applications 
FROM bank_loan
WHERE EXTRACT(MONTH FROM issue_date) = 12 
AND EXTRACT(YEAR FROM issue_date) = 2021

--Total loan application (Previous Month-to-Date)
SELECT COUNT(id) AS PMTD_Total_Loan_Applications
FROM bank_loan
WHERE EXTRACT(MONTH FROM issue_date) = 11 
AND EXTRACT(YEAR FROM issue_date) = 2021

--MoM = (MTD - PTD)/PTD


--Total Funded amount
SELECT SUM(loan_amount) AS Total_funded_amount 
FROM bank_loan

--MTD
SELECT SUM(loan_amount) AS Total_funded_amount 
FROM bank_loan
WHERE EXTRACT(MONTH FROM issue_date) = 12 
AND EXTRACT(YEAR FROM issue_date) = 2021

--PMTD
SELECT SUM(loan_amount) AS Total_funded_amount 
FROM bank_loan
WHERE EXTRACT(MONTH FROM issue_date) = 11 
AND EXTRACT(YEAR FROM issue_date) = 2021

--Total payment
SELECT SUM(total_payment) AS Total_amount_received 
FROM bank_loan

--MTD
SELECT SUM(total_payment) AS Total_amount_received 
FROM bank_loan
WHERE EXTRACT(MONTH FROM issue_date) = 12 
AND EXTRACT(YEAR FROM issue_date) = 2021

--PMTD
SELECT SUM(total_payment) AS Total_amount_received FROM bank_loan
WHERE EXTRACT(MONTH FROM issue_date) = 11 
AND EXTRACT(YEAR FROM issue_date) = 2021


--Average interest rate
SELECT AVG(int_rate) * 100
FROM bank_loan

--MTD
SELECT AVG(int_rate) * 100
FROM bank_loan
WHERE EXTRACT(MONTH FROM issue_date) = 12 
AND EXTRACT(YEAR FROM issue_date) = 2021

--PMTD
SELECT AVG(int_rate) * 100
FROM bank_loan
WHERE EXTRACT(MONTH FROM issue_date) = 11 
AND EXTRACT(YEAR FROM issue_date) = 2021


--Debt to income ratio
--MTD
SELECT AVG(dti) * 100 AS Avg_DTI 
FROM bank_loan
WHERE EXTRACT(MONTH FROM issue_date) = 12 
AND EXTRACT(YEAR FROM issue_date) = 2021

--PMTD
SELECT AVG(dti) * 100 AS Avg_DTI 
FROM bank_loan
WHERE EXTRACT(MONTH FROM issue_date) = 11 
AND EXTRACT(YEAR FROM issue_date) = 2021


--Good Loan percentage
SELECT 
	(COUNT(CASE WHEN loan_status = 'Fully Paid' OR loan_status = 'Current' THEN id END) *100)
	/
	COUNT(id) AS Good_loan_percentage
FROM bank_loan


--Good Loan Application
SELECT COUNT(id) AS Good_loan_Application
FROM bank_loan
WHERE loan_status = 'Fully Paid' OR
loan_status = 'Current'


--Good Loan Funded Amount
SELECT SUM(loan_amount) AS Good_loan_Funded_Amount
FROM bank_loan
WHERE loan_status = 'Fully Paid' OR
loan_status = 'Current'


--Good Loan Total Received Amount
SELECT SUM(total_payment) AS Good_loan_amount_received
FROM bank_loan
WHERE loan_status = 'Fully Paid' OR
loan_status = 'Current'


--Bad Loan percentage
SELECT 
	(COUNT(CASE WHEN loan_status = 'Charged Off' THEN id END) *100.0)
	/
	COUNT(id) AS Bad_loan_percentage
FROM bank_loan


--Bad Loan Application
SELECT COUNT(id) AS Bad_loan_Application
FROM bank_loan
WHERE loan_status = 'Charged Off'


--Bad Loan Funded Amount
SELECT SUM(loan_amount) AS Bad_loan_Funded_Amount
FROM bank_loan
WHERE loan_status = 'Charged Off'


--Bad Loan Total Received Amount
SELECT SUM(total_payment) AS Bad_loan_amount_received
FROM bank_loan
WHERE loan_status = 'Charged Off'


--Loan Status

SELECT  loan_status,
		COUNT(id) AS Total_loan_applications,
		SUM(total_payment) AS Total_amount_received,
		SUM(loan_amount) AS Total_Funded_amount,
		AVG(int_rate * 100) AS interest_rate,
		AVG(dti * 100) AS dti
FROM bank_loan
GROUP BY loan_status


--MTD Loan Status
SELECT  loan_status,
		SUM(total_payment) AS MTD_Total_amount_received,
		SUM(loan_amount) AS MTD_Total_Funded_amount
FROM bank_loan
WHERE EXTRACT(MONTH FROM issue_date) = 12
GROUP BY loan_status

--OVERVIEW

--Monthly trends by issue date
SELECT 
	EXTRACT(MONTH FROM issue_date),
	TO_CHAR(issue_date, 'Month'),
	COUNT(id) AS Total_loan_applications,
	SUM(loan_amount) AS total_funded_amount,
	SUM(total_payment) AS total_received_amount
FROM bank_loan
GROUP BY EXTRACT(MONTH FROM issue_date),
		 TO_CHAR(issue_date, 'Month')
ORDER BY EXTRACT(MONTH FROM issue_date)

--Regional Analysis by State
SELECT 
	address_state,
	COUNT(id) AS Total_loan_applications,
	SUM(loan_amount) AS total_funded_amount,
	SUM(total_payment) AS total_received_amount
FROM bank_loan
GROUP BY address_state
ORDER BY COUNT(id) DESC


--Loan Term Analysis
SELECT 
	term,
	COUNT(id) AS Total_loan_applications,
	SUM(loan_amount) AS total_funded_amount,
	SUM(total_payment) AS total_received_amount
FROM bank_loan
GROUP BY term
ORDER BY term

--Employee Lenght Analysis
SELECT 
	emp_length,
	COUNT(id) AS Total_loan_applications,
	SUM(loan_amount) AS total_funded_amount,
	SUM(total_payment) AS total_received_amount
FROM bank_loan
GROUP BY emp_length
ORDER BY COUNT(id) DESC


--Purpose of Loan
SELECT 
	purpose,
	COUNT(id) AS Total_loan_applications,
	SUM(loan_amount) AS total_funded_amount,
	SUM(total_payment) AS total_received_amount
FROM bank_loan
GROUP BY purpose
ORDER BY COUNT(id) DESC

--home ownership
SELECT 
	home_ownership,
	COUNT(id) AS Total_loan_applications,
	SUM(loan_amount) AS total_funded_amount,
	SUM(total_payment) AS total_received_amount
FROM bank_loan
WHERE grade = 'A' AND address_state = 'CA'
GROUP BY home_ownership
ORDER BY COUNT(id) DESC

