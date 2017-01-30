print('/*******************  BEGIN Update strTransactionNumber in tblARPaymentDetail  *******************/')
GO

UPDATE tblARPaymentDetail
SET
	[strTransactionNumber] =	(CASE 
									WHEN ISNULL([intInvoiceId],0) <> 0 
										THEN ISNULL((SELECT [strInvoiceNumber] FROM tblARInvoice WHERE tblARInvoice.[intInvoiceId] = tblARPaymentDetail.[intInvoiceId]),'')
									WHEN ISNULL([intBillId],0) <> 0 
										THEN ISNULL((SELECT [strBillId] FROM tblAPBill WHERE tblAPBill.[intBillId] = tblARPaymentDetail.[intBillId]),'')
									ELSE ''
								END)
WHERE
	ISNULL([strTransactionNumber],'') = ''

GO
print('/*******************  END Update strTransactionNumber in tblARPaymentDetail  *******************/')