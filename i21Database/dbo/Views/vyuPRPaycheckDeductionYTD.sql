CREATE VIEW [dbo].[vyuPRPaycheckDeductionYTD]
AS

SELECT 
     intEntityEmployeeId
    ,strDeduction
    ,strDescription
    ,SUM(dblTotal) as dblTotal
    ,YEAR(dtmPayDate) as intPayrollYear
        FROM vyuPRPaycheckDeduction 
        WHERE YEAR(dtmPayDate) = YEAR(GETDATE())
GROUP BY strDeduction,strDescription,intEntityEmployeeId,YEAR(dtmPayDate)

GO