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

BEGIN
	
	DECLARE @UserEntityId INT
	SET @UserEntityId = ISNULL((SELECT [intEntityId] FROM tblSMUserSecurity WHERE [intEntityId] = @UserId), @UserId)

	SELECT DISTINCT RecordKey = intLoadHeaderId INTO #tmpLoads FROM tblTRLoadHeader WHERE ysnPosted = 0

	IF @TransactionId != 'ALL'
	BEGIN
		DELETE FROM #tmpLoads WHERE RecordKey NOT IN (SELECT Item FROM [fnSplitStringWithTrim](@TransactionId,',') )
	END

	DECLARE @intRecordKey INT

	SET @SuccessfulCount = 0

	WHILE EXISTS(SELECT 1 FROM #tmpLoads)
	BEGIN
		SELECT TOP 1 @intRecordKey = RecordKey FROM #tmpLoads

		EXEC [uspTRLoadPosting]
			 @intLoadHeaderId = @intRecordKey
			,@intUserId = @UserId
			,@ysnRecap = @Recap
			,@ysnPostOrUnPost = @Post

		DELETE FROM #tmpLoads WHERE RecordKey = @intRecordKey
	END

	DROP TABLE #tmpLoads
END