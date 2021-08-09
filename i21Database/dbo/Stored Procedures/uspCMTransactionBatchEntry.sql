
CREATE PROCEDURE [dbo].[uspCMTransactionBatchEntry]
	@intBankTransactionTypeId INT,
	@intBankAccountId INT,
	@intCurrencyId INT,
	@dtmBatchDate DATETIME,
	@strBankTransactionBatchId NVARCHAR(40),
	@intCompanyLocationId INT,
	@strDescription NVARCHAR(250),
	@intEntityUserId INT,
	@BankTransactionBatchDetailEntries BankTransactionBatchDetailTable READONLY,
	@newStrTransactionIds NVARCHAR(MAX) = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @NewIntTransactionId INT,
		@transactionType NVARCHAR(50) = 'Bank Deposit',
		@newStrTransactionId  NVARCHAR(40),
		@intStartingNumberId INT

--Variables for Detail
DECLARE @intTransactionId INT
		,@dtmDate DATETIME
		,@intGLAccountId INT
		,@strDescriptionDetail NVARCHAR(250)
		,@strName NVARCHAR(50)
		,@dblDebit DECIMAL(18,6)
		,@dblCredit DECIMAL(18,6)
		,@strRowState NVARCHAR(20)
		,@intConcurrencyId INT
		,@detailCount INT
		,@intBankLoanId INT


SELECT  *
INTO	#tmpBankTransactionBatchDetailEntries
FROM @BankTransactionBatchDetailEntries 
--ORDER BY intTransactionId DESC


	IF @transactionType <> 'Bank Transfer'
	BEGIN 
		
		--Update transaction header if the changes happens in batch header only (meaning no detail was sent upon request)
		SELECT @detailCount = COUNT(intTransactionId) FROM #tmpBankTransactionBatchDetailEntries
		IF @detailCount = 0
		BEGIN
			UPDATE [dbo].[tblCMBankTransaction]
					SET [intBankAccountId] = @intBankAccountId
						,[intCurrencyId] = @intCurrencyId
						,[dtmDate] = @dtmBatchDate
						,[strMemo] = @strDescription
						,[intCompanyLocationId] = @intCompanyLocationId
						,[intLastModifiedUserId] = @intEntityUserId
						,[dtmLastModified] = GETDATE()
						,[intConcurrencyId] = intConcurrencyId + 1
					WHERE intTransactionId IN (SELECT intTransactionId FROM tblCMBankTransaction WHERE strLink = @strBankTransactionBatchId AND intBankTransactionTypeId = @intBankTransactionTypeId)
		END

	
		WHILE EXISTS (SELECT TOP 1 1 FROM #tmpBankTransactionBatchDetailEntries) -- ORDER BY intTransactionId DESC)
		BEGIN
			SELECT TOP 1 
				@intTransactionId		= intTransactionId
				,@dtmDate				= dtmDate
				,@intGLAccountId		= intGLAccountId
				,@intBankLoanId			= intBankLoanId
				,@strDescriptionDetail	= strDescription
				,@strName				= strName
				,@dblDebit				= dblDebit
				,@dblCredit				= dblCredit
				,@strRowState			= strRowState
				,@intConcurrencyId		= intConcurrencyId
			FROM #tmpBankTransactionBatchDetailEntries --ORDER BY intTransactionId DESC

			IF @strRowState = 'Added'
			BEGIN
				--Assemble the transaction id
				--SELECT @newStrTransactionId = strPrefix + CAST(intNumber AS NVARCHAR) FROM tblSMStartingNumber WHERE strTransactionType = @transactionType
				SELECT @intStartingNumberId = intStartingNumberId FROM tblSMStartingNumber WHERE strTransactionType = @transactionType
				EXEC uspSMGetStartingNumber @intStartingNumberId, @newStrTransactionId OUTPUT, @intCompanyLocationId

				SET @newStrTransactionIds = ISNULL(@newStrTransactionIds,'') + @newStrTransactionId + ','

				INSERT INTO tblCMBankTransaction(
					[strTransactionId]
					,[intBankTransactionTypeId]
					,[intBankAccountId]
					,[intBankLoanId]
					,[intCurrencyId]
					,[dblExchangeRate]
					,[dtmDate]
					,[strPayee]
					,[intPayeeId]
					,[strAddress]
					,[strZipCode]
					,[strCity]
					,[strState]
					,[strCountry]
					,[dblAmount]
					,[dblShortAmount]
					,[intShortGLAccountId]
					,[strAmountInWords]
					,[strMemo]
					,[strReferenceNo]
					,[dtmCheckPrinted]
					,[ysnCheckToBePrinted]
					,[ysnCheckVoid]
					,[ysnPosted]
					,[strLink]
					,[ysnClr]
					,[ysnEmailSent]
					,[strEmailStatus]
					,[dtmDateReconciled]
					,[intBankStatementImportId]
					,[intBankFileAuditId]
					,[strSourceSystem]
					,[intEntityId]
					,[intCreatedUserId]
					,[intCompanyLocationId]
					,[dtmCreated]
					,[intLastModifiedUserId]
					,[dtmLastModified]
					,[ysnRecurring]
					,[ysnDelete]
					,[dtmDateDeleted]
					,[intConcurrencyId]
				)
				VALUES( 
					@newStrTransactionId--[strTransactionId]
					,@intBankTransactionTypeId--[intBankTransactionTypeId]
					,@intBankAccountId--[intBankAccountId]
					,@intBankLoanId
					,@intCurrencyId--[intCurrencyId]
					,1--[dblExchangeRate]
					,@dtmDate--[dtmDate]
					,@strName--[strPayee]
					,NULL--[intPayeeId]
					,NULL--[strAddress]
					,NULL--[strZipCode]
					,NULL--[strCity]
					,NULL--[strState]
					,NULL--[strCountry]
					,@dblCredit--[dblAmount]
					,0--[dblShortAmount]
					,NULL--[intShortGLAccountId]
					,dbo.fnConvertNumberToWord(@dblCredit)--[strAmountInWords]
					,@strDescription--[strMemo]
					,''--[strReferenceNo]
					,NULL --[dtmCheckPrinted]
					,1 --[ysnCheckToBePrinted]
					,0 --[ysnCheckVoid]
					,0 --[ysnPosted]
					,@strBankTransactionBatchId--[strLink]
					,0 --[ysnClr]
					,NULL --[ysnEmailSent]
					,NULL --[strEmailStatus]
					,NULL --[dtmDateReconciled]
					,NULL--[intBankStatementImportId]
					,NULL--[intBankFileAuditId]
					,NULL--[strSourceSystem]
					,@intEntityUserId--[intEntityId]
					,@intEntityUserId--[intCreatedUserId]
					,@intCompanyLocationId--[intCompanyLocationId]
					,GETDATE()--[dtmCreated]
					,@intEntityUserId --[intLastModifiedUserId]
					,GETDATE() --[dtmLastModified]
					,0--[ysnRecurring]
					,NULL--[ysnDelete]
					,NULL--[dtmDateDeleted]
					,0--[intConcurrencyId]
					)

					SET @NewIntTransactionId = SCOPE_IDENTITY()


				--=====================================================================================================================================
				-- 	CREATE THE BANK TRANSACTION DETAIL ENTRIES TO THE tblCMBankTransactionDetail table.
				--=====================================================================================================================================

				--Add the Bank Transaction Detail entries from the temporary table to the permanent table (tblCMBankTransactionDetail)
				INSERT INTO [dbo].[tblCMBankTransactionDetail]
					([intTransactionId]
					,[dtmDate]
					,[intGLAccountId]
					,[strDescription]
					,[dblDebit]
					,[dblCredit]
					,[intUndepositedFundId]
					,[intEntityId]
					,[intCreatedUserId]
					,[dtmCreated]
					,[intLastModifiedUserId]
					,[dtmLastModified]
					,[intConcurrencyId])
					VALUES(
					@NewIntTransactionId
					,@dtmDate			
					,@intGLAccountId	
					,@strDescriptionDetail	
					,@dblDebit			
					,@dblCredit			
					,NULL--[intUndepositedFundId]
					,@intEntityUserId--[intEntityId]
					,@intEntityUserId--[intCreatedUserId]
					,GETDATE()--[dtmCreated]
					,@intEntityUserId--[intLastModifiedUserId]
					,GETDATE()--[dtmLastModified]
					,0--[intConcurrencyId]
					)

				
				--UPDATE starting numbers
				--UPDATE tblSMStartingNumber SET intNumber = intNumber + 1 WHERE strTransactionType = @transactionType
			END

			IF @strRowState = 'Modified'
			BEGIN
				UPDATE [dbo].[tblCMBankTransaction]
					SET [intBankTransactionTypeId] = @intBankTransactionTypeId
						,[intBankAccountId] = @intBankAccountId
						,[intBankLoanId] = @intBankLoanId
						,[intCurrencyId] = @intCurrencyId
						,[dtmDate] = @dtmDate
						,[strPayee] = @strName
						,[dblAmount] = @dblCredit
						,[strAmountInWords] = dbo.fnConvertNumberToWord(@dblCredit)
						,[strMemo] = @strDescription
						,[intCompanyLocationId] = @intCompanyLocationId
						,[intLastModifiedUserId] = @intEntityUserId
						,[dtmLastModified] = GETDATE()
						,[intConcurrencyId] = intConcurrencyId + 1
					WHERE intTransactionId = @intTransactionId



				--==============
				--UPDATE DETAILS
				--==============
				UPDATE [dbo].[tblCMBankTransactionDetail]
					SET [dtmDate] = @dtmDate
						,[intGLAccountId] = @intGLAccountId
						,[strDescription] = @strDescriptionDetail
						,[dblDebit] = @dblDebit
						,[dblCredit] = @dblCredit
						,[intLastModifiedUserId] = @intEntityUserId
						,[dtmLastModified] = GETDATE()
						,[intConcurrencyId] = intConcurrencyId + 1
					WHERE intTransactionId = @intTransactionId

			END

			IF @strRowState = 'Delete'
			BEGIN

				DELETE FROM [dbo].[tblCMBankTransaction] WHERE intTransactionId = @intTransactionId AND ysnPosted = 0

			END

			DELETE FROM #tmpBankTransactionBatchDetailEntries WHERE intTransactionId =  @intTransactionId

		END

	END
	--ELSE
	--BEGIN

	--	INSERT INTO [dbo].[tblCMBankTransfer]
	--		([strTransactionId]
	--        ,[dtmDate]
	--        ,[intBankTransactionTypeId]
	--        ,[dblAmount]
	--        ,[strDescription]
	--        ,[intBankAccountIdFrom]
	--        ,[intGLAccountIdFrom]
	--        ,[strReferenceFrom]
	--        ,[intBankAccountIdTo]
	--        ,[intGLAccountIdTo]
	--        ,[strReferenceTo]
	--        ,[ysnPosted]
	--        ,[intEntityId]
	--        ,[intCreatedUserId]
	--        ,[dtmCreated]
	--        ,[intLastModifiedUserId]
	--        ,[dtmLastModified]
	--        ,[ysnRecurring]
	--        ,[ysnDelete]
	--        ,[dtmDateDeleted]
	--        ,[intConcurrencyId])
	--	SELECT
	--		@newStrTransactionId
	--        ,@dtmDate
	--        ,[intBankTransactionTypeId]
	--        ,[dblAmount]
	--        ,[strDescription]
	--        ,[intBankAccountIdFrom]
	--        ,[intGLAccountIdFrom]
	--        ,[strReferenceFrom]
	--        ,[intBankAccountIdTo]
	--        ,[intGLAccountIdTo]
	--        ,[strReferenceTo]
	--        ,0--[ysnPosted]
	--        ,@entityId--[intEntityId]
	--        ,@entityId--[intCreatedUserId]
	--        ,GETDATE()--[dtmCreated]
	--        ,@entityId--[intLastModifiedUserId]
	--        ,GETDATE()--[dtmLastModified]
	--        ,0--[ysnRecurring]
	--        ,[ysnDelete]
	--        ,[dtmDateDeleted]
	--        ,0--[intConcurrencyId]
	--	FROM tblCMBankTransfer

	--END




--=====================================================================================================================================
-- 	EXIT ROUTINES 
---------------------------------------------------------------------------------------------------------------------------------------
Exit_Procedure: