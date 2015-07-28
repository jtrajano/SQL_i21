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


GO
print('/*******************  END Update tblARInvoice Type  *******************/')