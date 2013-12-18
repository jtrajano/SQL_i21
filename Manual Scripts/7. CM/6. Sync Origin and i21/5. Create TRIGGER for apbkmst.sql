IF OBJECT_ID ('trg_insert_apcbkmst') IS NOT NULL 
	DROP TRIGGER trg_insert_apcbkmst
GO

CREATE TRIGGER trg_insert_apcbkmst
ON [dbo].apcbkmst
INSTEAD OF INSERT
AS
BEGIN 

SET NOCOUNT ON 

	-- Bank Account Types:
	DECLARE @DEPOSIT_ACCOUNT INT = 1
	DECLARE @LOAN_ACCOUNT INT = 2
	
	-- MICR: ACCOUNT SPACE POSITION
	DECLARE @ACCOUNT_LEADING INT = 1
	DECLARE @ACCOUNT_TRAILING INT = 2
	
	-- MICR: CHECK NUMBER SPACE POSITION
	DECLARE @CHECKNO_LEADING INT = 1
	DECLARE @CHECKNO_TRAILING INT = 2
	
	-- MICR: CHECK NUMBER POSITION
	DECLARE @CHECKNO_LEFT INT = 1
	DECLARE @CHECKNO_MIDDLE INT = 2
	DECLARE @CHECKNO_RIGHT INT = 3

	-- Proceed in inserting the record the base table (apcbkmsti21fied)			
	INSERT INTO apcbkmsti21fied (
			apcbk_no				
			,apcbk_currency			
			,apcbk_password			
			,apcbk_desc				
			,apcbk_bank_acct_no		
			,apcbk_comment			
			,apcbk_show_bal_yn		
			,apcbk_prompt_align_yn	
			,apcbk_chk_clr_ord_dn	
			,apcbk_import_export_yn	
			,apcbk_export_cbk_no	
			,apcbk_stmt_lock_rev_dt	
			,apcbk_gl_close_rev_dt	
			,apcbk_bal				
			,apcbk_next_chk_no		
			,apcbk_next_eft_no		
			,apcbk_check_format_cs	
			,apcbk_laser_down_lines	
			,apcbk_prtr_checks		
			,apcbk_auto_assign_trx_yn
			,apcbk_next_trx_no		
			,apcbk_transit_route	
			,apcbk_ach_company_id	
			,apcbk_ach_bankname		
			,apcbk_gl_cash			
			,apcbk_gl_ap			
			,apcbk_gl_disc			
			,apcbk_gl_wthhld		
			,apcbk_gl_curr			
			,apcbk_active_yn		
			,apcbk_bnk_no			
			,apcbk_user_id			
			,apcbk_user_rev_dt		
	)	
	SELECT 
			apcbk_no					= i.apcbk_no
			,apcbk_currency				= i.apcbk_currency
			,apcbk_password				= i.apcbk_password
			,apcbk_desc					= i.apcbk_desc
			,apcbk_bank_acct_no			= i.apcbk_bank_acct_no
			,apcbk_comment				= i.apcbk_comment
			,apcbk_show_bal_yn			= i.apcbk_show_bal_yn
			,apcbk_prompt_align_yn		= i.apcbk_prompt_align_yn
			,apcbk_chk_clr_ord_dn		= i.apcbk_chk_clr_ord_dn
			,apcbk_import_export_yn		= i.apcbk_import_export_yn
			,apcbk_export_cbk_no		= i.apcbk_export_cbk_no
			,apcbk_stmt_lock_rev_dt		= i.apcbk_stmt_lock_rev_dt
			,apcbk_gl_close_rev_dt		= i.apcbk_gl_close_rev_dt
			,apcbk_bal					= i.apcbk_bal
			,apcbk_next_chk_no			= i.apcbk_next_chk_no
			,apcbk_next_eft_no			= i.apcbk_next_eft_no
			,apcbk_check_format_cs		= i.apcbk_check_format_cs
			,apcbk_laser_down_lines		= i.apcbk_laser_down_lines
			,apcbk_prtr_checks			= i.apcbk_prtr_checks
			,apcbk_auto_assign_trx_yn	= i.apcbk_auto_assign_trx_yn
			,apcbk_next_trx_no			= i.apcbk_next_trx_no
			,apcbk_transit_route		= i.apcbk_transit_route
			,apcbk_ach_company_id		= i.apcbk_ach_company_id
			,apcbk_ach_bankname			= i.apcbk_ach_bankname
			,apcbk_gl_cash				= i.apcbk_gl_cash
			,apcbk_gl_ap				= i.apcbk_gl_ap
			,apcbk_gl_disc				= i.apcbk_gl_disc
			,apcbk_gl_wthhld			= i.apcbk_gl_wthhld
			,apcbk_gl_curr				= i.apcbk_gl_curr
			,apcbk_active_yn			= i.apcbk_active_yn
			,apcbk_bnk_no				= i.apcbk_bnk_no
			,apcbk_user_id				= i.apcbk_user_id
			,apcbk_user_rev_dt			= i.apcbk_user_rev_dt
	FROM	inserted i 
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER

	-- INSERT new records for tblCMBank
	INSERT INTO tblCMBank (
			strBankName
			,strContact
			,strAddress
			,strZipCode
			,strCity
			,strState
			,strCountry
			,strPhone
			,strFax
			,strWebsite
			,strEmail
			,strRTN
			,intCreatedUserID
			,dtmCreated
			,intLastModifiedUserID
			,dtmLastModified
			,intConcurrencyID
		)
	SELECT 
			strBankName				= ISNULL(i.apcbk_desc, '') COLLATE Latin1_General_CI_AS
			,strContact				= ''
			,strAddress				= ''
			,strZipCode				= ''
			,strCity				= ''
			,strState				= ''
			,strCountry				= ''
			,strPhone				= ''
			,strFax					= ''
			,strWebsite				= ''	
			,strEmail				= ''
			,strRTN					= CAST(i.apcbk_transit_route AS NVARCHAR(12)) COLLATE Latin1_General_CI_AS
			,intCreatedUserID		= NULL
			,dtmCreated				= GETDATE()
			,intLastModifiedUserID	= NULL
			,dtmLastModified		= GETDATE()
			,intConcurrencyID		= 1
	FROM	inserted i
	WHERE	NOT EXISTS (SELECT TOP 1 1 FROM tblCMBank WHERE strBankName = ISNULL(i.apcbk_desc, '') COLLATE Latin1_General_CI_AS)
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER
	
	-- Insert new record in tblCMBankAccount
	INSERT INTO tblCMBankAccount (
		strBankName
		,ysnActive
		,intGLAccountID
		,intCurrencyID
		,intBankAccountType
		,strContact
		,strBankAccountNo
		,strRTN
		,strAddress
		,strZipCode
		,strCity
		,strState
		,strCountry
		,strPhone
		,strFax
		,strWebsite
		,strEmail
		,intCheckStartingNo
		,intCheckEndingNo
		,intCheckNextNo
		,ysnCheckEnableMICRPrint
		,ysnCheckDefaultToBePrinted
		,intBackupCheckStartingNo
		,intBackupCheckEndingNo
		,intEFTNextNo
		,intEFTBankFileFormatID
		,strEFTCompanyID
		,strEFTBankName
		,strMICRDescription
		,intMICRBankAccountSpacesCount
		,intMICRBankAccountSpacesPosition
		,intMICRCheckNoSpacesCount
		,intMICRCheckNoSpacesPosition
		,intMICRCheckNoLength
		,intMICRCheckNoPosition
		,strMICRLeftSymbol
		,strMICRRightSymbol
		,intCreatedUserID
		,dtmCreated
		,intLastModifiedUserID
		,dtmLastModified
		,intConcurrencyID
		,strCbkNo	
	)
	SELECT			
		strBankName							= ISNULL(i.apcbk_desc, '') COLLATE Latin1_General_CI_AS
		,ysnActive							= CASE WHEN i.apcbk_active_yn = 'Y' THEN 1 ELSE 0 END 
		,intGLAccountID						= dbo.fn_GetGLAccountIDFromOriginToi21(i.apcbk_gl_cash) 
		,intCurrencyID						= dbo.fn_GetCurrencyIDFromOriginToi21(i.apcbk_currency)
		,intBankAccountType					= @DEPOSIT_ACCOUNT
		,strContact							= ''
		,strBankAccountNo					= i.apcbk_bank_acct_no
		,strRTN								= i.apcbk_transit_route
		,strAddress							= ''
		,strZipCode							= ''
		,strCity							= ''
		,strState							= ''
		,strCountry							= ''
		,strPhone							= ''
		,strFax								= ''
		,strWebsite							= ''
		,strEmail							= ''
		,intCheckStartingNo					= 1
		,intCheckEndingNo					= i.apcbk_next_chk_no
		,intCheckNextNo						= i.apcbk_next_chk_no
		,ysnCheckEnableMICRPrint			= 1
		,ysnCheckDefaultToBePrinted			= 1
		,intBackupCheckStartingNo			= 0
		,intBackupCheckEndingNo				= 0
		,intEFTNextNo						= i.apcbk_next_eft_no
		,intEFTBankFileFormatID				= NULL 
		,strEFTCompanyID					= ''
		,strEFTBankName						= ''
		,strMICRDescription					= ''
		,intMICRBankAccountSpacesCount		= 0
		,intMICRBankAccountSpacesPosition	= @ACCOUNT_LEADING
		,intMICRCheckNoSpacesCount			= 0
		,intMICRCheckNoSpacesPosition		= @CHECKNO_LEADING
		,intMICRCheckNoLength				= 6
		,intMICRCheckNoPosition				= @CHECKNO_LEFT
		,strMICRLeftSymbol					= 'C'
		,strMICRRightSymbol					= 'C'
		,intCreatedUserID					= NULL
		,dtmCreated							= GETDATE()
		,intLastModifiedUserID				= NULL
		,dtmLastModified					= GETDATE()
		,intConcurrencyID					= 1
		,strCbkNo							= i.apcbk_no	
	FROM	inserted i
	WHERE	NOT EXISTS (SELECT TOP 1 1 FROM tblCMBankAccount WHERE tblCMBankAccount.strCbkNo = i.apcbk_no)
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER
	
EXIT_TRIGGER: 

END
GO 

IF OBJECT_ID ('trg_update_apcbkmst') IS NOT NULL 
	DROP TRIGGER trg_update_apcbkmst
GO

CREATE TRIGGER trg_update_apcbkmst
ON [dbo].apcbkmst
INSTEAD OF UPDATE
AS
BEGIN 

SET NOCOUNT ON

	-- Bank Account Types:
	DECLARE @DEPOSIT_ACCOUNT INT = 1
	DECLARE @LOAN_ACCOUNT INT = 2
	
	-- MICR: ACCOUNT SPACE POSITION
	DECLARE @ACCOUNT_LEADING INT = 1
	DECLARE @ACCOUNT_TRAILING INT = 2
	
	-- MICR: CHECK NUMBER SPACE POSITION
	DECLARE @CHECKNO_LEADING INT = 1
	DECLARE @CHECKNO_TRAILING INT = 2
	
	-- MICR: CHECK NUMBER POSITION
	DECLARE @CHECKNO_LEFT INT = 1
	DECLARE @CHECKNO_MIDDLE INT = 2
	DECLARE @CHECKNO_RIGHT INT = 3 	
	
	-- Proceed in updating the base table (apcbkmsti21fied)				
	UPDATE	apcbkmsti21fied
	SET		apcbk_no					= i.apcbk_no
			,apcbk_currency				= i.apcbk_currency
			,apcbk_password				= i.apcbk_password
			,apcbk_desc					= i.apcbk_desc
			,apcbk_bank_acct_no			= i.apcbk_bank_acct_no
			,apcbk_comment				= i.apcbk_comment
			,apcbk_show_bal_yn			= i.apcbk_show_bal_yn
			,apcbk_prompt_align_yn		= i.apcbk_prompt_align_yn
			,apcbk_chk_clr_ord_dn		= i.apcbk_chk_clr_ord_dn
			,apcbk_import_export_yn		= i.apcbk_import_export_yn
			,apcbk_export_cbk_no		= i.apcbk_export_cbk_no
			,apcbk_stmt_lock_rev_dt		= i.apcbk_stmt_lock_rev_dt
			,apcbk_gl_close_rev_dt		= i.apcbk_gl_close_rev_dt
			,apcbk_bal					= i.apcbk_bal
			,apcbk_next_chk_no			= i.apcbk_next_chk_no
			,apcbk_next_eft_no			= i.apcbk_next_eft_no
			,apcbk_check_format_cs		= i.apcbk_check_format_cs
			,apcbk_laser_down_lines		= i.apcbk_laser_down_lines
			,apcbk_prtr_checks			= i.apcbk_prtr_checks
			,apcbk_auto_assign_trx_yn	= i.apcbk_auto_assign_trx_yn
			,apcbk_next_trx_no			= i.apcbk_next_trx_no
			,apcbk_transit_route		= i.apcbk_transit_route
			,apcbk_ach_company_id		= i.apcbk_ach_company_id
			,apcbk_ach_bankname			= i.apcbk_ach_bankname
			,apcbk_gl_cash				= i.apcbk_gl_cash
			,apcbk_gl_ap				= i.apcbk_gl_ap
			,apcbk_gl_disc				= i.apcbk_gl_disc
			,apcbk_gl_wthhld			= i.apcbk_gl_wthhld
			,apcbk_gl_curr				= i.apcbk_gl_curr
			,apcbk_active_yn			= i.apcbk_active_yn
			,apcbk_bnk_no				= i.apcbk_bnk_no
			,apcbk_user_id				= i.apcbk_user_id
			,apcbk_user_rev_dt			= i.apcbk_user_rev_dt
	FROM	inserted i INNER JOIN apcbkmsti21fied B
				ON i.apcbk_no = B.apcbk_no

	IF @@ERROR <> 0 GOTO EXIT_TRIGGER	

	-- INSERT new records for tblCMBank
	INSERT INTO tblCMBank (
			strBankName
			,strContact
			,strAddress
			,strZipCode
			,strCity
			,strState
			,strCountry
			,strPhone
			,strFax
			,strWebsite
			,strEmail
			,strRTN
			,intCreatedUserID
			,dtmCreated
			,intLastModifiedUserID
			,dtmLastModified
			,intConcurrencyID
		)
	SELECT 
			strBankName				= ISNULL(i.apcbk_desc, '') COLLATE Latin1_General_CI_AS
			,strContact				= ''
			,strAddress				= ''
			,strZipCode				= ''
			,strCity				= ''
			,strState				= ''
			,strCountry				= ''
			,strPhone				= ''
			,strFax					= ''
			,strWebsite				= ''	
			,strEmail				= ''
			,strRTN					= CAST(i.apcbk_transit_route AS NVARCHAR(12)) COLLATE Latin1_General_CI_AS
			,intCreatedUserID		= NULL
			,dtmCreated				= GETDATE()
			,intLastModifiedUserID	= NULL
			,dtmLastModified		= GETDATE()
			,intConcurrencyID		= 1
	FROM	inserted i INNER JOIN deleted d
				ON i.apcbk_no = d.apcbk_no 
	WHERE	NOT EXISTS (SELECT TOP 1 1 FROM tblCMBank WHERE strBankName = ISNULL(d.apcbk_desc, '') COLLATE Latin1_General_CI_AS)
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER

	-- UPDATE modified record for tblCMBank
	UPDATE	tblCMBank
	SET		strBankName		= ISNULL(i.apcbk_desc, '') COLLATE Latin1_General_CI_AS
			,strRTN			= CAST(i.apcbk_transit_route AS NVARCHAR(12)) COLLATE Latin1_General_CI_AS
	FROM	inserted i INNER JOIN deleted d
				ON i.apcbk_no = d.apcbk_no 
			INNER JOIN tblCMBank
				ON ISNULL(d.apcbk_desc, '') COLLATE Latin1_General_CI_AS = tblCMBank.strBankName
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER	
	
	-- Insert new record in tblCMBankAccount
	INSERT INTO tblCMBankAccount (
			strBankName
			,ysnActive
			,intGLAccountID
			,intCurrencyID
			,intBankAccountType
			,strContact
			,strBankAccountNo
			,strRTN
			,strAddress
			,strZipCode
			,strCity
			,strState
			,strCountry
			,strPhone
			,strFax
			,strWebsite
			,strEmail
			,intCheckStartingNo
			,intCheckEndingNo
			,intCheckNextNo
			,ysnCheckEnableMICRPrint
			,ysnCheckDefaultToBePrinted
			,intBackupCheckStartingNo
			,intBackupCheckEndingNo
			,intEFTNextNo
			,intEFTBankFileFormatID
			,strEFTCompanyID
			,strEFTBankName
			,strMICRDescription
			,intMICRBankAccountSpacesCount
			,intMICRBankAccountSpacesPosition
			,intMICRCheckNoSpacesCount
			,intMICRCheckNoSpacesPosition
			,intMICRCheckNoLength
			,intMICRCheckNoPosition
			,strMICRLeftSymbol
			,strMICRRightSymbol
			,intCreatedUserID
			,dtmCreated
			,intLastModifiedUserID
			,dtmLastModified
			,intConcurrencyID
			,strCbkNo	
	)
	SELECT			
			strBankName							= ISNULL(i.apcbk_desc, '') 
			,ysnActive							= CASE WHEN i.apcbk_active_yn = 'Y' THEN 1 ELSE 0 END 
			,intGLAccountID						= dbo.fn_GetGLAccountIDFromOriginToi21(i.apcbk_gl_cash) 
			,intCurrencyID						= dbo.fn_GetCurrencyIDFromOriginToi21(i.apcbk_currency)
			,intBankAccountType					= @DEPOSIT_ACCOUNT
			,strContact							= ''
			,strBankAccountNo					= ISNULL(i.apcbk_bank_acct_no, '') 
			,strRTN								= i.apcbk_transit_route 
			,strAddress							= ''
			,strZipCode							= ''
			,strCity							= ''
			,strState							= ''
			,strCountry							= ''
			,strPhone							= ''
			,strFax								= ''
			,strWebsite							= ''
			,strEmail							= ''
			,intCheckStartingNo					= 1
			,intCheckEndingNo					= i.apcbk_next_chk_no
			,intCheckNextNo						= i.apcbk_next_chk_no
			,ysnCheckEnableMICRPrint			= 1
			,ysnCheckDefaultToBePrinted			= 1
			,intBackupCheckStartingNo			= 0
			,intBackupCheckEndingNo				= 0
			,intEFTNextNo						= i.apcbk_next_eft_no
			,intEFTBankFileFormatID				= NULL 
			,strEFTCompanyID					= ''
			,strEFTBankName						= ''
			,strMICRDescription					= ''
			,intMICRBankAccountSpacesCount		= 0
			,intMICRBankAccountSpacesPosition	= @ACCOUNT_LEADING
			,intMICRCheckNoSpacesCount			= 0
			,intMICRCheckNoSpacesPosition		= @CHECKNO_LEADING
			,intMICRCheckNoLength				= 6
			,intMICRCheckNoPosition				= @CHECKNO_LEFT
			,strMICRLeftSymbol					= 'C'
			,strMICRRightSymbol					= 'C'
			,intCreatedUserID					= NULL
			,dtmCreated							= GETDATE()
			,intLastModifiedUserID				= NULL
			,dtmLastModified					= GETDATE()
			,intConcurrencyID					= 1
			,strCbkNo							= i.apcbk_no	
	FROM	inserted i INNER JOIN deleted d
				ON i.apcbk_no = d.apcbk_no 
	WHERE	NOT EXISTS (SELECT TOP 1 1 FROM tblCMBankAccount WHERE tblCMBankAccount.strCbkNo = i.apcbk_no)
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER	
	
	-- UPDATE modified record for tblCMBank
	UPDATE	tblCMBankAccount
	SET		strBankName							= i.apcbk_desc COLLATE Latin1_General_CI_AS
			,ysnActive							= CASE WHEN i.apcbk_active_yn = 'Y' THEN 1 ELSE 0 END
			,intGLAccountID						= dbo.fn_GetGLAccountIDFromOriginToi21(i.apcbk_gl_cash) 
			,intCurrencyID						= dbo.fn_GetCurrencyIDFromOriginToi21(i.apcbk_currency)
			,strBankAccountNo					= ISNULL(i.apcbk_bank_acct_no, '')
			,strRTN								= i.apcbk_transit_route
			,intCheckNextNo						= i.apcbk_next_chk_no
			,intEFTNextNo						= i.apcbk_next_eft_no
			,dtmLastModified					= GETDATE()
			,intConcurrencyID					= 1
			,strCbkNo							= i.apcbk_no	
	FROM	inserted i INNER JOIN deleted d
				ON i.apcbk_no = d.apcbk_no 
			INNER JOIN tblCMBankAccount
				ON d.apcbk_no = tblCMBankAccount.strCbkNo
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER	

EXIT_TRIGGER:

END 