CREATE PROCEDURE [dbo].[uspARRebuildPayment]
	@intPaymentId	INT
AS

DECLARE  @InitTranCount		INT
		,@Savepoint			NVARCHAR(32)
		,@ErrorMerssage		NVARCHAR(MAX)

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('uspARRebuildPayment' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint

BEGIN TRY
	DECLARE @PaymentDetails TABLE (
		 intPaymentDetailId INT
		,intInvoiceId		INT
	)

	INSERT INTO @PaymentDetails
	(
		intPaymentDetailId, intInvoiceId
	)
	SELECT DISTINCT intPaymentDetailId, intInvoiceId
	FROM tblARPaymentDetail
	WHERE intPaymentId = @intPaymentId

	WHILE EXISTS(SELECT TOP 1 NULL FROM @PaymentDetails)
	BEGIN
		DECLARE  @intPaymentDetailId	INT
				,@intInvoiceId			INT

		SELECT TOP 1 
			 @intPaymentDetailId	= intPaymentDetailId
			,@intInvoiceId			= intInvoiceId
		FROM @PaymentDetails ORDER BY intInvoiceId

		--Get posted payment, discount and interest
		DECLARE @dblPostedPayment		NUMERIC(18, 6) = 0
		DECLARE @dblPostedBasePayment	NUMERIC(18, 6) = 0
		DECLARE @dblPostedDiscount		NUMERIC(18, 6) = 0
		DECLARE @dblPostedBaseDiscount	NUMERIC(18, 6) = 0
		DECLARE @dblPostedInterest		NUMERIC(18, 6) = 0
		DECLARE @dblPostedBaseInterest	NUMERIC(18, 6) = 0

		SELECT 
			 @dblPostedPayment		= SUM((PD.dblPayment + PD.dblWriteOffAmount) * [dbo].[fnARGetInvoiceAmountMultiplier](I.[strTransactionType])) 
			,@dblPostedBasePayment  = SUM((PD.dblBasePayment + PD.dblBaseWriteOffAmount) * [dbo].[fnARGetInvoiceAmountMultiplier](I.[strTransactionType]))
			,@dblPostedDiscount		= SUM(PD.dblDiscount) 
			,@dblPostedBaseDiscount = SUM(PD.dblBaseDiscount) 
			,@dblPostedInterest		= SUM(PD.dblInterest) 
			,@dblPostedBaseInterest	= SUM(PD.dblBaseInterest)			
		FROM
			tblARPaymentDetail PD
		INNER JOIN tblARPayment P
		ON PD.intPaymentId = P.intPaymentId
		INNER JOIN tblARInvoice I
		ON PD.intInvoiceId = I.intInvoiceId
		WHERE
			P.[ysnInvoicePrepayment] = 0
		AND P.ysnPosted = 1
		AND I.intInvoiceId = @intInvoiceId
		GROUP BY
			PD.intInvoiceId,
			I.strTransactionType

		--Recompute amount due
		UPDATE tblARPayment
		SET intCurrentStatus = 5
		WHERE intPaymentId = @intPaymentId

		UPDATE tblARPaymentDetail 
		SET dblAmountDue		= dblInvoiceTotal + dblInterest - dblPayment - @dblPostedPayment
		  , dblBaseAmountDue	= dblBaseInvoiceTotal + dblBaseInterest - dblBasePayment - @dblPostedBasePayment
		WHERE intPaymentDetailId = @intPaymentDetailId

		EXEC uspARRebuildInvoice 
			 @intInvoiceId			 = @intInvoiceId
			,@dblPostedPayment		 = @dblPostedPayment
			,@dblPostedBasePayment   = @dblPostedBasePayment
			,@dblPostedDiscount		 = @dblPostedDiscount
			,@dblPostedBaseDiscount  = @dblPostedBaseDiscount
			,@dblPostedInterest		 = @dblPostedInterest
			,@dblPostedBaseInterest  = @dblPostedBaseInterest

		DELETE FROM @PaymentDetails WHERE intPaymentDetailId = @intPaymentDetailId
	END

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
