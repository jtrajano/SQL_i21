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
*/

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
DECLARE @intBankAccountID AS INT 

-- 1. Gather the bank accounts record and store it in a temporary table. 
SELECT	intBankAccountID, strBankName
INTO	#tmpBankAccounts
FROM	tblCMBankAccount

-- 2. Loop thru the bank accounts
WHILE EXISTS (SELECT TOP 1 1 FROM #tmpBankAccounts)
BEGIN 
	-- 2.1. Get a bank account to process
	SELECT TOP 1 @intBankAccountID = intBankAccountID
	FROM #tmpBankAccounts
	
	-- 2.1. Gather the reconciled transactions and store it inside a temp table. 
	-- Group it by the date reconciled. 
	SELECT	A.dtmDateReconciled
			,dblClearedPaymentsOrDebits = SUM(
				CASE 
					WHEN A.intBankTransactionTypeID IN (@ORIGIN_CHECKS, @ORIGIN_EFT, @ORIGIN_WITHDRAWAL, @ORIGIN_WIRE) THEN
						ISNULL(A.dblAmount, 0)
					ELSE
						0
				END
			)		
			,dblDepositsOrCredits = SUM(
				CASE 
					WHEN	A.intBankTransactionTypeID IN (@ORIGIN_DEPOSIT) THEN
						ISNULL(A.dblAmount, 0)
					ELSE
						0
				END
			)
			,dblBankAccountBalance = (
				SELECT SUM(
							CASE	WHEN B.intBankTransactionTypeID IN (@ORIGIN_CHECKS, @ORIGIN_EFT, @ORIGIN_WITHDRAWAL, @ORIGIN_WIRE) THEN
										ISNULL(B.dblAmount, 0) * -1
									WHEN B.intBankTransactionTypeID IN (@ORIGIN_DEPOSIT) THEN
										ISNULL(B.dblAmount, 0)
									ELSE 
										0
							END
						)
				FROM	tblCMBankTransaction B
				WHERE	B.intBankAccountID = @intBankAccountID
						AND B.dtmDate <= A.dtmDateReconciled
						AND B.ysnPosted = 1
			)
	INTO	#tmpClearedTransactions 
	FROM	tblCMBankTransaction  A
	WHERE	A.dtmDateReconciled IS NOT NULL 
			AND A.intBankAccountID = @intBankAccountID
			AND A.ysnClr = 1
			AND A.ysnPosted = 1
			AND ISNULL(A.dblAmount, 0) <> 0
	GROUP BY A.dtmDateReconciled
	ORDER BY A.dtmDateReconciled
	
	INSERT INTO tblCMBankReconciliation (
			intBankAccountID
			,dtmDateReconciled
			,dblStatementOpeningBalance
			,dblDebitCleared
			,dblCreditCleared
			,dblBankAccountBalance
			,dblStatementEndingBalance
			,intCreatedUserID
			,dtmCreated
			,intLastModifiedUserID
			,dtmLastModified
			,intConcurrencyID
	)
	SELECT	
			intBankAccountID			= @intBankAccountID
			,dtmDateReconciled			= tmp.dtmDateReconciled
			,dblStatementOpeningBalance = 0
			,dblDebitCleared			= tmp.dblClearedPaymentsOrDebits
			,dblCreditCleared			= tmp.dblDepositsOrCredits
			,dblBankAccountBalance		= tmp.dblBankAccountBalance
			,dblStatementEndingBalance	= 0
			,intCreatedUserID			= 0
			,dtmCreated					= GETDATE()
			,intLastModifiedUserID		= 0
			,dtmLastModified			= GETDATE()
			,intConcurrencyID			= 1
	FROM	#tmpClearedTransactions tmp	
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblCMBankReconciliation WHERE intBankAccountID = @intBankAccountID AND dtmDateReconciled = tmp.dtmDateReconciled)

	-- 2.last. Delete the bank account from the tmp table after processing it. 
	DELETE FROM #tmpBankAccounts
	WHERE intBankAccountID = @intBankAccountID
	
	-- 2.last. Drop the temp table. 
	IF EXISTS (SELECT 1 FROM TEMPDB..SYSOBJECTS WHERE ID = OBJECT_ID('TEMPDB..#tmpClearedTransactions')) DROP TABLE #tmpClearedTransactions
END

-- 3. Drop the temp table. 
IF EXISTS (SELECT 1 FROM TEMPDB..SYSOBJECTS WHERE ID = OBJECT_ID('TEMPDB..#tmpBankAccounts')) DROP TABLE #tmpBankAccounts
GO 
