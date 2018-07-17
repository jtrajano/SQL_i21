print('/*******************  BEGIN Update tblARInvoice.dtmDate, dtmPostDate, dtmDueDate, dtmShipDate  *******************/')
GO

UPDATE I
SET dtmDate		= ISNULL(P.dtmDatePaid, GETDATE())
  , dtmDueDate	= ISNULL(P.dtmDatePaid, GETDATE())
  , dtmPostDate = ISNULL(P.dtmDatePaid, GETDATE())
  , dtmShipDate = ISNULL(P.dtmDatePaid, GETDATE())
FROM tblARInvoice I 
	INNER JOIN tblARPayment P ON I.intPaymentId = P.intPaymentId
WHERE I.strTransactionType IN ('Overpayment', 'Credit', 'Prepayment', 'Customer Prepayment')

GO
print('/*******************  END Update tblARInvoice.dtmDate, dtmPostDate, dtmDueDate, dtmShipDate  *******************/')