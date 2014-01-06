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
*/

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
		,@ORIGIN_CHECKS AS INT = 12			-- POSITIVE AMOUNT, INDICATOR: C, APCHK_CHK_NO PREFIX: N/A, IT MUST BE A VALID NUMBER
		,@ORIGIN_EFT AS INT = 13			-- POSITIVE AMOUNT, INDICATOR: N/A, APCHK_CHK_NO PREFIX: 'E'		
		,@ORIGIN_WITHDRAWAL AS INT = 14		-- POSITIVE AMOUNT, INDICATOR: N/A, APCHK_CHK_NO PREFIX: NONE
		,@ORIGIN_WIRE AS INT = 15			-- POSITIVE AMOUNT, INDICATOR: N/A, APCHK_CHK_NO PREFIX: 'W'
		
		-- Declare the local variables. 
		,@intBankAccountID AS INT	

-- Insert the record from the origin system to i21. 
INSERT INTO tblCMBankTransaction (
		strTransactionID
		,intBankTransactionTypeID
		,intBankAccountID
		,intCurrencyID
		,dblExchangeRate
		,dtmDate
		,strPayee
		,intPayeeID
		,strAddress
		,strZipCode
		,strCity
		,strState
		,strCountry
		,dblAmount
		,strAmountInWords
		,strMemo
		,strReferenceNo
		,ysnCheckPrinted
		,ysnCheckToBePrinted
		,ysnCheckVoid
		,ysnPosted
		,strLink
		,ysnClr
		,dtmDateReconciled
		,intCreatedUserID
		,dtmCreated
		,intLastModifiedUserID
		,dtmLastModified
		,intConcurrencyID	
)
SELECT 
		strTransactionID			=	CAST(i.apchk_cbk_no AS NVARCHAR(2)) + '-'
										+ CAST(i.apchk_rev_dt AS NVARCHAR(10)) + '-'
										+ CAST(i.apchk_trx_ind AS NVARCHAR(1)) + '-'
										+ CAST(i.apchk_chk_no AS NVARCHAR(8))
		,intBankTransactionTypeID	=	
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
		,intBankAccountID			=	f.intBankAccountID
		,intCurrencyID				=	dbo.fn_GetCurrencyIDFromOriginToi21(i.apchk_currency_cnt)
		,dblExchangeRate			=	ISNULL(i.apchk_currency_rt, 1)
		,dtmDate					=	dbo.fn_ConvertOriginDateToSQLDateTime(i.apchk_gl_rev_dt)
		,strPayee					=	RTRIM(LTRIM(ISNULL(i.apchk_name, ''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_payee_1))) > 0 THEN ', '  ELSE '' END +
										RTRIM(LTRIM(ISNULL(i.apchk_payee_1, ''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_payee_2))) > 0 THEN ', '  ELSE '' END +
										RTRIM(LTRIM(ISNULL(i.apchk_payee_2, ''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_payee_3))) > 0 THEN ', '  ELSE '' END +
										RTRIM(LTRIM(ISNULL(i.apchk_payee_3, ''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_payee_4))) > 0 THEN ', '  ELSE '' END +
										RTRIM(LTRIM(ISNULL(i.apchk_payee_4, '')))							
		,intPayeeID					=	NULL
		,strAddress					=	RTRIM(LTRIM(ISNULL(i.apchk_addr_1, ''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_addr_2))) > 0 THEN CHAR(13) ELSE '' END +
										RTRIM(LTRIM(ISNULL(i.apchk_addr_2, '')))
		,strZipCode					=	RTRIM(LTRIM(i.apchk_zip))
		,strCity					=	RTRIM(LTRIM(i.apchk_city))
		,strState					=	RTRIM(LTRIM(i.apchk_st))
		,strCountry					=	NULL
		,dblAmount					=	ABS(i.apchk_chk_amt) -- Import as a positive AMOUNT value. 
		,strAmountInWords			=	dbo.fn_ConvertNumberToWord(ABS(i.apchk_chk_amt))
		,strMemo					=	RTRIM(LTRIM(ISNULL(i.apchk_comment_1, ''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_comment_2))) > 0 THEN CHAR(13) ELSE '' END +
										RTRIM(LTRIM(ISNULL(i.apchk_comment_2, ''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_comment_3))) > 0 THEN CHAR(13) ELSE '' END +
										RTRIM(LTRIM(ISNULL(i.apchk_comment_3, ''))) 
		,strReferenceNo				=	RTRIM(LTRIM(i.apchk_chk_no))
		,ysnCheckPrinted			=	1 
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
		,dtmDateReconciled			=	dbo.fn_ConvertOriginDateToSQLDateTime(i.apchk_clear_rev_dt)
		,intCreatedUserID			=	i.apchk_user_id
		,dtmCreated					=	dbo.fn_ConvertOriginDateToSQLDateTime(i.apchk_user_rev_dt)
		,intLastModifiedUserID		=	i.apchk_user_id
		,dtmLastModified			=	dbo.fn_ConvertOriginDateToSQLDateTime(i.apchk_rev_dt)
		,intConcurrencyID			=	1
FROM	dbo.tblCMBankAccount f INNER JOIN apchkmst i
			ON f.strCbkNo = i.apchk_cbk_no COLLATE Latin1_General_CI_AS  	
WHERE	f.intBankAccountID IS NOT NULL
		AND i.apchk_chk_amt <> 0
		AND dbo.fn_ConvertOriginDateToSQLDateTime(apchk_gl_rev_dt) IS NOT NULL
IF @@ERROR <> 0 GOTO EXIT_INSERT

EXIT_INSERT: 