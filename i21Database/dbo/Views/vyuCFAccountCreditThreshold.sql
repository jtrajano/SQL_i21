CREATE VIEW [dbo].[vyuCFAccountCreditThreshold]
AS
SELECT 
mainQuery.intEntityCustomerId, 
mainQuery.strCustomerName, 
mainQuery.strCustomerNumber,
mainQuery.dblCreditLimit, 
mainQuery.dblTotalDue, 
mainQuery.dblTotalAR, 
mainQuery.dblOverLimit, 
ARCust.strCreditCode, 
CFAccnt.intAccountId, 
CASE 
WHEN (dblOverLimit > 0 AND dblTotalDue > 0) 
	THEN 'Both' 
WHEN (dblOverLimit <= 0 AND dblTotalDue > 0) 
	THEN 'Past Due' 
WHEN (dblOverLimit > 0 AND dblTotalDue <= 0) 
	THEN 'Over Credit Limit' END AS strReason

FROM   (
SELECT 
intEntityCustomerId, 
strCustomerName, 
strCustomerNumber, 
dblCreditLimit, 
dblTotalDue AS dblTotalAR, 
dbl10Days + dbl30Days + dbl60Days + dbl90Days + dbl91Days AS dblTotalDue, 
CASE 
WHEN ((dblTotalDue) - dblCreditLimit) <= 0 
THEN 0 
WHEN ((dblTotalDue) - dblCreditLimit) > 0 
THEN ((dblTotalDue) - dblCreditLimit) 
END AS dblOverLimit
             
			 FROM    dbo.vyuARCustomerInquiry) AS mainQuery INNER JOIN
             dbo.tblARCustomer AS ARCust ON mainQuery.intEntityCustomerId = ARCust.intEntityCustomerId INNER JOIN
             dbo.tblCFAccount AS CFAccnt ON mainQuery.intEntityCustomerId = CFAccnt.intCustomerId INNER JOIN
                 (SELECT DISTINCT intAccountId
                  FROM dbo.tblCFCard
                  WHERE (ysnCardLocked = 0)) AS CFCard ON CFAccnt.intAccountId = CFCard.intAccountId
WHERE (mainQuery.dblOverLimit > 0) OR
             (mainQuery.dblTotalDue > 0)
GO