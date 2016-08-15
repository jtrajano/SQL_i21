print('/*******************  BEGIN Update tblARInvoice Link to PrePayment/OverPayment  *******************/')
GO

Update
	tblARInvoice
SET
	tblARInvoice.intPaymentId = P.intPaymentId 
FROM
	tblARInvoice I
INNER JOIN
	tblARPayment P
		ON I.strComments = P.strRecordNumber
WHERE
	intInvoiceId = I.intInvoiceId
	AND I.strTransactionType IN ('Overpayment', 'Prepayment', 'Customer Prepayment') 
	AND (I.intPaymentId IS NULL OR I.intPaymentId NOT IN (SELECT intPaymentId FROM tblARPayment))

GO
print('/*******************  END Update tblARInvoice Link to PrePayment/OverPayment  *******************/')