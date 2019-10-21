CREATE VIEW [dbo].[vyuARAgingSourceTransactionSearch]
AS
SELECT 
	strSourceTransaction = 'Standard' COLLATE Latin1_General_CI_AS

UNION ALL

SELECT 
	strSourceTransaction	= 'Software' COLLATE Latin1_General_CI_AS

UNION ALL

SELECT 
	strSourceTransaction	= 'Tank Delivery' COLLATE Latin1_General_CI_AS

UNION ALL
	
SELECT 
	strSourceTransaction = 'Provisional' COLLATE Latin1_General_CI_AS

UNION ALL

SELECT 
	strSourceTransaction	= 'Service Charge' COLLATE Latin1_General_CI_AS

UNION ALL

SELECT 
	strSourceTransaction	= 'Transport Delivery' COLLATE Latin1_General_CI_AS

UNION ALL 

SELECT 
	strSourceTransaction	= 'Store' COLLATE Latin1_General_CI_AS

UNION ALL

SELECT 
	strSourceTransaction	= 'Meter Billing' COLLATE Latin1_General_CI_AS

UNION ALL

SELECT 
	strSourceTransaction	= 'Card Fueling' COLLATE Latin1_General_CI_AS
