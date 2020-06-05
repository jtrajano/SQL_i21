CREATE PROCEDURE uspCMBatchPosting
	@ysnPost				BIT		= 0
	,@ysnRecap				BIT		= 0
	,@TransactionId			NVARCHAR(MAX)
	,@strTransactionType	NVARCHAR(50)
	,@intUserId				INT		= NULL
	,@intEntityId			INT		= NULL
	,@BatchId				NVARCHAR(MAX)
	,@successfulCount		AS INT	= 0 OUTPUT

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
--SET ANSI_WARNINGS OFF

--=====================================================================================================================================
-- 	DECLARATION 
---------------------------------------------------------------------------------------------------------------------------------------
DECLARE @intTransactionId AS INT
		,@strTransactionId AS NVARCHAR(40)
		,@intCount AS INT = 0
		,@isSuccessful AS BIT
		,@PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'


SELECT intTransactionId = Item INTO #tmpTransactionId FROM fnSplitString(@TransactionId,',')

IF @strTransactionType = 'Bank Deposit'
BEGIN
	WHILE (EXISTS(SELECT 1 FROM #tmpTransactionId ))
	BEGIN
		SELECT TOP 1 @intTransactionId = intTransactionId FROM #tmpTransactionId

		SELECT @strTransactionId = strTransactionId FROM tblCMBankTransaction WHERE intTransactionId = @intTransactionId

		EXEC uspCMPostBankDeposit 
		@ysnPost=@ysnPost, 
		@ysnRecap =@ysnRecap, 
		@strTransactionId=@strTransactionId,
		@strBatchId= @BatchId, 
		@intUserId=@intUserId, 
		@intEntityId=@intEntityId, 
		@isSuccessful=@isSuccessful OUTPUT
		,@ysnBatch =1

		IF @@ERROR = 0 AND @isSuccessful = 1
		BEGIN
			SET @intCount += 1
			--Insert on Post Result when not a recap
			IF @ysnRecap = 0
			INSERT INTO tblGLPostResult (strBatchId,intTransactionId,strTransactionId,strDescription,dtmDate,intEntityId,strTransactionType)
			VALUES(@BatchId,@intTransactionId,@strTransactionId,@PostSuccessfulMsg,GETDATE(),@intEntityId,@strTransactionType)
		END
		ELSE
		BEGIN
			INSERT INTO tblGLPostResult (strBatchId,intTransactionId,strTransactionId,strDescription,dtmDate,intEntityId,strTransactionType)
			VALUES(@BatchId,@intTransactionId,@strTransactionId,'ERROR',GETDATE(),@intEntityId,@strTransactionType)
		END

		DELETE FROM #tmpTransactionId WHERE intTransactionId = @intTransactionId
	END
	GOTO Post_Exit
END

IF @strTransactionType = 'Bank Transaction'
BEGIN
	WHILE (EXISTS(SELECT 1 FROM #tmpTransactionId ))
	BEGIN
		SELECT TOP 1 @intTransactionId = intTransactionId FROM #tmpTransactionId

		SELECT @strTransactionId = strTransactionId FROM tblCMBankTransaction WHERE intTransactionId = @intTransactionId
		
		EXEC uspCMPostBankTransaction 
			@ysnPost=@ysnPost, 
			@ysnRecap=@ysnRecap, 
			@strTransactionId=@strTransactionId, 
			@strBatchId=@BatchId, 
			@intUserId=@intUserId, 
			@intEntityId=@intEntityId, 
			@isSuccessful=@isSuccessful OUTPUT,
			@ysnBatch = 1

		IF @@ERROR = 0 AND @isSuccessful = 1
		BEGIN
			SET @intCount += 1
			--Insert on Post Result when not a recap
			IF @ysnRecap = 0
			INSERT INTO tblGLPostResult (strBatchId,intTransactionId,strTransactionId,strDescription,dtmDate,intEntityId,strTransactionType)
			VALUES(@BatchId,@intTransactionId,@strTransactionId,@PostSuccessfulMsg,GETDATE(),@intEntityId,@strTransactionType)
		END
		ELSE
		BEGIN
			INSERT INTO tblGLPostResult (strBatchId,intTransactionId,strTransactionId,strDescription,dtmDate,intEntityId,strTransactionType)
			VALUES(@BatchId,@intTransactionId,@strTransactionId,'ERROR',GETDATE(),@intEntityId,@strTransactionType)
		END

		DELETE FROM #tmpTransactionId WHERE intTransactionId = @intTransactionId
	END
	GOTO Post_Exit
END

IF @strTransactionType = 'Misc Checks'
BEGIN
	WHILE (EXISTS(SELECT 1 FROM #tmpTransactionId ))
	BEGIN
		SELECT TOP 1 @intTransactionId = intTransactionId FROM #tmpTransactionId

		SELECT @strTransactionId = strTransactionId FROM tblCMBankTransaction WHERE intTransactionId = @intTransactionId

		EXEC uspCMPostMiscChecks  
		@ysnPost=@ysnPost, 
		@ysnRecap=@ysnRecap,
		@strTransactionId =@strTransactionId, 
		@strBatchId=@BatchId, 
		@intUserId=@intUserId, 
		@intEntityId=@intEntityId, 
		@isSuccessful=@isSuccessful OUTPUT,
		@ysnBatch = 1

		IF @@ERROR = 0 AND @isSuccessful = 1
		BEGIN
			SET @intCount += 1
			--Insert on Post Result when not a recap
			IF @ysnRecap = 0
			INSERT INTO tblGLPostResult (strBatchId,intTransactionId,strTransactionId,strDescription,dtmDate,intEntityId,strTransactionType)
			VALUES(@BatchId,@intTransactionId,@strTransactionId,@PostSuccessfulMsg,GETDATE(),@intEntityId,@strTransactionType)
		END
		ELSE
		BEGIN
			INSERT INTO tblGLPostResult (strBatchId,intTransactionId,strTransactionId,strDescription,dtmDate,intEntityId,strTransactionType)
			VALUES(@BatchId,@intTransactionId,@strTransactionId,'ERROR',GETDATE(),@intEntityId,@strTransactionType)
		END

		DELETE FROM #tmpTransactionId WHERE intTransactionId = @intTransactionId
	END
	GOTO Post_Exit
END

IF @strTransactionType = 'Bank Transfer'
BEGIN
	WHILE (EXISTS(SELECT 1 FROM #tmpTransactionId ))
	BEGIN
		SELECT TOP 1 @intTransactionId = intTransactionId FROM #tmpTransactionId

		SELECT @strTransactionId = strTransactionId FROM tblCMBankTransfer WHERE intTransactionId = @intTransactionId

		EXEC uspCMPostBankTransfer 
		@ysnPost=@ysnPost, 
		@ysnRecap= @ysnRecap, 
		@strTransactionId=@strTransactionId, 
		@strBatchId=@BatchId,
		@intUserId =@intUserId, 
		@intEntityId=@intEntityId, 
		@isSuccessful=@isSuccessful OUTPUT,
		@ysnBatch = 1

		IF @@ERROR = 0 AND @isSuccessful = 1
		BEGIN
			SET @intCount += 1
			--Insert on Post Result when not a recap
			IF @ysnRecap = 0
			INSERT INTO tblGLPostResult (strBatchId,intTransactionId,strTransactionId,strDescription,dtmDate,intEntityId,strTransactionType)
			VALUES(@BatchId,@intTransactionId,@strTransactionId,@PostSuccessfulMsg,GETDATE(),@intEntityId,@strTransactionType)
		END
		ELSE
		BEGIN
			INSERT INTO tblGLPostResult (strBatchId,intTransactionId,strTransactionId,strDescription,dtmDate,intEntityId,strTransactionType)
			VALUES(@BatchId,@intTransactionId,@strTransactionId,'ERROR',GETDATE(),@intEntityId,@strTransactionType)
		END

		DELETE FROM #tmpTransactionId WHERE intTransactionId = @intTransactionId
	END
	GOTO Post_Exit
END


--=====================================================================================================================================
-- 	EXIT ROUTINES
---------------------------------------------------------------------------------------------------------------------------------------
Post_Exit:
SET @successfulCount = @intCount