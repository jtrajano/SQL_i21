	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'apchkmst')
		DROP VIEW apchkmst

	IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1
	BEGIN
		EXEC ('
			CREATE VIEW [dbo].apchkmst
			AS 
				SELECT * FROM apchkmst_origin
			')

		EXEC('
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
							,@ORIGIN_DEPOSIT AS INT = 11		-- NEGATIVE AMOUNT, INDICATOR: O, APCHK_CHK_NO PREFIX: NONE
							,@ORIGIN_CHECKS AS INT = 12			-- POSITIVE AMOUNT, INDICATOR: C, APCHK_CHK_NO PREFIX: N/A, IT MUST BE A VALId NUMBER
							,@ORIGIN_EFT AS INT = 13			-- POSITIVE AMOUNT, INDICATOR: N/A, APCHK_CHK_NO PREFIX: ''E''		
							,@ORIGIN_WITHDRAWAL AS INT = 14		-- POSITIVE AMOUNT, INDICATOR: N/A, APCHK_CHK_NO PREFIX: NONE
							,@ORIGIN_WIRE AS INT = 15			-- POSITIVE AMOUNT, INDICATOR: N/A, APCHK_CHK_NO PREFIX: ''W''
			
							-- Declare the local variables. 
							,@intBankAccountId AS INT
	
					-- Delete record from the apchkmst base table (apchkmst_origin) in the origin system. 
					DELETE	dbo.apchkmst_origin 
					FROM	dbo.apchkmst_origin f INNER JOIN deleted d
								ON f.apchk_chk_no = d.apchk_chk_no
					IF @@ERROR <> 0 GOTO EXIT_TRIGGER				
				
					-- Delete record from Cash Management > Bank Transaction table
					DELETE	dbo.tblCMBankTransaction
					FROM	dbo.tblCMBankTransaction f INNER JOIN deleted d
									ON f.strLink = ( CAST(d.apchk_cbk_no AS NVARCHAR(2)) 
													+ CAST(d.apchk_rev_dt AS NVARCHAR(10)) 
													+ CAST(d.apchk_trx_ind AS NVARCHAR(1)) 
													+ CAST(d.apchk_chk_no AS NVARCHAR(8))
									) COLLATE Latin1_General_CI_AS 
									AND f.intBankTransactionTypeId IN (@ORIGIN_DEPOSIT, @ORIGIN_CHECKS, @ORIGIN_EFT, @ORIGIN_WITHDRAWAL, @ORIGIN_WIRE)
							INNER JOIN dbo.tblCMBankAccount e
								ON e.strCbkNo = d.apchk_cbk_no COLLATE Latin1_General_CI_AS
								AND e.intBankAccountId = f.intBankAccountId						
					IF @@ERROR <> 0 GOTO EXIT_TRIGGER

				EXIT_TRIGGER:

				END
			')

		EXEC ('
			CREATE TRIGGER trg_insert_apchkmst
			ON [dbo].apchkmst
			INSTEAD OF INSERT
			AS
			BEGIN 

			SET NOCOUNT ON 

				-- Insert record to the origin-base table. 
				INSERT dbo.apchkmst_origin(
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
						,@ORIGIN_DEPOSIT AS INT = 11		-- NEGATIVE AMOUNT, INDICATOR: O, APCHK_CHK_NO PREFIX: NONE
						,@ORIGIN_CHECKS AS INT = 12			-- POSITIVE AMOUNT, INDICATOR: C, APCHK_CHK_NO PREFIX: N/A, IT MUST BE A VALId NUMBER
						,@ORIGIN_EFT AS INT = 13			-- POSITIVE AMOUNT, INDICATOR: N/A, APCHK_CHK_NO PREFIX: ''E''		
						,@ORIGIN_WITHDRAWAL AS INT = 14		-- POSITIVE AMOUNT, INDICATOR: N/A, APCHK_CHK_NO PREFIX: NONE
						,@ORIGIN_WIRE AS INT = 15			-- POSITIVE AMOUNT, INDICATOR: N/A, APCHK_CHK_NO PREFIX: ''W''
			
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
						strTransactionId			=	CAST(i.apchk_cbk_no AS NVARCHAR(2)) + ''-''
														+ CAST(i.apchk_rev_dt AS NVARCHAR(10)) + ''-''
														+ CAST(i.apchk_trx_ind AS NVARCHAR(1)) + ''-''
														+ CAST(i.apchk_chk_no AS NVARCHAR(8))
						,intBankTransactionTypeId	=	
														CASE
															WHEN i.apchk_chk_amt > 0 THEN 
																CASE 
																	WHEN LEFT(i.apchk_chk_no, 1) = ''E'' THEN @ORIGIN_EFT
																	WHEN LEFT(i.apchk_chk_no, 1) = ''W'' THEN @ORIGIN_WIRE
																	WHEN i.apchk_trx_ind = ''C'' THEN @ORIGIN_CHECKS
																	ELSE @ORIGIN_WITHDRAWAL
																END
															WHEN i.apchk_chk_amt < 0 THEN @ORIGIN_DEPOSIT
														END
						,intBankAccountId			=	f.intBankAccountId
						,intCurrencyId				=	dbo.fn_GetCurrencyIdFromOriginToi21(i.apchk_currency_cnt)
						,dblExchangeRate			=	ISNULL(i.apchk_currency_rt, 1)
						,dtmDate					=	dbo.fn_ConvertOriginDateToSQLDateTime(i.apchk_gl_rev_dt)
						,strPayee					=	RTRIM(LTRIM(ISNULL(i.apchk_name, ''''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_payee_1))) > 0 THEN '', ''  ELSE '''' END +
														RTRIM(LTRIM(ISNULL(i.apchk_payee_1, ''''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_payee_2))) > 0 THEN '', ''  ELSE '''' END +
														RTRIM(LTRIM(ISNULL(i.apchk_payee_2, ''''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_payee_3))) > 0 THEN '', ''  ELSE '''' END +
														RTRIM(LTRIM(ISNULL(i.apchk_payee_3, ''''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_payee_4))) > 0 THEN '', ''  ELSE '''' END +
														RTRIM(LTRIM(ISNULL(i.apchk_payee_4, '''')))							
						,intPayeeId					=	NULL
						,strAddress					=	RTRIM(LTRIM(ISNULL(i.apchk_addr_1, ''''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_addr_2))) > 0 THEN CHAR(13) ELSE '''' END +
														RTRIM(LTRIM(ISNULL(i.apchk_addr_2, '''')))
						,strZipCode					=	RTRIM(LTRIM(i.apchk_zip))
						,strCity					=	RTRIM(LTRIM(i.apchk_city))
						,strState					=	RTRIM(LTRIM(i.apchk_st))
						,strCountry					=	NULL
						,dblAmount					=	ABS(i.apchk_chk_amt) -- Import as a positive AMOUNT value. 
						,strAmountInWords			=	dbo.fn_ConvertNumberToWord(ABS(i.apchk_chk_amt))
						,strMemo					=	RTRIM(LTRIM(ISNULL(i.apchk_comment_1, ''''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_comment_2))) > 0 THEN CHAR(13) ELSE '''' END +
														RTRIM(LTRIM(ISNULL(i.apchk_comment_2, ''''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_comment_3))) > 0 THEN CHAR(13) ELSE '''' END +
														RTRIM(LTRIM(ISNULL(i.apchk_comment_3, ''''))) 
						,strReferenceNo				=	RTRIM(LTRIM(i.apchk_chk_no))
						,dtmCheckPrinted			=	dbo.fn_ConvertOriginDateToSQLDateTime(i.apchk_gl_rev_dt)
						,ysnCheckToBePrinted		=	1
						,ysnCheckVoid				=	CASE
															WHEN i.apchk_void_ind = ''Y'' THEN 1
															ELSE 0
														END
						,ysnPosted					=	1
						,strLink					=	CAST(apchk_cbk_no AS NVARCHAR(2)) 
														+ CAST(apchk_rev_dt AS NVARCHAR(10)) 
														+ CAST(apchk_trx_ind AS NVARCHAR(1)) 
														+ CAST(apchk_chk_no AS NVARCHAR(8)) 
						,ysnClr						=	CASE 
															WHEN i.apchk_cleared_ind = ''C'' THEN 1
															ELSE 0
														END
						,dtmDateReconciled			=	dbo.fn_ConvertOriginDateToSQLDateTime(i.apchk_clear_rev_dt)
						,intCreatedUserId			=	i.apchk_user_id
						,dtmCreated					=	dbo.fn_ConvertOriginDateToSQLDateTime(i.apchk_user_rev_dt)
						,intLastModifiedUserId		=	i.apchk_user_id
						,dtmLastModified			=	dbo.fn_ConvertOriginDateToSQLDateTime(i.apchk_rev_dt)
						,intConcurrencyId			=	1
				FROM	dbo.tblCMBankAccount f INNER JOIN inserted i
							ON f.strCbkNo = i.apchk_cbk_no COLLATE Latin1_General_CI_AS  	
				WHERE	f.intBankAccountId IS NOT NULL
						AND i.apchk_chk_amt <> 0
						AND dbo.fn_ConvertOriginDateToSQLDateTime(apchk_gl_rev_dt) IS NOT NULL
				IF @@ERROR <> 0 GOTO EXIT_TRIGGER	 
	
			EXIT_TRIGGER: 

			END
			')

	EXEC ('
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
						,@ORIGIN_DEPOSIT AS INT = 11		-- NEGATIVE AMOUNT, INDICATOR: O, APCHK_CHK_NO PREFIX: NONE
						,@ORIGIN_CHECKS AS INT = 12			-- POSITIVE AMOUNT, INDICATOR: C, APCHK_CHK_NO PREFIX: N/A, IT MUST BE A VALId NUMBER
						,@ORIGIN_EFT AS INT = 13			-- POSITIVE AMOUNT, INDICATOR: N/A, APCHK_CHK_NO PREFIX: ''E''		
						,@ORIGIN_WITHDRAWAL AS INT = 14		-- POSITIVE AMOUNT, INDICATOR: N/A, APCHK_CHK_NO PREFIX: NONE
						,@ORIGIN_WIRE AS INT = 15			-- POSITIVE AMOUNT, INDICATOR: N/A, APCHK_CHK_NO PREFIX: ''W''
						
						-- Declare the local variables. 
						,@intBankAccountId AS INT
						
				-- Update the base table first (apchkmst_origin)
				UPDATE dbo.apchkmst_origin
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
				FROM	dbo.apchkmst_origin f INNER JOIN inserted i
							ON f.apchk_cbk_no = i.apchk_cbk_no
							AND f.apchk_rev_dt = i.apchk_rev_dt
							AND f.apchk_trx_ind = i.apchk_trx_ind
							AND f.apchk_chk_no = i.apchk_chk_no
				IF @@ERROR <> 0 GOTO EXIT_TRIGGER
						
				-- Check if the record exists. 
				-- If it does not exists, insert it.
				IF NOT EXISTS (
					SELECT	TOP 1 1 
					FROM	dbo.tblCMBankTransaction f INNER JOIN inserted i
								ON f.strLink = ( CAST(i.apchk_cbk_no AS NVARCHAR(2)) 
												+ CAST(i.apchk_rev_dt AS NVARCHAR(10))
												+ CAST(i.apchk_trx_ind AS NVARCHAR(1))
												+ CAST(i.apchk_chk_no AS NVARCHAR(8))
								) COLLATE Latin1_General_CI_AS 
								AND f.intBankTransactionTypeId IN (@ORIGIN_DEPOSIT, @ORIGIN_CHECKS, @ORIGIN_EFT, @ORIGIN_WITHDRAWAL, @ORIGIN_WIRE)
				)
				BEGIN 
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
							strTransactionId			=	CAST(i.apchk_cbk_no AS NVARCHAR(2)) + ''-''
															+ CAST(i.apchk_rev_dt AS NVARCHAR(10)) + ''-''
															+ CAST(i.apchk_trx_ind AS NVARCHAR(1)) + ''-''
															+ CAST(i.apchk_chk_no AS NVARCHAR(8))
							,intBankTransactionTypeId	=	
															CASE
																WHEN i.apchk_chk_amt > 0 THEN 
																	CASE 
																		WHEN LEFT(i.apchk_chk_no, 1) = ''E'' THEN @ORIGIN_EFT
																		WHEN LEFT(i.apchk_chk_no, 1) = ''W'' THEN @ORIGIN_WIRE
																		WHEN i.apchk_trx_ind = ''C'' THEN @ORIGIN_CHECKS
																		ELSE @ORIGIN_WITHDRAWAL
																	END
																WHEN i.apchk_chk_amt < 0 THEN @ORIGIN_DEPOSIT
															END
							,intBankAccountId			=	f.intBankAccountId
							,intCurrencyId				=	dbo.fn_GetCurrencyIdFromOriginToi21(i.apchk_currency_cnt)
							,dblExchangeRate			=	ISNULL(i.apchk_currency_rt, 1)
							,dtmDate					=	dbo.fn_ConvertOriginDateToSQLDateTime(i.apchk_gl_rev_dt)
							,strPayee					=	RTRIM(LTRIM(ISNULL(i.apchk_name, ''''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_payee_1))) > 0 THEN '', ''  ELSE '''' END +
															RTRIM(LTRIM(ISNULL(i.apchk_payee_1, ''''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_payee_2))) > 0 THEN '', ''  ELSE '''' END +
															RTRIM(LTRIM(ISNULL(i.apchk_payee_2, ''''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_payee_3))) > 0 THEN '', ''  ELSE '''' END +
															RTRIM(LTRIM(ISNULL(i.apchk_payee_3, ''''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_payee_4))) > 0 THEN '', ''  ELSE '''' END +
															RTRIM(LTRIM(ISNULL(i.apchk_payee_4, '''')))							
							,intPayeeId					=	NULL
							,strAddress					=	RTRIM(LTRIM(ISNULL(i.apchk_addr_1, ''''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_addr_2))) > 0 THEN CHAR(13) ELSE '''' END +
															RTRIM(LTRIM(ISNULL(i.apchk_addr_2, '''')))
							,strZipCode					=	RTRIM(LTRIM(i.apchk_zip))
							,strCity					=	RTRIM(LTRIM(i.apchk_city))
							,strState					=	RTRIM(LTRIM(i.apchk_st))
							,strCountry					=	NULL
							,dblAmount					=	ABS(i.apchk_chk_amt) -- Import as a positive AMOUNT value. 
							,strAmountInWords			=	dbo.fn_ConvertNumberToWord(ABS(i.apchk_chk_amt))
							,strMemo					=	RTRIM(LTRIM(ISNULL(i.apchk_comment_1, ''''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_comment_2))) > 0 THEN CHAR(13) ELSE '''' END +
															RTRIM(LTRIM(ISNULL(i.apchk_comment_2, ''''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_comment_3))) > 0 THEN CHAR(13) ELSE '''' END +
															RTRIM(LTRIM(ISNULL(i.apchk_comment_3, ''''))) 
							,strReferenceNo				=	RTRIM(LTRIM(i.apchk_chk_no))
							,dtmCheckPrinted			=	dbo.fn_ConvertOriginDateToSQLDateTime(i.apchk_gl_rev_dt) 
							,ysnCheckToBePrinted		=	1
							,ysnCheckVoid				=	CASE
																WHEN i.apchk_void_ind = ''Y'' THEN 1
																ELSE 0
															END
							,ysnPosted					=	1
							,strLink					=	CAST(apchk_cbk_no AS NVARCHAR(2)) 
															+ CAST(apchk_rev_dt AS NVARCHAR(10)) 
															+ CAST(apchk_trx_ind AS NVARCHAR(1)) 
															+ CAST(apchk_chk_no AS NVARCHAR(8)) 
							,ysnClr						=	CASE 
																WHEN i.apchk_cleared_ind = ''C'' THEN 1
																ELSE 0
															END
							,dtmDateReconciled			=	dbo.fn_ConvertOriginDateToSQLDateTime(i.apchk_clear_rev_dt)
							,intCreatedUserId			=	i.apchk_user_id
							,dtmCreated					=	dbo.fn_ConvertOriginDateToSQLDateTime(i.apchk_user_rev_dt)
							,intLastModifiedUserId		=	i.apchk_user_id
							,dtmLastModified			=	dbo.fn_ConvertOriginDateToSQLDateTime(i.apchk_rev_dt)
							,intConcurrencyId			=	1
					FROM	dbo.tblCMBankAccount f INNER JOIN inserted i
								ON f.strCbkNo = i.apchk_cbk_no COLLATE Latin1_General_CI_AS  	
					WHERE	f.intBankAccountId IS NOT NULL
							AND i.apchk_chk_amt <> 0
							AND dbo.fn_ConvertOriginDateToSQLDateTime(apchk_gl_rev_dt) IS NOT NULL				
					IF @@ERROR <> 0 GOTO EXIT_TRIGGER	
				END		
				ELSE 
				BEGIN 
					-- Update the i21 bank transaction table. 
					-- However, do not allow the update if the bank record is already cleared. 
					UPDATE	dbo.tblCMBankTransaction 
					SET		
							strTransactionId			=	CAST(i.apchk_cbk_no AS NVARCHAR(2)) + ''-''
															+ CAST(i.apchk_rev_dt AS NVARCHAR(10)) + ''-''
															+ CAST(i.apchk_trx_ind AS NVARCHAR(1)) + ''-''
															+ CAST(i.apchk_chk_no AS NVARCHAR(8))
							,intBankTransactionTypeId	=	
															CASE
																WHEN i.apchk_chk_amt > 0 THEN 
																	CASE 
																		WHEN LEFT(i.apchk_chk_no, 1) = ''E'' THEN @ORIGIN_EFT
																		WHEN LEFT(i.apchk_chk_no, 1) = ''W'' THEN @ORIGIN_WIRE
																		WHEN i.apchk_trx_ind = ''C'' THEN @ORIGIN_CHECKS
																		ELSE @ORIGIN_WITHDRAWAL
																	END
																WHEN i.apchk_chk_amt < 0 THEN @ORIGIN_DEPOSIT
															END
							,intBankAccountId			=	e.intBankAccountId
							,intCurrencyId				=	dbo.fn_GetCurrencyIdFromOriginToi21(i.apchk_currency_cnt)
							,dblExchangeRate			=	ISNULL(i.apchk_currency_rt, 1)
							,dtmDate					=	dbo.fn_ConvertOriginDateToSQLDateTime(i.apchk_gl_rev_dt)
							,strPayee					=	RTRIM(LTRIM(ISNULL(i.apchk_name, ''''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_payee_1))) > 0 THEN '', ''  ELSE '''' END +
															RTRIM(LTRIM(ISNULL(i.apchk_payee_1, ''''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_payee_2))) > 0 THEN '', ''  ELSE '''' END +
															RTRIM(LTRIM(ISNULL(i.apchk_payee_2, ''''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_payee_3))) > 0 THEN '', ''  ELSE '''' END +
															RTRIM(LTRIM(ISNULL(i.apchk_payee_3, ''''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_payee_4))) > 0 THEN '', ''  ELSE '''' END +
															RTRIM(LTRIM(ISNULL(i.apchk_payee_4, '''')))
							,intPayeeId					=	NULL
							,strAddress					=	RTRIM(LTRIM(ISNULL(i.apchk_addr_1, ''''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_addr_2))) > 0 THEN CHAR(13) ELSE '''' END +
															RTRIM(LTRIM(ISNULL(i.apchk_addr_2, '''')))	
							,strZipCode					=	RTRIM(LTRIM(i.apchk_zip))
							,strCity					=	RTRIM(LTRIM(i.apchk_city))
							,strState					=	RTRIM(LTRIM(i.apchk_st))
							,strCountry					=	NULL
							,dblAmount					=	ABS(i.apchk_chk_amt) -- Import as a positive AMOUNT value. 
							,strAmountInWords			=	dbo.fn_ConvertNumberToWord(ABS(i.apchk_chk_amt))
							,strMemo					=	RTRIM(LTRIM(ISNULL(i.apchk_comment_1, ''''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_comment_2))) > 0 THEN CHAR(13) ELSE '''' END +
															RTRIM(LTRIM(ISNULL(i.apchk_comment_2, ''''))) + CASE WHEN LEN(LTRIM(RTRIM(i.apchk_comment_3))) > 0 THEN CHAR(13) ELSE '''' END +
															RTRIM(LTRIM(ISNULL(i.apchk_comment_3, ''''))) 
							,strReferenceNo				=	RTRIM(LTRIM(i.apchk_chk_no))
							,dtmCheckPrinted			=	dbo.fn_ConvertOriginDateToSQLDateTime(i.apchk_gl_rev_dt)
							,ysnCheckToBePrinted		=	1
							,ysnCheckVoid				=	CASE
																WHEN i.apchk_void_ind = ''Y'' THEN 1
																ELSE 0
															END
							,ysnPosted					=	1
							,strLink					=	CAST(apchk_cbk_no AS NVARCHAR(2)) 
															+ CAST(apchk_rev_dt AS NVARCHAR(10)) 
															+ CAST(apchk_trx_ind AS NVARCHAR(1)) 
															+ CAST(apchk_chk_no AS NVARCHAR(8)) 
							,ysnClr						=	CASE 
																WHEN i.apchk_cleared_ind = ''C'' THEN 1
																ELSE 0
															END
							,dtmDateReconciled			=	dbo.fn_ConvertOriginDateToSQLDateTime(i.apchk_clear_rev_dt)
							,intCreatedUserId			=	i.apchk_user_id
							,dtmCreated					=	dbo.fn_ConvertOriginDateToSQLDateTime(i.apchk_user_rev_dt)
							,intLastModifiedUserId		=	i.apchk_user_id
							,dtmLastModified			=	dbo.fn_ConvertOriginDateToSQLDateTime(i.apchk_rev_dt)
							,intConcurrencyId			=	f.intConcurrencyId + 1
					FROM	inserted i INNER JOIN dbo.tblCMBankTransaction f
								ON f.strLink = ( CAST(i.apchk_cbk_no AS NVARCHAR(2)) 
												+ CAST(i.apchk_rev_dt AS NVARCHAR(10)) 
												+ CAST(i.apchk_trx_ind AS NVARCHAR(1)) 
												+ CAST(i.apchk_chk_no AS NVARCHAR(8))
								) COLLATE Latin1_General_CI_AS 
								AND f.intBankTransactionTypeId IN (@ORIGIN_DEPOSIT, @ORIGIN_CHECKS, @ORIGIN_EFT, @ORIGIN_WITHDRAWAL, @ORIGIN_WIRE)
								AND f.ysnClr = 0
							INNER JOIN dbo.tblCMBankAccount e
								ON e.strCbkNo = i.apchk_cbk_no COLLATE Latin1_General_CI_AS
								AND e.intBankAccountId = f.intBankAccountId				
					WHERE	e.intBankAccountId IS NOT NULL
							AND i.apchk_chk_amt <> 0
							AND dbo.fn_ConvertOriginDateToSQLDateTime(apchk_gl_rev_dt) IS NOT NULL
					IF @@ERROR <> 0 GOTO EXIT_TRIGGER
				END
				
			EXIT_TRIGGER:

			END
		')
	END