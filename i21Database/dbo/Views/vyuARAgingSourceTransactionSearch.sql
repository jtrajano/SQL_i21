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
	strSourceTransaction	= 'Service Charge'

UNION ALL

SELECT 
	strSourceTransaction	= 'Transport Delivery'

UNION ALL 

SELECT 
	strSourceTransaction	= 'Store'

UNION ALL

SELECT 
	strSourceTransaction	= 'Meter Billing'

UNION ALL

SELECT 
	strSourceTransaction	= 'Card Fueling'
