CREATE PROCEDURE [dbo].[uspARRebuildInvoice]
	 @intInvoiceId			INT
	,@dblPostedPayment		NUMERIC(18, 6)
	,@dblPostedBasePayment	NUMERIC(18, 6)
	,@dblPostedDiscount		NUMERIC(18, 6)
	,@dblPostedBaseDiscount	NUMERIC(18, 6)
	,@dblPostedInterest		NUMERIC(18, 6)
	,@dblPostedBaseInterest	NUMERIC(18, 6)
AS

DECLARE  @InitTranCount		INT
		,@Savepoint			NVARCHAR(32)
		,@ErrorMerssage		NVARCHAR(MAX)

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('uspARRebuildInvoice' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint

BEGIN TRY
	DECLARE @dblAmountDue		NUMERIC(18, 6)
	DECLARE @dblBaseAmountDue	NUMERIC(18, 6)

	UPDATE tblARInvoice 
	SET 
		 dblPayment			= ISNULL(@dblPostedPayment, 0)
		,dblBasePayment		= ISNULL(@dblPostedBasePayment, 0)
		,dblDiscount		= ISNULL(@dblPostedDiscount, 0)
		,dblBaseDiscount	= ISNULL(@dblPostedBaseDiscount, 0)
		,dblInterest		= ISNULL(@dblPostedInterest, 0)
		,dblBaseInterest	= ISNULL(@dblPostedBaseInterest, 0)
		,dblAmountDue		= dblInvoiceTotal + ISNULL(@dblPostedInterest, 0) - ISNULL(@dblPostedPayment, 0)
		,dblBaseAmountDue	= dblBaseInvoiceTotal + ISNULL(@dblPostedBaseInterest, 0) - ISNULL(@dblPostedBasePayment, 0)
	WHERE intInvoiceId		= @intInvoiceId

	IF @InitTranCount = 0 AND XACT_STATE() = 1
		COMMIT TRANSACTION
END TRY
BEGIN CATCH
	SELECT @ErrorMerssage = ERROR_MESSAGE()

	IF @InitTranCount = 0
		IF (XACT_STATE()) <> 0
			ROLLBACK TRANSACTION
        ELSE
            IF (XACT_STATE()) <> 0
                ROLLBACK TRANSACTION @Savepoint

	RAISERROR(@ErrorMerssage, 11, 1)
END CATCH

RETURN 0
