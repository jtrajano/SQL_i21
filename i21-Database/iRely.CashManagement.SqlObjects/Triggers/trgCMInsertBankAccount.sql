CREATE TRIGGER trgCMInsertBankAccount
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
				FROM	inserted i 
				IF @@ERROR <> 0 GOTO EXIT_TRIGGER
			EXIT_TRIGGER: 

			CLOSE SYMMETRIC KEY i21EncryptionSymKeyByASym

END
