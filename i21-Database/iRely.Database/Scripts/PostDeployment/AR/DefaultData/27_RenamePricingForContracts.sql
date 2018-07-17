print('/*******************  BEGIN Update strTransactionNumber in tblARPaymentDetail  *******************/')
GO

UPDATE tblARPricingHistory
SET
	strPricing = 'Contracts'
WHERE
	strPricing = 'Contracts - Customer Pricing'

UPDATE tblARPricingHistory
SET
	strOriginalPricing = 'Contracts'
WHERE
	strOriginalPricing = 'Contracts - Customer Pricing'

UPDATE tblARInvoiceDetail
SET
	strPricing = 'Contracts'
WHERE
	strPricing = 'Contracts - Customer Pricing'

UPDATE tblSOSalesOrderDetail
SET
	strPricing = 'Contracts'
WHERE
	strPricing = 'Contracts - Customer Pricing'

GO
print('/*******************  END Update strTransactionNumber in tblARPaymentDetail  *******************/')