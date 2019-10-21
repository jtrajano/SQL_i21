CREATE VIEW [dbo].[vyuARInvoicePaymentInformation]
	AS 


select 
	B.intPaymentId, 
	A.dtmDatePaid, 
	B.intPaymentDetailId,
	intInvoiceId 
	from tblARPayment A 
	JOIN (SELECT intPaymentId, intInvoiceId, intPaymentDetailId FROM tblARPaymentDetail) B
		ON A.intPaymentId = B.intPaymentId
--order by B.intPaymentDetailId desc
