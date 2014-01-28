
CREATE VIEW [dbo].vwCMBankAccount
WITH SCHEMABINDING
AS 

SELECT	i21.intBankAccountID
		,i21.strBankName
		,i21.ysnActive
		,i21.intGLAccountID
		,i21.intCurrencyID
		,i21.intBankAccountType
		,i21.strContact
		,i21.strBankAccountNo
		,i21.strRTN
		,i21.strAddress
		,i21.strZipCode
		,i21.strCity
		,i21.strState
		,i21.strCountry
		,i21.strPhone
		,i21.strFax
		,i21.strWebsite
		,i21.strEmail
		,i21.intCheckStartingNo
		,i21.intCheckEndingNo
		,i21.intCheckNextNo
		,i21.ysnCheckEnableMICRPrint
		,i21.ysnCheckDefaultToBePrinted
		,i21.intBackupCheckStartingNo
		,i21.intBackupCheckEndingNo
		,i21.intEFTNextNo
		,i21.intEFTBankFileFormatID
		,i21.strEFTCompanyID
		,i21.strEFTBankName
		,i21.strMICRDescription
		,i21.intMICRBankAccountSpacesCount
		,i21.intMICRBankAccountSpacesPosition
		,i21.intMICRCheckNoSpacesCount
		,i21.intMICRCheckNoSpacesPosition
		,i21.intMICRCheckNoLength
		,i21.intMICRCheckNoPosition
		,i21.strMICRLeftSymbol
		,i21.strMICRRightSymbol
		,i21.intCreatedUserID
		,i21.dtmCreated
		,i21.intLastModifiedUserID
		,i21.dtmLastModified
		,i21.strCbkNo
		,i21.intConcurrencyId
		-- The following fields are from the origin system		
		,origin.apcbk_comment				-- CHAR (30)
		,apcbk_password = ISNULL(origin.apcbk_password, '')	-- CHAR (16)
		,origin.apcbk_show_bal_yn			-- Y/N
		,origin.apcbk_prompt_align_yn		-- Y/N
		,origin.apcbk_chk_clr_ord_dn		-- Y/N
		,origin.apcbk_import_export_yn		-- Y/N
		,origin.apcbk_export_cbk_no			-- CHAR (2)
		,origin.apcbk_stmt_lock_rev_dt		-- INT yyyymmdd
		,origin.apcbk_gl_close_rev_dt		-- INT yyyymmdd
		,origin.apcbk_check_format_cs		-- CHAR (2)
		,origin.apcbk_laser_down_lines		-- INT
		,origin.apcbk_prtr_checks			-- CHAR (80)
		,origin.apcbk_auto_assign_trx_yn	-- Y/N
FROM	dbo.tblCMBankAccount i21 LEFT JOIN dbo.apcbkmst_legacy origin
			ON i21.strCbkNo = origin.apcbk_no COLLATE Latin1_General_CI_AS
GO

GO

GO

CREATE TRIGGER trg_update_vwCMBankAccount
ON [dbo].vwCMBankAccount
INSTEAD OF UPDATE
AS
BEGIN 

SET NOCOUNT ON

	-- Perform validation on strCbkNo field. 
	IF EXISTS (
		SELECT	TOP 1 1 
		FROM	inserted i
		WHERE	EXISTS (
					SELECT	TOP 1 1 
					FROM	dbo.tblCMBankAccount t 
					WHERE	t.intBankAccountID <> i.intBankAccountID 
							AND t.strCbkNo = i.strCbkNo 
							AND ISNULL(i.strCbkNo, '') <> ''
				)
	)
	BEGIN 
		RAISERROR(50011, 11, 1)	-- 'Duplicate checkbook id found.'
		GOTO EXIT_TRIGGER
	END 

	-- Proceed in updating the base table (tblCMBankAccount)				
	UPDATE	dbo.tblCMBankAccount 
	SET		strBankName							= i.strBankName
			,ysnActive							= i.ysnActive
			,intGLAccountID						= i.intGLAccountID
			,intCurrencyID						= i.intCurrencyID
			,intBankAccountType					= i.intBankAccountType
			,strContact							= i.strContact
			,strBankAccountNo					= i.strBankAccountNo
			,strRTN								= i.strRTN
			,strAddress							= i.strAddress
			,strZipCode							= i.strZipCode
			,strCity							= i.strCity
			,strState							= i.strState
			,strCountry							= i.strCountry
			,strPhone							= i.strPhone
			,strFax								= i.strFax
			,strWebsite							= i.strWebsite
			,strEmail							= i.strEmail
			,intCheckStartingNo					= i.intCheckStartingNo
			,intCheckEndingNo					= i.intCheckEndingNo
			,intCheckNextNo						= i.intCheckNextNo
			,ysnCheckEnableMICRPrint			= i.ysnCheckEnableMICRPrint
			,ysnCheckDefaultToBePrinted			= i.ysnCheckDefaultToBePrinted
			,intBackupCheckStartingNo			= i.intBackupCheckStartingNo
			,intBackupCheckEndingNo				= i.intBackupCheckEndingNo
			,intEFTNextNo						= i.intEFTNextNo
			,intEFTBankFileFormatID				= i.intEFTBankFileFormatID
			,strEFTCompanyID					= i.strEFTCompanyID
			,strEFTBankName						= i.strEFTBankName
			,strMICRDescription					= i.strMICRDescription
			,intMICRBankAccountSpacesCount		= i.intMICRBankAccountSpacesCount
			,intMICRBankAccountSpacesPosition	= i.intMICRBankAccountSpacesPosition
			,intMICRCheckNoSpacesCount			= i.intMICRCheckNoSpacesCount
			,intMICRCheckNoSpacesPosition		= i.intMICRCheckNoSpacesPosition
			,intMICRCheckNoLength				= i.intMICRCheckNoLength
			,intMICRCheckNoPosition				= i.intMICRCheckNoPosition
			,strMICRLeftSymbol					= i.strMICRLeftSymbol
			,strMICRRightSymbol					= i.strMICRRightSymbol
			,intCreatedUserID					= i.intCreatedUserID
			,dtmCreated							= i.dtmCreated
			,intLastModifiedUserID				= i.intLastModifiedUserID
			,dtmLastModified					= i.dtmLastModified
			,intConcurrencyId					= i.intConcurrencyId
			,strCbkNo							= i.strCbkNo
	FROM	inserted i INNER JOIN dbo.tblCMBankAccount B
				ON i.intBankAccountID = B.intBankAccountID

	IF @@ERROR <> 0 GOTO EXIT_TRIGGER
	
	-- UPDATE modified record for apcbkmst_legacy
	UPDATE	dbo.apcbkmst_legacy 
	SET		apcbk_no					= i.strCbkNo
			,apcbk_currency				= dbo.fn_GetCurrencyIDFromi21ToOrigin(i.intCurrencyID)
			,apcbk_password				= i.apcbk_password
			,apcbk_desc					= i.strBankName COLLATE SQL_Latin1_General_CP1_CS_AS
			,apcbk_bank_acct_no			= i.strBankAccountNo COLLATE SQL_Latin1_General_CP1_CS_AS
			,apcbk_comment				= i.apcbk_comment 
			,apcbk_show_bal_yn			= i.apcbk_show_bal_yn
			,apcbk_prompt_align_yn		= i.apcbk_prompt_align_yn
			,apcbk_chk_clr_ord_dn		= i.apcbk_chk_clr_ord_dn
			,apcbk_import_export_yn		= i.apcbk_import_export_yn
			,apcbk_export_cbk_no		= i.apcbk_export_cbk_no
			,apcbk_stmt_lock_rev_dt		= i.apcbk_stmt_lock_rev_dt
			,apcbk_gl_close_rev_dt		= i.apcbk_gl_close_rev_dt
			--,apcbk_bal				= NULL
			--,apcbk_next_chk_no		= NULL
			--,apcbk_next_eft_no		= NULL 
			,apcbk_check_format_cs		= i.apcbk_check_format_cs
			,apcbk_laser_down_lines		= i.apcbk_laser_down_lines
			,apcbk_prtr_checks			= i.apcbk_prtr_checks
			,apcbk_auto_assign_trx_yn	= i.apcbk_auto_assign_trx_yn
			--,apcbk_next_trx_no		= NULL
			--,apcbk_transit_route		= NULL
			--,apcbk_ach_company_id		= NULL
			--,apcbk_ach_bankname		= NULL
			,apcbk_gl_cash				= dbo.fn_GetGLAccountIDFromi21ToOrigin(i.intGLAccountID)
			--,apcbk_gl_ap				= NULL
			--,apcbk_gl_disc			= NULL
			--,apcbk_gl_wthhld			= NULL
			--,apcbk_gl_curr			= 0
			,apcbk_active_yn			= CASE WHEN i.ysnActive = 1 THEN 'Y' ELSE 'N' END 
			--,apcbk_bnk_no				= NULL
			--,apcbk_user_id			= NULL 
			--,apcbk_user_rev_dt		= 0	
	FROM	inserted i INNER JOIN deleted d
				ON i.intBankAccountID = d.intBankAccountID
			INNER JOIN dbo.apcbkmst_legacy legacy
				ON d.strCbkNo = legacy.apcbk_no COLLATE Latin1_General_CI_AS
	WHERE	ISNULL(i.strCbkNo, '') <> ''
			AND ISNULL(d.strCbkNo, '') <> ''
					
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER			

	-- INSERT new records for apcbkmst_legacy (if it does not exists)
	INSERT INTO apcbkmst_legacy (
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
			apcbk_no					= i.strCbkNo
			,apcbk_currency				= dbo.fn_GetCurrencyIDFromi21ToOrigin(i.intCurrencyID)
			,apcbk_password				= i.apcbk_password
			,apcbk_desc					= i.strBankName COLLATE SQL_Latin1_General_CP1_CS_AS
			,apcbk_bank_acct_no			= i.strBankAccountNo COLLATE SQL_Latin1_General_CP1_CS_AS
			,apcbk_comment				= i.apcbk_comment 
			,apcbk_show_bal_yn			= i.apcbk_show_bal_yn
			,apcbk_prompt_align_yn		= i.apcbk_prompt_align_yn
			,apcbk_chk_clr_ord_dn		= i.apcbk_chk_clr_ord_dn
			,apcbk_import_export_yn		= i.apcbk_import_export_yn
			,apcbk_export_cbk_no		= i.apcbk_export_cbk_no
			,apcbk_stmt_lock_rev_dt		= i.apcbk_stmt_lock_rev_dt
			,apcbk_gl_close_rev_dt		= i.apcbk_gl_close_rev_dt
			,apcbk_bal					= NULL
			,apcbk_next_chk_no			= NULL
			,apcbk_next_eft_no			= NULL 
			,apcbk_check_format_cs		= i.apcbk_check_format_cs
			,apcbk_laser_down_lines		= i.apcbk_laser_down_lines
			,apcbk_prtr_checks			= i.apcbk_prtr_checks
			,apcbk_auto_assign_trx_yn	= i.apcbk_auto_assign_trx_yn
			,apcbk_next_trx_no			= NULL
			,apcbk_transit_route		= NULL
			,apcbk_ach_company_id		= NULL
			,apcbk_ach_bankname			= NULL
			,apcbk_gl_cash				= dbo.fn_GetGLAccountIDFromi21ToOrigin(i.intGLAccountID)
			,apcbk_gl_ap				= NULL
			,apcbk_gl_disc				= NULL
			,apcbk_gl_wthhld			= NULL
			,apcbk_gl_curr				= 0
			,apcbk_active_yn			= CASE WHEN i.ysnActive = 1 THEN 'Y' ELSE 'N' END 
			,apcbk_bnk_no				= NULL
			,apcbk_user_id				= NULL 
			,apcbk_user_rev_dt			= 0
	FROM	inserted i 
	WHERE	ISNULL(i.strCbkNo, '') <> ''
			AND NOT EXISTS (SELECT TOP 1 1 FROM dbo.apcbkmst_legacy legacy WHERE legacy.apcbk_no COLLATE Latin1_General_CI_AS = i.strCbkNo)			
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER

EXIT_TRIGGER:
END
GO

CREATE TRIGGER trg_insert_vwCMBankAccount
ON [dbo].vwCMBankAccount
INSTEAD OF INSERT
AS
BEGIN 

SET NOCOUNT ON 

	-- Proceed in inserting the record the base table (tblCMBankAccount)			
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
			,intConcurrencyId
			,strCbkNo
	)
	OUTPUT 	inserted.intBankAccountID
	SELECT	strBankName							= i.strBankName
			,ysnActive							= i.ysnActive
			,intGLAccountID						= i.intGLAccountID
			,intCurrencyID						= i.intCurrencyID
			,intBankAccountType					= i.intBankAccountType
			,strContact							= i.strContact
			,strBankAccountNo					= i.strBankAccountNo
			,strRTN								= i.strRTN
			,strAddress							= i.strAddress
			,strZipCode							= i.strZipCode
			,strCity							= i.strCity
			,strState							= i.strState
			,strCountry							= i.strCountry
			,strPhone							= i.strPhone
			,strFax								= i.strFax
			,strWebsite							= i.strWebsite
			,strEmail							= i.strEmail
			,intCheckStartingNo					= i.intCheckStartingNo
			,intCheckEndingNo					= i.intCheckEndingNo
			,intCheckNextNo						= i.intCheckNextNo
			,ysnCheckEnableMICRPrint			= i.ysnCheckEnableMICRPrint
			,ysnCheckDefaultToBePrinted			= i.ysnCheckDefaultToBePrinted
			,intBackupCheckStartingNo			= i.intBackupCheckStartingNo
			,intBackupCheckEndingNo				= i.intBackupCheckEndingNo
			,intEFTNextNo						= i.intEFTNextNo
			,intEFTBankFileFormatID				= i.intEFTBankFileFormatID
			,strEFTCompanyID					= i.strEFTCompanyID
			,strEFTBankName						= i.strEFTBankName
			,strMICRDescription					= i.strMICRDescription
			,intMICRBankAccountSpacesCount		= i.intMICRBankAccountSpacesCount
			,intMICRBankAccountSpacesPosition	= i.intMICRBankAccountSpacesPosition
			,intMICRCheckNoSpacesCount			= i.intMICRCheckNoSpacesCount
			,intMICRCheckNoSpacesPosition		= i.intMICRCheckNoSpacesPosition
			,intMICRCheckNoLength				= i.intMICRCheckNoLength
			,intMICRCheckNoPosition				= i.intMICRCheckNoPosition
			,strMICRLeftSymbol					= i.strMICRLeftSymbol
			,strMICRRightSymbol					= i.strMICRRightSymbol
			,intCreatedUserID					= i.intCreatedUserID
			,dtmCreated							= i.dtmCreated
			,intLastModifiedUserID				= i.intLastModifiedUserID
			,dtmLastModified					= i.dtmLastModified
			,intConcurrencyId					= i.intConcurrencyId
			,strCbkNo							= i.strCbkNo
	FROM	inserted i 
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER

	-- INSERT new records for apcbkmst_legacy
	INSERT INTO apcbkmst_legacy (
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
			apcbk_no					= i.strCbkNo
			,apcbk_currency				= dbo.fn_GetCurrencyIDFromi21ToOrigin(i.intCurrencyID)
			,apcbk_password				= i.apcbk_password
			,apcbk_desc					= i.strBankName COLLATE SQL_Latin1_General_CP1_CS_AS
			,apcbk_bank_acct_no			= i.strBankAccountNo COLLATE SQL_Latin1_General_CP1_CS_AS
			,apcbk_comment				= i.apcbk_comment 
			,apcbk_show_bal_yn			= i.apcbk_show_bal_yn
			,apcbk_prompt_align_yn		= i.apcbk_prompt_align_yn
			,apcbk_chk_clr_ord_dn		= i.apcbk_chk_clr_ord_dn
			,apcbk_import_export_yn		= i.apcbk_import_export_yn
			,apcbk_export_cbk_no		= i.apcbk_export_cbk_no
			,apcbk_stmt_lock_rev_dt		= i.apcbk_stmt_lock_rev_dt
			,apcbk_gl_close_rev_dt		= i.apcbk_gl_close_rev_dt
			,apcbk_bal					= NULL
			,apcbk_next_chk_no			= NULL
			,apcbk_next_eft_no			= NULL 
			,apcbk_check_format_cs		= i.apcbk_check_format_cs
			,apcbk_laser_down_lines		= i.apcbk_laser_down_lines
			,apcbk_prtr_checks			= i.apcbk_prtr_checks
			,apcbk_auto_assign_trx_yn	= i.apcbk_auto_assign_trx_yn
			,apcbk_next_trx_no			= NULL
			,apcbk_transit_route		= NULL
			,apcbk_ach_company_id		= NULL
			,apcbk_ach_bankname			= NULL
			,apcbk_gl_cash				= dbo.fn_GetGLAccountIDFromi21ToOrigin(i.intGLAccountID)
			,apcbk_gl_ap				= NULL
			,apcbk_gl_disc				= NULL
			,apcbk_gl_wthhld			= NULL
			,apcbk_gl_curr				= 0
			,apcbk_active_yn			= CASE WHEN i.ysnActive = 1 THEN 'Y' ELSE 'N' END 
			,apcbk_bnk_no				= NULL
			,apcbk_user_id				= NULL 
			,apcbk_user_rev_dt			= 0
	FROM	inserted i
	WHERE	ISNULL(i.strCbkNo, '') <> ''
	
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER
 		
EXIT_TRIGGER: 

END
GO


CREATE TRIGGER trg_delete_vwCMBankAccount
ON [dbo].vwCMBankAccount
INSTEAD OF DELETE
AS
BEGIN 

	SET NOCOUNT ON

	------------------------------------------------------------------------------------------
	-- Validate the checkbook first before deleting the record. Prevent delete if: 
	------------------------------------------------------------------------------------------
	-- 1. ...if checkbook is used in apivcmst (Accounts Payable Invoice File)
	IF EXISTS (
		SELECT	TOP 1 1 
		FROM	deleted d INNER JOIN dbo.apivcmst legacy 
					ON d.strCbkNo = legacy.apivc_cbk_no COLLATE Latin1_General_CI_AS
		WHERE	ISNULL(d.strCbkNo, '') <> ''
	)
	BEGIN
		RAISERROR(50012, 11, 1)	-- 'Unable to delete checkbook because it is used in the A/P Invoice file.'
		GOTO EXIT_TRIGGER
	END
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER

	-- 2. ...if checkbook is used in apchkmst (Check History File)
	IF EXISTS (
		SELECT	TOP 1 1 
		FROM	deleted d INNER JOIN dbo.apchkmst legacy 
					ON d.strCbkNo = legacy.apchk_cbk_no COLLATE Latin1_General_CI_AS
		WHERE	ISNULL(d.strCbkNo, '') <> ''
	)
	BEGIN
		RAISERROR(50013, 11, 1)	-- 'Unable to delete checkbook because it is used in the Check History file.'
		GOTO EXIT_TRIGGER
	END
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER

	-- 3. ...if checkbook is used in aptrxmst (A/P Trans File)
	IF EXISTS (
		SELECT	TOP 1 1 
		FROM	deleted d INNER JOIN dbo.aptrxmst legacy 
					ON d.strCbkNo = legacy.aptrx_cbk_no COLLATE Latin1_General_CI_AS
		WHERE	ISNULL(d.strCbkNo, '') <> ''
	)
	BEGIN
		RAISERROR(50014, 11, 1)	-- 'Unable to delete checkbook because it is used in the A/P Transaction file.'
		GOTO EXIT_TRIGGER
	END
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER

	------------------------------------------------------------------------------------------
	-- Below deletes the record
	------------------------------------------------------------------------------------------
	-- Delete records from i21 bank account table. 
	DELETE	dbo.tblCMBankAccount
	FROM	dbo.tblCMBankAccount 
	WHERE	intBankAccountID IN (SELECT d.intBankAccountID FROM deleted d)
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER

	-- Delete records in legacy bank account table (apcbkmst_legacy). 
	DELETE	dbo.apcbkmst_legacy
	FROM	deleted d INNER JOIN dbo.apcbkmst_legacy legacy
				ON d.strCbkNo = legacy.apcbk_no COLLATE Latin1_General_CI_AS
	WHERE	ISNULL(d.strCbkNo, '') <> ''
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER

EXIT_TRIGGER:

END