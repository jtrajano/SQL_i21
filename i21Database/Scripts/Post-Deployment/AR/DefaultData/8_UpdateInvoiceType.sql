print('/*******************  BEGIN Update tblARInvoice Type  *******************/')
GO

UPDATE tblSOSalesOrder SET ysnQuote = 1 WHERE strTransactionType = 'Quote'

Update tblARInvoice SET strType = 'Standard'
WHERE strType IS NULL OR LTRIM(RTRIM(strType)) = '' OR strType = 'General'

UPDATE tblARInvoice
SET
	 strTransactionType = 'Debit Memo'
	,strType			= 'Standard'
WHERE
	strType = 'Debit Memo'
	
UPDATE tblARInvoice
SET
	 strTransactionType = 'Credit Memo'
	,strType			= 'Standard'
WHERE
	strType = 'Credit Memo'	

IF COL_LENGTH('tblARInvoice', 'intDistributionHeaderId') IS NOT NULL OR COL_LENGTH('tblARInvoice', 'intLoadDistributionHeaderId') IS NOT NULL
	BEGIN
		IF COL_LENGTH('tblARInvoice', 'intLoadDistributionHeaderId') IS NULL
			BEGIN
				UPDATE tblARInvoice SET strType = 'Transport Delivery' WHERE ISNULL(intDistributionHeaderId, 0) > 0
			END
		ELSE
			BEGIN
				UPDATE tblARInvoice SET strType = 'Transport Delivery' WHERE ISNULL(intDistributionHeaderId, 0) > 0 OR ISNULL(intLoadDistributionHeaderId, 0) > 0
			END
	END

GO
print('/*******************  END Update tblARInvoice Type  *******************/')