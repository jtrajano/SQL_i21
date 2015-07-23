print('/*******************  BEGIN Update tblARInvoice Type  *******************/')
GO

Update
	tblARInvoice
SET
	 strType = 'General'
WHERE
	strType IS NULL OR LTRIM(RTRIM(strType)) = ''



Update
	tblARInvoice
SET
	 strType = 'Credit Memo'
WHERE
	strTransactionType = 'Credit Memo'


GO
print('/*******************  END Update tblARInvoice Type  *******************/')