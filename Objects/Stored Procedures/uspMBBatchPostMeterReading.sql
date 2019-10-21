CREATE PROCEDURE [dbo].[uspMBBatchPostMeterReading]
	@TransactionId		NVARCHAR(MAX)
	, @UserId				INT
	, @Post					BIT
	, @Recap				BIT
	, @BatchId				NVARCHAR(MAX)
	, @SuccessfulCount		INT				= 0		OUTPUT
	, @ErrorMessage			NVARCHAR(250)	= NULL	OUTPUT
	, @CreatedInvoices		NVARCHAR(MAX)	= NULL	OUTPUT
	, @UpdatedInvoices		NVARCHAR(MAX)	= NULL	OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT
DECLARE @ErrorNumber INT

BEGIN TRY
	
	DECLARE @intCurrency INT = NULL
	DECLARE @tmpRecord TABLE (intId INT NOT NULL, UNIQUE (intId))
	DECLARE @intId INT = NULL
	DECLARE @CursorTran AS CURSOR

	SELECT @intCurrency = ISNULL(intDefaultCurrencyId, 1) FROM tblSMCompanyPreference

	IF @TransactionId != 'ALL'
	BEGIN
		INSERT INTO @tmpRecord(intId)
		SELECT CONVERT(INT,Item) FROM [fnSplitStringWithTrim](@TransactionId,',')
	END
	ELSE
	BEGIN
		INSERT INTO @tmpRecord(intId)
		SELECT DISTINCT intMeterReadingId FROM vyuMBGetMeterReading WHERE ysnPosted = 0
	END
	
	SET @SuccessfulCount = 0


	SET @CursorTran = CURSOR FOR
	SELECT intId FROM @tmpRecord ORDER BY intId

	OPEN @CursorTran
	FETCH NEXT FROM @CursorTran INTO @intId
	WHILE @@FETCH_STATUS = 0
	BEGIN

		DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
		DECLARE @strMeterReadingError NVARCHAR(MAX) = NULL
		DECLARE @strTransactionId NVARCHAR(30) = NULL
		DECLARE @intInvoiceId INT = NULL

		SELECT @strTransactionId = strTransactionId, @intInvoiceId = intInvoiceId FROM tblMBMeterReading WHERE intMeterReadingId = @intId

		BEGIN TRY
			IF (@Recap = 0)
			BEGIN
				EXEC [dbo].[uspMBPostMeterReading]
					@TransactionId = @intId
					,@UserId = @UserId
					,@Post = @Post
					,@Recap = @Recap
					,@InvoiceId = @intInvoiceId
					,@ErrorMessage = @ErrorMessage
					,@CreatedInvoices = @CreatedInvoices
					,@UpdatedInvoices = @UpdatedInvoices

				SET @strMeterReadingError = 'Meter Reading successfully posted'
				SET @SuccessfulCount = @SuccessfulCount + 1
			END
			ELSE
			BEGIN
				SET @strMeterReadingError = 'Post Preview is not applicable'
			END
		END TRY
		BEGIN CATCH
			SET @strMeterReadingError = ERROR_MESSAGE()	
		END CATCH

		--Add to Batch Post Log for invalid Meter Reading
		INSERT INTO tblMBPostResult (strBatchId, intTransactionId, strTransactionId, strDescription, dtmDate, strTransactionType, intUserId)
		VALUES(@BatchId, @intId, @strTransactionId, @strMeterReadingError, GETDATE(), 'Meter Reading', @UserId)

		FETCH NEXT FROM @CursorTran INTO @intId
	END
	CLOSE @CursorTran
	DEALLOCATE @CursorTran

END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorState = ERROR_STATE()
	SET @ErrorNumber   = ERROR_NUMBER()
		
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState ,@ErrorNumber)
END CATCH