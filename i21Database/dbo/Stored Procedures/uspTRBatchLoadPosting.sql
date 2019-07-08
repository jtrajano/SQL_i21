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
	
	DECLARE @UserEntityId INT = NULL
	DECLARE @intId INT = NULL
	DECLARE @tmpData TABLE (
		intId INT NOT NULL,
		PRIMARY KEY CLUSTERED (intId)
	)

	SET @UserEntityId = ISNULL((SELECT intEntityId FROM tblSMUserSecurity WHERE intEntityId = @UserId), @UserId)

	IF @TransactionId != 'ALL'
	BEGIN
		INSERT INTO @tmpData 
		SELECT DISTINCT intLoadHeaderId FROM tblTRLoadHeader WHERE ysnPosted = 0
		AND intLoadHeaderId IN (SELECT Item FROM [fnSplitStringWithTrim](@TransactionId,',') )
	END

	DECLARE CursorTran CURSOR FOR
	SELECT intLoadHeaderId
		FROM tblTRLoadHeader  
		WHERE ysnPosted = 0	AND 1=1
	
	SET @SuccessfulCount = 0

	OPEN CursorTran 
	FETCH NEXT FROM CursorTran INTO @intId  

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC [uspTRLoadPosting]
			 @intLoadHeaderId = @intId
			,@intUserId = @UserId
			,@ysnRecap = @Recap
			,@ysnPostOrUnPost = @Post

		SET @SuccessfulCount = @SuccessfulCount + 1;

		FETCH NEXT FROM CursorTran INTO @intId  
	END
	CLOSE CursorTran
	DEALLOCATE CursorTran

END