CREATE VIEW [dbo].[vyuPRPaycheckEarningYTD]
AS

SELECT 
     intEntityEmployeeId
    ,strEarning,strDescription
    ,SUM(dblHours) as dblHours
    ,SUM(dblTotal) as dblTotal
    ,YEAR(dtmPayDate) as intPayrollYear
        FROM vyuPRPaycheckEarning 
        WHERE YEAR(dtmPayDate) = YEAR(GETDATE())
        AND strCalculationType != 'Reimbursement'
GROUP BY strEarning,strDescription,intEntityEmployeeId,YEAR(dtmPayDate)
GO