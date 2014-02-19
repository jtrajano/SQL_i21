/*
 '====================================================================================================================================='
   SCRIPT CREATED BY: Feb Montefrio	DATE CREATED: January 2, 2014
  -------------------------------------------------------------------------------------------------------------------------------------						
   Script Name	:	Cash Management - Import Bank Reconciliation 
   
   Description	:	This script will try to recreate the bank reconciliation done in the legacy. 
					The following are imported:
					1. Date of the reconciliation
					2. The total of the payments (or debits) reconciled
					3. The total of the deposits (or credits) reconciled. 
					
					However, this script is not capable of knowing the real statement balance per reconciliation. 
					1. dblStatementOpeningBalance - Legacy/origin system does not have a record of the statement opening balance. 
					2. dblStatementEndingBalance - Legacy/Origin does not have a record of the statement ending balance. 
					
					After importing the bank reconciliation records, the user can re-enter the statement balance inside the bank reconciliation screen and save
					the bank statement balance.					
				
					*Prerequisite: Run this script after a successful run of the "Import Bank Transactions from apchkmst" script.  
					
					Modification 01/07/2014:
					1. Import logic is changed. All reconciled records will be imported in one reconciliation history record per bank account. 
					2. The user will be doing the reconciliation from this single record. 

	Sequence of scripts to run the import: 
	   1. uspCMImportBankAccountsFromOrigin 
	   2. uspCMImportBankTransactionsFromOrigin 
	   3. uspCMImportBankReconciliationFromOrigin (*This file)
*/

CREATE PROCEDURE [dbo].[uspCMImportBankReconciliationFromOrigin]
AS

-- Declare and initialize the constant variables
DECLARE @BANK_DEPOSIT INT = 1
		,@BANK_WITHDRAWAL INT = 2
		,@MISC_CHECKS INT = 3
		,@BANK_TRANSFER INT = 4
		,@BANK_TRANSACTION INT = 5
		,@CREDIT_CARD_CHARGE INT = 6
		,@CREDIT_CARD_RETURNS INT = 7
		,@CREDIT_CARD_PAYMENTS INT = 8
		,@BANK_TRANSFER_WD INT = 9
		,@BANK_TRANSFER_DEP INT = 10
		,@ORIGIN_DEPOSIT AS INT = 11
		,@ORIGIN_CHECKS AS INT = 12
		,@ORIGIN_EFT AS INT = 13
		,@ORIGIN_WITHDRAWAL AS INT = 14
		,@ORIGIN_WIRE AS INT = 15

-- Declare and initialize the local variables.
DECLARE @intBankAccountId AS INT
		,@dtmMostRecentReconciliation DATETIME


-- 1. Gather the bank accounts record and store it in a temporary table. 
SELECT	intBankAccountId, intBankId
INTO	#tmpBankAccounts
FROM	tblCMBankAccount

-- 2. Loop thru the bank accounts
WHILE EXISTS (SELECT TOP 1 1 FROM #tmpBankAccounts)
BEGIN 
	-- 2.1. Get a bank account to process
	SELECT TOP 1 @intBankAccountId = intBankAccountId
	FROM #tmpBankAccounts
	
	-- 2.2. Get the most recent bank reconciliation for the bank account. 
	SELECT	@dtmMostRecentReconciliation = MAX(A.dtmDateReconciled)
	FROM	tblCMBankTransaction A
	WHERE	A.dtmDateReconciled IS NOT NULL 
			AND A.intBankAccountId = @intBankAccountId
			AND A.ysnClr = 1
			AND A.ysnPosted = 1
			AND ISNULL(A.dblAmount, 0) <> 0	
	
	-- 2.3. Gather the reconciled transactions and store it inside a temp table. 
	-- Group it by the date reconciled. 
	SELECT	dblClearedPaymentsOrDebits = SUM(
				CASE 
					WHEN A.intBankTransactionTypeId IN (@ORIGIN_CHECKS, @ORIGIN_EFT, @ORIGIN_WITHDRAWAL, @ORIGIN_WIRE) THEN
						ISNULL(A.dblAmount, 0)
					ELSE
						0
				END
			)		
			,dblDepositsOrCredits = SUM(
				CASE 
					WHEN	A.intBankTransactionTypeId IN (@ORIGIN_DEPOSIT) THEN
						ISNULL(A.dblAmount, 0)
					ELSE
						0
				END
			)
			,dblBankAccountBalance = (
				SELECT SUM(
							CASE	WHEN B.intBankTransactionTypeId IN (@ORIGIN_CHECKS, @ORIGIN_EFT, @ORIGIN_WITHDRAWAL, @ORIGIN_WIRE) THEN
										ISNULL(B.dblAmount, 0) * -1
									WHEN B.intBankTransactionTypeId IN (@ORIGIN_DEPOSIT) THEN
										ISNULL(B.dblAmount, 0)
									ELSE 
										0
							END
						)
				FROM	tblCMBankTransaction B
				WHERE	B.intBankAccountId = @intBankAccountId
						AND B.dtmDate <= @dtmMostRecentReconciliation
						AND B.ysnPosted = 1
			)
	INTO	#tmpClearedTransactions 
	FROM	tblCMBankTransaction  A
	WHERE	A.dtmDateReconciled IS NOT NULL
			AND @dtmMostRecentReconciliation IS NOT NULL
			AND A.intBankAccountId = @intBankAccountId
			AND A.ysnClr = 1
			AND A.ysnPosted = 1 
			AND ISNULL(A.dblAmount, 0) <> 0
	
	-- 2.4. Insert the bank reconciliation record. 
	INSERT INTO tblCMBankReconciliation (
			intBankAccountId
			,dtmDateReconciled
			,dblStatementOpeningBalance
			,dblDebitCleared
			,dblCreditCleared
			,dblBankAccountBalance
			,dblStatementEndingBalance
			,intCreatedUserId
			,dtmCreated
			,intLastModifiedUserId
			,dtmLastModified
			,intConcurrencyId
			,ysnImported
	)
	SELECT	
			intBankAccountId			= @intBankAccountId
			,dtmDateReconciled			= @dtmMostRecentReconciliation
			,dblStatementOpeningBalance = 0
			,dblDebitCleared			= tmp.dblClearedPaymentsOrDebits
			,dblCreditCleared			= tmp.dblDepositsOrCredits
			,dblBankAccountBalance		= tmp.dblBankAccountBalance
			,dblStatementEndingBalance	= 0
			,intCreatedUserId			= 0
			,dtmCreated					= GETDATE()
			,intLastModifiedUserId		= 0
			,dtmLastModified			= GETDATE()
			,intConcurrencyId			= 1
			,ysnImported				= 1
	FROM	#tmpClearedTransactions tmp	
	WHERE	NOT EXISTS (SELECT TOP 1 1 FROM tblCMBankReconciliation WHERE intBankAccountId = @intBankAccountId AND dtmDateReconciled = @dtmMostRecentReconciliation)
			AND @dtmMostRecentReconciliation IS NOT NULL
			
	-- 2.6. Update the bank transaction and set the imported record to the new reconciliation date. 
	UPDATE tblCMBankTransaction
	SET		dtmDateReconciled = @dtmMostRecentReconciliation
	WHERE	dtmDateReconciled IS NOT NULL
			AND @dtmMostRecentReconciliation IS NOT NULL
			AND intBankAccountId = @intBankAccountId
			AND ysnClr = 1
			AND ysnPosted = 1 
			AND ISNULL(dblAmount, 0) <> 0
			AND intBankTransactionTypeId IN (@ORIGIN_DEPOSIT, @ORIGIN_CHECKS,@ORIGIN_EFT, @ORIGIN_WITHDRAWAL, @ORIGIN_WIRE)

	-- 2.6. Delete the bank account from the tmp table after processing it. 
	DELETE FROM #tmpBankAccounts
	WHERE intBankAccountId = @intBankAccountId
	
	-- 2.7. Drop the temp table. 
	IF EXISTS (SELECT 1 FROM TEMPDB..SYSOBJECTS WHERE Id = OBJECT_Id('TEMPDB..#tmpClearedTransactions')) DROP TABLE #tmpClearedTransactions
END

-- 3. Drop the temp table. 
IF EXISTS (SELECT 1 FROM TEMPDB..SYSOBJECTS WHERE Id = OBJECT_Id('TEMPDB..#tmpBankAccounts')) DROP TABLE #tmpBankAccounts
GO 
