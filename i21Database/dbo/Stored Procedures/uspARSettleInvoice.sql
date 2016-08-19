CREATE PROCEDURE [dbo].[uspARSettleInvoice]
	 @PaymentDetailId	INT
	,@userId			INT
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF


DECLARE @UserEntityID	INT
		,@actionType	NVARCHAR(50)
		,@InvoiceId		INT
		,@PaymentAmount	NUMERIC(18, 6)
		,@Discount		NUMERIC(18, 6)
		,@Interest		NUMERIC(18, 6)
		,@ZeroDecimal			NUMERIC(18, 6)
		
SET @ZeroDecimal = 0.000000	
SET @UserEntityID = ISNULL((SELECT intEntityUserSecurityId FROM tblSMUserSecurity WHERE intEntityUserSecurityId = @userId),@userId) 
SET @actionType = 'Settlement'
SELECT
	  @InvoiceId		= APPD.[intInvoiceId]
	 ,@PaymentAmount	= APPD.[dblPayment] 
	 ,@Discount			= APPD.[dblDiscount]
	 ,@Interest			= APPD.[dblInterest] 
FROM
	tblAPPaymentDetail APPD
INNER JOIN
	tblAPPayment APP
		ON APPD.[intPaymentId] = APP.[intPaymentId]
INNER JOIN
	tblARInvoice ARI
		ON APPD.[intInvoiceId] = ARI.[intInvoiceId] 
WHERE
	APPD.[intPaymentDetailId] = @PaymentDetailId
	AND APP.[ysnPosted] = 1
	AND APPD.[dblPayment] <> @ZeroDecimal
	AND ARI.[ysnPosted] = 1
	
IF ISNULL(@InvoiceId,0) <> 0
	BEGIN
		UPDATE tblARInvoice
		SET
			 [dblPayment]	= [dblPayment] + @PaymentAmount
			--,[dblDiscount]	= [dblDiscount] + @PaymentAmount
			--,[dblInterest]	= [dblInterest] + @PaymentAmount
		WHERE 
			[intInvoiceId] = @InvoiceId
			
		EXEC dbo.[uspARReComputeInvoiceAmounts] @InvoiceId
		
		UPDATE tblARInvoice
		SET
			[ysnPaid] = 1
		WHERE
			[intInvoiceId] = @InvoiceId
			AND [dblAmountDue] = @ZeroDecimal
			
			
		--Audit Log          
		EXEC dbo.uspSMAuditLog 
			 @keyValue			= @InvoiceId						-- Primary Key Value of the Invoice. 
			,@screenName		= 'AccountsReceivable.view.Invoice'	-- Screen Namespace
			,@entityId			= @UserEntityID						-- Entity Id.
			,@actionType		= @actionType						-- Action Type
			,@changeDescription	= ''								-- Description
			,@fromValue			= ''								-- Previous Value
			,@toValue			= ''								-- New Value
	END
