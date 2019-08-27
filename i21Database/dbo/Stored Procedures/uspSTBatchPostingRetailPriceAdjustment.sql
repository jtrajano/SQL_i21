CREATE PROCEDURE [dbo].[uspSTBatchPostingRetailPriceAdjustment]
	@TransactionId		NVARCHAR(MAX)
	, @UserId				INT
	, @Post					BIT
	, @Recap				BIT
	, @BatchId				NVARCHAR(MAX)
	, @SuccessfulCount		INT				= 0		OUTPUT
	, @ErrorMessage			NVARCHAR(250)	= NULL	OUTPUT

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

BEGIN
	
	DECLARE @UserEntityId							INT = NULL
	DECLARE @intId									INT = NULL
	DECLARE @strRetailPriceAdjustmentBatchId		NVARCHAR(50)
	DECLARE @ysnSuccess								BIT = CAST(1 AS BIT)
	DECLARE @strMessage								NVARCHAR(1000)

	DECLARE @tmpData TABLE (
		intId							INT			NOT NULL,
		strRetailPriceAdjustmentBatchId	NVARCHAR(50)
		PRIMARY KEY CLUSTERED (intId)
	)

	SET @UserEntityId = ISNULL((SELECT intEntityId FROM tblSMUserSecurity WHERE intEntityId = @UserId), @UserId)


	IF (@TransactionId = 'ALL')
		BEGIN
			INSERT INTO @tmpData 
			(
				intId,
				strRetailPriceAdjustmentBatchId
			)
			SELECT DISTINCT 
				intId								= vrpa.intTransactionId,
				strRetailPriceAdjustmentBatchId		= rpa.strRetailPriceAdjustmentNumber
			FROM vyuSTBatchPostingRetailPriceAdjustment vrpa
			INNER JOIN tblSTRetailPriceAdjustment rpa
				ON vrpa.intTransactionId = rpa.intRetailPriceAdjustmentId
			WHERE ISNULL(vrpa.ysnPosted, 0) = 0
				AND CAST(rpa.dtmEffectiveDate AS DATE) <= CAST(GETDATE() AS DATE)
		END
	ELSE 
		BEGIN
			INSERT INTO @tmpData 
			(
				intId,
				strRetailPriceAdjustmentBatchId
			)
			SELECT DISTINCT 
				intId								= vrpa.intTransactionId,
				strRetailPriceAdjustmentBatchId		= rpa.strRetailPriceAdjustmentNumber
			FROM vyuSTBatchPostingRetailPriceAdjustment vrpa
			INNER JOIN tblSTRetailPriceAdjustment rpa
				ON vrpa.intTransactionId = rpa.intRetailPriceAdjustmentId
			WHERE ISNULL(vrpa.ysnPosted, 0) = 0
				AND CAST(rpa.dtmEffectiveDate AS DATE) <= CAST(GETDATE() AS DATE)
				AND vrpa.intTransactionId IN (SELECT Item FROM [fnSplitStringWithTrim](@TransactionId,',') )
		END

	
	SET @SuccessfulCount = 0


	WHILE EXISTS(SELECT TOP 1 1 FROM @tmpData)
		BEGIN 

			SELECT TOP 1 
				@intId							 = intId,
				@strRetailPriceAdjustmentBatchId = strRetailPriceAdjustmentBatchId
			FROM @tmpData


			EXEC [dbo].[uspSTUpdateRetailPriceAdjustment]
				@intRetailPriceAdjustmentId		= @intId,
				@intCurrentUserId				= @UserEntityId,
				@ysnHasPreviewReport			= 1,
				@ysnRecap						= @Recap,
				@ysnSuccess						= @ysnSuccess	OUTPUT,
				@strMessage						= @strMessage	OUTPUT
			
			IF(@ysnSuccess = 1)
				BEGIN
					SET @SuccessfulCount = @SuccessfulCount + 1;

					INSERT INTO tblSTPostResult
					(
						[strBatchId],
						[intTransactionId],
						[strTransactionId],
						[strDescription],
						[dtmDate],
						[strTransactionType],
						[intUserId],
						[intEntityId]
					)
					SELECT 
						[strBatchId]		= @BatchId,
						[intTransactionId]	= @intId,
						[strTransactionId]	= @strRetailPriceAdjustmentBatchId,
						[strDescription]	= 'Transaction successfully posted.',
						[dtmDate]			= GETUTCDATE(),
						[strTransactionType]= 'Retail Price Adjustment',
						[intUserId]			= @UserId,
						[intEntityId]		= @UserId

				END
			ELSE
				BEGIN
					SET @ErrorMessage = @strMessage
						
					INSERT INTO tblSTPostResult
					(
						[strBatchId],
						[intTransactionId],
						[strTransactionId],
						[strDescription],
						[dtmDate],
						[strTransactionType],
						[intUserId],
						[intEntityId]
					)
					SELECT 
						[strBatchId]		= @BatchId,
						[intTransactionId]	= @intId,
						[strTransactionId]	= @strRetailPriceAdjustmentBatchId,
						[strDescription]	= 'Unable to Post. ' + @strMessage,
						[dtmDate]			= GETUTCDATE(),
						[strTransactionType]= 'Retail Price Adjustment',
						[intUserId]			= @UserId,
						[intEntityId]		= @UserId

					RETURN
				END
			

			DELETE FROM @tmpData WHERE intId = @intId
		END

END