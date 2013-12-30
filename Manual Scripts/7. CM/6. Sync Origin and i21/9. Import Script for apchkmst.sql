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
		,@ORIGIN_DEPOSIT AS INT = 11 -- NEGATIVE AMOUNT
		,@ORIGIN_WITHDRAWAL AS INT = 14 -- POSITIVE AMOUNT
		
		-- Declare the local variables. 
		,@intBankAccountID AS INT
		
-- Get the proper transaction prefix to use: 
DECLARE @ORIGIN_DEPOSIT_PREFIX AS NVARCHAR(10),
		@ORIGIN_WITHDRAWAL_PREFIX AS NVARCHAR(10)

IF @@ERROR <> 0 GOTO EXIT_INSERT

-- Get the prefix from the transaction type table
SELECT	TOP 1 
		@ORIGIN_DEPOSIT_PREFIX = strTransactionPrefix
FROM	dbo.[tblCMBankTransactionType]
WHERE	intBankTransactionTypeID = @ORIGIN_DEPOSIT
IF @@ERROR <> 0 GOTO EXIT_INSERT
		
SELECT	TOP 1 
		@ORIGIN_WITHDRAWAL_PREFIX = strTransactionPrefix
FROM	dbo.[tblCMBankTransactionType]
WHERE	intBankTransactionTypeID = @ORIGIN_WITHDRAWAL
IF @@ERROR <> 0 GOTO EXIT_INSERT

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
		,intReferenceNo
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
		strTransactionID			=	
										CASE 
											WHEN i.apchk_chk_amt > 0 THEN
												@ORIGIN_WITHDRAWAL_PREFIX + '-' 
												+ CAST(i.apchk_cbk_no AS NVARCHAR(2)) 
												+ CAST(i.apchk_rev_dt AS NVARCHAR(10))
												+ CAST(i.apchk_trx_ind AS NVARCHAR(1))
												+ CAST(i.apchk_chk_no AS NVARCHAR(8)) 
											WHEN i.apchk_chk_amt < 0 THEN 
												@ORIGIN_DEPOSIT_PREFIX + '-' 
												+ CAST(i.apchk_cbk_no AS NVARCHAR(2)) 
												+ CAST(i.apchk_rev_dt AS NVARCHAR(10))
												+ CAST(i.apchk_trx_ind AS NVARCHAR(1))
												+ CAST(i.apchk_chk_no AS NVARCHAR(8))  
										END
		,intBankTransactionTypeID	=	
										CASE	
											WHEN i.apchk_chk_amt > 0 THEN @ORIGIN_WITHDRAWAL
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
		,intReferenceNo				=	dbo.fn_GetNumbersFromString(i.apchk_chk_no)
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