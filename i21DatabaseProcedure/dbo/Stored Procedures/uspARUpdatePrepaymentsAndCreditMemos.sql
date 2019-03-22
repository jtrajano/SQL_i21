CREATE PROCEDURE [dbo].[uspARUpdatePrepaymentsAndCreditMemos]
	@InvoiceIds		InvoiceId	READONLY
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000

	UPDATE ARI
	SET
		 ARI.dblPayment		= ARI.dblPayment + ((CASE WHEN ISNULL(ARI1.[ysnPost], 0) = 0 THEN -1 ELSE 1 END) * ARPAC.[dblAppliedInvoiceDetailAmount])
		,ARI.dblAmountDue	= ARI.dblInvoiceTotal - (ARI.dblPayment + ((CASE WHEN ISNULL(ARI1.[ysnPost], 0) = 0 THEN -1 ELSE 1 END) * ARPAC.[dblAppliedInvoiceDetailAmount]))
	FROM
		(SELECT intInvoiceId, dblPayment, dblAmountDue, dblInvoiceTotal FROM tblARInvoice WITH (NOLOCK)) ARI
	INNER JOIN						
		(SELECT intPrepaymentId, [intInvoiceId], [dblAppliedInvoiceDetailAmount], [ysnApplied] FROM tblARPrepaidAndCredit WITH (NOLOCK)) ARPAC
			ON ARI.intInvoiceId = ARPAC.intPrepaymentId
	INNER JOIN
		(SELECT [intHeaderId], [ysnPost] FROM @InvoiceIds) ARI1
			ON ARPAC.[intInvoiceId] = ARI1.[intHeaderId] 
     WHERE
         ISNULL(ARPAC.[ysnApplied],0) = 1
         AND ARPAC.[dblAppliedInvoiceDetailAmount] <> @ZeroDecimal
						
	

	UPDATE ARI
	SET
		 ARI.ysnPaid	= (CASE WHEN (ARI.dblAmountDue) = 0 THEN 1 ELSE 0 END)
	FROM
		(SELECT intInvoiceId, dblAmountDue, ysnPaid FROM tblARInvoice WITH (NOLOCK)) ARI
	INNER JOIN						
		(SELECT [intInvoiceId], intPrepaymentId, [ysnApplied], [dblAppliedInvoiceDetailAmount] FROM tblARPrepaidAndCredit WITH (NOLOCK)) ARPAC
			ON ARI.intInvoiceId = ARPAC.intPrepaymentId
	INNER JOIN
		(SELECT [intHeaderId] FROM @InvoiceIds) ARI1
			ON ARPAC.[intInvoiceId] = ARI1.[intHeaderId] 
    WHERE
		ISNULL(ARPAC.[ysnApplied],0) = 1
        AND ARPAC.[dblAppliedInvoiceDetailAmount] <> @ZeroDecimal

		 

END

GO
