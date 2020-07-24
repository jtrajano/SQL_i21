CREATE PROCEDURE [dbo].[uspTRBatchLoadPosting]
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

BEGIN TRY

	SET @SuccessfulCount = 0
		
	DECLARE @intId INT = NULL
	DECLARE @tmpData TABLE (
		intId INT NOT NULL
	)

	IF @TransactionId != 'ALL'
	BEGIN
		INSERT INTO @tmpData (intId)
		SELECT Item FROM [fnSplitStringWithTrim](@TransactionId,',')
	END
	ELSE
	BEGIN
		INSERT INTO @tmpData (intId)
		SELECT intLoadHeaderId FROM tblTRLoadHeader WHERE ysnPosted = 0
	END

	DECLARE CursorTran CURSOR FOR
	SELECT intId FROM @tmpData 

	OPEN CursorTran 
	FETCH NEXT FROM CursorTran INTO @intId  
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		DECLARE @strTransaction NVARCHAR(50) = NULL
		DECLARE @Message NVARCHAR(MAX)	= NULL

		BEGIN TRY

			SELECT @strTransaction = strTransaction FROM tblTRLoadHeader WHERE intLoadHeaderId = @intId

			EXEC [uspTRLoadPosting]
				@intLoadHeaderId = @intId
				,@intUserId = @UserId
				,@ysnRecap = @Recap
				,@ysnPostOrUnPost = @Post
				,@BatchId = @BatchId

			SET @SuccessfulCount = @SuccessfulCount + 1
			IF @Post = 1 AND @Recap=1
			BEGIN
				SET @Message = 'Post Preview is not applicable for Transport Load'
			END
			ELSE 
			BEGIN
				SET @Message = 'Transport Load Posted Successfully'
			END

		END TRY
		BEGIN CATCH	
			SET @Message = ERROR_MESSAGE()
		END CATCH

		-- CREATE TO BATCH POST LOG
		INSERT INTO tblTRPostResult (strBatchId, intTransactionId, strTransactionId, strDescription, dtmDate, strTransactionType, intUserId)
		VALUES(@BatchId, @intId, @strTransaction , @Message, GETDATE(), 'Transport Load', @UserId)

		FETCH NEXT FROM CursorTran INTO @intId
	END
	CLOSE CursorTran
	DEALLOCATE CursorTran

END TRY
BEGIN CATCH

	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE()

	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	)
END CATCH
