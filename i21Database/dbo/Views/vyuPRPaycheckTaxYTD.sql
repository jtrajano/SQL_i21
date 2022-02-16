CREATE VIEW [dbo].[vyuPRPaycheckTaxYTD]
AS

SELECT 
     intEntityEmployeeId
    ,strTaxId,strDescription
    ,SUM(dblTaxableAmountYTD) AS dblTaxableAmountYTD
    ,SUM(dblTotal) AS dblTotal
    ,YEAR(dtmPayDate) as intPayrollYear
        FROM vyuPRPaycheckTax
        WHERE YEAR(dtmPayDate) = YEAR(GETDATE())
GROUP BY strTaxId,strDescription,intEntityEmployeeId,YEAR(dtmPayDate)

GO