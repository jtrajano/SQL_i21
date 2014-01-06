
/*
 '====================================================================================================================================='
   SCRIPT CREATED BY: Feb Montefrio	DATE CREATED: December 19, 2013
  -------------------------------------------------------------------------------------------------------------------------------------						
   Script Name         :  Cash Management - Bank and Bank Accounts Import Script. 
   
   Description		   :  The purpose of this script is to import bank account records from the legacy system into i21. 
   
*/

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
		strBankName				= LTRIM(RTRIM(ISNULL(i.apcbk_desc, ''))) COLLATE Latin1_General_CI_AS
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
		,strRTN					= ISNULL(CAST(i.apcbk_transit_route AS NVARCHAR(12)), '') COLLATE Latin1_General_CI_AS
		,intCreatedUserID		= NULL
		,dtmCreated				= GETDATE()
		,intLastModifiedUserID	= NULL
		,dtmLastModified		= GETDATE()
		,intConcurrencyID		= 1
FROM	apcbkmst i
WHERE	NOT EXISTS (SELECT TOP 1 1 FROM tblCMBank WHERE strBankName = LTRIM(RTRIM(ISNULL(i.apcbk_desc, ''))) COLLATE Latin1_General_CI_AS)

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
		strBankName							= LTRIM(RTRIM(ISNULL(i.apcbk_desc, ''))) COLLATE Latin1_General_CI_AS
		,ysnActive							= CASE WHEN i.apcbk_active_yn = 'Y' THEN 1 ELSE 0 END 
		,intGLAccountID						= dbo.fn_GetGLAccountIDFromOriginToi21(i.apcbk_gl_cash) 
		,intCurrencyID						= dbo.fn_GetCurrencyIDFromOriginToi21(i.apcbk_currency)
		,intBankAccountType					= @DEPOSIT_ACCOUNT
		,strContact							= ''
		,strBankAccountNo					= ISNULL(i.apcbk_bank_acct_no, '') COLLATE Latin1_General_CI_AS
		,strRTN								= ISNULL(i.apcbk_transit_route, '') 
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
		,intCheckEndingNo					= ISNULL(i.apcbk_next_chk_no, 0)
		,intCheckNextNo						= ISNULL(i.apcbk_next_chk_no, 0)
		,ysnCheckEnableMICRPrint			= 1
		,ysnCheckDefaultToBePrinted			= 1
		,intBackupCheckStartingNo			= 0
		,intBackupCheckEndingNo				= 0
		,intEFTNextNo						= ISNULL(i.apcbk_next_eft_no, 0)
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
FROM	apcbkmst i
WHERE	NOT EXISTS (SELECT TOP 1 1 FROM tblCMBankAccount WHERE tblCMBankAccount.strCbkNo = i.apcbk_no COLLATE Latin1_General_CI_AS)
