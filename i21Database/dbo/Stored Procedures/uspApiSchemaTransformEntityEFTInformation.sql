CREATE PROCEDURE [dbo].[uspApiSchemaTransformEntityEFTInformation] (
	 @guiApiUniqueId	UNIQUEIDENTIFIER,
	 @guiLogId			UNIQUEIDENTIFIER
)
AS

DECLARE @entityName nvarchar(100), @bankName nvarchar(100), 
		@currencyName nvarchar(100), @strBankAccountNumber nvarchar(100),
		@strDefault nvarchar(100), @strIBAN nvarchar(100), 
		@strSwift nvarchar(11), @strBICCode nvarchar(8), 
		@strBranchCode nvarchar(3), @strIntermediaryBank nvarchar(100), 
		@strIntermediarySwiftCode nvarchar(11), @strIntermediaryBICCode nvarchar(8), 
		@strIntermediaryIBAN nvarchar(100), @strNationalBankIdentifier nvarchar(100), 
		@strComment nvarchar(100), @strIntermediaryBankAddress nvarchar(100), 
		@strFiftySevenFormat nvarchar(100), @strFiftySixFormat nvarchar(100), 
		@strPrintNotifications nvarchar(100), @strAccountType nvarchar(100), 
		@strAccountClassification nvarchar(100), @strEffectiveDate nvarchar(100), 
		@strActive nvarchar(100), @strPullARBy nvarchar(100), 
		@strPullTaxSeparately nvarchar(100), @strRefundBudgetCredits nvarchar(100), 
		@strPrenoteSent nvarchar(100), @strDetailsOfCharges nvarchar(100);
DECLARE @intRowNo				INT;
DECLARE @intEntityId			INT;
DECLARE @intBankId				INT;
DECLARE @intCurrencyId			INT;
DECLARE @ysnAccountTypeValid	INT;

DECLARE @intEntityEFTHeaderId				INT;
DECLARE @ysnDefaultTransform				BIT;
DECLARE @ysnPrintNotificationsTransform		BIT;
DECLARE @ysnActiveTransform					BIT;
DECLARE @ysnPullTaxSeparatelyTransform		BIT;
DECLARE @ysnRefundBudgetCreditsTransform	BIT;
DECLARE @ysnPrenoteSentTransform			BIT;


DECLARE @dtmEffectiveDate		DATETIME;
DECLARE @intCountEFTInfoRecords	INT;
DECLARE @intExistingEFTInfoId	INT;
DECLARE @intEntityEFTInfoId		INT;

DECLARE @overWrite				BIT;
DECLARE @stopOnError			BIT;
DECLARE @withError				BIT;
DECLARE @defaultExist			SMALLINT;

DECLARE StagingCursor CURSOR LOCAL FOR 
SELECT	intRowNumber,strEntityName, strBankName, strCurrency, strBankAccountNumber, strDefault, strIBAN, strSwift, strBICCode, strBranchCode, strIntermediaryBank, strIntermediarySwiftCode,
		strIntermediaryBICCode, strIntermediaryIBAN, strNationalBankIdentifier, strComment, strIntermediaryBankAddress, strFiftySevenFormat, strFiftySixFormat, strPrintNotifications,
		strAccountType, strAccountClassification, strEffectiveDate, strActive, strPullARBy, strPullTaxSeparately, strRefundBudgetCredits, strPrenoteSent, strDetailsOfCharges
FROM	tblApiSchemaEntityEFTInformation
WHERE	guiApiUniqueId = @guiApiUniqueId


SELECT	@overWrite = CAST(Overwrite AS BIT), @stopOnError = CAST(StopOnError AS BIT)
FROM	(SELECT tp.strPropertyName, tp.varPropertyValue FROM tblApiSchemaTransformProperty AS tp WHERE tp.guiApiUniqueId = @guiApiUniqueId) AS Properties
PIVOT	(MIN([varPropertyValue]) FOR [strPropertyName] IN (Overwrite, StopOnError)) AS PivotTable;

OPEN	StagingCursor 
FETCH NEXT FROM StagingCursor INTO 
		@intRowNo, @entityName, @bankName, @currencyName, @strBankAccountNumber, @strDefault, @strIBAN, @strSwift, @strBICCode, @strBranchCode, @strIntermediaryBank, @strIntermediarySwiftCode,
		@strIntermediaryBICCode, @strIntermediaryIBAN, @strNationalBankIdentifier, @strComment, @strIntermediaryBankAddress, @strFiftySevenFormat, @strFiftySixFormat, @strPrintNotifications,
		@strAccountType, @strAccountClassification, @strEffectiveDate, @strActive, @strPullARBy, @strPullTaxSeparately, @strRefundBudgetCredits, @strPrenoteSent, @strDetailsOfCharges

WHILE @@FETCH_STATUS = 0  
BEGIN  
	SET @intEntityId		= NULL;
	SET @intEntityEFTInfoId = NULL;
	SET @intExistingEFTInfoId = NULL;
	SET @withError            = 0;
	SET @defaultExist		= 0;
    SELECT	distinct top 1 @intEntityId = en.intEntityId
	FROM	tblEMEntity AS en
			INNER JOIN tblEMEntityToContact AS en_tc ON
			en.intEntityId = en_tc.intEntityId
	WHERE	strName = @entityName;

	SELECT	@intBankId = intBankId
	FROM	tblCMBank
	WHERE	strBankName = @bankName;

	SELECT	@intCurrencyId = intCurrencyID
	FROM	tblSMCurrency
	WHERE	strCurrency = @currencyName;

	-- RESET EFT HEADER ID VALUE FOR CURRENT LOOP
	SET @intEntityEFTHeaderId = NULL;

	-- GET EFT HEADER ID
	SELECT	@intEntityEFTHeaderId = intEntityEFTHeaderId
	FROM	tblEMEntityEFTHeader
	WHERE	intEntityId = @intEntityId;

	-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Start: Field Validations
	-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	IF @intEntityId IS NULL
	BEGIN 
		INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
		VALUES(NEWID(),  @guiLogId, 'Entity Name', @entityName, 'Error', 'Failed', @intRowNo, 'Entity Name does not exist in database');
		SET @withError = 1;
	END

	IF @intBankId IS NULL
	BEGIN 
		INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
		VALUES(NEWID(),  @guiLogId, 'Bank Name', @bankName, 'Error', 'Failed', @intRowNo, 'Bank Name does not exist in database');
		SET @withError = 1;
	END

	IF @intCurrencyId IS NULL
	BEGIN 
		INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
		VALUES(NEWID(),  @guiLogId, 'Currency', @currencyName, 'Error', 'Failed', @intRowNo, 'Currency does not exist in database');
		SET @withError = 1;
	END

	IF @strBankAccountNumber IS NULL
	BEGIN 
		INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
		VALUES(NEWID(),  @guiLogId, 'Bank Account Number', @bankName, 'Error', 'Failed', @intRowNo, 'Bank Account Number is required');
		SET @withError = 1;
	END

	IF @strBICCode IS NULL
	BEGIN 
		INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
		VALUES(NEWID(),  @guiLogId, 'BIC Code', @strBICCode, 'Error', 'Failed', @intRowNo, 'BIC Code is required');
		SET @withError = 1;
	END

	IF @strBranchCode IS NULL
	BEGIN 
		INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
		VALUES(NEWID(),  @guiLogId, 'Branch Code', @strBranchCode, 'Error', 'Failed', @intRowNo, 'Branch Code is required');
		SET @withError = 1;
	END

	IF @strBranchCode IS NULL
	BEGIN 
		INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
		VALUES(NEWID(),  @guiLogId, 'Branch Code', @strBranchCode, 'Error', 'Failed', @intRowNo, 'Branch Code is required');
		SET @withError = 1;
	END
	
	IF @strAccountType IS NULL OR (lower(@strAccountType) != 'savings' AND lower(@strAccountType) != 'checking') 
	BEGIN 
		INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
		VALUES(NEWID(),  @guiLogId, 'Account Type', @strAccountType, 'Error', 'Failed', @intRowNo, 'Account Type is required. Valid values are : Savings or Checking');
		SET @withError = 1;
	END
	
	IF @strDefault IS NULL OR (lower(@strDefault) != 'true' AND lower(@strDefault) != 'yes' AND lower(@strDefault) != 'false' AND lower(@strDefault) != 'no')
	BEGIN 
		INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
		VALUES(NEWID(),  @guiLogId, 'Default', @strDefault, 'Error', 'Failed', @intRowNo, 'Default field is required. Valid values are : Yes or No');
		SET @withError = 1;
	END
	ELSE
	BEGIN
		
		SELECT @defaultExist = COUNT(*) FROM tblEMEntityEFTInformation WHERE ysnDefaultAccount = 1 and intEntityId = @intEntityId and intCurrencyId = @intCurrencyId;
		IF @defaultExist > 0 AND @currencyName IS NOT NULL AND (lower(@strDefault) = 'true' OR lower(@strDefault) = 'yes')
		BEGIN
			INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
		VALUES(NEWID(),  @guiLogId, 'Default', @strDefault, 'Error', 'Failed', @intRowNo, concat('Default Currency for ', @currencyName, ' is already present!'));
		SET @withError = 1;
		END
	END

	IF @strPrintNotifications IS NULL OR (lower(@strPrintNotifications) != 'true' AND lower(@strPrintNotifications) != 'yes' AND lower(@strPrintNotifications) != 'false' AND lower(@strPrintNotifications) != 'no')
	BEGIN 
		INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
		VALUES(NEWID(),  @guiLogId, 'Print Notifications', @strPrintNotifications, 'Error', 'Failed', @intRowNo, 'Print Notifications is required. Valid values are : Yes or No');
		SET @withError = 1;
	END

	IF @strActive IS NULL OR (lower(@strActive) != 'true' AND lower(@strActive) != 'yes' AND lower(@strActive) != 'false' AND lower(@strActive) != 'no')
	BEGIN 
		INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
		VALUES(NEWID(),  @guiLogId, 'Active', @strActive, 'Error', 'Failed', @intRowNo, 'Active field is required. Valid values are : Yes or No');
		SET @withError = 1;
	END

	IF @strActive IS NULL OR (lower(@strActive) != 'true' AND lower(@strActive) != 'yes' AND lower(@strActive) != 'false' AND lower(@strActive) != 'no')
	BEGIN 
		INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
		VALUES(NEWID(),  @guiLogId, 'Active', @strActive, 'Error', 'Failed', @intRowNo, 'Active field is required. Valid values are : Yes or No');
		SET @withError = 1;
	END

	IF @strPullTaxSeparately IS NULL OR (lower(@strPullTaxSeparately) != 'true' AND lower(@strPullTaxSeparately) != 'yes' AND lower(@strPullTaxSeparately) != 'false' AND lower(@strPullTaxSeparately) != 'no')
	BEGIN 
		INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
		VALUES(NEWID(),  @guiLogId, 'Pull Tax Separately', @strPullTaxSeparately, 'Error', 'Failed', @intRowNo, 'Pull Tax Separately is required. Valid values are : Yes or No');
		SET @withError = 1;
	END
	
	IF @strRefundBudgetCredits IS NULL OR (lower(@strRefundBudgetCredits) != 'true' AND lower(@strRefundBudgetCredits) != 'yes' AND lower(@strRefundBudgetCredits) != 'false' AND lower(@strRefundBudgetCredits) != 'no')
	BEGIN 
		INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
		VALUES(NEWID(),  @guiLogId, 'Refund Budget Credits', @strRefundBudgetCredits, 'Error', 'Failed', @intRowNo, 'Refund Budget Credits is required. Valid values are : Yes or No');
		SET @withError = 1;
	END
		
	IF @strPrenoteSent IS NULL OR (lower(@strPrenoteSent) != 'true' AND lower(@strPrenoteSent) != 'yes' AND lower(@strPrenoteSent) != 'false' AND lower(@strPrenoteSent) != 'no')
	BEGIN 
		INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
		VALUES(NEWID(),  @guiLogId, 'Prenote Sent', @strPrenoteSent, 'Error', 'Failed', @intRowNo, 'Prenote Sent is required. Valid values are : Yes or No');
		SET @withError = 1;
	END		

	IF LOWER(@strFiftySevenFormat) != '57a' AND LOWER(@strFiftySevenFormat) != '57d' AND (@strFiftySevenFormat IS NOT NULL OR @strFiftySevenFormat != '')
	BEGIN 
		INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
		VALUES(NEWID(),  @guiLogId, 'Beneficiary Bank (57A & 57D)', @strFiftySevenFormat, 'Error', 'Failed', @intRowNo, 'Invalid value. Valid values are : 57A or 57D');
		SET @withError = 1;
	END
	ELSE
	BEGIN
		IF LOWER(@strFiftySevenFormat) = '57a' AND (@strSwift IS NULL OR replace(@strSwift, ' ', '')= '')
		BEGIN 
			INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
			VALUES(NEWID(),  @guiLogId, 'Swift Code', @strSwift, 'Error', 'Failed', @intRowNo, 'Swift Code is required when 57 Format 57A was selected!');
			SET @withError = 1;
		END
	END

	IF LOWER(@strFiftySixFormat) != '56a' AND LOWER(@strFiftySixFormat)!= '56c' AND LOWER(@strFiftySixFormat)!= '56d' AND (@strFiftySixFormat IS NOT NULL OR @strFiftySixFormat != '')
	BEGIN 
		INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
		VALUES(NEWID(),  @guiLogId, 'Intermediary (56A 56C 56D)', @strFiftySixFormat, 'Error', 'Failed', @intRowNo, 'Invalid value. Valid values are : 56A, 56C, 56D');
		SET @withError = 1;
	END
	ELSE
	BEGIN
		IF LOWER(@strFiftySixFormat) = '56a' AND (@strIntermediarySwiftCode IS NULL OR replace(@strIntermediarySwiftCode, ' ', '')= '')
		BEGIN 
			INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
			VALUES(NEWID(),  @guiLogId, 'Intermediary Swift Code', @strIntermediarySwiftCode, 'Error', 'Failed', @intRowNo, 'Intermediary Swift Code is required when 56 Format 56A was selected!');
			SET @withError = 1;
		END
	END
	
	IF LOWER(@strAccountClassification)!= 'corporate' AND LOWER(@strAccountClassification) != 'personal' AND (@strAccountClassification IS NOT NULL OR @strAccountClassification != '')
	BEGIN 
		INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
		VALUES(NEWID(),  @guiLogId, 'Account Classification', @strAccountClassification, 'Error', 'Failed', @intRowNo, 'Invalid value. Valid values are : Corporate, Personal');
		SET @withError = 1;
	END	

	IF @strEffectiveDate IS NOT NULL AND ISDATE(@strEffectiveDate) != 1
	BEGIN 
		INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
		VALUES(NEWID(),  @guiLogId, 'Effective Date', @strEffectiveDate, 'Error', 'Failed', @intRowNo, 'Invalid date format. Sample valid format (yyyy/mm/dd)');
		SET @withError = 1;
	END	

	IF LOWER(@strPullARBy)!= 'statement amount' AND LOWER(@strPullARBy) != 'budget amount' AND LOWER(@strPullARBy) != 'invoice by terms' AND (@strPullARBy IS NOT NULL OR @strPullARBy != '')
	BEGIN 
		INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
		VALUES(NEWID(),  @guiLogId, 'Pull AR By', @strPullARBy, 'Error', 'Failed', @intRowNo, 'Invalid value. Valid values are : Statement Amount, Budget Amount, Invoice by Terms');
		SET @withError = 1;
	END	
	-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- End: Field Validations
	-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	IF @withError = 0
	BEGIN
		-- Default Column Transform
		IF LOWER(@strDefault) = 'true' OR LOWER(@strDefault) = 'yes'
			SET @ysnDefaultTransform = 1
		ELSE
			SET @ysnDefaultTransform = 0

		-- PrintNotification column Transform
		IF LOWER(@strPrintNotifications) = 'true' OR LOWER(@strPrintNotifications) = 'yes'
			SET @ysnPrintNotificationsTransform = 1
		ELSE
			SET @ysnPrintNotificationsTransform = 0
		
		-- Active column Transform
		IF LOWER(@strActive) = 'true' OR LOWER(@strActive) = 'yes'
			SET @ysnActiveTransform = 1
		ELSE
			SET @ysnActiveTransform = 0

		-- PullTaxSeparately column Transform
		IF LOWER(@strPullTaxSeparately) = 'true' OR LOWER(@strPullTaxSeparately) = 'yes'
			SET @ysnPullTaxSeparatelyTransform = 1
		ELSE
			SET @ysnPullTaxSeparatelyTransform = 0

		-- RefundBudgetCredits column Transform
		IF LOWER(@strRefundBudgetCredits) = 'true' OR LOWER(@strRefundBudgetCredits) = 'yes'
			SET @ysnRefundBudgetCreditsTransform = 1
		ELSE
			SET @ysnRefundBudgetCreditsTransform = 0

		-- PrenoteSent column Transform
		IF LOWER(@strPrenoteSent) = 'true' OR LOWER(@strPrenoteSent) = 'yes'
			SET @ysnPrenoteSentTransform = 1
		ELSE
			SET @ysnPrenoteSentTransform = 0

		-- Effective Date column Transform
		IF @strEffectiveDate IS NOT NULL
			SET @dtmEffectiveDate = CAST(@strEffectiveDate AS datetime);

		-- RESET EFT HEADER ID VALUE FOR CURRENT LOOP
		SET @intEntityEFTHeaderId = NULL;


		-- TODO Validate duplicate EFT Information
		--SELECT	@intCountEFTInfoRecords = COUNT(*) 
		--FROM	tblEMEntityEFTInformation 
		--WHERE	strAccountNumber	= @strBankAccountNumber AND 
		--		intEntityId			= @intEntityId AND 
		--		intBankId			= @intBankId AND 
		--		intCurrencyId		= @intCurrencyId;
		
		--IF(@intCountEFTInfoRecords = 0)
		--BEGIN
				-- GET EFT HEADER ID
		SELECT	@intEntityEFTHeaderId = intEntityEFTHeaderId
		FROM	tblEMEntityEFTHeader
		WHERE	intEntityId = @intEntityId;

		-- CHECK IF EFT HEADER ALREADY EXISTS FOR THE ENTITY. CREATE ONE IF NO RECORD YET
		IF @intEntityEFTHeaderId IS NULL
		BEGIN
			INSERT INTO tblEMEntityEFTHeader(intEntityId, intConcurrencyId) values(@intEntityId, 1);
			SET @intEntityEFTHeaderId =  @@Identity;
		END	

		INSERT INTO tblEMEntityEFTInformation(intEntityId, intEntityEFTHeaderId, intBankId, strBankName, strAccountNumber, strAccountType, strAccountClassification, dtmEffectiveDate, ysnPrintNotifications,
												ysnActive, strPullARBy, ysnPullTaxSeparately, ysnRefundBudgetCredits, ysnPrenoteSent, strDistributionType, dblAmount, intOrder, strEFTType, strCurrency,
												strIBAN, strSwiftCode, strBicCode, strBranchCode, ysnDefaultAccount, strIntermediaryBank, strIntermediaryBankAddress, strIntermediarySwiftCode,
												strIntermediaryIBAN, strIntermediaryBicCode, strNationalBankIdentifier, strComment, strDetailsOfCharges, strFiftySevenFormat, strFiftySixFormat,
												intCurrencyId, ysnDomestic, intRowNumber, guiApiUniqueId, intConcurrencyId)
										VALUES(@intEntityId, @intEntityEFTHeaderId, @intBankId, @bankName, dbo.fnAESEncryptASym(@strBankAccountNumber), @strAccountType, @strAccountClassification, @dtmEffectiveDate, @ysnPrintNotificationsTransform,
												@ysnActiveTransform, @strPullARBy, @ysnPullTaxSeparatelyTransform, @ysnRefundBudgetCreditsTransform, @ysnPrenoteSentTransform, NULL, NULL, 0, NULL, @currencyName,
												@strIBAN, @strSwift, @strBICCode, @strBranchCode, @ysnDefaultTransform, @strIntermediaryBank, @strIntermediaryBankAddress, @strIntermediarySwiftCode,
												@strIntermediaryIBAN, @strIntermediaryBICCode, @strNationalBankIdentifier, @strComment, @strDetailsOfCharges, @strFiftySevenFormat, @strFiftySixFormat,
												@intCurrencyId, NULL, @intRowNo, @guiApiUniqueId, 1);
		SET @intEntityEFTInfoId =  @@Identity;
		--END
		--ELSE
		--BEGIN 
		--	IF @overWrite = 1
		--	BEGIN
		--		SELECT	@intExistingEFTInfoId = intEntityEFTInfoId FROM tblEMEntityEFTInformation WHERE strAccountNumber = @strBankAccountNumber AND intEntityId = @intEntityId AND intBankId = @intBankId;
		
		--		UPDATE tblEMEntityEFTInformation
		--		SET strAccountType = @strAccountType
		--		WHERE	intEntityEFTInfoId = @intExistingEFTInfoId;

		--		SET @intEntityEFTInfoId = @intExistingEFTInfoId;
		--	END
		--	ELSE 
		--		SET @intEntityEFTInfoId = NULL;
		--END

		IF @intEntityEFTInfoId IS NOT NULL
		BEGIN 
			INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
										VALUES(NEWID(), @guiLogId, 'Entity EFT Information', @intEntityEFTInfoId, 'Info', 'Success', @intRowNo, 'The record was imported successfully.');
		END
		ELSE
		BEGIN
			INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
										VALUES(NEWID(), @guiLogId, 'Entity EFT Information', @intEntityEFTInfoId, 'Warning', 'Skipped', @intRowNo, 'EFT Information already exists for the entity');
			BREAK;
		END

	END
	-- IF BLOCK END


	IF @stopOnError = 1 AND @withError = 1
		BREAK;

	FETCH NEXT FROM StagingCursor INTO 
		@intRowNo, @entityName, @bankName, @currencyName, @strBankAccountNumber, @strDefault, @strIBAN, @strSwift, @strBICCode, @strBranchCode, @strIntermediaryBank, @strIntermediarySwiftCode,
		@strIntermediaryBICCode, @strIntermediaryIBAN, @strNationalBankIdentifier, @strComment, @strIntermediaryBankAddress, @strFiftySevenFormat, @strFiftySixFormat, @strPrintNotifications,
		@strAccountType, @strAccountClassification, @strEffectiveDate, @strActive, @strPullARBy, @strPullTaxSeparately, @strRefundBudgetCredits, @strPrenoteSent, @strDetailsOfCharges
END 

