CREATE VIEW [dbo].[vwCPBillingAccountPayments]
AS
SELECT
	   id = row_number() over (order by dblAmount)
      ,strCustomerNo
	  ,dtmDate
      ,strCheckNo
      ,dblAmount = sum(dblAmount)
  FROM vwCPPaymentsDetails
  GROUP BY dblAmount, dtmDate, strCheckNo,strCustomerNo
  --order by dtmDate