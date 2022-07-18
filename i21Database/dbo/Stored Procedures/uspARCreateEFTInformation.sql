CREATE PROCEDURE uspARCreateEFTInformation
	  @intEntityCustomerId		INT
	, @intCurrencyId			INT = NULL--
	, @intEntityUserId			INT = NULL
    , @intGLAccountId           INT = NULL--
	, @strBankName				NVARCHAR(250)--
	, @strBankAccountNo			NVARCHAR(500)--
	, @strRTN					NVARCHAR(500)--
	, @ysnDefaultAccount		BIT = 0 --
	, @strAccountType			NVARCHAR(10) = 'Checking'
	, @strBICCode				NVARCHAR(8) = NULL--
	, @strBranchCode			NVARCHAR(3) = NULL--
	, @intNewBankId				INT = NULL OUTPUT
    , @intNewBankAccountId      INT = NULL OUTPUT
	, @intNewEntityEFTInfoId	INT = NULL OUTPUT
AS

DECLARE @intEntityEFTHeaderId	INT = NULL
	  , @strCurrency			NVARCHAR(50) = NULL

SELECT TOP 1 @intNewBankId = intBankId 
FROM tblCMBank 
WHERE dbo.fnAESDecryptASym(strRTN) = @strRTN
ORDER BY strBankName ASC

SELECT TOP 1 @intNewBankAccountId = intBankAccountId 
FROM tblCMBankAccount
WHERE dbo.fnAESDecryptASym(strRTN) = @strRTN
ORDER BY intBankAccountId ASC

SELECT TOP 1 @intEntityEFTHeaderId = intEntityEFTHeaderId
FROM tblEMEntityEFTHeader
WHERE intEntityId = @intEntityCustomerId
ORDER BY intEntityEFTHeaderId ASC

SELECT TOP 1 @strCurrency = strCurrency
FROM tblSMCurrency
WHERE intCurrencyID = @intCurrencyId
ORDER BY intCurrencyID ASC

--EFT HEADER
IF @intEntityEFTHeaderId IS NULL
	BEGIN 
		INSERT INTO tblEMEntityEFTHeader (
			  intEntityId
			, intConcurrencyId
		)
		SELECT intEntityId		= @intEntityCustomerId
			, intConcurrencyId  = 1

		SET @intEntityEFTHeaderId = SCOPE_IDENTITY()
	END

--NEW BANK
IF @intNewBankId IS NULL
	BEGIN
		INSERT INTO tblCMBank (
			   strBankName
			 , strContact
			 , strAddress
			 , strZipCode
			 , strCity
			 , strState
			 , strCountry
			 , strPhone
			 , strFax
			 , strWebsite
			 , strEmail
			 , strRTN
			 , strBICCode
			 , intCreatedUserId
			 , dtmCreated
			 , intConcurrencyId
		)
		SELECT strBankName				= @strBankName
			 , strContact				= ECC.strName
			 , strAddress				= EL.strAddress
			 , strZipCode				= EL.strZipCode
			 , strCity					= EL.strCity
			 , strState					= EL.strState
			 , strCountry				= EL.strCountry
			 , strPhone					= EL.strPhone
			 , strFax					= EL.strFax
			 , strWebsite				= E.strWebsite
			 , strEmail					= E.strEmail
			 , strRTN					= dbo.fnAESEncryptASym(@strRTN)
			 , strBICCode				= @strBICCode
			 , intCreatedUserId			= @intEntityUserId
			 , dtmCreated				= GETDATE()
			 , intConcurrencyId			= 1
		FROM tblEMEntity E
		INNER JOIN tblEMEntityToContact EC ON E.intEntityId = EC.intEntityId
		INNER JOIN tblEMEntity ECC ON EC.intEntityContactId = ECC.intEntityId
		INNER JOIN tblEMEntityLocation EL ON E.intEntityId = EL.intEntityId
		WHERE E.intEntityId = @intEntityCustomerId
		  AND EC.ysnDefaultContact = 1
		  AND EL.ysnDefaultLocation = 1

		SELECT TOP 1 @intNewBankId = intBankId
		FROM tblCMBank
		WHERE strBankName = @strBankName
	END

--NEW BANK ACCOUNT
IF @intNewBankAccountId IS NULL AND @intNewBankId IS NOT NULL
    BEGIN 
        INSERT INTO tblCMBankAccount (
              intBankId
            , ysnActive
            , intGLAccountId
            , intCurrencyId
            , intBankAccountTypeId
            , intBrokerageAccountId
            , strContact
            , strBankAccountHolder
            , strBankAccountNo
            , strRTN
            , strAddress
            , strZipCode
            , strCity
            , strState
            , strCountry
            , strPhone
            , strFax
            , strWebsite
            , strEmail
            , strIBAN
            , strSWIFT
            , strBICCode
            , strBranchCode
            , intEFTBankFileFormatId
            , intEFTARFileFormatId
            , intCreatedUserId
            , dtmCreated
			, strCbkNo
            , intConcurrencyId
        )
        SELECT TOP 1 intBankId			= B.intBankId
            , ysnActive					= 1
            , intGLAccountId			= @intGLAccountId
            , intCurrencyId				= @intCurrencyId 
            , intBankAccountTypeId		= @intGLAccountId
            , intBrokerageAccountId		= NULL
            , strContact				= NULL
            , strBankAccountHolder		= NULL
            , strBankAccountNo			= dbo.fnAESEncryptASym(@strBankAccountNo)
            , strRTN					= B.strRTN
            , strAddress				= B.strAddress
            , strZipCode				= B.strZipCode
            , strCity					= B.strCity
            , strState					= B.strState
            , strCountry				= B.strCountry
            , strPhone					= B.strPhone
            , strFax					= B.strFax
            , strWebsite				= B.strWebsite
            , strEmail					= B.strEmail
            , strIBAN					= B.strIBAN
            , strSWIFT					= B.strSwiftCode
            , strBICCode				= B.strBICCode
            , strBranchCode				= @strBranchCode
            , intEFTBankFileFormatId	= BFF.intBankFileFormatId
            , intEFTARFileFormatId		= BFF.intBankFileFormatId
            , intCreatedUserId			= @intEntityUserId
            , dtmCreated				= GETDATE()
			, strCbkNo					= ''
            , intConcurrencyId			= 1
        FROM tblCMBank B
        CROSS APPLY (
            SELECT TOP 1 intBankAccountTypeId 
            FROM tblCMBankAccountType 
            WHERE strBankAccountType = 'Bank'
        ) BAT
        CROSS APPLY (
            SELECT TOP 1 intBankFileFormatId 
            FROM tblCMBankFileFormat 
            WHERE strName = 'AR ACH' 
        ) BFF
        WHERE B.intBankId = @intNewBankId

        SET @intNewBankAccountId = SCOPE_IDENTITY()
    END

--NEW EFT INFO
INSERT INTO tblEMEntityEFTInformation (
	  intEntityId
	, intEntityEFTHeaderId
	, intBankId
	, strBankName
	, strAccountNumber
	, strAccountType
	, strAccountClassification
	, dtmEffectiveDate
	, ysnPrintNotifications
	, ysnActive
	, ysnPullTaxSeparately
	, ysnRefundBudgetCredits
	, ysnPrenoteSent
	, strDistributionType
	, dblAmount
	, strEFTType
	, strCurrency
	, strBicCode
	, strBranchCode
	, strNationalBankIdentifier
	, intCurrencyId
	, intOrder
	, intConcurrencyId
)
SELECT intEntityId					= @intEntityCustomerId
	 , intEntityEFTHeaderId			= @intEntityEFTHeaderId
	 , intBankId					= B.intBankId
	 , strBankName					= B.strBankName
	 , strAccountNumber				= dbo.fnAESEncryptASym(@strBankAccountNo)
	 , strAccountType				= @strAccountType
	 , strAccountClassification		= 'Personal'
	 , dtmEffectiveDate				= CAST(GETDATE() AS DATE)
	 , ysnPrintNotifications		= 0
	 , ysnActive					= 1
	 , ysnPullTaxSeparately			= 0
	 , ysnRefundBudgetCredits		= 0
	 , ysnPrenoteSent				= 0
	 , strDistributionType			= NULL
	 , dblAmount					= 0
	 , strEFTType					= 'Accounts Receivable'
	 , strCurrency					= @strCurrency
	 , strBicCode					= @strBICCode
	 , strBranchCode				= @strBranchCode
	 , strNationalBankIdentifier	= @strRTN
	 , intCurrencyId				= @intCurrencyId
	 , intOrder						= 0
	 , intConcurrencyId				= 1
FROM tblCMBank B
WHERE B.intBankId = @intNewBankId

SET @intNewEntityEFTInfoId = SCOPE_IDENTITY()

IF @ysnDefaultAccount = 1
	BEGIN
		UPDATE tblEMEntityEFTInformation 
		SET ysnDefaultAccount = CASE WHEN intEntityEFTInfoId = @intNewEntityEFTInfoId THEN 1 ELSE 0 END 
		WHERE intEntityId = @intEntityCustomerId
	END