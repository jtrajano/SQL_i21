-- Create a stub view that can be used if the Origin Integration is not established. 

CREATE VIEW [dbo].vyuCMBankAccount
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
		,strACHFormat = (SELECT strName FROM dbo.tblCMBankFileFormat WHERE intBankFileFormatId = i21.intEFTBankFileFormatId)
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
		,i21.intCreatedUserId
		,i21.dtmCreated
		,i21.intLastModifiedUserId
		,i21.dtmLastModified
		,i21.strCbkNo
		,i21.intConcurrencyId
		-- The following fields are from the origin system		
		,apcbk_comment = CAST(NULL AS NVARCHAR(30))	-- CHAR (30)
		,apcbk_password = CAST(NULL AS NVARCHAR(16))	-- CHAR (16)
		,apcbk_show_bal_yn = CAST(NULL AS NVARCHAR(1))	-- Y/N
		,apcbk_prompt_align_yn	= CAST(NULL AS NVARCHAR(1))	-- Y/N
		,apcbk_chk_clr_ord_dn	= CAST(NULL AS NVARCHAR(1))	-- Y/N
		,apcbk_import_export_yn	= CAST(NULL AS NVARCHAR(1))	-- Y/N
		,apcbk_export_cbk_no	= CAST(NULL AS NVARCHAR(2))	-- CHAR (2)
		,apcbk_stmt_lock_rev_dt	= CAST(NULL AS INT)	-- INT yyyymmdd
		,apcbk_gl_close_rev_dt	= CAST(NULL AS INT)	-- INT yyyymmdd
		,apcbk_check_format_cs	= CAST(NULL AS NVARCHAR(2))	-- CHAR (2)
		,apcbk_laser_down_lines	= CAST(NULL AS INT)	-- INT
		,apcbk_prtr_checks	= CAST(NULL AS NVARCHAR(80))	-- CHAR (80)
		,apcbk_auto_assign_trx_yn	= CAST(NULL AS NVARCHAR(1))	-- Y/N
		-- This is used to check if the bank account have a transaction
		,ysnHasTransaction = CAST(ISNULL((select TOP 1 1 from  dbo.tblCMBankTransaction where intBankAccountId = i21.intBankAccountId),0) AS bit)
FROM	dbo.tblCMBankAccount i21

GO
--Create trigger that will insert on the main table

CREATE TRIGGER trg_insert_vyuCMBankAccount
			ON [dbo].vyuCMBankAccount
			INSTEAD OF INSERT
			AS
			BEGIN 

			SET NOCOUNT ON 

			--For Encryption and Decryption
			OPEN SYMMETRIC KEY i21EncryptionSymKeyByASym
			DECRYPTION BY ASYMMETRIC KEY i21EncryptionASymKeyPwd 
			WITH PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='

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
						,intCreatedUserId
						,dtmCreated
						,intLastModifiedUserId
						,dtmLastModified
						,intConcurrencyId
						,strCbkNo
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
						,intCreatedUserId					= i.intCreatedUserId
						,dtmCreated							= i.dtmCreated
						,intLastModifiedUserId				= i.intLastModifiedUserId
						,dtmLastModified					= i.dtmLastModified
						,intConcurrencyId					= i.intConcurrencyId
						,strCbkNo							= i.strCbkNo
				FROM	inserted i 
				IF @@ERROR <> 0 GOTO EXIT_TRIGGER
			EXIT_TRIGGER: 

			CLOSE SYMMETRIC KEY i21EncryptionSymKeyByASym

END

GO
 --Create trigger that will update the record on the main table
CREATE TRIGGER trg_update_vyuCMBankAccount
		ON [dbo].vyuCMBankAccount
		INSTEAD OF UPDATE
		AS
		BEGIN 

		SET NOCOUNT ON

			--For Encryption and Decryption
			OPEN SYMMETRIC KEY i21EncryptionSymKeyByASym
			DECRYPTION BY ASYMMETRIC KEY i21EncryptionASymKeyPwd 
			WITH PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='

			-- Proceed in updating the base table (tblCMBankAccount)				
			UPDATE	dbo.tblCMBankAccount 
			SET		intBankId							= i.intBankId
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
					,intCreatedUserId					= i.intCreatedUserId
					,dtmCreated							= i.dtmCreated
					,intLastModifiedUserId				= i.intLastModifiedUserId
					,dtmLastModified					= i.dtmLastModified
					,intConcurrencyId					= i.intConcurrencyId
					,strCbkNo							= i.strCbkNo
			FROM	inserted i INNER JOIN dbo.tblCMBankAccount B
						ON i.intBankAccountId = B.intBankAccountId

			IF @@ERROR <> 0 GOTO EXIT_TRIGGER
			EXIT_TRIGGER:

			CLOSE SYMMETRIC KEY i21EncryptionSymKeyByASym
END