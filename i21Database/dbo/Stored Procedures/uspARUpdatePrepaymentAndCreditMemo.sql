CREATE PROCEDURE [dbo].[uspARUpdatePrepaymentAndCreditMemo]
	 @TransactionId	INT
	,@Post			BIT	= 0
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
		 ARI.dblPayment		= ARI.dblPayment + ((CASE WHEN @Post = 0 THEN -1 ELSE 1 END) * ARPAC.[dblAppliedInvoiceDetailAmount])
		,ARI.dblAmountDue	= ARI.dblInvoiceTotal - (ARI.dblPayment + ((CASE WHEN @Post = 0 THEN -1 ELSE 1 END) * ARPAC.[dblAppliedInvoiceDetailAmount]))
	FROM
		tblARInvoice ARI
	INNER JOIN						
		tblARPrepaidAndCredit ARPAC
			ON ARI.intInvoiceId = ARPAC.intPrepaymentId
	INNER JOIN
		tblARInvoice ARI1
			ON ARPAC.[intInvoiceId] = ARI1.[intInvoiceId] 
	WHERE
		ARI1.intInvoiceId = @TransactionId
		AND ISNULL(ARPAC.[ysnApplied],0) = 1
		AND ARPAC.[dblAppliedInvoiceDetailAmount] <> @ZeroDecimal
	

	UPDATE ARI
	SET
		 ARI.ysnPaid	= (CASE WHEN (ARI.dblAmountDue) = 0 THEN 1 ELSE 0 END)
	FROM
		tblARInvoice ARI
	INNER JOIN						
		tblARPrepaidAndCredit ARPAC
			ON ARI.intInvoiceId = ARPAC.intPrepaymentId
	INNER JOIN
		tblARInvoice ARI1
			ON ARPAC.[intInvoiceId] = ARI1.[intInvoiceId] 
	WHERE
		ARI1.intInvoiceId = @TransactionId
		AND ISNULL(ARPAC.[ysnApplied],0) = 1
		AND ARPAC.[dblAppliedInvoiceDetailAmount] <> @ZeroDecimal

END

GO