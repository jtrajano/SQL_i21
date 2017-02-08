CREATE PROCEDURE [dbo].[uspGLReverseGLEntries]
	 @strBatchId		AS NVARCHAR(100)	= ''
	,@strTransactionId	NVARCHAR(40)	= NULL
	,@ysnRecap			AS BIT			= 0
	,@strCode			NVARCHAR(10)	= NULL
	,@dtmDateReverse	DATETIME		= NULL 
	,@intEntityId		INT				= NULL 
	,@successfulCount	AS INT			= 0 OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION;

--=====================================================================================================================================
-- 	INITIALIZATION 
---------------------------------------------------------------------------------------------------------------------------------------
IF ISNULL(@ysnRecap, 0) = 0
BEGIN
	SELECT	@strBatchId = MAX(strBatchId)
	FROM	tblGLDetail
	WHERE	strTransactionId = @strTransactionId
			AND ysnIsUnposted = 0
			AND strCode = ISNULL(@strCode, strCode)
END			

--=====================================================================================================================================
-- 	REVERSE THE G/L ENTRIES
---------------------------------------------------------------------------------------------------------------------------------------
IF ISNULL(@ysnRecap, 0) = 0
	BEGIN			
		
		EXEC uspGLInsertReverseGLEntry @strTransactionId,@intEntityId,@dtmDateReverse
		IF @@ERROR <> 0	GOTO Post_Rollback;
	END
ELSE
	BEGIN
		-- DELETE Results 1 DAYS OLDER	
		DELETE tblGLPostRecap WHERE dtmDateEntered < DATEADD(day, -1, GETDATE()) and intEntityId = @intEntityId;
		DECLARE @GLEntries RecapTableType
		
		INSERT INTO @GLEntries (
			 [strTransactionId]
			,[intTransactionId]
			,[intAccountId]
			,[strDescription]
			,[strReference]	
			,[dtmTransactionDate]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitForeign]
			,[dblCreditForeign]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[dtmDate]
			,[ysnIsUnposted]
			,[intConcurrencyId]	
			,[dblExchangeRate]
			,[intUserId]
			,[intEntityId]
			,[dtmDateEntered]
			,[strBatchId]
			,[strCode]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
		)
		SELECT 
			 [strTransactionId]
			,[intTransactionId]
			,[intAccountId]			
			,[strDescription]		=  A.strJournalLineDescription
			,[strReference]			
			,[dtmTransactionDate]	
			,[dblDebit]				= [dblCredit]
			,[dblCredit]			= [dblDebit]	
			,[dblDebitForeign]		= [dblCreditForeign]
			,[dblCreditForeign]		= [dblDebitForeign]	
			,[dblDebitUnit]			= [dblCreditUnit]
			,[dblCreditUnit]		= [dblDebitUnit]
			,[dtmDate]				
			,[ysnIsUnposted]		
			,[intConcurrencyId]		
			,[dblExchangeRate]		
			,[intUserId]			= 0
			,[intEntityId]			= @intEntityId
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @strBatchId
			,[strCode]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
		FROM	tblGLDetail A
		WHERE	strTransactionId = @strTransactionId and ysnIsUnposted = 0
		ORDER BY intGLDetailId

		EXEC uspGLPostRecap @GLEntries, @intEntityId
				
		IF @@ERROR <> 0	GOTO Post_Rollback;

		GOTO Post_Commit;

	END

IF @@ERROR <> 0	GOTO Post_Rollback;

--=====================================================================================================================================
-- 	RETURN TOTAL NUMBER OF VALID GL ENTRIES
---------------------------------------------------------------------------------------------------------------------------------------
SET @successfulCount = (SELECT COUNT(*) FROM tblGLDetail WHERE strTransactionId = @strTransactionId)

IF @@ERROR <> 0	GOTO Post_Rollback;

--=====================================================================================================================================
-- 	FINALIZING STAGE
---------------------------------------------------------------------------------------------------------------------------------------
Post_Commit:
	COMMIT TRANSACTION
	GOTO Post_Exit

Post_Rollback:
	ROLLBACK TRANSACTION		            
	GOTO Post_Exit

Post_Exit:
	
GO

