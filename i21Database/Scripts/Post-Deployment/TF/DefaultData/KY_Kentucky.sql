IF EXISTS(SELECT TOP 1 1 FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'KY')
BEGIN
	PRINT ('Deploying Kentucky Tax Forms')
END
GO

DECLARE @TaxAuthorityCode NVARCHAR(10) = 'KY'
	, @TaxAuthorityId INT

SELECT @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = @TaxAuthorityCode

IF(@TaxAuthorityId IS NOT NULL)
BEGIN
-- Product Codes
/* Generate script for Product Codes. Specify Tax Authority Id to filter out specific Product Codes only.
select 'UNION ALL SELECT intProductCodeId = ' + CAST(0 AS NVARCHAR(10)) 
	+ CASE WHEN strProductCode IS NULL THEN ', strProductCode = NULL' ELSE ', strProductCode = ''' + strProductCode + ''''  END
	+ CASE WHEN strDescription IS NULL THEN ', strDescription = NULL' ELSE ', strDescription = ''' + strDescription + ''''  END
	+ CASE WHEN strProductCodeGroup IS NULL THEN ', strProductCodeGroup = NULL' ELSE ', strProductCodeGroup = ''' + strProductCodeGroup + ''''  END
	+ CASE WHEN strNote IS NULL THEN ', strNote = NULL' ELSE ', strNote = ''' + strNote + '''' END 
--	+ ', intMasterId = ' + CAST((CASE WHEN ISNULL(intMasterId, '') = '' THEN intProductCodeId ELSE intMasterId END) AS NVARCHAR(20)) -- Old Format
	+ ', intMasterId = ' + CASE WHEN intMasterId IS NULL THEN CAST(@TaxAuthorityId AS NVARCHAR(20)) + CAST(intProductCodeId AS NVARCHAR(20)) ELSE CAST(intMasterId AS NVARCHAR(20)) END -- First 2 digit for TaxAuthorityCodeID
from tblTFProductCode
where intTaxAuthorityId = @TaxAuthorityId
*/
	DECLARE @ProductCodes AS TFProductCodes

	INSERT INTO @ProductCodes (
		intProductCodeId
		, strProductCode
		, strDescription
		, strProductCodeGroup
		, strNote
		, intMasterId
	)
	SELECT intProductCodeId = 0, strProductCode = '061', strDescription = 'Natural Gasoline', strProductCodeGroup = 'GA (Gasoline)', strNote = NULL, intMasterId = 171016
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '065', strDescription = 'Gasoline', strProductCodeGroup = 'GA (Gasoline)', strNote = NULL, intMasterId = 171017
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '071', strDescription = 'Gasoline MTBE', strProductCodeGroup = 'GA (Gasoline)', strNote = NULL, intMasterId = 171018
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '092', strDescription = 'Undefined Products (Transmix)', strProductCodeGroup = 'GA (Gasoline)', strNote = NULL, intMasterId = 171019
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '122', strDescription = 'Blending Components', strProductCodeGroup = 'GA (Gasoline)', strNote = NULL, intMasterId = 171020
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '123', strDescription = 'Alcohol', strProductCodeGroup = 'GA (Gasoline)', strNote = NULL, intMasterId = 171021
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '124', strDescription = 'Gasohol', strProductCodeGroup = 'GA (Gasoline)', strNote = NULL, intMasterId = 171022
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '125', strDescription = 'Aviation Gasoline', strProductCodeGroup = 'GA (Gasoline)', strNote = NULL, intMasterId = 171023
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '280', strDescription = 'Marine Gas Oil', strProductCodeGroup = 'GA (Gasoline)', strNote = NULL, intMasterId = 171024
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'E00', strDescription = 'Ethanol (100%)', strProductCodeGroup = 'GA (Gasoline)', strNote = NULL, intMasterId = 171025
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'E10', strDescription = 'Ethanol (10%)', strProductCodeGroup = 'GA (Gasoline)', strNote = NULL, intMasterId = 171026
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'E85', strDescription = 'Ethanol (85%)', strProductCodeGroup = 'GA (Gasoline)', strNote = NULL, intMasterId = 171027
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'M00', strDescription = 'Methanol (100%)', strProductCodeGroup = 'GA (Gasoline)', strNote = NULL, intMasterId = 171028
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '072', strDescription = 'Kerosene - Dyed', strProductCodeGroup = 'SF (Special Fuels)', strNote = NULL, intMasterId = 171029
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '073', strDescription = 'Low Sulfur Kerosene - Dyed', strProductCodeGroup = 'SF (Special Fuels)', strNote = NULL, intMasterId = 171030
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '074', strDescription = 'High Sulfur Kerosene - Dyed', strProductCodeGroup = 'SF (Special Fuels)', strNote = NULL, intMasterId = 171031
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '090', strDescription = 'Additive Misc. (Blending)', strProductCodeGroup = 'SF (Special Fuels)', strNote = NULL, intMasterId = 171032
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '100', strDescription = 'Transmix', strProductCodeGroup = 'SF (Special Fuels)', strNote = NULL, intMasterId = 171033
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '142', strDescription = 'Kerosene - Undyed', strProductCodeGroup = 'SF (Special Fuels)', strNote = NULL, intMasterId = 171034
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '145', strDescription = 'Low Sulfur Kerosene - Undyed', strProductCodeGroup = 'SF (Special Fuels)', strNote = NULL, intMasterId = 171035
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '147', strDescription = 'High Sulfur Kerosene - Undyed', strProductCodeGroup = 'SF (Special Fuels)', strNote = NULL, intMasterId = 171036
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '150', strDescription = 'No. 1 Fuel Oil - Undyed', strProductCodeGroup = 'SF (Special Fuels)', strNote = NULL, intMasterId = 171037
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '152', strDescription = 'Heating Oil', strProductCodeGroup = 'SF (Special Fuels)', strNote = NULL, intMasterId = 171038
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '160', strDescription = 'Diesel Fuel - Undyed', strProductCodeGroup = 'SF (Special Fuels)', strNote = NULL, intMasterId = 171039
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '161', strDescription = 'Low Sulfur Diesel #1 - Undyed', strProductCodeGroup = 'SF (Special Fuels)', strNote = NULL, intMasterId = 171040
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '167', strDescription = 'Low Sulfur Diesel #2 - Undyed', strProductCodeGroup = 'SF (Special Fuels)', strNote = NULL, intMasterId = 171041
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '224', strDescription = 'Comprssed Natural Gas (CNG)', strProductCodeGroup = 'SF (Special Fuels)', strNote = NULL, intMasterId = 171042
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '225', strDescription = 'Liquid Natural Gas (LNG)', strProductCodeGroup = 'SF (Special Fuels)', strNote = NULL, intMasterId = 171043
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '226', strDescription = 'High Sulfur Diesel - Dyed', strProductCodeGroup = 'SF (Special Fuels)', strNote = NULL, intMasterId = 171044
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '227', strDescription = 'Low Sulfur Diesel - Dyed', strProductCodeGroup = 'SF (Special Fuels)', strNote = NULL, intMasterId = 171045
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '228', strDescription = 'Diesel Fuel - Dyed', strProductCodeGroup = 'SF (Special Fuels)', strNote = NULL, intMasterId = 171046
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '231', strDescription = 'No. 1 Fuel Oil - Dyed', strProductCodeGroup = 'SF (Special Fuels)', strNote = NULL, intMasterId = 171047
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '279', strDescription = 'Marine Diesel Oil', strProductCodeGroup = 'SF (Special Fuels)', strNote = NULL, intMasterId = 171048
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '283', strDescription = 'High Sulfur Diesel #2- Undyed', strProductCodeGroup = 'SF (Special Fuels)', strNote = NULL, intMasterId = 171049
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'B00', strDescription = 'Biodiesel (100%) - Undyed', strProductCodeGroup = 'SF (Special Fuels)', strNote = NULL, intMasterId = 171050
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'B11', strDescription = 'Biodiesel (11%) - Undyed', strProductCodeGroup = 'SF (Special Fuels)', strNote = NULL, intMasterId = 171051
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'D00', strDescription = 'Biodiesel (100%) - Dyed', strProductCodeGroup = 'SF (Special Fuels)', strNote = NULL, intMasterId = 171052
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '054', strDescription = 'Propane', strProductCodeGroup = 'LP', strNote = NULL, intMasterId = 171053

	EXEC uspTFUpgradeProductCodes @TaxAuthorityCode = @TaxAuthorityCode, @ProductCodes = @ProductCodes


-- Reporting Component
/* Generate script for Reporting Components. Specify Tax Authority Id to filter out specific Reporting Components only.
select 'UNION ALL SELECT intReportingComponentId = ' + CAST(0 AS NVARCHAR(10))
	+ CASE WHEN strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strFormName IS NULL THEN ', strFormName = NULL' ELSE ', strFormName = ''' + strFormName + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN strScheduleName IS NULL THEN ', strScheduleName = NULL' ELSE ', strScheduleName = ''' + strScheduleName + '''' END 
	+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END
	+ CASE WHEN strNote IS NULL THEN ', strNote = NULL' ELSE ', strNote = ''' + strNote + '''' END
	+ CASE WHEN strTransactionType IS NULL THEN ', strTransactionType = NULL' ELSE ', strTransactionType = ''' + strTransactionType + '''' END
	+ CASE WHEN intSort IS NULL THEN ', intSort = NULL' ELSE ', intSort = ' + CAST(intSort AS NVARCHAR(10)) END
	+ CASE WHEN strStoredProcedure IS NULL THEN ', strStoredProcedure = NULL' ELSE ', strStoredProcedure = ''' + strStoredProcedure + '''' END
--	+ ', intMasterId = ' + CAST((CASE WHEN ISNULL(intMasterId, '') = '' THEN intReportingComponentId ELSE intMasterId END) AS NVARCHAR(20)) -- Old Format
	+ ', intMasterId = ' + CASE WHEN intMasterId IS NULL THEN CAST(@TaxAuthorityId AS NVARCHAR(20)) + CAST(intReportingComponentId AS NVARCHAR(20)) ELSE CAST(intMasterId AS NVARCHAR(20)) END -- First 2 digit for TaxAuthorityCodeID
	+ CASE WHEN intComponentTypeId IS NULL THEN ', intComponentTypeId = NULL' ELSE ', intComponentTypeId = ' + CAST(intComponentTypeId AS NVARCHAR(10)) END
from tblTFReportingComponent
where intTaxAuthorityId = @TaxAuthorityId
*/
	DECLARE @ReportingComponent AS TFReportingComponent

	INSERT INTO @ReportingComponent(
		intReportingComponentId
		, strFormCode
		, strFormName
		, strScheduleCode
		, strScheduleName
		, strType
		, strNote
		, strTransactionType
		, intSort
		, strStoredProcedure
		, intMasterId
		, intComponentTypeId
	)
	SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '1', strScheduleName = 'Received, KY Tax Paid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 10, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 172056, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '2', strScheduleName = 'Received from Licensed Distributor, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 20, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 172057, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '2A', strScheduleName = 'Received from Terminals, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 30, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 172058, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '2B', strScheduleName = 'Blendable Stock Received, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 40, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 172059, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '3_IL', strScheduleName = 'Imported from IL, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 50, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 172060, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '3_IN', strScheduleName = 'Imported from IN, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 60, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 172061, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '3_TN', strScheduleName = 'Imported from TN, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 70, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 172062, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '5D_IL', strScheduleName = 'Sold for Import from IL, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 80, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172063, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '5D_IN', strScheduleName = 'Sold for Import from IN, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 90, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172064, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '5D_TN', strScheduleName = 'Sold for Import from TN, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 100, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172065, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '6', strScheduleName = 'Delivered to Licensed Distributors, KY Tax Not Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 110, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172066, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '7_IL', strScheduleName = 'Exported to IL', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 120, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172067, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '7_IN', strScheduleName = 'Exported to IN', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 130, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172068, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '7_TN', strScheduleName = 'Exported to TN', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 140, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172069, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '8', strScheduleName = 'Delivered to US Government, Tax Exempt', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 150, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172070, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '10I', strScheduleName = 'Delivered for Farming, Tax Exempt', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 160, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172071, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '72A089', strScheduleName = '', strType = '', strNote = 'Main Form', strTransactionType = '', intSort = 710, strStoredProcedure = '', intMasterId = 172072, intComponentTypeId = 2
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '1', strScheduleName = 'Received, KY Tax Paid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 200, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 172073, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '2', strScheduleName = 'Received from Licensed Distributor, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 210, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 172074, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '2A', strScheduleName = 'Received from Terminals, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 220, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 172075, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '2B', strScheduleName = 'Blendable Stock Received, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 230, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 172076, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '3_IL', strScheduleName = 'Imported from IL, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 240, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 172077, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '3_IN', strScheduleName = 'Imported from IN, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 250, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 172078, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '3_TN', strScheduleName = 'Imported from TN, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 260, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 172079, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '5D_IL', strScheduleName = 'Sold for Import from IL, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 270, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172080, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '5D_IN', strScheduleName = 'Sold for Import from IN, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 280, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172081, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '5D_TN', strScheduleName = 'Sold for Import from TN, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 290, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172082, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '6', strScheduleName = 'Delivered to Licensed Distributors, KY Tax Not Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 300, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172083, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '7_IL', strScheduleName = 'Exported to IL', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 310, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172084, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '7_IN', strScheduleName = 'Exported to IN', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 320, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172085, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '7_TN', strScheduleName = 'Exported to TN', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 330, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172086, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '8', strScheduleName = 'Delivered to US Government, Tax Exempt', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 340, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172087, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '9', strScheduleName = 'Delivered to State and Local Government, Tax Exempt', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 350, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172088, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '10A', strScheduleName = 'Sold for Non-highway Use', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 360, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172089, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '10G', strScheduleName = 'Delivered to Non-profit Religious, Charitable, or Educational Organizations', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 370, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172090, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '10I', strScheduleName = 'Delivered for Farming, Tax Exempt', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 380, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172091, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '10J', strScheduleName = 'Delivered for Residential Heating, Tax Exempt', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 390, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172092, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '10Y', strScheduleName = 'Delivered to Railroads, Tax Exempt', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 400, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172093, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '72A138', strScheduleName = '', strType = '', strNote = 'Main Form', strTransactionType = '', intSort = 450, strStoredProcedure = '', intMasterId = 172094, intComponentTypeId = 2
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'KY EDI', strFormName = 'KY EDI', strScheduleCode = 'EDI', strScheduleName = '', strType = '', strNote = 'KY EDI File', strTransactionType = '', intSort = 1000, strStoredProcedure = '', intMasterId = 172095, intComponentTypeId = 3
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '3_OH', strScheduleName = 'Imported from OH, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 73, strStoredProcedure = 'uspTFGetTransporterInventoryTax', intMasterId = 172096, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '3_VA', strScheduleName = 'Imported from VA, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 75, strStoredProcedure = 'uspTFGetTransporterInventoryTax', intMasterId = 172097, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '3_WV', strScheduleName = 'Imported from WV, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 77, strStoredProcedure = 'uspTFGetTransporterInventoryTax', intMasterId = 172098, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '5D_OH', strScheduleName = 'Sold for Import from OH, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 103, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172099, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '5D_VA', strScheduleName = 'Sold for Import from VA, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 105, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172100, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '5D_WV', strScheduleName = 'Sold for Import from WV, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 107, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172101, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '7_OH', strScheduleName = 'Exported to OH', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 143, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172102, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '7_VA', strScheduleName = 'Exported to VA', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 145, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172103, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '7_WV', strScheduleName = 'Exported to WV', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 147, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172104, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '3_OH', strScheduleName = 'Imported from OH, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 263, strStoredProcedure = 'uspTFGetTransporterInventoryTax', intMasterId = 172105, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '3_VA', strScheduleName = 'Imported from VA, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 265, strStoredProcedure = 'uspTFGetTransporterInventoryTax', intMasterId = 172106, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '3_WV', strScheduleName = 'Imported from WV, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 267, strStoredProcedure = 'uspTFGetTransporterInventoryTax', intMasterId = 172107, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '5D_OH', strScheduleName = 'Sold for Import from OH, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 293, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172108, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '5D_VA', strScheduleName = 'Sold for Import from VA, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 295, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172109, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '5D_WV', strScheduleName = 'Sold for Import from WV, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 297, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172110, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '7_OH', strScheduleName = 'Exported to OH', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 333, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172111, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '7_VA', strScheduleName = 'Exported to VA', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 335, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172112, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '7_WV', strScheduleName = 'Exported to WV', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 337, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172113, intComponentTypeId = 1

	------MFT-1704
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A099', strFormName = 'KY Transporters Return', strScheduleCode = '14'	, strScheduleName =	'Delivery Schedule (To Bulk)'	  , strType = 'Gasoline'		, strNote = '' , strTransactionType = 'Invoice'	, intSort = 900	,strStoredProcedure = 'uspTFGetTransporterBulkInvoiceTax'		, intMasterId = 172114	, intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A099', strFormName = 'KY Transporters Return', strScheduleCode = '14'	, strScheduleName =	'Delivery Schedule (To Bulk)'	  , strType = 'Special Fuels'	, strNote = '' , strTransactionType = 'Invoice'	, intSort = 910	,strStoredProcedure = 'uspTFGetTransporterBulkInvoiceTax'		, intMasterId = 172115	, intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A099', strFormName = 'KY Transporters Return', strScheduleCode = '14_C'	, strScheduleName =	'Delivery Schedule (To Customer)' , strType = 'Gasoline'		, strNote = '' , strTransactionType = 'Invoice'	, intSort = 920	,strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax'	, intMasterId = 172116	, intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A099', strFormName = 'KY Transporters Return', strScheduleCode = '14_C'	, strScheduleName =	'Delivery Schedule (To Customer)' , strType = 'Special Fuels'	, strNote = '' , strTransactionType = 'Invoice'	, intSort = 930	,strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax'	, intMasterId = 172117	, intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A099', strFormName = 'TR-EDI', strScheduleCode = 'TR-EDI', strScheduleName = '', strType = '', strNote = 'KY TR-EDI File', strTransactionType = '', intSort = 1100, strStoredProcedure = '', intMasterId = 172148, intComponentTypeId = 3

	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '1_TR', strScheduleName = 'Received, KY Tax Paid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 411, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172118 , intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '2_TR', strScheduleName = 'Received from Licensed Distributor, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 412, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172119 , intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '2A_TR', strScheduleName = 'Received from Terminals, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 413, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172120 , intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '2B_TR', strScheduleName = 'Blendable Stock Received, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 414, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172121 , intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '3_IL_TR', strScheduleName = 'Imported from IL, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 415, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172122 , intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '3_IN_TR', strScheduleName = 'Imported from IN, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 416, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172123 , intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '3_TN_TR', strScheduleName = 'Imported from TN, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 417, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172124 , intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '5D_IL_TR', strScheduleName = 'Sold for Import from IL, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 418, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172125 , intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '5D_IN_TR', strScheduleName = 'Sold for Import from IN, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 419, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172126 , intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '5D_TN_TR', strScheduleName = 'Sold for Import from TN, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 420, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172127 , intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '6_TR', strScheduleName = 'Delivered to Licensed Distributors, KY Tax Not Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 421, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172128		, intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '7_IL_TR', strScheduleName = 'Exported to IL', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 422, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172129 , intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '7_IN_TR', strScheduleName = 'Exported to IN', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 423, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172130 , intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '7_TN_TR', strScheduleName = 'Exported to TN', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 424, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172131 , intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '8_TR', strScheduleName = 'Delivered to US Government, Tax Exempt', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 425, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172132 , intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '9_TR', strScheduleName = 'Delivered to State and Local Government, Tax Exempt', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 426, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172133 , intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '10A_TR', strScheduleName = 'Sold for Non-highway Use', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 427, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172134 , intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '10G_TR', strScheduleName = 'Delivered to Non-profit Religious, Charitable, or Educational Organizations', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 428,	strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax',		intMasterId = 172135		, intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '10I_TR', strScheduleName = 'Delivered for Farming, Tax Exempt', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 429, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172136 , intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '10J_TR', strScheduleName = 'Delivered for Residential Heating, Tax Exempt', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 430, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172137 , intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '10Y_TR', strScheduleName = 'Delivered to Railroads, Tax Exempt', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 431, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172138 , intComponentTypeId =	1
						
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '3_OH_TR', strScheduleName = 'Imported from OH, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 432, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172139 , intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '3_VA_TR', strScheduleName = 'Imported from VA, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 433, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172140 , intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '3_WV_TR', strScheduleName = 'Imported from WV, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 434, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172141 , intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '5D_OH_TR', strScheduleName = 'Sold for Import from OH, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 435, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172142		, intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '5D_VA_TR', strScheduleName = 'Sold for Import from VA, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 436, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172143		, intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '5D_WV_TR', strScheduleName = 'Sold for Import from WV, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 437, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172144		, intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '7_OH_TR', strScheduleName = 'Exported to OH', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 438, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172145		, intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '7_VA_TR', strScheduleName = 'Exported to VA', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 439, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172146		, intComponentTypeId =	1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '7_WV_TR', strScheduleName = 'Exported to WV', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 440, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172147		, intComponentTypeId =	1

	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '1_TR', strScheduleName = 'Received, KY Tax Paid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 460, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172172, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '2_TR', strScheduleName = 'Received from Licensed Distributor, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 470, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172149, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '2A_TR', strScheduleName = 'Received from Terminals, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 480, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172150, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '2B_TR', strScheduleName = 'Blendable Stock Received, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 485, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172151, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '3_IL_TR', strScheduleName = 'Imported from IL, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 490, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172152, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '3_IN_TR', strScheduleName = 'Imported from IN, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 510, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172153, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '3_TN_TR', strScheduleName = 'Imported from TN, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 520, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172154, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '3_OH_TR', strScheduleName = 'Imported from OH, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 522, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172164, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '3_VA_TR', strScheduleName = 'Imported from VA, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 524, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172165, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '3_WV_TR', strScheduleName = 'Imported from WV, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 526, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172166, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '5D_IL_TR', strScheduleName = 'Sold for Import from IL, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 530, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172155, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '5D_IN_TR', strScheduleName = 'Sold for Import from IN, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 540, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172156, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '5D_TN_TR', strScheduleName = 'Sold for Import from TN, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 550, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172157, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '5D_OH_TR', strScheduleName = 'Sold for Import from OH, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 552, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172167, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '5D_VA_TR', strScheduleName = 'Sold for Import from VA, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 554, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172168, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '5D_WV_TR', strScheduleName = 'Sold for Import from WV, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 556, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172169, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '6_TR', strScheduleName = 'Delivered to Licensed Distributors, KY Tax Not Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 560, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172158, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '7_IL_TR', strScheduleName = 'Exported to IL', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 570, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172159, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '7_IN_TR', strScheduleName = 'Exported to IN', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 580, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172160, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '7_TN_TR', strScheduleName = 'Exported to TN', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 590, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172161, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '7_OH_TR', strScheduleName = 'Exported to OH', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 592, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172170, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '7_VA_TR', strScheduleName = 'Exported to VA', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 594, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172171, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '7_WV_TR', strScheduleName = 'Exported to WV', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 596, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172173, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '8_TR', strScheduleName = 'Delivered to US Government, Tax Exempt', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 600, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172162, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '10I_TR', strScheduleName = 'Delivered for Farming, Tax Exempt', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 610, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172163, intComponentTypeId = 1	

	EXEC uspTFUpgradeReportingComponents @TaxAuthorityCode = @TaxAuthorityCode, @ReportingComponent = @ReportingComponent


-- Tax Criteria
/* Generate script for Tax Criteria. Specify Tax Authority Id to filter out specific Tax Criteria only.
select 'UNION ALL SELECT intTaxCriteriaId = ' + CAST(0 AS NVARCHAR(10))
	+ CASE WHEN TaxCat.strTaxCategory IS NULL THEN ', strTaxCategory = NULL' ELSE ', strTaxCategory = ''' + TaxCat.strTaxCategory + ''''  END
	+ CASE WHEN TaxCat.strState IS NULL THEN ', strState = NULL' ELSE ', strState = ''' + TaxCat.strState + ''''  END
	+ CASE WHEN strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END
	+ CASE WHEN strCriteria IS NULL THEN ', strCriteria = NULL' ELSE ', strCriteria = ''' + strCriteria + '''' END
--	+ ', intMasterId = ' + CAST((CASE WHEN ISNULL(TaxCrit.intMasterId, '') = '' THEN intReportingComponentCriteriaId ELSE TaxCrit.intMasterId END) AS NVARCHAR(20)) -- Old Format
	+ ', intMasterId = ' + CASE WHEN TaxCrit.intMasterId IS NULL THEN CAST(@TaxAuthorityId AS NVARCHAR(20)) + CAST(intReportingComponentCriteriaId AS NVARCHAR(20)) ELSE CAST(TaxCrit.intMasterId AS NVARCHAR(20)) END -- First 2 digit for TaxAuthorityCodeID
from tblTFReportingComponentCriteria TaxCrit
left join tblTFTaxCategory TaxCat ON TaxCat.intTaxCategoryId = TaxCrit.intTaxCategoryId
left join tblTFReportingComponent RC ON RC.intReportingComponentId = TaxCrit.intReportingComponentId
where RC.intTaxAuthorityId = @TaxAuthorityId 
*/
	DECLARE @TaxCriteria AS TFTaxCriteria

	INSERT INTO @TaxCriteria(
		intTaxCriteriaId
		, strTaxCategory
		, strState
		, strFormCode
		, strScheduleCode
		, strType
		, strCriteria
		, intMasterId
	)
	SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '2', strType = '', strCriteria = '= 0', intMasterId = 17908
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '2A', strType = '', strCriteria = '= 0', intMasterId = 17909
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '2B', strType = '', strCriteria = '= 0', intMasterId = 17910
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', strCriteria = '= 0', intMasterId = 17911
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', strCriteria = '= 0', intMasterId = 17912
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', strCriteria = '= 0', intMasterId = 17913
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '2', strType = '', strCriteria = '= 0', intMasterId = 17914
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '2A', strType = '', strCriteria = '= 0', intMasterId = 17915
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '2B', strType = '', strCriteria = '= 0', intMasterId = 17916
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', strCriteria = '= 0', intMasterId = 17917
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', strCriteria = '= 0', intMasterId = 17918
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', strCriteria = '= 0', intMasterId = 17919
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '10I', strType = '', strCriteria = '= 0', intMasterId = 17920
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '8', strType = '', strCriteria = '= 0', intMasterId = 17921
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '10I', strType = '', strCriteria = '= 0', intMasterId = 17922
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '10J', strType = '', strCriteria = '= 0', intMasterId = 17923
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '10Y', strType = '', strCriteria = '= 0', intMasterId = 17924
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '8', strType = '', strCriteria = '= 0', intMasterId = 17925
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '9', strType = '', strCriteria = '= 0', intMasterId = 17926
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '1', strType = '', strCriteria = '<> 0', intMasterId = 17927
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '1', strType = '', strCriteria = '<> 0', intMasterId = 17928
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '5D_IL', strType = '', strCriteria = '<> 0', intMasterId = 17929
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '5D_IN', strType = '', strCriteria = '<> 0', intMasterId = 17930
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '5D_TN', strType = '', strCriteria = '<> 0', intMasterId = 17931
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '6', strType = '', strCriteria = '= 0', intMasterId = 17932
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', strCriteria = '<> 0', intMasterId = 17933
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', strCriteria = '<> 0', intMasterId = 17934
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', strCriteria = '<> 0', intMasterId = 17935
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '6', strType = '', strCriteria = '= 0', intMasterId = 17936
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', strCriteria = '= 0', intMasterId = 17937
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', strCriteria = '= 0', intMasterId = 17938
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', strCriteria = '= 0', intMasterId = 17939
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '5D_OH', strType = '', strCriteria = '<> 0', intMasterId = 17940
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '5D_VA', strType = '', strCriteria = '<> 0', intMasterId = 17941
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '5D_WV', strType = '', strCriteria = '<> 0', intMasterId = 17942
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', strCriteria = '= 0', intMasterId = 17943
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', strCriteria = '= 0', intMasterId = 17944
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', strCriteria = '= 0', intMasterId = 17945
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', strCriteria = '<> 0', intMasterId = 17946
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', strCriteria = '<> 0', intMasterId = 17947
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', strCriteria = '<> 0', intMasterId = 17948

	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '2_TR', strType = '', strCriteria = '= 0', intMasterId = 17949
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '', strCriteria = '= 0', intMasterId = 17950
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '', strCriteria = '= 0', intMasterId = 17951
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '', strCriteria = '= 0', intMasterId = 17952
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '', strCriteria = '= 0', intMasterId = 17953
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '', strCriteria = '= 0', intMasterId = 17954
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '', strCriteria = '= 0', intMasterId = 17955
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '', strCriteria = '= 0', intMasterId = 17956
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '', strCriteria = '= 0', intMasterId = 17957
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '8_TR', strType = '', strCriteria = '= 0', intMasterId = 17958
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '9_TR', strType = '', strCriteria = '= 0', intMasterId = 17959
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '1_TR', strType = '', strCriteria = '<> 0', intMasterId = 17960
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '', strCriteria = '<> 0', intMasterId = 17961
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '', strCriteria = '<> 0', intMasterId = 17962
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '', strCriteria = '<> 0', intMasterId = 17963
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '6_TR', strType = '', strCriteria = '= 0', intMasterId = 17964
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '', strCriteria = '= 0', intMasterId = 17965
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '', strCriteria = '= 0', intMasterId = 17966
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '', strCriteria = '= 0', intMasterId = 17967
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '', strCriteria = '<> 0', intMasterId = 17968
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '', strCriteria = '<> 0', intMasterId = 17969
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '', strCriteria = '<> 0', intMasterId = 17970

	EXEC uspTFUpgradeTaxCriteria @TaxAuthorityCode = @TaxAuthorityCode, @TaxCriteria = @TaxCriteria


-- Reporting Component - Base
/* Generate script for Valid Product Codes. Specify Tax Authority Id to filter out specific Valid Product Codes only.
select 'UNION ALL SELECT intValidProductCodeId = ' + CAST(0 AS NVARCHAR(10))
	+ CASE WHEN PC.strProductCode IS NULL THEN ', strProductCode = NULL' ELSE ', strProductCode = ''' + PC.strProductCode + ''''  END
	+ CASE WHEN RC.strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN RC.strType IS NULL THEN ', strType = ''''' ELSE ', strType = ''' + RC.strType + '''' END
--	+ ', intMasterId = ' + CAST((CASE WHEN ISNULL(RCPC.intMasterId, '') = '' THEN intReportingComponentProductCodeId ELSE RCPC.intMasterId END) AS NVARCHAR(20)) -- Old Format
	+ ', intMasterId = ' + CASE WHEN RCPC.intMasterId IS NULL THEN CAST(@TaxAuthorityId AS NVARCHAR(20)) + CAST(intReportingComponentProductCodeId AS NVARCHAR(20)) ELSE CAST(RCPC.intMasterId AS NVARCHAR(20)) END -- First 2 digit for TaxAuthorityCodeID
from tblTFReportingComponentProductCode RCPC
left join tblTFProductCode PC ON PC.intProductCodeId= RCPC.intProductCodeId
left join tblTFReportingComponent RC ON RC.intReportingComponentId = RCPC.intReportingComponentId
where RC.intTaxAuthorityId = @TaxAuthorityId
*/
/* Generate script for Valid Origin States. Specify Tax Authority Id to filter out specific Valid Origin States only.
select 'UNION ALL SELECT intValidOriginStateId = ' + CAST(0 AS NVARCHAR(10))
	+ CASE WHEN RC.strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + RC.strFormCode + ''''  END
	+ CASE WHEN RC.strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + RC.strScheduleCode + ''''  END
	+ CASE WHEN RC.strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + RC.strType + '''' END
	+ CASE WHEN ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS IS NULL THEN ', strState = NULL' ELSE ', strState = ''' + ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS + ''''  END
	+ CASE WHEN RCOS.strType IS NULL THEN ', strStatus = NULL' ELSE ', strStatus = ''' + RCOS.strType + ''''  END
--	+ ', intMasterId = ' + CAST((CASE WHEN ISNULL(RCOS.intMasterId, '') = '' THEN intReportingComponentOriginStateId ELSE RCOS.intMasterId END) AS NVARCHAR(20)) -- Old Format
	+ ', intMasterId = ' + CASE WHEN RCOS.intMasterId IS NULL THEN CAST(@TaxAuthorityId AS NVARCHAR(20)) + CAST(intReportingComponentOriginStateId AS NVARCHAR(20)) ELSE CAST(RCOS.intMasterId AS NVARCHAR(20)) END -- First 2 digit for TaxAuthorityCodeID
from tblTFReportingComponentOriginState RCOS
left join tblTFOriginDestinationState ODS ON ODS.intOriginDestinationStateId= RCOS.intOriginDestinationStateId
left join tblTFReportingComponent RC ON RC.intReportingComponentId = RCOS.intReportingComponentId
where RC.intTaxAuthorityId = @TaxAuthorityId
*/
/* Generate script for Valid Destination States. Specify Tax Authority Id to filter out specific Valid Destination States only.
select 'UNION ALL SELECT intValidDestinationStateId = ' + CAST(0 AS NVARCHAR(10))
	+ CASE WHEN RC.strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + RC.strFormCode + ''''  END
	+ CASE WHEN RC.strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + RC.strScheduleCode + ''''  END
	+ CASE WHEN RC.strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + RC.strType + '''' END
	+ CASE WHEN ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS IS NULL THEN ', strState = NULL' ELSE ', strState = ''' + ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS + ''''  END
	+ CASE WHEN RCDS.strType IS NULL THEN ', strStatus = NULL' ELSE ', strStatus = ''' + RCDS.strType + ''''  END
--	+ ', intMasterId = ' + CAST((CASE WHEN ISNULL(RCDS.intMasterId, '') = '' THEN intReportingComponentDestinationStateId ELSE RCDS.intMasterId END) AS NVARCHAR(20)) -- Old Format
	+ ', intMasterId = ' + CASE WHEN RCDS.intMasterId IS NULL THEN CAST(@TaxAuthorityId AS NVARCHAR(20)) + CAST(intReportingComponentDestinationStateId AS NVARCHAR(20)) ELSE CAST(RCDS.intMasterId AS NVARCHAR(20)) END -- First 2 digit for TaxAuthorityCodeID
from tblTFReportingComponentDestinationState RCDS
left join tblTFOriginDestinationState ODS ON ODS.intOriginDestinationStateId= RCDS.intOriginDestinationStateId
left join tblTFReportingComponent RC ON RC.intReportingComponentId = RCDS.intReportingComponentId
where RC.intTaxAuthorityId = @TaxAuthorityId
*/
	DECLARE @ValidProductCodes AS TFValidProductCodes
	DECLARE @ValidOriginStates AS TFValidOriginStates
	DECLARE @ValidDestinationStates AS TFValidDestinationStates

	INSERT INTO @ValidProductCodes(
		intValidProductCodeId
		, strProductCode
		, strFormCode
		, strScheduleCode
		, strType
		, intMasterId
	)
	SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '1', strType = '', intMasterId = 178460
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '1', strType = '', intMasterId = 178461
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '1', strType = '', intMasterId = 178462
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '1', strType = '', intMasterId = 178463
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '1', strType = '', intMasterId = 178464
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '1', strType = '', intMasterId = 178465
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '1', strType = '', intMasterId = 178466
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '1', strType = '', intMasterId = 178467
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '1', strType = '', intMasterId = 178468
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '1', strType = '', intMasterId = 178469
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '1', strType = '', intMasterId = 178470
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '1', strType = '', intMasterId = 178471
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '1', strType = '', intMasterId = 178472
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '1', strType = '', intMasterId = 178473
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '1', strType = '', intMasterId = 178474
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '1', strType = '', intMasterId = 178475
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '1', strType = '', intMasterId = 178476
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '1', strType = '', intMasterId = 178477
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '1', strType = '', intMasterId = 178478
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '1', strType = '', intMasterId = 178479
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '1', strType = '', intMasterId = 178480
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '1', strType = '', intMasterId = 178481
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '1', strType = '', intMasterId = 178482
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '1', strType = '', intMasterId = 178483
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '10A', strType = '', intMasterId = 178844
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '10A', strType = '', intMasterId = 178845
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '10A', strType = '', intMasterId = 178846
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '10A', strType = '', intMasterId = 178847
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '10A', strType = '', intMasterId = 178848
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '10A', strType = '', intMasterId = 178849
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '10A', strType = '', intMasterId = 178850
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '10A', strType = '', intMasterId = 178851
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '10A', strType = '', intMasterId = 178852
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '10A', strType = '', intMasterId = 178853
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '10A', strType = '', intMasterId = 178854
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '10A', strType = '', intMasterId = 178855
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '10A', strType = '', intMasterId = 178856
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '10A', strType = '', intMasterId = 178857
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '10A', strType = '', intMasterId = 178858
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '10A', strType = '', intMasterId = 178859
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '10A', strType = '', intMasterId = 178860
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '10A', strType = '', intMasterId = 178861
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '10A', strType = '', intMasterId = 178862
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '10A', strType = '', intMasterId = 178863
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '10A', strType = '', intMasterId = 178864
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '10A', strType = '', intMasterId = 178865
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '10A', strType = '', intMasterId = 178866
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '10A', strType = '', intMasterId = 178867
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '10G', strType = '', intMasterId = 178868
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '10G', strType = '', intMasterId = 178869
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '10G', strType = '', intMasterId = 178870
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '10G', strType = '', intMasterId = 178871
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '10G', strType = '', intMasterId = 178872
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '10G', strType = '', intMasterId = 178873
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '10G', strType = '', intMasterId = 178874
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '10G', strType = '', intMasterId = 178875
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '10G', strType = '', intMasterId = 178876
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '10G', strType = '', intMasterId = 178877
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '10G', strType = '', intMasterId = 178878
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '10G', strType = '', intMasterId = 178879
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '10G', strType = '', intMasterId = 178880
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '10G', strType = '', intMasterId = 178881
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '10G', strType = '', intMasterId = 178882
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '10G', strType = '', intMasterId = 178883
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '10G', strType = '', intMasterId = 178884
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '10G', strType = '', intMasterId = 178885
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '10G', strType = '', intMasterId = 178886
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '10G', strType = '', intMasterId = 178887
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '10G', strType = '', intMasterId = 178888
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '10G', strType = '', intMasterId = 178889
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '10G', strType = '', intMasterId = 178890
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '10G', strType = '', intMasterId = 178891
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '10I', strType = '', intMasterId = 178892
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '10I', strType = '', intMasterId = 178893
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '10I', strType = '', intMasterId = 178894
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '10I', strType = '', intMasterId = 178895
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '10I', strType = '', intMasterId = 178896
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '10I', strType = '', intMasterId = 178897
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '10I', strType = '', intMasterId = 178898
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '10I', strType = '', intMasterId = 178899
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '10I', strType = '', intMasterId = 178900
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '10I', strType = '', intMasterId = 178901
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '10I', strType = '', intMasterId = 178902
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '10I', strType = '', intMasterId = 178903
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '10I', strType = '', intMasterId = 178904
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '10I', strType = '', intMasterId = 178905
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '10I', strType = '', intMasterId = 178906
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '10I', strType = '', intMasterId = 178907
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '10I', strType = '', intMasterId = 178908
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '10I', strType = '', intMasterId = 178909
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '10I', strType = '', intMasterId = 178910
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '10I', strType = '', intMasterId = 178911
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '10I', strType = '', intMasterId = 178912
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '10I', strType = '', intMasterId = 178913
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '10I', strType = '', intMasterId = 178914
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '10I', strType = '', intMasterId = 178915
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '10J', strType = '', intMasterId = 178916
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '10J', strType = '', intMasterId = 178917
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '10J', strType = '', intMasterId = 178918
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '10J', strType = '', intMasterId = 178919
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '10J', strType = '', intMasterId = 178920
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '10J', strType = '', intMasterId = 178921
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '10J', strType = '', intMasterId = 178922
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '10J', strType = '', intMasterId = 178923
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '10J', strType = '', intMasterId = 178924
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '10J', strType = '', intMasterId = 178925
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '10J', strType = '', intMasterId = 178926
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '10J', strType = '', intMasterId = 178927
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '10J', strType = '', intMasterId = 178928
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '10J', strType = '', intMasterId = 178929
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '10J', strType = '', intMasterId = 178930
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '10J', strType = '', intMasterId = 178931
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '10J', strType = '', intMasterId = 178932
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '10J', strType = '', intMasterId = 178933
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '10J', strType = '', intMasterId = 178934
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '10J', strType = '', intMasterId = 178935
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '10J', strType = '', intMasterId = 178936
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '10J', strType = '', intMasterId = 178937
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '10J', strType = '', intMasterId = 178938
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '10J', strType = '', intMasterId = 178939
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '10Y', strType = '', intMasterId = 178940
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '10Y', strType = '', intMasterId = 178941
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '10Y', strType = '', intMasterId = 178942
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '10Y', strType = '', intMasterId = 178943
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '10Y', strType = '', intMasterId = 178944
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '10Y', strType = '', intMasterId = 178945
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '10Y', strType = '', intMasterId = 178946
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '10Y', strType = '', intMasterId = 178947
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '10Y', strType = '', intMasterId = 178948
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '10Y', strType = '', intMasterId = 178949
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '10Y', strType = '', intMasterId = 178950
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '10Y', strType = '', intMasterId = 178951
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '10Y', strType = '', intMasterId = 178952
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '10Y', strType = '', intMasterId = 178953
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '10Y', strType = '', intMasterId = 178954
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '10Y', strType = '', intMasterId = 178955
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '10Y', strType = '', intMasterId = 178956
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '10Y', strType = '', intMasterId = 178957
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '10Y', strType = '', intMasterId = 178958
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '10Y', strType = '', intMasterId = 178959
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '10Y', strType = '', intMasterId = 178960
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '10Y', strType = '', intMasterId = 178961
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '10Y', strType = '', intMasterId = 178962
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '10Y', strType = '', intMasterId = 178963
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '2', strType = '', intMasterId = 178484
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '2', strType = '', intMasterId = 178485
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '2', strType = '', intMasterId = 178486
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '2', strType = '', intMasterId = 178487
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '2', strType = '', intMasterId = 178488
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '2', strType = '', intMasterId = 178489
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '2', strType = '', intMasterId = 178490
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '2', strType = '', intMasterId = 178491
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '2', strType = '', intMasterId = 178492
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '2', strType = '', intMasterId = 178493
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '2', strType = '', intMasterId = 178494
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '2', strType = '', intMasterId = 178495
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '2', strType = '', intMasterId = 178496
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '2', strType = '', intMasterId = 178497
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '2', strType = '', intMasterId = 178498
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '2', strType = '', intMasterId = 178499
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '2', strType = '', intMasterId = 178500
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '2', strType = '', intMasterId = 178501
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '2', strType = '', intMasterId = 178502
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '2', strType = '', intMasterId = 178503
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '2', strType = '', intMasterId = 178504
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '2', strType = '', intMasterId = 178505
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '2', strType = '', intMasterId = 178506
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '2', strType = '', intMasterId = 178507
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '2A', strType = '', intMasterId = 178508
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '2A', strType = '', intMasterId = 178509
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '2A', strType = '', intMasterId = 178510
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '2A', strType = '', intMasterId = 178511
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '2A', strType = '', intMasterId = 178512
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '2A', strType = '', intMasterId = 178513
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '2A', strType = '', intMasterId = 178514
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '2A', strType = '', intMasterId = 178515
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '2A', strType = '', intMasterId = 178516
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '2A', strType = '', intMasterId = 178517
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '2A', strType = '', intMasterId = 178518
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '2A', strType = '', intMasterId = 178519
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '2A', strType = '', intMasterId = 178520
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '2A', strType = '', intMasterId = 178521
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '2A', strType = '', intMasterId = 178522
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '2A', strType = '', intMasterId = 178523
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '2A', strType = '', intMasterId = 178524
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '2A', strType = '', intMasterId = 178525
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '2A', strType = '', intMasterId = 178526
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '2A', strType = '', intMasterId = 178527
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '2A', strType = '', intMasterId = 178528
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '2A', strType = '', intMasterId = 178529
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '2A', strType = '', intMasterId = 178530
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '2A', strType = '', intMasterId = 178531
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '2B', strType = '', intMasterId = 178532
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '2B', strType = '', intMasterId = 178533
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '2B', strType = '', intMasterId = 178534
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '2B', strType = '', intMasterId = 178535
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '2B', strType = '', intMasterId = 178536
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '2B', strType = '', intMasterId = 178537
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '2B', strType = '', intMasterId = 178538
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '2B', strType = '', intMasterId = 178539
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '2B', strType = '', intMasterId = 178540
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '2B', strType = '', intMasterId = 178541
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '2B', strType = '', intMasterId = 178542
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '2B', strType = '', intMasterId = 178543
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '2B', strType = '', intMasterId = 178544
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '2B', strType = '', intMasterId = 178545
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '2B', strType = '', intMasterId = 178546
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '2B', strType = '', intMasterId = 178547
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '2B', strType = '', intMasterId = 178548
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '2B', strType = '', intMasterId = 178549
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '2B', strType = '', intMasterId = 178550
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '2B', strType = '', intMasterId = 178551
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '2B', strType = '', intMasterId = 178552
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '2B', strType = '', intMasterId = 178553
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '2B', strType = '', intMasterId = 178554
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '2B', strType = '', intMasterId = 178555
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', intMasterId = 178556
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', intMasterId = 178557
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', intMasterId = 178558
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', intMasterId = 178559
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', intMasterId = 178560
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', intMasterId = 178561
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', intMasterId = 178562
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', intMasterId = 178563
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', intMasterId = 178564
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', intMasterId = 178565
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', intMasterId = 178566
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', intMasterId = 178567
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', intMasterId = 178568
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', intMasterId = 178569
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', intMasterId = 178570
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', intMasterId = 178571
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', intMasterId = 178572
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', intMasterId = 178573
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', intMasterId = 178574
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', intMasterId = 178575
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', intMasterId = 178576
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', intMasterId = 178577
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', intMasterId = 178578
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', intMasterId = 178579
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', intMasterId = 178580
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', intMasterId = 178581
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', intMasterId = 178582
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', intMasterId = 178583
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', intMasterId = 178584
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', intMasterId = 178585
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', intMasterId = 178586
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', intMasterId = 178587
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', intMasterId = 178588
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', intMasterId = 178589
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', intMasterId = 178590
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', intMasterId = 178591
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', intMasterId = 178592
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', intMasterId = 178593
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', intMasterId = 178594
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', intMasterId = 178595
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', intMasterId = 178596
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', intMasterId = 178597
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', intMasterId = 178598
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', intMasterId = 178599
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', intMasterId = 178600
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', intMasterId = 178601
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', intMasterId = 178602
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', intMasterId = 178603
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', intMasterId = 178604
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', intMasterId = 178605
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', intMasterId = 178606
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', intMasterId = 178607
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', intMasterId = 178608
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', intMasterId = 178609
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', intMasterId = 178610
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', intMasterId = 178611
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', intMasterId = 178612
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', intMasterId = 178613
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', intMasterId = 178614
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', intMasterId = 178615
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', intMasterId = 178616
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', intMasterId = 178617
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', intMasterId = 178618
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', intMasterId = 178619
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', intMasterId = 178620
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', intMasterId = 178621
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', intMasterId = 178622
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', intMasterId = 178623
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', intMasterId = 178624
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', intMasterId = 178625
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', intMasterId = 178626
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', intMasterId = 178627
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', intMasterId = 178628
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', intMasterId = 178629
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', intMasterId = 178630
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', intMasterId = 178631
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', intMasterId = 178632
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', intMasterId = 178633
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', intMasterId = 178634
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', intMasterId = 178635
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', intMasterId = 178636
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', intMasterId = 178637
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', intMasterId = 178638
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', intMasterId = 178639
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', intMasterId = 178640
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', intMasterId = 178641
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', intMasterId = 178642
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', intMasterId = 178643
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', intMasterId = 178644
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', intMasterId = 178645
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', intMasterId = 178646
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', intMasterId = 178647
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', intMasterId = 178648
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', intMasterId = 178649
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', intMasterId = 178650
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', intMasterId = 178651
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', intMasterId = 178652
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', intMasterId = 178653
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', intMasterId = 178654
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', intMasterId = 178655
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', intMasterId = 178656
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', intMasterId = 178657
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', intMasterId = 178658
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', intMasterId = 178659
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', intMasterId = 178660
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', intMasterId = 178661
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', intMasterId = 178662
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', intMasterId = 178663
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', intMasterId = 178664
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', intMasterId = 178665
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', intMasterId = 178666
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', intMasterId = 178667
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', intMasterId = 178668
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', intMasterId = 178669
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', intMasterId = 178670
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', intMasterId = 178671
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', intMasterId = 178672
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', intMasterId = 178673
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', intMasterId = 178674
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', intMasterId = 178675
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', intMasterId = 178676
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', intMasterId = 178677
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', intMasterId = 178678
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', intMasterId = 178679
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', intMasterId = 178680
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', intMasterId = 178681
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', intMasterId = 178682
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', intMasterId = 178683
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', intMasterId = 178684
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', intMasterId = 178685
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', intMasterId = 178686
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', intMasterId = 178687
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', intMasterId = 178688
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', intMasterId = 178689
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', intMasterId = 178690
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', intMasterId = 178691
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', intMasterId = 178692
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', intMasterId = 178693
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', intMasterId = 178694
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', intMasterId = 178695
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', intMasterId = 178696
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', intMasterId = 178697
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', intMasterId = 178698
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', intMasterId = 178699
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '6', strType = '', intMasterId = 178700
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '6', strType = '', intMasterId = 178701
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '6', strType = '', intMasterId = 178702
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '6', strType = '', intMasterId = 178703
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '6', strType = '', intMasterId = 178704
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '6', strType = '', intMasterId = 178705
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '6', strType = '', intMasterId = 178706
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '6', strType = '', intMasterId = 178707
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '6', strType = '', intMasterId = 178708
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '6', strType = '', intMasterId = 178709
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '6', strType = '', intMasterId = 178710
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '6', strType = '', intMasterId = 178711
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '6', strType = '', intMasterId = 178712
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '6', strType = '', intMasterId = 178713
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '6', strType = '', intMasterId = 178714
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '6', strType = '', intMasterId = 178715
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '6', strType = '', intMasterId = 178716
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '6', strType = '', intMasterId = 178717
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '6', strType = '', intMasterId = 178718
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '6', strType = '', intMasterId = 178719
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '6', strType = '', intMasterId = 178720
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '6', strType = '', intMasterId = 178721
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '6', strType = '', intMasterId = 178722
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '6', strType = '', intMasterId = 178723
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', intMasterId = 178724
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', intMasterId = 178725
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', intMasterId = 178726
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', intMasterId = 178727
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', intMasterId = 178728
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', intMasterId = 178729
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', intMasterId = 178730
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', intMasterId = 178731
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', intMasterId = 178732
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', intMasterId = 178733
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', intMasterId = 178734
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', intMasterId = 178735
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', intMasterId = 178736
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', intMasterId = 178737
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', intMasterId = 178738
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', intMasterId = 178739
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', intMasterId = 178740
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', intMasterId = 178741
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', intMasterId = 178742
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', intMasterId = 178743
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', intMasterId = 178744
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', intMasterId = 178745
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', intMasterId = 178746
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', intMasterId = 178747
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', intMasterId = 178748
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', intMasterId = 178749
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', intMasterId = 178750
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', intMasterId = 178751
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', intMasterId = 178752
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', intMasterId = 178753
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', intMasterId = 178754
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', intMasterId = 178755
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', intMasterId = 178756
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', intMasterId = 178757
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', intMasterId = 178758
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', intMasterId = 178759
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', intMasterId = 178760
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', intMasterId = 178761
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', intMasterId = 178762
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', intMasterId = 178763
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', intMasterId = 178764
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', intMasterId = 178765
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', intMasterId = 178766
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', intMasterId = 178767
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', intMasterId = 178768
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', intMasterId = 178769
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', intMasterId = 178770
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', intMasterId = 178771
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', intMasterId = 178772
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', intMasterId = 178773
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', intMasterId = 178774
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', intMasterId = 178775
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', intMasterId = 178776
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', intMasterId = 178777
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', intMasterId = 178778
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', intMasterId = 178779
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', intMasterId = 178780
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', intMasterId = 178781
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', intMasterId = 178782
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', intMasterId = 178783
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', intMasterId = 178784
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', intMasterId = 178785
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', intMasterId = 178786
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', intMasterId = 178787
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', intMasterId = 178788
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', intMasterId = 178789
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', intMasterId = 178790
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', intMasterId = 178791
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', intMasterId = 178792
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', intMasterId = 178793
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', intMasterId = 178794
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', intMasterId = 178795
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '8', strType = '', intMasterId = 178796
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '8', strType = '', intMasterId = 178797
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '8', strType = '', intMasterId = 178798
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '8', strType = '', intMasterId = 178799
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '8', strType = '', intMasterId = 178800
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '8', strType = '', intMasterId = 178801
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '8', strType = '', intMasterId = 178802
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '8', strType = '', intMasterId = 178803
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '8', strType = '', intMasterId = 178804
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '8', strType = '', intMasterId = 178805
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '8', strType = '', intMasterId = 178806
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '8', strType = '', intMasterId = 178807
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '8', strType = '', intMasterId = 178808
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '8', strType = '', intMasterId = 178809
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '8', strType = '', intMasterId = 178810
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '8', strType = '', intMasterId = 178811
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '8', strType = '', intMasterId = 178812
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '8', strType = '', intMasterId = 178813
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '8', strType = '', intMasterId = 178814
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '8', strType = '', intMasterId = 178815
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '8', strType = '', intMasterId = 178816
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '8', strType = '', intMasterId = 178817
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '8', strType = '', intMasterId = 178818
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '8', strType = '', intMasterId = 178819
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '9', strType = '', intMasterId = 178820
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '9', strType = '', intMasterId = 178821
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '9', strType = '', intMasterId = 178822
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '9', strType = '', intMasterId = 178823
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '9', strType = '', intMasterId = 178824
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '9', strType = '', intMasterId = 178825
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '9', strType = '', intMasterId = 178826
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '9', strType = '', intMasterId = 178827
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '9', strType = '', intMasterId = 178828
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '9', strType = '', intMasterId = 178829
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '9', strType = '', intMasterId = 178830
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '9', strType = '', intMasterId = 178831
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '9', strType = '', intMasterId = 178832
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '9', strType = '', intMasterId = 178833
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '9', strType = '', intMasterId = 178834
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '9', strType = '', intMasterId = 178835
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '9', strType = '', intMasterId = 178836
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '9', strType = '', intMasterId = 178837
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '9', strType = '', intMasterId = 178838
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '9', strType = '', intMasterId = 178839
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '9', strType = '', intMasterId = 178840
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '9', strType = '', intMasterId = 178841
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '9', strType = '', intMasterId = 178842
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '9', strType = '', intMasterId = 178843
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '8', strType = '', intMasterId = 178434
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '8', strType = '', intMasterId = 178435
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '8', strType = '', intMasterId = 178436
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '8', strType = '', intMasterId = 178437
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '8', strType = '', intMasterId = 178438
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '8', strType = '', intMasterId = 178439
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '8', strType = '', intMasterId = 178440
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '8', strType = '', intMasterId = 178441
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '8', strType = '', intMasterId = 178442
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '8', strType = '', intMasterId = 178443
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '8', strType = '', intMasterId = 178444
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '8', strType = '', intMasterId = 178445
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '8', strType = '', intMasterId = 178446
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', intMasterId = 178421
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', intMasterId = 178422
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', intMasterId = 178423
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', intMasterId = 178424
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', intMasterId = 178425
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', intMasterId = 178426
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', intMasterId = 178427
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', intMasterId = 178428
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', intMasterId = 178429
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', intMasterId = 178430
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', intMasterId = 178431
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', intMasterId = 178432
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', intMasterId = 178433
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', intMasterId = 178408
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', intMasterId = 178409
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', intMasterId = 178410
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', intMasterId = 178411
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', intMasterId = 178412
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', intMasterId = 178413
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', intMasterId = 178414
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', intMasterId = 178415
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', intMasterId = 178416
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', intMasterId = 178417
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', intMasterId = 178418
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', intMasterId = 178419
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', intMasterId = 178420
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', intMasterId = 178395
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', intMasterId = 178396
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', intMasterId = 178397
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', intMasterId = 178398
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', intMasterId = 178399
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', intMasterId = 178400
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', intMasterId = 178401
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', intMasterId = 178402
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', intMasterId = 178403
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', intMasterId = 178404
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', intMasterId = 178405
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', intMasterId = 178406
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', intMasterId = 178407
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '6', strType = '', intMasterId = 178382
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '6', strType = '', intMasterId = 178383
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '6', strType = '', intMasterId = 178384
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '6', strType = '', intMasterId = 178385
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '6', strType = '', intMasterId = 178386
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '6', strType = '', intMasterId = 178387
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '6', strType = '', intMasterId = 178388
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '6', strType = '', intMasterId = 178389
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '6', strType = '', intMasterId = 178390
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '6', strType = '', intMasterId = 178391
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '6', strType = '', intMasterId = 178392
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '6', strType = '', intMasterId = 178393
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '6', strType = '', intMasterId = 178394
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '5D_TN', strType = '', intMasterId = 178369
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '5D_TN', strType = '', intMasterId = 178370
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '5D_TN', strType = '', intMasterId = 178371
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '5D_TN', strType = '', intMasterId = 178372
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '5D_TN', strType = '', intMasterId = 178373
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '5D_TN', strType = '', intMasterId = 178374
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '5D_TN', strType = '', intMasterId = 178375
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '5D_TN', strType = '', intMasterId = 178376
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '5D_TN', strType = '', intMasterId = 178377
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '5D_TN', strType = '', intMasterId = 178378
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '5D_TN', strType = '', intMasterId = 178379
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '5D_TN', strType = '', intMasterId = 178380
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '5D_TN', strType = '', intMasterId = 178381
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '5D_IN', strType = '', intMasterId = 178356
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '5D_IN', strType = '', intMasterId = 178357
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '5D_IN', strType = '', intMasterId = 178358
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '5D_IN', strType = '', intMasterId = 178359
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '5D_IN', strType = '', intMasterId = 178360
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '5D_IN', strType = '', intMasterId = 178361
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '5D_IN', strType = '', intMasterId = 178362
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '5D_IN', strType = '', intMasterId = 178363
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '5D_IN', strType = '', intMasterId = 178364
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '5D_IN', strType = '', intMasterId = 178365
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '5D_IN', strType = '', intMasterId = 178366
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '5D_IN', strType = '', intMasterId = 178367
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '5D_IN', strType = '', intMasterId = 178368
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '5D_IL', strType = '', intMasterId = 178343
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '5D_IL', strType = '', intMasterId = 178344
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '5D_IL', strType = '', intMasterId = 178345
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '5D_IL', strType = '', intMasterId = 178346
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '5D_IL', strType = '', intMasterId = 178347
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '5D_IL', strType = '', intMasterId = 178348
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '5D_IL', strType = '', intMasterId = 178349
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '5D_IL', strType = '', intMasterId = 178350
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '5D_IL', strType = '', intMasterId = 178351
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '5D_IL', strType = '', intMasterId = 178352
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '5D_IL', strType = '', intMasterId = 178353
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '5D_IL', strType = '', intMasterId = 178354
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '5D_IL', strType = '', intMasterId = 178355
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', intMasterId = 178330
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', intMasterId = 178331
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', intMasterId = 178332
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', intMasterId = 178333
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', intMasterId = 178334
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', intMasterId = 178335
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', intMasterId = 178336
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', intMasterId = 178337
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', intMasterId = 178338
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', intMasterId = 178339
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', intMasterId = 178340
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', intMasterId = 178341
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', intMasterId = 178342
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', intMasterId = 178317
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', intMasterId = 178318
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', intMasterId = 178319
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', intMasterId = 178320
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', intMasterId = 178321
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', intMasterId = 178322
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', intMasterId = 178323
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', intMasterId = 178324
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', intMasterId = 178325
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', intMasterId = 178326
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', intMasterId = 178327
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', intMasterId = 178328
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', intMasterId = 178329
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', intMasterId = 178304
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', intMasterId = 178305
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', intMasterId = 178306
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', intMasterId = 178307
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', intMasterId = 178308
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', intMasterId = 178309
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', intMasterId = 178310
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', intMasterId = 178311
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', intMasterId = 178312
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', intMasterId = 178313
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', intMasterId = 178314
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', intMasterId = 178315
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', intMasterId = 178316
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '2B', strType = '', intMasterId = 178291
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '2B', strType = '', intMasterId = 178292
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '2B', strType = '', intMasterId = 178293
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '2B', strType = '', intMasterId = 178294
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '2B', strType = '', intMasterId = 178295
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '2B', strType = '', intMasterId = 178296
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '2B', strType = '', intMasterId = 178297
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '2B', strType = '', intMasterId = 178298
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '2B', strType = '', intMasterId = 178299
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '2B', strType = '', intMasterId = 178300
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '2B', strType = '', intMasterId = 178301
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '2B', strType = '', intMasterId = 178302
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '2B', strType = '', intMasterId = 178303
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '2A', strType = '', intMasterId = 178278
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '2A', strType = '', intMasterId = 178279
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '2A', strType = '', intMasterId = 178280
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '2A', strType = '', intMasterId = 178281
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '2A', strType = '', intMasterId = 178282
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '2A', strType = '', intMasterId = 178283
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '2A', strType = '', intMasterId = 178284
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '2A', strType = '', intMasterId = 178285
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '2A', strType = '', intMasterId = 178286
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '2A', strType = '', intMasterId = 178287
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '2A', strType = '', intMasterId = 178288
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '2A', strType = '', intMasterId = 178289
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '2A', strType = '', intMasterId = 178290
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '2', strType = '', intMasterId = 178265
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '2', strType = '', intMasterId = 178266
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '2', strType = '', intMasterId = 178267
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '2', strType = '', intMasterId = 178268
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '2', strType = '', intMasterId = 178269
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '2', strType = '', intMasterId = 178270
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '2', strType = '', intMasterId = 178271
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '2', strType = '', intMasterId = 178272
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '2', strType = '', intMasterId = 178273
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '2', strType = '', intMasterId = 178274
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '2', strType = '', intMasterId = 178275
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '2', strType = '', intMasterId = 178276
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '2', strType = '', intMasterId = 178277
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '10I', strType = '', intMasterId = 178447
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '10I', strType = '', intMasterId = 178448
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '10I', strType = '', intMasterId = 178449
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '10I', strType = '', intMasterId = 178450
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '10I', strType = '', intMasterId = 178451
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '10I', strType = '', intMasterId = 178452
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '10I', strType = '', intMasterId = 178453
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '10I', strType = '', intMasterId = 178454
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '10I', strType = '', intMasterId = 178455
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '10I', strType = '', intMasterId = 178456
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '10I', strType = '', intMasterId = 178457
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '10I', strType = '', intMasterId = 178458
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '10I', strType = '', intMasterId = 178459
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '1', strType = '', intMasterId = 178252
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '1', strType = '', intMasterId = 178253
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '1', strType = '', intMasterId = 178254
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '1', strType = '', intMasterId = 178255
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '1', strType = '', intMasterId = 178256
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '1', strType = '', intMasterId = 178257
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '1', strType = '', intMasterId = 178258
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '1', strType = '', intMasterId = 178259
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '1', strType = '', intMasterId = 178260
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '1', strType = '', intMasterId = 178261
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '1', strType = '', intMasterId = 178262
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '1', strType = '', intMasterId = 178263
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '1', strType = '', intMasterId = 178264

	
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', intMasterId = 178964
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', intMasterId = 178965
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', intMasterId = 178966
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', intMasterId = 178967
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', intMasterId = 178968
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', intMasterId = 178969
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', intMasterId = 178970
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', intMasterId = 178971
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', intMasterId = 178972
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', intMasterId = 178973
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', intMasterId = 178974
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', intMasterId = 178975
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', intMasterId = 178976
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', intMasterId = 178977
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', intMasterId = 178978
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', intMasterId = 178979
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', intMasterId = 178980
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', intMasterId = 178981
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', intMasterId = 178982
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', intMasterId = 178983
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', intMasterId = 178984
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', intMasterId = 178985
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', intMasterId = 178986
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', intMasterId = 178987
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', intMasterId = 178988
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', intMasterId = 178989
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', intMasterId = 178990
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', intMasterId = 178991
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', intMasterId = 178992
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', intMasterId = 178993
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', intMasterId = 178994
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', intMasterId = 178995
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', intMasterId = 178996
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', intMasterId = 178997
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', intMasterId = 178998
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', intMasterId = 178999
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', intMasterId = 179000
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', intMasterId = 179001
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', intMasterId = 179002
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '5D_OH', strType = '', intMasterId = 179003
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '5D_OH', strType = '', intMasterId = 179004
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '5D_OH', strType = '', intMasterId = 179005
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '5D_OH', strType = '', intMasterId = 179006
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '5D_OH', strType = '', intMasterId = 179007
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '5D_OH', strType = '', intMasterId = 179008
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '5D_OH', strType = '', intMasterId = 179009
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '5D_OH', strType = '', intMasterId = 179010
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '5D_OH', strType = '', intMasterId = 179011
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '5D_OH', strType = '', intMasterId = 179012
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '5D_OH', strType = '', intMasterId = 179013
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '5D_OH', strType = '', intMasterId = 179014
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '5D_OH', strType = '', intMasterId = 179015
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '5D_VA', strType = '', intMasterId = 179016
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '5D_VA', strType = '', intMasterId = 179017
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '5D_VA', strType = '', intMasterId = 179018
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '5D_VA', strType = '', intMasterId = 179019
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '5D_VA', strType = '', intMasterId = 179020
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '5D_VA', strType = '', intMasterId = 179021
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '5D_VA', strType = '', intMasterId = 179022
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '5D_VA', strType = '', intMasterId = 179023
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '5D_VA', strType = '', intMasterId = 179024
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '5D_VA', strType = '', intMasterId = 179025
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '5D_VA', strType = '', intMasterId = 179026
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '5D_VA', strType = '', intMasterId = 179027
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '5D_VA', strType = '', intMasterId = 179028
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '5D_WV', strType = '', intMasterId = 179029
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '5D_WV', strType = '', intMasterId = 179030
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '5D_WV', strType = '', intMasterId = 179031
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '5D_WV', strType = '', intMasterId = 179032
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '5D_WV', strType = '', intMasterId = 179033
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '5D_WV', strType = '', intMasterId = 179034
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '5D_WV', strType = '', intMasterId = 179035
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '5D_WV', strType = '', intMasterId = 179036
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '5D_WV', strType = '', intMasterId = 179037
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '5D_WV', strType = '', intMasterId = 179038
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '5D_WV', strType = '', intMasterId = 179039
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '5D_WV', strType = '', intMasterId = 179040
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '5D_WV', strType = '', intMasterId = 179041
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', intMasterId = 179042
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', intMasterId = 179043
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', intMasterId = 179044
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', intMasterId = 179045
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', intMasterId = 179046
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', intMasterId = 179047
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', intMasterId = 179048
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', intMasterId = 179049
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', intMasterId = 179050
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', intMasterId = 179051
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', intMasterId = 179052
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', intMasterId = 179053
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', intMasterId = 179054
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', intMasterId = 179055
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', intMasterId = 179056
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', intMasterId = 179057
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', intMasterId = 179058
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', intMasterId = 179059
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', intMasterId = 179060
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', intMasterId = 179061
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', intMasterId = 179062
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', intMasterId = 179063
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', intMasterId = 179064
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', intMasterId = 179065
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', intMasterId = 179066
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', intMasterId = 179067
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', intMasterId = 179068
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', intMasterId = 179069
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', intMasterId = 179070
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', intMasterId = 179071
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', intMasterId = 179072
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', intMasterId = 179073
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', intMasterId = 179074
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', intMasterId = 179075
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', intMasterId = 179076
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', intMasterId = 179077
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', intMasterId = 179078
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', intMasterId = 179079
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', intMasterId = 179080

	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', intMasterId = 179081
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', intMasterId = 179082
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', intMasterId = 179083
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', intMasterId = 179084
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', intMasterId = 179085
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', intMasterId = 179086
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', intMasterId = 179087
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', intMasterId = 179088
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', intMasterId = 179089
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', intMasterId = 179090
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', intMasterId = 179091
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', intMasterId = 179092
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', intMasterId = 179093
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', intMasterId = 179094
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', intMasterId = 179095
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', intMasterId = 179096
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', intMasterId = 179097
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', intMasterId = 179098
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', intMasterId = 179099
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', intMasterId = 179100
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', intMasterId = 179101
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', intMasterId = 179102
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', intMasterId = 179103
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', intMasterId = 179104
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', intMasterId = 179105
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', intMasterId = 179106
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', intMasterId = 179107
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', intMasterId = 179108
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', intMasterId = 179109
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', intMasterId = 179110
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', intMasterId = 179111
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', intMasterId = 179112
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', intMasterId = 179113
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', intMasterId = 179114
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', intMasterId = 179115
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', intMasterId = 179116
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', intMasterId = 179117
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', intMasterId = 179118
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', intMasterId = 179119
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', intMasterId = 179120
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', intMasterId = 179121
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', intMasterId = 179122
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', intMasterId = 179123
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', intMasterId = 179124
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', intMasterId = 179125
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', intMasterId = 179126
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', intMasterId = 179127
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', intMasterId = 179128
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', intMasterId = 179129
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', intMasterId = 179130
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', intMasterId = 179131
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', intMasterId = 179132
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', intMasterId = 179133
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', intMasterId = 179134
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', intMasterId = 179135
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', intMasterId = 179136
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', intMasterId = 179137
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', intMasterId = 179138
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', intMasterId = 179139
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', intMasterId = 179140
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', intMasterId = 179141
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', intMasterId = 179142
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', intMasterId = 179143
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', intMasterId = 179144
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', intMasterId = 179145
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', intMasterId = 179146
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', intMasterId = 179147
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', intMasterId = 179148
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', intMasterId = 179149
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', intMasterId = 179150
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', intMasterId = 179151
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', intMasterId = 179152
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', intMasterId = 179153
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', intMasterId = 179154
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', intMasterId = 179155
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', intMasterId = 179156
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', intMasterId = 179157
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', intMasterId = 179158
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', intMasterId = 179159
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', intMasterId = 179160
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', intMasterId = 179161
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', intMasterId = 179162
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', intMasterId = 179163
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', intMasterId = 179164
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', intMasterId = 179165
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', intMasterId = 179166
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', intMasterId = 179167
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', intMasterId = 179168
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', intMasterId = 179169
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', intMasterId = 179170
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', intMasterId = 179171
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', intMasterId = 179172
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', intMasterId = 179173
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', intMasterId = 179174
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', intMasterId = 179175
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', intMasterId = 179176
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', intMasterId = 179177
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', intMasterId = 179178
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', intMasterId = 179179
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', intMasterId = 179180
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', intMasterId = 179181
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', intMasterId = 179182
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', intMasterId = 179183
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', intMasterId = 179184
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', intMasterId = 179185
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', intMasterId = 179186
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', intMasterId = 179187
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', intMasterId = 179188
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', intMasterId = 179189
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', intMasterId = 179190
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', intMasterId = 179191
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', intMasterId = 179192
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', intMasterId = 179193
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', intMasterId = 179194
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', intMasterId = 179195
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', intMasterId = 179196
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', intMasterId = 179197
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', intMasterId = 179198
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', intMasterId = 179199
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', intMasterId = 179200
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', intMasterId = 179201
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', intMasterId = 179202
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', intMasterId = 179203
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', intMasterId = 179204
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', intMasterId = 179205
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', intMasterId = 179206
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', intMasterId = 179207
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', intMasterId = 179208
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', intMasterId = 179209
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', intMasterId = 179210
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', intMasterId = 179211
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', intMasterId = 179212
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', intMasterId = 179213
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', intMasterId = 179214
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', intMasterId = 179215
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', intMasterId = 179216
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', intMasterId = 179217
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', intMasterId = 179218
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', intMasterId = 179219
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', intMasterId = 179220
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', intMasterId = 179221
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', intMasterId = 179222
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', intMasterId = 179223
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', intMasterId = 179224
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', intMasterId = 179225
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', intMasterId = 179226
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', intMasterId = 179227
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', intMasterId = 179228
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', intMasterId = 179229
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', intMasterId = 179230
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', intMasterId = 179231
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', intMasterId = 179232
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', intMasterId = 179233
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', intMasterId = 179234
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', intMasterId = 179235
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', intMasterId = 179236
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', intMasterId = 179237
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', intMasterId = 179238
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', intMasterId = 179239
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', intMasterId = 179240
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', intMasterId = 179241
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', intMasterId = 179242
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', intMasterId = 179243
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', intMasterId = 179244
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', intMasterId = 179245
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', intMasterId = 179246
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', intMasterId = 179247
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', intMasterId = 179248
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', intMasterId = 179249
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', intMasterId = 179250
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', intMasterId = 179251
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', intMasterId = 179252
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', intMasterId = 179253
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', intMasterId = 179254
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', intMasterId = 179255
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', intMasterId = 179256
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', intMasterId = 179257
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', intMasterId = 179258
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', intMasterId = 179259
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', intMasterId = 179260
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', intMasterId = 179261
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', intMasterId = 179262
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', intMasterId = 179263
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', intMasterId = 179264
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', intMasterId = 179265
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', intMasterId = 179266
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', intMasterId = 179267
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', intMasterId = 179268
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', intMasterId = 179269
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', intMasterId = 179270
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', intMasterId = 179271
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', intMasterId = 179272
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', intMasterId = 179273
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', intMasterId = 179274
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', intMasterId = 179275
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', intMasterId = 179276
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', intMasterId = 179277
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', intMasterId = 179278
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', intMasterId = 179279
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', intMasterId = 179280
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', intMasterId = 179281
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', intMasterId = 179282
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', intMasterId = 179283
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', intMasterId = 179284
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', intMasterId = 179285
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', intMasterId = 179286
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', intMasterId = 179287
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', intMasterId = 179288
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', intMasterId = 179289
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', intMasterId = 179290
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', intMasterId = 179291
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', intMasterId = 179292
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', intMasterId = 179293
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', intMasterId = 179294
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', intMasterId = 179295
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', intMasterId = 179296

	--MFT-1704
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A099', strScheduleCode = '14', strType = 'Gasoline', intMasterId = 179297
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A099', strScheduleCode = '14', strType = 'Gasoline', intMasterId = 179298
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A099', strScheduleCode = '14', strType = 'Gasoline', intMasterId = 179299
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A099', strScheduleCode = '14', strType = 'Gasoline', intMasterId = 179300
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A099', strScheduleCode = '14', strType = 'Gasoline', intMasterId = 179301
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A099', strScheduleCode = '14', strType = 'Gasoline', intMasterId = 179302
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A099', strScheduleCode = '14', strType = 'Gasoline', intMasterId = 179303
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A099', strScheduleCode = '14', strType = 'Gasoline', intMasterId = 179304
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A099', strScheduleCode = '14', strType = 'Gasoline', intMasterId = 179305
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A099', strScheduleCode = '14', strType = 'Gasoline', intMasterId = 179306
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A099', strScheduleCode = '14', strType = 'Gasoline', intMasterId = 179307
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A099', strScheduleCode = '14', strType = 'Gasoline', intMasterId = 179308
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A099', strScheduleCode = '14', strType = 'Gasoline', intMasterId = 179309
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A099', strScheduleCode = '14', strType = 'Special Fuels', intMasterId = 179310
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A099', strScheduleCode = '14', strType = 'Special Fuels', intMasterId = 179311
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A099', strScheduleCode = '14', strType = 'Special Fuels', intMasterId = 179312
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A099', strScheduleCode = '14', strType = 'Special Fuels', intMasterId = 179313
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A099', strScheduleCode = '14', strType = 'Special Fuels', intMasterId = 179314
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A099', strScheduleCode = '14', strType = 'Special Fuels', intMasterId = 179315
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A099', strScheduleCode = '14', strType = 'Special Fuels', intMasterId = 179316
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A099', strScheduleCode = '14', strType = 'Special Fuels', intMasterId = 179317
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A099', strScheduleCode = '14', strType = 'Special Fuels', intMasterId = 179318
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A099', strScheduleCode = '14', strType = 'Special Fuels', intMasterId = 179319
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A099', strScheduleCode = '14', strType = 'Special Fuels', intMasterId = 179320
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A099', strScheduleCode = '14', strType = 'Special Fuels', intMasterId = 179321
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A099', strScheduleCode = '14', strType = 'Special Fuels', intMasterId = 179322
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A099', strScheduleCode = '14', strType = 'Special Fuels', intMasterId = 179323
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A099', strScheduleCode = '14', strType = 'Special Fuels', intMasterId = 179324
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A099', strScheduleCode = '14', strType = 'Special Fuels', intMasterId = 179325
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A099', strScheduleCode = '14', strType = 'Special Fuels', intMasterId = 179326
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A099', strScheduleCode = '14', strType = 'Special Fuels', intMasterId = 179327
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A099', strScheduleCode = '14', strType = 'Special Fuels', intMasterId = 179328
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A099', strScheduleCode = '14', strType = 'Special Fuels', intMasterId = 179329
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A099', strScheduleCode = '14', strType = 'Special Fuels', intMasterId = 179330
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A099', strScheduleCode = '14', strType = 'Special Fuels', intMasterId = 179331
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A099', strScheduleCode = '14', strType = 'Special Fuels', intMasterId = 179332
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A099', strScheduleCode = '14', strType = 'Special Fuels', intMasterId = 179333
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Gasoline', intMasterId = 179334
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Gasoline', intMasterId = 179335
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Gasoline', intMasterId = 179336
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Gasoline', intMasterId = 179337
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Gasoline', intMasterId = 179338
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Gasoline', intMasterId = 179339
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Gasoline', intMasterId = 179340
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Gasoline', intMasterId = 179341
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Gasoline', intMasterId = 179342
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Gasoline', intMasterId = 179343
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Gasoline', intMasterId = 179344
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Gasoline', intMasterId = 179345
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Gasoline', intMasterId = 179346
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Special Fuels', intMasterId = 179347
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Special Fuels', intMasterId = 179348
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Special Fuels', intMasterId = 179349
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Special Fuels', intMasterId = 179350
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Special Fuels', intMasterId = 179351
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Special Fuels', intMasterId = 179352
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Special Fuels', intMasterId = 179353
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Special Fuels', intMasterId = 179354
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Special Fuels', intMasterId = 179355
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Special Fuels', intMasterId = 179356
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Special Fuels', intMasterId = 179357
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Special Fuels', intMasterId = 179358
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Special Fuels', intMasterId = 179359
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Special Fuels', intMasterId = 179360
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Special Fuels', intMasterId = 179361
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Special Fuels', intMasterId = 179362
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Special Fuels', intMasterId = 179363
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Special Fuels', intMasterId = 179364
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Special Fuels', intMasterId = 179365
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Special Fuels', intMasterId = 179366
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Special Fuels', intMasterId = 179367
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Special Fuels', intMasterId = 179368
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Special Fuels', intMasterId = 179369
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Special Fuels', intMasterId = 179370

	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '1_TR', strType = '',	intMasterId = 179371
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '1_TR', strType = '',	intMasterId = 179372
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '1_TR', strType = '',	intMasterId = 179373
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '1_TR', strType = '',	intMasterId = 179374
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '1_TR', strType = '',	intMasterId = 179375
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '1_TR', strType = '',	intMasterId = 179376
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '1_TR', strType = '',	intMasterId = 179377
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '1_TR', strType = '',	intMasterId = 179378
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '1_TR', strType = '',	intMasterId = 179379
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '1_TR', strType = '',	intMasterId = 179380
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '1_TR', strType = '',	intMasterId = 179381
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '1_TR', strType = '',	intMasterId = 179382
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '1_TR', strType = '',	intMasterId = 179383
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '1_TR', strType = '',	intMasterId = 179384
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '1_TR', strType = '',	intMasterId = 179385
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '1_TR', strType = '',	intMasterId = 179386
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '1_TR', strType = '',	intMasterId = 179387
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '1_TR', strType = '',	intMasterId = 179388
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '1_TR', strType = '',	intMasterId = 179389
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '1_TR', strType = '',	intMasterId = 179390
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '1_TR', strType = '',	intMasterId = 179391
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '1_TR', strType = '',	intMasterId = 179392
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '1_TR', strType = '',	intMasterId = 179393
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '1_TR', strType = '',	intMasterId = 179394
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '',	intMasterId = 179395
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '',	intMasterId = 179396
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '',	intMasterId = 179397
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '',	intMasterId = 179398
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '',	intMasterId = 179399
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '',	intMasterId = 179400
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '',	intMasterId = 179401
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '',	intMasterId = 179402
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '',	intMasterId = 179403
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '',	intMasterId = 179404
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '',	intMasterId = 179405
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '',	intMasterId = 179406
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '',	intMasterId = 179407
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '',	intMasterId = 179408
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '',	intMasterId = 179409
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '',	intMasterId = 179410
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '',	intMasterId = 179411
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '',	intMasterId = 179412
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '',	intMasterId = 179413
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '',	intMasterId = 179414
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '',	intMasterId = 179415
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '',	intMasterId = 179416
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '',	intMasterId = 179417
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '',	intMasterId = 179418
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '',	intMasterId = 179419
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '',	intMasterId = 179420
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '',	intMasterId = 179421
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '',	intMasterId = 179422
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '',	intMasterId = 179423
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '',	intMasterId = 179424
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '',	intMasterId = 179425
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '',	intMasterId = 179426
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '',	intMasterId = 179427
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '',	intMasterId = 179428
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '',	intMasterId = 179429
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '',	intMasterId = 179430
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '',	intMasterId = 179431
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '',	intMasterId = 179432
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '',	intMasterId = 179433
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '',	intMasterId = 179434
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '',	intMasterId = 179435
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '',	intMasterId = 179436
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '',	intMasterId = 179437
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '',	intMasterId = 179438
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '',	intMasterId = 179439
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '',	intMasterId = 179440
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '',	intMasterId = 179441
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '',	intMasterId = 179442
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '',	intMasterId = 179443
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '',	intMasterId = 179444
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '',	intMasterId = 179445
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '',	intMasterId = 179446
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '',	intMasterId = 179447
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '',	intMasterId = 179448
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '',	intMasterId = 179449
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '',	intMasterId = 179450
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '',	intMasterId = 179451
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '',	intMasterId = 179452
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '',	intMasterId = 179453
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '',	intMasterId = 179454
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '',	intMasterId = 179455
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '',	intMasterId = 179456
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '',	intMasterId = 179457
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '',	intMasterId = 179458
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '',	intMasterId = 179459
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '',	intMasterId = 179460
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '',	intMasterId = 179461
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '',	intMasterId = 179462
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '',	intMasterId = 179463
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '',	intMasterId = 179464
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '',	intMasterId = 179465
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '',	intMasterId = 179466
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '',	intMasterId = 179467
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '',	intMasterId = 179468
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '',	intMasterId = 179469
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '',	intMasterId = 179470
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '',	intMasterId = 179471
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '',	intMasterId = 179472
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '',	intMasterId = 179473
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '',	intMasterId = 179474
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '',	intMasterId = 179475
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '',	intMasterId = 179476
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '',	intMasterId = 179477
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '',	intMasterId = 179478
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '',	intMasterId = 179479
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '',	intMasterId = 179480
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '',	intMasterId = 179481
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '',	intMasterId = 179482
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '',	intMasterId = 179483
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '',	intMasterId = 179484
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '',	intMasterId = 179485
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '',	intMasterId = 179486
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '',	intMasterId = 179487
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '',	intMasterId = 179488
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '',	intMasterId = 179489
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '',	intMasterId = 179490
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '',	intMasterId = 179491
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '',	intMasterId = 179492
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '',	intMasterId = 179493
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '',	intMasterId = 179494
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '',	intMasterId = 179495
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '',	intMasterId = 179496
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '',	intMasterId = 179497
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '',	intMasterId = 179498
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '',	intMasterId = 179499
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '',	intMasterId = 179500
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '',	intMasterId = 179501
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '',	intMasterId = 179502
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '',	intMasterId = 179503
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '',	intMasterId = 179504
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '',	intMasterId = 179505
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '',	intMasterId = 179506
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '',	intMasterId = 179507
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '',	intMasterId = 179508
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '',	intMasterId = 179509
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '',	intMasterId = 179510
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '',	intMasterId = 179511
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '',	intMasterId = 179512
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '',	intMasterId = 179513
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '',	intMasterId = 179514
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '2_TR', strType = '',	intMasterId = 179515
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '2_TR', strType = '',	intMasterId = 179516
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '2_TR', strType = '',	intMasterId = 179517
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '2_TR', strType = '',	intMasterId = 179518
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '2_TR', strType = '',	intMasterId = 179519
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '2_TR', strType = '',	intMasterId = 179520
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '2_TR', strType = '',	intMasterId = 179521
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '2_TR', strType = '',	intMasterId = 179522
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '2_TR', strType = '',	intMasterId = 179523
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '2_TR', strType = '',	intMasterId = 179524
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '2_TR', strType = '',	intMasterId = 179525
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '2_TR', strType = '',	intMasterId = 179526
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '2_TR', strType = '',	intMasterId = 179527
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '2_TR', strType = '',	intMasterId = 179528
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '2_TR', strType = '',	intMasterId = 179529
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '2_TR', strType = '',	intMasterId = 179530
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '2_TR', strType = '',	intMasterId = 179531
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '2_TR', strType = '',	intMasterId = 179532
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '2_TR', strType = '',	intMasterId = 179533
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '2_TR', strType = '',	intMasterId = 179534
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '2_TR', strType = '',	intMasterId = 179535
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '2_TR', strType = '',	intMasterId = 179536
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '2_TR', strType = '',	intMasterId = 179537
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '2_TR', strType = '',	intMasterId = 179538
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '',	intMasterId = 179539
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '',	intMasterId = 179540
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '',	intMasterId = 179541
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '',	intMasterId = 179542
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '',	intMasterId = 179543
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '',	intMasterId = 179544
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '',	intMasterId = 179545
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '',	intMasterId = 179546
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '',	intMasterId = 179547
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '',	intMasterId = 179548
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '',	intMasterId = 179549
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '',	intMasterId = 179550
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '',	intMasterId = 179551
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '',	intMasterId = 179552
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '',	intMasterId = 179553
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '',	intMasterId = 179554
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '',	intMasterId = 179555
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '',	intMasterId = 179556
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '',	intMasterId = 179557
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '',	intMasterId = 179558
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '',	intMasterId = 179559
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '',	intMasterId = 179560
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '',	intMasterId = 179561
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '',	intMasterId = 179562
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '',	intMasterId = 179563
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '',	intMasterId = 179564
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '',	intMasterId = 179565
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '',	intMasterId = 179566
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '',	intMasterId = 179567
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '',	intMasterId = 179568
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '',	intMasterId = 179569
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '',	intMasterId = 179570
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '',	intMasterId = 179571
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '',	intMasterId = 179572
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '',	intMasterId = 179573
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '',	intMasterId = 179574
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '',	intMasterId = 179575
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '',	intMasterId = 179576
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '',	intMasterId = 179577
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '',	intMasterId = 179578
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '',	intMasterId = 179579
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '',	intMasterId = 179580
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '',	intMasterId = 179581
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '',	intMasterId = 179582
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '',	intMasterId = 179583
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '',	intMasterId = 179584
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '',	intMasterId = 179585
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '',	intMasterId = 179586
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '',	intMasterId = 179587
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '',	intMasterId = 179588
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '',	intMasterId = 179589
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '',	intMasterId = 179590
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '',	intMasterId = 179591
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '',	intMasterId = 179592
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '',	intMasterId = 179593
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '',	intMasterId = 179594
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '',	intMasterId = 179595
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '',	intMasterId = 179596
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '',	intMasterId = 179597
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '',	intMasterId = 179598
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '',	intMasterId = 179599
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '',	intMasterId = 179600
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '',	intMasterId = 179601
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '',	intMasterId = 179602
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '',	intMasterId = 179603
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '',	intMasterId = 179604
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '',	intMasterId = 179605
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '',	intMasterId = 179606
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '',	intMasterId = 179607
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '',	intMasterId = 179608
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '',	intMasterId = 179609
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '',	intMasterId = 179610
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '',	intMasterId = 179611
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '',	intMasterId = 179612
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '',	intMasterId = 179613
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '',	intMasterId = 179614
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '',	intMasterId = 179615
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '',	intMasterId = 179616
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '',	intMasterId = 179617
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '',	intMasterId = 179618
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '',	intMasterId = 179619
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '',	intMasterId = 179620
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '',	intMasterId = 179621
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '',	intMasterId = 179622
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '',	intMasterId = 179623
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '',	intMasterId = 179624
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '',	intMasterId = 179625
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '',	intMasterId = 179626
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '',	intMasterId = 179627
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '',	intMasterId = 179628
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '',	intMasterId = 179629
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '',	intMasterId = 179630
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '',	intMasterId = 179631
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '',	intMasterId = 179632
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '',	intMasterId = 179633
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '',	intMasterId = 179634
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '',	intMasterId = 179635
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '',	intMasterId = 179636
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '',	intMasterId = 179637
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '',	intMasterId = 179638
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '',	intMasterId = 179639
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '',	intMasterId = 179640
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '',	intMasterId = 179641
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '',	intMasterId = 179642
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '',	intMasterId = 179643
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '',	intMasterId = 179644
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '',	intMasterId = 179645
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '',	intMasterId = 179646
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '',	intMasterId = 179647
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '',	intMasterId = 179648
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '',	intMasterId = 179649
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '',	intMasterId = 179650
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '',	intMasterId = 179651
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '',	intMasterId = 179652
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '',	intMasterId = 179653
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '',	intMasterId = 179654
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '',	intMasterId = 179655
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '',	intMasterId = 179656
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '',	intMasterId = 179657
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '',	intMasterId = 179658
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '',	intMasterId = 179659
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '',	intMasterId = 179660
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '',	intMasterId = 179661
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '',	intMasterId = 179662
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '',	intMasterId = 179663
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '',	intMasterId = 179664
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '',	intMasterId = 179665
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '',	intMasterId = 179666
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '',	intMasterId = 179667
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '',	intMasterId = 179668
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '',	intMasterId = 179669
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '',	intMasterId = 179670
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '',	intMasterId = 179671
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '',	intMasterId = 179672
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '',	intMasterId = 179673
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '',	intMasterId = 179674
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '',	intMasterId = 179675
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '',	intMasterId = 179676
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '',	intMasterId = 179677
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '',	intMasterId = 179678
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '',	intMasterId = 179679
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '',	intMasterId = 179680
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '',	intMasterId = 179681
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '',	intMasterId = 179682
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '',	intMasterId = 179683
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '',	intMasterId = 179684
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '',	intMasterId = 179685
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '',	intMasterId = 179686
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '',	intMasterId = 179687
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '',	intMasterId = 179688
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '',	intMasterId = 179689
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '',	intMasterId = 179690
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '',	intMasterId = 179691
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '',	intMasterId = 179692
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '',	intMasterId = 179693
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '',	intMasterId = 179694
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '',	intMasterId = 179695
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '',	intMasterId = 179696
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '',	intMasterId = 179697
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '',	intMasterId = 179698
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '',	intMasterId = 179699
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '',	intMasterId = 179700
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '',	intMasterId = 179701
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '',	intMasterId = 179702
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '',	intMasterId = 179703
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '',	intMasterId = 179704
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '',	intMasterId = 179705
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '',	intMasterId = 179706
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '',	intMasterId = 179707
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '',	intMasterId = 179708
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '',	intMasterId = 179709
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '',	intMasterId = 179710
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '',	intMasterId = 179711
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '',	intMasterId = 179712
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '',	intMasterId = 179713
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '',	intMasterId = 179714
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '',	intMasterId = 179715
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '',	intMasterId = 179716
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '',	intMasterId = 179717
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '',	intMasterId = 179718
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '',	intMasterId = 179719
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '',	intMasterId = 179720
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '',	intMasterId = 179721
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '',	intMasterId = 179722
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '',	intMasterId = 179723
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '',	intMasterId = 179724
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '',	intMasterId = 179725
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '',	intMasterId = 179726
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '',	intMasterId = 179727
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '',	intMasterId = 179728
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '',	intMasterId = 179729
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '',	intMasterId = 179730
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '6_TR', strType = '',	intMasterId = 179731
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '6_TR', strType = '',	intMasterId = 179732
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '6_TR', strType = '',	intMasterId = 179733
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '6_TR', strType = '',	intMasterId = 179734
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '6_TR', strType = '',	intMasterId = 179735
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '6_TR', strType = '',	intMasterId = 179736
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '6_TR', strType = '',	intMasterId = 179737
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '6_TR', strType = '',	intMasterId = 179738
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '6_TR', strType = '',	intMasterId = 179739
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '6_TR', strType = '',	intMasterId = 179740
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '6_TR', strType = '',	intMasterId = 179741
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '6_TR', strType = '',	intMasterId = 179742
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '6_TR', strType = '',	intMasterId = 179743
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '6_TR', strType = '',	intMasterId = 179744
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '6_TR', strType = '',	intMasterId = 179745
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '6_TR', strType = '',	intMasterId = 179746
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '6_TR', strType = '',	intMasterId = 179747
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '6_TR', strType = '',	intMasterId = 179748
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '6_TR', strType = '',	intMasterId = 179749
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '6_TR', strType = '',	intMasterId = 179750
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '6_TR', strType = '',	intMasterId = 179751
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '6_TR', strType = '',	intMasterId = 179752
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '6_TR', strType = '',	intMasterId = 179753
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '6_TR', strType = '',	intMasterId = 179754
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '',	intMasterId = 179755
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '',	intMasterId = 179756
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '',	intMasterId = 179757
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '',	intMasterId = 179758
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '',	intMasterId = 179759
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '',	intMasterId = 179760
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '',	intMasterId = 179761
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '',	intMasterId = 179762
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '',	intMasterId = 179763
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '',	intMasterId = 179764
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '',	intMasterId = 179765
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '',	intMasterId = 179766
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '',	intMasterId = 179767
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '',	intMasterId = 179768
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '',	intMasterId = 179769
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '',	intMasterId = 179770
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '',	intMasterId = 179771
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '',	intMasterId = 179772
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '',	intMasterId = 179773
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '',	intMasterId = 179774
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '',	intMasterId = 179775
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '',	intMasterId = 179776
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '',	intMasterId = 179777
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '',	intMasterId = 179778
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '',	intMasterId = 179779
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '',	intMasterId = 179780
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '',	intMasterId = 179781
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '',	intMasterId = 179782
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '',	intMasterId = 179783
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '',	intMasterId = 179784
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '',	intMasterId = 179785
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '',	intMasterId = 179786
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '',	intMasterId = 179787
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '',	intMasterId = 179788
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '',	intMasterId = 179789
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '',	intMasterId = 179790
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '',	intMasterId = 179791
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '',	intMasterId = 179792
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '',	intMasterId = 179793
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '',	intMasterId = 179794
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '',	intMasterId = 179795
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '',	intMasterId = 179796
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '',	intMasterId = 179797
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '',	intMasterId = 179798
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '',	intMasterId = 179799
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '',	intMasterId = 179800
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '',	intMasterId = 179801
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '',	intMasterId = 179802
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '',	intMasterId = 179803
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '',	intMasterId = 179804
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '',	intMasterId = 179805
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '',	intMasterId = 179806
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '',	intMasterId = 179807
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '',	intMasterId = 179808
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '',	intMasterId = 179809
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '',	intMasterId = 179810
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '',	intMasterId = 179811
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '',	intMasterId = 179812
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '',	intMasterId = 179813
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '',	intMasterId = 179814
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '',	intMasterId = 179815
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '',	intMasterId = 179816
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '',	intMasterId = 179817
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '',	intMasterId = 179818
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '',	intMasterId = 179819
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '',	intMasterId = 179820
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '',	intMasterId = 179821
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '',	intMasterId = 179822
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '',	intMasterId = 179823
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '',	intMasterId = 179824
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '',	intMasterId = 179825
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '',	intMasterId = 179826
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '8_TR', strType = '',	intMasterId = 179827
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '8_TR', strType = '',	intMasterId = 179828
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '8_TR', strType = '',	intMasterId = 179829
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '8_TR', strType = '',	intMasterId = 179830
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '8_TR', strType = '',	intMasterId = 179831
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '8_TR', strType = '',	intMasterId = 179832
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '8_TR', strType = '',	intMasterId = 179833
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '8_TR', strType = '',	intMasterId = 179834
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '8_TR', strType = '',	intMasterId = 179835
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '8_TR', strType = '',	intMasterId = 179836
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '8_TR', strType = '',	intMasterId = 179837
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '8_TR', strType = '',	intMasterId = 179838
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '8_TR', strType = '',	intMasterId = 179839
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '8_TR', strType = '',	intMasterId = 179840
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '8_TR', strType = '',	intMasterId = 179841
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '8_TR', strType = '',	intMasterId = 179842
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '8_TR', strType = '',	intMasterId = 179843
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '8_TR', strType = '',	intMasterId = 179844
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '8_TR', strType = '',	intMasterId = 179845
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '8_TR', strType = '',	intMasterId = 179846
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '8_TR', strType = '',	intMasterId = 179847
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '8_TR', strType = '',	intMasterId = 179848
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '8_TR', strType = '',	intMasterId = 179849
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '8_TR', strType = '',	intMasterId = 179850
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '9_TR', strType = '',	intMasterId = 179851
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '9_TR', strType = '',	intMasterId = 179852
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '9_TR', strType = '',	intMasterId = 179853
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '9_TR', strType = '',	intMasterId = 179854
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '9_TR', strType = '',	intMasterId = 179855
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '9_TR', strType = '',	intMasterId = 179856
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '9_TR', strType = '',	intMasterId = 179857
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '9_TR', strType = '',	intMasterId = 179858
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '9_TR', strType = '',	intMasterId = 179859
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '9_TR', strType = '',	intMasterId = 179860
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '9_TR', strType = '',	intMasterId = 179861
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '9_TR', strType = '',	intMasterId = 179862
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '9_TR', strType = '',	intMasterId = 179863
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '9_TR', strType = '',	intMasterId = 179864
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '9_TR', strType = '',	intMasterId = 179865
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '9_TR', strType = '',	intMasterId = 179866
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '9_TR', strType = '',	intMasterId = 179867
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '9_TR', strType = '',	intMasterId = 179868
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '9_TR', strType = '',	intMasterId = 179869
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '9_TR', strType = '',	intMasterId = 179870
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '9_TR', strType = '',	intMasterId = 179871
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '9_TR', strType = '',	intMasterId = 179872
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '9_TR', strType = '',	intMasterId = 179873
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '9_TR', strType = '',	intMasterId = 179874
	
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '',	intMasterId = 179875
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '',	intMasterId = 179876
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '',	intMasterId = 179877
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '',	intMasterId = 179878
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '',	intMasterId = 179879
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '',	intMasterId = 179880
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '',	intMasterId = 179881
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '',	intMasterId = 179882
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '',	intMasterId = 179883
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '',	intMasterId = 179884
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '',	intMasterId = 179885
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '',	intMasterId = 179886
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '',	intMasterId = 179887
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '',	intMasterId = 179888
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '',	intMasterId = 179889
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '',	intMasterId = 179890
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '',	intMasterId = 179891
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '',	intMasterId = 179892
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '',	intMasterId = 179893
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '',	intMasterId = 179894
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '',	intMasterId = 179895
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '',	intMasterId = 179896
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '',	intMasterId = 179897
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '',	intMasterId = 179898
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '',	intMasterId = 179899
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '',	intMasterId = 179900
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '',	intMasterId = 179901
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '',	intMasterId = 179902
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '',	intMasterId = 179903
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '',	intMasterId = 179904
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '',	intMasterId = 179905
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '',	intMasterId = 179906
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '',	intMasterId = 179907
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '',	intMasterId = 179908
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '',	intMasterId = 179909
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '',	intMasterId = 179910
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '',	intMasterId = 179911
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '',	intMasterId = 179912
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '',	intMasterId = 179913
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '',	intMasterId = 179914
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '',	intMasterId = 179915
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '',	intMasterId = 179916
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '',	intMasterId = 179917
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '',	intMasterId = 179918
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '',	intMasterId = 179919
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '',	intMasterId = 179920
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '',	intMasterId = 179921
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '',	intMasterId = 179922
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '',	intMasterId = 179923
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '',	intMasterId = 179924
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '',	intMasterId = 179925
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '',	intMasterId = 179926
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '',	intMasterId = 179927
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '',	intMasterId = 179928
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '',	intMasterId = 179929
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '',	intMasterId = 179930
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '',	intMasterId = 179931
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '',	intMasterId = 179932
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '',	intMasterId = 179933
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '',	intMasterId = 179934
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '',	intMasterId = 179935
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '',	intMasterId = 179936
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '',	intMasterId = 179937
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '',	intMasterId = 179938
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '',	intMasterId = 179939
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '',	intMasterId = 179940
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '',	intMasterId = 179941
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '',	intMasterId = 179942
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '',	intMasterId = 179943
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '',	intMasterId = 179944
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '',	intMasterId = 179945
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '',	intMasterId = 179946
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '',	intMasterId = 179947
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '',	intMasterId = 179948
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '',	intMasterId = 179949
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '',	intMasterId = 179950
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '',	intMasterId = 179951
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '',	intMasterId = 179952
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '',	intMasterId = 179953
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '',	intMasterId = 179954
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '',	intMasterId = 179955
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '',	intMasterId = 179956
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '',	intMasterId = 179957
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '',	intMasterId = 179958
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '',	intMasterId = 179959
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '',	intMasterId = 179960
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '',	intMasterId = 179961
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '',	intMasterId = 179962
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '',	intMasterId = 179963
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '',	intMasterId = 179964
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '',	intMasterId = 179965
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '',	intMasterId = 179966
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '',	intMasterId = 179967
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '',	intMasterId = 179968
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '',	intMasterId = 179969
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '',	intMasterId = 179970
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '',	intMasterId = 179971
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '',	intMasterId = 179972
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '',	intMasterId = 179973
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '',	intMasterId = 179974
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '',	intMasterId = 179975
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '',	intMasterId = 179976
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '',	intMasterId = 179977
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '',	intMasterId = 179978
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '',	intMasterId = 179979
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '',	intMasterId = 179980
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '',	intMasterId = 179981
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '',	intMasterId = 179982
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '',	intMasterId = 179983
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '',	intMasterId = 179984
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '',	intMasterId = 179985
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '',	intMasterId = 179986
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '',	intMasterId = 179987
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '',	intMasterId = 179988
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '',	intMasterId = 179989
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '',	intMasterId = 179990
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '',	intMasterId = 179991
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '',	intMasterId = 179992
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '',	intMasterId = 179993
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '',	intMasterId = 179994
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '',	intMasterId = 179995
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '',	intMasterId = 179996
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '',	intMasterId = 179997
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '',	intMasterId = 179998
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '',	intMasterId = 179999
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '',	intMasterId = 180000
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '',	intMasterId = 180001
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '',	intMasterId = 180002
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '',	intMasterId = 180003
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '',	intMasterId = 180004
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '',	intMasterId = 180005
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '',	intMasterId = 180006
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '',	intMasterId = 180007
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '',	intMasterId = 180008
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '',	intMasterId = 180009
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '',	intMasterId = 180010
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '',	intMasterId = 180011
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '',	intMasterId = 180012
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '',	intMasterId = 180013
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '',	intMasterId = 180014
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '',	intMasterId = 180015
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '',	intMasterId = 180016
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '',	intMasterId = 180017
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '',	intMasterId = 180018
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '',	intMasterId = 180019
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '',	intMasterId = 180020
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '',	intMasterId = 180021
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '',	intMasterId = 180022
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '',	intMasterId = 180023
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '',	intMasterId = 180024
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '',	intMasterId = 180025
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '',	intMasterId = 180026
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '',	intMasterId = 180027
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '',	intMasterId = 180028
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '',	intMasterId = 180029
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '',	intMasterId = 180030
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '',	intMasterId = 180031
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '',	intMasterId = 180032
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '',	intMasterId = 180033
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '',	intMasterId = 180034
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '',	intMasterId = 180035
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '',	intMasterId = 180036
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '',	intMasterId = 180037
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '',	intMasterId = 180038
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '',	intMasterId = 180039
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '',	intMasterId = 180040
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '',	intMasterId = 180041
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '',	intMasterId = 180042
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '',	intMasterId = 180043
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '',	intMasterId = 180044
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '',	intMasterId = 180045
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '',	intMasterId = 180046
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '',	intMasterId = 180047
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '',	intMasterId = 180048
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '',	intMasterId = 180049
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '',	intMasterId = 180050
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '',	intMasterId = 180051
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '',	intMasterId = 180052
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '',	intMasterId = 180053
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '',	intMasterId = 180054
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '',	intMasterId = 180055
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '',	intMasterId = 180056
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '',	intMasterId = 180057
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '',	intMasterId = 180058
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '',	intMasterId = 180059
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '',	intMasterId = 180060
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '',	intMasterId = 180061
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '',	intMasterId = 180062
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '',	intMasterId = 180063
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '',	intMasterId = 180064
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '',	intMasterId = 180065
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '',	intMasterId = 180066
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '',	intMasterId = 180067
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '',	intMasterId = 180068
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '',	intMasterId = 180069
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '',	intMasterId = 180070
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '',	intMasterId = 180071
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '',	intMasterId = 180072
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '',	intMasterId = 180073
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '',	intMasterId = 180074
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '',	intMasterId = 180075
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '',	intMasterId = 180076
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '',	intMasterId = 180077
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '',	intMasterId = 180078
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '',	intMasterId = 180079
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '',	intMasterId = 180080
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '',	intMasterId = 180081
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '',	intMasterId = 180082
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '',	intMasterId = 180083
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '',	intMasterId = 180084
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '',	intMasterId = 180085
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '',	intMasterId = 180086
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '',	intMasterId = 180087
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '',	intMasterId = 180088
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '',	intMasterId = 180089
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '',	intMasterId = 180090

	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', intMasterId = 180091
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', intMasterId = 180092
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', intMasterId = 180093
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', intMasterId = 180094
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', intMasterId = 180095
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', intMasterId = 180096
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', intMasterId = 180097
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', intMasterId = 180098
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', intMasterId = 180099
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', intMasterId = 180100
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', intMasterId = 180101
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', intMasterId = 180102
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', intMasterId = 180103
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', intMasterId = 180104
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', intMasterId = 180105
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', intMasterId = 180106
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', intMasterId = 180107
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', intMasterId = 180108
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', intMasterId = 180109
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', intMasterId = 180110
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', intMasterId = 180111
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', intMasterId = 180112
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', intMasterId = 180113
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', intMasterId = 180114
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', intMasterId = 180115
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', intMasterId = 180116
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', intMasterId = 180117
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', intMasterId = 180118
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', intMasterId = 180119
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', intMasterId = 180120
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', intMasterId = 180121
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', intMasterId = 180122
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', intMasterId = 180123
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', intMasterId = 180124
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', intMasterId = 180125
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', intMasterId = 180126
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', intMasterId = 180127
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', intMasterId = 180128
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', intMasterId = 180129
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', intMasterId = 180130
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', intMasterId = 180131
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', intMasterId = 180132
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', intMasterId = 180133
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', intMasterId = 180134
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', intMasterId = 180135
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', intMasterId = 180136
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', intMasterId = 180137
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', intMasterId = 180138
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', intMasterId = 180139
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', intMasterId = 180140
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', intMasterId = 180141
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', intMasterId = 180142
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '6_TR', strType = '', intMasterId = 180143
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '6_TR', strType = '', intMasterId = 180144
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '6_TR', strType = '', intMasterId = 180145
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '6_TR', strType = '', intMasterId = 180146
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '6_TR', strType = '', intMasterId = 180147
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '6_TR', strType = '', intMasterId = 180148
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '6_TR', strType = '', intMasterId = 180149
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '6_TR', strType = '', intMasterId = 180150
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '6_TR', strType = '', intMasterId = 180151
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '6_TR', strType = '', intMasterId = 180152
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '6_TR', strType = '', intMasterId = 180153
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '6_TR', strType = '', intMasterId = 180154
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '6_TR', strType = '', intMasterId = 180155
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '5D_TN_TR', strType = '', intMasterId = 180156
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '5D_TN_TR', strType = '', intMasterId = 180157
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '5D_TN_TR', strType = '', intMasterId = 180158
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '5D_TN_TR', strType = '', intMasterId = 180159
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '5D_TN_TR', strType = '', intMasterId = 180160
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '5D_TN_TR', strType = '', intMasterId = 180161
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '5D_TN_TR', strType = '', intMasterId = 180162
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '5D_TN_TR', strType = '', intMasterId = 180163
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '5D_TN_TR', strType = '', intMasterId = 180164
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '5D_TN_TR', strType = '', intMasterId = 180165
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '5D_TN_TR', strType = '', intMasterId = 180166
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '5D_TN_TR', strType = '', intMasterId = 180167
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '5D_TN_TR', strType = '', intMasterId = 180168
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '5D_IN_TR', strType = '', intMasterId = 180169
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '5D_IN_TR', strType = '', intMasterId = 180170
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '5D_IN_TR', strType = '', intMasterId = 180171
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '5D_IN_TR', strType = '', intMasterId = 180172
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '5D_IN_TR', strType = '', intMasterId = 180173
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '5D_IN_TR', strType = '', intMasterId = 180174
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '5D_IN_TR', strType = '', intMasterId = 180175
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '5D_IN_TR', strType = '', intMasterId = 180176
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '5D_IN_TR', strType = '', intMasterId = 180177
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '5D_IN_TR', strType = '', intMasterId = 180178
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '5D_IN_TR', strType = '', intMasterId = 180179
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '5D_IN_TR', strType = '', intMasterId = 180180
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '5D_IN_TR', strType = '', intMasterId = 180181
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '5D_IL_TR', strType = '', intMasterId = 180182
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '5D_IL_TR', strType = '', intMasterId = 180183
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '5D_IL_TR', strType = '', intMasterId = 180184
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '5D_IL_TR', strType = '', intMasterId = 180185
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '5D_IL_TR', strType = '', intMasterId = 180186
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '5D_IL_TR', strType = '', intMasterId = 180187
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '5D_IL_TR', strType = '', intMasterId = 180188
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '5D_IL_TR', strType = '', intMasterId = 180189
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '5D_IL_TR', strType = '', intMasterId = 180190
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '5D_IL_TR', strType = '', intMasterId = 180191
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '5D_IL_TR', strType = '', intMasterId = 180192
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '5D_IL_TR', strType = '', intMasterId = 180193
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '5D_IL_TR', strType = '', intMasterId = 180194
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', intMasterId = 180195
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', intMasterId = 180196
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', intMasterId = 180197
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', intMasterId = 180198
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', intMasterId = 180199
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', intMasterId = 180200
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', intMasterId = 180201
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', intMasterId = 180202
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', intMasterId = 180203
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', intMasterId = 180204
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', intMasterId = 180205
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', intMasterId = 180206
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', intMasterId = 180207
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', intMasterId = 180208
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', intMasterId = 180209
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', intMasterId = 180210
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', intMasterId = 180211
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', intMasterId = 180212
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', intMasterId = 180213
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', intMasterId = 180214
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', intMasterId = 180215
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', intMasterId = 180216
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', intMasterId = 180217
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', intMasterId = 180218
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', intMasterId = 180219
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', intMasterId = 180220
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', intMasterId = 180221
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', intMasterId = 180222
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', intMasterId = 180223
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', intMasterId = 180224
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', intMasterId = 180225
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', intMasterId = 180226
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', intMasterId = 180227
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', intMasterId = 180228
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', intMasterId = 180229
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', intMasterId = 180230
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', intMasterId = 180231
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', intMasterId = 180232
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', intMasterId = 180233
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', intMasterId = 180234
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', intMasterId = 180235
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', intMasterId = 180236
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', intMasterId = 180237
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', intMasterId = 180238
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', intMasterId = 180239
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', intMasterId = 180240
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', intMasterId = 180241
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', intMasterId = 180242
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', intMasterId = 180243
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', intMasterId = 180244
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', intMasterId = 180245
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', intMasterId = 180246
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', intMasterId = 180247
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', intMasterId = 180248
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', intMasterId = 180249
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', intMasterId = 180250
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', intMasterId = 180251
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', intMasterId = 180252
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', intMasterId = 180253
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', intMasterId = 180254
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', intMasterId = 180255
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', intMasterId = 180256
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', intMasterId = 180257
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', intMasterId = 180258
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', intMasterId = 180259
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', intMasterId = 180260
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', intMasterId = 180261
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', intMasterId = 180262
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', intMasterId = 180263
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', intMasterId = 180264
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', intMasterId = 180265
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', intMasterId = 180266
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', intMasterId = 180267
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', intMasterId = 180268
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', intMasterId = 180269
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', intMasterId = 180270
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', intMasterId = 180271
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', intMasterId = 180272
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', intMasterId = 180273
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', intMasterId = 180274
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', intMasterId = 180275
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', intMasterId = 180276
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', intMasterId = 180277
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', intMasterId = 180278
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', intMasterId = 180279
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', intMasterId = 180280
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', intMasterId = 180281
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', intMasterId = 180282
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', intMasterId = 180283
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', intMasterId = 180284
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', intMasterId = 180285
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', intMasterId = 180286
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', intMasterId = 180287
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', intMasterId = 180288
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', intMasterId = 180289
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', intMasterId = 180290
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', intMasterId = 180291
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', intMasterId = 180292
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', intMasterId = 180293
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', intMasterId = 180294
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', intMasterId = 180295
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', intMasterId = 180296
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', intMasterId = 180297
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', intMasterId = 180298

	
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', intMasterId = 180299
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', intMasterId = 180300
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', intMasterId = 180301
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', intMasterId = 180302
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', intMasterId = 180303
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', intMasterId = 180304
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', intMasterId = 180305
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', intMasterId = 180306
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', intMasterId = 180307
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', intMasterId = 180308
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', intMasterId = 180309
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', intMasterId = 180310
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', intMasterId = 180311
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', intMasterId = 180312
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', intMasterId = 180313
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', intMasterId = 180314
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', intMasterId = 180315
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', intMasterId = 180316
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', intMasterId = 180317
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', intMasterId = 180318
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', intMasterId = 180319
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', intMasterId = 180320
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', intMasterId = 180321
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', intMasterId = 180322
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', intMasterId = 180323
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', intMasterId = 180324
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', intMasterId = 180325
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', intMasterId = 180326
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', intMasterId = 180327
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', intMasterId = 180328
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', intMasterId = 180329
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', intMasterId = 180330
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', intMasterId = 180331
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', intMasterId = 180332
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', intMasterId = 180333
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', intMasterId = 180334
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', intMasterId = 180335
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', intMasterId = 180336
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', intMasterId = 180337
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '5D_OH_TR', strType = '', intMasterId = 180338
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '5D_OH_TR', strType = '', intMasterId = 180339
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '5D_OH_TR', strType = '', intMasterId = 180340
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '5D_OH_TR', strType = '', intMasterId = 180341
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '5D_OH_TR', strType = '', intMasterId = 180342
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '5D_OH_TR', strType = '', intMasterId = 180343
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '5D_OH_TR', strType = '', intMasterId = 180344
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '5D_OH_TR', strType = '', intMasterId = 180345
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '5D_OH_TR', strType = '', intMasterId = 180346
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '5D_OH_TR', strType = '', intMasterId = 180347
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '5D_OH_TR', strType = '', intMasterId = 180348
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '5D_OH_TR', strType = '', intMasterId = 180349
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '5D_OH_TR', strType = '', intMasterId = 180350
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '5D_VA_TR', strType = '', intMasterId = 180351
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '5D_VA_TR', strType = '', intMasterId = 180352
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '5D_VA_TR', strType = '', intMasterId = 180353
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '5D_VA_TR', strType = '', intMasterId = 180354
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '5D_VA_TR', strType = '', intMasterId = 180355
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '5D_VA_TR', strType = '', intMasterId = 180356
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '5D_VA_TR', strType = '', intMasterId = 180357
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '5D_VA_TR', strType = '', intMasterId = 180358
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '5D_VA_TR', strType = '', intMasterId = 180359
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '5D_VA_TR', strType = '', intMasterId = 180360
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '5D_VA_TR', strType = '', intMasterId = 180361
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '5D_VA_TR', strType = '', intMasterId = 180362
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '5D_VA_TR', strType = '', intMasterId = 180363
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '5D_WV_TR', strType = '', intMasterId = 180364
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '5D_WV_TR', strType = '', intMasterId = 180365
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '5D_WV_TR', strType = '', intMasterId = 180366
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '5D_WV_TR', strType = '', intMasterId = 180367
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '5D_WV_TR', strType = '', intMasterId = 180368
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '5D_WV_TR', strType = '', intMasterId = 180369
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '5D_WV_TR', strType = '', intMasterId = 180370
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '5D_WV_TR', strType = '', intMasterId = 180371
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '5D_WV_TR', strType = '', intMasterId = 180372
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '5D_WV_TR', strType = '', intMasterId = 180373
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '5D_WV_TR', strType = '', intMasterId = 180374
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '5D_WV_TR', strType = '', intMasterId = 180375
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '5D_WV_TR', strType = '', intMasterId = 180376
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', intMasterId = 180377
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', intMasterId = 180378
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', intMasterId = 180379
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', intMasterId = 180380
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', intMasterId = 180381
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', intMasterId = 180382
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', intMasterId = 180383
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', intMasterId = 180384
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', intMasterId = 180385
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', intMasterId = 180386
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', intMasterId = 180387
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', intMasterId = 180388
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', intMasterId = 180389
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', intMasterId = 180390
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', intMasterId = 180391
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', intMasterId = 180392
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', intMasterId = 180393
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', intMasterId = 180394
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', intMasterId = 180395
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', intMasterId = 180396
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', intMasterId = 180397
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', intMasterId = 180398
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', intMasterId = 180399
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', intMasterId = 180400
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', intMasterId = 180401
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', intMasterId = 180402
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', intMasterId = 180403
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', intMasterId = 180404
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', intMasterId = 180405
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', intMasterId = 180406
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', intMasterId = 180407
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', intMasterId = 180408
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', intMasterId = 180409
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', intMasterId = 180410
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', intMasterId = 180411
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', intMasterId = 180412
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', intMasterId = 180413
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', intMasterId = 180414
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', intMasterId = 180415
	
	
	INSERT INTO @ValidOriginStates(
		intValidOriginStateId
		, strFormCode
		, strScheduleCode
		, strType
		, strState
		, strStatus
		, intMasterId
	)
	SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '10I', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171101
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '2', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171079
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '2A', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171080
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '2B', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171081
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', strState = 'IL', strStatus = 'Include', intMasterId = 171086
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', strState = 'IN', strStatus = 'Include', intMasterId = 171087
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', strState = 'TN', strStatus = 'Include', intMasterId = 171088
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '6', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171099
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171092
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171093
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171094
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '8', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171100
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '10A', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171105
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '10G', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171106
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '10I', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171107
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '10J', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171108
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '10Y', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171109
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '2', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171083
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '2A', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171084
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '2B', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171085
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', strState = 'IL', strStatus = 'Include', intMasterId = 171089
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', strState = 'IN', strStatus = 'Include', intMasterId = 171090
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', strState = 'TN', strStatus = 'Include', intMasterId = 171091
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '6', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171102
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171095
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171096
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171097
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '8', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171103
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '9', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171104
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', strState = 'OH', strStatus = 'Include', intMasterId = 171110
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', strState = 'VA', strStatus = 'Include', intMasterId = 171111
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', strState = 'WV', strStatus = 'Include', intMasterId = 171112
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171113
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171114
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171115
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', strState = 'OH', strStatus = 'Include', intMasterId = 171116
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', strState = 'VA', strStatus = 'Include', intMasterId = 171117
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', strState = 'WV', strStatus = 'Include', intMasterId = 171118
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171119
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171120
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171121

	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '', strState = 'KY', strStatus = 'Include',	intMasterId = 171122
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '', strState = 'KY', strStatus = 'Include',	intMasterId = 171123
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '', strState = 'KY', strStatus = 'Include',	intMasterId = 171124
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '', strState = 'KY', strStatus = 'Include',	intMasterId = 171125
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '', strState = 'KY', strStatus = 'Include',	intMasterId = 171126
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '2_TR', strType = '', strState = 'KY', strStatus = 'Include',		intMasterId = 171127
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '', strState = 'KY', strStatus = 'Include',	intMasterId = 171128
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '', strState = 'KY', strStatus = 'Include',	intMasterId = 171129
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '', strState = 'IL', strStatus = 'Include',	intMasterId = 171130
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '', strState = 'IN', strStatus = 'Include',	intMasterId = 171131
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '', strState = 'TN', strStatus = 'Include',	intMasterId = 171132
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '6_TR', strType = '', strState = 'KY', strStatus = 'Include',		intMasterId = 171133
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '', strState = 'KY', strStatus = 'Include',	intMasterId = 171134
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '', strState = 'KY', strStatus = 'Include',	intMasterId = 171135
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '', strState = 'KY', strStatus = 'Include',	intMasterId = 171136
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '8_TR', strType = '', strState = 'KY', strStatus = 'Include',		intMasterId = 171137
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '9_TR', strType = '', strState = 'KY', strStatus = 'Include',		intMasterId = 171138

	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '', strState = 'OH', strStatus = 'Include',		intMasterId = 171139
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '', strState = 'VA', strStatus = 'Include',		intMasterId = 171140
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '', strState = 'WV', strStatus = 'Include',		intMasterId = 171141
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '', strState = 'KY', strStatus = 'Include',		intMasterId = 171142
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '', strState = 'KY', strStatus = 'Include',		intMasterId = 171143
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '', strState = 'KY', strStatus = 'Include',		intMasterId = 171144

	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171162
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171145
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171146
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171147
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', strState = 'IL', strStatus = 'Include', intMasterId = 171148
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', strState = 'IN', strStatus = 'Include', intMasterId = 171149
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', strState = 'TN', strStatus = 'Include', intMasterId = 171150
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '6_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171151
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171152
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171153
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171154
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171155
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', strState = 'OH', strStatus = 'Include', intMasterId = 171156
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', strState = 'VA', strStatus = 'Include', intMasterId = 171157
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', strState = 'WV', strStatus = 'Include', intMasterId = 171158
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171159
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171160
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171161


	INSERT INTO @ValidDestinationStates(
		intValidDestinationStateId
		, strFormCode
		, strScheduleCode
		, strType
		, strState
		, strStatus
		, intMasterId
	)
	SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '1', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171041
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '10I', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171064
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '2', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171042
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '2A', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171043
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '2B', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171044
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171049
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171050
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171051
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '6', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171062
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', strState = 'IL', strStatus = 'Include', intMasterId = 171055
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', strState = 'IN', strStatus = 'Include', intMasterId = 171056
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', strState = 'TN', strStatus = 'Include', intMasterId = 171057
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '8', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171063
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '1', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171045
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '10A', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171068
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '10G', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171069
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '10I', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171070
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '10J', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171071
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '10Y', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171072
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '2', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171046
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '2A', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171047
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '2B', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171048
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171052
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171053
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171054
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '6', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171065
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', strState = 'IL', strStatus = 'Include', intMasterId = 171058
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', strState = 'IN', strStatus = 'Include', intMasterId = 171059
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', strState = 'TN', strStatus = 'Include', intMasterId = 171060
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '8', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171066
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '9', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171067
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171073
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171074
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171075
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', strState = 'OH', strStatus = 'Include', intMasterId = 171076
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', strState = 'VA', strStatus = 'Include', intMasterId = 171077
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', strState = 'WV', strStatus = 'Include', intMasterId = 171078
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171079
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171080
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171081
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', strState = 'OH', strStatus = 'Include', intMasterId = 171082
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', strState = 'VA', strStatus = 'Include', intMasterId = 171083
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', strState = 'WV', strStatus = 'Include', intMasterId = 171084

	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '1_TR', strType = '', strState = 'KY', strStatus = 'Include',   intMasterId = 171085
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171086
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171087
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171088
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171089
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171090
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '2_TR', strType = '', strState = 'KY', strStatus = 'Include',	intMasterId = 171091
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '', strState = 'KY', strStatus = 'Include',	intMasterId = 171092
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '', strState = 'KY', strStatus = 'Include',	intMasterId = 171093
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171094
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171095
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171096
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '6_TR', strType = '', strState = 'KY', strStatus = 'Include',	intMasterId = 171097
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '', strState = 'IL', strStatus = 'Include', intMasterId = 171098
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '', strState = 'IN', strStatus = 'Include', intMasterId = 171099
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '', strState = 'TN', strStatus = 'Include', intMasterId = 171100
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '8_TR', strType = '', strState = 'KY', strStatus = 'Include',	intMasterId = 171101
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '9_TR', strType = '', strState = 'KY', strStatus = 'Include',	intMasterId = 171102

	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171103
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171104
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171105
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '', strState = 'OH', strStatus = 'Include', intMasterId = 171106
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '', strState = 'VA', strStatus = 'Include', intMasterId = 171107
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '', strState = 'WV', strStatus = 'Include', intMasterId = 171108

	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171109
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171110
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171111
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171112
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171113
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171114
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171115
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171116
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '6_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171117
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', strState = 'IL', strStatus = 'Include', intMasterId = 171118
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', strState = 'IN', strStatus = 'Include', intMasterId = 171119
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', strState = 'TN', strStatus = 'Include', intMasterId = 171120
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171121
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171122
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171123
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171124
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', strState = 'OH', strStatus = 'Include', intMasterId = 171125
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', strState = 'VA', strStatus = 'Include', intMasterId = 171126
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', strState = 'WV', strStatus = 'Include', intMasterId = 171127

	EXEC uspTFUpgradeValidProductCodes @TaxAuthorityCode = @TaxAuthorityCode, @ValidProductCodes = @ValidProductCodes
	EXEC uspTFUpgradeValidOriginStates @TaxAuthorityCode = @TaxAuthorityCode, @ValidOriginStates = @ValidOriginStates
	EXEC uspTFUpgradeValidDestinationStates @TaxAuthorityCode = @TaxAuthorityCode, @ValidDestinationStates = @ValidDestinationStates


-- Reporting Component - Configuration
/* Generate script for Reporting Component - Configurations. Specify Tax Authority Id to filter out specific Reporting Component - Configurations only.
select 'UNION ALL SELECT intReportTemplateId = ' + CAST(0 AS NVARCHAR(10))
	+ CASE WHEN RC.strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + RC.strFormCode + ''''  END
	+ CASE WHEN RC.strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + RC.strScheduleCode + ''''  END
	+ CASE WHEN RC.strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + RC.strType + '''' END
	+ CASE WHEN strTemplateItemId IS NULL THEN ', strTemplateItemId = NULL' ELSE ', strTemplateItemId = ''' + strTemplateItemId + ''''  END
	+ CASE WHEN strReportSection IS NULL THEN ', strReportSection = NULL' ELSE ', strReportSection = ''' + strReportSection + ''''  END
	+ CASE WHEN intReportItemSequence IS NULL THEN ', intReportItemSequence = NULL' ELSE ', intReportItemSequence = ''' + CAST(intReportItemSequence AS NVARCHAR(10)) + ''''  END
	+ CASE WHEN intTemplateItemNumber IS NULL THEN ', intTemplateItemNumber = NULL' ELSE ', intTemplateItemNumber = ''' + CAST(intTemplateItemNumber AS NVARCHAR(10)) + ''''  END
	+ CASE WHEN strDescription IS NULL THEN ', strDescription = NULL' ELSE ', strDescription = ''' + REPLACE(strDescription, '''', '''''') + ''''  END
	+ CASE WHEN Config.strScheduleCode IS NULL THEN ', strScheduleList = NULL' ELSE ', strScheduleList = ''' + Config.strScheduleCode + ''''  END
	+ CASE WHEN strConfiguration IS NULL THEN ', strConfiguration = NULL' ELSE ', strConfiguration = ''' + strConfiguration + ''''  END
	+ CASE WHEN ysnConfiguration IS NULL THEN ', ysnConfiguration = NULL' ELSE ', ysnConfiguration = ''' + CAST(ysnConfiguration AS NVARCHAR(5)) + ''''  END
	+ CASE WHEN ysnUserDefinedValue IS NULL THEN ', ysnUserDefinedValue = NULL' ELSE ', ysnUserDefinedValue = ''' + CAST(ysnUserDefinedValue AS NVARCHAR(5)) + ''''  END
	+ CASE WHEN strLastIndexOf IS NULL THEN ', strLastIndexOf = NULL' ELSE ', strLastIndexOf = ''' + strLastIndexOf + ''''  END
	+ CASE WHEN strSegment IS NULL THEN ', strSegment = NULL' ELSE ', strSegment = ''' + strSegment + ''''  END
	+ CASE WHEN intConfigurationSequence IS NULL THEN ', intConfigurationSequence = NULL' ELSE ', intConfigurationSequence = ''' + CAST(intConfigurationSequence AS NVARCHAR(10)) + ''''  END
	+ CASE WHEN ysnOutputDesigner IS NULL THEN ', ysnOutputDesigner = NULL' ELSE ', ysnOutputDesigner = ' + CAST(ysnOutputDesigner AS NVARCHAR(5)) + ''  END
	+ CASE WHEN strInputType IS NULL THEN ', strInputType = NULL' ELSE ', strInputType = ''' + strInputType + ''''  END
--	+ ', intMasterId = ' + CAST((CASE WHEN ISNULL(Config.intMasterId, '') = '' THEN intReportingComponentConfigurationId ELSE Config.intMasterId END) AS NVARCHAR(20)) -- Old Format
	+ ', intMasterId = ' + CASE WHEN Config.intMasterId IS NULL THEN CAST(@TaxAuthorityId AS NVARCHAR(20)) + CAST(intReportingComponentConfigurationId AS NVARCHAR(20)) ELSE CAST(Config.intMasterId AS NVARCHAR(20)) END -- First 2 digit for TaxAuthorityCodeID
from tblTFReportingComponentConfiguration Config
left join tblTFReportingComponent RC ON RC.intReportingComponentId = Config.intReportingComponentId
WHERE RC.intTaxAuthorityId = @TaxAuthorityId
*/
	DECLARE @ReportingComponentConfigurations AS TFReportingComponentConfigurations

	INSERT INTO @ReportingComponentConfigurations(
		intReportTemplateId
		, strFormCode
		, strScheduleCode
		, strType
		, strTemplateItemId
		, strReportSection
		, intReportItemSequence
		, intTemplateItemNumber
		, strDescription
		, strScheduleList
		, strConfiguration
		, ysnConfiguration
		, ysnUserDefinedValue
		, strLastIndexOf
		, strSegment
		, intSort
		, ysnOutputDesigner
		, strInputType
		, intMasterId
	)
	SELECT intReportTemplateId = 0, strFormCode = '72A089', strScheduleCode = '72A089', strType = '', strTemplateItemId = 'KYGas-Ln9', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '1', strDescription = 'Line 9 Gals lost through accountable losses', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '1', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 171159
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A089', strScheduleCode = '72A089', strType = '', strTemplateItemId = 'KYGas-Ln12', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '2', strDescription = 'Line 12 Tax rate', strScheduleList = NULL, strConfiguration = '0.2460', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '2', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 171160
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A089', strScheduleCode = '72A089', strType = '', strTemplateItemId = 'KYGas-Ln13a', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '3', strDescription = 'Line 13.a Tax rate adjustment - rate', strScheduleList = NULL, strConfiguration = '0.0000', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '3', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 171161
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A089', strScheduleCode = '72A089', strType = '', strTemplateItemId = 'KYGas-Ln13b', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '4', strDescription = 'Line 13.b Tax rate adjustment - gallons', strScheduleList = NULL, strConfiguration = '0', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '4', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 171162
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A089', strScheduleCode = '72A089', strType = '', strTemplateItemId = 'KYGas-Ln16', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '5', strDescription = 'Line 16 Tax rate for non-highway dealer credit', strScheduleList = NULL, strConfiguration = '0.2460', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '5', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 171163
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A089', strScheduleCode = '72A089', strType = '', strTemplateItemId = 'KYGas-Ln18', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '6', strDescription = 'Line 18 Dealer compensation allowance rate', strScheduleList = NULL, strConfiguration = '0.0225', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '6', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 171164
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A089', strScheduleCode = '72A089', strType = '', strTemplateItemId = 'KYGas-Ln20', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '7', strDescription = 'Line 20 Credits', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '7', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 171165
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A089', strScheduleCode = '72A089', strType = '', strTemplateItemId = 'KYGas-StaGal', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '8', strDescription = 'Statistical gallons - fuel grade alcohol', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '8', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 171166
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A138', strScheduleCode = '72A138', strType = '', strTemplateItemId = 'KYSF-Ln8', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '1', strDescription = 'Line 8 Gals lost through accountable losses', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '1', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 171167
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A138', strScheduleCode = '72A138', strType = '', strTemplateItemId = 'KYSF-Ln11', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '2', strDescription = 'Line 11 Special Fuel used by licensed dealer for non-highway purposes', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '2', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 171168
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A138', strScheduleCode = '72A138', strType = '', strTemplateItemId = 'KYSF-Ln14', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '3', strDescription = 'Line 14 Tax rate', strScheduleList = NULL, strConfiguration = '0.2160', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '3', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 171169
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A138', strScheduleCode = '72A138', strType = '', strTemplateItemId = 'KYSF-Ln15a', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '4', strDescription = 'Line 15.a Tax rate adjustment - rate', strScheduleList = NULL, strConfiguration = '0.0000', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '4', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 171170
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A138', strScheduleCode = '72A138', strType = '', strTemplateItemId = 'KYSF-Ln15b', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '5', strDescription = 'Line 15.b Tax rate adjustment - gallons', strScheduleList = NULL, strConfiguration = '0', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '5', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 171171
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A138', strScheduleCode = '72A138', strType = '', strTemplateItemId = 'KYSF-Ln17', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '6', strDescription = 'Line 17 Tax rate for non-highway dealer credit', strScheduleList = NULL, strConfiguration = '0.2160', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '6', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 171172
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A138', strScheduleCode = '72A138', strType = '', strTemplateItemId = 'KYSF-Ln20', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '7', strDescription = 'Line 20 Dealer compensation allowance rate', strScheduleList = NULL, strConfiguration = '0.0225', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '7', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 171173
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A138', strScheduleCode = '72A138', strType = '', strTemplateItemId = 'KYSF-Ln22', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '8', strDescription = 'Line 22 Credits', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '8', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 171174
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-ISA01', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '1', strDescription = 'ISA01 - Authorization Information Qualifier', strScheduleList = NULL, strConfiguration = '3', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '1', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171220
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-ISA03', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '2', strDescription = 'ISA03 - Security Information Qualifier', strScheduleList = NULL, strConfiguration = '0', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '2', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171221
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-ISA05', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '3', strDescription = 'ISA05 - Interchange ID Qualifier', strScheduleList = NULL, strConfiguration = '32', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '3', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171222
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-ISA07', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '4', strDescription = 'ISA07 - Interchange ID Qualifier', strScheduleList = NULL, strConfiguration = '1', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '4', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171223
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-ISA08', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '5', strDescription = 'ISA08 - Interchange Receiver ID', strScheduleList = NULL, strConfiguration = '614553816T     ', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '5', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171224
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-ISA11', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '6', strDescription = 'ISA11 - Repetition Separator', strScheduleList = NULL, strConfiguration = '|', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '6', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171225
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-ISA12', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '7', strDescription = 'ISA12 - Interchange Control Version Number', strScheduleList = NULL, strConfiguration = '00403', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '7', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171226
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-ISA13', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '8', strDescription = 'ISA13 - Interchange Control Number (for next transmission)', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '8', ysnOutputDesigner = 0, strInputType = 'integer', intMasterId = 171227
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-ISA14', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '9', strDescription = 'ISA14 - Acknowledgement Requested', strScheduleList = NULL, strConfiguration = '0', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '9', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171228
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-ISA15', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '10', strDescription = 'ISA15 - Usage Indicator (P = Production; T = Test)', strScheduleList = NULL, strConfiguration = 'T', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '10', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171229
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-ISA16', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '11', strDescription = 'ISA16 - Component Sub-element Separator', strScheduleList = NULL, strConfiguration = '^', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '11', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171230
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-GS01', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '12', strDescription = 'GS01 - Functional Identifier Code', strScheduleList = NULL, strConfiguration = 'TF', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '12', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171231
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-GS02', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '13', strDescription = 'GS02 - Application Sender''s Code', strScheduleList = NULL, strConfiguration = 'KY606502', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '13', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171232
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-GS03', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '14', strDescription = 'GS03 - Receiver''s Code', strScheduleList = NULL, strConfiguration = '614553816T', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '14', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171233
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-GS06', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '15', strDescription = 'GS06 - Group Control Number (for next transmission)', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '15', ysnOutputDesigner = 0, strInputType = 'integer', intMasterId = 171234
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-GS07', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '16', strDescription = 'GS07 - Responsible Agency Code', strScheduleList = NULL, strConfiguration = 'X', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '16', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171235
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-GS08', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '17', strDescription = 'GS08 - Version/Release/Industry ID Code', strScheduleList = NULL, strConfiguration = '004030', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '17', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171236
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-ST01', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '18', strDescription = 'ST01 - Transaction Set Code', strScheduleList = NULL, strConfiguration = '813', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '18', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171237
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-ST02', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '19', strDescription = 'ST02 - Transaction Set Control Number (for next transmission)', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '19', ysnOutputDesigner = 0, strInputType = 'integer', intMasterId = 171238
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-ST03', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '20', strDescription = 'ST03 - Implementation Convention Reference', strScheduleList = NULL, strConfiguration = '1', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '20', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171239
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-BTI01', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '21', strDescription = 'BTI01 - Reference Number Qualifier', strScheduleList = NULL, strConfiguration = 'T6', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '21', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171240
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-BTI02', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '22', strDescription = 'BTI02 - Reference Number', strScheduleList = NULL, strConfiguration = '50', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '22', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171241
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-BTI03', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '23', strDescription = 'BTI03 - ID Code Qualifier', strScheduleList = NULL, strConfiguration = '47', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '23', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171242
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-BTI04', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '24', strDescription = 'BTI04 - ID Code', strScheduleList = NULL, strConfiguration = 'KY', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '24', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171243
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-BTI06', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '25', strDescription = 'BTI06 - Name Control ID (4-char business name)', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '25', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171244
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-BTI07', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '26', strDescription = 'BTI07 - ID Code Qualifier', strScheduleList = NULL, strConfiguration = '24', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '26', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171245
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-BTI13', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '27', strDescription = 'BTI13 - Transaction Set Purpose Code', strScheduleList = NULL, strConfiguration = '0', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '27', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171246
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-BTI14', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '28', strDescription = 'BTI14 - Transaction Type Code', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '28', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171247
	
	--MFT-1704
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-LicNumGD', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '29', strDescription = 'Gasoline Return License Number (GD999999999)', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '29', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171248
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', strTemplateItemId = 'KYEDI-LicNumSF', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '30', strDescription = 'Special Fuels Retrun License Number (SF999999999)', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '30', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171249


	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-ISA01', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '1', strDescription = 'ISA01 - Authorization Information Qualifier', strScheduleList = NULL, strConfiguration = '3', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '1', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171251
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-ISA03', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '2', strDescription = 'ISA03 - Security Information Qualifier', strScheduleList = NULL, strConfiguration = '0', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '2', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171252
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-ISA05', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '3', strDescription = 'ISA05 - Interchange ID Qualifier', strScheduleList = NULL, strConfiguration = '32', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '3', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171253
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-ISA07', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '4', strDescription = 'ISA07 - Interchange ID Qualifier', strScheduleList = NULL, strConfiguration = '1', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '4', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171254
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-ISA08', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '5', strDescription = 'ISA08 - Interchange Receiver ID', strScheduleList = NULL, strConfiguration = '614553816T     ', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '5', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171255
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-ISA11', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '6', strDescription = 'ISA11 - Repetition Separator', strScheduleList = NULL, strConfiguration = '|', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '6', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171256
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-ISA12', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '7', strDescription = 'ISA12 - Interchange Control Version Number', strScheduleList = NULL, strConfiguration = '00403', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '7', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171257
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-ISA13', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '8', strDescription = 'ISA13 - Interchange Control Number (for next transmission)', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '8', ysnOutputDesigner = 0, strInputType = 'integer', intMasterId = 171258
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-ISA14', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '9', strDescription = 'ISA14 - Acknowledgement Requested', strScheduleList = NULL, strConfiguration = '0', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '9', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171259
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-ISA15', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '10', strDescription = 'ISA15 - Usage Indicator (P = Production; T = Test)', strScheduleList = NULL, strConfiguration = 'T', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '10', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171260
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-ISA16', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '11', strDescription = 'ISA16 - Component Sub-element Separator', strScheduleList = NULL, strConfiguration = '^', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '11', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171261
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-GS01', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '12', strDescription = 'GS01 - Functional Identifier Code', strScheduleList = NULL, strConfiguration = 'TF', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '12', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171262
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-GS02', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '13', strDescription = 'GS02 - Application Sender''s Code', strScheduleList = NULL, strConfiguration = 'KY606502', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '13', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171263
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-GS03', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '14', strDescription = 'GS03 - Receiver''s Code', strScheduleList = NULL, strConfiguration = '614553816T', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '14', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171264
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-GS06', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '15', strDescription = 'GS06 - Group Control Number (for next transmission)', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '15', ysnOutputDesigner = 0, strInputType = 'integer', intMasterId = 171265
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-GS07', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '16', strDescription = 'GS07 - Responsible Agency Code', strScheduleList = NULL, strConfiguration = 'X', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '16', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171266
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-GS08', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '17', strDescription = 'GS08 - Version/Release/Industry ID Code', strScheduleList = NULL, strConfiguration = '004030', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '17', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171267
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-ST01', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '18', strDescription = 'ST01 - Transaction Set Code', strScheduleList = NULL, strConfiguration = '813', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '18', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171268
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-ST02', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '19', strDescription = 'ST02 - Transaction Set Control Number (for next transmission)', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '19', ysnOutputDesigner = 0, strInputType = 'integer', intMasterId = 171269
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-ST03', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '20', strDescription = 'ST03 - Implementation Convention Reference', strScheduleList = NULL, strConfiguration = '1', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '20', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171270
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-BTI01', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '21', strDescription = 'BTI01 - Reference Number Qualifier', strScheduleList = NULL, strConfiguration = 'T6', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '21', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171271
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-BTI02', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '22', strDescription = 'BTI02 - Reference Number', strScheduleList = NULL, strConfiguration = '50', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '22', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171272
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-BTI03', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '23', strDescription = 'BTI03 - ID Code Qualifier', strScheduleList = NULL, strConfiguration = '47', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '23', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171273
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-BTI04', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '24', strDescription = 'BTI04 - ID Code', strScheduleList = NULL, strConfiguration = 'KY', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '24', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171274
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-BTI06', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '25', strDescription = 'BTI06 - Name Control ID (4-char business name)', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '25', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171275
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-BTI07', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '26', strDescription = 'BTI07 - ID Code Qualifier', strScheduleList = NULL, strConfiguration = '24', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '26', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171276
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-BTI13', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '27', strDescription = 'BTI13 - Transaction Set Purpose Code', strScheduleList = NULL, strConfiguration = '0', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '27', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171277
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-BTI14', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '28', strDescription = 'BTI14 - Transaction Type Code', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '28', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171278									
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-LicNumTR', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '31', strDescription = 'Transporters Return License Number (TR999999999)', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '31', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171279
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', strTemplateItemId = 'KYTREDI-AcntId', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '31', strDescription = 'Account ID', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '32', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 171280


	EXEC uspTFUpgradeReportingComponentConfigurations @TaxAuthorityCode = @TaxAuthorityCode, @ReportingComponentConfigurations = @ReportingComponentConfigurations


-- Reporting Component - Output Designer
/* Generate script for Reporting Component - Output Designer. Specify Tax Authority Id to filter out specific Reporting Component - Output Designer only.
select 'UNION ALL SELECT intScheduleColumnId = ' + CAST(ROW_NUMBER() OVER(ORDER BY RCF.intMasterId) AS NVARCHAR(10))
	+ CASE WHEN strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END
	+ CASE WHEN strColumn IS NULL THEN ', strColumn = NULL' ELSE ', strColumn = ''' + strColumn + '''' END
	+ CASE WHEN strCaption IS NULL THEN ', strCaption = NULL' ELSE ', strCaption = ''' + strCaption + '''' END
	+ CASE WHEN strFormat IS NULL THEN ', strFormat = NULL' ELSE ', strFormat = ''' + strFormat + '''' END
	+ CASE WHEN strFooter IS NULL THEN ', strFooter = NULL' ELSE ', strFooter = ''' + strFooter + '''' END
	+ CASE WHEN intWidth IS NULL THEN ', intWidth = NULL' ELSE ', intWidth = ' + CAST(intWidth AS NVARCHAR(10)) END
	+ CASE WHEN ysnFromConfiguration IS NULL THEN ', ysnFromConfiguration = NULL' ELSE ', ysnFromConfiguration = ' + CAST(ysnFromConfiguration AS NVARCHAR(5)) + ''  END
--	+ ', intMasterId = ' + CAST((CASE WHEN ISNULL(RCF.intMasterId, '') = '' THEN intReportingComponentFieldId ELSE RCF.intMasterId END) AS NVARCHAR(20)) -- Old Format
	+ ', intMasterId = ' + CASE WHEN RCF.intMasterId IS NULL THEN CAST(@TaxAuthorityId AS NVARCHAR(20)) + CAST(intReportingComponentFieldId AS NVARCHAR(20)) ELSE CAST(RCF.intMasterId AS NVARCHAR(20)) END -- First 2 digit for TaxAuthorityCodeID
from tblTFReportingComponentField RCF
left join tblTFReportingComponent RC on RC.intReportingComponentId = RCF.intReportingComponentId
where RC.intTaxAuthorityId = @TaxAuthorityId ORDER BY RCF.intMasterId 
*/
	DECLARE @ReportingComponentOutputDesigners AS TFReportingComponentOutputDesigners

	INSERT INTO @ReportingComponentOutputDesigners(
		intScheduleColumnId
		, strFormCode
		, strScheduleCode
		, strType
		, strColumn
		, strCaption
		, strFormat
		, strFooter
		, intWidth
		, ysnFromConfiguration
		, intMasterId
	)
	SELECT intScheduleColumnId = 1, strFormCode = '72A089', strScheduleCode = '1', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726025
	UNION ALL SELECT intScheduleColumnId = 2, strFormCode = '72A089', strScheduleCode = '1', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726026
	UNION ALL SELECT intScheduleColumnId = 3, strFormCode = '72A089', strScheduleCode = '1', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726027
	UNION ALL SELECT intScheduleColumnId = 4, strFormCode = '72A089', strScheduleCode = '1', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726028
	UNION ALL SELECT intScheduleColumnId = 5, strFormCode = '72A089', strScheduleCode = '1', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726029
	UNION ALL SELECT intScheduleColumnId = 6, strFormCode = '72A089', strScheduleCode = '1', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726030
	UNION ALL SELECT intScheduleColumnId = 7, strFormCode = '72A089', strScheduleCode = '1', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726031
	UNION ALL SELECT intScheduleColumnId = 8, strFormCode = '72A089', strScheduleCode = '1', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726032
	UNION ALL SELECT intScheduleColumnId = 9, strFormCode = '72A089', strScheduleCode = '1', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726033
	UNION ALL SELECT intScheduleColumnId = 10, strFormCode = '72A089', strScheduleCode = '1', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726034
	UNION ALL SELECT intScheduleColumnId = 11, strFormCode = '72A089', strScheduleCode = '1', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726035
	UNION ALL SELECT intScheduleColumnId = 12, strFormCode = '72A089', strScheduleCode = '1', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726036
	UNION ALL SELECT intScheduleColumnId = 13, strFormCode = '72A089', strScheduleCode = '1', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726037
	UNION ALL SELECT intScheduleColumnId = 14, strFormCode = '72A089', strScheduleCode = '2', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726038
	UNION ALL SELECT intScheduleColumnId = 15, strFormCode = '72A089', strScheduleCode = '2', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726039
	UNION ALL SELECT intScheduleColumnId = 16, strFormCode = '72A089', strScheduleCode = '2', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726040
	UNION ALL SELECT intScheduleColumnId = 17, strFormCode = '72A089', strScheduleCode = '2', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726041
	UNION ALL SELECT intScheduleColumnId = 18, strFormCode = '72A089', strScheduleCode = '2', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726042
	UNION ALL SELECT intScheduleColumnId = 19, strFormCode = '72A089', strScheduleCode = '2', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726043
	UNION ALL SELECT intScheduleColumnId = 20, strFormCode = '72A089', strScheduleCode = '2', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726044
	UNION ALL SELECT intScheduleColumnId = 21, strFormCode = '72A089', strScheduleCode = '2', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726045
	UNION ALL SELECT intScheduleColumnId = 22, strFormCode = '72A089', strScheduleCode = '2', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726046
	UNION ALL SELECT intScheduleColumnId = 23, strFormCode = '72A089', strScheduleCode = '2', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726047
	UNION ALL SELECT intScheduleColumnId = 24, strFormCode = '72A089', strScheduleCode = '2', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726048
	UNION ALL SELECT intScheduleColumnId = 25, strFormCode = '72A089', strScheduleCode = '2', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726049
	UNION ALL SELECT intScheduleColumnId = 26, strFormCode = '72A089', strScheduleCode = '2', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726050
	UNION ALL SELECT intScheduleColumnId = 27, strFormCode = '72A089', strScheduleCode = '2A', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726051
	UNION ALL SELECT intScheduleColumnId = 28, strFormCode = '72A089', strScheduleCode = '2A', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726052
	UNION ALL SELECT intScheduleColumnId = 29, strFormCode = '72A089', strScheduleCode = '2A', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726053
	UNION ALL SELECT intScheduleColumnId = 30, strFormCode = '72A089', strScheduleCode = '2A', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726054
	UNION ALL SELECT intScheduleColumnId = 31, strFormCode = '72A089', strScheduleCode = '2A', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726055
	UNION ALL SELECT intScheduleColumnId = 32, strFormCode = '72A089', strScheduleCode = '2A', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726056
	UNION ALL SELECT intScheduleColumnId = 33, strFormCode = '72A089', strScheduleCode = '2A', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726057
	UNION ALL SELECT intScheduleColumnId = 34, strFormCode = '72A089', strScheduleCode = '2A', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726058
	UNION ALL SELECT intScheduleColumnId = 35, strFormCode = '72A089', strScheduleCode = '2A', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726059
	UNION ALL SELECT intScheduleColumnId = 36, strFormCode = '72A089', strScheduleCode = '2A', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726060
	UNION ALL SELECT intScheduleColumnId = 37, strFormCode = '72A089', strScheduleCode = '2A', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726061
	UNION ALL SELECT intScheduleColumnId = 38, strFormCode = '72A089', strScheduleCode = '2A', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726062
	UNION ALL SELECT intScheduleColumnId = 39, strFormCode = '72A089', strScheduleCode = '2A', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726063
	UNION ALL SELECT intScheduleColumnId = 40, strFormCode = '72A089', strScheduleCode = '2B', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726064
	UNION ALL SELECT intScheduleColumnId = 41, strFormCode = '72A089', strScheduleCode = '2B', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726065
	UNION ALL SELECT intScheduleColumnId = 42, strFormCode = '72A089', strScheduleCode = '2B', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726066
	UNION ALL SELECT intScheduleColumnId = 43, strFormCode = '72A089', strScheduleCode = '2B', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726067
	UNION ALL SELECT intScheduleColumnId = 44, strFormCode = '72A089', strScheduleCode = '2B', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726068
	UNION ALL SELECT intScheduleColumnId = 45, strFormCode = '72A089', strScheduleCode = '2B', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726069
	UNION ALL SELECT intScheduleColumnId = 46, strFormCode = '72A089', strScheduleCode = '2B', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726070
	UNION ALL SELECT intScheduleColumnId = 47, strFormCode = '72A089', strScheduleCode = '2B', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726071
	UNION ALL SELECT intScheduleColumnId = 48, strFormCode = '72A089', strScheduleCode = '2B', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726072
	UNION ALL SELECT intScheduleColumnId = 49, strFormCode = '72A089', strScheduleCode = '2B', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726073
	UNION ALL SELECT intScheduleColumnId = 50, strFormCode = '72A089', strScheduleCode = '2B', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726074
	UNION ALL SELECT intScheduleColumnId = 51, strFormCode = '72A089', strScheduleCode = '2B', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726075
	UNION ALL SELECT intScheduleColumnId = 52, strFormCode = '72A089', strScheduleCode = '2B', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726076
	UNION ALL SELECT intScheduleColumnId = 53, strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726077
	UNION ALL SELECT intScheduleColumnId = 54, strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726078
	UNION ALL SELECT intScheduleColumnId = 55, strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726079
	UNION ALL SELECT intScheduleColumnId = 56, strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726080
	UNION ALL SELECT intScheduleColumnId = 57, strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726081
	UNION ALL SELECT intScheduleColumnId = 58, strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726082
	UNION ALL SELECT intScheduleColumnId = 59, strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726083
	UNION ALL SELECT intScheduleColumnId = 60, strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726084
	UNION ALL SELECT intScheduleColumnId = 61, strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726085
	UNION ALL SELECT intScheduleColumnId = 62, strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726086
	UNION ALL SELECT intScheduleColumnId = 63, strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726087
	UNION ALL SELECT intScheduleColumnId = 64, strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726088
	UNION ALL SELECT intScheduleColumnId = 65, strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726089
	UNION ALL SELECT intScheduleColumnId = 66, strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726090
	UNION ALL SELECT intScheduleColumnId = 67, strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726091
	UNION ALL SELECT intScheduleColumnId = 68, strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726092
	UNION ALL SELECT intScheduleColumnId = 69, strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726093
	UNION ALL SELECT intScheduleColumnId = 70, strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726094
	UNION ALL SELECT intScheduleColumnId = 71, strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726095
	UNION ALL SELECT intScheduleColumnId = 72, strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726096
	UNION ALL SELECT intScheduleColumnId = 73, strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726097
	UNION ALL SELECT intScheduleColumnId = 74, strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726098
	UNION ALL SELECT intScheduleColumnId = 75, strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726099
	UNION ALL SELECT intScheduleColumnId = 76, strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726100
	UNION ALL SELECT intScheduleColumnId = 77, strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726101
	UNION ALL SELECT intScheduleColumnId = 78, strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726102
	UNION ALL SELECT intScheduleColumnId = 79, strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726103
	UNION ALL SELECT intScheduleColumnId = 80, strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726104
	UNION ALL SELECT intScheduleColumnId = 81, strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726105
	UNION ALL SELECT intScheduleColumnId = 82, strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726106
	UNION ALL SELECT intScheduleColumnId = 83, strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726107
	UNION ALL SELECT intScheduleColumnId = 84, strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726108
	UNION ALL SELECT intScheduleColumnId = 85, strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726109
	UNION ALL SELECT intScheduleColumnId = 86, strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726110
	UNION ALL SELECT intScheduleColumnId = 87, strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726111
	UNION ALL SELECT intScheduleColumnId = 88, strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726112
	UNION ALL SELECT intScheduleColumnId = 89, strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726113
	UNION ALL SELECT intScheduleColumnId = 90, strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726114
	UNION ALL SELECT intScheduleColumnId = 91, strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726115
	UNION ALL SELECT intScheduleColumnId = 92, strFormCode = '72A138', strScheduleCode = '1', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726116
	UNION ALL SELECT intScheduleColumnId = 93, strFormCode = '72A138', strScheduleCode = '1', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726117
	UNION ALL SELECT intScheduleColumnId = 94, strFormCode = '72A138', strScheduleCode = '1', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726118
	UNION ALL SELECT intScheduleColumnId = 95, strFormCode = '72A138', strScheduleCode = '1', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726119
	UNION ALL SELECT intScheduleColumnId = 96, strFormCode = '72A138', strScheduleCode = '1', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726120
	UNION ALL SELECT intScheduleColumnId = 97, strFormCode = '72A138', strScheduleCode = '1', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726121
	UNION ALL SELECT intScheduleColumnId = 98, strFormCode = '72A138', strScheduleCode = '1', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726122
	UNION ALL SELECT intScheduleColumnId = 99, strFormCode = '72A138', strScheduleCode = '1', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726123
	UNION ALL SELECT intScheduleColumnId = 100, strFormCode = '72A138', strScheduleCode = '1', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726124
	UNION ALL SELECT intScheduleColumnId = 101, strFormCode = '72A138', strScheduleCode = '1', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726125
	UNION ALL SELECT intScheduleColumnId = 102, strFormCode = '72A138', strScheduleCode = '1', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726126
	UNION ALL SELECT intScheduleColumnId = 103, strFormCode = '72A138', strScheduleCode = '1', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726127
	UNION ALL SELECT intScheduleColumnId = 104, strFormCode = '72A138', strScheduleCode = '1', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726128
	UNION ALL SELECT intScheduleColumnId = 105, strFormCode = '72A138', strScheduleCode = '2', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726129
	UNION ALL SELECT intScheduleColumnId = 106, strFormCode = '72A138', strScheduleCode = '2', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726130
	UNION ALL SELECT intScheduleColumnId = 107, strFormCode = '72A138', strScheduleCode = '2', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726131
	UNION ALL SELECT intScheduleColumnId = 108, strFormCode = '72A138', strScheduleCode = '2', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726132
	UNION ALL SELECT intScheduleColumnId = 109, strFormCode = '72A138', strScheduleCode = '2', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726133
	UNION ALL SELECT intScheduleColumnId = 110, strFormCode = '72A138', strScheduleCode = '2', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726134
	UNION ALL SELECT intScheduleColumnId = 111, strFormCode = '72A138', strScheduleCode = '2', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726135
	UNION ALL SELECT intScheduleColumnId = 112, strFormCode = '72A138', strScheduleCode = '2', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726136
	UNION ALL SELECT intScheduleColumnId = 113, strFormCode = '72A138', strScheduleCode = '2', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726137
	UNION ALL SELECT intScheduleColumnId = 114, strFormCode = '72A138', strScheduleCode = '2', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726138
	UNION ALL SELECT intScheduleColumnId = 115, strFormCode = '72A138', strScheduleCode = '2', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726139
	UNION ALL SELECT intScheduleColumnId = 116, strFormCode = '72A138', strScheduleCode = '2', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726140
	UNION ALL SELECT intScheduleColumnId = 117, strFormCode = '72A138', strScheduleCode = '2', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726141
	UNION ALL SELECT intScheduleColumnId = 118, strFormCode = '72A138', strScheduleCode = '2A', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726142
	UNION ALL SELECT intScheduleColumnId = 119, strFormCode = '72A138', strScheduleCode = '2A', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726143
	UNION ALL SELECT intScheduleColumnId = 120, strFormCode = '72A138', strScheduleCode = '2A', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726144
	UNION ALL SELECT intScheduleColumnId = 121, strFormCode = '72A138', strScheduleCode = '2A', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726145
	UNION ALL SELECT intScheduleColumnId = 122, strFormCode = '72A138', strScheduleCode = '2A', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726146
	UNION ALL SELECT intScheduleColumnId = 123, strFormCode = '72A138', strScheduleCode = '2A', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726147
	UNION ALL SELECT intScheduleColumnId = 124, strFormCode = '72A138', strScheduleCode = '2A', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726148
	UNION ALL SELECT intScheduleColumnId = 125, strFormCode = '72A138', strScheduleCode = '2A', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726149
	UNION ALL SELECT intScheduleColumnId = 126, strFormCode = '72A138', strScheduleCode = '2A', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726150
	UNION ALL SELECT intScheduleColumnId = 127, strFormCode = '72A138', strScheduleCode = '2A', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726151
	UNION ALL SELECT intScheduleColumnId = 128, strFormCode = '72A138', strScheduleCode = '2A', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726152
	UNION ALL SELECT intScheduleColumnId = 129, strFormCode = '72A138', strScheduleCode = '2A', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726153
	UNION ALL SELECT intScheduleColumnId = 130, strFormCode = '72A138', strScheduleCode = '2A', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726154
	UNION ALL SELECT intScheduleColumnId = 131, strFormCode = '72A138', strScheduleCode = '2B', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726155
	UNION ALL SELECT intScheduleColumnId = 132, strFormCode = '72A138', strScheduleCode = '2B', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726156
	UNION ALL SELECT intScheduleColumnId = 133, strFormCode = '72A138', strScheduleCode = '2B', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726157
	UNION ALL SELECT intScheduleColumnId = 134, strFormCode = '72A138', strScheduleCode = '2B', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726158
	UNION ALL SELECT intScheduleColumnId = 135, strFormCode = '72A138', strScheduleCode = '2B', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726159
	UNION ALL SELECT intScheduleColumnId = 136, strFormCode = '72A138', strScheduleCode = '2B', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726160
	UNION ALL SELECT intScheduleColumnId = 137, strFormCode = '72A138', strScheduleCode = '2B', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726161
	UNION ALL SELECT intScheduleColumnId = 138, strFormCode = '72A138', strScheduleCode = '2B', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726162
	UNION ALL SELECT intScheduleColumnId = 139, strFormCode = '72A138', strScheduleCode = '2B', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726163
	UNION ALL SELECT intScheduleColumnId = 140, strFormCode = '72A138', strScheduleCode = '2B', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726164
	UNION ALL SELECT intScheduleColumnId = 141, strFormCode = '72A138', strScheduleCode = '2B', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726165
	UNION ALL SELECT intScheduleColumnId = 142, strFormCode = '72A138', strScheduleCode = '2B', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726166
	UNION ALL SELECT intScheduleColumnId = 143, strFormCode = '72A138', strScheduleCode = '2B', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726167
	UNION ALL SELECT intScheduleColumnId = 144, strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726168
	UNION ALL SELECT intScheduleColumnId = 145, strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726169
	UNION ALL SELECT intScheduleColumnId = 146, strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726170
	UNION ALL SELECT intScheduleColumnId = 147, strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726171
	UNION ALL SELECT intScheduleColumnId = 148, strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726172
	UNION ALL SELECT intScheduleColumnId = 149, strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726173
	UNION ALL SELECT intScheduleColumnId = 150, strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726174
	UNION ALL SELECT intScheduleColumnId = 151, strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726175
	UNION ALL SELECT intScheduleColumnId = 152, strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726176
	UNION ALL SELECT intScheduleColumnId = 153, strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726177
	UNION ALL SELECT intScheduleColumnId = 154, strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726178
	UNION ALL SELECT intScheduleColumnId = 155, strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726179
	UNION ALL SELECT intScheduleColumnId = 156, strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726180
	UNION ALL SELECT intScheduleColumnId = 157, strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726181
	UNION ALL SELECT intScheduleColumnId = 158, strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726182
	UNION ALL SELECT intScheduleColumnId = 159, strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726183
	UNION ALL SELECT intScheduleColumnId = 160, strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726184
	UNION ALL SELECT intScheduleColumnId = 161, strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726185
	UNION ALL SELECT intScheduleColumnId = 162, strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726186
	UNION ALL SELECT intScheduleColumnId = 163, strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726187
	UNION ALL SELECT intScheduleColumnId = 164, strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726188
	UNION ALL SELECT intScheduleColumnId = 165, strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726189
	UNION ALL SELECT intScheduleColumnId = 166, strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726190
	UNION ALL SELECT intScheduleColumnId = 167, strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726191
	UNION ALL SELECT intScheduleColumnId = 168, strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726192
	UNION ALL SELECT intScheduleColumnId = 169, strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726193
	UNION ALL SELECT intScheduleColumnId = 170, strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726194
	UNION ALL SELECT intScheduleColumnId = 171, strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726195
	UNION ALL SELECT intScheduleColumnId = 172, strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726196
	UNION ALL SELECT intScheduleColumnId = 173, strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726197
	UNION ALL SELECT intScheduleColumnId = 174, strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726198
	UNION ALL SELECT intScheduleColumnId = 175, strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726199
	UNION ALL SELECT intScheduleColumnId = 176, strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726200
	UNION ALL SELECT intScheduleColumnId = 177, strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726201
	UNION ALL SELECT intScheduleColumnId = 178, strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726202
	UNION ALL SELECT intScheduleColumnId = 179, strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726203
	UNION ALL SELECT intScheduleColumnId = 180, strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726204
	UNION ALL SELECT intScheduleColumnId = 181, strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726205
	UNION ALL SELECT intScheduleColumnId = 182, strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726206
	UNION ALL SELECT intScheduleColumnId = 183, strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726207
	UNION ALL SELECT intScheduleColumnId = 184, strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726208
	UNION ALL SELECT intScheduleColumnId = 185, strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726209
	UNION ALL SELECT intScheduleColumnId = 186, strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726210
	UNION ALL SELECT intScheduleColumnId = 187, strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726211
	UNION ALL SELECT intScheduleColumnId = 188, strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726212
	UNION ALL SELECT intScheduleColumnId = 189, strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726213
	UNION ALL SELECT intScheduleColumnId = 190, strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726214
	UNION ALL SELECT intScheduleColumnId = 191, strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726215
	UNION ALL SELECT intScheduleColumnId = 192, strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726216
	UNION ALL SELECT intScheduleColumnId = 193, strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726217
	UNION ALL SELECT intScheduleColumnId = 194, strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726218
	UNION ALL SELECT intScheduleColumnId = 195, strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726219
	UNION ALL SELECT intScheduleColumnId = 196, strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726220
	UNION ALL SELECT intScheduleColumnId = 197, strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726221
	UNION ALL SELECT intScheduleColumnId = 198, strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726222
	UNION ALL SELECT intScheduleColumnId = 199, strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726223
	UNION ALL SELECT intScheduleColumnId = 200, strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726224
	UNION ALL SELECT intScheduleColumnId = 201, strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726225
	UNION ALL SELECT intScheduleColumnId = 202, strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726226
	UNION ALL SELECT intScheduleColumnId = 203, strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726227
	UNION ALL SELECT intScheduleColumnId = 204, strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726228
	UNION ALL SELECT intScheduleColumnId = 205, strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726229
	UNION ALL SELECT intScheduleColumnId = 206, strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726230
	UNION ALL SELECT intScheduleColumnId = 207, strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726231
	UNION ALL SELECT intScheduleColumnId = 208, strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726232
	UNION ALL SELECT intScheduleColumnId = 209, strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726233
	UNION ALL SELECT intScheduleColumnId = 210, strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726234
	UNION ALL SELECT intScheduleColumnId = 211, strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726235
	UNION ALL SELECT intScheduleColumnId = 212, strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726236
	UNION ALL SELECT intScheduleColumnId = 213, strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726237
	UNION ALL SELECT intScheduleColumnId = 214, strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726238
	UNION ALL SELECT intScheduleColumnId = 215, strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726239
	UNION ALL SELECT intScheduleColumnId = 216, strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726240
	UNION ALL SELECT intScheduleColumnId = 217, strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726241
	UNION ALL SELECT intScheduleColumnId = 218, strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726242
	UNION ALL SELECT intScheduleColumnId = 219, strFormCode = '72A138', strScheduleCode = '6', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726243
	UNION ALL SELECT intScheduleColumnId = 220, strFormCode = '72A138', strScheduleCode = '6', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726244
	UNION ALL SELECT intScheduleColumnId = 221, strFormCode = '72A138', strScheduleCode = '6', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726245
	UNION ALL SELECT intScheduleColumnId = 222, strFormCode = '72A138', strScheduleCode = '6', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726246
	UNION ALL SELECT intScheduleColumnId = 223, strFormCode = '72A138', strScheduleCode = '6', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726247
	UNION ALL SELECT intScheduleColumnId = 224, strFormCode = '72A138', strScheduleCode = '6', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726248
	UNION ALL SELECT intScheduleColumnId = 225, strFormCode = '72A138', strScheduleCode = '6', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726249
	UNION ALL SELECT intScheduleColumnId = 226, strFormCode = '72A138', strScheduleCode = '6', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726250
	UNION ALL SELECT intScheduleColumnId = 227, strFormCode = '72A138', strScheduleCode = '6', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726251
	UNION ALL SELECT intScheduleColumnId = 228, strFormCode = '72A138', strScheduleCode = '6', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726252
	UNION ALL SELECT intScheduleColumnId = 229, strFormCode = '72A138', strScheduleCode = '6', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726253
	UNION ALL SELECT intScheduleColumnId = 230, strFormCode = '72A138', strScheduleCode = '6', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726254
	UNION ALL SELECT intScheduleColumnId = 231, strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726255
	UNION ALL SELECT intScheduleColumnId = 232, strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726256
	UNION ALL SELECT intScheduleColumnId = 233, strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726257
	UNION ALL SELECT intScheduleColumnId = 234, strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726258
	UNION ALL SELECT intScheduleColumnId = 235, strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726259
	UNION ALL SELECT intScheduleColumnId = 236, strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726260
	UNION ALL SELECT intScheduleColumnId = 237, strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726261
	UNION ALL SELECT intScheduleColumnId = 238, strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726262
	UNION ALL SELECT intScheduleColumnId = 239, strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726263
	UNION ALL SELECT intScheduleColumnId = 240, strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726264
	UNION ALL SELECT intScheduleColumnId = 241, strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726265
	UNION ALL SELECT intScheduleColumnId = 242, strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726266
	UNION ALL SELECT intScheduleColumnId = 243, strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726267
	UNION ALL SELECT intScheduleColumnId = 244, strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726268
	UNION ALL SELECT intScheduleColumnId = 245, strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726269
	UNION ALL SELECT intScheduleColumnId = 246, strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726270
	UNION ALL SELECT intScheduleColumnId = 247, strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726271
	UNION ALL SELECT intScheduleColumnId = 248, strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726272
	UNION ALL SELECT intScheduleColumnId = 249, strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726273
	UNION ALL SELECT intScheduleColumnId = 250, strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726274
	UNION ALL SELECT intScheduleColumnId = 251, strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726275
	UNION ALL SELECT intScheduleColumnId = 252, strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726276
	UNION ALL SELECT intScheduleColumnId = 253, strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726277
	UNION ALL SELECT intScheduleColumnId = 254, strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726278
	UNION ALL SELECT intScheduleColumnId = 255, strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726279
	UNION ALL SELECT intScheduleColumnId = 256, strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726280
	UNION ALL SELECT intScheduleColumnId = 257, strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726281
	UNION ALL SELECT intScheduleColumnId = 258, strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726282
	UNION ALL SELECT intScheduleColumnId = 259, strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726283
	UNION ALL SELECT intScheduleColumnId = 260, strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726284
	UNION ALL SELECT intScheduleColumnId = 261, strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726285
	UNION ALL SELECT intScheduleColumnId = 262, strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726286
	UNION ALL SELECT intScheduleColumnId = 263, strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726287
	UNION ALL SELECT intScheduleColumnId = 264, strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726288
	UNION ALL SELECT intScheduleColumnId = 265, strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726289
	UNION ALL SELECT intScheduleColumnId = 266, strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726290
	UNION ALL SELECT intScheduleColumnId = 267, strFormCode = '72A138', strScheduleCode = '8', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726291
	UNION ALL SELECT intScheduleColumnId = 268, strFormCode = '72A138', strScheduleCode = '8', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726292
	UNION ALL SELECT intScheduleColumnId = 269, strFormCode = '72A138', strScheduleCode = '8', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726293
	UNION ALL SELECT intScheduleColumnId = 270, strFormCode = '72A138', strScheduleCode = '8', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726294
	UNION ALL SELECT intScheduleColumnId = 271, strFormCode = '72A138', strScheduleCode = '8', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726295
	UNION ALL SELECT intScheduleColumnId = 272, strFormCode = '72A138', strScheduleCode = '8', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726296
	UNION ALL SELECT intScheduleColumnId = 273, strFormCode = '72A138', strScheduleCode = '8', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726297
	UNION ALL SELECT intScheduleColumnId = 274, strFormCode = '72A138', strScheduleCode = '8', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726298
	UNION ALL SELECT intScheduleColumnId = 275, strFormCode = '72A138', strScheduleCode = '8', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726299
	UNION ALL SELECT intScheduleColumnId = 276, strFormCode = '72A138', strScheduleCode = '8', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726300
	UNION ALL SELECT intScheduleColumnId = 277, strFormCode = '72A138', strScheduleCode = '8', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726301
	UNION ALL SELECT intScheduleColumnId = 278, strFormCode = '72A138', strScheduleCode = '8', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726302
	UNION ALL SELECT intScheduleColumnId = 279, strFormCode = '72A138', strScheduleCode = '9', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726303
	UNION ALL SELECT intScheduleColumnId = 280, strFormCode = '72A138', strScheduleCode = '9', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726304
	UNION ALL SELECT intScheduleColumnId = 281, strFormCode = '72A138', strScheduleCode = '9', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726305
	UNION ALL SELECT intScheduleColumnId = 282, strFormCode = '72A138', strScheduleCode = '9', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726306
	UNION ALL SELECT intScheduleColumnId = 283, strFormCode = '72A138', strScheduleCode = '9', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726307
	UNION ALL SELECT intScheduleColumnId = 284, strFormCode = '72A138', strScheduleCode = '9', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726308
	UNION ALL SELECT intScheduleColumnId = 285, strFormCode = '72A138', strScheduleCode = '9', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726309
	UNION ALL SELECT intScheduleColumnId = 286, strFormCode = '72A138', strScheduleCode = '9', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726310
	UNION ALL SELECT intScheduleColumnId = 287, strFormCode = '72A138', strScheduleCode = '9', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726311
	UNION ALL SELECT intScheduleColumnId = 288, strFormCode = '72A138', strScheduleCode = '9', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726312
	UNION ALL SELECT intScheduleColumnId = 289, strFormCode = '72A138', strScheduleCode = '9', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726313
	UNION ALL SELECT intScheduleColumnId = 290, strFormCode = '72A138', strScheduleCode = '9', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726314
	UNION ALL SELECT intScheduleColumnId = 291, strFormCode = '72A138', strScheduleCode = '10A', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726315
	UNION ALL SELECT intScheduleColumnId = 292, strFormCode = '72A138', strScheduleCode = '10A', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726316
	UNION ALL SELECT intScheduleColumnId = 293, strFormCode = '72A138', strScheduleCode = '10A', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726317
	UNION ALL SELECT intScheduleColumnId = 294, strFormCode = '72A138', strScheduleCode = '10A', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726318
	UNION ALL SELECT intScheduleColumnId = 295, strFormCode = '72A138', strScheduleCode = '10A', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726319
	UNION ALL SELECT intScheduleColumnId = 296, strFormCode = '72A138', strScheduleCode = '10A', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726320
	UNION ALL SELECT intScheduleColumnId = 297, strFormCode = '72A138', strScheduleCode = '10A', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726321
	UNION ALL SELECT intScheduleColumnId = 298, strFormCode = '72A138', strScheduleCode = '10A', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726322
	UNION ALL SELECT intScheduleColumnId = 299, strFormCode = '72A138', strScheduleCode = '10A', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726323
	UNION ALL SELECT intScheduleColumnId = 300, strFormCode = '72A138', strScheduleCode = '10A', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726324
	UNION ALL SELECT intScheduleColumnId = 301, strFormCode = '72A138', strScheduleCode = '10A', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726325
	UNION ALL SELECT intScheduleColumnId = 302, strFormCode = '72A138', strScheduleCode = '10A', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726326
	UNION ALL SELECT intScheduleColumnId = 303, strFormCode = '72A138', strScheduleCode = '10G', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726327
	UNION ALL SELECT intScheduleColumnId = 304, strFormCode = '72A138', strScheduleCode = '10G', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726328
	UNION ALL SELECT intScheduleColumnId = 305, strFormCode = '72A138', strScheduleCode = '10G', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726329
	UNION ALL SELECT intScheduleColumnId = 306, strFormCode = '72A138', strScheduleCode = '10G', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726330
	UNION ALL SELECT intScheduleColumnId = 307, strFormCode = '72A138', strScheduleCode = '10G', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726331
	UNION ALL SELECT intScheduleColumnId = 308, strFormCode = '72A138', strScheduleCode = '10G', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726332
	UNION ALL SELECT intScheduleColumnId = 309, strFormCode = '72A138', strScheduleCode = '10G', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726333
	UNION ALL SELECT intScheduleColumnId = 310, strFormCode = '72A138', strScheduleCode = '10G', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726334
	UNION ALL SELECT intScheduleColumnId = 311, strFormCode = '72A138', strScheduleCode = '10G', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726335
	UNION ALL SELECT intScheduleColumnId = 312, strFormCode = '72A138', strScheduleCode = '10G', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726336
	UNION ALL SELECT intScheduleColumnId = 313, strFormCode = '72A138', strScheduleCode = '10G', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726337
	UNION ALL SELECT intScheduleColumnId = 314, strFormCode = '72A138', strScheduleCode = '10G', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726338
	UNION ALL SELECT intScheduleColumnId = 315, strFormCode = '72A138', strScheduleCode = '10I', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726339
	UNION ALL SELECT intScheduleColumnId = 316, strFormCode = '72A138', strScheduleCode = '10I', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726340
	UNION ALL SELECT intScheduleColumnId = 317, strFormCode = '72A138', strScheduleCode = '10I', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726341
	UNION ALL SELECT intScheduleColumnId = 318, strFormCode = '72A138', strScheduleCode = '10I', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726342
	UNION ALL SELECT intScheduleColumnId = 319, strFormCode = '72A138', strScheduleCode = '10I', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726343
	UNION ALL SELECT intScheduleColumnId = 320, strFormCode = '72A138', strScheduleCode = '10I', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726344
	UNION ALL SELECT intScheduleColumnId = 321, strFormCode = '72A138', strScheduleCode = '10I', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726345
	UNION ALL SELECT intScheduleColumnId = 322, strFormCode = '72A138', strScheduleCode = '10I', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726346
	UNION ALL SELECT intScheduleColumnId = 323, strFormCode = '72A138', strScheduleCode = '10I', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726347
	UNION ALL SELECT intScheduleColumnId = 324, strFormCode = '72A138', strScheduleCode = '10I', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726348
	UNION ALL SELECT intScheduleColumnId = 325, strFormCode = '72A138', strScheduleCode = '10I', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726349
	UNION ALL SELECT intScheduleColumnId = 326, strFormCode = '72A138', strScheduleCode = '10I', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726350
	UNION ALL SELECT intScheduleColumnId = 327, strFormCode = '72A138', strScheduleCode = '10J', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726351
	UNION ALL SELECT intScheduleColumnId = 328, strFormCode = '72A138', strScheduleCode = '10J', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726352
	UNION ALL SELECT intScheduleColumnId = 329, strFormCode = '72A138', strScheduleCode = '10J', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726353
	UNION ALL SELECT intScheduleColumnId = 330, strFormCode = '72A138', strScheduleCode = '10J', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726354
	UNION ALL SELECT intScheduleColumnId = 331, strFormCode = '72A138', strScheduleCode = '10J', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726355
	UNION ALL SELECT intScheduleColumnId = 332, strFormCode = '72A138', strScheduleCode = '10J', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726356
	UNION ALL SELECT intScheduleColumnId = 333, strFormCode = '72A138', strScheduleCode = '10J', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726357
	UNION ALL SELECT intScheduleColumnId = 334, strFormCode = '72A138', strScheduleCode = '10J', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726358
	UNION ALL SELECT intScheduleColumnId = 335, strFormCode = '72A138', strScheduleCode = '10J', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726359
	UNION ALL SELECT intScheduleColumnId = 336, strFormCode = '72A138', strScheduleCode = '10J', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726360
	UNION ALL SELECT intScheduleColumnId = 337, strFormCode = '72A138', strScheduleCode = '10J', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726361
	UNION ALL SELECT intScheduleColumnId = 338, strFormCode = '72A138', strScheduleCode = '10J', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726362
	UNION ALL SELECT intScheduleColumnId = 339, strFormCode = '72A138', strScheduleCode = '10Y', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726363
	UNION ALL SELECT intScheduleColumnId = 340, strFormCode = '72A138', strScheduleCode = '10Y', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726364
	UNION ALL SELECT intScheduleColumnId = 341, strFormCode = '72A138', strScheduleCode = '10Y', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726365
	UNION ALL SELECT intScheduleColumnId = 342, strFormCode = '72A138', strScheduleCode = '10Y', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726366
	UNION ALL SELECT intScheduleColumnId = 343, strFormCode = '72A138', strScheduleCode = '10Y', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726367
	UNION ALL SELECT intScheduleColumnId = 344, strFormCode = '72A138', strScheduleCode = '10Y', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726368
	UNION ALL SELECT intScheduleColumnId = 345, strFormCode = '72A138', strScheduleCode = '10Y', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726369
	UNION ALL SELECT intScheduleColumnId = 346, strFormCode = '72A138', strScheduleCode = '10Y', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726370
	UNION ALL SELECT intScheduleColumnId = 347, strFormCode = '72A138', strScheduleCode = '10Y', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726371
	UNION ALL SELECT intScheduleColumnId = 348, strFormCode = '72A138', strScheduleCode = '10Y', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726372
	UNION ALL SELECT intScheduleColumnId = 349, strFormCode = '72A138', strScheduleCode = '10Y', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726373
	UNION ALL SELECT intScheduleColumnId = 350, strFormCode = '72A138', strScheduleCode = '10Y', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726374
	UNION ALL SELECT intScheduleColumnId = 351, strFormCode = '72A089', strScheduleCode = '5D_IL', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726375
	UNION ALL SELECT intScheduleColumnId = 352, strFormCode = '72A089', strScheduleCode = '5D_IL', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726376
	UNION ALL SELECT intScheduleColumnId = 353, strFormCode = '72A089', strScheduleCode = '5D_IL', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726377
	UNION ALL SELECT intScheduleColumnId = 354, strFormCode = '72A089', strScheduleCode = '5D_IL', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726378
	UNION ALL SELECT intScheduleColumnId = 355, strFormCode = '72A089', strScheduleCode = '5D_IL', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726379
	UNION ALL SELECT intScheduleColumnId = 356, strFormCode = '72A089', strScheduleCode = '5D_IL', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726380
	UNION ALL SELECT intScheduleColumnId = 357, strFormCode = '72A089', strScheduleCode = '5D_IL', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726381
	UNION ALL SELECT intScheduleColumnId = 358, strFormCode = '72A089', strScheduleCode = '5D_IL', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726382
	UNION ALL SELECT intScheduleColumnId = 359, strFormCode = '72A089', strScheduleCode = '5D_IL', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726383
	UNION ALL SELECT intScheduleColumnId = 360, strFormCode = '72A089', strScheduleCode = '5D_IL', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726384
	UNION ALL SELECT intScheduleColumnId = 361, strFormCode = '72A089', strScheduleCode = '5D_IL', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726385
	UNION ALL SELECT intScheduleColumnId = 362, strFormCode = '72A089', strScheduleCode = '5D_IL', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726386
	UNION ALL SELECT intScheduleColumnId = 363, strFormCode = '72A089', strScheduleCode = '5D_IN', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726387
	UNION ALL SELECT intScheduleColumnId = 364, strFormCode = '72A089', strScheduleCode = '5D_IN', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726388
	UNION ALL SELECT intScheduleColumnId = 365, strFormCode = '72A089', strScheduleCode = '5D_IN', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726389
	UNION ALL SELECT intScheduleColumnId = 366, strFormCode = '72A089', strScheduleCode = '5D_IN', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726390
	UNION ALL SELECT intScheduleColumnId = 367, strFormCode = '72A089', strScheduleCode = '5D_IN', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726391
	UNION ALL SELECT intScheduleColumnId = 368, strFormCode = '72A089', strScheduleCode = '5D_IN', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726392
	UNION ALL SELECT intScheduleColumnId = 369, strFormCode = '72A089', strScheduleCode = '5D_IN', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726393
	UNION ALL SELECT intScheduleColumnId = 370, strFormCode = '72A089', strScheduleCode = '5D_IN', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726394
	UNION ALL SELECT intScheduleColumnId = 371, strFormCode = '72A089', strScheduleCode = '5D_IN', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726395
	UNION ALL SELECT intScheduleColumnId = 372, strFormCode = '72A089', strScheduleCode = '5D_IN', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726396
	UNION ALL SELECT intScheduleColumnId = 373, strFormCode = '72A089', strScheduleCode = '5D_IN', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726397
	UNION ALL SELECT intScheduleColumnId = 374, strFormCode = '72A089', strScheduleCode = '5D_IN', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726398
	UNION ALL SELECT intScheduleColumnId = 375, strFormCode = '72A089', strScheduleCode = '5D_TN', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726399
	UNION ALL SELECT intScheduleColumnId = 376, strFormCode = '72A089', strScheduleCode = '5D_TN', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726400
	UNION ALL SELECT intScheduleColumnId = 377, strFormCode = '72A089', strScheduleCode = '5D_TN', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726401
	UNION ALL SELECT intScheduleColumnId = 378, strFormCode = '72A089', strScheduleCode = '5D_TN', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726402
	UNION ALL SELECT intScheduleColumnId = 379, strFormCode = '72A089', strScheduleCode = '5D_TN', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726403
	UNION ALL SELECT intScheduleColumnId = 380, strFormCode = '72A089', strScheduleCode = '5D_TN', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726404
	UNION ALL SELECT intScheduleColumnId = 381, strFormCode = '72A089', strScheduleCode = '5D_TN', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726405
	UNION ALL SELECT intScheduleColumnId = 382, strFormCode = '72A089', strScheduleCode = '5D_TN', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726406
	UNION ALL SELECT intScheduleColumnId = 383, strFormCode = '72A089', strScheduleCode = '5D_TN', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726407
	UNION ALL SELECT intScheduleColumnId = 384, strFormCode = '72A089', strScheduleCode = '5D_TN', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726408
	UNION ALL SELECT intScheduleColumnId = 385, strFormCode = '72A089', strScheduleCode = '5D_TN', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726409
	UNION ALL SELECT intScheduleColumnId = 386, strFormCode = '72A089', strScheduleCode = '5D_TN', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726410
	UNION ALL SELECT intScheduleColumnId = 387, strFormCode = '72A089', strScheduleCode = '6', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726411
	UNION ALL SELECT intScheduleColumnId = 388, strFormCode = '72A089', strScheduleCode = '6', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726412
	UNION ALL SELECT intScheduleColumnId = 389, strFormCode = '72A089', strScheduleCode = '6', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726413
	UNION ALL SELECT intScheduleColumnId = 390, strFormCode = '72A089', strScheduleCode = '6', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726414
	UNION ALL SELECT intScheduleColumnId = 391, strFormCode = '72A089', strScheduleCode = '6', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726415
	UNION ALL SELECT intScheduleColumnId = 392, strFormCode = '72A089', strScheduleCode = '6', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726416
	UNION ALL SELECT intScheduleColumnId = 393, strFormCode = '72A089', strScheduleCode = '6', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726417
	UNION ALL SELECT intScheduleColumnId = 394, strFormCode = '72A089', strScheduleCode = '6', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726418
	UNION ALL SELECT intScheduleColumnId = 395, strFormCode = '72A089', strScheduleCode = '6', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726419
	UNION ALL SELECT intScheduleColumnId = 396, strFormCode = '72A089', strScheduleCode = '6', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726420
	UNION ALL SELECT intScheduleColumnId = 397, strFormCode = '72A089', strScheduleCode = '6', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726421
	UNION ALL SELECT intScheduleColumnId = 398, strFormCode = '72A089', strScheduleCode = '6', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726422
	UNION ALL SELECT intScheduleColumnId = 399, strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726423
	UNION ALL SELECT intScheduleColumnId = 400, strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726424
	UNION ALL SELECT intScheduleColumnId = 401, strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726425
	UNION ALL SELECT intScheduleColumnId = 402, strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726426
	UNION ALL SELECT intScheduleColumnId = 403, strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726427
	UNION ALL SELECT intScheduleColumnId = 404, strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726428
	UNION ALL SELECT intScheduleColumnId = 405, strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726429
	UNION ALL SELECT intScheduleColumnId = 406, strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726430
	UNION ALL SELECT intScheduleColumnId = 407, strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726431
	UNION ALL SELECT intScheduleColumnId = 408, strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726432
	UNION ALL SELECT intScheduleColumnId = 409, strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726433
	UNION ALL SELECT intScheduleColumnId = 410, strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726434
	UNION ALL SELECT intScheduleColumnId = 411, strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726435
	UNION ALL SELECT intScheduleColumnId = 412, strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726436
	UNION ALL SELECT intScheduleColumnId = 413, strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726437
	UNION ALL SELECT intScheduleColumnId = 414, strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726438
	UNION ALL SELECT intScheduleColumnId = 415, strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726439
	UNION ALL SELECT intScheduleColumnId = 416, strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726440
	UNION ALL SELECT intScheduleColumnId = 417, strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726441
	UNION ALL SELECT intScheduleColumnId = 418, strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726442
	UNION ALL SELECT intScheduleColumnId = 419, strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726443
	UNION ALL SELECT intScheduleColumnId = 420, strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726444
	UNION ALL SELECT intScheduleColumnId = 421, strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726445
	UNION ALL SELECT intScheduleColumnId = 422, strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726446
	UNION ALL SELECT intScheduleColumnId = 423, strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726447
	UNION ALL SELECT intScheduleColumnId = 424, strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726448
	UNION ALL SELECT intScheduleColumnId = 425, strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726449
	UNION ALL SELECT intScheduleColumnId = 426, strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726450
	UNION ALL SELECT intScheduleColumnId = 427, strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726451
	UNION ALL SELECT intScheduleColumnId = 428, strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726452
	UNION ALL SELECT intScheduleColumnId = 429, strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726453
	UNION ALL SELECT intScheduleColumnId = 430, strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726454
	UNION ALL SELECT intScheduleColumnId = 431, strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726455
	UNION ALL SELECT intScheduleColumnId = 432, strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726456
	UNION ALL SELECT intScheduleColumnId = 433, strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726457
	UNION ALL SELECT intScheduleColumnId = 434, strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726458
	UNION ALL SELECT intScheduleColumnId = 435, strFormCode = '72A089', strScheduleCode = '8', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726459
	UNION ALL SELECT intScheduleColumnId = 436, strFormCode = '72A089', strScheduleCode = '8', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726460
	UNION ALL SELECT intScheduleColumnId = 437, strFormCode = '72A089', strScheduleCode = '8', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726461
	UNION ALL SELECT intScheduleColumnId = 438, strFormCode = '72A089', strScheduleCode = '8', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726462
	UNION ALL SELECT intScheduleColumnId = 439, strFormCode = '72A089', strScheduleCode = '8', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726463
	UNION ALL SELECT intScheduleColumnId = 440, strFormCode = '72A089', strScheduleCode = '8', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726464
	UNION ALL SELECT intScheduleColumnId = 441, strFormCode = '72A089', strScheduleCode = '8', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726465
	UNION ALL SELECT intScheduleColumnId = 442, strFormCode = '72A089', strScheduleCode = '8', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726466
	UNION ALL SELECT intScheduleColumnId = 443, strFormCode = '72A089', strScheduleCode = '8', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726467
	UNION ALL SELECT intScheduleColumnId = 444, strFormCode = '72A089', strScheduleCode = '8', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726468
	UNION ALL SELECT intScheduleColumnId = 445, strFormCode = '72A089', strScheduleCode = '8', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726469
	UNION ALL SELECT intScheduleColumnId = 446, strFormCode = '72A089', strScheduleCode = '8', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726470
	UNION ALL SELECT intScheduleColumnId = 447, strFormCode = '72A089', strScheduleCode = '10I', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726471
	UNION ALL SELECT intScheduleColumnId = 448, strFormCode = '72A089', strScheduleCode = '10I', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726472
	UNION ALL SELECT intScheduleColumnId = 449, strFormCode = '72A089', strScheduleCode = '10I', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726473
	UNION ALL SELECT intScheduleColumnId = 450, strFormCode = '72A089', strScheduleCode = '10I', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726474
	UNION ALL SELECT intScheduleColumnId = 451, strFormCode = '72A089', strScheduleCode = '10I', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726475
	UNION ALL SELECT intScheduleColumnId = 452, strFormCode = '72A089', strScheduleCode = '10I', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726476
	UNION ALL SELECT intScheduleColumnId = 453, strFormCode = '72A089', strScheduleCode = '10I', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726477
	UNION ALL SELECT intScheduleColumnId = 454, strFormCode = '72A089', strScheduleCode = '10I', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726478
	UNION ALL SELECT intScheduleColumnId = 455, strFormCode = '72A089', strScheduleCode = '10I', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726479
	UNION ALL SELECT intScheduleColumnId = 456, strFormCode = '72A089', strScheduleCode = '10I', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726480
	UNION ALL SELECT intScheduleColumnId = 457, strFormCode = '72A089', strScheduleCode = '10I', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726481
	UNION ALL SELECT intScheduleColumnId = 458, strFormCode = '72A089', strScheduleCode = '10I', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726482

	UNION ALL SELECT intScheduleColumnId = 459, strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726483
	UNION ALL SELECT intScheduleColumnId = 460, strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726484
	UNION ALL SELECT intScheduleColumnId = 461, strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726485
	UNION ALL SELECT intScheduleColumnId = 462, strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726486
	UNION ALL SELECT intScheduleColumnId = 463, strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726487
	UNION ALL SELECT intScheduleColumnId = 464, strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726488
	UNION ALL SELECT intScheduleColumnId = 465, strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726489
	UNION ALL SELECT intScheduleColumnId = 466, strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726490
	UNION ALL SELECT intScheduleColumnId = 467, strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726491
	UNION ALL SELECT intScheduleColumnId = 468, strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726492
	UNION ALL SELECT intScheduleColumnId = 469, strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726493
	UNION ALL SELECT intScheduleColumnId = 470, strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726494
	UNION ALL SELECT intScheduleColumnId = 471, strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726495
	UNION ALL SELECT intScheduleColumnId = 472, strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726496
	UNION ALL SELECT intScheduleColumnId = 473, strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726497
	UNION ALL SELECT intScheduleColumnId = 474, strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726498
	UNION ALL SELECT intScheduleColumnId = 475, strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726499
	UNION ALL SELECT intScheduleColumnId = 476, strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726500
	UNION ALL SELECT intScheduleColumnId = 477, strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726501
	UNION ALL SELECT intScheduleColumnId = 478, strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726502
	UNION ALL SELECT intScheduleColumnId = 479, strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726503
	UNION ALL SELECT intScheduleColumnId = 480, strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726504
	UNION ALL SELECT intScheduleColumnId = 481, strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726505
	UNION ALL SELECT intScheduleColumnId = 482, strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726506
	UNION ALL SELECT intScheduleColumnId = 483, strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726507
	UNION ALL SELECT intScheduleColumnId = 484, strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726508
	UNION ALL SELECT intScheduleColumnId = 485, strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726509
	UNION ALL SELECT intScheduleColumnId = 486, strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726510
	UNION ALL SELECT intScheduleColumnId = 487, strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726511
	UNION ALL SELECT intScheduleColumnId = 488, strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726512
	UNION ALL SELECT intScheduleColumnId = 489, strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726513
	UNION ALL SELECT intScheduleColumnId = 490, strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726514
	UNION ALL SELECT intScheduleColumnId = 491, strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726515
	UNION ALL SELECT intScheduleColumnId = 492, strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726516
	UNION ALL SELECT intScheduleColumnId = 493, strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726517
	UNION ALL SELECT intScheduleColumnId = 494, strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726518
	UNION ALL SELECT intScheduleColumnId = 495, strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726519
	UNION ALL SELECT intScheduleColumnId = 496, strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726520
	UNION ALL SELECT intScheduleColumnId = 497, strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726521
	UNION ALL SELECT intScheduleColumnId = 498, strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726522
	UNION ALL SELECT intScheduleColumnId = 499, strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726523
	UNION ALL SELECT intScheduleColumnId = 500, strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726524
	UNION ALL SELECT intScheduleColumnId = 501, strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726525
	UNION ALL SELECT intScheduleColumnId = 502, strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726526
	UNION ALL SELECT intScheduleColumnId = 503, strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726527
	UNION ALL SELECT intScheduleColumnId = 504, strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726528
	UNION ALL SELECT intScheduleColumnId = 505, strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726529
	UNION ALL SELECT intScheduleColumnId = 506, strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726530
	UNION ALL SELECT intScheduleColumnId = 507, strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726531
	UNION ALL SELECT intScheduleColumnId = 508, strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726532
	UNION ALL SELECT intScheduleColumnId = 509, strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726533
	UNION ALL SELECT intScheduleColumnId = 510, strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726534
	UNION ALL SELECT intScheduleColumnId = 511, strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726535
	UNION ALL SELECT intScheduleColumnId = 512, strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726536
	UNION ALL SELECT intScheduleColumnId = 513, strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726537
	UNION ALL SELECT intScheduleColumnId = 514, strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726538
	UNION ALL SELECT intScheduleColumnId = 515, strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726539
	UNION ALL SELECT intScheduleColumnId = 516, strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726540
	UNION ALL SELECT intScheduleColumnId = 517, strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726541
	UNION ALL SELECT intScheduleColumnId = 518, strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726542
	UNION ALL SELECT intScheduleColumnId = 519, strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726543
	UNION ALL SELECT intScheduleColumnId = 520, strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726544
	UNION ALL SELECT intScheduleColumnId = 521, strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726545
	UNION ALL SELECT intScheduleColumnId = 522, strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726546
	UNION ALL SELECT intScheduleColumnId = 523, strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726547
	UNION ALL SELECT intScheduleColumnId = 524, strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726548
	UNION ALL SELECT intScheduleColumnId = 525, strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726549
	UNION ALL SELECT intScheduleColumnId = 526, strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726550
	UNION ALL SELECT intScheduleColumnId = 527, strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726551
	UNION ALL SELECT intScheduleColumnId = 528, strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726552
	UNION ALL SELECT intScheduleColumnId = 529, strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726553
	UNION ALL SELECT intScheduleColumnId = 530, strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726554
	UNION ALL SELECT intScheduleColumnId = 531, strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726555
	UNION ALL SELECT intScheduleColumnId = 532, strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726556
	UNION ALL SELECT intScheduleColumnId = 533, strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726557
	UNION ALL SELECT intScheduleColumnId = 534, strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726558
	UNION ALL SELECT intScheduleColumnId = 535, strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726559
	UNION ALL SELECT intScheduleColumnId = 536, strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726560
	UNION ALL SELECT intScheduleColumnId = 537, strFormCode = '72A089', strScheduleCode = '5D_OH', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726561
	UNION ALL SELECT intScheduleColumnId = 538, strFormCode = '72A089', strScheduleCode = '5D_OH', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726562
	UNION ALL SELECT intScheduleColumnId = 539, strFormCode = '72A089', strScheduleCode = '5D_OH', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726563
	UNION ALL SELECT intScheduleColumnId = 540, strFormCode = '72A089', strScheduleCode = '5D_OH', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726564
	UNION ALL SELECT intScheduleColumnId = 541, strFormCode = '72A089', strScheduleCode = '5D_OH', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726565
	UNION ALL SELECT intScheduleColumnId = 542, strFormCode = '72A089', strScheduleCode = '5D_OH', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726566
	UNION ALL SELECT intScheduleColumnId = 543, strFormCode = '72A089', strScheduleCode = '5D_OH', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726567
	UNION ALL SELECT intScheduleColumnId = 544, strFormCode = '72A089', strScheduleCode = '5D_OH', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726568
	UNION ALL SELECT intScheduleColumnId = 545, strFormCode = '72A089', strScheduleCode = '5D_OH', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726569
	UNION ALL SELECT intScheduleColumnId = 546, strFormCode = '72A089', strScheduleCode = '5D_OH', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726570
	UNION ALL SELECT intScheduleColumnId = 547, strFormCode = '72A089', strScheduleCode = '5D_OH', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726571
	UNION ALL SELECT intScheduleColumnId = 548, strFormCode = '72A089', strScheduleCode = '5D_OH', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726572
	UNION ALL SELECT intScheduleColumnId = 549, strFormCode = '72A089', strScheduleCode = '5D_VA', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726573
	UNION ALL SELECT intScheduleColumnId = 550, strFormCode = '72A089', strScheduleCode = '5D_VA', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726574
	UNION ALL SELECT intScheduleColumnId = 551, strFormCode = '72A089', strScheduleCode = '5D_VA', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726575
	UNION ALL SELECT intScheduleColumnId = 552, strFormCode = '72A089', strScheduleCode = '5D_VA', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726576
	UNION ALL SELECT intScheduleColumnId = 553, strFormCode = '72A089', strScheduleCode = '5D_VA', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726577
	UNION ALL SELECT intScheduleColumnId = 554, strFormCode = '72A089', strScheduleCode = '5D_VA', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726578
	UNION ALL SELECT intScheduleColumnId = 555, strFormCode = '72A089', strScheduleCode = '5D_VA', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726579
	UNION ALL SELECT intScheduleColumnId = 556, strFormCode = '72A089', strScheduleCode = '5D_VA', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726580
	UNION ALL SELECT intScheduleColumnId = 557, strFormCode = '72A089', strScheduleCode = '5D_VA', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726581
	UNION ALL SELECT intScheduleColumnId = 558, strFormCode = '72A089', strScheduleCode = '5D_VA', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726582
	UNION ALL SELECT intScheduleColumnId = 559, strFormCode = '72A089', strScheduleCode = '5D_VA', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726583
	UNION ALL SELECT intScheduleColumnId = 560, strFormCode = '72A089', strScheduleCode = '5D_VA', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726584
	UNION ALL SELECT intScheduleColumnId = 561, strFormCode = '72A089', strScheduleCode = '5D_WV', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726585
	UNION ALL SELECT intScheduleColumnId = 562, strFormCode = '72A089', strScheduleCode = '5D_WV', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726586
	UNION ALL SELECT intScheduleColumnId = 563, strFormCode = '72A089', strScheduleCode = '5D_WV', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726587
	UNION ALL SELECT intScheduleColumnId = 564, strFormCode = '72A089', strScheduleCode = '5D_WV', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726588
	UNION ALL SELECT intScheduleColumnId = 565, strFormCode = '72A089', strScheduleCode = '5D_WV', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726589
	UNION ALL SELECT intScheduleColumnId = 566, strFormCode = '72A089', strScheduleCode = '5D_WV', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726590
	UNION ALL SELECT intScheduleColumnId = 567, strFormCode = '72A089', strScheduleCode = '5D_WV', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726591
	UNION ALL SELECT intScheduleColumnId = 568, strFormCode = '72A089', strScheduleCode = '5D_WV', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726592
	UNION ALL SELECT intScheduleColumnId = 569, strFormCode = '72A089', strScheduleCode = '5D_WV', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726593
	UNION ALL SELECT intScheduleColumnId = 570, strFormCode = '72A089', strScheduleCode = '5D_WV', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726594
	UNION ALL SELECT intScheduleColumnId = 571, strFormCode = '72A089', strScheduleCode = '5D_WV', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726595
	UNION ALL SELECT intScheduleColumnId = 572, strFormCode = '72A089', strScheduleCode = '5D_WV', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726596
	UNION ALL SELECT intScheduleColumnId = 573, strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726597
	UNION ALL SELECT intScheduleColumnId = 574, strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726598
	UNION ALL SELECT intScheduleColumnId = 575, strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726599
	UNION ALL SELECT intScheduleColumnId = 576, strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726600
	UNION ALL SELECT intScheduleColumnId = 577, strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726601
	UNION ALL SELECT intScheduleColumnId = 578, strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726602
	UNION ALL SELECT intScheduleColumnId = 579, strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726603
	UNION ALL SELECT intScheduleColumnId = 580, strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726604
	UNION ALL SELECT intScheduleColumnId = 581, strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726605
	UNION ALL SELECT intScheduleColumnId = 582, strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726606
	UNION ALL SELECT intScheduleColumnId = 583, strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726607
	UNION ALL SELECT intScheduleColumnId = 584, strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726608
	UNION ALL SELECT intScheduleColumnId = 585, strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726609
	UNION ALL SELECT intScheduleColumnId = 586, strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726610
	UNION ALL SELECT intScheduleColumnId = 587, strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726611
	UNION ALL SELECT intScheduleColumnId = 588, strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726612
	UNION ALL SELECT intScheduleColumnId = 589, strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726613
	UNION ALL SELECT intScheduleColumnId = 590, strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726614
	UNION ALL SELECT intScheduleColumnId = 591, strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726615
	UNION ALL SELECT intScheduleColumnId = 592, strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726616
	UNION ALL SELECT intScheduleColumnId = 593, strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726617
	UNION ALL SELECT intScheduleColumnId = 594, strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726618
	UNION ALL SELECT intScheduleColumnId = 595, strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726619
	UNION ALL SELECT intScheduleColumnId = 596, strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726620
	UNION ALL SELECT intScheduleColumnId = 597, strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726621
	UNION ALL SELECT intScheduleColumnId = 598, strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726622
	UNION ALL SELECT intScheduleColumnId = 599, strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726623
	UNION ALL SELECT intScheduleColumnId = 600, strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726624
	UNION ALL SELECT intScheduleColumnId = 601, strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726625
	UNION ALL SELECT intScheduleColumnId = 602, strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726626
	UNION ALL SELECT intScheduleColumnId = 603, strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726627
	UNION ALL SELECT intScheduleColumnId = 604, strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726628
	UNION ALL SELECT intScheduleColumnId = 605, strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726629
	UNION ALL SELECT intScheduleColumnId = 606, strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726630
	UNION ALL SELECT intScheduleColumnId = 607, strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726631
	UNION ALL SELECT intScheduleColumnId = 608, strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726632
	UNION ALL SELECT intScheduleColumnId = 609, strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726633
	UNION ALL SELECT intScheduleColumnId = 610, strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726634
	UNION ALL SELECT intScheduleColumnId = 611, strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726635
	UNION ALL SELECT intScheduleColumnId = 612, strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726636
	UNION ALL SELECT intScheduleColumnId = 613, strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726637
	UNION ALL SELECT intScheduleColumnId = 614, strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726638
	UNION ALL SELECT intScheduleColumnId = 615, strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726639
	UNION ALL SELECT intScheduleColumnId = 616, strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726640
	UNION ALL SELECT intScheduleColumnId = 617, strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726641
	UNION ALL SELECT intScheduleColumnId = 618, strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726642
	UNION ALL SELECT intScheduleColumnId = 619, strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726643
	UNION ALL SELECT intScheduleColumnId = 620, strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726644
	UNION ALL SELECT intScheduleColumnId = 621, strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726645
	UNION ALL SELECT intScheduleColumnId = 622, strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726646
	UNION ALL SELECT intScheduleColumnId = 623, strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726647
	UNION ALL SELECT intScheduleColumnId = 624, strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726648
	UNION ALL SELECT intScheduleColumnId = 625, strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726649
	UNION ALL SELECT intScheduleColumnId = 626, strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726650
	UNION ALL SELECT intScheduleColumnId = 627, strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726651
	UNION ALL SELECT intScheduleColumnId = 628, strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726652
	UNION ALL SELECT intScheduleColumnId = 629, strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726653
	UNION ALL SELECT intScheduleColumnId = 630, strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726654
	UNION ALL SELECT intScheduleColumnId = 631, strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726655
	UNION ALL SELECT intScheduleColumnId = 632, strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726656
	UNION ALL SELECT intScheduleColumnId = 633, strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726657
	UNION ALL SELECT intScheduleColumnId = 634, strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726658
	UNION ALL SELECT intScheduleColumnId = 635, strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726659
	UNION ALL SELECT intScheduleColumnId = 636, strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726660
	UNION ALL SELECT intScheduleColumnId = 637, strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726661
	UNION ALL SELECT intScheduleColumnId = 638, strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726662
	UNION ALL SELECT intScheduleColumnId = 639, strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726663
	UNION ALL SELECT intScheduleColumnId = 640, strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726664
	UNION ALL SELECT intScheduleColumnId = 641, strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726665
	UNION ALL SELECT intScheduleColumnId = 642, strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726666
	UNION ALL SELECT intScheduleColumnId = 643, strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726667
	UNION ALL SELECT intScheduleColumnId = 644, strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726668
	UNION ALL SELECT intScheduleColumnId = 645, strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726669
	UNION ALL SELECT intScheduleColumnId = 646, strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726670
	UNION ALL SELECT intScheduleColumnId = 647, strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726671
	UNION ALL SELECT intScheduleColumnId = 648, strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726672
	UNION ALL SELECT intScheduleColumnId = 649, strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726673
	UNION ALL SELECT intScheduleColumnId = 650, strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726674
	UNION ALL SELECT intScheduleColumnId = 651, strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726675
	UNION ALL SELECT intScheduleColumnId = 652, strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726676
	UNION ALL SELECT intScheduleColumnId = 653, strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726677
	UNION ALL SELECT intScheduleColumnId = 654, strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726678
	UNION ALL SELECT intScheduleColumnId = 655, strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726679
	UNION ALL SELECT intScheduleColumnId = 656, strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726680
	UNION ALL SELECT intScheduleColumnId = 657, strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726681
	UNION ALL SELECT intScheduleColumnId = 658, strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726682
	UNION ALL SELECT intScheduleColumnId = 659, strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726683
	UNION ALL SELECT intScheduleColumnId = 660, strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726684
	UNION ALL SELECT intScheduleColumnId = 661, strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726685
	UNION ALL SELECT intScheduleColumnId = 662, strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726686
	UNION ALL SELECT intScheduleColumnId = 663, strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726687
	UNION ALL SELECT intScheduleColumnId = 664, strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726688
	UNION ALL SELECT intScheduleColumnId = 665, strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726689
	UNION ALL SELECT intScheduleColumnId = 666, strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726690
	UNION ALL SELECT intScheduleColumnId = 667, strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726691
	UNION ALL SELECT intScheduleColumnId = 668, strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726692
	UNION ALL SELECT intScheduleColumnId = 669, strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726693
	UNION ALL SELECT intScheduleColumnId = 670, strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726694
	UNION ALL SELECT intScheduleColumnId = 671, strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726695
	UNION ALL SELECT intScheduleColumnId = 672, strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726696
	UNION ALL SELECT intScheduleColumnId = 673, strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726697
	UNION ALL SELECT intScheduleColumnId = 674, strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726698
	UNION ALL SELECT intScheduleColumnId = 675, strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726699
	UNION ALL SELECT intScheduleColumnId = 676, strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726700
	UNION ALL SELECT intScheduleColumnId = 677, strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726701
	UNION ALL SELECT intScheduleColumnId = 678, strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726702
	UNION ALL SELECT intScheduleColumnId = 679, strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726703
	UNION ALL SELECT intScheduleColumnId = 680, strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726704

	--MFT-1704
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Gasoline' , strColumn = 'strScheduleCode'        , strCaption = 'Schedule Code' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726705 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Gasoline' , strColumn = 'strProductCode'        , strCaption = 'Product Code' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726706 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Gasoline' , strColumn = 'strTransporterName'        , strCaption = 'Transporter Name' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726707 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Gasoline' , strColumn = 'strTransporterFederalTaxId'        , strCaption = 'Transporter FEIN' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726708 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Gasoline' , strColumn = 'strTerminalControlNumber'        , strCaption = 'Terminal Code' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726709 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Gasoline' , strColumn = 'strConsignorName'        , strCaption = 'Hiring Company Name' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726710 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Gasoline' , strColumn = 'strConsignorFederalTaxId'        , strCaption = 'Hiring Company FEIN' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726711 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Gasoline' , strColumn = 'strVendorName'        , strCaption = 'Seller Name' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726712 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Gasoline' , strColumn = 'strVendorFederalTaxId'        , strCaption = 'Seller FEIN' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726713 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Gasoline' , strColumn = 'strTransportationMode'        , strCaption = 'Mode' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726714 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Gasoline' , strColumn = 'strOriginCity'        , strCaption = 'Origin City' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726715 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Gasoline' , strColumn = 'strOriginState'        , strCaption = 'Origin State' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726716 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Gasoline' , strColumn = 'strCustomerName'        , strCaption = 'Purchaser Name' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726717 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Gasoline' , strColumn = 'strDestinationCity'        , strCaption = 'Destination City' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726718 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Gasoline' , strColumn = 'strDestinationState'        , strCaption = 'Destination State' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726719 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Gasoline' , strColumn = 'strCustomerFederalTaxId'        , strCaption = 'Purchaser FEIN' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726720 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Gasoline' , strColumn = 'dtmDate'        , strCaption = 'Date' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726721 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Gasoline' , strColumn = 'strBillOfLading'        , strCaption = 'Doc Num' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726722 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Gasoline' , strColumn = 'dblGross'        , strCaption = 'Gross Gals' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726723 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Gasoline' , strColumn = 'dblNet'        , strCaption = 'Net Gals' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726724 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Special Fuels' , strColumn = 'strScheduleCode'        , strCaption = 'Schedule Code' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726725 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Special Fuels' , strColumn = 'strProductCode'        , strCaption = 'Product Code' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726726 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Special Fuels' , strColumn = 'strTransporterName'        , strCaption = 'Transporter Name' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726727 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Special Fuels' , strColumn = 'strTransporterFederalTaxId'        , strCaption = 'Transporter FEIN' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726728 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Special Fuels' , strColumn = 'strTerminalControlNumber'        , strCaption = 'Terminal Code' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726729 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Special Fuels' , strColumn = 'strConsignorName'        , strCaption = 'Hiring Company Name' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726730 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Special Fuels' , strColumn = 'strConsignorFederalTaxId'        , strCaption = 'Hiring Company FEIN' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726731 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Special Fuels' , strColumn = 'strVendorName'        , strCaption = 'Seller Name' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726732 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Special Fuels' , strColumn = 'strVendorFederalTaxId'        , strCaption = 'Seller FEIN' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726733 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Special Fuels' , strColumn = 'strTransportationMode'        , strCaption = 'Mode' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726734 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Special Fuels' , strColumn = 'strOriginCity'        , strCaption = 'Origin City' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726735 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Special Fuels' , strColumn = 'strOriginState'        , strCaption = 'Origin State' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726736 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Special Fuels' , strColumn = 'strCustomerName'        , strCaption = 'Purchaser Name' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726737 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Special Fuels' , strColumn = 'strDestinationCity'        , strCaption = 'Destination City' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726738 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Special Fuels' , strColumn = 'strDestinationState'        , strCaption = 'Destination State' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726739 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Special Fuels' , strColumn = 'strCustomerFederalTaxId'        , strCaption = 'Purchaser FEIN' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726740 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Special Fuels' , strColumn = 'dtmDate'        , strCaption = 'Date' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726741 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Special Fuels' , strColumn = 'strBillOfLading'        , strCaption = 'Doc Num' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726742 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Special Fuels' , strColumn = 'dblGross'        , strCaption = 'Gross Gals' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726743 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14' ,strType = 'Special Fuels' , strColumn = 'dblNet'        , strCaption = 'Net Gals' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726744 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Gasoline' , strColumn = 'strScheduleCode'        , strCaption = 'Schedule Code' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726745 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Gasoline' , strColumn = 'strProductCode'        , strCaption = 'Product Code' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726746 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Gasoline' , strColumn = 'strTransporterName'        , strCaption = 'Transporter Name' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726747 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Gasoline' , strColumn = 'strTransporterFederalTaxId'        , strCaption = 'Transporter FEIN' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726748 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Gasoline' , strColumn = 'strTerminalControlNumber'        , strCaption = 'Terminal Code' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726749 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Gasoline' , strColumn = 'strConsignorName'        , strCaption = 'Hiring Company Name' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726750 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Gasoline' , strColumn = 'strConsignorFederalTaxId'        , strCaption = 'Hiring Company FEIN' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726751 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Gasoline' , strColumn = 'strVendorName'        , strCaption = 'Seller Name' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726752 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Gasoline' , strColumn = 'strVendorFederalTaxId'        , strCaption = 'Seller FEIN' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726753 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Gasoline' , strColumn = 'strTransportationMode'        , strCaption = 'Mode' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726754 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Gasoline' , strColumn = 'strOriginCity'        , strCaption = 'Origin City' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726755 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Gasoline' , strColumn = 'strOriginState'        , strCaption = 'Origin State' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726756 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Gasoline' , strColumn = 'strCustomerName'        , strCaption = 'Purchaser Name' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726757 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Gasoline' , strColumn = 'strDestinationCity'        , strCaption = 'Destination City' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726758 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Gasoline' , strColumn = 'strDestinationState'        , strCaption = 'Destination State' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726759 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Gasoline' , strColumn = 'strCustomerFederalTaxId'        , strCaption = 'Purchaser FEIN' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726760 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Gasoline' , strColumn = 'dtmDate'        , strCaption = 'Date' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726761 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Gasoline' , strColumn = 'strBillOfLading'        , strCaption = 'Doc Num' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726762 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Gasoline' , strColumn = 'dblGross'        , strCaption = 'Gross Gals' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726763 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Gasoline' , strColumn = 'dblNet'        , strCaption = 'Net Gals' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726764 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Special Fuels' , strColumn = 'strScheduleCode'        , strCaption = 'Schedule Code' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726765 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Special Fuels' , strColumn = 'strProductCode'        , strCaption = 'Product Code' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726766 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Special Fuels' , strColumn = 'strTransporterName'        , strCaption = 'Transporter Name' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726767 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Special Fuels' , strColumn = 'strTransporterFederalTaxId'        , strCaption = 'Transporter FEIN' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726768 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Special Fuels' , strColumn = 'strTerminalControlNumber'        , strCaption = 'Terminal Code' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726769 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Special Fuels' , strColumn = 'strConsignorName'        , strCaption = 'Hiring Company Name' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726770 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Special Fuels' , strColumn = 'strConsignorFederalTaxId'        , strCaption = 'Hiring Company FEIN' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726771 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Special Fuels' , strColumn = 'strVendorName'        , strCaption = 'Seller Name' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726772 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Special Fuels' , strColumn = 'strVendorFederalTaxId'        , strCaption = 'Seller FEIN' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726773 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Special Fuels' , strColumn = 'strTransportationMode'        , strCaption = 'Mode' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726774 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Special Fuels' , strColumn = 'strOriginCity'        , strCaption = 'Origin City' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726775 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Special Fuels' , strColumn = 'strOriginState'        , strCaption = 'Origin State' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726776 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Special Fuels' , strColumn = 'strCustomerName'        , strCaption = 'Purchaser Name' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726777 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Special Fuels' , strColumn = 'strDestinationCity'        , strCaption = 'Destination City' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726778 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Special Fuels' , strColumn = 'strDestinationState'        , strCaption = 'Destination State' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726779 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Special Fuels' , strColumn = 'strCustomerFederalTaxId'        , strCaption = 'Purchaser FEIN' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726780 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Special Fuels' , strColumn = 'dtmDate'        , strCaption = 'Date' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726781 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Special Fuels' , strColumn = 'strBillOfLading'        , strCaption = 'Doc Num' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726782 
	UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Special Fuels' , strColumn = 'dblGross'        , strCaption = 'Gross Gals' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726783 
    UNION ALL SELECT intScheduleColumnId = 0 , strFormCode = '72A099' , strScheduleCode = '14_C' ,strType = 'Special Fuels' , strColumn = 'dblNet'        , strCaption = 'Net Gals' , strFormat = '' , strFooter = 'No'        , intWidth = 0, ysnFromConfiguration = 0 , intMasterId = 1726784 


	UNION ALL SELECT intScheduleColumnId = 92, strFormCode = '72A138', strScheduleCode = '1_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726785
	UNION ALL SELECT intScheduleColumnId = 93, strFormCode = '72A138', strScheduleCode = '1_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726786
	UNION ALL SELECT intScheduleColumnId = 94, strFormCode = '72A138', strScheduleCode = '1_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726787
	UNION ALL SELECT intScheduleColumnId = 95, strFormCode = '72A138', strScheduleCode = '1_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726788
	UNION ALL SELECT intScheduleColumnId = 96, strFormCode = '72A138', strScheduleCode = '1_TR', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726789
	UNION ALL SELECT intScheduleColumnId = 97, strFormCode = '72A138', strScheduleCode = '1_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726790
	UNION ALL SELECT intScheduleColumnId = 98, strFormCode = '72A138', strScheduleCode = '1_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726791
	UNION ALL SELECT intScheduleColumnId = 99, strFormCode = '72A138', strScheduleCode = '1_TR', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726792
	UNION ALL SELECT intScheduleColumnId = 100, strFormCode = '72A138', strScheduleCode = '1_TR', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726793
	UNION ALL SELECT intScheduleColumnId = 101, strFormCode = '72A138', strScheduleCode = '1_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726794
	UNION ALL SELECT intScheduleColumnId = 102, strFormCode = '72A138', strScheduleCode = '1_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726795
	UNION ALL SELECT intScheduleColumnId = 103, strFormCode = '72A138', strScheduleCode = '1_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726796
	UNION ALL SELECT intScheduleColumnId = 104, strFormCode = '72A138', strScheduleCode = '1_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726797
	UNION ALL SELECT intScheduleColumnId = 105, strFormCode = '72A138', strScheduleCode = '2_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726798
	UNION ALL SELECT intScheduleColumnId = 106, strFormCode = '72A138', strScheduleCode = '2_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726799
	UNION ALL SELECT intScheduleColumnId = 107, strFormCode = '72A138', strScheduleCode = '2_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726800
	UNION ALL SELECT intScheduleColumnId = 108, strFormCode = '72A138', strScheduleCode = '2_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726801
	UNION ALL SELECT intScheduleColumnId = 109, strFormCode = '72A138', strScheduleCode = '2_TR', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726802
	UNION ALL SELECT intScheduleColumnId = 110, strFormCode = '72A138', strScheduleCode = '2_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726803
	UNION ALL SELECT intScheduleColumnId = 111, strFormCode = '72A138', strScheduleCode = '2_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726804
	UNION ALL SELECT intScheduleColumnId = 112, strFormCode = '72A138', strScheduleCode = '2_TR', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726805
	UNION ALL SELECT intScheduleColumnId = 113, strFormCode = '72A138', strScheduleCode = '2_TR', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726806
	UNION ALL SELECT intScheduleColumnId = 114, strFormCode = '72A138', strScheduleCode = '2_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726807
	UNION ALL SELECT intScheduleColumnId = 115, strFormCode = '72A138', strScheduleCode = '2_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726808
	UNION ALL SELECT intScheduleColumnId = 116, strFormCode = '72A138', strScheduleCode = '2_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726809
	UNION ALL SELECT intScheduleColumnId = 117, strFormCode = '72A138', strScheduleCode = '2_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726810
	UNION ALL SELECT intScheduleColumnId = 118, strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726811
	UNION ALL SELECT intScheduleColumnId = 119, strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726812
	UNION ALL SELECT intScheduleColumnId = 120, strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726813
	UNION ALL SELECT intScheduleColumnId = 121, strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726814
	UNION ALL SELECT intScheduleColumnId = 122, strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726815
	UNION ALL SELECT intScheduleColumnId = 123, strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726816
	UNION ALL SELECT intScheduleColumnId = 124, strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726817
	UNION ALL SELECT intScheduleColumnId = 125, strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726818
	UNION ALL SELECT intScheduleColumnId = 126, strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726819
	UNION ALL SELECT intScheduleColumnId = 127, strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726820
	UNION ALL SELECT intScheduleColumnId = 128, strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726821
	UNION ALL SELECT intScheduleColumnId = 129, strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726822
	UNION ALL SELECT intScheduleColumnId = 130, strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726823
	UNION ALL SELECT intScheduleColumnId = 131, strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726824
	UNION ALL SELECT intScheduleColumnId = 132, strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726825
	UNION ALL SELECT intScheduleColumnId = 133, strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726826
	UNION ALL SELECT intScheduleColumnId = 134, strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726827
	UNION ALL SELECT intScheduleColumnId = 135, strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726828
	UNION ALL SELECT intScheduleColumnId = 136, strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726829
	UNION ALL SELECT intScheduleColumnId = 137, strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726830
	UNION ALL SELECT intScheduleColumnId = 138, strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726831
	UNION ALL SELECT intScheduleColumnId = 139, strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726832
	UNION ALL SELECT intScheduleColumnId = 140, strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726833
	UNION ALL SELECT intScheduleColumnId = 141, strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726834
	UNION ALL SELECT intScheduleColumnId = 142, strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726835
	UNION ALL SELECT intScheduleColumnId = 143, strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726836
	UNION ALL SELECT intScheduleColumnId = 144, strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726837
	UNION ALL SELECT intScheduleColumnId = 145, strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726838
	UNION ALL SELECT intScheduleColumnId = 146, strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726839
	UNION ALL SELECT intScheduleColumnId = 147, strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726840
	UNION ALL SELECT intScheduleColumnId = 148, strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726841
	UNION ALL SELECT intScheduleColumnId = 149, strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726842
	UNION ALL SELECT intScheduleColumnId = 150, strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726843
	UNION ALL SELECT intScheduleColumnId = 151, strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726844
	UNION ALL SELECT intScheduleColumnId = 152, strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726845
	UNION ALL SELECT intScheduleColumnId = 153, strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726846
	UNION ALL SELECT intScheduleColumnId = 154, strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726847
	UNION ALL SELECT intScheduleColumnId = 155, strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726848
	UNION ALL SELECT intScheduleColumnId = 156, strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726849
	UNION ALL SELECT intScheduleColumnId = 157, strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726850
	UNION ALL SELECT intScheduleColumnId = 158, strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726851
	UNION ALL SELECT intScheduleColumnId = 159, strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726852
	UNION ALL SELECT intScheduleColumnId = 160, strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726853
	UNION ALL SELECT intScheduleColumnId = 161, strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726854
	UNION ALL SELECT intScheduleColumnId = 162, strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726855
	UNION ALL SELECT intScheduleColumnId = 163, strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726856
	UNION ALL SELECT intScheduleColumnId = 164, strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726857
	UNION ALL SELECT intScheduleColumnId = 165, strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726858
	UNION ALL SELECT intScheduleColumnId = 166, strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726859
	UNION ALL SELECT intScheduleColumnId = 167, strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726860
	UNION ALL SELECT intScheduleColumnId = 168, strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726861
	UNION ALL SELECT intScheduleColumnId = 169, strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726862
	UNION ALL SELECT intScheduleColumnId = 170, strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726863
	UNION ALL SELECT intScheduleColumnId = 171, strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726864
	UNION ALL SELECT intScheduleColumnId = 172, strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726865
	UNION ALL SELECT intScheduleColumnId = 173, strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726866
	UNION ALL SELECT intScheduleColumnId = 174, strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726867
	UNION ALL SELECT intScheduleColumnId = 175, strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726868
	UNION ALL SELECT intScheduleColumnId = 176, strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726869
	UNION ALL SELECT intScheduleColumnId = 177, strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726870
	UNION ALL SELECT intScheduleColumnId = 178, strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726871
	UNION ALL SELECT intScheduleColumnId = 179, strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726872
	UNION ALL SELECT intScheduleColumnId = 180, strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726873
	UNION ALL SELECT intScheduleColumnId = 181, strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726874
	UNION ALL SELECT intScheduleColumnId = 182, strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726875
	UNION ALL SELECT intScheduleColumnId = 183, strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726876
	UNION ALL SELECT intScheduleColumnId = 184, strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726877
	UNION ALL SELECT intScheduleColumnId = 185, strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726878
	UNION ALL SELECT intScheduleColumnId = 186, strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726879
	UNION ALL SELECT intScheduleColumnId = 187, strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726880
	UNION ALL SELECT intScheduleColumnId = 188, strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726881
	UNION ALL SELECT intScheduleColumnId = 189, strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726882
	UNION ALL SELECT intScheduleColumnId = 190, strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726883
	UNION ALL SELECT intScheduleColumnId = 191, strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726884
	UNION ALL SELECT intScheduleColumnId = 192, strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726885
	UNION ALL SELECT intScheduleColumnId = 193, strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726886
	UNION ALL SELECT intScheduleColumnId = 194, strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726887
	UNION ALL SELECT intScheduleColumnId = 195, strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726888
	UNION ALL SELECT intScheduleColumnId = 196, strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726889
	UNION ALL SELECT intScheduleColumnId = 197, strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726890
	UNION ALL SELECT intScheduleColumnId = 198, strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726891
	UNION ALL SELECT intScheduleColumnId = 199, strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726892
	UNION ALL SELECT intScheduleColumnId = 200, strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726893
	UNION ALL SELECT intScheduleColumnId = 201, strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726894
	UNION ALL SELECT intScheduleColumnId = 202, strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726895
	UNION ALL SELECT intScheduleColumnId = 203, strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726896
	UNION ALL SELECT intScheduleColumnId = 204, strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726897
	UNION ALL SELECT intScheduleColumnId = 205, strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726898
	UNION ALL SELECT intScheduleColumnId = 206, strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726899
	UNION ALL SELECT intScheduleColumnId = 207, strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726900
	UNION ALL SELECT intScheduleColumnId = 208, strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726901
	UNION ALL SELECT intScheduleColumnId = 209, strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726902
	UNION ALL SELECT intScheduleColumnId = 210, strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726903
	UNION ALL SELECT intScheduleColumnId = 211, strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726904
	UNION ALL SELECT intScheduleColumnId = 212, strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726905
	UNION ALL SELECT intScheduleColumnId = 213, strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726906
	UNION ALL SELECT intScheduleColumnId = 214, strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726907
	UNION ALL SELECT intScheduleColumnId = 215, strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726908
	UNION ALL SELECT intScheduleColumnId = 216, strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726909
	UNION ALL SELECT intScheduleColumnId = 217, strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726910
	UNION ALL SELECT intScheduleColumnId = 218, strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726911
	UNION ALL SELECT intScheduleColumnId = 219, strFormCode = '72A138', strScheduleCode = '6_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726912
	UNION ALL SELECT intScheduleColumnId = 220, strFormCode = '72A138', strScheduleCode = '6_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726913
	UNION ALL SELECT intScheduleColumnId = 221, strFormCode = '72A138', strScheduleCode = '6_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726914
	UNION ALL SELECT intScheduleColumnId = 222, strFormCode = '72A138', strScheduleCode = '6_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726915
	UNION ALL SELECT intScheduleColumnId = 223, strFormCode = '72A138', strScheduleCode = '6_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726916
	UNION ALL SELECT intScheduleColumnId = 224, strFormCode = '72A138', strScheduleCode = '6_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726917
	UNION ALL SELECT intScheduleColumnId = 225, strFormCode = '72A138', strScheduleCode = '6_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726918
	UNION ALL SELECT intScheduleColumnId = 226, strFormCode = '72A138', strScheduleCode = '6_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726919
	UNION ALL SELECT intScheduleColumnId = 227, strFormCode = '72A138', strScheduleCode = '6_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726920
	UNION ALL SELECT intScheduleColumnId = 228, strFormCode = '72A138', strScheduleCode = '6_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726921
	UNION ALL SELECT intScheduleColumnId = 229, strFormCode = '72A138', strScheduleCode = '6_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726922
	UNION ALL SELECT intScheduleColumnId = 230, strFormCode = '72A138', strScheduleCode = '6_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726923
	UNION ALL SELECT intScheduleColumnId = 231, strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726924
	UNION ALL SELECT intScheduleColumnId = 232, strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726925
	UNION ALL SELECT intScheduleColumnId = 233, strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726926
	UNION ALL SELECT intScheduleColumnId = 234, strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726927
	UNION ALL SELECT intScheduleColumnId = 235, strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726928
	UNION ALL SELECT intScheduleColumnId = 236, strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726929
	UNION ALL SELECT intScheduleColumnId = 237, strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726930
	UNION ALL SELECT intScheduleColumnId = 238, strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726931
	UNION ALL SELECT intScheduleColumnId = 239, strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726932
	UNION ALL SELECT intScheduleColumnId = 240, strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726933
	UNION ALL SELECT intScheduleColumnId = 241, strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726934
	UNION ALL SELECT intScheduleColumnId = 242, strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726935
	UNION ALL SELECT intScheduleColumnId = 243, strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726936
	UNION ALL SELECT intScheduleColumnId = 244, strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726937
	UNION ALL SELECT intScheduleColumnId = 245, strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726938
	UNION ALL SELECT intScheduleColumnId = 246, strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726939
	UNION ALL SELECT intScheduleColumnId = 247, strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726940
	UNION ALL SELECT intScheduleColumnId = 248, strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726941
	UNION ALL SELECT intScheduleColumnId = 249, strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726942
	UNION ALL SELECT intScheduleColumnId = 250, strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726943
	UNION ALL SELECT intScheduleColumnId = 251, strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726944
	UNION ALL SELECT intScheduleColumnId = 252, strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726945
	UNION ALL SELECT intScheduleColumnId = 253, strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726946
	UNION ALL SELECT intScheduleColumnId = 254, strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726947
	UNION ALL SELECT intScheduleColumnId = 255, strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726948
	UNION ALL SELECT intScheduleColumnId = 256, strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726949
	UNION ALL SELECT intScheduleColumnId = 257, strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726950
	UNION ALL SELECT intScheduleColumnId = 258, strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726951
	UNION ALL SELECT intScheduleColumnId = 259, strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726952
	UNION ALL SELECT intScheduleColumnId = 260, strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726953
	UNION ALL SELECT intScheduleColumnId = 261, strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726954
	UNION ALL SELECT intScheduleColumnId = 262, strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726955
	UNION ALL SELECT intScheduleColumnId = 263, strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726956
	UNION ALL SELECT intScheduleColumnId = 264, strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726957
	UNION ALL SELECT intScheduleColumnId = 265, strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726958
	UNION ALL SELECT intScheduleColumnId = 266, strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726959
	UNION ALL SELECT intScheduleColumnId = 267, strFormCode = '72A138', strScheduleCode = '8_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726960
	UNION ALL SELECT intScheduleColumnId = 268, strFormCode = '72A138', strScheduleCode = '8_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726961
	UNION ALL SELECT intScheduleColumnId = 269, strFormCode = '72A138', strScheduleCode = '8_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726962
	UNION ALL SELECT intScheduleColumnId = 270, strFormCode = '72A138', strScheduleCode = '8_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726963
	UNION ALL SELECT intScheduleColumnId = 271, strFormCode = '72A138', strScheduleCode = '8_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726964
	UNION ALL SELECT intScheduleColumnId = 272, strFormCode = '72A138', strScheduleCode = '8_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726965
	UNION ALL SELECT intScheduleColumnId = 273, strFormCode = '72A138', strScheduleCode = '8_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,	intMasterId = 1726966
	UNION ALL SELECT intScheduleColumnId = 274, strFormCode = '72A138', strScheduleCode = '8_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                          	intMasterId = 1726967
	UNION ALL SELECT intScheduleColumnId = 275, strFormCode = '72A138', strScheduleCode = '8_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                        	intMasterId = 1726968
	UNION ALL SELECT intScheduleColumnId = 276, strFormCode = '72A138', strScheduleCode = '8_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                 	intMasterId = 1726969
	UNION ALL SELECT intScheduleColumnId = 277, strFormCode = '72A138', strScheduleCode = '8_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                             	intMasterId = 1726970
	UNION ALL SELECT intScheduleColumnId = 278, strFormCode = '72A138', strScheduleCode = '8_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                         	intMasterId = 1726971
	UNION ALL SELECT intScheduleColumnId = 279, strFormCode = '72A138', strScheduleCode = '9_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                 	intMasterId = 1726972
	UNION ALL SELECT intScheduleColumnId = 280, strFormCode = '72A138', strScheduleCode = '9_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                             	intMasterId = 1726973
	UNION ALL SELECT intScheduleColumnId = 281, strFormCode = '72A138', strScheduleCode = '9_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                     	intMasterId = 1726974
	UNION ALL SELECT intScheduleColumnId = 282, strFormCode = '72A138', strScheduleCode = '9_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                  	intMasterId = 1726975
	UNION ALL SELECT intScheduleColumnId = 283, strFormCode = '72A138', strScheduleCode = '9_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                 	intMasterId = 1726976
	UNION ALL SELECT intScheduleColumnId = 284, strFormCode = '72A138', strScheduleCode = '9_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                       	intMasterId = 1726977
	UNION ALL SELECT intScheduleColumnId = 285, strFormCode = '72A138', strScheduleCode = '9_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                  	intMasterId = 1726978
	UNION ALL SELECT intScheduleColumnId = 286, strFormCode = '72A138', strScheduleCode = '9_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                          	intMasterId = 1726979
	UNION ALL SELECT intScheduleColumnId = 287, strFormCode = '72A138', strScheduleCode = '9_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                        	intMasterId = 1726980
	UNION ALL SELECT intScheduleColumnId = 288, strFormCode = '72A138', strScheduleCode = '9_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                 	intMasterId = 1726981
	UNION ALL SELECT intScheduleColumnId = 289, strFormCode = '72A138', strScheduleCode = '9_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                             	intMasterId = 1726982
	UNION ALL SELECT intScheduleColumnId = 290, strFormCode = '72A138', strScheduleCode = '9_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                         	intMasterId = 1726983
	UNION ALL SELECT intScheduleColumnId = 291, strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1726984
	UNION ALL SELECT intScheduleColumnId = 292, strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                           	intMasterId = 1726985
	UNION ALL SELECT intScheduleColumnId = 293, strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                   	intMasterId = 1726986
	UNION ALL SELECT intScheduleColumnId = 294, strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                	intMasterId = 1726987
	UNION ALL SELECT intScheduleColumnId = 295, strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1726988
	UNION ALL SELECT intScheduleColumnId = 296, strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                     	intMasterId = 1726989
	UNION ALL SELECT intScheduleColumnId = 297, strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                	intMasterId = 1726990
	UNION ALL SELECT intScheduleColumnId = 298, strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                        	intMasterId = 1726991
	UNION ALL SELECT intScheduleColumnId = 299, strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                      	intMasterId = 1726992
	UNION ALL SELECT intScheduleColumnId = 300, strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1726993
	UNION ALL SELECT intScheduleColumnId = 301, strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                           	intMasterId = 1726994
	UNION ALL SELECT intScheduleColumnId = 302, strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                       	intMasterId = 1726995
	UNION ALL SELECT intScheduleColumnId = 303, strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1726996
	UNION ALL SELECT intScheduleColumnId = 304, strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                           	intMasterId = 1726997
	UNION ALL SELECT intScheduleColumnId = 305, strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                   	intMasterId = 1726998
	UNION ALL SELECT intScheduleColumnId = 306, strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                	intMasterId = 1726999
	UNION ALL SELECT intScheduleColumnId = 307, strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727000
	UNION ALL SELECT intScheduleColumnId = 308, strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                     	intMasterId = 1727001
	UNION ALL SELECT intScheduleColumnId = 309, strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                	intMasterId = 1727002
	UNION ALL SELECT intScheduleColumnId = 310, strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                        	intMasterId = 1727003
	UNION ALL SELECT intScheduleColumnId = 311, strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                      	intMasterId = 1727004
	UNION ALL SELECT intScheduleColumnId = 312, strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727005
	UNION ALL SELECT intScheduleColumnId = 313, strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                           	intMasterId = 1727006
	UNION ALL SELECT intScheduleColumnId = 314, strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                       	intMasterId = 1727007
	UNION ALL SELECT intScheduleColumnId = 315, strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727008
	UNION ALL SELECT intScheduleColumnId = 316, strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                           	intMasterId = 1727009
	UNION ALL SELECT intScheduleColumnId = 317, strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                   	intMasterId = 1727010
	UNION ALL SELECT intScheduleColumnId = 318, strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                	intMasterId = 1727011
	UNION ALL SELECT intScheduleColumnId = 319, strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727012
	UNION ALL SELECT intScheduleColumnId = 320, strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                     	intMasterId = 1727013
	UNION ALL SELECT intScheduleColumnId = 321, strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                	intMasterId = 1727014
	UNION ALL SELECT intScheduleColumnId = 322, strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                        	intMasterId = 1727015
	UNION ALL SELECT intScheduleColumnId = 323, strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                      	intMasterId = 1727016
	UNION ALL SELECT intScheduleColumnId = 324, strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727017
	UNION ALL SELECT intScheduleColumnId = 325, strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                           	intMasterId = 1727018
	UNION ALL SELECT intScheduleColumnId = 326, strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                       	intMasterId = 1727019
	UNION ALL SELECT intScheduleColumnId = 327, strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727020
	UNION ALL SELECT intScheduleColumnId = 328, strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                           	intMasterId = 1727021
	UNION ALL SELECT intScheduleColumnId = 329, strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                   	intMasterId = 1727022
	UNION ALL SELECT intScheduleColumnId = 330, strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                	intMasterId = 1727023
	UNION ALL SELECT intScheduleColumnId = 331, strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727024
	UNION ALL SELECT intScheduleColumnId = 332, strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                     	intMasterId = 1727025
	UNION ALL SELECT intScheduleColumnId = 333, strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                	intMasterId = 1727026
	UNION ALL SELECT intScheduleColumnId = 334, strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                        	intMasterId = 1727027
	UNION ALL SELECT intScheduleColumnId = 335, strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                      	intMasterId = 1727028
	UNION ALL SELECT intScheduleColumnId = 336, strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727029
	UNION ALL SELECT intScheduleColumnId = 337, strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                           	intMasterId = 1727030
	UNION ALL SELECT intScheduleColumnId = 338, strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                       	intMasterId = 1727031
	UNION ALL SELECT intScheduleColumnId = 339, strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727032
	UNION ALL SELECT intScheduleColumnId = 340, strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                           	intMasterId = 1727033
	UNION ALL SELECT intScheduleColumnId = 341, strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                   	intMasterId = 1727034
	UNION ALL SELECT intScheduleColumnId = 342, strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                	intMasterId = 1727035
	UNION ALL SELECT intScheduleColumnId = 343, strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727036
	UNION ALL SELECT intScheduleColumnId = 344, strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                     	intMasterId = 1727037
	UNION ALL SELECT intScheduleColumnId = 345, strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                	intMasterId = 1727038
	UNION ALL SELECT intScheduleColumnId = 346, strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                        	intMasterId = 1727039
	UNION ALL SELECT intScheduleColumnId = 347, strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                      	intMasterId = 1727040
	UNION ALL SELECT intScheduleColumnId = 348, strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727041
	UNION ALL SELECT intScheduleColumnId = 349, strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                           	intMasterId = 1727042
	UNION ALL SELECT intScheduleColumnId = 350, strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                       	intMasterId = 1727043

	UNION ALL SELECT intScheduleColumnId = 498, strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727044
	UNION ALL SELECT intScheduleColumnId = 499, strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                           	intMasterId = 1727045
	UNION ALL SELECT intScheduleColumnId = 500, strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                   	intMasterId = 1727046
	UNION ALL SELECT intScheduleColumnId = 501, strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                	intMasterId = 1727047
	UNION ALL SELECT intScheduleColumnId = 502, strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                         	intMasterId = 1727048
	UNION ALL SELECT intScheduleColumnId = 503, strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727049
	UNION ALL SELECT intScheduleColumnId = 504, strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                     	intMasterId = 1727050
	UNION ALL SELECT intScheduleColumnId = 505, strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                 	intMasterId = 1727051
	UNION ALL SELECT intScheduleColumnId = 506, strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                         	intMasterId = 1727052
	UNION ALL SELECT intScheduleColumnId = 507, strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                      	intMasterId = 1727053
	UNION ALL SELECT intScheduleColumnId = 508, strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727054
	UNION ALL SELECT intScheduleColumnId = 509, strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                           	intMasterId = 1727055
	UNION ALL SELECT intScheduleColumnId = 510, strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                    	intMasterId = 1727056
	UNION ALL SELECT intScheduleColumnId = 511, strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727057
	UNION ALL SELECT intScheduleColumnId = 512, strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                           	intMasterId = 1727058
	UNION ALL SELECT intScheduleColumnId = 513, strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                   	intMasterId = 1727059
	UNION ALL SELECT intScheduleColumnId = 514, strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                	intMasterId = 1727060
	UNION ALL SELECT intScheduleColumnId = 515, strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                         	intMasterId = 1727061
	UNION ALL SELECT intScheduleColumnId = 516, strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727062
	UNION ALL SELECT intScheduleColumnId = 517, strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                     	intMasterId = 1727063
	UNION ALL SELECT intScheduleColumnId = 518, strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                 	intMasterId = 1727064
	UNION ALL SELECT intScheduleColumnId = 519, strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                         	intMasterId = 1727065
	UNION ALL SELECT intScheduleColumnId = 520, strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                      	intMasterId = 1727066
	UNION ALL SELECT intScheduleColumnId = 521, strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727067
	UNION ALL SELECT intScheduleColumnId = 522, strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                           	intMasterId = 1727068
	UNION ALL SELECT intScheduleColumnId = 523, strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                    	intMasterId = 1727069
	UNION ALL SELECT intScheduleColumnId = 524, strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727070
	UNION ALL SELECT intScheduleColumnId = 525, strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                           	intMasterId = 1727071
	UNION ALL SELECT intScheduleColumnId = 526, strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                   	intMasterId = 1727072
	UNION ALL SELECT intScheduleColumnId = 527, strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                	intMasterId = 1727073
	UNION ALL SELECT intScheduleColumnId = 528, strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                         	intMasterId = 1727074
	UNION ALL SELECT intScheduleColumnId = 529, strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727075
	UNION ALL SELECT intScheduleColumnId = 530, strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                     	intMasterId = 1727076
	UNION ALL SELECT intScheduleColumnId = 531, strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                 	intMasterId = 1727077
	UNION ALL SELECT intScheduleColumnId = 532, strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                         	intMasterId = 1727078
	UNION ALL SELECT intScheduleColumnId = 533, strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                      	intMasterId = 1727079
	UNION ALL SELECT intScheduleColumnId = 534, strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727080
	UNION ALL SELECT intScheduleColumnId = 535, strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                           	intMasterId = 1727081
	UNION ALL SELECT intScheduleColumnId = 536, strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                    	intMasterId = 1727082
	
	UNION ALL SELECT intScheduleColumnId = 609, strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                              	intMasterId = 1727083
	UNION ALL SELECT intScheduleColumnId = 610, strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                          	intMasterId = 1727084
	UNION ALL SELECT intScheduleColumnId = 611, strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                  	intMasterId = 1727085
	UNION ALL SELECT intScheduleColumnId = 612, strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727086
	UNION ALL SELECT intScheduleColumnId = 613, strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                              	intMasterId = 1727087
	UNION ALL SELECT intScheduleColumnId = 614, strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                    	intMasterId = 1727088
	UNION ALL SELECT intScheduleColumnId = 615, strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727089
	UNION ALL SELECT intScheduleColumnId = 616, strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                       	intMasterId = 1727090
	UNION ALL SELECT intScheduleColumnId = 617, strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                     	intMasterId = 1727091
	UNION ALL SELECT intScheduleColumnId = 618, strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                              	intMasterId = 1727092
	UNION ALL SELECT intScheduleColumnId = 619, strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                          	intMasterId = 1727093
	UNION ALL SELECT intScheduleColumnId = 620, strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                   	intMasterId = 1727094
	UNION ALL SELECT intScheduleColumnId = 621, strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                              	intMasterId = 1727095
	UNION ALL SELECT intScheduleColumnId = 622, strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                          	intMasterId = 1727096
	UNION ALL SELECT intScheduleColumnId = 623, strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                  	intMasterId = 1727097
	UNION ALL SELECT intScheduleColumnId = 624, strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727098
	UNION ALL SELECT intScheduleColumnId = 625, strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                              	intMasterId = 1727099
	UNION ALL SELECT intScheduleColumnId = 626, strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                    	intMasterId = 1727100
	UNION ALL SELECT intScheduleColumnId = 627, strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727101
	UNION ALL SELECT intScheduleColumnId = 628, strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                       	intMasterId = 1727102
	UNION ALL SELECT intScheduleColumnId = 629, strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                     	intMasterId = 1727103
	UNION ALL SELECT intScheduleColumnId = 630, strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                              	intMasterId = 1727104
	UNION ALL SELECT intScheduleColumnId = 631, strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                          	intMasterId = 1727105
	UNION ALL SELECT intScheduleColumnId = 632, strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                   	intMasterId = 1727106
	UNION ALL SELECT intScheduleColumnId = 633, strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                              	intMasterId = 1727107
	UNION ALL SELECT intScheduleColumnId = 634, strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                          	intMasterId = 1727108
	UNION ALL SELECT intScheduleColumnId = 635, strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                  	intMasterId = 1727109
	UNION ALL SELECT intScheduleColumnId = 636, strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727110
	UNION ALL SELECT intScheduleColumnId = 637, strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                              	intMasterId = 1727111
	UNION ALL SELECT intScheduleColumnId = 638, strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                    	intMasterId = 1727112
	UNION ALL SELECT intScheduleColumnId = 639, strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727113
	UNION ALL SELECT intScheduleColumnId = 640, strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                       	intMasterId = 1727114
	UNION ALL SELECT intScheduleColumnId = 641, strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                     	intMasterId = 1727115
	UNION ALL SELECT intScheduleColumnId = 642, strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                              	intMasterId = 1727116
	UNION ALL SELECT intScheduleColumnId = 643, strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                          	intMasterId = 1727117
	UNION ALL SELECT intScheduleColumnId = 644, strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                   	intMasterId = 1727118
	UNION ALL SELECT intScheduleColumnId = 645, strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727119
	UNION ALL SELECT intScheduleColumnId = 646, strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                           	intMasterId = 1727120
	UNION ALL SELECT intScheduleColumnId = 647, strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                   	intMasterId = 1727121
	UNION ALL SELECT intScheduleColumnId = 648, strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                	intMasterId = 1727122
	UNION ALL SELECT intScheduleColumnId = 649, strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727123
	UNION ALL SELECT intScheduleColumnId = 650, strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                     	intMasterId = 1727124
	UNION ALL SELECT intScheduleColumnId = 651, strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                	intMasterId = 1727125
	UNION ALL SELECT intScheduleColumnId = 652, strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                        	intMasterId = 1727126
	UNION ALL SELECT intScheduleColumnId = 653, strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                      	intMasterId = 1727127
	UNION ALL SELECT intScheduleColumnId = 654, strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727128
	UNION ALL SELECT intScheduleColumnId = 655, strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                           	intMasterId = 1727129
	UNION ALL SELECT intScheduleColumnId = 656, strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                    	intMasterId = 1727130
	UNION ALL SELECT intScheduleColumnId = 657, strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727131
	UNION ALL SELECT intScheduleColumnId = 658, strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                           	intMasterId = 1727132
	UNION ALL SELECT intScheduleColumnId = 659, strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                   	intMasterId = 1727133
	UNION ALL SELECT intScheduleColumnId = 660, strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                	intMasterId = 1727134
	UNION ALL SELECT intScheduleColumnId = 661, strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727135
	UNION ALL SELECT intScheduleColumnId = 662, strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                     	intMasterId = 1727136
	UNION ALL SELECT intScheduleColumnId = 663, strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                	intMasterId = 1727137
	UNION ALL SELECT intScheduleColumnId = 664, strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                        	intMasterId = 1727138
	UNION ALL SELECT intScheduleColumnId = 665, strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                      	intMasterId = 1727139
	UNION ALL SELECT intScheduleColumnId = 666, strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727140
	UNION ALL SELECT intScheduleColumnId = 667, strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                           	intMasterId = 1727141
	UNION ALL SELECT intScheduleColumnId = 668, strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                    	intMasterId = 1727142
	UNION ALL SELECT intScheduleColumnId = 669, strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727143
	UNION ALL SELECT intScheduleColumnId = 670, strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                           	intMasterId = 1727144
	UNION ALL SELECT intScheduleColumnId = 671, strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                   	intMasterId = 1727145
	UNION ALL SELECT intScheduleColumnId = 672, strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                	intMasterId = 1727146
	UNION ALL SELECT intScheduleColumnId = 673, strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727147
	UNION ALL SELECT intScheduleColumnId = 674, strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                     	intMasterId = 1727148
	UNION ALL SELECT intScheduleColumnId = 675, strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                	intMasterId = 1727149
	UNION ALL SELECT intScheduleColumnId = 676, strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                        	intMasterId = 1727150
	UNION ALL SELECT intScheduleColumnId = 677, strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                      	intMasterId = 1727151
	UNION ALL SELECT intScheduleColumnId = 678, strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                               	intMasterId = 1727152
	UNION ALL SELECT intScheduleColumnId = 679, strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                           	intMasterId = 1727153
	UNION ALL SELECT intScheduleColumnId = 680, strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,                                                    	intMasterId = 1727154

	UNION ALL SELECT intScheduleColumnId = 681, strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,								intMasterId = 1727155
	UNION ALL SELECT intScheduleColumnId = 682, strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,							intMasterId = 1727156
	UNION ALL SELECT intScheduleColumnId = 683, strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727157
	UNION ALL SELECT intScheduleColumnId = 684, strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727158
	UNION ALL SELECT intScheduleColumnId = 685, strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727159
	UNION ALL SELECT intScheduleColumnId = 686, strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727160
	UNION ALL SELECT intScheduleColumnId = 687, strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,					intMasterId = 1727161
	UNION ALL SELECT intScheduleColumnId = 688, strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727162
	UNION ALL SELECT intScheduleColumnId = 689, strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,						intMasterId = 1727163
	UNION ALL SELECT intScheduleColumnId = 690, strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727164
	UNION ALL SELECT intScheduleColumnId = 691, strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727165
	UNION ALL SELECT intScheduleColumnId = 692, strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 										intMasterId = 1727166
	UNION ALL SELECT intScheduleColumnId = 693, strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727167
	UNION ALL SELECT intScheduleColumnId = 694, strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727168
	UNION ALL SELECT intScheduleColumnId = 695, strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727169
	UNION ALL SELECT intScheduleColumnId = 696, strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727170
	UNION ALL SELECT intScheduleColumnId = 697, strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727171
	UNION ALL SELECT intScheduleColumnId = 698, strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727172
	UNION ALL SELECT intScheduleColumnId = 699, strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727173
	UNION ALL SELECT intScheduleColumnId = 700, strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727174
	UNION ALL SELECT intScheduleColumnId = 701, strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727175
	UNION ALL SELECT intScheduleColumnId = 702, strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727176
	UNION ALL SELECT intScheduleColumnId = 703, strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727177
	UNION ALL SELECT intScheduleColumnId = 704, strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727178
	UNION ALL SELECT intScheduleColumnId = 705, strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 										intMasterId = 1727179
	UNION ALL SELECT intScheduleColumnId = 706, strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727180
	UNION ALL SELECT intScheduleColumnId = 707, strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727181
	UNION ALL SELECT intScheduleColumnId = 708, strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727182
	UNION ALL SELECT intScheduleColumnId = 709, strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727183
	UNION ALL SELECT intScheduleColumnId = 710, strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727184
	UNION ALL SELECT intScheduleColumnId = 711, strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727185
	UNION ALL SELECT intScheduleColumnId = 712, strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727186
	UNION ALL SELECT intScheduleColumnId = 713, strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727187
	UNION ALL SELECT intScheduleColumnId = 714, strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727188
	UNION ALL SELECT intScheduleColumnId = 715, strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727189
	UNION ALL SELECT intScheduleColumnId = 716, strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727190
	UNION ALL SELECT intScheduleColumnId = 717, strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727191
	UNION ALL SELECT intScheduleColumnId = 718, strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 										intMasterId = 1727192
	UNION ALL SELECT intScheduleColumnId = 719, strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727193
	UNION ALL SELECT intScheduleColumnId = 720, strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727194
	UNION ALL SELECT intScheduleColumnId = 721, strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727195
	UNION ALL SELECT intScheduleColumnId = 722, strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727196
	UNION ALL SELECT intScheduleColumnId = 723, strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727197
	UNION ALL SELECT intScheduleColumnId = 724, strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727198
	UNION ALL SELECT intScheduleColumnId = 725, strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727199
	UNION ALL SELECT intScheduleColumnId = 726, strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727200
	UNION ALL SELECT intScheduleColumnId = 727, strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727201
	UNION ALL SELECT intScheduleColumnId = 728, strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727202
	UNION ALL SELECT intScheduleColumnId = 729, strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727203
	UNION ALL SELECT intScheduleColumnId = 730, strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727204
	UNION ALL SELECT intScheduleColumnId = 731, strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 										intMasterId = 1727205
	UNION ALL SELECT intScheduleColumnId = 732, strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727206
	UNION ALL SELECT intScheduleColumnId = 733, strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727207
	UNION ALL SELECT intScheduleColumnId = 734, strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727208
	UNION ALL SELECT intScheduleColumnId = 735, strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727209
	UNION ALL SELECT intScheduleColumnId = 736, strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727210
	UNION ALL SELECT intScheduleColumnId = 737, strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727211
	UNION ALL SELECT intScheduleColumnId = 738, strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727212
	UNION ALL SELECT intScheduleColumnId = 739, strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727213
	UNION ALL SELECT intScheduleColumnId = 740, strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727214
	UNION ALL SELECT intScheduleColumnId = 741, strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727215
	UNION ALL SELECT intScheduleColumnId = 742, strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727216
	UNION ALL SELECT intScheduleColumnId = 743, strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727217
	UNION ALL SELECT intScheduleColumnId = 744, strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 										intMasterId = 1727218
	UNION ALL SELECT intScheduleColumnId = 745, strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727219
	UNION ALL SELECT intScheduleColumnId = 746, strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727220
	UNION ALL SELECT intScheduleColumnId = 747, strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727221
	UNION ALL SELECT intScheduleColumnId = 748, strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727222
	UNION ALL SELECT intScheduleColumnId = 749, strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727223
	UNION ALL SELECT intScheduleColumnId = 750, strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727224
	UNION ALL SELECT intScheduleColumnId = 751, strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727225
	UNION ALL SELECT intScheduleColumnId = 752, strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727226
	UNION ALL SELECT intScheduleColumnId = 753, strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727227
	UNION ALL SELECT intScheduleColumnId = 754, strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727228
	UNION ALL SELECT intScheduleColumnId = 755, strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727229
	UNION ALL SELECT intScheduleColumnId = 756, strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727230
	UNION ALL SELECT intScheduleColumnId = 757, strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 										intMasterId = 1727231
	UNION ALL SELECT intScheduleColumnId = 758, strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727232
	UNION ALL SELECT intScheduleColumnId = 759, strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727233
	UNION ALL SELECT intScheduleColumnId = 760, strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727234
	UNION ALL SELECT intScheduleColumnId = 761, strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727235
	UNION ALL SELECT intScheduleColumnId = 762, strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727236
	UNION ALL SELECT intScheduleColumnId = 763, strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727237
	UNION ALL SELECT intScheduleColumnId = 764, strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727238
	UNION ALL SELECT intScheduleColumnId = 765, strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727239
	UNION ALL SELECT intScheduleColumnId = 766, strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727240
	UNION ALL SELECT intScheduleColumnId = 767, strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727241
	UNION ALL SELECT intScheduleColumnId = 768, strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727242
	UNION ALL SELECT intScheduleColumnId = 769, strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727243
	UNION ALL SELECT intScheduleColumnId = 770, strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 										intMasterId = 1727244
	UNION ALL SELECT intScheduleColumnId = 771, strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727245
	UNION ALL SELECT intScheduleColumnId = 781, strFormCode = '72A089', strScheduleCode = '5D_IL_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727246
	UNION ALL SELECT intScheduleColumnId = 782, strFormCode = '72A089', strScheduleCode = '5D_IL_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727247
	UNION ALL SELECT intScheduleColumnId = 783, strFormCode = '72A089', strScheduleCode = '5D_IL_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 			intMasterId = 1727248
	UNION ALL SELECT intScheduleColumnId = 784, strFormCode = '72A089', strScheduleCode = '5D_IL_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727249
	UNION ALL SELECT intScheduleColumnId = 785, strFormCode = '72A089', strScheduleCode = '5D_IL_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727250
	UNION ALL SELECT intScheduleColumnId = 786, strFormCode = '72A089', strScheduleCode = '5D_IL_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727251
	UNION ALL SELECT intScheduleColumnId = 787, strFormCode = '72A089', strScheduleCode = '5D_IL_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727252
	UNION ALL SELECT intScheduleColumnId = 788, strFormCode = '72A089', strScheduleCode = '5D_IL_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727253
	UNION ALL SELECT intScheduleColumnId = 789, strFormCode = '72A089', strScheduleCode = '5D_IL_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727254
	UNION ALL SELECT intScheduleColumnId = 790, strFormCode = '72A089', strScheduleCode = '5D_IL_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727255
	UNION ALL SELECT intScheduleColumnId = 791, strFormCode = '72A089', strScheduleCode = '5D_IL_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727256
	UNION ALL SELECT intScheduleColumnId = 792, strFormCode = '72A089', strScheduleCode = '5D_IL_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727257
	UNION ALL SELECT intScheduleColumnId = 793, strFormCode = '72A089', strScheduleCode = '5D_IN_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727258
	UNION ALL SELECT intScheduleColumnId = 794, strFormCode = '72A089', strScheduleCode = '5D_IN_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727259
	UNION ALL SELECT intScheduleColumnId = 795, strFormCode = '72A089', strScheduleCode = '5D_IN_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0,  			intMasterId = 1727260
	UNION ALL SELECT intScheduleColumnId = 796, strFormCode = '72A089', strScheduleCode = '5D_IN_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727261
	UNION ALL SELECT intScheduleColumnId = 797, strFormCode = '72A089', strScheduleCode = '5D_IN_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727262
	UNION ALL SELECT intScheduleColumnId = 798, strFormCode = '72A089', strScheduleCode = '5D_IN_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727263
	UNION ALL SELECT intScheduleColumnId = 799, strFormCode = '72A089', strScheduleCode = '5D_IN_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727264
	UNION ALL SELECT intScheduleColumnId = 800, strFormCode = '72A089', strScheduleCode = '5D_IN_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727265
	UNION ALL SELECT intScheduleColumnId = 801, strFormCode = '72A089', strScheduleCode = '5D_IN_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727266
	UNION ALL SELECT intScheduleColumnId = 802, strFormCode = '72A089', strScheduleCode = '5D_IN_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727267
	UNION ALL SELECT intScheduleColumnId = 803, strFormCode = '72A089', strScheduleCode = '5D_IN_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727268
	UNION ALL SELECT intScheduleColumnId = 804, strFormCode = '72A089', strScheduleCode = '5D_IN_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727269
	UNION ALL SELECT intScheduleColumnId = 805, strFormCode = '72A089', strScheduleCode = '5D_TN_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727270
	UNION ALL SELECT intScheduleColumnId = 806, strFormCode = '72A089', strScheduleCode = '5D_TN_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727271
	UNION ALL SELECT intScheduleColumnId = 807, strFormCode = '72A089', strScheduleCode = '5D_TN_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 			intMasterId = 1727272
	UNION ALL SELECT intScheduleColumnId = 808, strFormCode = '72A089', strScheduleCode = '5D_TN_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727273
	UNION ALL SELECT intScheduleColumnId = 809, strFormCode = '72A089', strScheduleCode = '5D_TN_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727274
	UNION ALL SELECT intScheduleColumnId = 810, strFormCode = '72A089', strScheduleCode = '5D_TN_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727275
	UNION ALL SELECT intScheduleColumnId = 811, strFormCode = '72A089', strScheduleCode = '5D_TN_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727276
	UNION ALL SELECT intScheduleColumnId = 812, strFormCode = '72A089', strScheduleCode = '5D_TN_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727277
	UNION ALL SELECT intScheduleColumnId = 813, strFormCode = '72A089', strScheduleCode = '5D_TN_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727278
	UNION ALL SELECT intScheduleColumnId = 814, strFormCode = '72A089', strScheduleCode = '5D_TN_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727279
	UNION ALL SELECT intScheduleColumnId = 815, strFormCode = '72A089', strScheduleCode = '5D_TN_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727280
	UNION ALL SELECT intScheduleColumnId = 816, strFormCode = '72A089', strScheduleCode = '5D_TN_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727281
	UNION ALL SELECT intScheduleColumnId = 817, strFormCode = '72A089', strScheduleCode = '6_TR_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727282
	UNION ALL SELECT intScheduleColumnId = 818, strFormCode = '72A089', strScheduleCode = '6_TR_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727283
	UNION ALL SELECT intScheduleColumnId = 819, strFormCode = '72A089', strScheduleCode = '6_TR_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 			intMasterId = 1727284
	UNION ALL SELECT intScheduleColumnId = 820, strFormCode = '72A089', strScheduleCode = '6_TR_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727285
	UNION ALL SELECT intScheduleColumnId = 821, strFormCode = '72A089', strScheduleCode = '6_TR_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727286
	UNION ALL SELECT intScheduleColumnId = 822, strFormCode = '72A089', strScheduleCode = '6_TR_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727287
	UNION ALL SELECT intScheduleColumnId = 823, strFormCode = '72A089', strScheduleCode = '6_TR_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727288
	UNION ALL SELECT intScheduleColumnId = 824, strFormCode = '72A089', strScheduleCode = '6_TR_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727289
	UNION ALL SELECT intScheduleColumnId = 825, strFormCode = '72A089', strScheduleCode = '6_TR_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727290
	UNION ALL SELECT intScheduleColumnId = 826, strFormCode = '72A089', strScheduleCode = '6_TR_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727291
	UNION ALL SELECT intScheduleColumnId = 827, strFormCode = '72A089', strScheduleCode = '6_TR_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727292
	UNION ALL SELECT intScheduleColumnId = 828, strFormCode = '72A089', strScheduleCode = '6_TR_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727293
	UNION ALL SELECT intScheduleColumnId = 829, strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727294
	UNION ALL SELECT intScheduleColumnId = 830, strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727295
	UNION ALL SELECT intScheduleColumnId = 831, strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 			intMasterId = 1727296
	UNION ALL SELECT intScheduleColumnId = 832, strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727297
	UNION ALL SELECT intScheduleColumnId = 833, strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727298
	UNION ALL SELECT intScheduleColumnId = 834, strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727299
	UNION ALL SELECT intScheduleColumnId = 835, strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727300
	UNION ALL SELECT intScheduleColumnId = 836, strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727301
	UNION ALL SELECT intScheduleColumnId = 837, strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727302
	UNION ALL SELECT intScheduleColumnId = 838, strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727303
	UNION ALL SELECT intScheduleColumnId = 839, strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727304
	UNION ALL SELECT intScheduleColumnId = 840, strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727305
	UNION ALL SELECT intScheduleColumnId = 841, strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727306
	UNION ALL SELECT intScheduleColumnId = 842, strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727307
	UNION ALL SELECT intScheduleColumnId = 843, strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 			intMasterId = 1727308
	UNION ALL SELECT intScheduleColumnId = 844, strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727309
	UNION ALL SELECT intScheduleColumnId = 845, strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727310
	UNION ALL SELECT intScheduleColumnId = 846, strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727311
	UNION ALL SELECT intScheduleColumnId = 847, strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727312
	UNION ALL SELECT intScheduleColumnId = 848, strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727313
	UNION ALL SELECT intScheduleColumnId = 849, strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727314
	UNION ALL SELECT intScheduleColumnId = 850, strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727315
	UNION ALL SELECT intScheduleColumnId = 851, strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727316
	UNION ALL SELECT intScheduleColumnId = 852, strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727317
	UNION ALL SELECT intScheduleColumnId = 853, strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727318
	UNION ALL SELECT intScheduleColumnId = 854, strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727319
	UNION ALL SELECT intScheduleColumnId = 855, strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 			intMasterId = 1727320
	UNION ALL SELECT intScheduleColumnId = 856, strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727321
	UNION ALL SELECT intScheduleColumnId = 857, strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727322
	UNION ALL SELECT intScheduleColumnId = 858, strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727323
	UNION ALL SELECT intScheduleColumnId = 859, strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727324
	UNION ALL SELECT intScheduleColumnId = 860, strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727325
	UNION ALL SELECT intScheduleColumnId = 861, strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727326
	UNION ALL SELECT intScheduleColumnId = 862, strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727327
	UNION ALL SELECT intScheduleColumnId = 863, strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727328
	UNION ALL SELECT intScheduleColumnId = 864, strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727329
	UNION ALL SELECT intScheduleColumnId = 865, strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727330
	UNION ALL SELECT intScheduleColumnId = 866, strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727331
	UNION ALL SELECT intScheduleColumnId = 867, strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727332
	UNION ALL SELECT intScheduleColumnId = 868, strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727333
	UNION ALL SELECT intScheduleColumnId = 869, strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727334
	UNION ALL SELECT intScheduleColumnId = 870, strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727335
	UNION ALL SELECT intScheduleColumnId = 871, strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727336
	UNION ALL SELECT intScheduleColumnId = 872, strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727337
	UNION ALL SELECT intScheduleColumnId = 873, strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727338
	UNION ALL SELECT intScheduleColumnId = 874, strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727339
	UNION ALL SELECT intScheduleColumnId = 875, strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 										intMasterId = 1727340
	UNION ALL SELECT intScheduleColumnId = 876, strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727341
	UNION ALL SELECT intScheduleColumnId = 877, strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727342
	UNION ALL SELECT intScheduleColumnId = 878, strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727343
	UNION ALL SELECT intScheduleColumnId = 879, strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727344
	UNION ALL SELECT intScheduleColumnId = 880, strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727345
	UNION ALL SELECT intScheduleColumnId = 881, strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727346
	UNION ALL SELECT intScheduleColumnId = 882, strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727347
	UNION ALL SELECT intScheduleColumnId = 883, strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727348
	UNION ALL SELECT intScheduleColumnId = 884, strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727349
	UNION ALL SELECT intScheduleColumnId = 885, strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727350
	UNION ALL SELECT intScheduleColumnId = 886, strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727351
	UNION ALL SELECT intScheduleColumnId = 887, strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 										intMasterId = 1727352
	UNION ALL SELECT intScheduleColumnId = 888, strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727353
																																																																				
	UNION ALL SELECT intScheduleColumnId = 889, strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727354
	UNION ALL SELECT intScheduleColumnId = 890, strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727355
	UNION ALL SELECT intScheduleColumnId = 891, strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 			intMasterId = 1727356
	UNION ALL SELECT intScheduleColumnId = 892, strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727357
	UNION ALL SELECT intScheduleColumnId = 893, strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727358
	UNION ALL SELECT intScheduleColumnId = 894, strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727359
	UNION ALL SELECT intScheduleColumnId = 895, strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727360
	UNION ALL SELECT intScheduleColumnId = 896, strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727361
	UNION ALL SELECT intScheduleColumnId = 897, strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727362
	UNION ALL SELECT intScheduleColumnId = 898, strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727363
	UNION ALL SELECT intScheduleColumnId = 899, strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727364
	UNION ALL SELECT intScheduleColumnId = 900, strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727365
	UNION ALL SELECT intScheduleColumnId = 901, strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727366
	UNION ALL SELECT intScheduleColumnId = 902, strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727367
	UNION ALL SELECT intScheduleColumnId = 903, strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727368
	UNION ALL SELECT intScheduleColumnId = 904, strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 			intMasterId = 1727369
	UNION ALL SELECT intScheduleColumnId = 905, strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727370
	UNION ALL SELECT intScheduleColumnId = 906, strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727371
	UNION ALL SELECT intScheduleColumnId = 907, strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727372
	UNION ALL SELECT intScheduleColumnId = 908, strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727373
	UNION ALL SELECT intScheduleColumnId = 909, strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727374
	UNION ALL SELECT intScheduleColumnId = 910, strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727375
	UNION ALL SELECT intScheduleColumnId = 911, strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727376
	UNION ALL SELECT intScheduleColumnId = 912, strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727377
	UNION ALL SELECT intScheduleColumnId = 913, strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727378
	UNION ALL SELECT intScheduleColumnId = 914, strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727379
	UNION ALL SELECT intScheduleColumnId = 915, strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727380
	UNION ALL SELECT intScheduleColumnId = 916, strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727381
	UNION ALL SELECT intScheduleColumnId = 917, strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 			intMasterId = 1727382
	UNION ALL SELECT intScheduleColumnId = 918, strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727383
	UNION ALL SELECT intScheduleColumnId = 919, strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727384
	UNION ALL SELECT intScheduleColumnId = 920, strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727385
	UNION ALL SELECT intScheduleColumnId = 921, strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727386
	UNION ALL SELECT intScheduleColumnId = 922, strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727387
	UNION ALL SELECT intScheduleColumnId = 923, strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727388
	UNION ALL SELECT intScheduleColumnId = 924, strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727389
	UNION ALL SELECT intScheduleColumnId = 925, strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727390
	UNION ALL SELECT intScheduleColumnId = 926, strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727391
	UNION ALL SELECT intScheduleColumnId = 927, strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727392
	UNION ALL SELECT intScheduleColumnId = 937, strFormCode = '72A089', strScheduleCode = '5D_OH_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727393
	UNION ALL SELECT intScheduleColumnId = 938, strFormCode = '72A089', strScheduleCode = '5D_OH_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727394
	UNION ALL SELECT intScheduleColumnId = 939, strFormCode = '72A089', strScheduleCode = '5D_OH_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 			intMasterId = 1727395
	UNION ALL SELECT intScheduleColumnId = 930, strFormCode = '72A089', strScheduleCode = '5D_OH_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727396
	UNION ALL SELECT intScheduleColumnId = 941, strFormCode = '72A089', strScheduleCode = '5D_OH_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727397
	UNION ALL SELECT intScheduleColumnId = 942, strFormCode = '72A089', strScheduleCode = '5D_OH_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727398
	UNION ALL SELECT intScheduleColumnId = 943, strFormCode = '72A089', strScheduleCode = '5D_OH_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727399
	UNION ALL SELECT intScheduleColumnId = 944, strFormCode = '72A089', strScheduleCode = '5D_OH_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727400
	UNION ALL SELECT intScheduleColumnId = 945, strFormCode = '72A089', strScheduleCode = '5D_OH_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727401
	UNION ALL SELECT intScheduleColumnId = 946, strFormCode = '72A089', strScheduleCode = '5D_OH_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727402
	UNION ALL SELECT intScheduleColumnId = 947, strFormCode = '72A089', strScheduleCode = '5D_OH_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727403
	UNION ALL SELECT intScheduleColumnId = 948, strFormCode = '72A089', strScheduleCode = '5D_OH_TR', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727404
	UNION ALL SELECT intScheduleColumnId = 949, strFormCode = '72A089', strScheduleCode = '5D_VA_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727405
	UNION ALL SELECT intScheduleColumnId = 950, strFormCode = '72A089', strScheduleCode = '5D_VA_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727406
	UNION ALL SELECT intScheduleColumnId = 951, strFormCode = '72A089', strScheduleCode = '5D_VA_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 			intMasterId = 1727407
	UNION ALL SELECT intScheduleColumnId = 952, strFormCode = '72A089', strScheduleCode = '5D_VA_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727408
	UNION ALL SELECT intScheduleColumnId = 953, strFormCode = '72A089', strScheduleCode = '5D_VA_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727409
	UNION ALL SELECT intScheduleColumnId = 954, strFormCode = '72A089', strScheduleCode = '5D_VA_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727410
	UNION ALL SELECT intScheduleColumnId = 955, strFormCode = '72A089', strScheduleCode = '5D_VA_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727411
	UNION ALL SELECT intScheduleColumnId = 956, strFormCode = '72A089', strScheduleCode = '5D_VA_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727412
	UNION ALL SELECT intScheduleColumnId = 957, strFormCode = '72A089', strScheduleCode = '5D_VA_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727413
	UNION ALL SELECT intScheduleColumnId = 958, strFormCode = '72A089', strScheduleCode = '5D_VA_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727414
	UNION ALL SELECT intScheduleColumnId = 959, strFormCode = '72A089', strScheduleCode = '5D_VA_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727415
	UNION ALL SELECT intScheduleColumnId = 960, strFormCode = '72A089', strScheduleCode = '5D_VA_TR', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727416
	UNION ALL SELECT intScheduleColumnId = 961, strFormCode = '72A089', strScheduleCode = '5D_WV_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727417
	UNION ALL SELECT intScheduleColumnId = 962, strFormCode = '72A089', strScheduleCode = '5D_WV_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727418
	UNION ALL SELECT intScheduleColumnId = 963, strFormCode = '72A089', strScheduleCode = '5D_WV_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 			intMasterId = 1727419
	UNION ALL SELECT intScheduleColumnId = 964, strFormCode = '72A089', strScheduleCode = '5D_WV_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727420
	UNION ALL SELECT intScheduleColumnId = 965, strFormCode = '72A089', strScheduleCode = '5D_WV_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727421
	UNION ALL SELECT intScheduleColumnId = 966, strFormCode = '72A089', strScheduleCode = '5D_WV_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727422
	UNION ALL SELECT intScheduleColumnId = 967, strFormCode = '72A089', strScheduleCode = '5D_WV_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727423
	UNION ALL SELECT intScheduleColumnId = 968, strFormCode = '72A089', strScheduleCode = '5D_WV_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727424
	UNION ALL SELECT intScheduleColumnId = 969, strFormCode = '72A089', strScheduleCode = '5D_WV_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727425
	UNION ALL SELECT intScheduleColumnId = 970, strFormCode = '72A089', strScheduleCode = '5D_WV_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727426
	UNION ALL SELECT intScheduleColumnId = 971, strFormCode = '72A089', strScheduleCode = '5D_WV_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727427
	UNION ALL SELECT intScheduleColumnId = 972, strFormCode = '72A089', strScheduleCode = '5D_WV_TR', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727428
	UNION ALL SELECT intScheduleColumnId = 973, strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727429
	UNION ALL SELECT intScheduleColumnId = 974, strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727430
	UNION ALL SELECT intScheduleColumnId = 975, strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 			intMasterId = 1727431
	UNION ALL SELECT intScheduleColumnId = 976, strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727432
	UNION ALL SELECT intScheduleColumnId = 977, strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727433
	UNION ALL SELECT intScheduleColumnId = 978, strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727434
	UNION ALL SELECT intScheduleColumnId = 979, strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727435
	UNION ALL SELECT intScheduleColumnId = 980, strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727436
	UNION ALL SELECT intScheduleColumnId = 981, strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727437
	UNION ALL SELECT intScheduleColumnId = 982, strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727438
	UNION ALL SELECT intScheduleColumnId = 983, strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727439
	UNION ALL SELECT intScheduleColumnId = 984, strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727440
	UNION ALL SELECT intScheduleColumnId = 985, strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727441
	UNION ALL SELECT intScheduleColumnId = 986, strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727442
	UNION ALL SELECT intScheduleColumnId = 987, strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 			intMasterId = 1727443
	UNION ALL SELECT intScheduleColumnId = 988, strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727444
	UNION ALL SELECT intScheduleColumnId = 989, strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727445
	UNION ALL SELECT intScheduleColumnId = 990, strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727446
	UNION ALL SELECT intScheduleColumnId = 991, strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727447
	UNION ALL SELECT intScheduleColumnId = 992, strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727448
	UNION ALL SELECT intScheduleColumnId = 993, strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727449
	UNION ALL SELECT intScheduleColumnId = 994, strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727450
	UNION ALL SELECT intScheduleColumnId = 995, strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727451
	UNION ALL SELECT intScheduleColumnId = 996, strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727452
	UNION ALL SELECT intScheduleColumnId = 997, strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727453
	UNION ALL SELECT intScheduleColumnId = 998, strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727454
	UNION ALL SELECT intScheduleColumnId = 999, strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 			intMasterId = 1727455
	UNION ALL SELECT intScheduleColumnId = 1000, strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727456
	UNION ALL SELECT intScheduleColumnId = 1001, strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727457
	UNION ALL SELECT intScheduleColumnId = 1002, strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 				intMasterId = 1727458
	UNION ALL SELECT intScheduleColumnId = 1003, strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 							intMasterId = 1727459
	UNION ALL SELECT intScheduleColumnId = 1004, strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 					intMasterId = 1727460
	UNION ALL SELECT intScheduleColumnId = 1005, strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727461
	UNION ALL SELECT intScheduleColumnId = 1006, strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 						intMasterId = 1727462
	UNION ALL SELECT intScheduleColumnId = 1007, strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 									intMasterId = 1727463
	UNION ALL SELECT intScheduleColumnId = 1008, strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, 								intMasterId = 1727464
																																																																				
																																																																				
																																																																				
																																																																				
	EXEC uspTFUpgradeReportingComponentOutputDesigners @TaxAuthorityCode = @TaxAuthorityCode, @ReportingComponentOutputDesigners = @ReportingComponentOutputDesigners																											
																																																																				
-- Filing Packet																																																																
/* Generate script for Filing Packets. Specify Tax Authority Id to filter out specific Filing Packets only.																																										
select 'UNION ALL SELECT intFilingPacketId = ' + CAST(0 AS NVARCHAR(10))																																																		
	+ CASE WHEN strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END																																								
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END																																				
	+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END																																												
	+ CASE WHEN ysnStatus IS NULL THEN ', ysnStatus = NULL' ELSE ', ysnStatus = ' + CAST(ysnStatus AS NVARCHAR) END																																								
	+ CASE WHEN intFrequency IS NULL THEN ', intFrequency = NULL' ELSE ', intFrequency = ' + CAST(intFrequency AS NVARCHAR(10)) END																																				
--	+ ', intMasterId = ' + CAST((CASE WHEN ISNULL(FP.intMasterId, '') = '' THEN intFilingPacketId ELSE FP.intMasterId END) AS NVARCHAR(20)) -- Old Format																														
	+ ', intMasterId = ' + CASE WHEN FP.intMasterId IS NULL THEN CAST(@TaxAuthorityId AS NVARCHAR(20)) + CAST(intFilingPacketId AS NVARCHAR(20)) ELSE CAST(FP.intMasterId AS NVARCHAR(20)) END -- First 2 digit for TaxAuthorityCodeID											
from tblTFFilingPacket FP																																																														
left join tblTFReportingComponent RC on RC.intReportingComponentId = FP.intReportingComponentId																																													
where FP.intTaxAuthorityId = @TaxAuthorityId																																																									
*/																																																																				
	DECLARE @FilingPackets AS TFFilingPackets

	INSERT INTO @FilingPackets(
		intFilingPacketId
		, strFormCode
		, strScheduleCode
		, strType
		, ysnStatus
		, intFrequency
		, intMasterId
	)
	SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '72A089', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172975
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '1', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172959
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '10I', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172974
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '2', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172960
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '2A', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172961
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '2B', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172962
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '3_IL', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172963
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '3_IN', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172964
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '3_TN', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172965
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '5D_IL', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172966
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '5D_IN', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172967
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '5D_TN', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172968
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '6', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172969
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '7_IL', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172970
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '7_IN', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172971
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '7_TN', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172972
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '8', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172973
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '72A138', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172997
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '1', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172976
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '10A', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172992
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '10G', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172993
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '10I', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172994
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '10J', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172995
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '10Y', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172996
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '2', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172977
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '2A', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172978
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '2B', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172979
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '3_IL', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172980
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '3_IN', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172981
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '3_TN', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172982
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '5D_IL', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172983
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '5D_IN', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172984
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '5D_TN', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172985
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '6', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172986
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '7_IL', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172987
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '7_IN', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172988
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '7_TN', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172989
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '8', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172990
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '9', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172991
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'KY EDI', strScheduleCode = 'EDI', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172998
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '3_OH', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172999
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '3_VA', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173000
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '3_WV', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173001
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '5D_OH', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173002
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '5D_VA', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173003
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '5D_WV', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173004
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '7_OH', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173005
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '7_VA', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173006
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '7_WV', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173007
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '3_OH', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173008
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '3_VA', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173009
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '3_WV', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173010
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '5D_OH', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173011
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '5D_VA', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173012
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '5D_WV', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173013
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '7_OH', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173014
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '7_VA', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173015
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '7_WV', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173016


	

	--MFT-1704
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A099', strScheduleCode = '14'	, strType = 'Gasoline'		, ysnStatus = 1, intFrequency = 1, intMasterId =	173017
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A099', strScheduleCode = '14'	, strType = 'Special Fuels'	, ysnStatus = 1, intFrequency = 1, intMasterId =	173018
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Gasoline'		, ysnStatus = 1, intFrequency = 1, intMasterId =	173019
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A099', strScheduleCode = '14_C', strType = 'Special Fuels'	, ysnStatus = 1, intFrequency = 1, intMasterId =	173020
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A099', strScheduleCode = 'TR-EDI', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173051
	
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '1_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173021
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '10A_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173022
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '10G_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173023
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '10I_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173024
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '10J_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173025
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '10Y_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173026
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '2_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173027
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '2A_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173028
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '2B_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173029
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '3_IL_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173030
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '3_IN_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173031
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '3_TN_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173032
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '5D_IL_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173033
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '5D_IN_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173034
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '5D_TN_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173035
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '6_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173036
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '7_IL_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173037
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '7_IN_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173038
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '7_TN_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173039
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '8_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173040
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '9_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173041
		
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '3_OH_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173042
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '3_VA_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173043
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '3_WV_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173044
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '5D_OH_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173045
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '5D_VA_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173046
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '5D_WV_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173047
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '7_OH_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173048
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '7_VA_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173049
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '7_WV_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId =	173050

	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '1_TR', strType = '', ysnStatus = 1, intFrequency = 1,		intMasterId = 173052
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '10I_TR', strType = '', ysnStatus = 1, intFrequency = 1,		intMasterId = 173053
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '2_TR', strType = '', ysnStatus = 1, intFrequency = 1,		intMasterId = 173054
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '2A_TR', strType = '', ysnStatus = 1, intFrequency = 1,		intMasterId = 173055
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '2B_TR', strType = '', ysnStatus = 1, intFrequency = 1,		intMasterId = 173056
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '3_IL_TR', strType = '', ysnStatus = 1, intFrequency = 1,		intMasterId = 173057
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '3_IN_TR', strType = '', ysnStatus = 1, intFrequency = 1,		intMasterId = 173058
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '3_TN_TR', strType = '', ysnStatus = 1, intFrequency = 1,		intMasterId = 173059
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '5D_IL_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId = 173060
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '5D_IN_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId = 173061
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '5D_TN_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId = 173062
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '6_TR', strType = '', ysnStatus = 1, intFrequency = 1,		intMasterId = 173063
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '7_IL_TR', strType = '', ysnStatus = 1, intFrequency = 1,		intMasterId = 173064
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '7_IN_TR', strType = '', ysnStatus = 1, intFrequency = 1,		intMasterId = 173065
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '7_TN_TR', strType = '', ysnStatus = 1, intFrequency = 1,		intMasterId = 173066
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '8_TR', strType = '', ysnStatus = 1, intFrequency = 1,		intMasterId = 173067
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '3_OH_TR', strType = '', ysnStatus = 1, intFrequency = 1,		intMasterId = 173068
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '3_VA_TR', strType = '', ysnStatus = 1, intFrequency = 1,		intMasterId = 173069
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '3_WV_TR', strType = '', ysnStatus = 1, intFrequency = 1,		intMasterId = 173070
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '5D_OH_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId = 173071
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '5D_VA_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId = 173072
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '5D_WV_TR', strType = '', ysnStatus = 1, intFrequency = 1,	intMasterId = 173073
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '7_OH_TR', strType = '', ysnStatus = 1, intFrequency = 1,		intMasterId = 173074
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '7_VA_TR', strType = '', ysnStatus = 1, intFrequency = 1,		intMasterId = 173075
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '7_WV_TR', strType = '', ysnStatus = 1, intFrequency = 1,		intMasterId = 173076
																																					
																																					
	EXEC uspTFUpgradeFilingPackets @TaxAuthorityCode = @TaxAuthorityCode, @FilingPackets = @FilingPackets											
																																					
END																																					
																																					
GO																																					
