print('/*******************  BEGIN Fix amounts for tblARInvoice WHERE strTransactionType = Cash *******************/')
GO

UPDATE tblARInvoice 
SET dblAmountDue = 0,
	ysnPaid = 1,
	dblPayment = dblInvoiceTotal
WHERE strTransactionType = 'Cash'
AND ysnPosted = 1
AND dblAmountDue <> 0

GO
print('/*******************  END Fix amounts for tblARInvoice WHERE strTransactionType = Cash  *******************/')