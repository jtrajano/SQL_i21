--Activate this on 17.3 for AR-3714

--IF(EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblARPaymentDetail') AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intInvoiceId' AND [object_id] = OBJECT_ID(N'tblARPaymentDetail'))
--			AND EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblARInvoice') AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intInvoiceId' AND [object_id] = OBJECT_ID(N'tblARInvoice')))
--BEGIN

--UPDATE tblARPaymentDetail
--SET
--	[intInvoiceId] = NULL
--WHERE
--	[intInvoiceId] IS NOT NULL
--	AND NOT EXISTS (SELECT NULL FROM tblARInvoice WHERE tblARInvoice.[intInvoiceId] = tblARPaymentDetail.[intInvoiceId])

--END