CREATE PROCEDURE uspCMCreateBankTransactionEntries
	@BankTransactionEntries BankTransactionTable READONLY,
	@BankTransactionDetailEntries BankTransactionDetailTable READONLY,
	@intTransactionId INT = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--=====================================================================================================================================
-- 	VALIDATION
------------------------------------------------------------------------------------------------------------------------------------
--BEGIN 
--	EXEC dbo.uspCMValidateBankTransactionEntries @BankTransactionEntries;
--	IF @@ERROR <> 0	GOTO Exit_Procedure;
--END 
--;
--=====================================================================================================================================
-- 	CREATE THE BANK TRANSACTION ENTRIES TO THE tblCMBankTransaction table.
--------------------------------------------------------------------------------------------------------------------------------------
BEGIN 
	-- Add the Bank Transaction entries from the temporary table to the permanent table (tblCMBankTransaction)
	INSERT INTO tblCMBankTransaction(
		[strTransactionId],
		[intBankTransactionTypeId],
		[intBankAccountId],
		[intCurrencyId],
		[dblExchangeRate],
		[dtmDate],
		[strPayee],
		[intPayeeId],
		[strAddress],
		[strZipCode],
		[strCity],
		[strState],
		[strCountry],
		[dblAmount],
		[strAmountInWords],
		[strMemo],
		[strReferenceNo],
		[ysnCheckToBePrinted],
		[ysnCheckVoid],
		[ysnPosted],
		[strLink],
		[ysnClr],
		[ysnPOS],
		[dtmDateReconciled],
		[intEntityId],
		[intCreatedUserId],
		[intCompanyLocationId],
		[dtmCreated],
		[intLastModifiedUserId],
		[dtmLastModified],
		[intAPPaymentId],
		[intConcurrencyId]
	)
	SELECT 
		[strTransactionId],
		[intBankTransactionTypeId],
		[intBankAccountId],
		[intCurrencyId],
		[dblExchangeRate],
		[dtmDate],
		[strPayee],
		[intPayeeId],
		[strAddress],
		[strZipCode],
		[strCity],
		[strState],
		[strCountry],
		[dblAmount],
		dbo.fnConvertNumberToWord([dblAmount]),
		[strMemo],
		[strReferenceNo],
		[ysnCheckToBePrinted],
		[ysnCheckVoid],
		[ysnPosted],
		[strLink],
		[ysnClr],
		[ysnPOS],
		[dtmDateReconciled],
		[intEntityId],
		[intCreatedUserId],
		[intCompanyLocationId],
		[dtmCreated],
		[intLastModifiedUserId],
		[dtmLastModified],
		[intAPPaymentId],
		[intConcurrencyId]
	FROM @BankTransactionEntries BankTransactionEntries

	SET @intTransactionId = SCOPE_IDENTITY()
END
;

--=====================================================================================================================================
-- 	CREATE THE BANK TRANSACTION DETAIL ENTRIES TO THE tblCMBankTransactionDetail table.
--------------------------------------------------------------------------------------------------------------------------------------
IF EXISTS(SELECT TOP 1 1 FROM @BankTransactionDetailEntries)
BEGIN 

	--======================================================
	--VALIDATION FOR DETAIL
	--======================================================
	--validation sp goes here

	-- Add the Bank Transaction Detail entries from the temporary table to the permanent table (tblCMBankTransactionDetail)
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
		@intTransactionId
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
		,[intConcurrencyId]
	FROM @BankTransactionDetailEntries BankTransactionDetailEntries
END
;

-- Zero ACH transaction will skip ACH Generation and Proceed with Remittance Printing

	DECLARE @dblAmount NUMERIC(18,6)
	DECLARE @intBankTransactionTypeId INT
	DECLARE @intBankAccountId INT
	DECLARE @intEntityId INT
	DECLARE @strTransactionId NVARCHAR(100)
	SELECT 
		@strTransactionId = cast(@intTransactionId as nvarchar(20)), 
		@dblAmount = dblAmount, 
		@intBankTransactionTypeId = intBankTransactionTypeId,
		@intBankAccountId = intBankAccountId,
		@intEntityId = intEntityId
	FROM  @BankTransactionEntries
	IF( @dblAmount = 0 AND @intBankTransactionTypeId = 22) --ACH PAYMENT 
	BEGIN
		EXEC [dbo].[uspCMBankFileGenerationLog]
		@intBankAccountId = @intBankAccountId,
		@strTransactionIds = @strTransactionId,
		@strFileName = '',
		@strProcessType  = 'ACH OR NACHA',
		@intBankFileFormatId = 0,
		@intEntityId = @intEntityId
	END
--=====================================================================================================================================
-- 	EXIT ROUTINES 
---------------------------------------------------------------------------------------------------------------------------------------
Exit_Procedure:
