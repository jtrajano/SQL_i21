CREATE VIEW dbo.vyuCFAccountCreditThreshold
AS
SELECT mainQuery.[intEntityId], mainQuery.strCustomerName, mainQuery.strCustomerNumber, mainQuery.dblCreditLimit, mainQuery.dblTotalDue, mainQuery.dblTotalAR, mainQuery.dblOverLimit, ARCust.strCreditCode, CFAccnt.intAccountId, 
             CASE WHEN (dblOverLimit > 0 AND dblTotalDue > 0) THEN 'Both' WHEN (dblOverLimit <= 0 AND dblTotalDue > 0) THEN 'Past Due' WHEN (dblOverLimit > 0 AND dblTotalDue <= 0) THEN 'Over Credit Limit' END AS strReason
FROM   (SELECT [intEntityId], strCustomerName, strCustomerNumber, dblCreditLimit, dblTotalDue, dblTotalDue + dbl0Days AS dblTotalAR, CASE WHEN ((dblTotalDue + dbl0Days) - dblCreditLimit) <= 0 THEN 0 WHEN ((dblTotalDue + dbl0Days) - dblCreditLimit) 
                           > 0 THEN ((dblTotalDue + dbl0Days) - dblCreditLimit) END AS dblOverLimit
             FROM    dbo.vyuARCustomerInquiry) AS mainQuery INNER JOIN
             dbo.tblARCustomer AS ARCust ON mainQuery.[intEntityId] = ARCust.[intEntityId] INNER JOIN
             dbo.tblCFAccount AS CFAccnt ON mainQuery.[intEntityId] = CFAccnt.intCustomerId INNER JOIN
                 (SELECT DISTINCT intAccountId
                  FROM dbo.tblCFCard
                  WHERE (ysnCardLocked = 0)) AS CFCard ON CFAccnt.intAccountId = CFCard.intAccountId
WHERE (mainQuery.dblOverLimit > 0) OR
             (mainQuery.dblTotalDue > 0)