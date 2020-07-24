DECLARE @TaxAuthorityCode NVARCHAR(10) = 'KY'
	, @TaxAuthorityId INT

SELECT @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = @TaxAuthorityCode AND ysnFilingForThisTA = 1

IF(@TaxAuthorityId IS NOT NULL)
BEGIN

	PRINT ('Deploying Kentucky Tax Forms')

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
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '3IL', strScheduleName = 'Imported from IL, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 50, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 172060, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '3IN', strScheduleName = 'Imported from IN, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 60, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 172061, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '3TN', strScheduleName = 'Imported from TN, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 70, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 172062, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '5DIL', strScheduleName = 'Sold for Import from IL, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 80, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172063, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '5DIN', strScheduleName = 'Sold for Import from IN, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 90, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172064, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '5DTN', strScheduleName = 'Sold for Import from TN, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 100, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172065, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '6', strScheduleName = 'Delivered to Licensed Distributors, KY Tax Not Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 110, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172066, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '7IL', strScheduleName = 'Exported to IL', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 120, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172067, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '7IN', strScheduleName = 'Exported to IN', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 130, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172068, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '7TN', strScheduleName = 'Exported to TN', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 140, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172069, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '8', strScheduleName = 'Delivered to US Government, Tax Exempt', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 150, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172070, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '10I', strScheduleName = 'Delivered for Farming, Tax Exempt', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 160, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172071, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '72A089', strScheduleName = '', strType = '', strNote = 'Main Form', strTransactionType = '', intSort = 170, strStoredProcedure = '', intMasterId = 172072, intComponentTypeId = 2
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '1', strScheduleName = 'Received, KY Tax Paid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 200, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 172073, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '2', strScheduleName = 'Received from Licensed Distributor, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 210, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 172074, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '2A', strScheduleName = 'Received from Terminals, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 220, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 172075, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '2B', strScheduleName = 'Blendable Stock Received, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 230, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 172076, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '3IL', strScheduleName = 'Imported from IL, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 240, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 172077, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '3IN', strScheduleName = 'Imported from IN, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 250, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 172078, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '3TN', strScheduleName = 'Imported from TN, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 260, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 172079, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '5DIL', strScheduleName = 'Sold for Import from IL, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 270, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172080, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '5DIN', strScheduleName = 'Sold for Import from IN, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 280, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172081, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '5DTN', strScheduleName = 'Sold for Import from TN, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 290, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172082, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '6', strScheduleName = 'Delivered to Licensed Distributors, KY Tax Not Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 300, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172083, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '7IL', strScheduleName = 'Exported to IL', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 310, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172084, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '7IN', strScheduleName = 'Exported to IN', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 320, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172085, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '7TN', strScheduleName = 'Exported to TN', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 330, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172086, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '8', strScheduleName = 'Delivered to US Government, Tax Exempt', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 340, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172087, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '9', strScheduleName = 'Delivered to State and Local Government, Tax Exempt', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 350, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172088, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '10A', strScheduleName = 'Sold for Non-highway Use', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 360, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172089, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '10G', strScheduleName = 'Delivered to Non-profit Religious, Charitable, or Educational Organizations', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 370, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172090, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '10I', strScheduleName = 'Delivered for Farming, Tax Exempt', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 380, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172091, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '10J', strScheduleName = 'Delivered for Residential Heating, Tax Exempt', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 390, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172092, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '10Y', strScheduleName = 'Delivered to Railroads, Tax Exempt', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 400, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172093, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '72A138', strScheduleName = '', strType = '', strNote = 'Main Form', strTransactionType = '', intSort = 410, strStoredProcedure = '', intMasterId = 172094, intComponentTypeId = 2
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'KY EDI', strFormName = 'KY EDI', strScheduleCode = '', strScheduleName = '', strType = '', strNote = 'KY EDI File', strTransactionType = '', intSort = 1000, strStoredProcedure = '', intMasterId = 172095, intComponentTypeId = 3
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '3OH', strScheduleName = 'Imported from OH, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 73, strStoredProcedure = 'uspTFGetTransporterInventoryTax', intMasterId = 172096, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '3VA', strScheduleName = 'Imported from VA, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 75, strStoredProcedure = 'uspTFGetTransporterInventoryTax', intMasterId = 172097, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '3WV', strScheduleName = 'Imported from WV, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 77, strStoredProcedure = 'uspTFGetTransporterInventoryTax', intMasterId = 172098, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '5DOH', strScheduleName = 'Sold for Import from OH, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 103, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172099, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '5DVA', strScheduleName = 'Sold for Import from VA, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 105, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172100, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '5DWV', strScheduleName = 'Sold for Import from WV, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 107, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172101, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '7OH', strScheduleName = 'Exported to OH', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 143, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172102, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '7VA', strScheduleName = 'Exported to VA', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 145, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172103, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A089', strFormName = 'Gasoline Dealer Return', strScheduleCode = '7WV', strScheduleName = 'Exported to WV', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 147, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172104, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '3OH', strScheduleName = 'Imported from OH, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 263, strStoredProcedure = 'uspTFGetTransporterInventoryTax', intMasterId = 172105, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '3VA', strScheduleName = 'Imported from VA, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 265, strStoredProcedure = 'uspTFGetTransporterInventoryTax', intMasterId = 172106, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '3WV', strScheduleName = 'Imported from WV, KY Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 267, strStoredProcedure = 'uspTFGetTransporterInventoryTax', intMasterId = 172107, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '5DOH', strScheduleName = 'Sold for Import from OH, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 293, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172108, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '5DVA', strScheduleName = 'Sold for Import from VA, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 295, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172109, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '5DWV', strScheduleName = 'Sold for Import from WV, KY Tax Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 297, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 172110, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '7OH', strScheduleName = 'Exported to OH', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 333, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172111, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '7VA', strScheduleName = 'Exported to VA', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 335, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172112, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '72A138', strFormName = 'Special Fuel Dealer Return', strScheduleCode = '7WV', strScheduleName = 'Exported to WV', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 337, strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intMasterId = 172113, intComponentTypeId = 1

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
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '3IL', strType = '', strCriteria = '= 0', intMasterId = 17911
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '3IN', strType = '', strCriteria = '= 0', intMasterId = 17912
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '3TN', strType = '', strCriteria = '= 0', intMasterId = 17913
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '2', strType = '', strCriteria = '= 0', intMasterId = 17914
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '2A', strType = '', strCriteria = '= 0', intMasterId = 17915
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '2B', strType = '', strCriteria = '= 0', intMasterId = 17916
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '3IL', strType = '', strCriteria = '= 0', intMasterId = 17917
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '3IN', strType = '', strCriteria = '= 0', intMasterId = 17918
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '3TN', strType = '', strCriteria = '= 0', intMasterId = 17919
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '10I', strType = '', strCriteria = '= 0', intMasterId = 17920
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '8', strType = '', strCriteria = '= 0', intMasterId = 17921
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '10I', strType = '', strCriteria = '= 0', intMasterId = 17922
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '10J', strType = '', strCriteria = '= 0', intMasterId = 17923
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '10Y', strType = '', strCriteria = '= 0', intMasterId = 17924
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '8', strType = '', strCriteria = '= 0', intMasterId = 17925
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '9', strType = '', strCriteria = '= 0', intMasterId = 17926
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '1', strType = '', strCriteria = '<> 0', intMasterId = 17927
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '1', strType = '', strCriteria = '<> 0', intMasterId = 17928
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '5DIL', strType = '', strCriteria = '<> 0', intMasterId = 17929
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '5DIN', strType = '', strCriteria = '<> 0', intMasterId = 17930
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '5DTN', strType = '', strCriteria = '<> 0', intMasterId = 17931
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '6', strType = '', strCriteria = '= 0', intMasterId = 17932
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', strCriteria = '<> 0', intMasterId = 17933
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', strCriteria = '<> 0', intMasterId = 17934
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', strCriteria = '<> 0', intMasterId = 17935
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '6', strType = '', strCriteria = '= 0', intMasterId = 17936
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '3OH', strType = '', strCriteria = '= 0', intMasterId = 17937
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '3VA', strType = '', strCriteria = '= 0', intMasterId = 17938
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '3WV', strType = '', strCriteria = '= 0', intMasterId = 17939
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '5DOH', strType = '', strCriteria = '<> 0', intMasterId = 17940
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '5DVA', strType = '', strCriteria = '<> 0', intMasterId = 17941
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Gasoline', strState = 'KY', strFormCode = '72A089', strScheduleCode = '5DWV', strType = '', strCriteria = '<> 0', intMasterId = 17942
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '3OH', strType = '', strCriteria = '= 0', intMasterId = 17943
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '3VA', strType = '', strCriteria = '= 0', intMasterId = 17944
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '3WV', strType = '', strCriteria = '= 0', intMasterId = 17945
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', strCriteria = '<> 0', intMasterId = 17946
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', strCriteria = '<> 0', intMasterId = 17947
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KY Excise Tax Special Fuels', strState = 'KY', strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', strCriteria = '<> 0', intMasterId = 17948

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
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '3IL', strType = '', intMasterId = 178556
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '3IL', strType = '', intMasterId = 178557
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '3IL', strType = '', intMasterId = 178558
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '3IL', strType = '', intMasterId = 178559
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '3IL', strType = '', intMasterId = 178560
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '3IL', strType = '', intMasterId = 178561
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '3IL', strType = '', intMasterId = 178562
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '3IL', strType = '', intMasterId = 178563
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '3IL', strType = '', intMasterId = 178564
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '3IL', strType = '', intMasterId = 178565
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '3IL', strType = '', intMasterId = 178566
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '3IL', strType = '', intMasterId = 178567
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '3IL', strType = '', intMasterId = 178568
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '3IL', strType = '', intMasterId = 178569
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '3IL', strType = '', intMasterId = 178570
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '3IL', strType = '', intMasterId = 178571
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '3IL', strType = '', intMasterId = 178572
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '3IL', strType = '', intMasterId = 178573
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '3IL', strType = '', intMasterId = 178574
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '3IL', strType = '', intMasterId = 178575
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '3IL', strType = '', intMasterId = 178576
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '3IL', strType = '', intMasterId = 178577
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '3IL', strType = '', intMasterId = 178578
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '3IL', strType = '', intMasterId = 178579
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '3IN', strType = '', intMasterId = 178580
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '3IN', strType = '', intMasterId = 178581
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '3IN', strType = '', intMasterId = 178582
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '3IN', strType = '', intMasterId = 178583
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '3IN', strType = '', intMasterId = 178584
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '3IN', strType = '', intMasterId = 178585
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '3IN', strType = '', intMasterId = 178586
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '3IN', strType = '', intMasterId = 178587
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '3IN', strType = '', intMasterId = 178588
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '3IN', strType = '', intMasterId = 178589
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '3IN', strType = '', intMasterId = 178590
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '3IN', strType = '', intMasterId = 178591
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '3IN', strType = '', intMasterId = 178592
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '3IN', strType = '', intMasterId = 178593
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '3IN', strType = '', intMasterId = 178594
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '3IN', strType = '', intMasterId = 178595
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '3IN', strType = '', intMasterId = 178596
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '3IN', strType = '', intMasterId = 178597
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '3IN', strType = '', intMasterId = 178598
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '3IN', strType = '', intMasterId = 178599
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '3IN', strType = '', intMasterId = 178600
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '3IN', strType = '', intMasterId = 178601
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '3IN', strType = '', intMasterId = 178602
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '3IN', strType = '', intMasterId = 178603
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '3TN', strType = '', intMasterId = 178604
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '3TN', strType = '', intMasterId = 178605
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '3TN', strType = '', intMasterId = 178606
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '3TN', strType = '', intMasterId = 178607
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '3TN', strType = '', intMasterId = 178608
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '3TN', strType = '', intMasterId = 178609
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '3TN', strType = '', intMasterId = 178610
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '3TN', strType = '', intMasterId = 178611
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '3TN', strType = '', intMasterId = 178612
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '3TN', strType = '', intMasterId = 178613
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '3TN', strType = '', intMasterId = 178614
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '3TN', strType = '', intMasterId = 178615
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '3TN', strType = '', intMasterId = 178616
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '3TN', strType = '', intMasterId = 178617
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '3TN', strType = '', intMasterId = 178618
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '3TN', strType = '', intMasterId = 178619
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '3TN', strType = '', intMasterId = 178620
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '3TN', strType = '', intMasterId = 178621
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '3TN', strType = '', intMasterId = 178622
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '3TN', strType = '', intMasterId = 178623
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '3TN', strType = '', intMasterId = 178624
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '3TN', strType = '', intMasterId = 178625
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '3TN', strType = '', intMasterId = 178626
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '3TN', strType = '', intMasterId = 178627
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', intMasterId = 178628
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', intMasterId = 178629
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', intMasterId = 178630
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', intMasterId = 178631
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', intMasterId = 178632
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', intMasterId = 178633
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', intMasterId = 178634
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', intMasterId = 178635
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', intMasterId = 178636
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', intMasterId = 178637
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', intMasterId = 178638
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', intMasterId = 178639
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', intMasterId = 178640
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', intMasterId = 178641
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', intMasterId = 178642
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', intMasterId = 178643
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', intMasterId = 178644
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', intMasterId = 178645
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', intMasterId = 178646
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', intMasterId = 178647
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', intMasterId = 178648
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', intMasterId = 178649
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', intMasterId = 178650
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', intMasterId = 178651
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', intMasterId = 178652
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', intMasterId = 178653
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', intMasterId = 178654
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', intMasterId = 178655
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', intMasterId = 178656
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', intMasterId = 178657
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', intMasterId = 178658
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', intMasterId = 178659
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', intMasterId = 178660
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', intMasterId = 178661
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', intMasterId = 178662
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', intMasterId = 178663
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', intMasterId = 178664
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', intMasterId = 178665
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', intMasterId = 178666
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', intMasterId = 178667
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', intMasterId = 178668
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', intMasterId = 178669
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', intMasterId = 178670
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', intMasterId = 178671
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', intMasterId = 178672
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', intMasterId = 178673
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', intMasterId = 178674
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', intMasterId = 178675
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', intMasterId = 178676
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', intMasterId = 178677
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', intMasterId = 178678
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', intMasterId = 178679
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', intMasterId = 178680
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', intMasterId = 178681
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', intMasterId = 178682
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', intMasterId = 178683
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', intMasterId = 178684
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', intMasterId = 178685
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', intMasterId = 178686
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', intMasterId = 178687
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', intMasterId = 178688
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', intMasterId = 178689
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', intMasterId = 178690
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', intMasterId = 178691
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', intMasterId = 178692
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', intMasterId = 178693
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', intMasterId = 178694
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', intMasterId = 178695
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', intMasterId = 178696
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', intMasterId = 178697
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', intMasterId = 178698
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', intMasterId = 178699
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
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '7IL', strType = '', intMasterId = 178724
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '7IL', strType = '', intMasterId = 178725
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '7IL', strType = '', intMasterId = 178726
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '7IL', strType = '', intMasterId = 178727
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '7IL', strType = '', intMasterId = 178728
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '7IL', strType = '', intMasterId = 178729
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '7IL', strType = '', intMasterId = 178730
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '7IL', strType = '', intMasterId = 178731
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '7IL', strType = '', intMasterId = 178732
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '7IL', strType = '', intMasterId = 178733
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '7IL', strType = '', intMasterId = 178734
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '7IL', strType = '', intMasterId = 178735
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '7IL', strType = '', intMasterId = 178736
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '7IL', strType = '', intMasterId = 178737
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '7IL', strType = '', intMasterId = 178738
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '7IL', strType = '', intMasterId = 178739
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '7IL', strType = '', intMasterId = 178740
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '7IL', strType = '', intMasterId = 178741
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '7IL', strType = '', intMasterId = 178742
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '7IL', strType = '', intMasterId = 178743
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '7IL', strType = '', intMasterId = 178744
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '7IL', strType = '', intMasterId = 178745
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '7IL', strType = '', intMasterId = 178746
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '7IL', strType = '', intMasterId = 178747
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '7IN', strType = '', intMasterId = 178748
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '7IN', strType = '', intMasterId = 178749
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '7IN', strType = '', intMasterId = 178750
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '7IN', strType = '', intMasterId = 178751
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '7IN', strType = '', intMasterId = 178752
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '7IN', strType = '', intMasterId = 178753
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '7IN', strType = '', intMasterId = 178754
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '7IN', strType = '', intMasterId = 178755
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '7IN', strType = '', intMasterId = 178756
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '7IN', strType = '', intMasterId = 178757
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '7IN', strType = '', intMasterId = 178758
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '7IN', strType = '', intMasterId = 178759
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '7IN', strType = '', intMasterId = 178760
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '7IN', strType = '', intMasterId = 178761
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '7IN', strType = '', intMasterId = 178762
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '7IN', strType = '', intMasterId = 178763
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '7IN', strType = '', intMasterId = 178764
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '7IN', strType = '', intMasterId = 178765
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '7IN', strType = '', intMasterId = 178766
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '7IN', strType = '', intMasterId = 178767
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '7IN', strType = '', intMasterId = 178768
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '7IN', strType = '', intMasterId = 178769
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '7IN', strType = '', intMasterId = 178770
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '7IN', strType = '', intMasterId = 178771
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '7TN', strType = '', intMasterId = 178772
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '7TN', strType = '', intMasterId = 178773
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '7TN', strType = '', intMasterId = 178774
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '7TN', strType = '', intMasterId = 178775
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '7TN', strType = '', intMasterId = 178776
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '7TN', strType = '', intMasterId = 178777
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '7TN', strType = '', intMasterId = 178778
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '7TN', strType = '', intMasterId = 178779
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '7TN', strType = '', intMasterId = 178780
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '7TN', strType = '', intMasterId = 178781
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '7TN', strType = '', intMasterId = 178782
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '7TN', strType = '', intMasterId = 178783
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '7TN', strType = '', intMasterId = 178784
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '7TN', strType = '', intMasterId = 178785
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '7TN', strType = '', intMasterId = 178786
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '7TN', strType = '', intMasterId = 178787
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '7TN', strType = '', intMasterId = 178788
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '7TN', strType = '', intMasterId = 178789
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '7TN', strType = '', intMasterId = 178790
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '7TN', strType = '', intMasterId = 178791
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '7TN', strType = '', intMasterId = 178792
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '7TN', strType = '', intMasterId = 178793
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '7TN', strType = '', intMasterId = 178794
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '7TN', strType = '', intMasterId = 178795
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
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '7TN', strType = '', intMasterId = 178421
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '7TN', strType = '', intMasterId = 178422
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '7TN', strType = '', intMasterId = 178423
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '7TN', strType = '', intMasterId = 178424
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '7TN', strType = '', intMasterId = 178425
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '7TN', strType = '', intMasterId = 178426
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '7TN', strType = '', intMasterId = 178427
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '7TN', strType = '', intMasterId = 178428
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '7TN', strType = '', intMasterId = 178429
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '7TN', strType = '', intMasterId = 178430
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '7TN', strType = '', intMasterId = 178431
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '7TN', strType = '', intMasterId = 178432
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '7TN', strType = '', intMasterId = 178433
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '7IN', strType = '', intMasterId = 178408
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '7IN', strType = '', intMasterId = 178409
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '7IN', strType = '', intMasterId = 178410
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '7IN', strType = '', intMasterId = 178411
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '7IN', strType = '', intMasterId = 178412
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '7IN', strType = '', intMasterId = 178413
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '7IN', strType = '', intMasterId = 178414
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '7IN', strType = '', intMasterId = 178415
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '7IN', strType = '', intMasterId = 178416
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '7IN', strType = '', intMasterId = 178417
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '7IN', strType = '', intMasterId = 178418
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '7IN', strType = '', intMasterId = 178419
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '7IN', strType = '', intMasterId = 178420
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '7IL', strType = '', intMasterId = 178395
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '7IL', strType = '', intMasterId = 178396
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '7IL', strType = '', intMasterId = 178397
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '7IL', strType = '', intMasterId = 178398
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '7IL', strType = '', intMasterId = 178399
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '7IL', strType = '', intMasterId = 178400
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '7IL', strType = '', intMasterId = 178401
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '7IL', strType = '', intMasterId = 178402
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '7IL', strType = '', intMasterId = 178403
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '7IL', strType = '', intMasterId = 178404
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '7IL', strType = '', intMasterId = 178405
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '7IL', strType = '', intMasterId = 178406
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '7IL', strType = '', intMasterId = 178407
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
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '5DTN', strType = '', intMasterId = 178369
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '5DTN', strType = '', intMasterId = 178370
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '5DTN', strType = '', intMasterId = 178371
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '5DTN', strType = '', intMasterId = 178372
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '5DTN', strType = '', intMasterId = 178373
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '5DTN', strType = '', intMasterId = 178374
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '5DTN', strType = '', intMasterId = 178375
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '5DTN', strType = '', intMasterId = 178376
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '5DTN', strType = '', intMasterId = 178377
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '5DTN', strType = '', intMasterId = 178378
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '5DTN', strType = '', intMasterId = 178379
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '5DTN', strType = '', intMasterId = 178380
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '5DTN', strType = '', intMasterId = 178381
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '5DIN', strType = '', intMasterId = 178356
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '5DIN', strType = '', intMasterId = 178357
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '5DIN', strType = '', intMasterId = 178358
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '5DIN', strType = '', intMasterId = 178359
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '5DIN', strType = '', intMasterId = 178360
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '5DIN', strType = '', intMasterId = 178361
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '5DIN', strType = '', intMasterId = 178362
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '5DIN', strType = '', intMasterId = 178363
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '5DIN', strType = '', intMasterId = 178364
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '5DIN', strType = '', intMasterId = 178365
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '5DIN', strType = '', intMasterId = 178366
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '5DIN', strType = '', intMasterId = 178367
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '5DIN', strType = '', intMasterId = 178368
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '5DIL', strType = '', intMasterId = 178343
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '5DIL', strType = '', intMasterId = 178344
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '5DIL', strType = '', intMasterId = 178345
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '5DIL', strType = '', intMasterId = 178346
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '5DIL', strType = '', intMasterId = 178347
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '5DIL', strType = '', intMasterId = 178348
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '5DIL', strType = '', intMasterId = 178349
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '5DIL', strType = '', intMasterId = 178350
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '5DIL', strType = '', intMasterId = 178351
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '5DIL', strType = '', intMasterId = 178352
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '5DIL', strType = '', intMasterId = 178353
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '5DIL', strType = '', intMasterId = 178354
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '5DIL', strType = '', intMasterId = 178355
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '3TN', strType = '', intMasterId = 178330
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '3TN', strType = '', intMasterId = 178331
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '3TN', strType = '', intMasterId = 178332
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '3TN', strType = '', intMasterId = 178333
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '3TN', strType = '', intMasterId = 178334
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '3TN', strType = '', intMasterId = 178335
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '3TN', strType = '', intMasterId = 178336
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '3TN', strType = '', intMasterId = 178337
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '3TN', strType = '', intMasterId = 178338
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '3TN', strType = '', intMasterId = 178339
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '3TN', strType = '', intMasterId = 178340
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '3TN', strType = '', intMasterId = 178341
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '3TN', strType = '', intMasterId = 178342
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '3IN', strType = '', intMasterId = 178317
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '3IN', strType = '', intMasterId = 178318
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '3IN', strType = '', intMasterId = 178319
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '3IN', strType = '', intMasterId = 178320
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '3IN', strType = '', intMasterId = 178321
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '3IN', strType = '', intMasterId = 178322
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '3IN', strType = '', intMasterId = 178323
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '3IN', strType = '', intMasterId = 178324
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '3IN', strType = '', intMasterId = 178325
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '3IN', strType = '', intMasterId = 178326
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '3IN', strType = '', intMasterId = 178327
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '3IN', strType = '', intMasterId = 178328
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '3IN', strType = '', intMasterId = 178329
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '3IL', strType = '', intMasterId = 178304
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '3IL', strType = '', intMasterId = 178305
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '3IL', strType = '', intMasterId = 178306
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '3IL', strType = '', intMasterId = 178307
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '3IL', strType = '', intMasterId = 178308
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '3IL', strType = '', intMasterId = 178309
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '3IL', strType = '', intMasterId = 178310
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '3IL', strType = '', intMasterId = 178311
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '3IL', strType = '', intMasterId = 178312
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '3IL', strType = '', intMasterId = 178313
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '3IL', strType = '', intMasterId = 178314
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '3IL', strType = '', intMasterId = 178315
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '3IL', strType = '', intMasterId = 178316
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

	
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '3OH', strType = '', intMasterId = 178964
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '3OH', strType = '', intMasterId = 178965
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '3OH', strType = '', intMasterId = 178966
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '3OH', strType = '', intMasterId = 178967
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '3OH', strType = '', intMasterId = 178968
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '3OH', strType = '', intMasterId = 178969
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '3OH', strType = '', intMasterId = 178970
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '3OH', strType = '', intMasterId = 178971
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '3OH', strType = '', intMasterId = 178972
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '3OH', strType = '', intMasterId = 178973
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '3OH', strType = '', intMasterId = 178974
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '3OH', strType = '', intMasterId = 178975
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '3OH', strType = '', intMasterId = 178976
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '3VA', strType = '', intMasterId = 178977
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '3VA', strType = '', intMasterId = 178978
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '3VA', strType = '', intMasterId = 178979
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '3VA', strType = '', intMasterId = 178980
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '3VA', strType = '', intMasterId = 178981
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '3VA', strType = '', intMasterId = 178982
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '3VA', strType = '', intMasterId = 178983
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '3VA', strType = '', intMasterId = 178984
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '3VA', strType = '', intMasterId = 178985
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '3VA', strType = '', intMasterId = 178986
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '3VA', strType = '', intMasterId = 178987
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '3VA', strType = '', intMasterId = 178988
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '3VA', strType = '', intMasterId = 178989
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '3WV', strType = '', intMasterId = 178990
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '3WV', strType = '', intMasterId = 178991
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '3WV', strType = '', intMasterId = 178992
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '3WV', strType = '', intMasterId = 178993
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '3WV', strType = '', intMasterId = 178994
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '3WV', strType = '', intMasterId = 178995
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '3WV', strType = '', intMasterId = 178996
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '3WV', strType = '', intMasterId = 178997
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '3WV', strType = '', intMasterId = 178998
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '3WV', strType = '', intMasterId = 178999
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '3WV', strType = '', intMasterId = 179000
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '3WV', strType = '', intMasterId = 179001
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '3WV', strType = '', intMasterId = 179002
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '5DOH', strType = '', intMasterId = 179003
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '5DOH', strType = '', intMasterId = 179004
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '5DOH', strType = '', intMasterId = 179005
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '5DOH', strType = '', intMasterId = 179006
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '5DOH', strType = '', intMasterId = 179007
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '5DOH', strType = '', intMasterId = 179008
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '5DOH', strType = '', intMasterId = 179009
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '5DOH', strType = '', intMasterId = 179010
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '5DOH', strType = '', intMasterId = 179011
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '5DOH', strType = '', intMasterId = 179012
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '5DOH', strType = '', intMasterId = 179013
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '5DOH', strType = '', intMasterId = 179014
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '5DOH', strType = '', intMasterId = 179015
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '5DVA', strType = '', intMasterId = 179016
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '5DVA', strType = '', intMasterId = 179017
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '5DVA', strType = '', intMasterId = 179018
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '5DVA', strType = '', intMasterId = 179019
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '5DVA', strType = '', intMasterId = 179020
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '5DVA', strType = '', intMasterId = 179021
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '5DVA', strType = '', intMasterId = 179022
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '5DVA', strType = '', intMasterId = 179023
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '5DVA', strType = '', intMasterId = 179024
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '5DVA', strType = '', intMasterId = 179025
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '5DVA', strType = '', intMasterId = 179026
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '5DVA', strType = '', intMasterId = 179027
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '5DVA', strType = '', intMasterId = 179028
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '5DWV', strType = '', intMasterId = 179029
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '5DWV', strType = '', intMasterId = 179030
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '5DWV', strType = '', intMasterId = 179031
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '5DWV', strType = '', intMasterId = 179032
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '5DWV', strType = '', intMasterId = 179033
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '5DWV', strType = '', intMasterId = 179034
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '5DWV', strType = '', intMasterId = 179035
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '5DWV', strType = '', intMasterId = 179036
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '5DWV', strType = '', intMasterId = 179037
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '5DWV', strType = '', intMasterId = 179038
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '5DWV', strType = '', intMasterId = 179039
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '5DWV', strType = '', intMasterId = 179040
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '5DWV', strType = '', intMasterId = 179041
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '7OH', strType = '', intMasterId = 179042
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '7OH', strType = '', intMasterId = 179043
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '7OH', strType = '', intMasterId = 179044
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '7OH', strType = '', intMasterId = 179045
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '7OH', strType = '', intMasterId = 179046
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '7OH', strType = '', intMasterId = 179047
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '7OH', strType = '', intMasterId = 179048
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '7OH', strType = '', intMasterId = 179049
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '7OH', strType = '', intMasterId = 179050
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '7OH', strType = '', intMasterId = 179051
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '7OH', strType = '', intMasterId = 179052
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '7OH', strType = '', intMasterId = 179053
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '7OH', strType = '', intMasterId = 179054
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '7VA', strType = '', intMasterId = 179055
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '7VA', strType = '', intMasterId = 179056
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '7VA', strType = '', intMasterId = 179057
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '7VA', strType = '', intMasterId = 179058
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '7VA', strType = '', intMasterId = 179059
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '7VA', strType = '', intMasterId = 179060
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '7VA', strType = '', intMasterId = 179061
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '7VA', strType = '', intMasterId = 179062
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '7VA', strType = '', intMasterId = 179063
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '7VA', strType = '', intMasterId = 179064
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '7VA', strType = '', intMasterId = 179065
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '7VA', strType = '', intMasterId = 179066
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '7VA', strType = '', intMasterId = 179067
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '061', strFormCode = '72A089', strScheduleCode = '7WV', strType = '', intMasterId = 179068
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '72A089', strScheduleCode = '7WV', strType = '', intMasterId = 179069
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = '72A089', strScheduleCode = '7WV', strType = '', intMasterId = 179070
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '092', strFormCode = '72A089', strScheduleCode = '7WV', strType = '', intMasterId = 179071
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '72A089', strScheduleCode = '7WV', strType = '', intMasterId = 179072
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = '72A089', strScheduleCode = '7WV', strType = '', intMasterId = 179073
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '72A089', strScheduleCode = '7WV', strType = '', intMasterId = 179074
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '72A089', strScheduleCode = '7WV', strType = '', intMasterId = 179075
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '280', strFormCode = '72A089', strScheduleCode = '7WV', strType = '', intMasterId = 179076
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = '72A089', strScheduleCode = '7WV', strType = '', intMasterId = 179077
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = '72A089', strScheduleCode = '7WV', strType = '', intMasterId = 179078
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = '72A089', strScheduleCode = '7WV', strType = '', intMasterId = 179079
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = '72A089', strScheduleCode = '7WV', strType = '', intMasterId = 179080

	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '3OH', strType = '', intMasterId = 179081
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '3OH', strType = '', intMasterId = 179082
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '3OH', strType = '', intMasterId = 179083
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '3OH', strType = '', intMasterId = 179084
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '3OH', strType = '', intMasterId = 179085
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '3OH', strType = '', intMasterId = 179086
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '3OH', strType = '', intMasterId = 179087
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '3OH', strType = '', intMasterId = 179088
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '3OH', strType = '', intMasterId = 179089
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '3OH', strType = '', intMasterId = 179090
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '3OH', strType = '', intMasterId = 179091
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '3OH', strType = '', intMasterId = 179092
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '3OH', strType = '', intMasterId = 179093
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '3OH', strType = '', intMasterId = 179094
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '3OH', strType = '', intMasterId = 179095
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '3OH', strType = '', intMasterId = 179096
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '3OH', strType = '', intMasterId = 179097
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '3OH', strType = '', intMasterId = 179098
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '3OH', strType = '', intMasterId = 179099
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '3OH', strType = '', intMasterId = 179100
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '3OH', strType = '', intMasterId = 179101
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '3OH', strType = '', intMasterId = 179102
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '3OH', strType = '', intMasterId = 179103
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '3OH', strType = '', intMasterId = 179104
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '3VA', strType = '', intMasterId = 179105
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '3VA', strType = '', intMasterId = 179106
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '3VA', strType = '', intMasterId = 179107
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '3VA', strType = '', intMasterId = 179108
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '3VA', strType = '', intMasterId = 179109
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '3VA', strType = '', intMasterId = 179110
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '3VA', strType = '', intMasterId = 179111
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '3VA', strType = '', intMasterId = 179112
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '3VA', strType = '', intMasterId = 179113
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '3VA', strType = '', intMasterId = 179114
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '3VA', strType = '', intMasterId = 179115
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '3VA', strType = '', intMasterId = 179116
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '3VA', strType = '', intMasterId = 179117
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '3VA', strType = '', intMasterId = 179118
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '3VA', strType = '', intMasterId = 179119
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '3VA', strType = '', intMasterId = 179120
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '3VA', strType = '', intMasterId = 179121
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '3VA', strType = '', intMasterId = 179122
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '3VA', strType = '', intMasterId = 179123
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '3VA', strType = '', intMasterId = 179124
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '3VA', strType = '', intMasterId = 179125
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '3VA', strType = '', intMasterId = 179126
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '3VA', strType = '', intMasterId = 179127
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '3VA', strType = '', intMasterId = 179128
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '3WV', strType = '', intMasterId = 179129
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '3WV', strType = '', intMasterId = 179130
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '3WV', strType = '', intMasterId = 179131
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '3WV', strType = '', intMasterId = 179132
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '3WV', strType = '', intMasterId = 179133
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '3WV', strType = '', intMasterId = 179134
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '3WV', strType = '', intMasterId = 179135
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '3WV', strType = '', intMasterId = 179136
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '3WV', strType = '', intMasterId = 179137
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '3WV', strType = '', intMasterId = 179138
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '3WV', strType = '', intMasterId = 179139
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '3WV', strType = '', intMasterId = 179140
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '3WV', strType = '', intMasterId = 179141
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '3WV', strType = '', intMasterId = 179142
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '3WV', strType = '', intMasterId = 179143
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '3WV', strType = '', intMasterId = 179144
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '3WV', strType = '', intMasterId = 179145
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '3WV', strType = '', intMasterId = 179146
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '3WV', strType = '', intMasterId = 179147
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '3WV', strType = '', intMasterId = 179148
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '3WV', strType = '', intMasterId = 179149
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '3WV', strType = '', intMasterId = 179150
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '3WV', strType = '', intMasterId = 179151
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '3WV', strType = '', intMasterId = 179152
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', intMasterId = 179153
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', intMasterId = 179154
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', intMasterId = 179155
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', intMasterId = 179156
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', intMasterId = 179157
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', intMasterId = 179158
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', intMasterId = 179159
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', intMasterId = 179160
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', intMasterId = 179161
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', intMasterId = 179162
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', intMasterId = 179163
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', intMasterId = 179164
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', intMasterId = 179165
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', intMasterId = 179166
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', intMasterId = 179167
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', intMasterId = 179168
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', intMasterId = 179169
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', intMasterId = 179170
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', intMasterId = 179171
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', intMasterId = 179172
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', intMasterId = 179173
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', intMasterId = 179174
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', intMasterId = 179175
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', intMasterId = 179176
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', intMasterId = 179177
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', intMasterId = 179178
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', intMasterId = 179179
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', intMasterId = 179180
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', intMasterId = 179181
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', intMasterId = 179182
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', intMasterId = 179183
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', intMasterId = 179184
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', intMasterId = 179185
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', intMasterId = 179186
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', intMasterId = 179187
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', intMasterId = 179188
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', intMasterId = 179189
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', intMasterId = 179190
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', intMasterId = 179191
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', intMasterId = 179192
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', intMasterId = 179193
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', intMasterId = 179194
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', intMasterId = 179195
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', intMasterId = 179196
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', intMasterId = 179197
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', intMasterId = 179198
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', intMasterId = 179199
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', intMasterId = 179200
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', intMasterId = 179201
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', intMasterId = 179202
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', intMasterId = 179203
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', intMasterId = 179204
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', intMasterId = 179205
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', intMasterId = 179206
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', intMasterId = 179207
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', intMasterId = 179208
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', intMasterId = 179209
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', intMasterId = 179210
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', intMasterId = 179211
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', intMasterId = 179212
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', intMasterId = 179213
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', intMasterId = 179214
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', intMasterId = 179215
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', intMasterId = 179216
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', intMasterId = 179217
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', intMasterId = 179218
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', intMasterId = 179219
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', intMasterId = 179220
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', intMasterId = 179221
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', intMasterId = 179222
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', intMasterId = 179223
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', intMasterId = 179224
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '7OH', strType = '', intMasterId = 179225
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '7OH', strType = '', intMasterId = 179226
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '7OH', strType = '', intMasterId = 179227
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '7OH', strType = '', intMasterId = 179228
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '7OH', strType = '', intMasterId = 179229
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '7OH', strType = '', intMasterId = 179230
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '7OH', strType = '', intMasterId = 179231
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '7OH', strType = '', intMasterId = 179232
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '7OH', strType = '', intMasterId = 179233
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '7OH', strType = '', intMasterId = 179234
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '7OH', strType = '', intMasterId = 179235
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '7OH', strType = '', intMasterId = 179236
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '7OH', strType = '', intMasterId = 179237
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '7OH', strType = '', intMasterId = 179238
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '7OH', strType = '', intMasterId = 179239
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '7OH', strType = '', intMasterId = 179240
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '7OH', strType = '', intMasterId = 179241
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '7OH', strType = '', intMasterId = 179242
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '7OH', strType = '', intMasterId = 179243
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '7OH', strType = '', intMasterId = 179244
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '7OH', strType = '', intMasterId = 179245
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '7OH', strType = '', intMasterId = 179246
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '7OH', strType = '', intMasterId = 179247
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '7OH', strType = '', intMasterId = 179248
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '7VA', strType = '', intMasterId = 179249
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '7VA', strType = '', intMasterId = 179250
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '7VA', strType = '', intMasterId = 179251
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '7VA', strType = '', intMasterId = 179252
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '7VA', strType = '', intMasterId = 179253
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '7VA', strType = '', intMasterId = 179254
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '7VA', strType = '', intMasterId = 179255
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '7VA', strType = '', intMasterId = 179256
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '7VA', strType = '', intMasterId = 179257
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '7VA', strType = '', intMasterId = 179258
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '7VA', strType = '', intMasterId = 179259
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '7VA', strType = '', intMasterId = 179260
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '7VA', strType = '', intMasterId = 179261
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '7VA', strType = '', intMasterId = 179262
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '7VA', strType = '', intMasterId = 179263
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '7VA', strType = '', intMasterId = 179264
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '7VA', strType = '', intMasterId = 179265
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '7VA', strType = '', intMasterId = 179266
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '7VA', strType = '', intMasterId = 179267
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '7VA', strType = '', intMasterId = 179268
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '7VA', strType = '', intMasterId = 179269
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '7VA', strType = '', intMasterId = 179270
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '7VA', strType = '', intMasterId = 179271
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '7VA', strType = '', intMasterId = 179272
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '72A138', strScheduleCode = '7WV', strType = '', intMasterId = 179273
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = '72A138', strScheduleCode = '7WV', strType = '', intMasterId = 179274
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = '72A138', strScheduleCode = '7WV', strType = '', intMasterId = 179275
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = '72A138', strScheduleCode = '7WV', strType = '', intMasterId = 179276
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = '72A138', strScheduleCode = '7WV', strType = '', intMasterId = 179277
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '72A138', strScheduleCode = '7WV', strType = '', intMasterId = 179278
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = '72A138', strScheduleCode = '7WV', strType = '', intMasterId = 179279
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = '72A138', strScheduleCode = '7WV', strType = '', intMasterId = 179280
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = '72A138', strScheduleCode = '7WV', strType = '', intMasterId = 179281
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = '72A138', strScheduleCode = '7WV', strType = '', intMasterId = 179282
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '72A138', strScheduleCode = '7WV', strType = '', intMasterId = 179283
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = '72A138', strScheduleCode = '7WV', strType = '', intMasterId = 179284
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = '72A138', strScheduleCode = '7WV', strType = '', intMasterId = 179285
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = '72A138', strScheduleCode = '7WV', strType = '', intMasterId = 179286
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = '72A138', strScheduleCode = '7WV', strType = '', intMasterId = 179287
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = '72A138', strScheduleCode = '7WV', strType = '', intMasterId = 179288
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = '72A138', strScheduleCode = '7WV', strType = '', intMasterId = 179289
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '72A138', strScheduleCode = '7WV', strType = '', intMasterId = 179290
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = '72A138', strScheduleCode = '7WV', strType = '', intMasterId = 179291
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '279', strFormCode = '72A138', strScheduleCode = '7WV', strType = '', intMasterId = 179292
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = '72A138', strScheduleCode = '7WV', strType = '', intMasterId = 179293
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = '72A138', strScheduleCode = '7WV', strType = '', intMasterId = 179294
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B11', strFormCode = '72A138', strScheduleCode = '7WV', strType = '', intMasterId = 179295
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = '72A138', strScheduleCode = '7WV', strType = '', intMasterId = 179296
	
	
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
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '3IL', strType = '', strState = 'IL', strStatus = 'Include', intMasterId = 171086
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '3IN', strType = '', strState = 'IN', strStatus = 'Include', intMasterId = 171087
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '3TN', strType = '', strState = 'TN', strStatus = 'Include', intMasterId = 171088
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '6', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171099
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '7IL', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171092
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '7IN', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171093
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '7TN', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171094
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '8', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171100
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '10A', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171105
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '10G', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171106
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '10I', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171107
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '10J', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171108
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '10Y', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171109
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '2', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171083
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '2A', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171084
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '2B', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171085
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '3IL', strType = '', strState = 'IL', strStatus = 'Include', intMasterId = 171089
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '3IN', strType = '', strState = 'IN', strStatus = 'Include', intMasterId = 171090
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '3TN', strType = '', strState = 'TN', strStatus = 'Include', intMasterId = 171091
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '6', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171102
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '7IL', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171095
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '7IN', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171096
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '7TN', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171097
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '8', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171103
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '9', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171104
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '3OH', strType = '', strState = 'OH', strStatus = 'Include', intMasterId = 171110
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '3VA', strType = '', strState = 'VA', strStatus = 'Include', intMasterId = 171111
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '3WV', strType = '', strState = 'WV', strStatus = 'Include', intMasterId = 171112
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '7OH', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171113
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '7VA', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171114
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A089', strScheduleCode = '7WV', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171115
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '3OH', strType = '', strState = 'OH', strStatus = 'Include', intMasterId = 171116
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '3VA', strType = '', strState = 'VA', strStatus = 'Include', intMasterId = 171117
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '3WV', strType = '', strState = 'WV', strStatus = 'Include', intMasterId = 171118
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '7OH', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171119
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '7VA', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171120
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '72A138', strScheduleCode = '7WV', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171121


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
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '3IL', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171049
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '3IN', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171050
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '3TN', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171051
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '6', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171062
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '7IL', strType = '', strState = 'IL', strStatus = 'Include', intMasterId = 171055
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '7IN', strType = '', strState = 'IN', strStatus = 'Include', intMasterId = 171056
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '7TN', strType = '', strState = 'TN', strStatus = 'Include', intMasterId = 171057
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
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '3IL', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171052
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '3IN', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171053
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '3TN', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171054
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '6', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171065
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '7IL', strType = '', strState = 'IL', strStatus = 'Include', intMasterId = 171058
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '7IN', strType = '', strState = 'IN', strStatus = 'Include', intMasterId = 171059
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '7TN', strType = '', strState = 'TN', strStatus = 'Include', intMasterId = 171060
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '8', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171066
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '9', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171067
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '3OH', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171073
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '3VA', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171074
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '3WV', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171075
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '7OH', strType = '', strState = 'OH', strStatus = 'Include', intMasterId = 171076
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '7VA', strType = '', strState = 'VA', strStatus = 'Include', intMasterId = 171077
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A089', strScheduleCode = '7WV', strType = '', strState = 'WV', strStatus = 'Include', intMasterId = 171078
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '3OH', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171079
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '3VA', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171080
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '3WV', strType = '', strState = 'KY', strStatus = 'Include', intMasterId = 171081
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '7OH', strType = '', strState = 'OH', strStatus = 'Include', intMasterId = 171082
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '7VA', strType = '', strState = 'VA', strStatus = 'Include', intMasterId = 171083
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '72A138', strScheduleCode = '7WV', strType = '', strState = 'WV', strStatus = 'Include', intMasterId = 171084

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
		, intMasterId
	)
	SELECT intReportTemplateId = 0, strFormCode = '72A089', strScheduleCode = '72A089', strType = '', strTemplateItemId = 'KYGas-Ln9', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '1', strDescription = 'Line 9 Gals lost through accountable losses', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '1', ysnOutputDesigner = 0, intMasterId = 171159
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A089', strScheduleCode = '72A089', strType = '', strTemplateItemId = 'KYGas-Ln12', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '2', strDescription = 'Line 12 Tax rate', strScheduleList = NULL, strConfiguration = '0.2460', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '2', ysnOutputDesigner = 0, intMasterId = 171160
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A089', strScheduleCode = '72A089', strType = '', strTemplateItemId = 'KYGas-Ln13a', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '3', strDescription = 'Line 13.a Tax rate adjustment - rate', strScheduleList = NULL, strConfiguration = '0.0000', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '3', ysnOutputDesigner = 0, intMasterId = 171161
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A089', strScheduleCode = '72A089', strType = '', strTemplateItemId = 'KYGas-Ln13b', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '4', strDescription = 'Line 13.b Tax rate adjustment - gallons', strScheduleList = NULL, strConfiguration = '0', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '4', ysnOutputDesigner = 0, intMasterId = 171162
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A089', strScheduleCode = '72A089', strType = '', strTemplateItemId = 'KYGas-Ln16', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '5', strDescription = 'Line 16 Tax rate for non-highway dealer credit', strScheduleList = NULL, strConfiguration = '0.2460', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '5', ysnOutputDesigner = 0, intMasterId = 171163
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A089', strScheduleCode = '72A089', strType = '', strTemplateItemId = 'KYGas-Ln18', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '6', strDescription = 'Line 18 Dealer compensation allowance rate', strScheduleList = NULL, strConfiguration = '0.0225', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '6', ysnOutputDesigner = 0, intMasterId = 171164
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A089', strScheduleCode = '72A089', strType = '', strTemplateItemId = 'KYGas-Ln20', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '7', strDescription = 'Line 20 Credits', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '7', ysnOutputDesigner = 0, intMasterId = 171165
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A089', strScheduleCode = '72A089', strType = '', strTemplateItemId = 'KYGas-StaGal', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '8', strDescription = 'Statistical gallons - fuel grade alcohol', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '8', ysnOutputDesigner = 0, intMasterId = 171166
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A138', strScheduleCode = '72A138', strType = '', strTemplateItemId = 'KYSF-Ln8', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '1', strDescription = 'Line 8 Gals lost through accountable losses', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '1', ysnOutputDesigner = 0, intMasterId = 171167
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A138', strScheduleCode = '72A138', strType = '', strTemplateItemId = 'KYSF-Ln11', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '2', strDescription = 'Line 11 Special Fuel used by licensed dealer for non-highway purposes', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '2', ysnOutputDesigner = 0, intMasterId = 171168
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A138', strScheduleCode = '72A138', strType = '', strTemplateItemId = 'KYSF-Ln14', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '3', strDescription = 'Line 14 Tax rate', strScheduleList = NULL, strConfiguration = '0.2160', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '3', ysnOutputDesigner = 0, intMasterId = 171169
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A138', strScheduleCode = '72A138', strType = '', strTemplateItemId = 'KYSF-Ln15a', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '4', strDescription = 'Line 15.a Tax rate adjustment - rate', strScheduleList = NULL, strConfiguration = '0.0000', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '4', ysnOutputDesigner = 0, intMasterId = 171170
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A138', strScheduleCode = '72A138', strType = '', strTemplateItemId = 'KYSF-Ln15b', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '5', strDescription = 'Line 15.b Tax rate adjustment - gallons', strScheduleList = NULL, strConfiguration = '0', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '5', ysnOutputDesigner = 0, intMasterId = 171171
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A138', strScheduleCode = '72A138', strType = '', strTemplateItemId = 'KYSF-Ln17', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '6', strDescription = 'Line 17 Tax rate for non-highway dealer credit', strScheduleList = NULL, strConfiguration = '0.2160', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '6', ysnOutputDesigner = 0, intMasterId = 171172
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A138', strScheduleCode = '72A138', strType = '', strTemplateItemId = 'KYSF-Ln20', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '7', strDescription = 'Line 20 Dealer compensation allowance rate', strScheduleList = NULL, strConfiguration = '0.0225', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '7', ysnOutputDesigner = 0, intMasterId = 171173
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = '72A138', strScheduleCode = '72A138', strType = '', strTemplateItemId = 'KYSF-Ln22', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '8', strDescription = 'Line 22 Credits', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '8', ysnOutputDesigner = 0, intMasterId = 171174
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-ISA01', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '1', strDescription = 'ISA01 - Authorization Information Qualifier', strScheduleList = NULL, strConfiguration = '3', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '1', ysnOutputDesigner = 0, intMasterId = 171220
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-ISA03', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '2', strDescription = 'ISA03 - Security Information Qualifier', strScheduleList = NULL, strConfiguration = '0', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '2', ysnOutputDesigner = 0, intMasterId = 171221
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-ISA05', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '3', strDescription = 'ISA05 - Interchange ID Qualifier', strScheduleList = NULL, strConfiguration = '32', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '3', ysnOutputDesigner = 0, intMasterId = 171222
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-ISA07', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '4', strDescription = 'ISA07 - Interchange ID Qualifier', strScheduleList = NULL, strConfiguration = '1', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '4', ysnOutputDesigner = 0, intMasterId = 171223
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-ISA08', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '5', strDescription = 'ISA08 - Interchange Receiver ID', strScheduleList = NULL, strConfiguration = '614553816T     ', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '5', ysnOutputDesigner = 0, intMasterId = 171224
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-ISA11', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '6', strDescription = 'ISA11 - Repetition Separator', strScheduleList = NULL, strConfiguration = '|', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '6', ysnOutputDesigner = 0, intMasterId = 171225
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-ISA12', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '7', strDescription = 'ISA12 - Interchange Control Version Number', strScheduleList = NULL, strConfiguration = '00403', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '7', ysnOutputDesigner = 0, intMasterId = 171226
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-ISA13', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '8', strDescription = 'ISA13 - Interchange Control Number (for next transmission)', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '8', ysnOutputDesigner = 0, intMasterId = 171227
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-ISA14', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '9', strDescription = 'ISA14 - Acknowledgement Requested', strScheduleList = NULL, strConfiguration = '0', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '9', ysnOutputDesigner = 0, intMasterId = 171228
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-ISA15', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '10', strDescription = 'ISA15 - Usage Indicator (P = Production; T = Test)', strScheduleList = NULL, strConfiguration = 'T', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '10', ysnOutputDesigner = 0, intMasterId = 171229
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-ISA16', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '11', strDescription = 'ISA16 - Component Sub-element Separator', strScheduleList = NULL, strConfiguration = '^', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '11', ysnOutputDesigner = 0, intMasterId = 171230
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-GS01', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '12', strDescription = 'GS01 - Functional Identifier Code', strScheduleList = NULL, strConfiguration = 'TF', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '12', ysnOutputDesigner = 0, intMasterId = 171231
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-GS02', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '13', strDescription = 'GS02 - Application Sender''s Code', strScheduleList = NULL, strConfiguration = 'KY606502', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '13', ysnOutputDesigner = 0, intMasterId = 171232
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-GS03', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '14', strDescription = 'GS03 - Receiver''s Code', strScheduleList = NULL, strConfiguration = '614553816T', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '14', ysnOutputDesigner = 0, intMasterId = 171233
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-GS06', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '15', strDescription = 'GS06 - Group Control Number (for next transmission)', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '15', ysnOutputDesigner = 0, intMasterId = 171234
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-GS07', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '16', strDescription = 'GS07 - Responsible Agency Code', strScheduleList = NULL, strConfiguration = 'X', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '16', ysnOutputDesigner = 0, intMasterId = 171235
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-GS08', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '17', strDescription = 'GS08 - Version/Release/Industry ID Code', strScheduleList = NULL, strConfiguration = '004030', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '17', ysnOutputDesigner = 0, intMasterId = 171236
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-ST01', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '18', strDescription = 'ST01 - Transaction Set Code', strScheduleList = NULL, strConfiguration = '813', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '18', ysnOutputDesigner = 0, intMasterId = 171237
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-ST02', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '19', strDescription = 'ST02 - Transaction Set Control Number (for next transmission)', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '19', ysnOutputDesigner = 0, intMasterId = 171238
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-ST03', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '20', strDescription = 'ST03 - Implementation Convention Reference', strScheduleList = NULL, strConfiguration = '1', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '20', ysnOutputDesigner = 0, intMasterId = 171239
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-BTI01', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '21', strDescription = 'BTI01 - Reference Number Qualifier', strScheduleList = NULL, strConfiguration = 'T6', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '21', ysnOutputDesigner = 0, intMasterId = 171240
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-BTI02', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '22', strDescription = 'BTI02 - Reference Number', strScheduleList = NULL, strConfiguration = '50', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '22', ysnOutputDesigner = 0, intMasterId = 171241
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-BTI03', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '23', strDescription = 'BTI03 - ID Code Qualifier', strScheduleList = NULL, strConfiguration = '47', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '23', ysnOutputDesigner = 0, intMasterId = 171242
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-BTI04', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '24', strDescription = 'BTI04 - ID Code', strScheduleList = NULL, strConfiguration = 'KY', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '24', ysnOutputDesigner = 0, intMasterId = 171243
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-BTI06', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '25', strDescription = 'BTI06 - Name Control ID (4-char business name)', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '25', ysnOutputDesigner = 0, intMasterId = 171244
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-BTI07', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '26', strDescription = 'BTI07 - ID Code Qualifier', strScheduleList = NULL, strConfiguration = '24', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '26', ysnOutputDesigner = 0, intMasterId = 171245
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-BTI13', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '27', strDescription = 'BTI13 - Transaction Set Purpose Code', strScheduleList = NULL, strConfiguration = '0', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '27', ysnOutputDesigner = 0, intMasterId = 171246
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-BTI14', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '28', strDescription = 'BTI14 - Transaction Type Code', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '28', ysnOutputDesigner = 0, intMasterId = 171247
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KYEDI-LicNum', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '29', strDescription = 'KY License Number (GD999999999 or SF999999999)', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '29', ysnOutputDesigner = 0, intMasterId = 171248

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
	UNION ALL SELECT intScheduleColumnId = 53, strFormCode = '72A089', strScheduleCode = '3IL', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726077
	UNION ALL SELECT intScheduleColumnId = 54, strFormCode = '72A089', strScheduleCode = '3IL', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726078
	UNION ALL SELECT intScheduleColumnId = 55, strFormCode = '72A089', strScheduleCode = '3IL', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726079
	UNION ALL SELECT intScheduleColumnId = 56, strFormCode = '72A089', strScheduleCode = '3IL', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726080
	UNION ALL SELECT intScheduleColumnId = 57, strFormCode = '72A089', strScheduleCode = '3IL', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726081
	UNION ALL SELECT intScheduleColumnId = 58, strFormCode = '72A089', strScheduleCode = '3IL', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726082
	UNION ALL SELECT intScheduleColumnId = 59, strFormCode = '72A089', strScheduleCode = '3IL', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726083
	UNION ALL SELECT intScheduleColumnId = 60, strFormCode = '72A089', strScheduleCode = '3IL', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726084
	UNION ALL SELECT intScheduleColumnId = 61, strFormCode = '72A089', strScheduleCode = '3IL', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726085
	UNION ALL SELECT intScheduleColumnId = 62, strFormCode = '72A089', strScheduleCode = '3IL', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726086
	UNION ALL SELECT intScheduleColumnId = 63, strFormCode = '72A089', strScheduleCode = '3IL', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726087
	UNION ALL SELECT intScheduleColumnId = 64, strFormCode = '72A089', strScheduleCode = '3IL', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726088
	UNION ALL SELECT intScheduleColumnId = 65, strFormCode = '72A089', strScheduleCode = '3IL', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726089
	UNION ALL SELECT intScheduleColumnId = 66, strFormCode = '72A089', strScheduleCode = '3IN', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726090
	UNION ALL SELECT intScheduleColumnId = 67, strFormCode = '72A089', strScheduleCode = '3IN', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726091
	UNION ALL SELECT intScheduleColumnId = 68, strFormCode = '72A089', strScheduleCode = '3IN', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726092
	UNION ALL SELECT intScheduleColumnId = 69, strFormCode = '72A089', strScheduleCode = '3IN', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726093
	UNION ALL SELECT intScheduleColumnId = 70, strFormCode = '72A089', strScheduleCode = '3IN', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726094
	UNION ALL SELECT intScheduleColumnId = 71, strFormCode = '72A089', strScheduleCode = '3IN', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726095
	UNION ALL SELECT intScheduleColumnId = 72, strFormCode = '72A089', strScheduleCode = '3IN', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726096
	UNION ALL SELECT intScheduleColumnId = 73, strFormCode = '72A089', strScheduleCode = '3IN', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726097
	UNION ALL SELECT intScheduleColumnId = 74, strFormCode = '72A089', strScheduleCode = '3IN', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726098
	UNION ALL SELECT intScheduleColumnId = 75, strFormCode = '72A089', strScheduleCode = '3IN', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726099
	UNION ALL SELECT intScheduleColumnId = 76, strFormCode = '72A089', strScheduleCode = '3IN', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726100
	UNION ALL SELECT intScheduleColumnId = 77, strFormCode = '72A089', strScheduleCode = '3IN', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726101
	UNION ALL SELECT intScheduleColumnId = 78, strFormCode = '72A089', strScheduleCode = '3IN', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726102
	UNION ALL SELECT intScheduleColumnId = 79, strFormCode = '72A089', strScheduleCode = '3TN', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726103
	UNION ALL SELECT intScheduleColumnId = 80, strFormCode = '72A089', strScheduleCode = '3TN', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726104
	UNION ALL SELECT intScheduleColumnId = 81, strFormCode = '72A089', strScheduleCode = '3TN', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726105
	UNION ALL SELECT intScheduleColumnId = 82, strFormCode = '72A089', strScheduleCode = '3TN', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726106
	UNION ALL SELECT intScheduleColumnId = 83, strFormCode = '72A089', strScheduleCode = '3TN', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726107
	UNION ALL SELECT intScheduleColumnId = 84, strFormCode = '72A089', strScheduleCode = '3TN', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726108
	UNION ALL SELECT intScheduleColumnId = 85, strFormCode = '72A089', strScheduleCode = '3TN', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726109
	UNION ALL SELECT intScheduleColumnId = 86, strFormCode = '72A089', strScheduleCode = '3TN', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726110
	UNION ALL SELECT intScheduleColumnId = 87, strFormCode = '72A089', strScheduleCode = '3TN', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726111
	UNION ALL SELECT intScheduleColumnId = 88, strFormCode = '72A089', strScheduleCode = '3TN', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726112
	UNION ALL SELECT intScheduleColumnId = 89, strFormCode = '72A089', strScheduleCode = '3TN', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726113
	UNION ALL SELECT intScheduleColumnId = 90, strFormCode = '72A089', strScheduleCode = '3TN', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726114
	UNION ALL SELECT intScheduleColumnId = 91, strFormCode = '72A089', strScheduleCode = '3TN', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726115
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
	UNION ALL SELECT intScheduleColumnId = 144, strFormCode = '72A138', strScheduleCode = '3IL', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726168
	UNION ALL SELECT intScheduleColumnId = 145, strFormCode = '72A138', strScheduleCode = '3IL', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726169
	UNION ALL SELECT intScheduleColumnId = 146, strFormCode = '72A138', strScheduleCode = '3IL', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726170
	UNION ALL SELECT intScheduleColumnId = 147, strFormCode = '72A138', strScheduleCode = '3IL', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726171
	UNION ALL SELECT intScheduleColumnId = 148, strFormCode = '72A138', strScheduleCode = '3IL', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726172
	UNION ALL SELECT intScheduleColumnId = 149, strFormCode = '72A138', strScheduleCode = '3IL', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726173
	UNION ALL SELECT intScheduleColumnId = 150, strFormCode = '72A138', strScheduleCode = '3IL', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726174
	UNION ALL SELECT intScheduleColumnId = 151, strFormCode = '72A138', strScheduleCode = '3IL', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726175
	UNION ALL SELECT intScheduleColumnId = 152, strFormCode = '72A138', strScheduleCode = '3IL', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726176
	UNION ALL SELECT intScheduleColumnId = 153, strFormCode = '72A138', strScheduleCode = '3IL', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726177
	UNION ALL SELECT intScheduleColumnId = 154, strFormCode = '72A138', strScheduleCode = '3IL', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726178
	UNION ALL SELECT intScheduleColumnId = 155, strFormCode = '72A138', strScheduleCode = '3IL', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726179
	UNION ALL SELECT intScheduleColumnId = 156, strFormCode = '72A138', strScheduleCode = '3IL', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726180
	UNION ALL SELECT intScheduleColumnId = 157, strFormCode = '72A138', strScheduleCode = '3IN', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726181
	UNION ALL SELECT intScheduleColumnId = 158, strFormCode = '72A138', strScheduleCode = '3IN', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726182
	UNION ALL SELECT intScheduleColumnId = 159, strFormCode = '72A138', strScheduleCode = '3IN', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726183
	UNION ALL SELECT intScheduleColumnId = 160, strFormCode = '72A138', strScheduleCode = '3IN', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726184
	UNION ALL SELECT intScheduleColumnId = 161, strFormCode = '72A138', strScheduleCode = '3IN', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726185
	UNION ALL SELECT intScheduleColumnId = 162, strFormCode = '72A138', strScheduleCode = '3IN', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726186
	UNION ALL SELECT intScheduleColumnId = 163, strFormCode = '72A138', strScheduleCode = '3IN', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726187
	UNION ALL SELECT intScheduleColumnId = 164, strFormCode = '72A138', strScheduleCode = '3IN', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726188
	UNION ALL SELECT intScheduleColumnId = 165, strFormCode = '72A138', strScheduleCode = '3IN', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726189
	UNION ALL SELECT intScheduleColumnId = 166, strFormCode = '72A138', strScheduleCode = '3IN', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726190
	UNION ALL SELECT intScheduleColumnId = 167, strFormCode = '72A138', strScheduleCode = '3IN', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726191
	UNION ALL SELECT intScheduleColumnId = 168, strFormCode = '72A138', strScheduleCode = '3IN', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726192
	UNION ALL SELECT intScheduleColumnId = 169, strFormCode = '72A138', strScheduleCode = '3IN', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726193
	UNION ALL SELECT intScheduleColumnId = 170, strFormCode = '72A138', strScheduleCode = '3TN', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726194
	UNION ALL SELECT intScheduleColumnId = 171, strFormCode = '72A138', strScheduleCode = '3TN', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726195
	UNION ALL SELECT intScheduleColumnId = 172, strFormCode = '72A138', strScheduleCode = '3TN', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726196
	UNION ALL SELECT intScheduleColumnId = 173, strFormCode = '72A138', strScheduleCode = '3TN', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726197
	UNION ALL SELECT intScheduleColumnId = 174, strFormCode = '72A138', strScheduleCode = '3TN', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726198
	UNION ALL SELECT intScheduleColumnId = 175, strFormCode = '72A138', strScheduleCode = '3TN', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726199
	UNION ALL SELECT intScheduleColumnId = 176, strFormCode = '72A138', strScheduleCode = '3TN', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726200
	UNION ALL SELECT intScheduleColumnId = 177, strFormCode = '72A138', strScheduleCode = '3TN', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726201
	UNION ALL SELECT intScheduleColumnId = 178, strFormCode = '72A138', strScheduleCode = '3TN', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726202
	UNION ALL SELECT intScheduleColumnId = 179, strFormCode = '72A138', strScheduleCode = '3TN', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726203
	UNION ALL SELECT intScheduleColumnId = 180, strFormCode = '72A138', strScheduleCode = '3TN', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726204
	UNION ALL SELECT intScheduleColumnId = 181, strFormCode = '72A138', strScheduleCode = '3TN', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726205
	UNION ALL SELECT intScheduleColumnId = 182, strFormCode = '72A138', strScheduleCode = '3TN', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726206
	UNION ALL SELECT intScheduleColumnId = 183, strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726207
	UNION ALL SELECT intScheduleColumnId = 184, strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726208
	UNION ALL SELECT intScheduleColumnId = 185, strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726209
	UNION ALL SELECT intScheduleColumnId = 186, strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726210
	UNION ALL SELECT intScheduleColumnId = 187, strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726211
	UNION ALL SELECT intScheduleColumnId = 188, strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726212
	UNION ALL SELECT intScheduleColumnId = 189, strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726213
	UNION ALL SELECT intScheduleColumnId = 190, strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726214
	UNION ALL SELECT intScheduleColumnId = 191, strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726215
	UNION ALL SELECT intScheduleColumnId = 192, strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726216
	UNION ALL SELECT intScheduleColumnId = 193, strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726217
	UNION ALL SELECT intScheduleColumnId = 194, strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726218
	UNION ALL SELECT intScheduleColumnId = 195, strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726219
	UNION ALL SELECT intScheduleColumnId = 196, strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726220
	UNION ALL SELECT intScheduleColumnId = 197, strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726221
	UNION ALL SELECT intScheduleColumnId = 198, strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726222
	UNION ALL SELECT intScheduleColumnId = 199, strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726223
	UNION ALL SELECT intScheduleColumnId = 200, strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726224
	UNION ALL SELECT intScheduleColumnId = 201, strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726225
	UNION ALL SELECT intScheduleColumnId = 202, strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726226
	UNION ALL SELECT intScheduleColumnId = 203, strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726227
	UNION ALL SELECT intScheduleColumnId = 204, strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726228
	UNION ALL SELECT intScheduleColumnId = 205, strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726229
	UNION ALL SELECT intScheduleColumnId = 206, strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726230
	UNION ALL SELECT intScheduleColumnId = 207, strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726231
	UNION ALL SELECT intScheduleColumnId = 208, strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726232
	UNION ALL SELECT intScheduleColumnId = 209, strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726233
	UNION ALL SELECT intScheduleColumnId = 210, strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726234
	UNION ALL SELECT intScheduleColumnId = 211, strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726235
	UNION ALL SELECT intScheduleColumnId = 212, strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726236
	UNION ALL SELECT intScheduleColumnId = 213, strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726237
	UNION ALL SELECT intScheduleColumnId = 214, strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726238
	UNION ALL SELECT intScheduleColumnId = 215, strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726239
	UNION ALL SELECT intScheduleColumnId = 216, strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726240
	UNION ALL SELECT intScheduleColumnId = 217, strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726241
	UNION ALL SELECT intScheduleColumnId = 218, strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726242
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
	UNION ALL SELECT intScheduleColumnId = 231, strFormCode = '72A138', strScheduleCode = '7IL', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726255
	UNION ALL SELECT intScheduleColumnId = 232, strFormCode = '72A138', strScheduleCode = '7IL', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726256
	UNION ALL SELECT intScheduleColumnId = 233, strFormCode = '72A138', strScheduleCode = '7IL', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726257
	UNION ALL SELECT intScheduleColumnId = 234, strFormCode = '72A138', strScheduleCode = '7IL', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726258
	UNION ALL SELECT intScheduleColumnId = 235, strFormCode = '72A138', strScheduleCode = '7IL', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726259
	UNION ALL SELECT intScheduleColumnId = 236, strFormCode = '72A138', strScheduleCode = '7IL', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726260
	UNION ALL SELECT intScheduleColumnId = 237, strFormCode = '72A138', strScheduleCode = '7IL', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726261
	UNION ALL SELECT intScheduleColumnId = 238, strFormCode = '72A138', strScheduleCode = '7IL', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726262
	UNION ALL SELECT intScheduleColumnId = 239, strFormCode = '72A138', strScheduleCode = '7IL', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726263
	UNION ALL SELECT intScheduleColumnId = 240, strFormCode = '72A138', strScheduleCode = '7IL', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726264
	UNION ALL SELECT intScheduleColumnId = 241, strFormCode = '72A138', strScheduleCode = '7IL', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726265
	UNION ALL SELECT intScheduleColumnId = 242, strFormCode = '72A138', strScheduleCode = '7IL', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726266
	UNION ALL SELECT intScheduleColumnId = 243, strFormCode = '72A138', strScheduleCode = '7IN', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726267
	UNION ALL SELECT intScheduleColumnId = 244, strFormCode = '72A138', strScheduleCode = '7IN', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726268
	UNION ALL SELECT intScheduleColumnId = 245, strFormCode = '72A138', strScheduleCode = '7IN', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726269
	UNION ALL SELECT intScheduleColumnId = 246, strFormCode = '72A138', strScheduleCode = '7IN', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726270
	UNION ALL SELECT intScheduleColumnId = 247, strFormCode = '72A138', strScheduleCode = '7IN', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726271
	UNION ALL SELECT intScheduleColumnId = 248, strFormCode = '72A138', strScheduleCode = '7IN', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726272
	UNION ALL SELECT intScheduleColumnId = 249, strFormCode = '72A138', strScheduleCode = '7IN', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726273
	UNION ALL SELECT intScheduleColumnId = 250, strFormCode = '72A138', strScheduleCode = '7IN', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726274
	UNION ALL SELECT intScheduleColumnId = 251, strFormCode = '72A138', strScheduleCode = '7IN', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726275
	UNION ALL SELECT intScheduleColumnId = 252, strFormCode = '72A138', strScheduleCode = '7IN', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726276
	UNION ALL SELECT intScheduleColumnId = 253, strFormCode = '72A138', strScheduleCode = '7IN', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726277
	UNION ALL SELECT intScheduleColumnId = 254, strFormCode = '72A138', strScheduleCode = '7IN', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726278
	UNION ALL SELECT intScheduleColumnId = 255, strFormCode = '72A138', strScheduleCode = '7TN', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726279
	UNION ALL SELECT intScheduleColumnId = 256, strFormCode = '72A138', strScheduleCode = '7TN', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726280
	UNION ALL SELECT intScheduleColumnId = 257, strFormCode = '72A138', strScheduleCode = '7TN', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726281
	UNION ALL SELECT intScheduleColumnId = 258, strFormCode = '72A138', strScheduleCode = '7TN', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726282
	UNION ALL SELECT intScheduleColumnId = 259, strFormCode = '72A138', strScheduleCode = '7TN', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726283
	UNION ALL SELECT intScheduleColumnId = 260, strFormCode = '72A138', strScheduleCode = '7TN', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726284
	UNION ALL SELECT intScheduleColumnId = 261, strFormCode = '72A138', strScheduleCode = '7TN', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726285
	UNION ALL SELECT intScheduleColumnId = 262, strFormCode = '72A138', strScheduleCode = '7TN', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726286
	UNION ALL SELECT intScheduleColumnId = 263, strFormCode = '72A138', strScheduleCode = '7TN', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726287
	UNION ALL SELECT intScheduleColumnId = 264, strFormCode = '72A138', strScheduleCode = '7TN', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726288
	UNION ALL SELECT intScheduleColumnId = 265, strFormCode = '72A138', strScheduleCode = '7TN', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726289
	UNION ALL SELECT intScheduleColumnId = 266, strFormCode = '72A138', strScheduleCode = '7TN', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726290
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
	UNION ALL SELECT intScheduleColumnId = 351, strFormCode = '72A089', strScheduleCode = '5DIL', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726375
	UNION ALL SELECT intScheduleColumnId = 352, strFormCode = '72A089', strScheduleCode = '5DIL', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726376
	UNION ALL SELECT intScheduleColumnId = 353, strFormCode = '72A089', strScheduleCode = '5DIL', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726377
	UNION ALL SELECT intScheduleColumnId = 354, strFormCode = '72A089', strScheduleCode = '5DIL', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726378
	UNION ALL SELECT intScheduleColumnId = 355, strFormCode = '72A089', strScheduleCode = '5DIL', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726379
	UNION ALL SELECT intScheduleColumnId = 356, strFormCode = '72A089', strScheduleCode = '5DIL', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726380
	UNION ALL SELECT intScheduleColumnId = 357, strFormCode = '72A089', strScheduleCode = '5DIL', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726381
	UNION ALL SELECT intScheduleColumnId = 358, strFormCode = '72A089', strScheduleCode = '5DIL', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726382
	UNION ALL SELECT intScheduleColumnId = 359, strFormCode = '72A089', strScheduleCode = '5DIL', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726383
	UNION ALL SELECT intScheduleColumnId = 360, strFormCode = '72A089', strScheduleCode = '5DIL', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726384
	UNION ALL SELECT intScheduleColumnId = 361, strFormCode = '72A089', strScheduleCode = '5DIL', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726385
	UNION ALL SELECT intScheduleColumnId = 362, strFormCode = '72A089', strScheduleCode = '5DIL', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726386
	UNION ALL SELECT intScheduleColumnId = 363, strFormCode = '72A089', strScheduleCode = '5DIN', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726387
	UNION ALL SELECT intScheduleColumnId = 364, strFormCode = '72A089', strScheduleCode = '5DIN', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726388
	UNION ALL SELECT intScheduleColumnId = 365, strFormCode = '72A089', strScheduleCode = '5DIN', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726389
	UNION ALL SELECT intScheduleColumnId = 366, strFormCode = '72A089', strScheduleCode = '5DIN', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726390
	UNION ALL SELECT intScheduleColumnId = 367, strFormCode = '72A089', strScheduleCode = '5DIN', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726391
	UNION ALL SELECT intScheduleColumnId = 368, strFormCode = '72A089', strScheduleCode = '5DIN', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726392
	UNION ALL SELECT intScheduleColumnId = 369, strFormCode = '72A089', strScheduleCode = '5DIN', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726393
	UNION ALL SELECT intScheduleColumnId = 370, strFormCode = '72A089', strScheduleCode = '5DIN', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726394
	UNION ALL SELECT intScheduleColumnId = 371, strFormCode = '72A089', strScheduleCode = '5DIN', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726395
	UNION ALL SELECT intScheduleColumnId = 372, strFormCode = '72A089', strScheduleCode = '5DIN', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726396
	UNION ALL SELECT intScheduleColumnId = 373, strFormCode = '72A089', strScheduleCode = '5DIN', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726397
	UNION ALL SELECT intScheduleColumnId = 374, strFormCode = '72A089', strScheduleCode = '5DIN', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726398
	UNION ALL SELECT intScheduleColumnId = 375, strFormCode = '72A089', strScheduleCode = '5DTN', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726399
	UNION ALL SELECT intScheduleColumnId = 376, strFormCode = '72A089', strScheduleCode = '5DTN', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726400
	UNION ALL SELECT intScheduleColumnId = 377, strFormCode = '72A089', strScheduleCode = '5DTN', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726401
	UNION ALL SELECT intScheduleColumnId = 378, strFormCode = '72A089', strScheduleCode = '5DTN', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726402
	UNION ALL SELECT intScheduleColumnId = 379, strFormCode = '72A089', strScheduleCode = '5DTN', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726403
	UNION ALL SELECT intScheduleColumnId = 380, strFormCode = '72A089', strScheduleCode = '5DTN', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726404
	UNION ALL SELECT intScheduleColumnId = 381, strFormCode = '72A089', strScheduleCode = '5DTN', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726405
	UNION ALL SELECT intScheduleColumnId = 382, strFormCode = '72A089', strScheduleCode = '5DTN', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726406
	UNION ALL SELECT intScheduleColumnId = 383, strFormCode = '72A089', strScheduleCode = '5DTN', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726407
	UNION ALL SELECT intScheduleColumnId = 384, strFormCode = '72A089', strScheduleCode = '5DTN', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726408
	UNION ALL SELECT intScheduleColumnId = 385, strFormCode = '72A089', strScheduleCode = '5DTN', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726409
	UNION ALL SELECT intScheduleColumnId = 386, strFormCode = '72A089', strScheduleCode = '5DTN', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726410
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
	UNION ALL SELECT intScheduleColumnId = 399, strFormCode = '72A089', strScheduleCode = '7IL', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726423
	UNION ALL SELECT intScheduleColumnId = 400, strFormCode = '72A089', strScheduleCode = '7IL', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726424
	UNION ALL SELECT intScheduleColumnId = 401, strFormCode = '72A089', strScheduleCode = '7IL', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726425
	UNION ALL SELECT intScheduleColumnId = 402, strFormCode = '72A089', strScheduleCode = '7IL', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726426
	UNION ALL SELECT intScheduleColumnId = 403, strFormCode = '72A089', strScheduleCode = '7IL', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726427
	UNION ALL SELECT intScheduleColumnId = 404, strFormCode = '72A089', strScheduleCode = '7IL', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726428
	UNION ALL SELECT intScheduleColumnId = 405, strFormCode = '72A089', strScheduleCode = '7IL', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726429
	UNION ALL SELECT intScheduleColumnId = 406, strFormCode = '72A089', strScheduleCode = '7IL', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726430
	UNION ALL SELECT intScheduleColumnId = 407, strFormCode = '72A089', strScheduleCode = '7IL', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726431
	UNION ALL SELECT intScheduleColumnId = 408, strFormCode = '72A089', strScheduleCode = '7IL', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726432
	UNION ALL SELECT intScheduleColumnId = 409, strFormCode = '72A089', strScheduleCode = '7IL', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726433
	UNION ALL SELECT intScheduleColumnId = 410, strFormCode = '72A089', strScheduleCode = '7IL', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726434
	UNION ALL SELECT intScheduleColumnId = 411, strFormCode = '72A089', strScheduleCode = '7IN', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726435
	UNION ALL SELECT intScheduleColumnId = 412, strFormCode = '72A089', strScheduleCode = '7IN', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726436
	UNION ALL SELECT intScheduleColumnId = 413, strFormCode = '72A089', strScheduleCode = '7IN', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726437
	UNION ALL SELECT intScheduleColumnId = 414, strFormCode = '72A089', strScheduleCode = '7IN', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726438
	UNION ALL SELECT intScheduleColumnId = 415, strFormCode = '72A089', strScheduleCode = '7IN', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726439
	UNION ALL SELECT intScheduleColumnId = 416, strFormCode = '72A089', strScheduleCode = '7IN', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726440
	UNION ALL SELECT intScheduleColumnId = 417, strFormCode = '72A089', strScheduleCode = '7IN', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726441
	UNION ALL SELECT intScheduleColumnId = 418, strFormCode = '72A089', strScheduleCode = '7IN', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726442
	UNION ALL SELECT intScheduleColumnId = 419, strFormCode = '72A089', strScheduleCode = '7IN', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726443
	UNION ALL SELECT intScheduleColumnId = 420, strFormCode = '72A089', strScheduleCode = '7IN', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726444
	UNION ALL SELECT intScheduleColumnId = 421, strFormCode = '72A089', strScheduleCode = '7IN', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726445
	UNION ALL SELECT intScheduleColumnId = 422, strFormCode = '72A089', strScheduleCode = '7IN', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726446
	UNION ALL SELECT intScheduleColumnId = 423, strFormCode = '72A089', strScheduleCode = '7TN', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726447
	UNION ALL SELECT intScheduleColumnId = 424, strFormCode = '72A089', strScheduleCode = '7TN', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726448
	UNION ALL SELECT intScheduleColumnId = 425, strFormCode = '72A089', strScheduleCode = '7TN', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726449
	UNION ALL SELECT intScheduleColumnId = 426, strFormCode = '72A089', strScheduleCode = '7TN', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726450
	UNION ALL SELECT intScheduleColumnId = 427, strFormCode = '72A089', strScheduleCode = '7TN', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726451
	UNION ALL SELECT intScheduleColumnId = 428, strFormCode = '72A089', strScheduleCode = '7TN', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726452
	UNION ALL SELECT intScheduleColumnId = 429, strFormCode = '72A089', strScheduleCode = '7TN', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726453
	UNION ALL SELECT intScheduleColumnId = 430, strFormCode = '72A089', strScheduleCode = '7TN', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726454
	UNION ALL SELECT intScheduleColumnId = 431, strFormCode = '72A089', strScheduleCode = '7TN', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726455
	UNION ALL SELECT intScheduleColumnId = 432, strFormCode = '72A089', strScheduleCode = '7TN', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726456
	UNION ALL SELECT intScheduleColumnId = 433, strFormCode = '72A089', strScheduleCode = '7TN', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726457
	UNION ALL SELECT intScheduleColumnId = 434, strFormCode = '72A089', strScheduleCode = '7TN', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726458
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

	UNION ALL SELECT intScheduleColumnId = 459, strFormCode = '72A089', strScheduleCode = '3OH', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726483
	UNION ALL SELECT intScheduleColumnId = 460, strFormCode = '72A089', strScheduleCode = '3OH', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726484
	UNION ALL SELECT intScheduleColumnId = 461, strFormCode = '72A089', strScheduleCode = '3OH', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726485
	UNION ALL SELECT intScheduleColumnId = 462, strFormCode = '72A089', strScheduleCode = '3OH', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726486
	UNION ALL SELECT intScheduleColumnId = 463, strFormCode = '72A089', strScheduleCode = '3OH', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726487
	UNION ALL SELECT intScheduleColumnId = 464, strFormCode = '72A089', strScheduleCode = '3OH', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726488
	UNION ALL SELECT intScheduleColumnId = 465, strFormCode = '72A089', strScheduleCode = '3OH', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726489
	UNION ALL SELECT intScheduleColumnId = 466, strFormCode = '72A089', strScheduleCode = '3OH', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726490
	UNION ALL SELECT intScheduleColumnId = 467, strFormCode = '72A089', strScheduleCode = '3OH', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726491
	UNION ALL SELECT intScheduleColumnId = 468, strFormCode = '72A089', strScheduleCode = '3OH', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726492
	UNION ALL SELECT intScheduleColumnId = 469, strFormCode = '72A089', strScheduleCode = '3OH', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726493
	UNION ALL SELECT intScheduleColumnId = 470, strFormCode = '72A089', strScheduleCode = '3OH', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726494
	UNION ALL SELECT intScheduleColumnId = 471, strFormCode = '72A089', strScheduleCode = '3OH', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726495
	UNION ALL SELECT intScheduleColumnId = 472, strFormCode = '72A089', strScheduleCode = '3VA', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726496
	UNION ALL SELECT intScheduleColumnId = 473, strFormCode = '72A089', strScheduleCode = '3VA', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726497
	UNION ALL SELECT intScheduleColumnId = 474, strFormCode = '72A089', strScheduleCode = '3VA', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726498
	UNION ALL SELECT intScheduleColumnId = 475, strFormCode = '72A089', strScheduleCode = '3VA', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726499
	UNION ALL SELECT intScheduleColumnId = 476, strFormCode = '72A089', strScheduleCode = '3VA', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726500
	UNION ALL SELECT intScheduleColumnId = 477, strFormCode = '72A089', strScheduleCode = '3VA', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726501
	UNION ALL SELECT intScheduleColumnId = 478, strFormCode = '72A089', strScheduleCode = '3VA', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726502
	UNION ALL SELECT intScheduleColumnId = 479, strFormCode = '72A089', strScheduleCode = '3VA', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726503
	UNION ALL SELECT intScheduleColumnId = 480, strFormCode = '72A089', strScheduleCode = '3VA', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726504
	UNION ALL SELECT intScheduleColumnId = 481, strFormCode = '72A089', strScheduleCode = '3VA', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726505
	UNION ALL SELECT intScheduleColumnId = 482, strFormCode = '72A089', strScheduleCode = '3VA', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726506
	UNION ALL SELECT intScheduleColumnId = 483, strFormCode = '72A089', strScheduleCode = '3VA', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726507
	UNION ALL SELECT intScheduleColumnId = 484, strFormCode = '72A089', strScheduleCode = '3VA', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726508
	UNION ALL SELECT intScheduleColumnId = 485, strFormCode = '72A089', strScheduleCode = '3WV', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726509
	UNION ALL SELECT intScheduleColumnId = 486, strFormCode = '72A089', strScheduleCode = '3WV', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726510
	UNION ALL SELECT intScheduleColumnId = 487, strFormCode = '72A089', strScheduleCode = '3WV', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726511
	UNION ALL SELECT intScheduleColumnId = 488, strFormCode = '72A089', strScheduleCode = '3WV', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726512
	UNION ALL SELECT intScheduleColumnId = 489, strFormCode = '72A089', strScheduleCode = '3WV', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726513
	UNION ALL SELECT intScheduleColumnId = 490, strFormCode = '72A089', strScheduleCode = '3WV', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726514
	UNION ALL SELECT intScheduleColumnId = 491, strFormCode = '72A089', strScheduleCode = '3WV', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726515
	UNION ALL SELECT intScheduleColumnId = 492, strFormCode = '72A089', strScheduleCode = '3WV', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726516
	UNION ALL SELECT intScheduleColumnId = 493, strFormCode = '72A089', strScheduleCode = '3WV', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726517
	UNION ALL SELECT intScheduleColumnId = 494, strFormCode = '72A089', strScheduleCode = '3WV', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726518
	UNION ALL SELECT intScheduleColumnId = 495, strFormCode = '72A089', strScheduleCode = '3WV', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726519
	UNION ALL SELECT intScheduleColumnId = 496, strFormCode = '72A089', strScheduleCode = '3WV', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726520
	UNION ALL SELECT intScheduleColumnId = 497, strFormCode = '72A089', strScheduleCode = '3WV', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726521
	UNION ALL SELECT intScheduleColumnId = 498, strFormCode = '72A138', strScheduleCode = '3OH', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726522
	UNION ALL SELECT intScheduleColumnId = 499, strFormCode = '72A138', strScheduleCode = '3OH', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726523
	UNION ALL SELECT intScheduleColumnId = 500, strFormCode = '72A138', strScheduleCode = '3OH', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726524
	UNION ALL SELECT intScheduleColumnId = 501, strFormCode = '72A138', strScheduleCode = '3OH', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726525
	UNION ALL SELECT intScheduleColumnId = 502, strFormCode = '72A138', strScheduleCode = '3OH', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726526
	UNION ALL SELECT intScheduleColumnId = 503, strFormCode = '72A138', strScheduleCode = '3OH', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726527
	UNION ALL SELECT intScheduleColumnId = 504, strFormCode = '72A138', strScheduleCode = '3OH', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726528
	UNION ALL SELECT intScheduleColumnId = 505, strFormCode = '72A138', strScheduleCode = '3OH', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726529
	UNION ALL SELECT intScheduleColumnId = 506, strFormCode = '72A138', strScheduleCode = '3OH', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726530
	UNION ALL SELECT intScheduleColumnId = 507, strFormCode = '72A138', strScheduleCode = '3OH', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726531
	UNION ALL SELECT intScheduleColumnId = 508, strFormCode = '72A138', strScheduleCode = '3OH', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726532
	UNION ALL SELECT intScheduleColumnId = 509, strFormCode = '72A138', strScheduleCode = '3OH', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726533
	UNION ALL SELECT intScheduleColumnId = 510, strFormCode = '72A138', strScheduleCode = '3OH', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726534
	UNION ALL SELECT intScheduleColumnId = 511, strFormCode = '72A138', strScheduleCode = '3VA', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726535
	UNION ALL SELECT intScheduleColumnId = 512, strFormCode = '72A138', strScheduleCode = '3VA', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726536
	UNION ALL SELECT intScheduleColumnId = 513, strFormCode = '72A138', strScheduleCode = '3VA', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726537
	UNION ALL SELECT intScheduleColumnId = 514, strFormCode = '72A138', strScheduleCode = '3VA', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726538
	UNION ALL SELECT intScheduleColumnId = 515, strFormCode = '72A138', strScheduleCode = '3VA', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726539
	UNION ALL SELECT intScheduleColumnId = 516, strFormCode = '72A138', strScheduleCode = '3VA', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726540
	UNION ALL SELECT intScheduleColumnId = 517, strFormCode = '72A138', strScheduleCode = '3VA', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726541
	UNION ALL SELECT intScheduleColumnId = 518, strFormCode = '72A138', strScheduleCode = '3VA', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726542
	UNION ALL SELECT intScheduleColumnId = 519, strFormCode = '72A138', strScheduleCode = '3VA', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726543
	UNION ALL SELECT intScheduleColumnId = 520, strFormCode = '72A138', strScheduleCode = '3VA', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726544
	UNION ALL SELECT intScheduleColumnId = 521, strFormCode = '72A138', strScheduleCode = '3VA', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726545
	UNION ALL SELECT intScheduleColumnId = 522, strFormCode = '72A138', strScheduleCode = '3VA', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726546
	UNION ALL SELECT intScheduleColumnId = 523, strFormCode = '72A138', strScheduleCode = '3VA', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726547
	UNION ALL SELECT intScheduleColumnId = 524, strFormCode = '72A138', strScheduleCode = '3WV', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726548
	UNION ALL SELECT intScheduleColumnId = 525, strFormCode = '72A138', strScheduleCode = '3WV', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726549
	UNION ALL SELECT intScheduleColumnId = 526, strFormCode = '72A138', strScheduleCode = '3WV', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726550
	UNION ALL SELECT intScheduleColumnId = 527, strFormCode = '72A138', strScheduleCode = '3WV', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726551
	UNION ALL SELECT intScheduleColumnId = 528, strFormCode = '72A138', strScheduleCode = '3WV', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726552
	UNION ALL SELECT intScheduleColumnId = 529, strFormCode = '72A138', strScheduleCode = '3WV', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726553
	UNION ALL SELECT intScheduleColumnId = 530, strFormCode = '72A138', strScheduleCode = '3WV', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726554
	UNION ALL SELECT intScheduleColumnId = 531, strFormCode = '72A138', strScheduleCode = '3WV', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726555
	UNION ALL SELECT intScheduleColumnId = 532, strFormCode = '72A138', strScheduleCode = '3WV', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726556
	UNION ALL SELECT intScheduleColumnId = 533, strFormCode = '72A138', strScheduleCode = '3WV', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726557
	UNION ALL SELECT intScheduleColumnId = 534, strFormCode = '72A138', strScheduleCode = '3WV', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726558
	UNION ALL SELECT intScheduleColumnId = 535, strFormCode = '72A138', strScheduleCode = '3WV', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726559
	UNION ALL SELECT intScheduleColumnId = 536, strFormCode = '72A138', strScheduleCode = '3WV', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726560
	UNION ALL SELECT intScheduleColumnId = 537, strFormCode = '72A089', strScheduleCode = '5DOH', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726561
	UNION ALL SELECT intScheduleColumnId = 538, strFormCode = '72A089', strScheduleCode = '5DOH', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726562
	UNION ALL SELECT intScheduleColumnId = 539, strFormCode = '72A089', strScheduleCode = '5DOH', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726563
	UNION ALL SELECT intScheduleColumnId = 540, strFormCode = '72A089', strScheduleCode = '5DOH', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726564
	UNION ALL SELECT intScheduleColumnId = 541, strFormCode = '72A089', strScheduleCode = '5DOH', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726565
	UNION ALL SELECT intScheduleColumnId = 542, strFormCode = '72A089', strScheduleCode = '5DOH', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726566
	UNION ALL SELECT intScheduleColumnId = 543, strFormCode = '72A089', strScheduleCode = '5DOH', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726567
	UNION ALL SELECT intScheduleColumnId = 544, strFormCode = '72A089', strScheduleCode = '5DOH', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726568
	UNION ALL SELECT intScheduleColumnId = 545, strFormCode = '72A089', strScheduleCode = '5DOH', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726569
	UNION ALL SELECT intScheduleColumnId = 546, strFormCode = '72A089', strScheduleCode = '5DOH', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726570
	UNION ALL SELECT intScheduleColumnId = 547, strFormCode = '72A089', strScheduleCode = '5DOH', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726571
	UNION ALL SELECT intScheduleColumnId = 548, strFormCode = '72A089', strScheduleCode = '5DOH', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726572
	UNION ALL SELECT intScheduleColumnId = 549, strFormCode = '72A089', strScheduleCode = '5DVA', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726573
	UNION ALL SELECT intScheduleColumnId = 550, strFormCode = '72A089', strScheduleCode = '5DVA', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726574
	UNION ALL SELECT intScheduleColumnId = 551, strFormCode = '72A089', strScheduleCode = '5DVA', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726575
	UNION ALL SELECT intScheduleColumnId = 552, strFormCode = '72A089', strScheduleCode = '5DVA', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726576
	UNION ALL SELECT intScheduleColumnId = 553, strFormCode = '72A089', strScheduleCode = '5DVA', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726577
	UNION ALL SELECT intScheduleColumnId = 554, strFormCode = '72A089', strScheduleCode = '5DVA', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726578
	UNION ALL SELECT intScheduleColumnId = 555, strFormCode = '72A089', strScheduleCode = '5DVA', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726579
	UNION ALL SELECT intScheduleColumnId = 556, strFormCode = '72A089', strScheduleCode = '5DVA', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726580
	UNION ALL SELECT intScheduleColumnId = 557, strFormCode = '72A089', strScheduleCode = '5DVA', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726581
	UNION ALL SELECT intScheduleColumnId = 558, strFormCode = '72A089', strScheduleCode = '5DVA', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726582
	UNION ALL SELECT intScheduleColumnId = 559, strFormCode = '72A089', strScheduleCode = '5DVA', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726583
	UNION ALL SELECT intScheduleColumnId = 560, strFormCode = '72A089', strScheduleCode = '5DVA', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726584
	UNION ALL SELECT intScheduleColumnId = 561, strFormCode = '72A089', strScheduleCode = '5DWV', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726585
	UNION ALL SELECT intScheduleColumnId = 562, strFormCode = '72A089', strScheduleCode = '5DWV', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726586
	UNION ALL SELECT intScheduleColumnId = 563, strFormCode = '72A089', strScheduleCode = '5DWV', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726587
	UNION ALL SELECT intScheduleColumnId = 564, strFormCode = '72A089', strScheduleCode = '5DWV', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726588
	UNION ALL SELECT intScheduleColumnId = 565, strFormCode = '72A089', strScheduleCode = '5DWV', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726589
	UNION ALL SELECT intScheduleColumnId = 566, strFormCode = '72A089', strScheduleCode = '5DWV', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726590
	UNION ALL SELECT intScheduleColumnId = 567, strFormCode = '72A089', strScheduleCode = '5DWV', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726591
	UNION ALL SELECT intScheduleColumnId = 568, strFormCode = '72A089', strScheduleCode = '5DWV', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726592
	UNION ALL SELECT intScheduleColumnId = 569, strFormCode = '72A089', strScheduleCode = '5DWV', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726593
	UNION ALL SELECT intScheduleColumnId = 570, strFormCode = '72A089', strScheduleCode = '5DWV', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726594
	UNION ALL SELECT intScheduleColumnId = 571, strFormCode = '72A089', strScheduleCode = '5DWV', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726595
	UNION ALL SELECT intScheduleColumnId = 572, strFormCode = '72A089', strScheduleCode = '5DWV', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726596
	UNION ALL SELECT intScheduleColumnId = 573, strFormCode = '72A089', strScheduleCode = '7OH', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726597
	UNION ALL SELECT intScheduleColumnId = 574, strFormCode = '72A089', strScheduleCode = '7OH', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726598
	UNION ALL SELECT intScheduleColumnId = 575, strFormCode = '72A089', strScheduleCode = '7OH', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726599
	UNION ALL SELECT intScheduleColumnId = 576, strFormCode = '72A089', strScheduleCode = '7OH', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726600
	UNION ALL SELECT intScheduleColumnId = 577, strFormCode = '72A089', strScheduleCode = '7OH', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726601
	UNION ALL SELECT intScheduleColumnId = 578, strFormCode = '72A089', strScheduleCode = '7OH', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726602
	UNION ALL SELECT intScheduleColumnId = 579, strFormCode = '72A089', strScheduleCode = '7OH', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726603
	UNION ALL SELECT intScheduleColumnId = 580, strFormCode = '72A089', strScheduleCode = '7OH', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726604
	UNION ALL SELECT intScheduleColumnId = 581, strFormCode = '72A089', strScheduleCode = '7OH', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726605
	UNION ALL SELECT intScheduleColumnId = 582, strFormCode = '72A089', strScheduleCode = '7OH', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726606
	UNION ALL SELECT intScheduleColumnId = 583, strFormCode = '72A089', strScheduleCode = '7OH', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726607
	UNION ALL SELECT intScheduleColumnId = 584, strFormCode = '72A089', strScheduleCode = '7OH', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726608
	UNION ALL SELECT intScheduleColumnId = 585, strFormCode = '72A089', strScheduleCode = '7VA', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726609
	UNION ALL SELECT intScheduleColumnId = 586, strFormCode = '72A089', strScheduleCode = '7VA', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726610
	UNION ALL SELECT intScheduleColumnId = 587, strFormCode = '72A089', strScheduleCode = '7VA', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726611
	UNION ALL SELECT intScheduleColumnId = 588, strFormCode = '72A089', strScheduleCode = '7VA', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726612
	UNION ALL SELECT intScheduleColumnId = 589, strFormCode = '72A089', strScheduleCode = '7VA', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726613
	UNION ALL SELECT intScheduleColumnId = 590, strFormCode = '72A089', strScheduleCode = '7VA', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726614
	UNION ALL SELECT intScheduleColumnId = 591, strFormCode = '72A089', strScheduleCode = '7VA', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726615
	UNION ALL SELECT intScheduleColumnId = 592, strFormCode = '72A089', strScheduleCode = '7VA', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726616
	UNION ALL SELECT intScheduleColumnId = 593, strFormCode = '72A089', strScheduleCode = '7VA', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726617
	UNION ALL SELECT intScheduleColumnId = 594, strFormCode = '72A089', strScheduleCode = '7VA', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726618
	UNION ALL SELECT intScheduleColumnId = 595, strFormCode = '72A089', strScheduleCode = '7VA', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726619
	UNION ALL SELECT intScheduleColumnId = 596, strFormCode = '72A089', strScheduleCode = '7VA', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726620
	UNION ALL SELECT intScheduleColumnId = 597, strFormCode = '72A089', strScheduleCode = '7WV', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726621
	UNION ALL SELECT intScheduleColumnId = 598, strFormCode = '72A089', strScheduleCode = '7WV', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726622
	UNION ALL SELECT intScheduleColumnId = 599, strFormCode = '72A089', strScheduleCode = '7WV', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726623
	UNION ALL SELECT intScheduleColumnId = 600, strFormCode = '72A089', strScheduleCode = '7WV', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726624
	UNION ALL SELECT intScheduleColumnId = 601, strFormCode = '72A089', strScheduleCode = '7WV', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726625
	UNION ALL SELECT intScheduleColumnId = 602, strFormCode = '72A089', strScheduleCode = '7WV', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726626
	UNION ALL SELECT intScheduleColumnId = 603, strFormCode = '72A089', strScheduleCode = '7WV', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726627
	UNION ALL SELECT intScheduleColumnId = 604, strFormCode = '72A089', strScheduleCode = '7WV', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726628
	UNION ALL SELECT intScheduleColumnId = 605, strFormCode = '72A089', strScheduleCode = '7WV', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726629
	UNION ALL SELECT intScheduleColumnId = 606, strFormCode = '72A089', strScheduleCode = '7WV', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726630
	UNION ALL SELECT intScheduleColumnId = 607, strFormCode = '72A089', strScheduleCode = '7WV', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726631
	UNION ALL SELECT intScheduleColumnId = 608, strFormCode = '72A089', strScheduleCode = '7WV', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726632
	UNION ALL SELECT intScheduleColumnId = 609, strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726633
	UNION ALL SELECT intScheduleColumnId = 610, strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726634
	UNION ALL SELECT intScheduleColumnId = 611, strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726635
	UNION ALL SELECT intScheduleColumnId = 612, strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726636
	UNION ALL SELECT intScheduleColumnId = 613, strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726637
	UNION ALL SELECT intScheduleColumnId = 614, strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726638
	UNION ALL SELECT intScheduleColumnId = 615, strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726639
	UNION ALL SELECT intScheduleColumnId = 616, strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726640
	UNION ALL SELECT intScheduleColumnId = 617, strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726641
	UNION ALL SELECT intScheduleColumnId = 618, strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726642
	UNION ALL SELECT intScheduleColumnId = 619, strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726643
	UNION ALL SELECT intScheduleColumnId = 620, strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726644
	UNION ALL SELECT intScheduleColumnId = 621, strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726645
	UNION ALL SELECT intScheduleColumnId = 622, strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726646
	UNION ALL SELECT intScheduleColumnId = 623, strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726647
	UNION ALL SELECT intScheduleColumnId = 624, strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726648
	UNION ALL SELECT intScheduleColumnId = 625, strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726649
	UNION ALL SELECT intScheduleColumnId = 626, strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726650
	UNION ALL SELECT intScheduleColumnId = 627, strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726651
	UNION ALL SELECT intScheduleColumnId = 628, strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726652
	UNION ALL SELECT intScheduleColumnId = 629, strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726653
	UNION ALL SELECT intScheduleColumnId = 630, strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726654
	UNION ALL SELECT intScheduleColumnId = 631, strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726655
	UNION ALL SELECT intScheduleColumnId = 632, strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726656
	UNION ALL SELECT intScheduleColumnId = 633, strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726657
	UNION ALL SELECT intScheduleColumnId = 634, strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726658
	UNION ALL SELECT intScheduleColumnId = 635, strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726659
	UNION ALL SELECT intScheduleColumnId = 636, strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726660
	UNION ALL SELECT intScheduleColumnId = 637, strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726661
	UNION ALL SELECT intScheduleColumnId = 638, strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726662
	UNION ALL SELECT intScheduleColumnId = 639, strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726663
	UNION ALL SELECT intScheduleColumnId = 640, strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726664
	UNION ALL SELECT intScheduleColumnId = 641, strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726665
	UNION ALL SELECT intScheduleColumnId = 642, strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726666
	UNION ALL SELECT intScheduleColumnId = 643, strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726667
	UNION ALL SELECT intScheduleColumnId = 644, strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726668
	UNION ALL SELECT intScheduleColumnId = 645, strFormCode = '72A138', strScheduleCode = '7OH', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726669
	UNION ALL SELECT intScheduleColumnId = 646, strFormCode = '72A138', strScheduleCode = '7OH', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726670
	UNION ALL SELECT intScheduleColumnId = 647, strFormCode = '72A138', strScheduleCode = '7OH', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726671
	UNION ALL SELECT intScheduleColumnId = 648, strFormCode = '72A138', strScheduleCode = '7OH', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726672
	UNION ALL SELECT intScheduleColumnId = 649, strFormCode = '72A138', strScheduleCode = '7OH', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726673
	UNION ALL SELECT intScheduleColumnId = 650, strFormCode = '72A138', strScheduleCode = '7OH', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726674
	UNION ALL SELECT intScheduleColumnId = 651, strFormCode = '72A138', strScheduleCode = '7OH', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726675
	UNION ALL SELECT intScheduleColumnId = 652, strFormCode = '72A138', strScheduleCode = '7OH', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726676
	UNION ALL SELECT intScheduleColumnId = 653, strFormCode = '72A138', strScheduleCode = '7OH', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726677
	UNION ALL SELECT intScheduleColumnId = 654, strFormCode = '72A138', strScheduleCode = '7OH', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726678
	UNION ALL SELECT intScheduleColumnId = 655, strFormCode = '72A138', strScheduleCode = '7OH', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726679
	UNION ALL SELECT intScheduleColumnId = 656, strFormCode = '72A138', strScheduleCode = '7OH', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726680
	UNION ALL SELECT intScheduleColumnId = 657, strFormCode = '72A138', strScheduleCode = '7VA', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726681
	UNION ALL SELECT intScheduleColumnId = 658, strFormCode = '72A138', strScheduleCode = '7VA', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726682
	UNION ALL SELECT intScheduleColumnId = 659, strFormCode = '72A138', strScheduleCode = '7VA', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726683
	UNION ALL SELECT intScheduleColumnId = 660, strFormCode = '72A138', strScheduleCode = '7VA', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726684
	UNION ALL SELECT intScheduleColumnId = 661, strFormCode = '72A138', strScheduleCode = '7VA', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726685
	UNION ALL SELECT intScheduleColumnId = 662, strFormCode = '72A138', strScheduleCode = '7VA', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726686
	UNION ALL SELECT intScheduleColumnId = 663, strFormCode = '72A138', strScheduleCode = '7VA', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726687
	UNION ALL SELECT intScheduleColumnId = 664, strFormCode = '72A138', strScheduleCode = '7VA', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726688
	UNION ALL SELECT intScheduleColumnId = 665, strFormCode = '72A138', strScheduleCode = '7VA', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726689
	UNION ALL SELECT intScheduleColumnId = 666, strFormCode = '72A138', strScheduleCode = '7VA', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726690
	UNION ALL SELECT intScheduleColumnId = 667, strFormCode = '72A138', strScheduleCode = '7VA', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726691
	UNION ALL SELECT intScheduleColumnId = 668, strFormCode = '72A138', strScheduleCode = '7VA', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726692
	UNION ALL SELECT intScheduleColumnId = 669, strFormCode = '72A138', strScheduleCode = '7WV', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726693
	UNION ALL SELECT intScheduleColumnId = 670, strFormCode = '72A138', strScheduleCode = '7WV', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726694
	UNION ALL SELECT intScheduleColumnId = 671, strFormCode = '72A138', strScheduleCode = '7WV', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726695
	UNION ALL SELECT intScheduleColumnId = 672, strFormCode = '72A138', strScheduleCode = '7WV', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726696
	UNION ALL SELECT intScheduleColumnId = 673, strFormCode = '72A138', strScheduleCode = '7WV', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726697
	UNION ALL SELECT intScheduleColumnId = 674, strFormCode = '72A138', strScheduleCode = '7WV', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726698
	UNION ALL SELECT intScheduleColumnId = 675, strFormCode = '72A138', strScheduleCode = '7WV', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726699
	UNION ALL SELECT intScheduleColumnId = 676, strFormCode = '72A138', strScheduleCode = '7WV', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726700
	UNION ALL SELECT intScheduleColumnId = 677, strFormCode = '72A138', strScheduleCode = '7WV', strType = '', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726701
	UNION ALL SELECT intScheduleColumnId = 678, strFormCode = '72A138', strScheduleCode = '7WV', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726702
	UNION ALL SELECT intScheduleColumnId = 679, strFormCode = '72A138', strScheduleCode = '7WV', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726703
	UNION ALL SELECT intScheduleColumnId = 680, strFormCode = '72A138', strScheduleCode = '7WV', strType = '', strColumn = 'dblGross', strCaption = 'NetGross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1726704

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
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '3IL', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172963
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '3IN', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172964
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '3TN', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172965
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '5DIL', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172966
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '5DIN', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172967
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '5DTN', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172968
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '6', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172969
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '7IL', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172970
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '7IN', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172971
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '7TN', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172972
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
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '3IL', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172980
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '3IN', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172981
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '3TN', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172982
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '5DIL', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172983
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '5DIN', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172984
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '5DTN', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172985
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '6', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172986
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '7IL', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172987
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '7IN', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172988
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '7TN', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172989
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '8', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172990
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '9', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172991
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'KY EDI', strScheduleCode = '', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172998
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '3OH', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 172999
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '3VA', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173000
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '3WV', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173001
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '5DOH', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173002
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '5DVA', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173003
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '5DWV', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173004
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '7OH', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173005
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '7VA', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173006
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A089', strScheduleCode = '7WV', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173007
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '3OH', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173008
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '3VA', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173009
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '3WV', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173010
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '5DOH', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173011
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '5DVA', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173012
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '5DWV', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173013
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '7OH', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173014
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '7VA', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173015
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '72A138', strScheduleCode = '7WV', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 173016


	EXEC uspTFUpgradeFilingPackets @TaxAuthorityCode = @TaxAuthorityCode, @FilingPackets = @FilingPackets

END

GO