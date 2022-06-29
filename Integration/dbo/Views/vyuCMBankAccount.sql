﻿GO
IF  (SELECT TOP 1 ysnUsed FROM #tblOriginMod WHERE strPrefix = 'AP') = 1
BEGIN
	IF EXISTS (SELECT 1 FROM sys.triggers WHERE Name = 'trg_insert_vyuCMBankAccount') DROP TRIGGER dbo.trg_insert_vyuCMBankAccount;
	IF EXISTS (SELECT 1 FROM sys.triggers WHERE Name = 'trg_delete_vyuCMBankAccount') DROP TRIGGER dbo.trg_delete_vyuCMBankAccount;
	IF EXISTS (SELECT 1 FROM sys.triggers WHERE Name = 'trg_insert_vyuCMBankAccount') DROP TRIGGER dbo.trg_insert_vyuCMBankAccount;
	IF EXISTS (select 1 FROM sys.views where name = 'vyuCMBankAccount') DROP VIEW dbo.vyuCMBankAccount;


	EXEC('CREATE VIEW [dbo].vyuCMBankAccount
		WITH SCHEMABINDING
		AS 

		SELECT	i21.intBankAccountId
				,i21.intBankId
				,strBankName = (SELECT strBankName FROM dbo.tblCMBank WHERE intBankId = i21.intBankId)
				,i21.ysnActive
				,i21.intGLAccountId
				,strGLAccountId = (SELECT strAccountId FROM dbo.tblGLAccount WHERE intAccountId = i21.intGLAccountId)
				,i21.intCurrencyId
				,strCurrency = (SELECT strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = i21.intCurrencyId)
				,i21.intBankAccountType
				,i21.strContact
				,i21.strBankAccountHolder
				,ISNULL(dbo.fnAESDecryptASym(i21.strBankAccountNo),strBankAccountNo) COLLATE Latin1_General_CI_AS AS strBankAccountNo
				,ISNULL(dbo.fnAESDecryptASym(i21.strRTN),strRTN) COLLATE Latin1_General_CI_AS AS strRTN
				,i21.strAddress
				,i21.strZipCode
				,i21.strCity
				,i21.strState
				,i21.strCountry
				,i21.strPhone
				,i21.strFax
				,i21.strWebsite
				,i21.strEmail
				,i21.strIBAN
				,i21.strSWIFT
				,i21.intCheckStartingNo
				,i21.intCheckEndingNo
				,i21.intCheckNextNo
				,i21.intCheckNoLength
				,i21.ysnCheckEnableMICRPrint
				,i21.ysnCheckDefaultToBePrinted
				,i21.intBackupCheckStartingNo
				,i21.intBackupCheckEndingNo
				,i21.intEFTNextNo
				,i21.intBankStatementImportId
				,strBankStatementFormat = (SELECT strName FROM dbo.tblCMBankFileFormat WHERE intBankFileFormatId = i21.intBankStatementImportId)
				,i21.intEFTBankFileFormatId
				,i21.intEFTARFileFormatId
				,i21.intEFTPRFileFormatId
				,strACHFormat = (SELECT strName FROM dbo.tblCMBankFileFormat WHERE intBankFileFormatId = i21.intEFTBankFileFormatId)
				,strEFTARFormat = (SELECT strName FROM dbo.tblCMBankFileFormat WHERE intBankFileFormatId = i21.intEFTARFileFormatId)
				,strEFTPRFormat = (SELECT strName FROM dbo.tblCMBankFileFormat WHERE intBankFileFormatId = i21.intEFTPRFileFormatId)
				,i21.intPositivePayBankFileFormatId
				,strPositivePayFormat = (SELECT strName FROM dbo.tblCMBankFileFormat WHERE intBankFileFormatId = i21.intPositivePayBankFileFormatId)
				,i21.strEFTCompanyId
				,i21.strEFTBankName
				,i21.strMICRDescription
				,ISNULL(dbo.fnAESDecryptASym(i21.strMICRRoutingNo),strMICRRoutingNo) COLLATE Latin1_General_CI_AS AS strMICRRoutingNo
				,ISNULL(dbo.fnAESDecryptASym(i21.strMICRBankAccountNo),strMICRBankAccountNo) COLLATE Latin1_General_CI_AS AS strMICRBankAccountNo
				,i21.strMICRRoutingPrefix
				,i21.strMICRRoutingSuffix
				,i21.strMICRBankAccountPrefix
				,i21.strMICRBankAccountSuffix
				,i21.intMICRBankAccountSpacesCount
				,i21.intMICRBankAccountSpacesPosition
				,i21.intMICRCheckNoSpacesCount
				,i21.intMICRCheckNoSpacesPosition
				,i21.intMICRCheckNoLength
				,i21.intMICRCheckNoPosition
				,i21.strMICRLeftSymbol
				,i21.strMICRRightSymbol
				,i21.strMICRFinancialInstitutionPrefix
				,i21.strMICRFinancialInstitution
				,i21.strMICRFinancialInstitutionSuffix
				,i21.intMICRFinancialInstitutionSpacesCount
				,i21.intMICRFinancialInstitutionSpacesPosition
				,i21.strMICRDesignationPrefix
				,i21.strMICRDesignation
				,i21.strMICRDesignationSuffix
				,i21.intMICRDesignationSpacesCount
				,i21.intMICRDesignationSpacesPosition
				,i21.strFractionalRoutingNumber
				,i21.strUserDefineMessage
				,i21.strSignatureLineCaption
				,i21.ysnShowTwoSignatureLine
				,i21.dblGreaterThanAmount
				,i21.ysnShowFirstSignature
				,i21.dblFirstAmountIsOver
				,i21.intFirstUserId
				,strFirstUserName = (SELECT strUserName FROM dbo.tblSMUserSecurity WHERE intEntityId = i21.intFirstUserId)
				,i21.intFirstSignatureId
				,strFirstSignatureName = (SELECT strName FROM dbo.tblSMSignature WHERE intSignatureId = i21.intFirstSignatureId)
				,blbFirstSignatureDetail = (SELECT blbDetail FROM dbo.tblSMSignature WHERE intSignatureId = i21.intFirstSignatureId)
				,i21.ysnShowSecondSignature
				,i21.dblSecondAmountIsOver
				,i21.intSecondUserId
				,strSecondUserName = (SELECT strUserName FROM dbo.tblSMUserSecurity WHERE intEntityId = i21.intSecondUserId)
				,i21.intSecondSignatureId
				,strSecondSignatureName = (SELECT strName FROM dbo.tblSMSignature WHERE intSignatureId = i21.intSecondSignatureId)
				,blbSecondSignatureDetail = (SELECT blbDetail FROM dbo.tblSMSignature WHERE intSignatureId = i21.intSecondSignatureId)
				,i21.intCreatedUserId
				,i21.dtmCreated
				,i21.intLastModifiedUserId
				,i21.dtmLastModified
				,i21.strCbkNo
				,i21.intConcurrencyId
				,i21.intPayToDown
				,i21.intResponsibleEntityId
				,strResponsibleEntity = E.strName
				-- The following fields are from the origin system		
				,apcbk_comment = origin.apcbk_comment COLLATE Latin1_General_CI_AS			-- CHAR (30) 
				,apcbk_password =  ISNULL(origin.apcbk_password, '''') COLLATE Latin1_General_CI_AS	-- CHAR (16)
				,apcbk_show_bal_yn = origin.apcbk_show_bal_yn COLLATE Latin1_General_CI_AS	-- Y/N
				,apcbk_prompt_align_yn = origin.apcbk_prompt_align_yn  COLLATE Latin1_General_CI_AS -- Y/N
				,apcbk_chk_clr_ord_dn = origin.apcbk_chk_clr_ord_dn  COLLATE Latin1_General_CI_AS -- Y/N
				,apcbk_import_export_yn = origin.apcbk_import_export_yn  COLLATE Latin1_General_CI_AS -- Y/N
				,apcbk_export_cbk_no = origin.apcbk_export_cbk_no COLLATE Latin1_General_CI_AS -- CHAR (2)
				,origin.apcbk_stmt_lock_rev_dt		-- INT yyyymmdd
				,origin.apcbk_gl_close_rev_dt		-- INT yyyymmdd
				,apcbk_check_format_cs = origin.apcbk_check_format_cs COLLATE Latin1_General_CI_AS -- CHAR (2)
				,origin.apcbk_laser_down_lines		-- INT
				,apcbk_prtr_checks = origin.apcbk_prtr_checks COLLATE Latin1_General_CI_AS -- CHAR (80)
				,apcbk_auto_assign_trx_yn = origin.apcbk_auto_assign_trx_yn COLLATE Latin1_General_CI_AS -- Y/N

				-- convert value suitable for checkbox for apcbk_show_bal_yn,apcbk_import_export_yn,apcbk_prompt_align_yn,apcbk_auto_assign_trx_yn
				,cast (case when ISNULL(origin.apcbk_show_bal_yn,''N'') = ''N'' THEN 0 ELSE 1 end as bit) ysnShowRunningBalance
				,cast (case when ISNULL(origin.apcbk_prompt_align_yn,''N'') = ''N'' THEN 0 ELSE 1 end as bit) ysnPrintAlignPattern
				,cast (case when ISNULL(origin.apcbk_import_export_yn,''N'') = ''N'' THEN 0 ELSE 1 end as bit) ysnImportExportTrans
				,cast (case when ISNULL(origin.apcbk_auto_assign_trx_yn,''N'') = ''N'' THEN 0 ELSE 1 end as bit) ysnAutoAssignOtherTrans

				-- This is used to check if the bank account have a transaction
				,ysnHasTransaction = CAST(ISNULL((select TOP 1 1 from dbo.tblCMBankTransaction where intBankAccountId = i21.intBankAccountId),0) AS bit)
				-- This is used to check if EFT No has been used
				,ysnEFTNoUsed = CAST(ISNULL(
						(SELECT TOP 1 1 FROM (
						SELECT strTransactionId FROM  dbo.tblCMBankTransaction WHERE intBankAccountId = i21.intBankAccountId AND intBankTransactionTypeId IN (22,23,122,123) AND strReferenceNo <> '''' AND intBankFileAuditId IS NOT NULL
						UNION ALL SELECT strSourceTransactionId FROM dbo.tblCMUndepositedFund WHERE intBankAccountId = i21.intBankAccountId AND (strReferenceNo <> '''' OR strReferenceNo IS NOT NULL) AND intBankFileAuditId IS NOT NULL
						) tbl),0) AS bit)
		FROM	dbo.tblCMBankAccount i21 LEFT JOIN dbo.apcbkmst_origin origin
					ON i21.strCbkNo = origin.apcbk_no COLLATE Latin1_General_CI_AS
					LEFT JOIN dbo.tblEMEntity E on E.intEntityId = i21.intResponsibleEntityId
					')
		

	EXEC('
		CREATE TRIGGER trg_delete_vyuCMBankAccount
		ON [dbo].vyuCMBankAccount
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
				FROM	deleted d INNER JOIN dbo.apivcmst origin 
							ON d.strCbkNo = origin.apivc_cbk_no COLLATE Latin1_General_CI_AS
				WHERE	ISNULL(d.strCbkNo, '''') <> ''''
			)
			BEGIN
				RAISERROR(''Unable to delete checkbook because it is used in the A/P Invoice file.'', 11, 1)	-- ''Unable to delete checkbook because it is used in the A/P Invoice file.''
				GOTO EXIT_TRIGGER
			END
			IF @@ERROR <> 0 GOTO EXIT_TRIGGER

			-- 2. ...if checkbook is used in apchkmst (Check History File)
			IF EXISTS (
				SELECT	TOP 1 1 
				FROM	deleted d INNER JOIN dbo.apchkmst origin 
							ON d.strCbkNo = origin.apchk_cbk_no COLLATE Latin1_General_CI_AS
				WHERE	ISNULL(d.strCbkNo, '''') <> ''''
			)
			BEGIN
				RAISERROR(''Unable to delete checkbook because it is used in the Check History file.'', 11, 1)	-- ''Unable to delete checkbook because it is used in the Check History file.''
				GOTO EXIT_TRIGGER
			END
			IF @@ERROR <> 0 GOTO EXIT_TRIGGER

			-- 3. ...if checkbook is used in aptrxmst (A/P Trans File)
			IF EXISTS (
				SELECT	TOP 1 1 
				FROM	deleted d INNER JOIN dbo.aptrxmst origin 
							ON d.strCbkNo = origin.aptrx_cbk_no COLLATE Latin1_General_CI_AS
				WHERE	ISNULL(d.strCbkNo, '''') <> ''''
			)
			BEGIN
				RAISERROR(''Unable to delete checkbook because it is used in the A/P Transaction file.'', 11, 1)	-- ''Unable to delete checkbook because it is used in the A/P Transaction file.''
				GOTO EXIT_TRIGGER
			END
			IF @@ERROR <> 0 GOTO EXIT_TRIGGER

			------------------------------------------------------------------------------------------
			-- Below deletes the record
			------------------------------------------------------------------------------------------
			-- Delete records from i21 bank account table. 
			DELETE	dbo.tblCMBankAccount
			FROM	dbo.tblCMBankAccount 
			WHERE	intBankAccountId IN (SELECT d.intBankAccountId FROM deleted d)
			IF @@ERROR <> 0 GOTO EXIT_TRIGGER

			-- Delete records in origin bank account table (apcbkmst_origin). 
			DELETE	dbo.apcbkmst_origin
			FROM	deleted d INNER JOIN dbo.apcbkmst_origin origin
						ON d.strCbkNo = origin.apcbk_no COLLATE Latin1_General_CI_AS
			WHERE	ISNULL(d.strCbkNo, '''') <> ''''
			IF @@ERROR <> 0 GOTO EXIT_TRIGGER

		EXIT_TRIGGER:

		END
		')

	EXEC('
		CREATE TRIGGER trg_insert_vyuCMBankAccount
		ON [dbo].vyuCMBankAccount
		INSTEAD OF INSERT
		AS
		BEGIN 

		SET NOCOUNT ON 

			-- Check for duplicate values in apcbk_no
			IF EXISTS (
				SELECT	TOP 1 1 
				FROM	dbo.apcbkmst_origin o
				WHERE	o.apcbk_no COLLATE Latin1_General_CI_AS IN (SELECT DISTINCT i.strCbkNo FROM inserted i)				
			)
			BEGIN 
				-- The record being created already exists in origin. Remove the duplicate record from origin or do a conversion.
				RAISERROR(''The record being created already exists in origin. Remove the duplicate record from origin or do a conversion.'', 11, 1)
				GOTO EXIT_TRIGGER
			END		

			--For Encryption and Decryption
			OPEN SYMMETRIC KEY i21EncryptionSymKeyByASym
			DECRYPTION BY ASYMMETRIC KEY i21EncryptionASymKeyPwd 
			WITH PASSWORD = ''neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY=''

			-- Proceed in inserting the record the base table (tblCMBankAccount)			
			INSERT INTO tblCMBankAccount (
					intBankId
					,ysnActive
					,intGLAccountId
					,intCurrencyId
					,intBankAccountType
					,strContact
					,strBankAccountHolder
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
					,strIBAN
					,strSWIFT
					,intCheckStartingNo
					,intCheckEndingNo
					,intCheckNextNo
					,intCheckNoLength
					,ysnCheckEnableMICRPrint
					,ysnCheckDefaultToBePrinted
					,intBackupCheckStartingNo
					,intBackupCheckEndingNo
					,intEFTNextNo
					,intBankStatementImportId
					,intEFTBankFileFormatId
					,intEFTARFileFormatId
					,intEFTPRFileFormatId
					,intPositivePayBankFileFormatId
					,strEFTCompanyId
					,strEFTBankName
					,strMICRDescription
					,strMICRRoutingNo
					,strMICRBankAccountNo
					,strMICRRoutingPrefix
					,strMICRRoutingSuffix
					,strMICRBankAccountPrefix
					,strMICRBankAccountSuffix
					,intMICRBankAccountSpacesCount
					,intMICRBankAccountSpacesPosition
					,intMICRCheckNoSpacesCount
					,intMICRCheckNoSpacesPosition
					,intMICRCheckNoLength
					,intMICRCheckNoPosition
					,strMICRLeftSymbol
					,strMICRRightSymbol
					,strMICRFinancialInstitutionPrefix
					,strMICRFinancialInstitution
					,strMICRFinancialInstitutionSuffix
					,intMICRFinancialInstitutionSpacesCount
					,intMICRFinancialInstitutionSpacesPosition
					,strMICRDesignationPrefix
					,strMICRDesignation
					,strMICRDesignationSuffix
					,intMICRDesignationSpacesCount
					,intMICRDesignationSpacesPosition
					,strFractionalRoutingNumber
					,strUserDefineMessage	
					,strSignatureLineCaption
					,ysnShowTwoSignatureLine
					,dblGreaterThanAmount
					,ysnShowFirstSignature
					,dblFirstAmountIsOver
					,intFirstUserId						
					,intFirstSignatureId				
					,ysnShowSecondSignature				
					,dblSecondAmountIsOver				
					,intSecondUserId					
					,intSecondSignatureId				
					,intCreatedUserId
					,dtmCreated
					,intLastModifiedUserId
					,dtmLastModified
					,intConcurrencyId
					,strCbkNo
					,intPayToDown
					,intResponsibleEntityId
			)
			OUTPUT 	inserted.intBankAccountId
			SELECT	intBankId							= i.intBankId
					,ysnActive							= i.ysnActive
					,intGLAccountId						= i.intGLAccountId
					,intCurrencyId						= i.intCurrencyId
					,intBankAccountType					= i.intBankAccountType
					,strContact							= i.strContact
					,strBankAccountHolder				= i.strBankAccountHolder
					,strBankAccountNo					= [dbo].fnAESEncryptASym(i.strBankAccountNo)
					,strRTN								= [dbo].fnAESEncryptASym(i.strRTN)
					,strAddress							= i.strAddress
					,strZipCode							= i.strZipCode
					,strCity							= i.strCity
					,strState							= i.strState
					,strCountry							= i.strCountry
					,strPhone							= i.strPhone
					,strFax								= i.strFax
					,strWebsite							= i.strWebsite
					,strEmail							= i.strEmail
					,strIBAN							= i.strIBAN
					,strSWIFT							= i.strSWIFT
					,intCheckStartingNo					= i.intCheckStartingNo
					,intCheckEndingNo					= i.intCheckEndingNo
					,intCheckNextNo						= i.intCheckNextNo
					,intCheckNoLength					= i.intCheckNoLength
					,ysnCheckEnableMICRPrint			= i.ysnCheckEnableMICRPrint
					,ysnCheckDefaultToBePrinted			= i.ysnCheckDefaultToBePrinted
					,intBackupCheckStartingNo			= i.intBackupCheckStartingNo
					,intBackupCheckEndingNo				= i.intBackupCheckEndingNo
					,intEFTNextNo						= i.intEFTNextNo
					,intBankStatementImportId			= i.intBankStatementImportId
					,intEFTBankFileFormatId				= i.intEFTBankFileFormatId
					,intEFTARFileFormatId				= i.intEFTARFileFormatId
					,intEFTPRFileFormatId				= i.intEFTPRFileFormatId
					,intPositivePayBankFileFormatId		= i.intPositivePayBankFileFormatId
					,strEFTCompanyId					= i.strEFTCompanyId
					,strEFTBankName						= i.strEFTBankName
					,strMICRDescription					= i.strMICRDescription
					,strMICRRoutingNo					= [dbo].fnAESEncryptASym(i.strMICRRoutingNo)
					,strMICRBankAccountNo				= [dbo].fnAESEncryptASym(i.strMICRBankAccountNo)
					,strMICRRoutingPrefix				= i.strMICRRoutingPrefix
					,strMICRRoutingSuffix				= i.strMICRRoutingSuffix
					,strMICRBankAccountPrefix			= i.strMICRBankAccountPrefix
					,strMICRBankAccountSuffix			= i.strMICRBankAccountSuffix
					,intMICRBankAccountSpacesCount		= i.intMICRBankAccountSpacesCount
					,intMICRBankAccountSpacesPosition	= i.intMICRBankAccountSpacesPosition
					,intMICRCheckNoSpacesCount			= i.intMICRCheckNoSpacesCount
					,intMICRCheckNoSpacesPosition		= i.intMICRCheckNoSpacesPosition
					,intMICRCheckNoLength				= i.intMICRCheckNoLength
					,intMICRCheckNoPosition				= i.intMICRCheckNoPosition
					,strMICRLeftSymbol					= i.strMICRLeftSymbol
					,strMICRRightSymbol					= i.strMICRRightSymbol
					,strMICRFinancialInstitutionPrefix	= i.strMICRFinancialInstitutionPrefix
					,strMICRFinancialInstitution		= i.strMICRFinancialInstitution
					,strMICRFinancialInstitutionSuffix	= i.strMICRFinancialInstitutionSuffix
					,intMICRFinancialInstitutionSpacesCount = i.intMICRFinancialInstitutionSpacesCount
					,intMICRFinancialInstitutionSpacesPosition = i.intMICRFinancialInstitutionSpacesPosition
					,strMICRDesignationPrefix			= i.strMICRDesignationPrefix
					,strMICRDesignation					= i.strMICRDesignation
					,strMICRDesignationSuffix			= i.strMICRDesignationSuffix
					,intMICRDesignationSpacesCount		= i.intMICRDesignationSpacesCount
					,intMICRDesignationSpacesPosition	= i.intMICRDesignationSpacesPosition
					,strFractionalRoutingNumber			= i.strFractionalRoutingNumber
					,strUserDefineMessage				= i.strUserDefineMessage
					,strSignatureLineCaption			= i.strSignatureLineCaption
					,ysnShowTwoSignatureLine			= i.ysnShowTwoSignatureLine
					,dblGreaterThanAmount				= i.dblGreaterThanAmount
					,ysnShowFirstSignature				= i.ysnShowFirstSignature
					,dblFirstAmountIsOver				= i.dblFirstAmountIsOver
					,intFirstUserId						= i.intFirstUserId
					,intFirstSignatureId				= i.intFirstSignatureId
					,ysnShowSecondSignature				= i.ysnShowSecondSignature
					,dblSecondAmountIsOver				= i.dblSecondAmountIsOver
					,intSecondUserId					= i.intSecondUserId
					,intSecondSignatureId				= i.intSecondSignatureId
					,intCreatedUserId					= i.intCreatedUserId
					,dtmCreated							= i.dtmCreated
					,intLastModifiedUserId				= i.intLastModifiedUserId
					,dtmLastModified					= i.dtmLastModified
					,intConcurrencyId					= i.intConcurrencyId
					,strCbkNo							= i.strCbkNo
					,intPayToDown						= i.intPayToDown
					,intResponsibleEntityId				= i.intResponsibleEntityId
			FROM	inserted i 

			CLOSE SYMMETRIC KEY i21EncryptionSymKeyByASym
			IF @@ERROR <> 0 GOTO EXIT_TRIGGER

			-- INSERT new records for apcbkmst_origin
			INSERT INTO apcbkmst_origin (
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
					,apcbk_currency				= dbo.fnGetCurrencyIdFromi21ToOrigin(i.intCurrencyId)
					,apcbk_password				= i.apcbk_password
					,apcbk_desc					= LEFT(bank.strBankName COLLATE SQL_Latin1_General_CP1_CS_AS,30)
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
					,apcbk_next_chk_no			= i.intCheckNextNo
					,apcbk_next_eft_no			= NULL 
					,apcbk_check_format_cs		= i.apcbk_check_format_cs
					,apcbk_laser_down_lines		= i.apcbk_laser_down_lines
					,apcbk_prtr_checks			= i.apcbk_prtr_checks
					,apcbk_auto_assign_trx_yn	= i.apcbk_auto_assign_trx_yn
					,apcbk_next_trx_no			= NULL
					,apcbk_transit_route		= NULL
					,apcbk_ach_company_id		= NULL
					,apcbk_ach_bankname			= NULL
					,apcbk_gl_cash				= dbo.fnGetGLAccountIdFromi21ToOrigin(i.intGLAccountId)
					,apcbk_gl_ap				= (SELECT TOP 1 apcbk_gl_ap FROM apcbkmst)
					,apcbk_gl_disc				= (SELECT TOP 1 apcbk_gl_disc FROM apcbkmst)
					,apcbk_gl_wthhld			= (SELECT TOP 1 apcbk_gl_wthhld FROM apcbkmst)
					,apcbk_gl_curr				= (SELECT TOP 1 apcbk_gl_curr FROM apcbkmst)
					,apcbk_active_yn			= CASE WHEN i.ysnActive = 1 THEN ''Y'' ELSE ''N'' END 
					,apcbk_bnk_no				= NULL
					,apcbk_user_id				= dbo.fnConverti21UserIdtoOrigin(i.intCreatedUserId)
					,apcbk_user_rev_dt			= CONVERT(VARCHAR(10), i.dtmLastModified, 112)
			FROM	inserted i INNER JOIN dbo.tblCMBank bank
						ON i.intBankId = bank.intBankId
			WHERE	ISNULL(i.strCbkNo, '''') <> ''''
			
			IF @@ERROR <> 0 GOTO EXIT_TRIGGER
		 		
		EXIT_TRIGGER: 


		END
		')

	EXEC('
		CREATE TRIGGER trg_update_vyuCMBankAccount
		ON [dbo].vyuCMBankAccount
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
							WHERE	t.intBankAccountId <> i.intBankAccountId 
									AND t.strCbkNo = i.strCbkNo 
									AND ISNULL(i.strCbkNo, '''') <> ''''
						)
			)
			BEGIN 
				RAISERROR(''Duplicate checkbook id found.'', 11, 1)	-- ''Duplicate checkbook id found.''
				GOTO EXIT_TRIGGER
			END 

			--For Encryption and Decryption
			OPEN SYMMETRIC KEY i21EncryptionSymKeyByASym
			DECRYPTION BY ASYMMETRIC KEY i21EncryptionASymKeyPwd 
			WITH PASSWORD = ''neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY=''

			-- Proceed in updating the base table (tblCMBankAccount)				
			UPDATE	dbo.tblCMBankAccount 
			SET		intBankId							= i.intBankId
					,ysnActive							= i.ysnActive
					,intGLAccountId						= i.intGLAccountId
					,intCurrencyId						= i.intCurrencyId
					,intBankAccountType					= i.intBankAccountType
					,strContact							= i.strContact
					,strBankAccountHolder				= i.strBankAccountHolder
					,strBankAccountNo                    = CASE WHEN i.strBankAccountNo = B.strBankAccountNo THEN i.strBankAccountNo ELSE [dbo].fnAESEncryptASym(i.strBankAccountNo) END
					,strRTN                                = CASE WHEN i.strRTN = B.strRTN THEN i.strRTN ELSE [dbo].fnAESEncryptASym(i.strRTN) END
					,strAddress							= i.strAddress
					,strZipCode							= i.strZipCode
					,strCity							= i.strCity
					,strState							= i.strState
					,strCountry							= i.strCountry
					,strPhone							= i.strPhone
					,strFax								= i.strFax
					,strWebsite							= i.strWebsite
					,strEmail							= i.strEmail
					,strIBAN							= i.strIBAN
					,strSWIFT							= i.strSWIFT
					,intCheckStartingNo					= i.intCheckStartingNo
					,intCheckEndingNo					= i.intCheckEndingNo
					,intCheckNextNo						= i.intCheckNextNo
					,intCheckNoLength					= i.intCheckNoLength
					,ysnCheckEnableMICRPrint			= i.ysnCheckEnableMICRPrint
					,ysnCheckDefaultToBePrinted			= i.ysnCheckDefaultToBePrinted
					,intBackupCheckStartingNo			= i.intBackupCheckStartingNo
					,intBackupCheckEndingNo				= i.intBackupCheckEndingNo
					,intEFTNextNo						= i.intEFTNextNo
					,intBankStatementImportId			= i.intBankStatementImportId
					,intEFTBankFileFormatId				= i.intEFTBankFileFormatId
					,intEFTARFileFormatId				= i.intEFTARFileFormatId
					,intEFTPRFileFormatId				= i.intEFTPRFileFormatId
					,intPositivePayBankFileFormatId		= i.intPositivePayBankFileFormatId
					,strEFTCompanyId					= i.strEFTCompanyId
					,strEFTBankName						= i.strEFTBankName
					,strMICRDescription					= i.strMICRDescription
					,strMICRRoutingNo                    = CASE WHEN i.strMICRRoutingNo = B.strMICRRoutingNo THEN i.strMICRRoutingNo ELSE [dbo].fnAESEncryptASym(i.strMICRRoutingNo) END
					,strMICRBankAccountNo                = CASE WHEN i.strMICRBankAccountNo = B.strMICRBankAccountNo THEN i.strMICRBankAccountNo ELSE [dbo].fnAESEncryptASym(i.strMICRBankAccountNo) END
					,strMICRRoutingPrefix				= i.strMICRRoutingPrefix
					,strMICRRoutingSuffix				= i.strMICRRoutingSuffix
					,strMICRBankAccountPrefix			= i.strMICRBankAccountPrefix
					,strMICRBankAccountSuffix			= i.strMICRBankAccountSuffix
					,intMICRBankAccountSpacesCount		= i.intMICRBankAccountSpacesCount
					,intMICRBankAccountSpacesPosition	= i.intMICRBankAccountSpacesPosition
					,intMICRCheckNoSpacesCount			= i.intMICRCheckNoSpacesCount
					,intMICRCheckNoSpacesPosition		= i.intMICRCheckNoSpacesPosition
					,intMICRCheckNoLength				= i.intMICRCheckNoLength
					,intMICRCheckNoPosition				= i.intMICRCheckNoPosition
					,strMICRLeftSymbol					= i.strMICRLeftSymbol
					,strMICRRightSymbol					= i.strMICRRightSymbol
					,strMICRFinancialInstitutionPrefix	= i.strMICRFinancialInstitutionPrefix
					,strMICRFinancialInstitution		= i.strMICRFinancialInstitution
					,strMICRFinancialInstitutionSuffix	= i.strMICRFinancialInstitutionSuffix
					,intMICRFinancialInstitutionSpacesCount = i.intMICRFinancialInstitutionSpacesCount
					,intMICRFinancialInstitutionSpacesPosition = i.intMICRFinancialInstitutionSpacesPosition
					,strMICRDesignationPrefix			= i.strMICRDesignationPrefix
					,strMICRDesignation					= i.strMICRDesignation
					,strMICRDesignationSuffix			= i.strMICRDesignationSuffix
					,intMICRDesignationSpacesCount		= i.intMICRDesignationSpacesCount
					,intMICRDesignationSpacesPosition	= i.intMICRDesignationSpacesPosition
					,strFractionalRoutingNumber			= i.strFractionalRoutingNumber
					,strUserDefineMessage				= i.strUserDefineMessage
					,strSignatureLineCaption			= i.strSignatureLineCaption
					,ysnShowTwoSignatureLine			= i.ysnShowTwoSignatureLine
					,dblGreaterThanAmount				= i.dblGreaterThanAmount
					,ysnShowFirstSignature				= i.ysnShowFirstSignature
					,dblFirstAmountIsOver				= i.dblFirstAmountIsOver
					,intFirstUserId						= i.intFirstUserId
					,intFirstSignatureId				= i.intFirstSignatureId
					,ysnShowSecondSignature				= i.ysnShowSecondSignature
					,dblSecondAmountIsOver				= i.dblSecondAmountIsOver
					,intSecondUserId					= i.intSecondUserId
					,intSecondSignatureId				= i.intSecondSignatureId
					,intCreatedUserId					= i.intCreatedUserId
					,dtmCreated							= i.dtmCreated
					,intLastModifiedUserId				= i.intLastModifiedUserId
					,dtmLastModified					= i.dtmLastModified
					,intConcurrencyId					= i.intConcurrencyId
					,strCbkNo							= i.strCbkNo
					,intPayToDown						= i.intPayToDown
					,intResponsibleEntityId				= i.intResponsibleEntityId
			FROM	inserted i INNER JOIN dbo.tblCMBankAccount B
						ON i.intBankAccountId = B.intBankAccountId

			CLOSE SYMMETRIC KEY i21EncryptionSymKeyByASym
			IF @@ERROR <> 0 GOTO EXIT_TRIGGER
			
			-- UPDATE modified record for apcbkmst_origin
			UPDATE	dbo.apcbkmst_origin 
			SET		apcbk_no					= i.strCbkNo
					,apcbk_currency				= ISNULL(dbo.fnGetCurrencyIdFromi21ToOrigin(i.intCurrencyId),apcbk_currency)
					,apcbk_password				= i.apcbk_password
					--,apcbk_desc					= LEFT(bank.strBankName COLLATE SQL_Latin1_General_CP1_CS_AS,30)
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
					,apcbk_next_chk_no			= i.intCheckNextNo
					--,apcbk_next_eft_no		= NULL 
					,apcbk_check_format_cs		= i.apcbk_check_format_cs
					,apcbk_laser_down_lines		= i.apcbk_laser_down_lines
					,apcbk_prtr_checks			= i.apcbk_prtr_checks
					,apcbk_auto_assign_trx_yn	= i.apcbk_auto_assign_trx_yn
					--,apcbk_next_trx_no		= NULL
					--,apcbk_transit_route		= NULL
					--,apcbk_ach_company_id		= NULL
					--,apcbk_ach_bankname		= NULL
					,apcbk_gl_cash				= dbo.fnGetGLAccountIdFromi21ToOrigin(i.intGLAccountId)
					--,apcbk_gl_ap				= NULL
					--,apcbk_gl_disc			= NULL
					--,apcbk_gl_wthhld			= NULL
					--,apcbk_gl_curr			= 0
					,apcbk_active_yn			= CASE WHEN i.ysnActive = 1 THEN ''Y'' ELSE ''N'' END 
					--,apcbk_bnk_no				= NULL
					,apcbk_user_id				= dbo.fnConverti21UserIdtoOrigin(i.intLastModifiedUserId)
					,apcbk_user_rev_dt			= CONVERT(VARCHAR(10), i.dtmLastModified, 112)
			FROM	inserted i INNER JOIN deleted d
						ON i.intBankAccountId = d.intBankAccountId
					INNER JOIN dbo.apcbkmst_origin origin
						ON d.strCbkNo = origin.apcbk_no COLLATE Latin1_General_CI_AS
					INNER JOIN dbo.tblCMBank bank
						ON i.intBankId = bank.intBankId
			WHERE	ISNULL(i.strCbkNo, '''') <> ''''
					AND ISNULL(d.strCbkNo, '''') <> ''''
							
			IF @@ERROR <> 0 GOTO EXIT_TRIGGER			

			-- INSERT new records for apcbkmst_origin (if it does not exists)
			INSERT INTO apcbkmst_origin (
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
					,apcbk_currency				= dbo.fnGetCurrencyIdFromi21ToOrigin(i.intCurrencyId)
					,apcbk_password				= i.apcbk_password
					,apcbk_desc					= LEFT(bank.strBankName COLLATE SQL_Latin1_General_CP1_CS_AS,30)
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
					,apcbk_next_chk_no			= i.intCheckNextNo
					,apcbk_next_eft_no			= NULL 
					,apcbk_check_format_cs		= i.apcbk_check_format_cs
					,apcbk_laser_down_lines		= i.apcbk_laser_down_lines
					,apcbk_prtr_checks			= i.apcbk_prtr_checks
					,apcbk_auto_assign_trx_yn	= i.apcbk_auto_assign_trx_yn
					,apcbk_next_trx_no			= NULL
					,apcbk_transit_route		= NULL
					,apcbk_ach_company_id		= NULL
					,apcbk_ach_bankname			= NULL
					,apcbk_gl_cash				= dbo.fnGetGLAccountIdFromi21ToOrigin(i.intGLAccountId)
					,apcbk_gl_ap				= (SELECT TOP 1 apcbk_gl_ap FROM apcbkmst)
					,apcbk_gl_disc				= (SELECT TOP 1 apcbk_gl_disc FROM apcbkmst)
					,apcbk_gl_wthhld			= (SELECT TOP 1 apcbk_gl_wthhld FROM apcbkmst)
					,apcbk_gl_curr				= (SELECT TOP 1 apcbk_gl_curr FROM apcbkmst)
					,apcbk_active_yn			= CASE WHEN i.ysnActive = 1 THEN ''Y'' ELSE ''N'' END 
					,apcbk_bnk_no				= NULL
					,apcbk_user_id				= dbo.fnConverti21UserIdtoOrigin(i.intLastModifiedUserId)
					,apcbk_user_rev_dt			= CONVERT(VARCHAR(10), i.dtmLastModified, 112)
			FROM	inserted i INNER JOIN dbo.tblCMBank bank
						ON i.intBankId = bank.intBankId
			WHERE	ISNULL(i.strCbkNo, '''') <> ''''
					AND NOT EXISTS (SELECT TOP 1 1 FROM dbo.apcbkmst_origin origin WHERE origin.apcbk_no COLLATE Latin1_General_CI_AS = i.strCbkNo)			
			IF @@ERROR <> 0 GOTO EXIT_TRIGGER

		EXIT_TRIGGER:

		END
		')


END
GO