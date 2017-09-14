﻿DECLARE @TaxAuthorityCode NVARCHAR(10) = 'NC'
	, @TaxAuthorityId INT

SELECT @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = @TaxAuthorityCode AND ysnFilingForThisTA = 1

IF(@TaxAuthorityId IS NOT NULL)
BEGIN

PRINT ('Deploying North Carolina Tax Forms')

-- Product Codes
/* Generate script for Product Codes. Specify Tax Authority Id to filter out specific Product Codes only.
select 'UNION ALL SELECT intProductCodeId = ' + CAST(intProductCodeId AS NVARCHAR(10)) 
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
	SELECT intProductCodeId = 2586, strProductCode = '054', strDescription = 'Propane', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332586
	UNION ALL SELECT intProductCodeId = 2587, strProductCode = '065', strDescription = 'Gasoline', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332587
	UNION ALL SELECT intProductCodeId = 2588, strProductCode = '072', strDescription = 'Kerosene - Dyed', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332588
	UNION ALL SELECT intProductCodeId = 2589, strProductCode = '123', strDescription = 'Alcohol', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332589
	UNION ALL SELECT intProductCodeId = 2590, strProductCode = '124', strDescription = 'Gasohol', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332590
	UNION ALL SELECT intProductCodeId = 2591, strProductCode = '125', strDescription = 'Aviation Gasoline', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332591
	UNION ALL SELECT intProductCodeId = 2592, strProductCode = '130', strDescription = 'Jet Fuel', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332592
	UNION ALL SELECT intProductCodeId = 2593, strProductCode = '142', strDescription = 'Kerosene - Undyed', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332593
	UNION ALL SELECT intProductCodeId = 2594, strProductCode = '160', strDescription = 'Diesel - Undyed', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332594
	UNION ALL SELECT intProductCodeId = 2595, strProductCode = '224', strDescription = 'Compressed Natural Gas (CNG)', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332595
	UNION ALL SELECT intProductCodeId = 2596, strProductCode = '226', strDescription = 'Diesel – High Sulfur Dyed', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332596
	UNION ALL SELECT intProductCodeId = 2597, strProductCode = '227', strDescription = 'Diesel – Low Sulfur Dyed', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332597
	UNION ALL SELECT intProductCodeId = 2598, strProductCode = '241', strDescription = 'Ethanol', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332598
	UNION ALL SELECT intProductCodeId = 2599, strProductCode = '243', strDescription = 'Methanol', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332599
	UNION ALL SELECT intProductCodeId = 2600, strProductCode = '284', strDescription = 'BioDiesel – Undyed', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332600
	UNION ALL SELECT intProductCodeId = 2601, strProductCode = '290', strDescription = 'Biodiesel – Dyed', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332601

	EXEC uspTFUpgradeProductCodes @TaxAuthorityCode = @TaxAuthorityCode, @ProductCodes = @ProductCodes

-- Tax Category
/* Generate script for Tax Categories. Specify Tax Authority Id to filter out specific Tax Categories only.
select 'UNION ALL SELECT intTaxCategoryId = ' + CAST(intTaxCategoryId AS NVARCHAR(10))
	+ CASE WHEN strState IS NULL THEN ', strState = NULL' ELSE ', strState = ''' + strState + ''''  END
	+ CASE WHEN strTaxCategory IS NULL THEN ', strTaxCategory = NULL' ELSE ', strTaxCategory = ''' + strTaxCategory + ''''  END
--	+ ', intMasterId = ' + CAST((CASE WHEN ISNULL(intMasterId, '') = '' THEN intTaxCategoryId ELSE intMasterId END) AS NVARCHAR(20)) -- Old Format
	+ ', intMasterId = ' + CASE WHEN intMasterId IS NULL THEN CAST(@TaxAuthorityId AS NVARCHAR(20)) + CAST(intTaxCategoryId AS NVARCHAR(20)) ELSE CAST(intMasterId AS NVARCHAR(20)) END -- First 2 digit for TaxAuthorityCodeID
from tblTFTaxCategory
where intTaxAuthorityId = @TaxAuthorityId
*/
	DECLARE @TaxCategories AS TFTaxCategory

	INSERT INTO @TaxCategories(
		intTaxCategoryId
		, strState
		, strTaxCategory
		, intMasterId
	)
	SELECT intTaxCategoryId = 2099, strState = 'NC', strTaxCategory = 'NC Excise Tax Gasoline', intMasterId = 332099
	UNION ALL SELECT intTaxCategoryId = 2100, strState = 'NC', strTaxCategory = 'NC Excise Tax Diesel Clear', intMasterId = 332100

	EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = @TaxAuthorityCode, @TaxCategories = @TaxCategories

-- Reporting Component
/* Generate script for Reporting Components. Specify Tax Authority Id to filter out specific Reporting Components only.
select 'UNION ALL SELECT intReportingComponentId = ' + CAST(intReportingComponentId AS NVARCHAR(10))
	+ CASE WHEN strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strFormName IS NULL THEN ', strFormName = NULL' ELSE ', strFormName = ''' + strFormName + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN strScheduleName IS NULL THEN ', strScheduleName = NULL' ELSE ', strScheduleName = ''' + strScheduleName + '''' END 
	+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END
	+ CASE WHEN strNote IS NULL THEN ', strNote = NULL' ELSE ', strNote = ''' + strNote + '''' END
	+ CASE WHEN strTransactionType IS NULL THEN ', strTransactionType = NULL' ELSE ', strTransactionType = ''' + strTransactionType + '''' END
	+ CASE WHEN intSort IS NULL THEN ', intSort = NULL' ELSE ', intSort = ' + CAST(intSort AS NVARCHAR(10)) END
	+ CASE WHEN strSPInventory IS NULL THEN ', strSPInventory = NULL' ELSE ', strSPInventory = ''' + strSPInventory + '''' END
	+ CASE WHEN strSPInvoice IS NULL THEN ', strSPInvoice = NULL' ELSE ', strSPInvoice = ''' + strSPInvoice + '''' END
	+ CASE WHEN strSPRunReport IS NULL THEN ', strSPRunReport = NULL' ELSE ', strSPRunReport = ''' + strSPRunReport + '''' END
--	+ ', intMasterId = ' + CAST((CASE WHEN ISNULL(intMasterId, '') = '' THEN intReportingComponentId ELSE intMasterId END) AS NVARCHAR(20)) -- Old Format
	+ ', intMasterId = ' + CASE WHEN intMasterId IS NULL THEN CAST(@TaxAuthorityId AS NVARCHAR(20)) + CAST(intReportingComponentId AS NVARCHAR(20)) ELSE CAST(intMasterId AS NVARCHAR(20)) END -- First 2 digit for TaxAuthorityCodeID
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
		, strSPInventory
		, strSPInvoice
		, strSPRunReport
		, intMasterId
		, intComponentTypeId
	)
	SELECT intReportingComponentId = 2690, strFormCode = 'Gas-1301', strFormName = 'Transporter Return', strScheduleCode = '14A', strScheduleName = 'Gallons Loaded in NC and Delivered to Another State', strType = '', strNote = '', strTransactionType = '', intSort = 10, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332690, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2691, strFormCode = 'Gas-1301', strFormName = 'Transporter Return', strScheduleCode = '14B', strScheduleName = 'Gallons Loaded in Another State and Delivered to NC', strType = '', strNote = '', strTransactionType = '', intSort = 20, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332691, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2692, strFormCode = 'Gas-1301', strFormName = 'Transporter Return', strScheduleCode = '14C', strScheduleName = 'Gallons Loaded in NC and Delivered to NC', strType = '', strNote = '', strTransactionType = '', intSort = 30, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332692, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2693, strFormCode = 'Gas-1301', strFormName = 'Transporter Return', strScheduleCode = '', strScheduleName = 'NC Transporter Return', strType = '', strNote = 'Main Form', strTransactionType = '', intSort = 35, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332693, intComponentTypeId = 2
	UNION ALL SELECT intReportingComponentId = 2694, strFormCode = 'Gas-1239', strFormName = 'Bulk Plant Exporter Return', strScheduleCode = '7F', strScheduleName = 'Bulk Plant Exporter Schedule of Tax-Paid Exports', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 40, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332694, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2695, strFormCode = 'Gas-1239', strFormName = 'Bulk Plant Exporter Return', strScheduleCode = '7F', strScheduleName = 'Bulk Plant Exporter Schedule of Tax-Paid Exports', strType = 'Undyed Diesel', strNote = '', strTransactionType = 'Invoice', intSort = 50, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332695, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2696, strFormCode = 'Gas-1239', strFormName = 'Bulk Plant Exporter Return', strScheduleCode = '7F', strScheduleName = 'Bulk Plant Exporter Schedule of Tax-Paid Exports', strType = 'Dyed Diesel', strNote = '', strTransactionType = 'Invoice', intSort = 60, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332696, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2697, strFormCode = 'Gas-1239', strFormName = 'Bulk Plant Exporter Return', strScheduleCode = '7F', strScheduleName = 'Bulk Plant Exporter Schedule of Tax-Paid Exports', strType = 'Undyed Kerosene', strNote = '', strTransactionType = 'Invoice', intSort = 70, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332697, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2698, strFormCode = 'Gas-1239', strFormName = 'Bulk Plant Exporter Return', strScheduleCode = '7F', strScheduleName = 'Bulk Plant Exporter Schedule of Tax-Paid Exports', strType = 'Dyed Kerosene', strNote = '', strTransactionType = 'Invoice', intSort = 80, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332698, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2699, strFormCode = 'Gas-1239', strFormName = 'Bulk Plant Exporter Return', strScheduleCode = '7F', strScheduleName = 'Bulk Plant Exporter Schedule of Tax-Paid Exports', strType = 'Jet Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 90, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332699, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2700, strFormCode = 'Gas-1239', strFormName = 'Bulk Plant Exporter Return', strScheduleCode = '7F', strScheduleName = 'Bulk Plant Exporter Schedule of Tax-Paid Exports', strType = 'AvGas', strNote = '', strTransactionType = 'Invoice', intSort = 100, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332700, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2701, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '5A', strScheduleName = 'Gallons Sold to End-users and Retailers, Tax Collected', strType = 'Propane', strNote = '', strTransactionType = 'Invoice', intSort = 110, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332701, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2702, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '5A', strScheduleName = 'Gallons Sold to End-users and Retailers, Tax Collected', strType = 'CNG', strNote = '', strTransactionType = 'Invoice', intSort = 120, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332702, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2703, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '8', strScheduleName = 'Gallons Sold to US Government', strType = 'Propane', strNote = '', strTransactionType = 'Invoice', intSort = 130, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332703, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2704, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '8', strScheduleName = 'Gallons Sold to US Government', strType = 'CNG', strNote = '', strTransactionType = 'Invoice', intSort = 140, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332704, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2705, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '9A', strScheduleName = 'Gallons Sold to State of NC', strType = 'Propane', strNote = '', strTransactionType = 'Invoice', intSort = 150, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332705, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2706, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '9A', strScheduleName = 'Gallons Sold to State of NC', strType = 'CNG', strNote = '', strTransactionType = 'Invoice', intSort = 160, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332706, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2707, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '9C', strScheduleName = 'Gallons Sold to a NC Local Board of Education', strType = 'Propane', strNote = '', strTransactionType = 'Invoice', intSort = 170, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332707, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2708, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '9C', strScheduleName = 'Gallons Sold to a NC Local Board of Education', strType = 'CNG', strNote = '', strTransactionType = 'Invoice', intSort = 180, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332708, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2709, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '9E', strScheduleName = 'Gallons Sold to a NC County or Municipility', strType = 'Propane', strNote = '', strTransactionType = 'Invoice', intSort = 190, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332709, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2710, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '9E', strScheduleName = 'Gallons Sold to a NC County or Municipility', strType = 'CNG', strNote = '', strTransactionType = 'Invoice', intSort = 200, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332710, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2711, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '9F', strScheduleName = 'Gallons Sold to a NC Charter School', strType = 'Propane', strNote = '', strTransactionType = 'Invoice', intSort = 210, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332711, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2712, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '9F', strScheduleName = 'Gallons Sold to a NC Charter School', strType = 'CNG', strNote = '', strTransactionType = 'Invoice', intSort = 220, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332712, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2713, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '9G', strScheduleName = 'Gallons Sold to a NC Community College', strType = 'Propane', strNote = '', strTransactionType = 'Invoice', intSort = 230, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332713, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2714, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '9G', strScheduleName = 'Gallons Sold to a NC Community College', strType = 'CNG', strNote = '', strTransactionType = 'Invoice', intSort = 240, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332714, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2715, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5R', strScheduleName = 'Dyed Diesel or Dyed Kerosene Delivered to a Local Bus Company', strType = 'Dyed Diesel', strNote = '', strTransactionType = 'Invoice', intSort = 250, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332715, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2716, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5R', strScheduleName = 'Dyed Diesel or Dyed Kerosene Delivered to a Local Bus Company', strType = 'Dyed Kerosene', strNote = '', strTransactionType = 'Invoice', intSort = 260, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332716, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2717, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5S', strScheduleName = 'Dyed Diesel or Dyed Kerosene Delivered to an Education Organization that is not a Public School', strType = 'Dyed Diesel', strNote = '', strTransactionType = 'Invoice', intSort = 270, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332717, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2718, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5S', strScheduleName = 'Dyed Diesel or Dyed Kerosene Delivered to an Education Organization that is not a Public School', strType = 'Dyed Kerosene', strNote = '', strTransactionType = 'Invoice', intSort = 280, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332718, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2719, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5U', strScheduleName = 'Gallons of Fuel that were Allowed an Exemption but Used for Taxable Use', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 290, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332719, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2720, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5U', strScheduleName = 'Gallons of Fuel that were Allowed an Exemption but Used for Taxable Use', strType = 'Undyed Diesel', strNote = '', strTransactionType = 'Invoice', intSort = 300, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332720, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2721, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5U', strScheduleName = 'Gallons of Fuel that were Allowed an Exemption but Used for Taxable Use', strType = 'Dyed Diesel', strNote = '', strTransactionType = 'Invoice', intSort = 310, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332721, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2722, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5U', strScheduleName = 'Gallons of Fuel that were Allowed an Exemption but Used for Taxable Use', strType = 'Undyed Kerosene', strNote = '', strTransactionType = 'Invoice', intSort = 320, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332722, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2723, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5V', strScheduleName = 'Gallons of Fuel Used to Operate a Highway Vehicle on which a Reful has been Requested', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 330, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332723, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2724, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5V', strScheduleName = 'Gallons of Fuel Used to Operate a Highway Vehicle on which a Reful has been Requested', strType = 'Undyed Diesel', strNote = '', strTransactionType = 'Invoice', intSort = 340, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332724, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2725, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5V', strScheduleName = 'Gallons of Fuel Used to Operate a Highway Vehicle on which a Reful has been Requested', strType = 'Dyed Diesel', strNote = '', strTransactionType = 'Invoice', intSort = 350, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332725, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2726, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5V', strScheduleName = 'Gallons of Fuel Used to Operate a Highway Vehicle on which a Reful has been Requested', strType = 'Undyed Kerosene', strNote = '', strTransactionType = 'Invoice', intSort = 360, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332726, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2727, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5W', strScheduleName = 'Gallons Diverted', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 370, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332727, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2728, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5W', strScheduleName = 'Gallons Diverted', strType = 'Undyed Diesel', strNote = '', strTransactionType = 'Invoice', intSort = 380, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332728, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2729, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5W', strScheduleName = 'Gallons Diverted', strType = 'Dyed Diesel', strNote = '', strTransactionType = 'Invoice', intSort = 390, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332729, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2730, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5W', strScheduleName = 'Gallons Diverted', strType = 'Undyed Kerosene', strNote = '', strTransactionType = 'Invoice', intSort = 400, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332730, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2731, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5W', strScheduleName = 'Gallons Diverted', strType = 'Dyed Kerosene', strNote = '', strTransactionType = 'Invoice', intSort = 410, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332731, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2732, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5W', strScheduleName = 'Gallons Diverted', strType = 'Jet Fule and Av Gas', strNote = '', strTransactionType = 'Invoice', intSort = 420, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332732, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2733, strFormCode = 'Gas-1206', strFormName = 'Claim for Refund', strScheduleCode = 'USGov', strScheduleName = 'Exempt - U.S. Government', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 430, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332733, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2734, strFormCode = 'Gas-1206', strFormName = 'Claim for Refund', strScheduleCode = 'Muni', strScheduleName = 'Exempt - NC County or Municipility', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 440, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332734, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2735, strFormCode = 'Gas-1206', strFormName = 'Claim for Refund', strScheduleCode = 'Charter', strScheduleName = 'Exempt - NC Charter School', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 450, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332735, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2736, strFormCode = 'Gas-1206', strFormName = 'Claim for Refund', strScheduleCode = 'State', strScheduleName = 'Exempt - State of NC', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 460, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332736, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2737, strFormCode = 'Gas-1206', strFormName = 'Claim for Refund', strScheduleCode = 'Edu', strScheduleName = 'Exempt - NC Local Board of Education', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 470, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332737, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2738, strFormCode = 'Gas-1206', strFormName = 'Claim for Refund', strScheduleCode = 'College', strScheduleName = 'Exempt - NC Community College', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 480, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332738, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2739, strFormCode = 'NC EDI', strFormName = 'NC EDI File', strScheduleCode = '', strScheduleName = '', strType = '', strNote = 'NC EDI File', strTransactionType = '', intSort = 1000, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 332739, intComponentTypeId = 3

	EXEC uspTFUpgradeReportingComponents @TaxAuthorityCode = @TaxAuthorityCode, @ReportingComponent = @ReportingComponent


END