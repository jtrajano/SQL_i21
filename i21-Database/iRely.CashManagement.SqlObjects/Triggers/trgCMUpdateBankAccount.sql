--Create trigger that will update the record on the main table
CREATE TRIGGER trgCMUpdateBankAccount
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
			FROM	inserted i INNER JOIN dbo.tblCMBankAccount B
						ON i.intBankAccountId = B.intBankAccountId

			IF @@ERROR <> 0 GOTO EXIT_TRIGGER
			EXIT_TRIGGER:

			CLOSE SYMMETRIC KEY i21EncryptionSymKeyByASym
END