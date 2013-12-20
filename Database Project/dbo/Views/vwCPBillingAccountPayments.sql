















CREATE VIEW [dbo].[vwCPBillingAccountPayments]
AS
SELECT
	   id = row_number() over (order by dblAmount)
	  ,[dtmDate]
      ,[strCheckNo]
      ,dblAmount = sum([dblAmount])
  FROM [dbo].[vwCPPaymentsDetails]
  GROUP BY dblAmount, [dtmDate], [strCheckNo]
  --order by [dtmDate]





