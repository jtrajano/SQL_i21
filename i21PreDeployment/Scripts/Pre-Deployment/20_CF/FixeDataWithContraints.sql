IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblCFCard')
BEGIN
	print 'begin updating card data'
	update tblCFCard set intExpenseItemId = NULL where intExpenseItemId = 0
	update tblCFCard set intDepartmentId = NULL where intDepartmentId = 0
	update tblCFCard set intCardTypeId = NULL where intCardTypeId = 0
	update tblCFCard set intDefaultFixVehicleNumber = NULL where intDefaultFixVehicleNumber = 0
	update tblCFCard set intNetworkId = NULL where intNetworkId = 0
	print 'end updating card data'
END

IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblCFCreditCard')
BEGIN
	print 'begin updating credit card data'
	update tblCFCreditCard set intCustomerId = NULL where intCustomerId = 0
	print 'end updating credit card data'
END

IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblCFIndexPricingBySiteGroup')
BEGIN
	print 'begin updating index pricing by site group data'
	update tblCFIndexPricingBySiteGroup set intIndexPricingBySiteGroupHeaderId = NULL where intIndexPricingBySiteGroupHeaderId = 0
	update tblCFIndexPricingBySiteGroup set intARItemID = NULL where intARItemID = 0
	print 'end updating index pricing By site group data'
END

IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblCFItem')
BEGIN
	print 'begin updating item data'
	update tblCFItem set intARItemId = NULL where intARItemId = 0
	update tblCFItem set intTaxGroupMaster = NULL where intTaxGroupMaster = 0
	print 'end updating item data'
END

IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblCFNetwork')
BEGIN
	print 'begin updating network data'
	update tblCFNetwork set intCustomerId = NULL where intCustomerId = 0
	update tblCFNetwork set intLocationId = NULL where intLocationId = 0
	update tblCFNetwork set intImportMapperId = NULL where intImportMapperId = 0
	print 'end updating network data'
END

IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblCFPriceProfileDetail')
BEGIN
	print 'begin updating price profile detail data'
	update tblCFPriceProfileDetail set intItemId = NULL where intItemId = 0
	print 'end updating price profile detail data'
END

IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblCFSiteGroupPriceAdjustment')
BEGIN
	print 'begin updating site group price adjustment data'
	update tblCFPriceProfileDetail set intSiteGroupId = NULL where intSiteGroupId = 0
	update tblCFPriceProfileDetail set intItemId = NULL where intItemId = 0
	
	print 'end updating site group price adjustment data'
END

IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblCFSite')
BEGIN
	print 'begin updating site data'
	update tblCFSite set intNetworkId = NULL where intNetworkId = 0
	update tblCFSite set intARLocationId = NULL where intARLocationId = 0
	update tblCFSite set intImportMapperId = NULL where intImportMapperId = 0
	update tblCFSite set intCashCustomerID = NULL where intCashCustomerID = 0
	update tblCFSite set intAdjustmentSiteGroupId = NULL where intAdjustmentSiteGroupId = 0
	print 'end updating site data'
END

IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblCFTransaction')
BEGIN
	print 'begin updating transaction data'
	update tblCFTransaction set intNetworkId = NULL where intNetworkId = 0
	update tblCFTransaction set intSiteId = NULL where intSiteId = 0
	update tblCFTransaction set intCardId = NULL where intCardId = 0
	update tblCFTransaction set intVehicleId = NULL where intVehicleId = 0
	update tblCFTransaction set intSalesPersonId = NULL where intSalesPersonId = 0
	print 'end updating transaction data'
END

IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblCFVehicle')
BEGIN
	print 'begin updating vehicle data'
	update tblCFVehicle set intExpenseItemId = NULL where intExpenseItemId = 0
	print 'end updating vehicle data'
END
