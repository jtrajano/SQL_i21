/*
 '====================================================================================================================================='
   SCRIPT CREATED BY: Feb Montefrio	DATE CREATED: December 26, 2013
  -------------------------------------------------------------------------------------------------------------------------------------						
   Script Name	:	Cash Management - Trigger scripts for apchkmst
   
   Description	:	After apchkmst is converted into a view, this file will add the triggers for insert and update. 
					Delete trigger is not supported. 
					
					The triggers will synchronize the data from the legacy system to the new system (i21 Cash Management)   
*/

-------------------------------------------------------------------------------------------------------------------------------------
-- INSERT TRIGGER
-------------------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID ('trg_insert_apchkmst') IS NOT NULL 
	DROP TRIGGER trg_insert_apchkmst
GO

CREATE TRIGGER trg_insert_apchkmst
ON [dbo].apchkmst
INSTEAD OF INSERT
AS
BEGIN 

SET NOCOUNT ON 

	-- Insert record to the origin-base table. 
	INSERT dbo.apchkmst_legacy(
			apchk_cbk_no
			,apchk_rev_dt
			,apchk_trx_ind
			,apchk_chk_no
			,apchk_alt_cbk_no
			,apchk_alt_trx_ind
			,apchk_alt_chk_no
			,apchk_vnd_no
			,apchk_alt2_cbk_no
			,apchk_name
			,apchk_addr_1
			,apchk_addr_2
			,apchk_city
			,apchk_st
			,apchk_zip
			,apchk_chk_amt
			,apchk_disc_amt
			,apchk_wthhld_amt
			,apchk_1099_amt
			,apchk_gl_rev_dt
			,apchk_adv_chk_yn
			,apchk_man_auto_ind
			,apchk_void_ind
			,apchk_void_rev_dt
			,apchk_cleared_ind
			,apchk_clear_rev_dt
			,apchk_src_sys
			,apchk_comment_1
			,apchk_comment_2
			,apchk_comment_3
			,apchk_currency_rt
			,apchk_currency_cnt
			,apchk_payee_1
			,apchk_payee_2
			,apchk_payee_3
			,apchk_payee_4
			,apchk_user_id
			,apchk_user_rev_dt
	)
	SELECT
			apchk_cbk_no		= i.apchk_cbk_no		
			,apchk_rev_dt		= i.apchk_rev_dt		
			,apchk_trx_ind		= i.apchk_trx_ind		
			,apchk_chk_no		= i.apchk_chk_no		
			,apchk_alt_cbk_no	= i.apchk_alt_cbk_no	
			,apchk_alt_trx_ind	= i.apchk_alt_trx_ind	
			,apchk_alt_chk_no	= i.apchk_alt_chk_no	
			,apchk_vnd_no		= i.apchk_vnd_no		
			,apchk_alt2_cbk_no	= i.apchk_alt2_cbk_no	
			,apchk_name			= i.apchk_name			
			,apchk_addr_1		= i.apchk_addr_1		
			,apchk_addr_2		= i.apchk_addr_2		
			,apchk_city			= i.apchk_city			
			,apchk_st			= i.apchk_st			
			,apchk_zip			= i.apchk_zip			
			,apchk_chk_amt		= i.apchk_chk_amt		
			,apchk_disc_amt		= i.apchk_disc_amt		
			,apchk_wthhld_amt	= i.apchk_wthhld_amt	
			,apchk_1099_amt		= i.apchk_1099_amt		
			,apchk_gl_rev_dt	= i.apchk_gl_rev_dt	
			,apchk_adv_chk_yn	= i.apchk_adv_chk_yn	
			,apchk_man_auto_ind	= i.apchk_man_auto_ind	
			,apchk_void_ind		= i.apchk_void_ind		
			,apchk_void_rev_dt	= i.apchk_void_rev_dt	
			,apchk_cleared_ind	= i.apchk_cleared_ind	
			,apchk_clear_rev_dt	= i.apchk_clear_rev_dt	
			,apchk_src_sys		= i.apchk_src_sys		
			,apchk_comment_1	= i.apchk_comment_1	
			,apchk_comment_2	= i.apchk_comment_2	
			,apchk_comment_3	= i.apchk_comment_3	
			,apchk_currency_rt	= i.apchk_currency_rt	
			,apchk_currency_cnt	= i.apchk_currency_cnt	
			,apchk_payee_1		= i.apchk_payee_1		
			,apchk_payee_2		= i.apchk_payee_2		
			,apchk_payee_3		= i.apchk_payee_3		
			,apchk_payee_4		= i.apchk_payee_4		
			,apchk_user_id		= i.apchk_user_id		
			,apchk_user_rev_dt	= i.apchk_user_rev_dt	
	FROM inserted i
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER

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
			,@ORIGIN_DEPOSIT AS INT = 11
			,@ORIGIN_CHECKS AS INT = 12
			,@ORIGIN_EFT AS INT = 13
			
			-- Declare the local variables. 
			,@intBankAccountID AS INT
			
	-- Get the proper transaction prefix to use: 
	DECLARE @ORIGIN_DEPOSIT_PREFIX AS NVARCHAR(10),
			@ORIGIN_CHECKS_PREFIX AS NVARCHAR(10),
			@ORIGIN_EFT_PREFIX AS NVARCHAR(10)
	
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER
	
	-- Get the prefix from the transaction type table
	SELECT	TOP 1 
			@ORIGIN_DEPOSIT_PREFIX = strTransactionPrefix
	FROM	dbo.[tblCMBankTransactionType]
	WHERE	intBankTransactionTypeID = @ORIGIN_DEPOSIT
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER
			
	SELECT	TOP 1 
			@ORIGIN_CHECKS_PREFIX = strTransactionPrefix
	FROM	dbo.[tblCMBankTransactionType]
	WHERE	intBankTransactionTypeID = @ORIGIN_CHECKS
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER
	
	SELECT	TOP 1 
			@ORIGIN_EFT_PREFIX = strTransactionPrefix
	FROM	dbo.[tblCMBankTransactionType]
	WHERE	intBankTransactionTypeID = @ORIGIN_EFT
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER
	
	-- Get the bank account number 
	SELECT	TOP 1 
			@intBankAccountID = f.intBankAccountID 
	FROM	dbo.tblCMBankAccount f INNER JOIN inserted i
				ON f.strCbkNo = i.apchk_cbk_no COLLATE Latin1_General_CI_AS  
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER				

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
			strTransactionID			=	CASE	
												WHEN i.apchk_trx_ind = 'O' THEN 
														@ORIGIN_DEPOSIT_PREFIX + '-' + CAST(i.apchk_chk_no AS NVARCHAR(35))
												WHEN i.apchk_trx_ind = 'C' THEN 
														@ORIGIN_CHECKS_PREFIX + '-' + CAST(i.apchk_chk_no AS NVARCHAR(35))
												WHEN i.apchk_trx_ind = 'E' THEN 
														@ORIGIN_EFT_PREFIX + '-' + CAST(i.apchk_chk_no AS NVARCHAR(35))
											END
			,intBankTransactionTypeID	=	CASE	
												WHEN i.apchk_trx_ind = 'O' THEN @ORIGIN_DEPOSIT
												WHEN i.apchk_trx_ind = 'C' THEN @ORIGIN_CHECKS
												WHEN i.apchk_trx_ind = 'E' THEN @ORIGIN_EFT
											END
			,intBankAccountID			=	@intBankAccountID
			,intCurrencyID				=	NULL
			,dblExchangeRate			=	1
			,dtmDate					=	dbo.fn_ConvertOriginDateToSQLDateTime(i.apchk_rev_dt)
			,strPayee					=	i.apchk_name
			,intPayeeID					=	NULL
			,strAddress					=	RTRIM(LTRIM(i.apchk_addr_1)) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_addr_2))) > 0 THEN CHAR(13) ELSE '' END +
											RTRIM(LTRIM(i.apchk_addr_2))
			,strZipCode					=	RTRIM(LTRIM(i.apchk_zip))
			,strCity					=	RTRIM(LTRIM(i.apchk_city))
			,strState					=	RTRIM(LTRIM(i.apchk_st))
			,strCountry					=	NULL
			,dblAmount					=	ABS(i.apchk_chk_amt) -- Import as a positive AMOUNT value. 
			,strAmountInWords			=	dbo.fn_ConvertNumberToWord(i.apchk_chk_amt)
			,strMemo					=	RTRIM(LTRIM(ISNULL(i.apchk_comment_1, ''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_comment_2))) > 0 THEN CHAR(13) ELSE '' END +
											RTRIM(LTRIM(ISNULL(i.apchk_comment_2, ''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_comment_3))) > 0 THEN CHAR(13) ELSE '' END +
											RTRIM(LTRIM(ISNULL(i.apchk_comment_3, ''))) 
			,intReferenceNo				=	i.apchk_chk_no
			,ysnCheckPrinted			=	1 
			,ysnCheckToBePrinted		=	1
			,ysnCheckVoid				=	CASE
												WHEN i.apchk_void_ind = 'Y' THEN 1
												ELSE 0
											END
			,ysnPosted					=	1
			,strLink					=	i.apchk_chk_no
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
	FROM	inserted i
	WHERE	@intBankAccountID IS NOT NULL
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER	
	
EXIT_TRIGGER: 

END
GO 

-------------------------------------------------------------------------------------------------------------------------------------
-- UPDATE TRIGGER
-------------------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID ('trg_update_apchkmst') IS NOT NULL 
	DROP TRIGGER trg_update_apchkmst
GO

CREATE TRIGGER trg_update_apchkmst
ON [dbo].apchkmst
INSTEAD OF UPDATE
AS
BEGIN 

SET NOCOUNT ON

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
			,@ORIGIN_DEPOSIT AS INT = 11
			,@ORIGIN_CHECKS AS INT = 12
			,@ORIGIN_EFT AS INT = 13
			
			-- Declare the local variables. 
			,@intBankAccountID AS INT
			
	-- Update the base table first (apchkmst_legacy)
	UPDATE dbo.apchkmst_legacy
	SET		apchk_cbk_no		= i.apchk_cbk_no		
			,apchk_rev_dt		= i.apchk_rev_dt		
			,apchk_trx_ind		= i.apchk_trx_ind		
			,apchk_chk_no		= i.apchk_chk_no		
			,apchk_alt_cbk_no	= i.apchk_alt_cbk_no	
			,apchk_alt_trx_ind	= i.apchk_alt_trx_ind	
			,apchk_alt_chk_no	= i.apchk_alt_chk_no	
			,apchk_vnd_no		= i.apchk_vnd_no		
			,apchk_alt2_cbk_no	= i.apchk_alt2_cbk_no	
			,apchk_name			= i.apchk_name			
			,apchk_addr_1		= i.apchk_addr_1		
			,apchk_addr_2		= i.apchk_addr_2		
			,apchk_city			= i.apchk_city			
			,apchk_st			= i.apchk_st			
			,apchk_zip			= i.apchk_zip			
			,apchk_chk_amt		= i.apchk_chk_amt		
			,apchk_disc_amt		= i.apchk_disc_amt		
			,apchk_wthhld_amt	= i.apchk_wthhld_amt	
			,apchk_1099_amt		= i.apchk_1099_amt		
			,apchk_gl_rev_dt	= i.apchk_gl_rev_dt	
			,apchk_adv_chk_yn	= i.apchk_adv_chk_yn	
			,apchk_man_auto_ind	= i.apchk_man_auto_ind	
			,apchk_void_ind		= i.apchk_void_ind		
			,apchk_void_rev_dt	= i.apchk_void_rev_dt	
			,apchk_cleared_ind	= i.apchk_cleared_ind	
			,apchk_clear_rev_dt	= i.apchk_clear_rev_dt	
			,apchk_src_sys		= i.apchk_src_sys		
			,apchk_comment_1	= i.apchk_comment_1	
			,apchk_comment_2	= i.apchk_comment_2	
			,apchk_comment_3	= i.apchk_comment_3	
			,apchk_currency_rt	= i.apchk_currency_rt	
			,apchk_currency_cnt	= i.apchk_currency_cnt	
			,apchk_payee_1		= i.apchk_payee_1		
			,apchk_payee_2		= i.apchk_payee_2		
			,apchk_payee_3		= i.apchk_payee_3		
			,apchk_payee_4		= i.apchk_payee_4		
			,apchk_user_id		= i.apchk_user_id		
			,apchk_user_rev_dt	= i.apchk_user_rev_dt
	FROM	dbo.apchkmst_legacy f INNER JOIN inserted i
				ON f.apchk_chk_no = i.apchk_chk_no
			--INNER JOIN tblCMBankTransaction e
			--	ON e.strLink = i.apchk_chk_no COLLATE Latin1_General_CI_AS 
			--	AND e.intBankTransactionTypeID IN (@ORIGIN_DEPOSIT, @ORIGIN_CHECKS, @ORIGIN_EFT)
			--	AND e.ysnClr = 0
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER
	-- IF @@ROWCOUNT <= 0 GOTO EXIT_TRIGGER
			
	-- Get the proper transaction prefix to use: 
	DECLARE @ORIGIN_DEPOSIT_PREFIX AS NVARCHAR(10),
			@ORIGIN_CHECKS_PREFIX AS NVARCHAR(10),
			@ORIGIN_EFT_PREFIX AS NVARCHAR(10)
	
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER
	
	-- Get the prefix from the transaction type table
	SELECT	TOP 1 
			@ORIGIN_DEPOSIT_PREFIX = strTransactionPrefix
	FROM	dbo.[tblCMBankTransactionType]
	WHERE	intBankTransactionTypeID = @ORIGIN_DEPOSIT
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER
			
	SELECT	TOP 1 
			@ORIGIN_CHECKS_PREFIX = strTransactionPrefix
	FROM	dbo.[tblCMBankTransactionType]
	WHERE	intBankTransactionTypeID = @ORIGIN_CHECKS
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER
	
	SELECT	TOP 1 
			@ORIGIN_EFT_PREFIX = strTransactionPrefix
	FROM	dbo.[tblCMBankTransactionType]
	WHERE	intBankTransactionTypeID = @ORIGIN_EFT
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER
	
	-- Get the bank account number 
	SELECT	TOP 1 
			@intBankAccountID = f.intBankAccountID 
	FROM	dbo.tblCMBankAccount f INNER JOIN inserted i
				ON f.strCbkNo = i.apchk_cbk_no COLLATE Latin1_General_CI_AS  
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER
	
	-- Check if the record exists. 
	-- If it does not exists, insert it.
	IF NOT EXISTS (
		SELECT	TOP 1 1 
		FROM	dbo.tblCMBankTransaction f INNER JOIN inserted i
					ON f.strLink = i.apchk_chk_no COLLATE Latin1_General_CI_AS
					AND f.intBankTransactionTypeID IN (@ORIGIN_DEPOSIT, @ORIGIN_CHECKS, @ORIGIN_EFT)
	)
	BEGIN 
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
				strTransactionID			=	CASE	
													WHEN i.apchk_trx_ind = 'O' THEN 
															@ORIGIN_DEPOSIT_PREFIX + '-' + CAST(i.apchk_chk_no AS NVARCHAR(35))
													WHEN i.apchk_trx_ind = 'C' THEN 
															@ORIGIN_CHECKS_PREFIX + '-' + CAST(i.apchk_chk_no AS NVARCHAR(35))
													WHEN i.apchk_trx_ind = 'E' THEN 
															@ORIGIN_EFT_PREFIX + '-' + CAST(i.apchk_chk_no AS NVARCHAR(35))
												END
				,intBankTransactionTypeID	=	CASE	
													WHEN i.apchk_trx_ind = 'O' THEN @ORIGIN_DEPOSIT
													WHEN i.apchk_trx_ind = 'C' THEN @ORIGIN_CHECKS
													WHEN i.apchk_trx_ind = 'E' THEN @ORIGIN_EFT
												END
				,intBankAccountID			=	@intBankAccountID
				,intCurrencyID				=	NULL
				,dblExchangeRate			=	1
				,dtmDate					=	dbo.fn_ConvertOriginDateToSQLDateTime(i.apchk_rev_dt)
				,strPayee					=	i.apchk_name
				,intPayeeID					=	NULL
				,strAddress					=	RTRIM(LTRIM(i.apchk_addr_1)) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_addr_2))) > 0 THEN CHAR(13) ELSE '' END +
												RTRIM(LTRIM(i.apchk_addr_2))
				,strZipCode					=	RTRIM(LTRIM(i.apchk_zip))
				,strCity					=	RTRIM(LTRIM(i.apchk_city))
				,strState					=	RTRIM(LTRIM(i.apchk_st))
				,strCountry					=	NULL
				,dblAmount					=	ABS(i.apchk_chk_amt) -- Import as a positive AMOUNT value. 
				,strAmountInWords			=	dbo.fn_ConvertNumberToWord(i.apchk_chk_amt)
				,strMemo					=	RTRIM(LTRIM(ISNULL(i.apchk_comment_1, ''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_comment_2))) > 0 THEN CHAR(13) ELSE '' END +
												RTRIM(LTRIM(ISNULL(i.apchk_comment_2, ''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_comment_3))) > 0 THEN CHAR(13) ELSE '' END +
												RTRIM(LTRIM(ISNULL(i.apchk_comment_3, ''))) 
				,intReferenceNo				=	i.apchk_chk_no
				,ysnCheckPrinted			=	1 
				,ysnCheckToBePrinted		=	1
				,ysnCheckVoid				=	CASE
													WHEN i.apchk_void_ind = 'Y' THEN 1
													ELSE 0
												END
				,ysnPosted					=	1
				,strLink					=	i.apchk_chk_no
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
		FROM	inserted i
		WHERE	@intBankAccountID IS NOT NULL
		IF @@ERROR <> 0 GOTO EXIT_TRIGGER	
	END		
	
	-- Update the i21 bank transaction table. 
	-- However, do not allow the update if the bank record is already cleared. 
	UPDATE	dbo.tblCMBankTransaction 
	SET		strTransactionID			=	CASE	
												WHEN i.apchk_trx_ind = 'O' THEN 
														@ORIGIN_DEPOSIT_PREFIX + '-' + CAST(i.apchk_chk_no AS NVARCHAR(35))
												WHEN i.apchk_trx_ind = 'C' THEN 
														@ORIGIN_CHECKS_PREFIX + '-' + CAST(i.apchk_chk_no AS NVARCHAR(35))
												WHEN i.apchk_trx_ind = 'E' THEN 
														@ORIGIN_EFT_PREFIX + '-' + CAST(i.apchk_chk_no AS NVARCHAR(35))
											END
			,intBankTransactionTypeID	=	CASE	
												WHEN i.apchk_trx_ind = 'O' THEN @ORIGIN_DEPOSIT
												WHEN i.apchk_trx_ind = 'C' THEN @ORIGIN_CHECKS
												WHEN i.apchk_trx_ind = 'E' THEN @ORIGIN_EFT
											END
			,intBankAccountID			=	@intBankAccountID
			,intCurrencyID				=	NULL
			,dblExchangeRate			=	1
			,dtmDate					=	dbo.fn_ConvertOriginDateToSQLDateTime(i.apchk_rev_dt)
			,strPayee					=	i.apchk_name
			,intPayeeID					=	NULL
			,strAddress					=	RTRIM(LTRIM(i.apchk_addr_1)) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_addr_2))) > 0 THEN CHAR(13) ELSE '' END +
											RTRIM(LTRIM(i.apchk_addr_2))
			,strZipCode					=	RTRIM(LTRIM(i.apchk_zip))
			,strCity					=	RTRIM(LTRIM(i.apchk_city))
			,strState					=	RTRIM(LTRIM(i.apchk_st))
			,strCountry					=	NULL
			,dblAmount					=	ABS(i.apchk_chk_amt) -- Import as a positive AMOUNT value. 
			,strAmountInWords			=	dbo.fn_ConvertNumberToWord(i.apchk_chk_amt)
			,strMemo					=	RTRIM(LTRIM(ISNULL(i.apchk_comment_1, ''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_comment_2))) > 0 THEN CHAR(13) ELSE '' END +
											RTRIM(LTRIM(ISNULL(i.apchk_comment_2, ''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_comment_3))) > 0 THEN CHAR(13) ELSE '' END +
											RTRIM(LTRIM(ISNULL(i.apchk_comment_3, ''))) 
			,intReferenceNo				=	i.apchk_chk_no
			,ysnCheckPrinted			=	1 
			,ysnCheckToBePrinted		=	1
			,ysnCheckVoid				=	CASE
												WHEN i.apchk_void_ind = 'Y' THEN 1
												ELSE 0
											END
			,ysnPosted					=	1
			,strLink					=	i.apchk_chk_no
			,ysnClr						=	CASE 
												WHEN i.apchk_cleared_ind = 'C' THEN 1
												ELSE 0
											END
			,dtmDateReconciled			=	dbo.fn_ConvertOriginDateToSQLDateTime(i.apchk_clear_rev_dt)
			,intCreatedUserID			=	i.apchk_user_id
			,dtmCreated					=	dbo.fn_ConvertOriginDateToSQLDateTime(i.apchk_user_rev_dt)
			,intLastModifiedUserID		=	i.apchk_user_id
			,dtmLastModified			=	dbo.fn_ConvertOriginDateToSQLDateTime(i.apchk_rev_dt)
			,intConcurrencyID			=	intConcurrencyID + 1
	FROM	inserted i INNER JOIN dbo.tblCMBankTransaction f
				ON i.apchk_chk_no COLLATE Latin1_General_CI_AS = f.strLink
				AND f.intBankTransactionTypeID IN (@ORIGIN_DEPOSIT, @ORIGIN_CHECKS, @ORIGIN_EFT)
				AND f.ysnClr = 0
	WHERE	@intBankAccountID IS NOT NULL
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER
	


EXIT_TRIGGER:

END 
GO

-------------------------------------------------------------------------------------------------------------------------------------
-- DELETE TRIGGER
-------------------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID ('trg_delete_apchkmst') IS NOT NULL 
	DROP TRIGGER trg_delete_apchkmst
GO

CREATE TRIGGER trg_delete_apchkmst
ON [dbo].apchkmst
INSTEAD OF DELETE
AS
BEGIN 

SET NOCOUNT ON

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
			,@ORIGIN_DEPOSIT AS INT = 11
			,@ORIGIN_CHECKS AS INT = 12
			,@ORIGIN_EFT AS INT = 13
			
			-- Declare the local variables. 
			,@intBankAccountID AS INT
	
	-- Delete record from the origin system. 
	DELETE	dbo.apchkmst_legacy 
	FROM	dbo.apchkmst_legacy f INNER JOIN deleted d
				ON f.apchk_chk_no = d.apchk_chk_no
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER				
				
	-- Delete record from Cash Management > Bank Transaction table
	DELETE	dbo.tblCMBankTransaction
	FROM	dbo.tblCMBankTransaction f INNER JOIN deleted d
				ON f.strLink = d.apchk_chk_no COLLATE Latin1_General_CI_AS 
				AND f.intBankTransactionTypeID IN (@ORIGIN_DEPOSIT, @ORIGIN_CHECKS, @ORIGIN_EFT)
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER

EXIT_TRIGGER:

END 
GO