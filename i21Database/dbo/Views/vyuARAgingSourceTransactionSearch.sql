CREATE VIEW [dbo].[vyuARAgingSourceTransactionSearch]
AS
SELECT 
	strSourceTransaction = 'Standard'

UNION ALL

SELECT 
	strSourceTransaction	= 'Software'

UNION ALL

SELECT 
	strSourceTransaction	= 'Tank Delivery'

UNION ALL
	
SELECT 
	strSourceTransaction = 'Provisional'

UNION ALL

SELECT 
	strSourceTransaction	= 'Transport Delivery'