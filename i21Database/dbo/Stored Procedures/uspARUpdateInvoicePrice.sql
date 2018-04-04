CREATE PROCEDURE [dbo].[uspARUpdateInvoicePrice]
	 @InvoiceId			INT = NULL
	,@InvoiceDetailId	INT
	,@Price				NUMERIC(18,6)
	,@UserId			INT
AS

BEGIN


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @UserEntityID INT
	SET @UserEntityID = ISNULL((SELECT [intEntityId] FROM tblSMUserSecurity WHERE [intEntityId] = @UserId),@UserId) 


	DECLARE  @ZeroDecimal	DECIMAL(18,6)

	SET @ZeroDecimal = 0.000000	
		
	IF(EXISTS(SELECT NULL FROM tblARInvoice WHERE intInvoiceId = @InvoiceId AND ISNULL(ysnPosted,0) = 1))
		RAISERROR('Posted invoice cannot be updated!', 16, 1);
		
	IF ISNULL(@InvoiceId,0) = 0
		SELECT @InvoiceId = [intInvoiceId] FROM tblARInvoiceDetail WHERE [intInvoiceDetailId] = @InvoiceDetailId
	
	UPDATE
		tblARInvoiceDetail
	SET
		 [dblPrice]		= @Price
		,[dblBasePrice]	= ISNULL(ISNULL(@Price, @ZeroDecimal) * (CASE WHEN ISNULL([dblCurrencyExchangeRate], @ZeroDecimal) = @ZeroDecimal THEN 1 ELSE [dblCurrencyExchangeRate] END), @ZeroDecimal)
	WHERE
		[intInvoiceDetailId] = @InvoiceDetailId


	EXEC dbo.[uspARReComputeInvoiceAmounts] @InvoiceId = @InvoiceId

END TRY
BEGIN CATCH	
	DECLARE @ErrorMerssage NVARCHAR(MAX)
	SELECT @ErrorMerssage = ERROR_MESSAGE()									
	RAISERROR(@ErrorMerssage, 11, 1);
	RETURN 0	
END CATCH		

RETURN 1		                     
		                     
END