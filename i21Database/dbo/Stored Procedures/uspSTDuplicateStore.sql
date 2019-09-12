CREATE PROCEDURE [dbo].[uspSTDuplicateStore]
	@StoreId	NVARCHAR(MAX)
AS
BEGIN


BEGIN TRANSACTION

	BEGIN TRY

	DECLARE @NewStoreId INT

	--DETAILS & SETUP TAB--
	INSERT INTO tblSTStore
	(
		 intStoreNo
		,strDescription
		,strRegion
		,strDistrict
		,strAddress
		,strCity
		,strState
		,strCountry
		,strZipCode
		,strPhone
		,strFax
		,strEmail
		,strWebsite
		,intProfitCenter
		,ysnStoreOnHost
		,strPricebookAutomated
		,strHandheldCostBasis
		,intDefaultVendorId
		,intCompanyLocationId
		,strGLCoId
		,strARCoId
		,intNextOrderNo
		,ysnUsePricebook
		,intMaxPlu
		,ysnUseLargePlu
		,ysnUseCfn
		,strCfnSiteId
		,strManagersName
		,strManagersPassword
		,ysnInterfaceChecksToCheckbook
		,strCheckbook
		,strQuickbookInterfaceClass
		,strBarcodePrinterName
		,dblServiceChargeRate
		,ysnUseArStatements
		,dtmLastShiftOpenDate
		,intLastShiftNo
		,dtmLastPhysicalImportDate
		,dtmLastStatementRollDate
		,ysnShiftPhysicalQuantityRecieved
		,ysnShiftPhysicalQuantitySold
		,strHandheldDeviceModel
		,strDepositLookupType
		,intDefaultPaidoutId
		,intCustomerChargeMopId
		,intCashTransctionMopId
		,ysnAllowMassPriceChanges
		,ysnUsingTankMonitors
		,strRegisterName
		,intMaxRegisterPlu
		,strReportDepartmentAtGrossOrNet
		,intLoyaltyDiscountMopId
		,intLoyaltyDiscountCategoryId
		,ysnBreakoutPropCardTotal
		,intRemovePropCardMopId
		,intAddPropCardMopId
		,strPropNetworkCardName
		,strAllowRegisterMarkUpDown
		,strRegisterCheckoutDataEntry
		,strReconcileFuels
		,ysnRecieveProductByDepartment
		,ysnKeepArATStore
		,ysnUsingCheckWriter
		,ysnLoadFuelCost
		,ysnUseSafeFunds
		,ysnClearPricebookFieldsOnAdd
		,intNumberOfShifts
		,ysnUpdatePriceFromReciept
		,strGLSalesIndicator
		,ysnUpdateCaseCost
		,dtmInvoiceCloseDate
		,strTaxIdPassword
		,intRegisterId
		,dtmRegisterPricebookUpdateDate
		,dtmRegisterPricebookUpdateTime
		,dtmRegisterItemListUpdateDate
		,dtmRegisterItemListUpdateTime
		,dtmRegisterComboUpdateDate
		,dtmRegisterComboUpdateTime
		,dtmRegisterMixMatchUpdateDate
		,dtmRegisterMixMatchUpdateTime
		,intPassportFileNumber
		,strFalconDataPath
		,intFalconComPort
		,intFalconBaudRate
		,intInventoryCloseShiftNo
		,dtmInventoryCutoffDate
		,intInventoryCutoffShiftNo
		,dtmDepartmentLevelDate
		,strStatementFooter1
		,strStatementFooter2
		,strStatementFooter3
		,strStatementFooter4
		,intScnBackupSeqNo
		,intIpiBackupSeqNo
		,intRtlBackupSeqNo
		,intPhyBackupSeqNo
		,intBegVendorNumberId
		,intEndVendorNumberId
		,dtmBegReceiptDate
		,dtmEndReceiptDate
		,strBegOrderNo
		,strEndOrderNo
		,ysnRecieptErrors
		,dtmEndOfDayDate
		,intEndOfDayShiftNo
		,intTaxGroupId
		,intCheckoutCustomerId
		,intCustomerChargesItemId
		,intOverShortItemId
		,strStoreAppWebUrl
		,guidStoreAppConnectionId
		,strStoreAppMacAddress
		,dtmStoreAppLastDateLog
		,strHandheldScannerServerFolderPath
		,intConcurrencyId
	)
	SELECT TOP 1
		9999
		,strDescription
		,strRegion
		,strDistrict
		,strAddress
		,strCity
		,strState
		,strCountry
		,strZipCode
		,strPhone
		,strFax
		,strEmail
		,strWebsite
		,intProfitCenter
		,ysnStoreOnHost
		,strPricebookAutomated
		,strHandheldCostBasis
		,intDefaultVendorId
		,intCompanyLocationId
		,strGLCoId
		,strARCoId
		,intNextOrderNo
		,ysnUsePricebook
		,intMaxPlu
		,ysnUseLargePlu
		,ysnUseCfn
		,strCfnSiteId
		,strManagersName
		,strManagersPassword
		,ysnInterfaceChecksToCheckbook
		,strCheckbook
		,strQuickbookInterfaceClass
		,strBarcodePrinterName
		,dblServiceChargeRate
		,ysnUseArStatements
		,dtmLastShiftOpenDate
		,intLastShiftNo
		,dtmLastPhysicalImportDate
		,dtmLastStatementRollDate
		,ysnShiftPhysicalQuantityRecieved
		,ysnShiftPhysicalQuantitySold
		,strHandheldDeviceModel
		,strDepositLookupType
		,intDefaultPaidoutId
		,intCustomerChargeMopId
		,intCashTransctionMopId
		,ysnAllowMassPriceChanges
		,ysnUsingTankMonitors
		,strRegisterName
		,intMaxRegisterPlu
		,strReportDepartmentAtGrossOrNet
		,intLoyaltyDiscountMopId
		,intLoyaltyDiscountCategoryId
		,ysnBreakoutPropCardTotal
		,intRemovePropCardMopId
		,intAddPropCardMopId
		,strPropNetworkCardName
		,strAllowRegisterMarkUpDown
		,strRegisterCheckoutDataEntry
		,strReconcileFuels
		,ysnRecieveProductByDepartment
		,ysnKeepArATStore
		,ysnUsingCheckWriter
		,ysnLoadFuelCost
		,ysnUseSafeFunds
		,ysnClearPricebookFieldsOnAdd
		,intNumberOfShifts
		,ysnUpdatePriceFromReciept
		,strGLSalesIndicator
		,ysnUpdateCaseCost
		,dtmInvoiceCloseDate
		,strTaxIdPassword
		,intRegisterId
		,dtmRegisterPricebookUpdateDate
		,dtmRegisterPricebookUpdateTime
		,dtmRegisterItemListUpdateDate
		,dtmRegisterItemListUpdateTime
		,dtmRegisterComboUpdateDate
		,dtmRegisterComboUpdateTime
		,dtmRegisterMixMatchUpdateDate
		,dtmRegisterMixMatchUpdateTime
		,intPassportFileNumber
		,strFalconDataPath
		,intFalconComPort
		,intFalconBaudRate
		,intInventoryCloseShiftNo
		,dtmInventoryCutoffDate
		,intInventoryCutoffShiftNo
		,dtmDepartmentLevelDate
		,strStatementFooter1
		,strStatementFooter2
		,strStatementFooter3
		,strStatementFooter4
		,intScnBackupSeqNo
		,intIpiBackupSeqNo
		,intRtlBackupSeqNo
		,intPhyBackupSeqNo
		,intBegVendorNumberId
		,intEndVendorNumberId
		,dtmBegReceiptDate
		,dtmEndReceiptDate
		,strBegOrderNo
		,strEndOrderNo
		,ysnRecieptErrors
		,dtmEndOfDayDate
		,intEndOfDayShiftNo
		,intTaxGroupId
		,intCheckoutCustomerId
		,intCustomerChargesItemId
		,intOverShortItemId
		,strStoreAppWebUrl
		,guidStoreAppConnectionId
		,strStoreAppMacAddress
		,dtmStoreAppLastDateLog
		,''
		,intConcurrencyId
	FROM tblSTStore
	WHERE ISNULL(intStoreId,0) = ISNULL(@StoreId,0)

	SET @NewStoreId = SCOPE_IDENTITY()

	--REGISTER TAB--
	INSERT INTO tblSTRegister
	(
		 intStoreId
		,strRegisterName
		,strRegisterClass
		,ysnRegisterDataLoad
		,ysnCheckoutLoad
		,ysnPricebookBuild
		,ysnImportPricebook
		,ysnComboBuild
		,ysnMixMatchBuild
		,ysnItemListBuild
		,strRegisterPassword
		,strRubyPullType
		,intPortNumber
		,intLineSpeed
		,intDataBits
		,intStopBits
		,strParity
		,intTimeOut
		,ysnUseModem
		,strPhoneNumber
		,intNumberOfTerminals
		,ysnSupportComboSales
		,ysnSupportMixMatchSales
		,ysnDepartmentTotals
		,ysnPluItemTotals
		,ysnSummaryTotals
		,ysnCashierTotals
		,ysnElectronicJournal
		,ysnLoyaltyTotals
		,ysnProprietaryTotals
		,ysnPromotionTotals
		,ysnFuelTotals
		,ysnPayrollTimeWorked
		,ysnPaymentMethodTotals
		,ysnFuelTankTotals
		,ysnNetworkTotals
		,intPeriodNo
		,intSetNo
		,strSapphirePullType
		,strSapphireIpAddress
		,strSAPPHIREUserName
		,strSAPPHIREPassword
		,intSAPPHIRECheckoutPullTimePeriodId
		,intSAPPHIRECheckoutPullTimeSetId
		,ysnDealTotals
		,ysnHourlyTotals
		,ysnTaxTotals
		,ysnTransctionLog
		,ysnPostCashCardAsARDetail
		,intClubChargesCreditCardId
		,intFuelDriveOffMopId
		,strProgramPath
		,strWayneRegisterType
		,intMaxSkus
		,intWayneDefaultReportChain
		,intDiscountMopId
		,strUpdateSalesFrom
		,intBaudRate
		,intWayneComPort
		,intPCIriqForComPort
		,strWaynePassWord
		,intWayneSequenceNo
		,strXmlVersion
		,strRegisterInboxPath
		,strRegisterOutboxPath
		,strRegisterStoreId
		,intTaxStrategyIdForTax1
		,intTaxStrategyIdForTax2
		,intTaxStrategyIdForTax3
		,intTaxStrategyIdForTax4
		,intNonTaxableStrategyId
		,ysnSupportPropFleetCards
		,intDebitCardMopId
		,intLotteryWinnersMopId
		,ysnCreateCfnAtImport
		,strFTPPath
		,strFTPUserName
		,strFTPPassword
		,strArchivePath
		,intPurgeInterval
		,intConcurrencyId
	)
	SELECT
		 @NewStoreId
		,strRegisterName
		,strRegisterClass
		,ysnRegisterDataLoad
		,ysnCheckoutLoad
		,ysnPricebookBuild
		,ysnImportPricebook
		,ysnComboBuild
		,ysnMixMatchBuild
		,ysnItemListBuild
		,strRegisterPassword
		,strRubyPullType
		,intPortNumber
		,intLineSpeed
		,intDataBits
		,intStopBits
		,strParity
		,intTimeOut
		,ysnUseModem
		,strPhoneNumber
		,intNumberOfTerminals
		,ysnSupportComboSales
		,ysnSupportMixMatchSales
		,ysnDepartmentTotals
		,ysnPluItemTotals
		,ysnSummaryTotals
		,ysnCashierTotals
		,ysnElectronicJournal
		,ysnLoyaltyTotals
		,ysnProprietaryTotals
		,ysnPromotionTotals
		,ysnFuelTotals
		,ysnPayrollTimeWorked
		,ysnPaymentMethodTotals
		,ysnFuelTankTotals
		,ysnNetworkTotals
		,intPeriodNo
		,intSetNo
		,strSapphirePullType
		,strSapphireIpAddress
		,strSAPPHIREUserName
		,strSAPPHIREPassword
		,intSAPPHIRECheckoutPullTimePeriodId
		,intSAPPHIRECheckoutPullTimeSetId
		,ysnDealTotals
		,ysnHourlyTotals
		,ysnTaxTotals
		,ysnTransctionLog
		,ysnPostCashCardAsARDetail
		,intClubChargesCreditCardId
		,intFuelDriveOffMopId
		,strProgramPath
		,strWayneRegisterType
		,intMaxSkus
		,intWayneDefaultReportChain
		,intDiscountMopId
		,strUpdateSalesFrom
		,intBaudRate
		,intWayneComPort
		,intPCIriqForComPort
		,strWaynePassWord
		,intWayneSequenceNo
		,strXmlVersion
		,strRegisterInboxPath
		,strRegisterOutboxPath
		,strRegisterStoreId
		,intTaxStrategyIdForTax1
		,intTaxStrategyIdForTax2
		,intTaxStrategyIdForTax3
		,intTaxStrategyIdForTax4
		,intNonTaxableStrategyId
		,ysnSupportPropFleetCards
		,intDebitCardMopId
		,intLotteryWinnersMopId
		,ysnCreateCfnAtImport
		,strFTPPath
		,strFTPUserName
		,strFTPPassword
		,strArchivePath
		,intPurgeInterval
		,intConcurrencyId
		FROM tblSTRegister 
		WHERE intStoreId = @StoreId


	DECLARE @intRegisterId INT
	SET @intRegisterId = SCOPE_IDENTITY()


	DECLARE @intOldRegisterId INT
	SELECT TOP 1 @intOldRegisterId = intRegisterId
	FROM tblSTRegister 
	WHERE intStoreId = @StoreId



	INSERT INTO tblSTRegisterFileConfiguration
	(
		 intRegisterId
		,intImportFileHeaderId
		,strFileType
		,strFilePrefix
		,strFileNamePattern
		,strFolderPath
		,strURICommand
		,strStoredProcedure
		,intConcurrencyId
	)
	SELECT
		@intRegisterId
		,intImportFileHeaderId
		,strFileType
		,strFilePrefix
		,strFileNamePattern
		,strFolderPath
		,strURICommand
		,strStoredProcedure
		,intConcurrencyId
	FROM 
	tblSTRegisterFileConfiguration WHERE intRegisterId = @intOldRegisterId

	

	--REBASTES TAB--
	INSERT INTO tblSTStoreRebates
	(
		 intStoreId
		,intCategoryId
		,ysnTobacco
		,intConcurrencyId
	)
	SELECT
		@NewStoreId
		,intCategoryId
		,ysnTobacco
		,intConcurrencyId
	FROM tblSTStoreRebates
	WHERE intStoreId = @StoreId

	--REGISTER PRODUCT--
	INSERT INTO tblSTSubcategoryRegProd
	(
		 intStoreId
		,strRegProdCode
		,strRegProdDesc
		,strRegProdComment  
		,intConcurrencyId
	)
	SELECT 
		 @NewStoreId
		,strRegProdCode
		,strRegProdDesc
		,strRegProdComment  
		,intConcurrencyId
	FROM
	tblSTSubcategoryRegProd
	WHERE intStoreId = @StoreId

	--PAYMENT OPTION-- 
	INSERT INTO tblSTPaymentOption
	(
		 intStoreId
		,strPaymentOptionId
		,strDescription
		,intItemId
		,intAccountId
		,strRegisterMop
		,ysnDepositable
		,intConcurrencyId
	)
	SELECT 
		@NewStoreId
		,strPaymentOptionId
		,strDescription
		,intItemId
		,intAccountId
		,strRegisterMop
		,ysnDepositable
		,intConcurrencyId
	FROM 
	tblSTPaymentOption
	WHERE intStoreId = @StoreId

	--PUMP ITEM--
	INSERT INTO tblSTPumpItem
	(
		 intStoreId
		,intItemUOMId
		,dblPrice
		,intTaxGroupId
		,intCategoryId
		,intConcurrencyId
	)
	SELECT 
		@NewStoreId
		,intItemUOMId
		,dblPrice
		,intTaxGroupId
		,intCategoryId
		,intConcurrencyId
	FROM 
	tblSTPumpItem
	WHERE intStoreId = @StoreId

	--TAX TOTALS--
	INSERT INTO tblSTStoreTaxTotals
	(
		 intStoreId
		,intTaxCodeId
		,intItemId
		,intConcurrencyId
	)
	SELECT 
		@NewStoreId
		,intTaxCodeId
		,intItemId
		,intConcurrencyId
	FROM 
	tblSTStoreTaxTotals
	WHERE intStoreId = @StoreId


	COMMIT TRANSACTION

	SELECT TOP 1
	 intStoreId
	,intStoreNo
	,CAST(1 as BIT) as ysnResult
	FROM tblSTStore
	WHERE intStoreId = @NewStoreId
	

	END TRY
	BEGIN CATCH

	SELECT ERROR_MESSAGE()

	ROLLBACK TRANSACTION

	SELECT TOP 1
	 0 as intStoreId
	,'' as intStoreNo
	,CAST(0 as BIT) as ysnResult

	END CATCH
	
END