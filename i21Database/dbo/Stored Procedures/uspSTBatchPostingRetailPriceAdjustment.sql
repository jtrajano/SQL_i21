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
	
	DECLARE @UserEntityId		INT = NULL
	DECLARE @intId				INT = NULL
	DECLARE @ysnSuccess			BIT = CAST(1 AS BIT)
	DECLARE @strMessage			NVARCHAR(1000)

	DECLARE @tmpData TABLE (
		intId INT NOT NULL,
		PRIMARY KEY CLUSTERED (intId)
	)

	SET @UserEntityId = ISNULL((SELECT intEntityId FROM tblSMUserSecurity WHERE intEntityId = @UserId), @UserId)


	IF (@TransactionId = 'ALL')
		BEGIN
			INSERT INTO @tmpData 
			(
				intId
			)
			SELECT DISTINCT 
				intId	= vrpa.intTransactionId
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
				intId
			)
			SELECT DISTINCT 
				intId	= vrpa.intTransactionId
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
				@intId = intId 
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
				END
			ELSE
				BEGIN
					SET @ErrorMessage = @strMessage
					RETURN
				END
			

			DELETE FROM @tmpData WHERE intId = @intId
		END

END