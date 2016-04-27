print('/*******************  BEGIN Update tblARInvoice.dblInvoiceTotal, dblInvoiceSubtotal, dblAmountDue, dblPayment, dblDiscount *******************/')
GO

DECLARE @tblInvoices TABLE(intInvoiceId INT)

INSERT INTO @tblInvoices
SELECT intInvoiceId FROM tblARInvoice 
WHERE dblInvoiceTotal IS NULL
   OR dblInvoiceSubtotal IS NULL
   OR dblAmountDue IS NULL
   OR dblPayment IS NULL

WHILE EXISTS (SELECT NULL FROM @tblInvoices)
	BEGIN
		DECLARE @intInvoiceId INT

		SELECT TOP 1 @intInvoiceId = intInvoiceId FROM @tblInvoices

		EXEC dbo.uspARReComputeInvoiceTaxes @intInvoiceId

		DELETE FROM @tblInvoices WHERE intInvoiceId = @intInvoiceId
	END

GO
print('/*******************  END Update tblARInvoice.dblInvoiceTotal, dblInvoiceSubtotal, dblAmountDue, dblPayment, dblDiscount *******************/')