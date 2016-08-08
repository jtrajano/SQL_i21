CREATE PROCEDURE uspCMRecurTransaction
	@intTransactionId INT,
	@entityId INT,
	@dtmDate DATETIME,
	@transactionType NVARCHAR(20),
	@newStrTransactionId NVARCHAR(40) = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @NewIntTransactionId INT

--Assemble the transaction id
SELECT @newStrTransactionId = strPrefix + CAST(intNumber AS NVARCHAR) FROM tblSMStartingNumber WHERE strTransactionType = @transactionType

IF @transactionType <> 'Bank Transfer'
BEGIN 
--=====================================================================================================================================
-- 	CREATE THE BANK TRANSACTION ENTRIES TO THE tblCMBankTransaction table.
--=====================================================================================================================================

	INSERT INTO tblCMBankTransaction(
		[strTransactionId]
        ,[intBankTransactionTypeId]
        ,[intBankAccountId]
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
	SELECT 
		@newStrTransactionId--[strTransactionId]
        ,[intBankTransactionTypeId]
        ,[intBankAccountId]
        ,[intCurrencyId]
        ,[dblExchangeRate]
        ,@dtmDate--[dtmDate]
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
        ,NULL --[dtmCheckPrinted]
        ,1 --[ysnCheckToBePrinted]
        ,0 --[ysnCheckVoid]
        ,0 --[ysnPosted]
        ,[strLink]
        ,0 --[ysnClr]
        ,NULL --[ysnEmailSent]
        ,NULL --[strEmailStatus]
        ,NULL --[dtmDateReconciled]
        ,[intBankStatementImportId]
        ,[intBankFileAuditId]
        ,[strSourceSystem]
        ,@entityId--[intEntityId]
        ,@entityId--[intCreatedUserId]
        ,[intCompanyLocationId]
        ,GETDATE()--[dtmCreated]
        ,@entityId --[intLastModifiedUserId]
        ,GETDATE() --[dtmLastModified]
        ,0--[ysnRecurring]
        ,[ysnDelete]
        ,[dtmDateDeleted]
		,0--[intConcurrencyId]
	FROM tblCMBankTransaction
	WHERE intTransactionId = @intTransactionId

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
	SELECT
		@NewIntTransactionId
		,@dtmDate--[dtmDate]
		,[intGLAccountId]
		,[strDescription]
		,[dblDebit]
		,[dblCredit]
		,[intUndepositedFundId]
		,@entityId--[intEntityId]
		,@entityId--[intCreatedUserId]
		,GETDATE()--[dtmCreated]
		,@entityId--[intLastModifiedUserId]
		,GETDATE()--[dtmLastModified]
		,0--[intConcurrencyId]
	FROM tblCMBankTransactionDetail
	WHERE intTransactionId = @intTransactionId


END
ELSE
BEGIN

	INSERT INTO [dbo].[tblCMBankTransfer]
		([strTransactionId]
        ,[dtmDate]
        ,[intBankTransactionTypeId]
        ,[dblAmount]
        ,[strDescription]
        ,[intBankAccountIdFrom]
        ,[intGLAccountIdFrom]
        ,[strReferenceFrom]
        ,[intBankAccountIdTo]
        ,[intGLAccountIdTo]
        ,[strReferenceTo]
        ,[ysnPosted]
        ,[intEntityId]
        ,[intCreatedUserId]
        ,[dtmCreated]
        ,[intLastModifiedUserId]
        ,[dtmLastModified]
        ,[ysnRecurring]
        ,[ysnDelete]
        ,[dtmDateDeleted]
        ,[intConcurrencyId])
	SELECT
		@newStrTransactionId
        ,@dtmDate
        ,[intBankTransactionTypeId]
        ,[dblAmount]
        ,[strDescription]
        ,[intBankAccountIdFrom]
        ,[intGLAccountIdFrom]
        ,[strReferenceFrom]
        ,[intBankAccountIdTo]
        ,[intGLAccountIdTo]
        ,[strReferenceTo]
        ,0--[ysnPosted]
        ,@entityId--[intEntityId]
        ,@entityId--[intCreatedUserId]
        ,GETDATE()--[dtmCreated]
        ,@entityId--[intLastModifiedUserId]
        ,GETDATE()--[dtmLastModified]
        ,0--[ysnRecurring]
        ,[ysnDelete]
        ,[dtmDateDeleted]
        ,0--[intConcurrencyId]
	FROM tblCMBankTransfer
	WHERE intTransactionId = @intTransactionId

END
;

--UPDATE starting numbers
UPDATE tblSMStartingNumber SET intNumber = intNumber + 1 WHERE strTransactionType = @transactionType

--=====================================================================================================================================
-- 	EXIT ROUTINES 
---------------------------------------------------------------------------------------------------------------------------------------
Exit_Procedure:
