﻿CREATE PROCEDURE [dbo].[uspARSettleInvoice]
	 @PaymentDetailId	Id READONLY
	,@userId			INT
	,@post				BIT
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF


DECLARE @UserEntityID	INT
		,@ActionType	NVARCHAR(50)
		,@InvoiceIds	NVARCHAR(MAX)
		,@ZeroDecimal	NUMERIC(18, 6)
		
SET @ZeroDecimal = 0.000000	
SET @UserEntityID = ISNULL((SELECT intEntityUserSecurityId FROM tblSMUserSecurity WHERE intEntityUserSecurityId = @userId),@userId) 
SET @ActionType = CASE WHEN @post = 1 THEN 'Post Settlement' ELSE 'UnPost Settlement' END


UPDATE ARI						
SET	
	 ARI.[dblPayment]		= ISNULL(ARI.[dblPayment], @ZeroDecimal) + (APPD.[dblPayment] * (CASE WHEN @post = 1 THEN 1 ELSE -1 END)) 
	--,ARI.[dblDiscount]		= ISNULL(ARI.[dblDiscount], @ZeroDecimal) + APPD.[dblDiscount]
	--,ARI.[dblInterest]		= ISNULL(ARI.[dblInterest], @ZeroDecimal) + APPD.[dblInterest]
FROM
	@PaymentDetailId PID
INNER JOIN
	tblAPPaymentDetail APPD
		ON PID.[intId] = APPD.[intPaymentDetailId]
INNER JOIN
	tblARInvoice ARI
		ON APPD.intInvoiceId = ARI.intInvoiceId
INNER JOIN
	tblAPPayment APP
		ON APPD.[intPaymentId] = APP.[intPaymentId]
WHERE
	--APP.[ysnPosted] = 1
	--AND 
	ARI.[ysnPosted] = 1
	AND APPD.[dblPayment] <> @ZeroDecimal


UPDATE ARI						
SET	
	 ARI.dblAmountDue = (ARI.dblInvoiceTotal + ARI.dblInterest) - (ARI.dblPayment + ARI.dblDiscount)
	,ARI.[ysnPaid] = CASE WHEN (ARI.dblInvoiceTotal + ARI.dblInterest) - (ARI.dblPayment + ARI.dblDiscount) = @ZeroDecimal THEN 1 ELSE 0 END
	,ARI.[intConcurrencyId]	= ISNULL(ARI.intConcurrencyId,0) + 1	
FROM
	@PaymentDetailId PID
INNER JOIN
	tblAPPaymentDetail APPD
		ON PID.[intId] = APPD.[intPaymentDetailId]
INNER JOIN
	tblARInvoice ARI
		ON APPD.intInvoiceId = ARI.intInvoiceId
INNER JOIN
	tblAPPayment APP
		ON APPD.[intPaymentId] = APP.[intPaymentId]
WHERE
	--APP.[ysnPosted] = 1
	--AND 
	ARI.[ysnPosted] = 1
	AND APPD.[dblPayment] <> @ZeroDecimal


DECLARE @CustomerIds TABLE (intCustomerId INT)
	
INSERT INTO @CustomerIds
SELECT DISTINCT ARI.intEntityCustomerId
FROM
	@PaymentDetailId PID
INNER JOIN
	tblAPPaymentDetail APPD
		ON PID.[intId] = APPD.[intPaymentDetailId]
INNER JOIN
	tblARInvoice ARI
		ON APPD.intInvoiceId = ARI.intInvoiceId
INNER JOIN
	tblAPPayment APP
		ON APPD.[intPaymentId] = APP.[intPaymentId]
WHERE
	--APP.[ysnPosted] = 1
	--AND 
	ARI.[ysnPosted] = 1
	AND APPD.[dblPayment] <> @ZeroDecimal

WHILE EXISTS (SELECT NULL FROM @CustomerIds)
	BEGIN
		DECLARE @customerId	INT

		SELECT TOP 1 @customerId = intCustomerId FROM @CustomerIds

		EXEC dbo.uspARUpdateCustomerTotalAR @InvoiceId = NULL, @CustomerId = @customerId

		DELETE FROM @CustomerIds WHERE intCustomerId = @customerId
	END


SELECT
	@InvoiceIds = COALESCE(@InvoiceIds + ',' ,'') + CAST(ARI.[intInvoiceId] AS NVARCHAR(250))
FROM
	@PaymentDetailId PID
INNER JOIN
	tblAPPaymentDetail APPD
		ON PID.[intId] = APPD.[intPaymentDetailId]
INNER JOIN
	tblARInvoice ARI
		ON APPD.intInvoiceId = ARI.intInvoiceId
INNER JOIN
	tblAPPayment APP
		ON APPD.[intPaymentId] = APP.[intPaymentId]
WHERE
	--APP.[ysnPosted] = 1
	--AND 
	ARI.[ysnPosted] = 1
	AND APPD.[dblPayment] <> @ZeroDecimal

--Audit Log          
EXEC dbo.uspSMAuditLog 
		@keyValue			= @InvoiceIds						-- Primary Key Value of the Invoice. 
		,@screenName		= 'AccountsReceivable.view.Invoice'	-- Screen Namespace
		,@entityId			= @UserEntityID						-- Entity Id.
		,@actionType		= @ActionType						-- Action Type
		,@changeDescription	= ''								-- Description
		,@fromValue			= ''								-- Previous Value
		,@toValue			= ''								-- New Value
