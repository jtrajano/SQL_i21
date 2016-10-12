print('/*******************  BEGIN Update From Prepayment To Customer Prepayment  *******************/')
GO

UPDATE tblARInvoice SET strTransactionType = 'Customer Prepayment' WHERE strTransactionType = 'Prepayment'

print('/*******************  END Update From Prepayment To Customer Prepayment  *******************/')
GO