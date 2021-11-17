﻿CREATE PROCEDURE [dbo].[uspApiSchemaCCTransformVendorSite]
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS

BEGIN
	-- VALIDATE VENDOR
	INSERT INTO tblApiImportLogDetail (
		  guiApiImportLogDetailId
		, guiApiImportLogId
		, strField
		, strValue
		, strLogLevel
		, strStatus
		, intRowNo
		, strMessage
	)
	SELECT guiApiImportLogDetailId = NEWID()
		, guiApiImportLogId = @guiLogId
		, strField = 'Vendor Entity Number'
		, strValue = VS.strVendorNumber
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = VS.intRowNumber
		, strMessage = 'Could not find the Vendor Entity Number ''' +  VS.strVendorNumber + ''' in i21 Vendors.'
	FROM tblApiSchemaCCVendorSite VS
		LEFT JOIN tblAPVendor V ON VS.strVendorNumber = V.strVendorId
	WHERE V.intEntityId IS NULL
		AND ISNULL(VS.strVendorNumber, '') != ''
		AND VS.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE CUSTOMER
	INSERT INTO tblApiImportLogDetail (
		  guiApiImportLogDetailId
		, guiApiImportLogId
		, strField
		, strValue
		, strLogLevel
		, strStatus
		, intRowNo
		, strMessage
	)
	SELECT guiApiImportLogDetailId = NEWID()
		, guiApiImportLogId = @guiLogId
		, strField = 'Customer Number'
		, strValue = VS.strCustomerNumber
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = VS.intRowNumber
		, strMessage = 'Could not find the Customer Number ''' + VS.strCustomerNumber + ''' in i21 Customers.'
	FROM tblApiSchemaCCVendorSite VS
		LEFT JOIN tblEMEntity E ON E.strEntityNo = VS.strCustomerNumber
		LEFT JOIN tblARCustomer C ON C.intEntityId = E.intEntityId AND C.ysnActive = 1
	WHERE C.intEntityId IS NULL 
	AND VS.guiApiUniqueId = @guiApiUniqueId


	-- VALIDATE ACCOUNT
	INSERT INTO tblApiImportLogDetail (
		guiApiImportLogDetailId
		, guiApiImportLogId
		, strField
		, strValue
		, strLogLevel
		, strStatus
		, intRowNo
		, strMessage
	)
	SELECT guiApiImportLogDetailId = NEWID()
		, guiApiImportLogId = @guiLogId
		, strField = 'Account'
		, strValue = VS.strAccount
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = VS.intRowNumber
		, strMessage = 'Could not find the Account Id ''' + VS.strAccount + ''' in i21 ' + 
				CASE WHEN VS.strSiteType = 'E' 
				THEN 'Clearing Accounts' 
				ELSE 'Credit Card Receivables.' 
				END
	FROM tblApiSchemaCCVendorSite VS
		LEFT JOIN tblGLAccount AC ON VS.strAccount = AC.strAccountId
	WHERE AC.intAccountId IS NULL
		AND VS.guiApiUniqueId = @guiApiUniqueId


	-- VALIDATE FEE EXPENSE GL
	INSERT INTO tblApiImportLogDetail (
		guiApiImportLogDetailId
		, guiApiImportLogId
		, strField
		, strValue
		, strLogLevel
		, strStatus
		, intRowNo
		, strMessage
	)
	SELECT guiApiImportLogDetailId = NEWID()
		, guiApiImportLogId = @guiLogId
		, strField = 'Fee Expense GL'
		, strValue = VS.strFeeExpenseGL
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = VS.intRowNumber
		, strMessage = CASE WHEN ISNULL(VS.strFeeExpenseGL, '') = '' THEN 'Fee Expense GL is required for Company Owned Sites.' ELSE 'Could not find the Fee Expense GL Account Id ''' + VS.strFeeExpenseGL + ''' in i21 Credit Card Receivables.' END
	FROM tblApiSchemaCCVendorSite VS
		LEFT JOIN tblGLAccount AC ON VS.strFeeExpenseGL = AC.strAccountId
	WHERE AC.intAccountId IS NULL
		AND VS.guiApiUniqueId = @guiApiUniqueId
		AND VS.strSiteType = 'I'


	-- VALIDATE PAY TYPE
	INSERT INTO tblApiImportLogDetail (
		guiApiImportLogDetailId
		, guiApiImportLogId
		, strField
		, strValue
		, strLogLevel
		, strStatus
		, intRowNo
		, strMessage
	)
	SELECT guiApiImportLogDetailId = NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = 'Pay Type'
	, strValue = VS.strPayType
	, strLogLevel = 'Warning'
	, strStatus = 'Success'
	, intRowNo = VS.intRowNumber
	, strMessage = 'Could not find Pay Type ''' + VS.strPayType + ''' in i21 Payment Methods. Defaulted payment type to ''Debit Memos and Payments'''
	FROM tblApiSchemaCCVendorSite VS
		LEFT JOIN tblSMPaymentMethod PM ON VS.strPayType = PM.strPaymentMethod
	WHERE PM.intPaymentMethodID IS NULL
		AND PM.ysnActive = 1
		AND VS.guiApiUniqueId = @guiApiUniqueId


	-- VALIDATE SITE TYPE
	INSERT INTO tblApiImportLogDetail (
		guiApiImportLogDetailId
		, guiApiImportLogId
		, strField
		, strValue
		, strLogLevel
		, strStatus
		, intRowNo
		, strMessage
	)
	SELECT guiApiImportLogDetailId = NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = 'Site Type'
	, strValue = VS.strPayType
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = VS.intRowNumber
	, strMessage = 'Invalid Site Type. Valid values: "I" = Company Owned Site, "E" = Dealer Site'
	FROM tblApiSchemaCCVendorSite VS
	WHERE VS.strSiteType NOT IN ('I', 'E')
		AND VS.guiApiUniqueId = @guiApiUniqueId

	--TRANSFORM
	DECLARE cur CURSOR FOR
	SELECT VS.intKey 
		 , VS.intRowNumber
		 , VS.strDescription
		 , VS.dblSharedFee
		 , VS.strSite
		 , VS.strSiteType
		 , V.intEntityId
		 --, VD.intVendorDefaultId
		 , C.intEntityId
		 , AC.intAccountId
		 , AC2.intAccountId
		 , PM.intPaymentMethodID
		 , PM2.intPaymentMethodID
	FROM tblApiSchemaCCVendorSite VS
		INNER JOIN tblAPVendor V ON VS.strVendorNumber = V.strVendorId
		INNER JOIN tblARCustomer C ON VS.strCustomerNumber = C.strCustomerNumber
		INNER JOIN tblGLAccount AC ON VS.strAccount = AC.strAccountId
		LEFT JOIN tblGLAccount AC2 ON VS.strFeeExpenseGL = AC2.strAccountId
		LEFT JOIN tblSMPaymentMethod PM2 ON PM2.strPaymentMethod = 'Debit Memos and Payments'
		LEFT JOIN tblSMPaymentMethod PM ON VS.strPayType = PM.strPaymentMethod
	WHERE VS.guiApiUniqueId = @guiApiUniqueId
		AND 1 = (
				CASE 
					WHEN ISNULL(VS.strSiteType, '') = '' THEN 0
					WHEN VS.strSiteType = 'I' THEN CASE WHEN VS.strFeeExpenseGL IS NULL THEN 0 ELSE 1 END
					WHEN VS.strSiteType = 'E' THEN 1
					ELSE 0
				END
			)

    DECLARE @intKey 					INT = NULL
	DECLARE @intRowNumber				INT = NULL
	DECLARE @strDescription				NVARCHAR(250) = NULL
	DECLARE @dblSharedFee				NUMERIC(18, 6) = NULL
	DECLARE @strSite					NVARCHAR(100) = NULL
	DECLARE @strSiteType				NVARCHAR(1) = NULL
	DECLARE @intVendorDefaultId			INT = NULL
	DECLARE @intVendorId				INT = NULL
	DECLARE @intCustomerEntityId		INT = NULL
	DECLARE @intAccountId				INT = NULL
	DECLARE @intFeeExpenseAccountId		INT = NULL
	DECLARE @intPaymentMethodID			INT = NULL
	DECLARE @intPaymentMethodIdDefault	INT = NULL

	OPEN cur
	FETCH NEXT FROM cur INTO
	 @intKey 				 
	,@intRowNumber			 
	,@strDescription			
	,@dblSharedFee			
	,@strSite				
	,@strSiteType	
	,@intVendorId
	--,@intVendorDefaultId			
	,@intCustomerEntityId			
	,@intAccountId			
	,@intFeeExpenseAccountId	
	,@intPaymentMethodID		
	,@intPaymentMethodIdDefault

	WHILE @@FETCH_STATUS = 0   
	BEGIN

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblCCVendorDefault WHERE intVendorId = @intVendorId)
		BEGIN
			INSERT INTO tblCCVendorDefault(intVendorId, strApType, strEnterTotalsAsGrossOrNet, strFileType, strImportFileName, strImportAuxiliaryFileName, strImportFilePath, intConcurrencyId)
			VALUES(@intVendorId, '', '', '', '', '', '', 1)
			
			SET @intVendorDefaultId = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			SELECT TOP 1  @intVendorDefaultId = intVendorDefaultId  FROM tblCCVendorDefault WHERE intVendorId = @intVendorId
		END

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblCCSite WHERE strSite = @strSite AND intVendorDefaultId = @intVendorDefaultId)
		BEGIN
			IF (@strSiteType = 'I' AND @intFeeExpenseAccountId IS NOT NULL) -- Import only Company Owned Site with valid Fee Expense GL
				OR (@strSiteType = 'E')

			INSERT INTO tblCCSite ([guiApiUniqueId]
				,[intVendorDefaultId]
				,[strSite]
				,[strSiteDescription]
				,[intPaymentMethodId]
				,[intCustomerId]
				,[ysnPassedThruArCustomer]
				,[intAccountId]
				,[intFeeExpenseAccountId]
				,[ysnPostNetToArCustomer]
				,[strMerchantCategory]
				,[strTransactionType]
				,[ysnSharedFee]
				,[dblSharedFeePercentage]
				,[strType]
				,[intSort]
				,[intConcurrencyId])
			VALUES(@guiApiUniqueId
				,@intVendorDefaultId
				,@strSite
				,@strDescription
				,CASE WHEN ISNULL(@intPaymentMethodID, 0) = 0 THEN @intPaymentMethodIdDefault ELSE @intPaymentMethodID END
				,@intCustomerEntityId
				,0
				,@intAccountId
				,@intFeeExpenseAccountId
				,CASE WHEN @strSiteType = 'E' THEN 1 ELSE 0 END
				,''
				,''
				,CASE WHEN ISNULL(@dblSharedFee, 0) = 0 THEN 0 ELSE 1 END
				,@dblSharedFee
				,CASE WHEN @strSiteType = 'E' THEN 'DEALER' ELSE 'COMPANY OWNED' END
				,NULL
				,1
			)
			END
		ELSE -- IF EXISTS
		BEGIN
			UPDATE tblCCSite SET [guiApiUniqueId] = @guiApiUniqueId
				,[intVendorDefaultId] = @intVendorDefaultId
				,[strSite] = @strSite
				,[strSiteDescription] =  @strDescription
				,[intPaymentMethodId] = CASE WHEN ISNULL(@intPaymentMethodID, 0) = 0 THEN @intPaymentMethodIdDefault ELSE @intPaymentMethodID END
				,[intCustomerId] = @intCustomerEntityId
				,[ysnPassedThruArCustomer] = 0
				,[intAccountId] = @intAccountId
				,[intFeeExpenseAccountId] = @intFeeExpenseAccountId
				,[ysnPostNetToArCustomer] = CASE WHEN @strSiteType = 'E' THEN 1 ELSE 0 END
				,[strMerchantCategory] = ''
				,[strTransactionType] = ''
				,[ysnSharedFee] = CASE WHEN ISNULL(@dblSharedFee, 0) = 0 THEN 0 ELSE 1 END
				,[dblSharedFeePercentage] = @dblSharedFee
				,[strType] = CASE WHEN @strSiteType = 'E' THEN 'DEALER' WHEN @strSiteType = 'I' THEN 'COMPANY OWNED' ELSE NULL END
				,[intSort] = NULL
				,[intConcurrencyId] = 1
			WHERE strSite = @strSite AND intVendorDefaultId = @intVendorDefaultId
		END

	FETCH NEXT FROM cur INTO
	 @intKey 				 
	,@intRowNumber			 
	,@strDescription			
	,@dblSharedFee			
	,@strSite				
	,@strSiteType
	,@intVendorId
	--,@intVendorDefaultId			
	,@intCustomerEntityId			
	,@intAccountId			
	,@intFeeExpenseAccountId	
	,@intPaymentMethodID
	,@intPaymentMethodIdDefault
	END
	CLOSE cur
	DEALLOCATE cur

	UPDATE log
	SET log.intTotalRowsImported = r.intCount
	FROM tblApiImportLog log
	CROSS APPLY(
		SELECT COUNT(*) intCount
		FROM tblCCSite
		WHERE guiApiUniqueId = log.guiApiUniqueId
	) r
	WHERE log.guiApiImportLogId = @guiLogId
END




