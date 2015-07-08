CREATE VIEW [dbo].[vyuPRPaycheckTax]   
AS

SELECT DISTINCT 
tblPRPaycheck.intPaycheckId 
, ISNULL(tblPRPaycheckTax.strTax,'') AS strTaxId
, ISNULL(tblPRPaycheckTax.dblTotal,0) AS dblTotal 
, SUM(ISNULL(tblTaxSum.dblTotal,0)) AS dblTotalYTD 
FROM (SELECT tblPRPaycheckTax.intPaycheckId, 
			 tblPRPaycheckTax.intTypeTaxId, 
			 tblPRTypeTax.strTax,
			 tblPRPaycheckTax.dblAmount,
			 tblPRPaycheckTax.dblTotal, 
			 tblPRPaycheckTax.strPaidBy FROM tblPRPaycheckTax 
		LEFT JOIN tblPRTypeTax ON tblPRPaycheckTax.intTypeTaxId = tblPRTypeTax.intTypeTaxId) tblPRPaycheckTax
LEFT JOIN (SELECT tblPRPaycheck.intEmployeeId
		, tblPRPaycheckTax.intPaycheckId
		, tblPRPaycheckTax.intTypeTaxId 
		, dblTotal 
		, dtmPayDate 
		FROM tblPRPaycheckTax 
		LEFT JOIN tblPRPaycheck ON tblPRPaycheckTax.intPaycheckId = tblPRPaycheck.intPaycheckId 
		WHERE ysnPosted = 1 AND ysnVoid = 0
) tblTaxSum ON tblPRPaycheckTax.intTypeTaxId = tblTaxSum.intTypeTaxId 
LEFT JOIN tblPRPaycheck ON tblPRPaycheckTax.intPaycheckId = tblPRPaycheck.intPaycheckId 
WHERE CAST(FLOOR(CAST(tblTaxSum.dtmPayDate AS FLOAT)) AS DATETIME) 
		BETWEEN CAST(('1/1/' + CAST(YEAR(tblPRPaycheck.dtmPayDate) AS NVARCHAR(4))) AS DATETIME) 
			AND CAST(FLOOR(CAST(tblPRPaycheck.dtmPayDate AS FLOAT)) AS DATETIME) 
		AND strPaidBy = 'Employee'   
GROUP BY tblPRPaycheck.intPaycheckId 
, tblPRPaycheckTax.strTax
, tblPRPaycheckTax.dblTotal 