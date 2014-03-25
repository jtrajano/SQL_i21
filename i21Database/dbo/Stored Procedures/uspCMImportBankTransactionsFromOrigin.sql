
/*
 '====================================================================================================================================='
   SCRIPT CREATED BY: Feb Montefrio	DATE CREATED: December 27, 2013
  -------------------------------------------------------------------------------------------------------------------------------------						
   Script Name	:	Cash Management - Bank Transaction Import from apchkmst
   
   Description	:	The purpose of this script is to the bank transactions from the origin system to i21. 
					Transactions from origin are group as: 
					
					1. Origin Deposit - if apchk_chk_amt is negative amount. 
					2. Origin Checks - if apchk_chk_amt is a positive amount, apchk_trx_ind is a 'C', and apchk_chk_no is a number. 
					3. Origin EFT - if apchk_chk_amt is a positive amount and apchk_chk_no starts with a 'E'. 
					4. Origin Wire - if apchk_chk_amt is a positive amount and apchk_chk_no starts with a 'W'. 
					5. Origin Withdrawal - if apchk_chk_amt is a positive amount and it is not a check, EFT, nor a Wire transaction.
   
   Sequence of scripts to run the import: 
	   1. uspCMImportBankAccountsFromOrigin 
	   2. uspCMImportBankTransactionsFromOrigin (*This file)
	   3. uspCMImportBankReconciliationFromOrigin
*/

CREATE PROCEDURE [dbo].[uspCMImportBankTransactionsFromOrigin]
AS

-- Declare the transaction types (constant)
DECLARE @BANK_DEPOSIT AS INT = 1
		,@BANK_WITHDRAWAL AS INT = 2
		,@MISCELLANEOUS_CHECKS AS INT = 3
		,@BANK_TRANSFER AS INT = 4
		,@BANK_TRANSACTION AS INT = 5
		,@CREDIT_CARD_CHARGE AS INT = 6
		,@CREDIT_CARD_RETURNS AS INT = 7
		,@CREDIT_CARD_PAYMENTS AS INT = 8
		,@BANK_TRANSFER_WD AS INT = 9
		,@BANK_TRANSFER_DEP AS INT = 10
		,@ORIGIN_DEPOSIT AS INT = 11		-- NEGATIVE AMOUNT, INDICATOR: O, APCHK_CHK_NO PREFIX: NONE
		,@ORIGIN_CHECKS AS INT = 12			-- POSITIVE AMOUNT, INDICATOR: C, APCHK_CHK_NO PREFIX: N/A, IT MUST BE A VALId NUMBER
		,@ORIGIN_EFT AS INT = 13			-- POSITIVE AMOUNT, INDICATOR: N/A, APCHK_CHK_NO PREFIX: 'E'		
		,@ORIGIN_WITHDRAWAL AS INT = 14		-- POSITIVE AMOUNT, INDICATOR: N/A, APCHK_CHK_NO PREFIX: NONE
		,@ORIGIN_WIRE AS INT = 15			-- POSITIVE AMOUNT, INDICATOR: N/A, APCHK_CHK_NO PREFIX: 'W'
		,@AP_PAYMENT AS INT = 16

		-- Constant variables for Check number status. 
		,@CHECK_NUMBER_STATUS_UNUSED AS INT = 1
		,@CHECK_NUMBER_STATUS_USED AS INT = 2
		,@CHECK_NUMBER_STATUS_PRINTED AS INT = 3
		,@CHECK_NUMBER_STATUS_VOID AS INT = 4
		,@CHECK_NUMBER_STATUS_WASTED AS INT = 5
		,@CHECK_NUMBER_STATUS_FOR_PRINT_VERIFICATION AS INT = 6
		
		-- Declare the local variables. 
		,@intBankAccountId AS INT	

-- Insert the record from the origin system to i21. 
INSERT INTO tblCMBankTransaction (
		strTransactionId
		,intBankTransactionTypeId
		,intBankAccountId
		,intCurrencyId
		,dblExchangeRate
		,dtmDate
		,strPayee
		,intPayeeId
		,strAddress
		,strZipCode
		,strCity
		,strState
		,strCountry
		,dblAmount
		,strAmountInWords
		,strMemo
		,strReferenceNo
		,dtmCheckPrinted
		,ysnCheckToBePrinted
		,ysnCheckVoid
		,ysnPosted
		,strLink
		,ysnClr
		,dtmDateReconciled
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		,intConcurrencyId	
)
SELECT 
		strTransactionId			=	CAST(i.apchk_cbk_no AS NVARCHAR(2)) + '-'
										+ CAST(i.apchk_rev_dt AS NVARCHAR(10)) + '-'
										+ CAST(i.apchk_trx_ind AS NVARCHAR(1)) + '-'
										+ CAST(i.apchk_chk_no AS NVARCHAR(8))
		,intBankTransactionTypeId	=	
										CASE
											WHEN i.apchk_chk_amt > 0 THEN 
												CASE 
													WHEN LEFT(i.apchk_chk_no, 1) = 'E' THEN @ORIGIN_EFT
													WHEN LEFT(i.apchk_chk_no, 1) = 'W' THEN @ORIGIN_WIRE
													WHEN i.apchk_trx_ind = 'C' THEN @ORIGIN_CHECKS
													ELSE @ORIGIN_WITHDRAWAL
												END
											WHEN i.apchk_chk_amt < 0 THEN @ORIGIN_DEPOSIT
										END
		,intBankAccountId			=	f.intBankAccountId
		,intCurrencyId				=	dbo.fnCMGetCurrencyIdFromOriginToi21(i.apchk_currency_cnt)
		,dblExchangeRate			=	ISNULL(i.apchk_currency_rt, 1)
		,dtmDate					=	dbo.fnCMConvertOriginDateToSQLDateTime(i.apchk_gl_rev_dt)
		,strPayee					=	RTRIM(LTRIM(ISNULL(i.apchk_name, ''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_payee_1))) > 0 THEN ', '  ELSE '' END +
										RTRIM(LTRIM(ISNULL(i.apchk_payee_1, ''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_payee_2))) > 0 THEN ', '  ELSE '' END +
										RTRIM(LTRIM(ISNULL(i.apchk_payee_2, ''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_payee_3))) > 0 THEN ', '  ELSE '' END +
										RTRIM(LTRIM(ISNULL(i.apchk_payee_3, ''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_payee_4))) > 0 THEN ', '  ELSE '' END +
										RTRIM(LTRIM(ISNULL(i.apchk_payee_4, '')))							
		,intPayeeId					=	NULL
		,strAddress					=	RTRIM(LTRIM(ISNULL(i.apchk_addr_1, ''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_addr_2))) > 0 THEN CHAR(13) ELSE '' END +
										RTRIM(LTRIM(ISNULL(i.apchk_addr_2, '')))
		,strZipCode					=	RTRIM(LTRIM(i.apchk_zip))
		,strCity					=	RTRIM(LTRIM(i.apchk_city))
		,strState					=	RTRIM(LTRIM(i.apchk_st))
		,strCountry					=	NULL
		,dblAmount					=	ABS(i.apchk_chk_amt) -- Import as a positive AMOUNT value. 
		,strAmountInWords			=	dbo.fnCMConvertNumberToWord(ABS(i.apchk_chk_amt))
		,strMemo					=	RTRIM(LTRIM(ISNULL(i.apchk_comment_1, ''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_comment_2))) > 0 THEN CHAR(13) ELSE '' END +
										RTRIM(LTRIM(ISNULL(i.apchk_comment_2, ''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_comment_3))) > 0 THEN CHAR(13) ELSE '' END +
										RTRIM(LTRIM(ISNULL(i.apchk_comment_3, ''))) 
		,strReferenceNo				=	dbo.fnCMAddZeroPrefixes(i.apchk_chk_no)
		,dtmCheckPrinted			=	NULL
		,ysnCheckToBePrinted		=	1
		,ysnCheckVoid				=	CASE
											WHEN i.apchk_void_ind = 'Y' THEN 1
											ELSE 0
										END
		,ysnPosted					=	1
		,strLink					=	CAST(apchk_cbk_no AS NVARCHAR(2)) 
										+ CAST(apchk_rev_dt AS NVARCHAR(10)) 
										+ CAST(apchk_trx_ind AS NVARCHAR(1)) 
										+ CAST(apchk_chk_no AS NVARCHAR(8)) 
		,ysnClr						=	CASE 
											WHEN i.apchk_cleared_ind = 'C' THEN 1
											ELSE 0
										END
		,dtmDateReconciled			=	dbo.fnCMConvertOriginDateToSQLDateTime(i.apchk_clear_rev_dt)
		,intCreatedUserId			=	i.apchk_user_id
		,dtmCreated					=	dbo.fnCMConvertOriginDateToSQLDateTime(i.apchk_user_rev_dt)
		,intLastModifiedUserId		=	i.apchk_user_id
		,dtmLastModified			=	dbo.fnCMConvertOriginDateToSQLDateTime(i.apchk_rev_dt)
		,intConcurrencyId			=	1
FROM	dbo.tblCMBankAccount f INNER JOIN apchkmst i
			ON f.strCbkNo = i.apchk_cbk_no COLLATE Latin1_General_CI_AS  	
WHERE	f.intBankAccountId IS NOT NULL
		AND i.apchk_chk_amt <> 0
		AND dbo.fnCMConvertOriginDateToSQLDateTime(apchk_gl_rev_dt) IS NOT NULL
IF @@ERROR <> 0 GOTO EXIT_INSERT

-- Check number audit process: 
-- 1 of 2: Update the status of an existing record in the check number audit table. 
UPDATE	dbo.tblCMCheckNumberAudit
SET		intCheckNoStatus = CASE WHEN f.ysnCheckVoid = 1 THEN @CHECK_NUMBER_STATUS_VOID ELSE @CHECK_NUMBER_STATUS_PRINTED END
		,strRemarks			= CASE WHEN f.ysnCheckVoid = 1 THEN 'Voided from origin.' ELSE 'Generated from origin.' END
		,intTransactionId	= f.intTransactionId
		,strTransactionId	= f.strTransactionId
FROM	dbo.tblCMBankTransaction f INNER JOIN dbo.tblCMCheckNumberAudit a
			ON a.intBankAccountId = f.intBankAccountId
			AND a.strCheckNo = f.strReferenceNo
WHERE	f.intBankTransactionTypeId = @ORIGIN_CHECKS
		AND a.intCheckNoStatus = @CHECK_NUMBER_STATUS_UNUSED
IF @@ERROR <> 0 GOTO EXIT_INSERT

-- 2 of 2: Insert a check number record to the audit table if it does not exists. 
INSERT INTO dbo.tblCMCheckNumberAudit (
		intBankAccountId
		,strCheckNo
		,intCheckNoStatus
		,strRemarks
		,intTransactionId
		,strTransactionId
		,intUserId
		,dtmCreated
		,dtmCheckPrinted
)
SELECT	intBankAccountId	= f.intBankAccountId
		,strCheckNo			= dbo.fnCMAddZeroPrefixes(f.strReferenceNo)	
		,intCheckNoStatus	= CASE WHEN f.ysnCheckVoid = 1 THEN @CHECK_NUMBER_STATUS_VOID ELSE @CHECK_NUMBER_STATUS_PRINTED END
		,strRemarks			= CASE WHEN f.ysnCheckVoid = 1 THEN 'Voided from origin.' ELSE 'Generated from origin.' END
		,intTransactionId	= f.intTransactionId
		,strTransactionId	= f.strTransactionId
		,intUserId			= f.intCreatedUserId
		,dtmCreated			= GETDATE()
		,dtmCheckPrinted	= GETDATE()
FROM	dbo.tblCMBankTransaction f 
WHERE	f.intBankTransactionTypeId = @ORIGIN_CHECKS
		AND NOT EXISTS (
			SELECT	TOP 1 1 
			FROM	tblCMCheckNumberAudit
			WHERE	intBankAccountId = f.intBankAccountId
					AND strTransactionId = f.strTransactionId
					AND strCheckNo = f.strReferenceNo
		)
IF @@ERROR <> 0 GOTO EXIT_INSERT

EXIT_INSERT: 