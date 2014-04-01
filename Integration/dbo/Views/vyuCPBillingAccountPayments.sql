/*
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuCPBillingAccountPayments')
	DROP VIEW vyuCPBillingAccountPayments
GO

CREATE VIEW [dbo].[vyuCPBillingAccountPayments]
AS
SELECT
	   id = row_number() over (order by dblAmount)
      ,strCustomerNo
	  ,dtmDate
      ,strCheckNo
      ,dblAmount = sum(dblAmount)
  FROM vyuCPPaymentsDetails
  GROUP BY dblAmount, dtmDate, strCheckNo,strCustomerNo
  --order by dtmDate
GO
*/

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuCPBillingAccountPayments')
	DROP VIEW vyuCPBillingAccountPayments
GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuCPPaymentsDetails')
	EXEC('
		CREATE VIEW [dbo].[vyuCPBillingAccountPayments]
		AS
		SELECT
			   id = row_number() over (order by dblAmount)
			  ,strCustomerNo
			  ,dtmDate
			  ,strCheckNo
			  ,dblAmount = sum(dblAmount)
		  FROM vyuCPPaymentsDetails
		  GROUP BY dblAmount, dtmDate, strCheckNo,strCustomerNo
		  --order by dtmDate
	')
GO
