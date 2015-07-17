CREATE VIEW [dbo].[vyuPRPaycheckYTD]
AS

SELECT 
tblPRPaycheck.intEmployeeId
,tblPRPaycheck.intPaycheckId
,tblPRPaycheck.dtmPayDate
,dblGrossYTD = SUM(tblPaychecks.dblGross) 
,dblAdjustedGrossYTD = SUM(tblPaychecks.dblAdjustedGross) 
,dblCompanyTaxTotalYTD = SUM(tblPaychecks.dblCompanyTaxTotal) 
,dblDeductionTotalYTD = SUM(tblPaychecks.dblDeductionTotal) 
,dblNetPayTotalYTD = SUM(tblPaychecks.dblNetPayTotal) 
,dblTaxTotalYTD = SUM(tblPaychecks.dblTaxTotal) 
FROM tblPRPaycheck 
LEFT JOIN
	(--Posted Paychecks
	 SELECT intEmployeeId ,intPaycheckId ,dblGross ,dblAdjustedGross ,dblCompanyTaxTotal
	 ,dblDeductionTotal ,dblNetPayTotal ,dblTaxTotal ,dtmPayDate
	FROM tblPRPaycheck	WHERE ysnPosted = 1 AND ysnVoid = 0
	UNION ALL
	 --Current Paycheck (if Unposted)
	SELECT intEmployeeId ,intPaycheckId ,dblGross ,dblAdjustedGross ,dblCompanyTaxTotal
	 ,dblDeductionTotal ,dblNetPayTotal ,dblTaxTotal ,dtmPayDate
	FROM tblPRPaycheck
	WHERE ysnPosted = 0 AND ysnVoid = 0 AND intPaycheckId = tblPRPaycheck.intPaycheckId) tblPaychecks
ON tblPRPaycheck.intEmployeeId = tblPaychecks.intEmployeeId
AND CAST(FLOOR(CAST(tblPaychecks.dtmPayDate AS FLOAT)) AS DATETIME) 
		BETWEEN CAST(('1/1/' + CAST(YEAR(tblPRPaycheck.dtmPayDate) AS NVARCHAR(4))) AS DATETIME) 
			AND CAST(FLOOR(CAST(tblPRPaycheck.dtmPayDate AS FLOAT)) AS DATETIME) 
GROUP BY 
tblPRPaycheck.intEmployeeId
,tblPRPaycheck.intPaycheckId
,tblPRPaycheck.dtmPayDate