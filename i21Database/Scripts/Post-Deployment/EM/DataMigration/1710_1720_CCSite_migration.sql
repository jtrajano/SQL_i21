PRINT '*** Start 1710-1720 Site Migration***'
IF NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = '1710-1720 Site Migration')
BEGIN
	PRINT '*** EXECUTE ***'

	IF OBJECT_ID('tempdb..#Tmp_DealerSite') IS NOT NULL DROP TABLE #Tmp_DealerSite 

	SELECT * INTO #Tmp_DealerSite FROM tblCCDealerSite

	IF OBJECT_ID('tempdb..#Tmp_CompanyOwnedSite') IS NOT NULL DROP TABLE Tmp_CompanyOwnedSite

	SELECT * INTO #Tmp_CompanyOwnedSite FROM tblCCCompanyOwnedSite

	DECLARE @id INT

	UPDATE a SET 

			a.intVendorDefaultId = b.intVendorDefaultId,
			a.intAccountId = b.intAccountId,
			a.intFeeExpenseAccountId = b.intFeeExpenseAccountId,
			a.ysnPostNetToArCustomer = b.ysnPostNetToArCustomer,
			a.strMerchantCategory = b.strMerchantCategory,
			a.strTransactionType = b.strTransactionType,
			a.ysnSharedFee = b.ysnSharedFee,
			a.intSharedFeePercentage = b.intSharedFeePercentage,
			a.dblSharedFeePercentage = b.dblSharedFeePercentage,
			a.strType = 'DEALER'							
			FROM tblCCSite a
				JOIN #Tmp_DealerSite b
					ON a.intDealerSiteId = b.intDealerSiteId


	UPDATE a SET
			
			a.intVendorDefaultId = b.intVendorDefaultId,
			a.intAccountId = b.intCreditCardReceivableAccountId,
			a.intFeeExpenseAccountId = b.intFeeExpenseAccountId,
			a.ysnPassedThruArCustomer = b.ysnPassedThruArCustomer,
			a.strType = 'COMPANY OWNED'							

			FROM tblCCSite a
				JOIN #Tmp_CompanyOwnedSite b
					ON a.intCompanyOwnedSiteId = b.intCompanyOwnedSiteId	

	
	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('1710-1720 Site Migration', 1)
END
PRINT '*** End 1710-1720 Site Migration***'