/*
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPBillingAccountPayments')
	DROP VIEW vwCPBillingAccountPayments
GO

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
GO
*/

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPBillingAccountPayments')
	DROP VIEW vwCPBillingAccountPayments
GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPPaymentsDetails')
	EXEC('
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
	')
GO
