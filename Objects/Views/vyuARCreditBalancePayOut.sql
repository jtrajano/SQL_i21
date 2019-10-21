CREATE VIEW [dbo].[vyuARCreditBalancePayOut]
	AS

SELECT
	 [intCreditBalancePayOutId]         = CBP.[intCreditBalancePayOutId]
	,[dtmAsOfDate]                      = CBP.[dtmAsOfDate]
	,[ysnPayBalance]                    = CBP.[ysnPayBalance]
	,[ysnPreview]                       = CBP.[ysnPreview]
	,[dblOpenARBalance]                 = CBP.[dblOpenARBalance]
	,[intEntityId]                      = CBP.[intEntityId]
	,[strEntity]                        = EME.[strName]
	,[dtmDate]                          = CBP.[dtmDate]
	,[intCreditBalancePayOutDetailId]	= CBPD.[intCreditBalancePayOutDetailId]	
	,[intEntityCustomerId]              = CBPD.[intEntityCustomerId]
	,[strCustomerNumber]                = ARC.[strCustomerNumber]
	,[strTransactionNumber]             = ISNULL(ARP.[strRecordNumber], APB.[strBillId])
	,[dblTransactionTotal]              = ISNULL(ARP.[dblAmountPaid], APB.[dblTotal])
	,[intPaymentId]                     = CBPD.[intPaymentId]
	,[strRecordNumber]                  = ARP.[strRecordNumber]
	,[dblAmountPaid]                    = ARP.[dblAmountPaid]
	,[intBillId]                        = CBPD.[intBillId]
	,[strBillId]                        = APB.[strBillId]
	,[dblTotal]                         = APB.[dblTotal]
	,[ysnProcess]                       = CBPD.[ysnProcess]
	,[ysnSuccess]                       = CBPD.[ysnSuccess]
	,[strMessage]                       = CBPD.[strMessage] 
FROM
	tblARCreditBalancePayOutDetail CBPD
INNER JOIN
	(SELECT [intCreditBalancePayOutId], [dtmAsOfDate], [ysnPayBalance], [ysnPreview], [dblOpenARBalance], [intEntityId], [dtmDate] FROM tblARCreditBalancePayOut) CBP
		ON CBPD.[intCreditBalancePayOutId] = CBP.[intCreditBalancePayOutId]
INNER JOIN
	(SELECT [intEntityId], [strName] FROM tblEMEntity) EME
		ON CBP.[intEntityId] = EME.[intEntityId]
INNER JOIN
	(SELECT [intEntityId], [strCustomerNumber] FROM tblARCustomer) ARC
		ON CBPD.[intEntityCustomerId] = ARC.[intEntityId]
LEFT OUTER JOIN
	(SELECT [intPaymentId], [strRecordNumber], [dblAmountPaid] FROM tblARPayment) ARP
		ON CBPD.[intPaymentId] = ARP.[intPaymentId]
LEFT OUTER JOIN
	(SELECT [intBillId], [strBillId], [dblTotal] FROM tblAPBill) APB
		ON CBPD.[intBillId] = APB.[intBillId]
