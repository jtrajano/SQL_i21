IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspCCDealerSiteCompanyOwnedMigration]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspCCDealerSiteCompanyOwnedMigration]
GO

CREATE PROCEDURE [dbo].[uspCCDealerSiteCompanyOwnedMigration]
	@intUserId INT,
	@strSource NVARCHAR(100)
AS

DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT

BEGIN TRY

	DECLARE @strImportType NVARCHAR(50) = 'CCR VENDOR DEALER SITE COMPANY OWNED'

	IF EXISTS(SELECT TOP 1 1 FROM tblCCImportStatus WHERE strImportType = @strImportType AND ysnActive = 1)
	BEGIN
		RETURN 0
	END

	DECLARE @intVendorId AS INT = NULL, 
		@intPaymentMethodId AS INT = NULL, 
		@intCustomerId AS INT = NULL, 
		@intClearingAccountId AS INT = NULL, 
		@intFeeExpenceAccountId AS INT = NULL,
		@strSite AS NVARCHAR(100) = NULL, 
		@strSiteDescription AS NVARCHAR(300) = NULL, 
		@strMerchantCategory AS NVARCHAR(100) = NULL, 
		@strTransactionType AS NVARCHAR(100) = NULL,
		@strDealerSiteType NVARCHAR(50) = NULL,
		@dblSharedFeePercentage NUMERIC(18,6),
		@strPostNetToArCustomer NVARCHAR(50) = NULL
	 
	DECLARE @CursorTran AS CURSOR

	SET @CursorTran = CURSOR FOR
	SELECT VENDOR.intEntityId intVendorId, 
		PM.intPaymentMethodID intPaymentMethodId, 
		CUSTOMER.intEntityId intCustomerId, 
		dbo.fnGetGLAccountIdFromOriginToi21(DS.apvds_gl_acct) intClearingAccountId,
		dbo.fnGetGLAccountIdFromOriginToi21(DS.apvds_fees_gl_acct) intFeeExpenceAccountId,
		DS.apvds_dealer_site_no strSite, 
		DS.apvds_desc strSiteDescription, 
		DS.apvds_mer_cat_cd strMerchantCategory, 
		DS.apvds_trans_type_rptd strTransactionType,
		DS.apvds_dealer_site_type strDealerSiteType,
		DS.apvds_fees_to_ar_pct dblSharedFeePercentage,
		DS.apvds_post_net_gross strPostNetToArCustomer
	FROM apvdsmst DS INNER JOIN tblAPVendor VENDOR ON VENDOR.strVendorId = DS.apvds_vnd_no COLLATE Latin1_General_CI_AS
	LEFT JOIN tblSMPaymentMethod PM ON PM.strPaymentMethod = DS.apvds_ar_pay_type COLLATE Latin1_General_CI_AS
	LEFT JOIN tblARCustomer CUSTOMER ON CUSTOMER.strCustomerNumber = DS.apvds_ar_cus_no  COLLATE Latin1_General_CI_AS
	--LEFT JOIN glactmst CLRACC ON CLRACC.glact_acct1_8 = CAST(DS.apvds_gl_acct AS INT) AND CLRACC.glact_acct9_16 = CAST(PARSENAME((DS.apvds_gl_acct % 1),1) AS INT)
	--LEFT JOIN tblGLCOACrossReference CLRCOA ON CLRCOA.intLegacyReferenceId = CLRACC.A4GLIdentity
	--LEFT JOIN tblGLAccount CLRGLACC ON CLRGLACC.intAccountId = CLRCOA.inti21Id
	--LEFT JOIN glactmst EXPACC ON EXPACC.glact_acct1_8 = CAST(DS.apvds_fees_gl_acct AS INT) AND EXPACC.glact_acct9_16 = CAST(PARSENAME((DS.apvds_fees_gl_acct % 1),1) AS INT)
	--LEFT JOIN tblGLCOACrossReference EXPCOA ON EXPCOA.intLegacyReferenceId = EXPACC.A4GLIdentity
	--LEFT JOIN tblGLAccount EXPGLACC ON EXPGLACC.intAccountId = EXPCOA.inti21Id
	ORDER BY DS.apvds_vnd_no

	OPEN @CursorTran

	FETCH NEXT FROM @CursorTran INTO @intVendorId, @intPaymentMethodId, @intCustomerId, @intClearingAccountId, @intFeeExpenceAccountId, @strSite, @strSiteDescription, @strMerchantCategory, @strTransactionType, @strDealerSiteType, @dblSharedFeePercentage, @strPostNetToArCustomer
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		DECLARE @intVendorDefaultId INT = NULL
	
		SELECT @intVendorDefaultId = intVendorDefaultId FROM tblCCVendorDefault WHERE intVendorId = @intVendorId 
	
		IF(@intVendorDefaultId IS NULL)
		BEGIN
			INSERT INTO tblCCVendorDefault (intVendorId, strApType, strEnterTotalsAsGrossOrNet, strFileType, intConcurrencyId) VALUES (@intVendorId, '','','', 1)
			SELECT @intVendorDefaultId = SCOPE_IDENTITY()
		END

		-- D - Dealer Site
		IF (@strDealerSiteType = 'D')
		BEGIN
			INSERT INTO tblCCSite ([intVendorDefaultId]
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
				,[dblSharedFeePercentage]
				,[strType]
				,[intSort]
				,[intConcurrencyId])
			VALUES (@intVendorDefaultId
				,@strSite
				,@strSiteDescription
				,@intPaymentMethodId
				,@intCustomerId
				,0
				,@intClearingAccountId
				,@intFeeExpenceAccountId
				,CASE WHEN @strPostNetToArCustomer = 'G' THEN 1 ELSE 0 END
				,@strMerchantCategory
				,@strTransactionType
				,0
				,'DEALER'
				,1
				,1)
		END
	
		-- S - Dealer Site Shared Fees
		IF (@strDealerSiteType = 'S')
		BEGIN
			INSERT INTO tblCCSite ([intVendorDefaultId]
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
			VALUES (@intVendorDefaultId
				,@strSite
				,@strSiteDescription
				,@intPaymentMethodId
				,@intCustomerId
				,0
				,@intClearingAccountId
				,@intFeeExpenceAccountId
				,CASE WHEN @strPostNetToArCustomer = 'G' THEN 1 ELSE 0 END
				,@strMerchantCategory
				,@strTransactionType
				,1
				,@dblSharedFeePercentage
				,'DEALER'
				,1
				,1)
		END

		-- C - Company Owned
		IF (@strDealerSiteType = 'C')
		BEGIN
			INSERT INTO tblCCSite ([intVendorDefaultId]
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
				,[strType]
				,[intSort]
				,[intConcurrencyId])
			VALUES (@intVendorDefaultId
				,@strSite
				,@strSiteDescription
				,@intPaymentMethodId
				,@intCustomerId
				,0
				,@intClearingAccountId
				,@intFeeExpenceAccountId
				,0
				,@strMerchantCategory
				,@strTransactionType
				,'COMPANY OWNED'
				,1
				,1)
		END

		-- P - Company Owned Pass Thru A/R Customer
		IF (@strDealerSiteType = 'P')
		BEGIN
			INSERT INTO tblCCSite ([intVendorDefaultId]
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
				,[strType]
				,[intSort]
				,[intConcurrencyId])
			VALUES (@intVendorDefaultId
				,@strSite
				,@strSiteDescription
				,@intPaymentMethodId
				,@intCustomerId
				,1
				,@intClearingAccountId
				,@intFeeExpenceAccountId
				,0
				,@strMerchantCategory
				,@strTransactionType
				,'COMPANY OWNED'
				,1
				,1)
		END

		FETCH NEXT FROM @CursorTran INTO @intVendorId, @intPaymentMethodId, @intCustomerId, @intClearingAccountId, @intFeeExpenceAccountId, @strSite, @strSiteDescription, @strMerchantCategory, @strTransactionType, @strDealerSiteType, @dblSharedFeePercentage, @strPostNetToArCustomer
	END
	CLOSE @CursorTran
	DEALLOCATE @CursorTran

	INSERT INTO [dbo].[tblCCImportStatus]
           ([strImportType]
           ,[strDescription]
           ,[strSource]
           ,[ysnActive]
           ,[dtmImportDate]
           ,[intUserId])
     VALUES
           (@strImportType
           ,'CCR VENDOR DEALER SITE AND COMPANY OWNED INFORMATION - VENDOR SCREEN - CREDIT CARD RECON'
           ,@strSource
           ,1
           ,GETDATE()
           ,@intUserId)

	RETURN 1

END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	)
END CATCH