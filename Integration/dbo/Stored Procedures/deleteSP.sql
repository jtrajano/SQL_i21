IF EXISTS(select top 1 1 from sys.procedures where name = 'uspGRImportStorageType')
	DROP PROCEDURE uspGRImportStorageType
GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspGRImportWeightGrades')
	DROP PROCEDURE uspGRImportWeightGrades
GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspGRImportShipTo')
	DROP PROCEDURE uspGRImportShipTo
GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspMFImportRecipe')
	DROP PROCEDURE uspMFImportRecipe
GO

IF EXISTS (select top 1 1 from sys.procedures where name = 'uspTRImportRackPrice')
	DROP PROCEDURE uspTRImportRackPrice
GO

IF EXISTS (select top 1 1 from sys.procedures where name = 'uspTRImportOriginHistory')
	DROP PROCEDURE uspTRImportOriginHistory
GO

IF EXISTS (select top 1 1 from sys.procedures where name = 'uspTRImportSupplyPoint')
	DROP PROCEDURE uspTRImportSupplyPoint
GO

IF EXISTS (select top 1 1 from sys.procedures where name = 'uspTRImportSupplyPointProductSearch')
	DROP PROCEDURE uspTRImportSupplyPointProductSearch
GO

IF EXISTS (select top 1 1 from sys.procedures where name = 'uspTRImportSupplyPointRackPriceEquation')
	DROP PROCEDURE uspTRImportSupplyPointRackPriceEquation
GO

IF EXISTS (select top 1 1 from sys.procedures where name = 'uspTRImportTruck')
	DROP PROCEDURE uspTRImportTruck
GO

IF EXISTS (select top 1 1 from sys.procedures where name = 'uspLGImportEquipmentType')
	DROP PROCEDURE uspLGImportEquipmentType
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspETRecreateDeliveryMetricsView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspETRecreateDeliveryMetricsView
GO

IF EXISTS (select top 1 1 from sys.procedures where name = 'uspEMImportPTTerminalToCustomer')
	DROP PROCEDURE uspEMImportPTTerminalToCustomer
GO

IF EXISTS (select top 1 1 from sys.procedures where name = 'uspARImportPTTaxExemption')
	DROP PROCEDURE uspARImportPTTaxExemption
GO

IF EXISTS (select top 1 1 from sys.procedures where name = 'uspAPImportVendorTaxExemption')
	DROP PROCEDURE uspAPImportVendorTaxExemption
GO

IF EXISTS (select top 1 1 from sys.procedures where name = 'uspARImportCustomerComments')
	DROP PROCEDURE uspARImportCustomerComments
GO


