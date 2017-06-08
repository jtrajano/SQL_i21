print('/*******************  BEGIN Fix amounts for tblARInvoice.intEntityContactId *******************/')
GO

UPDATE tblARInvoice   
SET intEntityContactId = dbo.fnARGetCustomerDefaultContact(intEntityCustomerId)
WHERE ISNULL(intEntityContactId, 0) = 0

GO
print('/*******************  END Fix amounts for tblARInvoice.intEntityContactId  *******************/')