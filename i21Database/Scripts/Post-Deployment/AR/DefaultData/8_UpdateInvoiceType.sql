print('/*******************  BEGIN Update tblARInvoice Type  *******************/')
GO

Update
	tblARInvoice
SET
	 strType = 'Standard'
WHERE
	strType IS NULL OR LTRIM(RTRIM(strType)) = '' OR strType = 'General'

Update
	tblARInvoice
SET
	 strType = 'Credit Memo'
WHERE
	strTransactionType = 'Credit Memo'

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