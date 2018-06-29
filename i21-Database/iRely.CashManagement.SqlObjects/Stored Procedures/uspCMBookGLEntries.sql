﻿
CREATE PROCEDURE uspCMBookGLEntries
	@ysnPost		BIT	= 0
	,@ysnRecap		BIT	= 0
	,@isSuccessful	BIT = 0 OUTPUT
	,@message_id	INT = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
--SET ANSI_WARNINGS OFF

--=====================================================================================================================================
-- 	DECLARATION 
--------------------------------------------------------------------------------------------------------------------------------------

DECLARE @dblDebitCreditBalance NUMERIC(18,2)

--------------------------------------------------------------------------------------------------------------------------------------
--  END OF VALIDATION
--=====================================================================================================================================

--=====================================================================================================================================
-- 	START OF THE VALIDATION
--------------------------------------------------------------------------------------------------------------------------------------

-- Check if the required temporary table is not missing. If missing, throw an error. 
IF NOT EXISTS (	SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID(N'[tempdb]..[#tmpGLDetail]'))
BEGIN 
	-- 'Invalid G/L temp table.'
	RAISERROR ('Invalid G/L temporary table.',11,1)
	GOTO Exit_BookGLEntries_WithErrors
END

-- When doing a post or unpost, check for any invalid G/L Account ids. 
-- When doing a recap, ignore any invalid G/L account id's. 
IF EXISTS (SELECT TOP 1 1 FROM #tmpGLDetail WHERE intAccountId IS NULL AND @ysnRecap = 0)
BEGIN 
	-- 'Failed. Invalid G/L account id found.'
	RAISERROR ('Invalid G/L account id found.',11,1)
	GOTO Exit_BookGLEntries_WithErrors
END		

-- Check if the debit and credit amounts are balanced. 
SELECT	@dblDebitCreditBalance = SUM(dblDebit) - SUM(dblCredit) 
FROM	#tmpGLDetail

IF ISNULL(@dblDebitCreditBalance, 0) <> 0 AND @ysnRecap = 0 
BEGIN
	-- If not balanced, throw an error. 
	RAISERROR ('Debit and credit amounts are not balanced.',11,1)
	GOTO Exit_BookGLEntries_WithErrors	
END 

-- Check if the debit and credit amounts are balanced. 
-- This time join the temporary table with the GL Account table. 
-- It ensures the amounts are using valid account id's (existing and active account id's)
SELECT	@dblDebitCreditBalance = SUM(dblDebit) - SUM(dblCredit) 
FROM	#tmpGLDetail INNER JOIN tblGLAccount
			ON #tmpGLDetail.intAccountId = tblGLAccount.intAccountId
WHERE	ISNULL(tblGLAccount.ysnActive, 0) = 1

IF ISNULL(@dblDebitCreditBalance, 0) <> 0
BEGIN
	-- Debit and credit amounts are not balanced.
	RAISERROR ('Debit and credit amounts are not balanced.',11,1)
	GOTO Exit_BookGLEntries_WithErrors	
END 

-- TODO: Check if the currency is invalid. 
-- TODO: Check for invalid unit of measure (for unit accounting)

-- Validate the date against the FY Periods
IF EXISTS (SELECT 1 FROM #tmpGLDetail WHERE [dbo].isOpenAccountingDate(#tmpGLDetail.dtmDate) = 0) AND @ysnRecap = 0
BEGIN 
	-- Unable to find an open fiscal year period to match the transaction date.
	RAISERROR('Unable to find an open fiscal year period to match the transaction date.', 11, 1)
	GOTO Exit_BookGLEntries_WithErrors
END

--------------------------------------------------------------------------------------------------------------------------------------
--  END OF VALIDATION
--=====================================================================================================================================

--=====================================================================================================================================
-- 	START OF THE INITIALIZATION																										 
--------------------------------------------------------------------------------------------------------------------------------------

-- Process the switching of the debit and credit sides.
-- 1. Negative Credit goes as Positive Debit. 
-- 2. Negative Debit goes as positive Credit. 
-- 3. When debit is negative, change it to zero. When credit is negative, change it to zero. 
UPDATE #tmpGLDetail
SET	dblDebit	= CASE	WHEN dblCredit < 0 THEN ABS(dblCredit)
						WHEN dblDebit < 0 THEN 0
						ELSE dblDebit 
				END 
	,dblCredit	= CASE	WHEN dblDebit < 0 THEN ABS(dblDebit)
						WHEN dblCredit < 0 THEN 0
						ELSE dblCredit
				END			

--------------------------------------------------------------------------------------------------------------------------------------
--  END OF INITIALIZATION
--=====================================================================================================================================

--=====================================================================================================================================
-- 	BOOK THE G/L ENTRIES TO THE tblGLDetail table.
--------------------------------------------------------------------------------------------------------------------------------------

-- TODO: Account Allocation

-- Add the G/L entries from the temporary table to the permanent table (tblGLDetail)
INSERT INTO tblGLDetail (
		[dtmDate]
		,[strBatchId]
		,[intAccountId]
		,[dblDebit]
		,[dblCredit]
		,[dblDebitUnit]
		,[dblCreditUnit]
		,[strDescription]
		,[strCode]
		,[strReference]
		,[intCurrencyId]
		,[dblExchangeRate]
		,[dtmDateEntered]
		,[dtmTransactionDate]
		,[strJournalLineDescription]
		,[intJournalLineNo]
		,[ysnIsUnposted]
		,[intUserId]
		,[intEntityId]
		,[strTransactionId]
		,[intTransactionId]
		,[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]
		,[intConcurrencyId]
)
SELECT 
		[dtmDate]
		,[strBatchId]
		,[intAccountId]
		,[dblDebit]
		,[dblCredit]
		,[dblDebitUnit]
		,[dblCreditUnit]
		,[strDescription]
		,[strCode]
		,[strReference]
		,[intCurrencyId]
		,[dblExchangeRate]
		,[dtmDateEntered]
		,[dtmTransactionDate]
		,[strJournalLineDescription]
		,[intJournalLineNo]
		,[ysnIsUnposted]
		,[intUserId]
		,[intEntityId]
		,[strTransactionId]
		,[intTransactionId]
		,[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]
		,[intConcurrencyId]
FROM	#tmpGLDetail
WHERE	@ysnRecap = 0

--=====================================================================================================================================
-- 	UPDATE THE SUMMARY TABLE. 
---------------------------------------------------------------------------------------------------------------------------------------

UPDATE	tblGLSummary 
SET		dblDebit = ISNULL(tblGLSummary.dblDebit, 0) + ISNULL(tmpGLDetailGrouped.dblDebit, 0)
		,dblCredit = ISNULL(tblGLSummary.dblCredit, 0) + ISNULL(tmpGLDetailGrouped.dblCredit, 0)
		,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
FROM	(
			SELECT	dblDebit	= CASE WHEN @ysnPost = 1 THEN SUM(ISNULL(B.dblDebit, 0)) ELSE SUM(ISNULL(B.dblCredit, 0)) * -1 END 
					,dblCredit	= CASE WHEN @ysnPost = 1 THEN SUM(ISNULL(B.dblCredit, 0))  ELSE SUM(ISNULL(B.dblDebit, 0)) * -1 END 
					,A.intAccountId
					,dtmDate	= ISNULL(CONVERT(VARCHAR(10), B.dtmDate, 112), '')
					,B.strCode						
			FROM	tblGLSummary A INNER JOIN #tmpGLDetail B
						ON CONVERT(VARCHAR(10), A.dtmDate, 112) = CONVERT(VARCHAR(10), B.dtmDate, 112)
						AND A.intAccountId = B.intAccountId
						AND A.strCode = B.strCode 
			WHERE	@ysnRecap = 0 
			GROUP BY	ISNULL(CONVERT(VARCHAR(10), B.dtmDate, 112), ''), 
						A.intAccountId,
						B.strCode
		) AS tmpGLDetailGrouped
WHERE	tblGLSummary.intAccountId = tmpGLDetailGrouped.intAccountId
		AND ISNULL(CONVERT(VARCHAR(10), tblGLSummary.dtmDate, 112), '') = ISNULL(CONVERT(VARCHAR(10), tmpGLDetailGrouped.dtmDate, 112), '')
		AND @ysnRecap = 0
		AND tblGLSummary.strCode = tmpGLDetailGrouped.strCode 

-- INSERT RECORDS TO THE SUMMARY TABLE
INSERT INTO tblGLSummary (
		intAccountId
		,dtmDate
		,dblDebit
		,dblCredit
		,dblDebitUnit
		,dblCreditUnit
		,strCode
		,intConcurrencyId
)
SELECT	#tmpGLDetail.intAccountId
		,ISNULL(CONVERT(VARCHAR(10), #tmpGLDetail.dtmDate, 112), '')
		,SUM(#tmpGLDetail.dblDebit)
		,SUM(#tmpGLDetail.dblCredit)
		,SUM(#tmpGLDetail.dblDebitUnit)
		,SUM(#tmpGLDetail.dblCreditUnit)
		,#tmpGLDetail.strCode
		,1
FROM	#tmpGLDetail
WHERE	NOT EXISTS (
			SELECT	TOP 1 1
			FROM	tblGLSummary
			WHERE	ISNULL(CONVERT(VARCHAR(10), #tmpGLDetail.dtmDate, 112), '') = ISNULL(CONVERT(VARCHAR(10), tblGLSummary.dtmDate, 112), '') 
					AND #tmpGLDetail.intAccountId = tblGLSummary.intAccountId
					AND #tmpGLDetail.strCode = tblGLSummary.strCode
		)
		AND @ysnRecap = 0
GROUP BY	ISNULL(CONVERT(VARCHAR(10), #tmpGLDetail.dtmDate, 112), ''), 
			#tmpGLDetail.intAccountId,
			#tmpGLDetail.strCode


--=====================================================================================================================================
-- 	EXIT ROUTINES 
---------------------------------------------------------------------------------------------------------------------------------------

Exit_Successfully:
	SET @isSuccessful = 1
	GOTO Exit_BookGLEntries

Exit_BookGLEntries_WithErrors:
	SET @isSuccessful = 0		
	GOTO Exit_BookGLEntries	
	
Exit_BookGLEntries:

-- Clean up. Remove any disposable temporary tables here.
-- None