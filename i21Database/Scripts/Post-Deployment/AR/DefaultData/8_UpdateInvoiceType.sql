print('/*******************  BEGIN Update tblARInvoice Type  *******************/')
GO

Update
	tblARInvoice
SET
	 strType = 'General'
WHERE
	strType IS NULL OR LTRIM(RTRIM(strType)) = ''


GO
print('/*******************  END Update tblARInvoice Type  *******************/')