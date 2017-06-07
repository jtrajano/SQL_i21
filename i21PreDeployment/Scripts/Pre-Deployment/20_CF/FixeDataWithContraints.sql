IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblCFCard')
BEGIN
	print 'begin updating card data'
	
	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFCard'AND COLUMN_NAME = 'intExpenseItemId')
	BEGIN
		EXEC ('update tblCFCard set intExpenseItemId = NULL where intExpenseItemId = 0')
	END

	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFCard'AND COLUMN_NAME = 'intDepartmentId')
	BEGIN
		EXEC ('update tblCFCard set intDepartmentId = NULL where intDepartmentId = 0')
	END

	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFCard'AND COLUMN_NAME = 'intCardTypeId')
	BEGIN
		EXEC ('update tblCFCard set intCardTypeId = NULL where intCardTypeId = 0')
	END

	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFCard'AND COLUMN_NAME = 'intDefaultFixVehicleNumber')
	BEGIN
		EXEC ('update tblCFCard set intDefaultFixVehicleNumber = NULL where intDefaultFixVehicleNumber = 0')
	END

	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFCard'AND COLUMN_NAME = 'intNetworkId')
	BEGIN
		EXEC ('update tblCFCard set intNetworkId = NULL where intNetworkId = 0')
	END
	print 'end updating card data'
END

IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblCFCreditCard')
BEGIN
	print 'begin updating credit card data'

	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFCreditCard'AND COLUMN_NAME = 'intCustomerId')
	BEGIN
		EXEC ('update tblCFCreditCard set intCustomerId = NULL where intCustomerId = 0')
	END
	print 'end updating credit card data'
END

IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblCFIndexPricingBySiteGroup')
BEGIN
	print 'begin updating index pricing by site group data'
	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFIndexPricingBySiteGroup'AND COLUMN_NAME = 'intIndexPricingBySiteGroupHeaderId')
	BEGIN
		EXEC ('update tblCFIndexPricingBySiteGroup set intIndexPricingBySiteGroupHeaderId = NULL where intIndexPricingBySiteGroupHeaderId = 0')
	END
	
	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFIndexPricingBySiteGroup'AND COLUMN_NAME = 'intARItemID')
	BEGIN
		EXEC ('update tblCFIndexPricingBySiteGroup set intARItemID = NULL where intARItemID = 0')
	END
	print 'end updating index pricing By site group data'
END

IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblCFItem')
BEGIN
	print 'begin updating item data'
	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFItem'AND COLUMN_NAME = 'intARItemId')
	BEGIN
		EXEC ('update tblCFItem set intARItemId = NULL where intARItemId = 0')
	END
	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFItem'AND COLUMN_NAME = 'intTaxGroupMaster')
	BEGIN
		EXEC ('update tblCFItem set intTaxGroupMaster = NULL where intTaxGroupMaster = 0')
	END
	print 'end updating item data'
END

IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblCFNetwork')
BEGIN
	print 'begin updating network data'
	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFNetwork'AND COLUMN_NAME = 'intCustomerId')
	BEGIN
		EXEC ('update tblCFNetwork set intCustomerId = NULL where intCustomerId = 0')
	END
	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFNetwork'AND COLUMN_NAME = 'intLocationId')
	BEGIN
		EXEC ('update tblCFNetwork set intLocationId = NULL where intLocationId = 0')
	END
	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFNetwork'AND COLUMN_NAME = 'intImportMapperId')
	BEGIN
		EXEC ('update tblCFNetwork set intImportMapperId = NULL where intImportMapperId = 0')
	END
	print 'end updating network data'
END

IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblCFPriceProfileDetail')
BEGIN
	print 'begin updating price profile detail data'
	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFPriceProfileDetail'AND COLUMN_NAME = 'intItemId')
	BEGIN
		EXEC ('update tblCFPriceProfileDetail set intItemId = NULL where intItemId = 0')
	END
	
	print 'end updating price profile detail data'
END

IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblCFSiteGroupPriceAdjustment')
BEGIN
	print 'begin updating site group price adjustment data'
	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFSiteGroupPriceAdjustment'AND COLUMN_NAME = 'intSiteGroupId')
	BEGIN
		EXEC ('update tblCFSiteGroupPriceAdjustment set intSiteGroupId = NULL where intSiteGroupId = 0')
	END
	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFSiteGroupPriceAdjustment'AND COLUMN_NAME = 'intItemId')
	BEGIN
		EXEC ('update tblCFSiteGroupPriceAdjustment set intItemId = NULL where intItemId = 0')
	END
	print 'end updating site group price adjustment data'
END

IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblCFSite')
BEGIN
	print 'begin updating site data'
	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFSite'AND COLUMN_NAME = 'intNetworkId')
	BEGIN
		EXEC ('update tblCFSite set intNetworkId = NULL where intNetworkId = 0')
	END
	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFSite'AND COLUMN_NAME = 'intARLocationId')
	BEGIN
		EXEC ('update tblCFSite set intARLocationId = NULL where intARLocationId = 0')
	END
	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFSite'AND COLUMN_NAME = 'intImportMapperId')
	BEGIN
		EXEC ('update tblCFSite set intImportMapperId = NULL where intImportMapperId = 0')
	END
	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFSite'AND COLUMN_NAME = 'intCashCustomerID')
	BEGIN
		EXEC ('update tblCFSite set intCashCustomerID = NULL where intCashCustomerID = 0')
	END
	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFSite'AND COLUMN_NAME = 'intAdjustmentSiteGroupId')
	BEGIN
		EXEC ('update tblCFSite set intAdjustmentSiteGroupId = NULL where intAdjustmentSiteGroupId = 0')
	END
	print 'end updating site data'
END

IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblCFTransaction')
BEGIN
	print 'begin updating transaction data'
	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFTransaction'AND COLUMN_NAME = 'intNetworkId')
	BEGIN
		EXEC ('update tblCFTransaction set intNetworkId = NULL where intNetworkId = 0')
	END
	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFTransaction'AND COLUMN_NAME = 'intSiteId')
	BEGIN
		EXEC ('update tblCFTransaction set intSiteId = NULL where intSiteId = 0')
	END
	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFTransaction'AND COLUMN_NAME = 'intCardId')
	BEGIN
		EXEC ('update tblCFTransaction set intCardId = NULL where intCardId = 0')
	END
	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFTransaction'AND COLUMN_NAME = 'intVehicleId')
	BEGIN
		EXEC ('update tblCFTransaction set intVehicleId = NULL where intVehicleId = 0')
	END
	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFTransaction'AND COLUMN_NAME = 'intSalesPersonId')
	BEGIN
		EXEC ('update tblCFTransaction set intSalesPersonId = NULL where intSalesPersonId = 0')
	END
	print 'end updating transaction data'
END

IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblCFVehicle')
BEGIN
	print 'begin updating vehicle data'
	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFVehicle'AND COLUMN_NAME = 'intExpenseItemId')
	BEGIN
		EXEC ('update tblCFVehicle set intExpenseItemId = NULL where intExpenseItemId = 0')
	END
	
	print 'end updating vehicle data'
END


IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblCFAccount')
BEGIN
	print 'begin updating account data'
	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFAccount'AND COLUMN_NAME = 'intFeeProfileId')
	BEGIN
		EXEC ('update tblCFAccount set intFeeProfileId = NULL where intFeeProfileId = 0')
	END

	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFAccount'AND COLUMN_NAME = 'intLocalPriceProfileId')
	BEGIN
		EXEC ('update tblCFAccount set intLocalPriceProfileId = NULL where intLocalPriceProfileId = 0')
	END

	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFAccount'AND COLUMN_NAME = 'intRemotePriceProfileId')
	BEGIN
		EXEC ('update tblCFAccount set intRemotePriceProfileId = NULL where intRemotePriceProfileId = 0')
	END

	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFAccount'AND COLUMN_NAME = 'intExtRemotePriceProfileId')
	BEGIN
		EXEC ('update tblCFAccount set intExtRemotePriceProfileId = NULL where intExtRemotePriceProfileId = 0')
	END
	
	print 'end updating account data'
END


IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblCFAccount')
BEGIN
	print 'begin updating account data'
	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFAccount'AND COLUMN_NAME = 'intPriceRuleGroup')
	BEGIN
		EXEC ('update tblCFAccount set intPriceRuleGroup = NULL where intPriceRuleGroup = 0')
	END
	
	print 'end updating account data'
END


IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblCFPriceProfileDetail')
BEGIN
	print 'begin updating account data'
	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFPriceProfileDetail'AND COLUMN_NAME = 'intPriceIndexId')
	BEGIN
		EXEC ('update tblCFPriceProfileDetail set intPriceIndexId = NULL where intPriceIndexId = 0')
	END
	
	print 'end updating account data'
END



IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblCFPriceProfileDetail')
BEGIN
	print 'begin updating account data'
	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFPriceProfileDetail'AND COLUMN_NAME = 'intLocalPricingIndex')
	BEGIN
		EXEC ('update tblCFPriceProfileDetail set intLocalPricingIndex = NULL where intLocalPricingIndex = 0')
	END
	
	print 'end updating account data'
END


IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblCFTransactionTax')
BEGIN
	print 'remove orphan transaction tax'
	IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblCFTransactionTax'AND COLUMN_NAME = 'intTaxCodeId')
	BEGIN
		IF EXISTS(SELECT 1 FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblSMTaxCode'AND COLUMN_NAME = 'intTaxCodeId')
		BEGIN
			EXEC ('delete from tblCFTransactionTax where intTaxCodeId not in (SELECT intTaxCodeId FROM tblSMTaxCode)')
		END
	END
	
	print 'remove orphan transaction tax'
END



IF EXISTS(SELECT * FROM sys.indexes WHERE name = 'tblCFSite_UniqueNetworkSiteName' AND object_id = OBJECT_ID('tblCFSite'))
BEGIN
	print 'drop tblCFSite_UniqueNetworkSiteName index'
	DROP INDEX tblCFSite_UniqueNetworkSiteName ON tblCFSite
	print 'drop tblCFSite_UniqueNetworkSiteName index'
END