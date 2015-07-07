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
	(SELECT
	 intEmployeeId
	 ,intPaycheckId
	 ,dblGross
	 ,dblAdjustedGross
	 ,dblCompanyTaxTotal
	 ,dblDeductionTotal
	 ,dblNetPayTotal
	 ,dblTaxTotal
	 ,dtmPayDate
	FROM tblPRPaycheck) tblPaychecks
ON tblPRPaycheck.intEmployeeId = tblPaychecks.intEmployeeId
AND CAST(FLOOR(CAST(tblPaychecks.dtmPayDate AS FLOAT)) AS DATETIME) 
		BETWEEN CAST(('1/1/' + CAST(YEAR(tblPRPaycheck.dtmPayDate) AS NVARCHAR(4))) AS DATETIME) 
			AND CAST(FLOOR(CAST(tblPRPaycheck.dtmPayDate AS FLOAT)) AS DATETIME) 
WHERE ysnPosted = 1 and ysnVoid = 0
GROUP BY 
tblPRPaycheck.intEmployeeId
,tblPRPaycheck.intPaycheckId
,tblPRPaycheck.dtmPayDate