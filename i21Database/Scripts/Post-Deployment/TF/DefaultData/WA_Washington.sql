﻿DECLARE @TaxAuthorityCode NVARCHAR(10) = 'WA'
	, @TaxAuthorityId INT

SELECT @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = @TaxAuthorityCode AND ysnFilingForThisTA = 1

IF(@TaxAuthorityId IS NOT NULL)
BEGIN

PRINT ('Deploying Washington Tax Forms')

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
	SELECT intProductCodeId = 0, strProductCode = '125', strDescription = 'Aviation Gasoline', strProductCodeGroup = 'Aircraft Fuel', strNote = NULL, intMasterId = 472560
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '130', strDescription = 'Jet Fuel', strProductCodeGroup = 'Aircraft Fuel', strNote = NULL, intMasterId = 472561
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'D05', strDescription = 'Biodiesel - Dyed (5%)', strProductCodeGroup = 'Special Fuel - Dyed', strNote = NULL, intMasterId = 472562
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'D20', strDescription = 'Biodiesel - Dyed (20%)', strProductCodeGroup = 'Special Fuel - Dyed', strNote = NULL, intMasterId = 472563
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'D99', strDescription = 'Biodiesel - Dyed (99%)', strProductCodeGroup = 'Special Fuel - Dyed', strNote = NULL, intMasterId = 472564
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'D00', strDescription = 'Biodiesel - Dyed (100%)', strProductCodeGroup = 'Special Fuel - Dyed', strNote = NULL, intMasterId = 472565
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '228', strDescription = 'Diesel Fuel - Dyed', strProductCodeGroup = 'Special Fuel - Dyed', strNote = NULL, intMasterId = 472566
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '072', strDescription = 'Kerosene - Dyed', strProductCodeGroup = 'Special Fuel - Dyed', strNote = NULL, intMasterId = 472567
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '090', strDescription = 'Additive Misc', strProductCodeGroup = 'Motor Fuel', strNote = NULL, intMasterId = 472568
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '123', strDescription = 'Alcohol', strProductCodeGroup = 'Motor Fuel', strNote = NULL, intMasterId = 472569
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '055', strDescription = 'Butane', strProductCodeGroup = 'Motor Fuel', strNote = NULL, intMasterId = 472570
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'E10', strDescription = 'Ethanol (10%)', strProductCodeGroup = 'Motor Fuel', strNote = NULL, intMasterId = 472571
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'E85', strDescription = 'Ethanol (85%)', strProductCodeGroup = 'Motor Fuel', strNote = NULL, intMasterId = 472572
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'E00', strDescription = 'Ethanol (100%)', strProductCodeGroup = 'Motor Fuel', strNote = NULL, intMasterId = 472573
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '065', strDescription = 'Gasoline', strProductCodeGroup = 'Motor Fuel', strNote = NULL, intMasterId = 472574
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'M00', strDescription = 'Methanol', strProductCodeGroup = 'Motor Fuel', strNote = NULL, intMasterId = 472575
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'B05', strDescription = 'Biodiesel - Undyed (5%)', strProductCodeGroup = 'Special Fuel - Undyed', strNote = NULL, intMasterId = 472576
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'B20', strDescription = 'Biodiesel - Undyed (20%)', strProductCodeGroup = 'Special Fuel - Undyed', strNote = NULL, intMasterId = 472577
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'B99', strDescription = 'Biodiesel - Undyed (99%)', strProductCodeGroup = 'Special Fuel - Undyed', strNote = NULL, intMasterId = 472578
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'B00', strDescription = 'Biodiesel - Undyed (100%)', strProductCodeGroup = 'Special Fuel - Undyed', strNote = NULL, intMasterId = 472579
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '152', strDescription = 'Heating Oil', strProductCodeGroup = 'Special Fuel - Undyed', strNote = NULL, intMasterId = 472580
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '160', strDescription = 'Diesel', strProductCodeGroup = 'Special Fuel - Undyed', strNote = NULL, intMasterId = 472581
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '167', strDescription = 'Low Sulfur Diesel #2 - Undyed', strProductCodeGroup = 'Special Fuel - Undyed', strNote = NULL, intMasterId = 472582
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '100', strDescription = 'Transmix', strProductCodeGroup = 'Special Fuel - Undyed', strNote = NULL, intMasterId = 472583
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '091', strDescription = 'Waste Oil', strProductCodeGroup = 'Special Fuel - Undyed', strNote = NULL, intMasterId = 472584
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '142', strDescription = 'Kerosene - Undyed', strProductCodeGroup = 'Special Fuel - Undyed', strNote = NULL, intMasterId = 472585

	EXEC uspTFUpgradeProductCodes @TaxAuthorityCode = @TaxAuthorityCode, @ProductCodes = @ProductCodes

-- Tax Category
/* Generate script for Tax Categories. Specify Tax Authority Id to filter out specific Tax Categories only.
select 'UNION ALL SELECT intTaxCategoryId = ' + CAST(0 AS NVARCHAR(10))
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
	SELECT intTaxCategoryId = 0, strState = 'WA', strTaxCategory = 'WA Excise Tax Gasoline', intMasterId = 472096
	UNION ALL SELECT intTaxCategoryId = 0, strState = 'WA', strTaxCategory = 'WA Excise Tax Diesel Clear', intMasterId = 472097

	EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = @TaxAuthorityCode, @TaxCategories = @TaxCategories

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
	+ CASE WHEN strSPInventory IS NULL THEN ', strSPInventory = NULL' ELSE ', strSPInventory = ''' + strSPInventory + '''' END
	+ CASE WHEN strSPInvoice IS NULL THEN ', strSPInvoice = NULL' ELSE ', strSPInvoice = ''' + strSPInvoice + '''' END
	+ CASE WHEN strSPRunReport IS NULL THEN ', strSPRunReport = NULL' ELSE ', strSPRunReport = ''' + strSPRunReport + '''' END
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
		, strSPInventory
		, strSPInvoice
		, strSPRunReport
		, intMasterId
		, intComponentTypeId
	)
	SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '1', strScheduleName = 'Gallons Received, Tax Paid', strType = 'Motor Fuel', strNote = '', strTransactionType = 'Inventory', intSort = 10, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472649, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '1', strScheduleName = 'Gallons Received, Tax Paid', strType = 'Special Fuel', strNote = '', strTransactionType = 'Inventory', intSort = 20, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472650, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '2A', strScheduleName = 'Gallons Received from WA Terminal/Refinery, Tax Exempt', strType = 'Motor Fuel', strNote = '', strTransactionType = 'Inventory', intSort = 30, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472651, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '2A', strScheduleName = 'Gallons Received from WA Terminal/Refinery, Tax Exempt', strType = 'Special Fuel', strNote = '', strTransactionType = 'Inventory', intSort = 40, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472652, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '2A', strScheduleName = 'Gallons Received from WA Terminal/Refinery, Tax Exempt', strType = 'Dyed Speical Fuel', strNote = '', strTransactionType = 'Inventory', intSort = 50, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472653, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '2B', strScheduleName = 'Gallosn Received, Tax Exempt Blend Stock', strType = 'Motor Fuel', strNote = '', strTransactionType = 'Inventory', intSort = 60, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472654, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '2B', strScheduleName = 'Gallosn Received, Tax Exempt Blend Stock', strType = 'Special Fuel', strNote = '', strTransactionType = 'Inventory', intSort = 70, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472655, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '3', strScheduleName = 'Gallons Imported Below Terminal', strType = 'Motor Fuel', strNote = '', strTransactionType = 'Inventory', intSort = 80, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472656, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '3', strScheduleName = 'Gallons Imported Below Terminal', strType = 'Special Fuel', strNote = '', strTransactionType = 'Inventory', intSort = 90, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472657, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '3', strScheduleName = 'Gallons Imported Below Terminal', strType = 'Dyed Speical Fuel', strNote = '', strTransactionType = 'Inventory', intSort = 100, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472658, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '4', strScheduleName = 'Gallons Imported to Tax Exempt Storage', strType = 'Motor Fuel', strNote = '', strTransactionType = 'Inventory', intSort = 110, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472659, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '4', strScheduleName = 'Gallons Imported to Tax Exempt Storage', strType = 'Special Fuel', strNote = '', strTransactionType = 'Inventory', intSort = 120, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472660, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '4', strScheduleName = 'Gallons Imported to Tax Exempt Storage', strType = 'Dyed Speical Fuel', strNote = '', strTransactionType = 'Inventory', intSort = 130, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472661, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '6A', strScheduleName = 'Gallons Sold to Licensed Distributors, Tax Exempt', strType = 'Motor Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 140, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472662, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '6A', strScheduleName = 'Gallons Sold to Licensed Distributors, Tax Exempt', strType = 'Special Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 150, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472663, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '6A', strScheduleName = 'Gallons Sold to Licensed Distributors, Tax Exempt', strType = 'Dyed Speical Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 160, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472664, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '6D', strScheduleName = 'Gallons Sold to Licensed Suppliers, Tax Exempt', strType = 'Motor Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 170, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472665, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '6D', strScheduleName = 'Gallons Sold to Licensed Suppliers, Tax Exempt', strType = 'Special Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 180, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472666, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '6D', strScheduleName = 'Gallons Sold to Licensed Suppliers, Tax Exempt', strType = 'Dyed Speical Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 190, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472667, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '6F', strScheduleName = 'Gallons Sold to IFTA Authorized Carriers', strType = 'Motor Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 200, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472668, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '6F', strScheduleName = 'Gallons Sold to IFTA Authorized Carriers', strType = 'Special Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 210, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472669, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '6F', strScheduleName = 'Gallons Sold to IFTA Authorized Carriers', strType = 'Dyed Speical Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 220, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472670, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '6Z', strScheduleName = 'Gallons Sold for Racing', strType = 'Motor Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 230, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472671, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '7', strScheduleName = 'Gallons Exported', strType = 'Motor Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 240, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472672, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '7', strScheduleName = 'Gallons Exported', strType = 'Special Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 250, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472673, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '7', strScheduleName = 'Gallons Exported', strType = 'Dyed Speical Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 260, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472674, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '8', strScheduleName = 'Gallons Sold to U.S. Military/National Guard/Government, Tax Exempt', strType = 'Motor Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 270, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472675, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '8', strScheduleName = 'Gallons Sold to U.S. Military/National Guard/Government, Tax Exempt', strType = 'Special Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 280, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472676, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '8', strScheduleName = 'Gallons Sold to U.S. Military/National Guard/Government, Tax Exempt', strType = 'Dyed Speical Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 290, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472677, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '10C', strScheduleName = 'Gallons Sold to Urban Passenger Transportation System, Tax Exempt', strType = 'Special Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 300, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472678, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '10C', strScheduleName = 'Gallons Sold to Urban Passenger Transportation System, Tax Exempt', strType = 'Dyed Speical Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 310, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472679, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '10D', strScheduleName = 'Credit Card Sales to Diplomats, Tax Exempt', strType = 'Motor Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 320, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472680, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '10F', strScheduleName = 'Gallons Delivered to storage WA Terminal, Tax Exempt', strType = 'Motor Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 330, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472681, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '10F', strScheduleName = 'Gallons Delivered to storage WA Terminal, Tax Exempt', strType = 'Special Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 340, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472682, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '10F', strScheduleName = 'Gallons Delivered to storage WA Terminal, Tax Exempt', strType = 'Dyed Speical Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 350, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472683, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '10G', strScheduleName = 'Gallons Sold to Other Tax-Exempt Entities', strType = 'Motor Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 360, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472684, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '10G', strScheduleName = 'Gallons Sold to Other Tax-Exempt Entities', strType = 'Special Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 370, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472685, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '10G', strScheduleName = 'Gallons Sold to Other Tax-Exempt Entities', strType = 'Dyed Speical Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 380, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472686, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '13X', strScheduleName = 'Gallons of Biodiesel Rebranded to Dyed', strType = 'Special Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 390, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472688, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Supplier', strFormName = 'WA Supplier Return', strScheduleCode = '', strScheduleName = 'Main Form', strType = '', strNote = 'Main Form', strTransactionType = NULL, intSort = 400, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = NULL, intMasterId = 472689, intComponentTypeId = 2

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
where RC.intTaxAuthorityId = @TaxAuthorityId and TaxCat.intTaxAuthorityId = @TaxAuthorityId
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
	SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Gasoline', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', strCriteria = '<> 0', intMasterId = 47412
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Diesel Clear', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', strCriteria = '<> 0', intMasterId = 47413
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Gasoline', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', strCriteria = '= 0', intMasterId = 47414
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Gasoline', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', strCriteria = '= 0', intMasterId = 47415
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Gasoline', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', strCriteria = '= 0', intMasterId = 47416
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Gasoline', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', strCriteria = '= 0', intMasterId = 47417
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Gasoline', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', strCriteria = '= 0', intMasterId = 47418
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Gasoline', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', strCriteria = '= 0', intMasterId = 47419
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Gasoline', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', strCriteria = '= 0', intMasterId = 47420
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Gasoline', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', strCriteria = '= 0', intMasterId = 47421
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Gasoline', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', strCriteria = '= 0', intMasterId = 47422
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Gasoline', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', strCriteria = '= 0', intMasterId = 47423
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Gasoline', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', strCriteria = '= 0', intMasterId = 47424
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Gasoline', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', strCriteria = '= 0', intMasterId = 47425
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Gasoline', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', strCriteria = '= 0', intMasterId = 47426
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Diesel Clear', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', strCriteria = '= 0', intMasterId = 47427
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Diesel Clear', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', strCriteria = '= 0', intMasterId = 47428
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Diesel Clear', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', strCriteria = '= 0', intMasterId = 47429
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Diesel Clear', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', strCriteria = '= 0', intMasterId = 47430
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Diesel Clear', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', strCriteria = '= 0', intMasterId = 47431
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Diesel Clear', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', strCriteria = '= 0', intMasterId = 47432
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Diesel Clear', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', strCriteria = '= 0', intMasterId = 47433
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Diesel Clear', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', strCriteria = '= 0', intMasterId = 47434
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Diesel Clear', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', strCriteria = '= 0', intMasterId = 47435
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Diesel Clear', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', strCriteria = '= 0', intMasterId = 47436
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Diesel Clear', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', strCriteria = '= 0', intMasterId = 47437
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Diesel Clear', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', strCriteria = '= 0', intMasterId = 47438
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'WA Excise Tax Diesel Clear', strState = 'WA', strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', strCriteria = '= 0', intMasterId = 47439

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
	SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', intMasterId = 473828
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', intMasterId = 473851
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 473945
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', intMasterId = 473922
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Dyed Speical Fuel', intMasterId = 473997
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', intMasterId = 473736
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', intMasterId = 473759
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Dyed Speical Fuel', intMasterId = 473974
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', intMasterId = 473782
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', intMasterId = 473951
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', intMasterId = 473805
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', intMasterId = 473928
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', intMasterId = 473882
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', intMasterId = 473845
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '055', strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', intMasterId = 473788
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', intMasterId = 473799
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Dyed Speical Fuel', intMasterId = 473985
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Dyed Speical Fuel', intMasterId = 473991
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', intMasterId = 473742
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', intMasterId = 473891
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', intMasterId = 473911
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', intMasterId = 473888
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Dyed Speical Fuel', intMasterId = 474005
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', intMasterId = 473839
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', intMasterId = 473862
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', intMasterId = 473931
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', intMasterId = 473954
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', intMasterId = 473905
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Dyed Speical Fuel', intMasterId = 474011
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', intMasterId = 473776
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', intMasterId = 473762
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', intMasterId = 473725
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', intMasterId = 473713
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', intMasterId = 473819
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Dyed Speical Fuel', intMasterId = 473968
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Dyed Speical Fuel', intMasterId = 473962
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', intMasterId = 473868
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', intMasterId = 473768
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', intMasterId = 473719
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D05', strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Dyed Speical Fuel', intMasterId = 473994
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', intMasterId = 473733
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Dyed Speical Fuel', intMasterId = 474017
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', intMasterId = 473948
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D20', strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Dyed Speical Fuel', intMasterId = 473971
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', intMasterId = 473902
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', intMasterId = 473831
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', intMasterId = 473825
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', intMasterId = 473925
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', intMasterId = 473802
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', intMasterId = 473808
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', intMasterId = 473779
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', intMasterId = 473879
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '055', strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', intMasterId = 473756
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D05', strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Dyed Speical Fuel', intMasterId = 473988
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', intMasterId = 473739
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', intMasterId = 473894
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', intMasterId = 473785
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', intMasterId = 473848
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '055', strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', intMasterId = 473748
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '055', strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', intMasterId = 473796
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 473942
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', intMasterId = 473842
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', intMasterId = 473745
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', intMasterId = 473722
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', intMasterId = 473885
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D99', strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Dyed Speical Fuel', intMasterId = 474008
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', intMasterId = 473934
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', intMasterId = 473908
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D20', strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Dyed Speical Fuel', intMasterId = 473977
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', intMasterId = 473822
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '055', strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', intMasterId = 473716
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', intMasterId = 473871
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', intMasterId = 473859
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', intMasterId = 473914
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', intMasterId = 473765
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', intMasterId = 473865
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D99', strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Dyed Speical Fuel', intMasterId = 474014
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D20', strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Dyed Speical Fuel', intMasterId = 473965
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', intMasterId = 473757
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', intMasterId = 473734
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', intMasterId = 473874
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D99', strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Dyed Speical Fuel', intMasterId = 473972
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', intMasterId = 473711
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', intMasterId = 473897
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D99', strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Dyed Speical Fuel', intMasterId = 474020
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '091', strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', intMasterId = 473926
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', intMasterId = 473949
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '091', strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', intMasterId = 473826
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', intMasterId = 473880
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', intMasterId = 473803
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '055', strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', intMasterId = 473780
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', intMasterId = 473903
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', intMasterId = 473751
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', intMasterId = 473834
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '055', strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', intMasterId = 473740
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', intMasterId = 473797
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', intMasterId = 473843
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', intMasterId = 473937
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 473943
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D20', strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Dyed Speical Fuel', intMasterId = 473989
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '091', strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', intMasterId = 473886
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D99', strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Dyed Speical Fuel', intMasterId = 473960
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', intMasterId = 473909
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Dyed Speical Fuel', intMasterId = 474003
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Dyed Speical Fuel', intMasterId = 473980
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', intMasterId = 473917
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Dyed Speical Fuel', intMasterId = 474023
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', intMasterId = 473774
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', intMasterId = 473811
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', intMasterId = 473860
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', intMasterId = 473823
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Dyed Speical Fuel', intMasterId = 474009
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D99', strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Dyed Speical Fuel', intMasterId = 473966
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', intMasterId = 473717
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', intMasterId = 473817
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '091', strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', intMasterId = 473866
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', intMasterId = 473923
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', intMasterId = 473900
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Dyed Speical Fuel', intMasterId = 473969
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '091', strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 473946
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', intMasterId = 473760
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', intMasterId = 473754
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', intMasterId = 473777
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', intMasterId = 473783
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', intMasterId = 473877
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '055', strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', intMasterId = 473708
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', intMasterId = 473854
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', intMasterId = 473731
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D05', strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Dyed Speical Fuel', intMasterId = 474000
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', intMasterId = 473929
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '091', strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', intMasterId = 473846
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', intMasterId = 473883
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', intMasterId = 473800
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', intMasterId = 473737
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', intMasterId = 473837
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Dyed Speical Fuel', intMasterId = 473986
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Dyed Speical Fuel', intMasterId = 473992
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', intMasterId = 473791
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', intMasterId = 473794
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 473940
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', intMasterId = 473743
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D05', strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Dyed Speical Fuel', intMasterId = 474006
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', intMasterId = 473840
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', intMasterId = 473863
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', intMasterId = 473957
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D20', strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Dyed Speical Fuel', intMasterId = 473983
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', intMasterId = 473763
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D05', strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Dyed Speical Fuel', intMasterId = 474012
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '091', strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', intMasterId = 473906
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', intMasterId = 473857
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', intMasterId = 473728
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', intMasterId = 473714
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', intMasterId = 473920
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', intMasterId = 473771
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', intMasterId = 473814
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', intMasterId = 473820
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Dyed Speical Fuel', intMasterId = 473963
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', intMasterId = 473720
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D05', strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Dyed Speical Fuel', intMasterId = 474018
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', intMasterId = 473924
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', intMasterId = 473709
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D20', strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Dyed Speical Fuel', intMasterId = 473995
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', intMasterId = 473778
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', intMasterId = 473849
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', intMasterId = 473855
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', intMasterId = 473832
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', intMasterId = 473901
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '055', strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', intMasterId = 473732
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', intMasterId = 473878
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', intMasterId = 473755
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 473941
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', intMasterId = 473895
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', intMasterId = 473786
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', intMasterId = 473749
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', intMasterId = 473795
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', intMasterId = 473838
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Dyed Speical Fuel', intMasterId = 473987
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', intMasterId = 473889
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', intMasterId = 473792
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', intMasterId = 473841
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', intMasterId = 473935
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', intMasterId = 473746
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D99', strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Dyed Speical Fuel', intMasterId = 473984
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', intMasterId = 473723
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D20', strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Dyed Speical Fuel', intMasterId = 474007
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D05', strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Dyed Speical Fuel', intMasterId = 473958
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D99', strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Dyed Speical Fuel', intMasterId = 473978
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D20', strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Dyed Speical Fuel', intMasterId = 474001
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', intMasterId = 473858
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', intMasterId = 473715
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', intMasterId = 473809
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', intMasterId = 473821
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', intMasterId = 473872
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', intMasterId = 473766
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '055', strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', intMasterId = 473772
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Dyed Speical Fuel', intMasterId = 474015
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', intMasterId = 473815
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', intMasterId = 473915
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D05', strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Dyed Speical Fuel', intMasterId = 473964
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', intMasterId = 473852
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', intMasterId = 473758
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', intMasterId = 473875
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', intMasterId = 473898
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', intMasterId = 473735
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', intMasterId = 473921
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', intMasterId = 473712
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Dyed Speical Fuel', intMasterId = 474021
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Dyed Speical Fuel', intMasterId = 473998
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', intMasterId = 473904
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', intMasterId = 473806
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Dyed Speical Fuel', intMasterId = 473975
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', intMasterId = 473729
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', intMasterId = 473952
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', intMasterId = 473829
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', intMasterId = 473706
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', intMasterId = 473881
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', intMasterId = 473752
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', intMasterId = 473798
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', intMasterId = 473835
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 473938
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 473944
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', intMasterId = 473789
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', intMasterId = 473892
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', intMasterId = 473769
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', intMasterId = 473912
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Dyed Speical Fuel', intMasterId = 473981
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', intMasterId = 473932
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Dyed Speical Fuel', intMasterId = 474004
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '100', strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', intMasterId = 473955
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', intMasterId = 473775
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', intMasterId = 473918
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', intMasterId = 473869
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '055', strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', intMasterId = 473812
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', intMasterId = 473726
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', intMasterId = 473861
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Dyed Speical Fuel', intMasterId = 473961
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', intMasterId = 473818
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 473947
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '091', strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', intMasterId = 473876
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', intMasterId = 473899
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Dyed Speical Fuel', intMasterId = 473993
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D05', strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Dyed Speical Fuel', intMasterId = 473970
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', intMasterId = 473784
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', intMasterId = 473707
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', intMasterId = 473801
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', intMasterId = 473807
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Dyed Speical Fuel', intMasterId = 474022
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Dyed Speical Fuel', intMasterId = 473999
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', intMasterId = 473753
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', intMasterId = 473830
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D05', strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Dyed Speical Fuel', intMasterId = 473976
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', intMasterId = 473853
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', intMasterId = 473730
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', intMasterId = 473893
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', intMasterId = 473930
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', intMasterId = 473738
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '091', strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', intMasterId = 473836
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', intMasterId = 473884
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', intMasterId = 473847
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', intMasterId = 473790
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', intMasterId = 473744
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 473939
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', intMasterId = 473793
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', intMasterId = 473864
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', intMasterId = 473770
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', intMasterId = 473721
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D05', strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Dyed Speical Fuel', intMasterId = 473982
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', intMasterId = 473933
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '091', strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', intMasterId = 473956
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', intMasterId = 473870
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '055', strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', intMasterId = 473764
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', intMasterId = 473727
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', intMasterId = 473907
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', intMasterId = 473919
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', intMasterId = 473813
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', intMasterId = 473913
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D20', strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Dyed Speical Fuel', intMasterId = 474013
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', intMasterId = 473781
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', intMasterId = 473710
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D99', strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Dyed Speical Fuel', intMasterId = 473996
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D20', strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Dyed Speical Fuel', intMasterId = 474019
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', intMasterId = 473950
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', intMasterId = 473873
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Dyed Speical Fuel', intMasterId = 473973
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', intMasterId = 473850
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '091', strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', intMasterId = 473856
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', intMasterId = 473827
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', intMasterId = 473927
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '055', strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', intMasterId = 473804
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', intMasterId = 473787
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', intMasterId = 473750
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', intMasterId = 473833
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '091', strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', intMasterId = 473896
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', intMasterId = 473844
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D99', strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Dyed Speical Fuel', intMasterId = 473990
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', intMasterId = 473741
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', intMasterId = 473890
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D20', strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Dyed Speical Fuel', intMasterId = 473959
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', intMasterId = 473887
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '091', strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', intMasterId = 473936
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', intMasterId = 473910
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', intMasterId = 473747
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '055', strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', intMasterId = 473724
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Dyed Speical Fuel', intMasterId = 473979
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D99', strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Dyed Speical Fuel', intMasterId = 474002
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', intMasterId = 473953
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', intMasterId = 473824
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'M00', strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', intMasterId = 473761
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E10', strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', intMasterId = 473773
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '090', strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', intMasterId = 473810
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', intMasterId = 473867
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Dyed Speical Fuel', intMasterId = 474010
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Dyed Speical Fuel', intMasterId = 474016
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D00', strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Dyed Speical Fuel', intMasterId = 473967
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '091', strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', intMasterId = 473916
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', intMasterId = 473767
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', intMasterId = 473816
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', intMasterId = 473718

	INSERT INTO @ValidOriginStates(
		intValidOriginStateId
		, strFormCode
		, strScheduleCode
		, strType
		, strState
		, strStatus
		, intMasterId
	)
	SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47498
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47499
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47500
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47501
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Dyed Speical Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47502
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47503
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47504
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', strState = 'WA', strStatus = 'Exclude', intMasterId = 47505
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', strState = 'WA', strStatus = 'Exclude', intMasterId = 47506
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Dyed Speical Fuel', strState = 'WA', strStatus = 'Exclude', intMasterId = 47507
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', strState = 'WA', strStatus = 'Exclude', intMasterId = 47508
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', strState = 'WA', strStatus = 'Exclude', intMasterId = 47509
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Dyed Speical Fuel', strState = 'WA', strStatus = 'Exclude', intMasterId = 47510
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47511
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47512
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Dyed Speical Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47513
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47514
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47515
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Dyed Speical Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47516
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47517
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47518
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Dyed Speical Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47519
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47520
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47529
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47530
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Dyed Speical Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47531
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47521
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47522
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Dyed Speical Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47523
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47524
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Dyed Speical Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47525
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47526
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47527
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Dyed Speical Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47528

	INSERT INTO @ValidDestinationStates(
		intValidDestinationStateId
		, strFormCode
		, strScheduleCode
		, strType
		, strState
		, strStatus
		, intMasterId
	)
	SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47564
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47565
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47566
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47567
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Dyed Speical Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47568
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47569
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47570
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47571
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47572
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Dyed Speical Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47573
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47574
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47575
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Dyed Speical Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47576
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47577
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47578
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Dyed Speical Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47579
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47580
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47581
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Dyed Speical Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47582
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47583
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47584
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Dyed Speical Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47585
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47586
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', strState = 'WA', strStatus = 'Exclude', intMasterId = 47595
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', strState = 'WA', strStatus = 'Exclude', intMasterId = 47596
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Dyed Speical Fuel', strState = 'WA', strStatus = 'Exclude', intMasterId = 47597
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47587
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47588
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Dyed Speical Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47589
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47590
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Dyed Speical Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47591
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47598
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47599
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Dyed Speical Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47600
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47592
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47593
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Dyed Speical Fuel', strState = 'WA', strStatus = 'Include', intMasterId = 47594

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
		, intMasterId
	)
	SELECT intReportTemplateId = 0, strFormCode = 'Supplier', strScheduleCode = '', strType = '', strTemplateItemId = 'Supplier-AcctNumber', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '1', strDescription = 'WA Account Number', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = NULL, ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 47387
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'Supplier', strScheduleCode = '', strType = '', strTemplateItemId = 'Supplier-Line23TaxRateMF', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '2', strDescription = 'Line 23 Tax Rate - Motor Fuel', strScheduleList = NULL, strConfiguration = '0.494', ysnConfiguration = NULL, ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 47388
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'Supplier', strScheduleCode = '', strType = '', strTemplateItemId = 'Supplier-Line23TaxRateSF', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '3', strDescription = 'Line 23 Tax Rate - Special Fuel', strScheduleList = NULL, strConfiguration = '0.494', ysnConfiguration = NULL, ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 47389
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'Supplier', strScheduleCode = '', strType = '', strTemplateItemId = 'Supplier-Line24PenaltyPctMF', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '4', strDescription = 'Line 24 Penalty Percentage - Motor Fuel', strScheduleList = NULL, strConfiguration = '0.10', ysnConfiguration = NULL, ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 47390
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'Supplier', strScheduleCode = '', strType = '', strTemplateItemId = 'Supplier-Line24PenaltyPctSF', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '5', strDescription = 'Line 24 Penalty Percentage - Special Fuel', strScheduleList = NULL, strConfiguration = '0.10', ysnConfiguration = NULL, ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 47391
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'Supplier', strScheduleCode = '', strType = '', strTemplateItemId = 'Supplier-Line26IntAmtMF', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '6', strDescription = 'Line 26 Interest Amount - Motor Fuel', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = NULL, ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 47392
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'Supplier', strScheduleCode = '', strType = '', strTemplateItemId = 'Supplier-Line26IntAmtSF', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '7', strDescription = 'Line 26 Interest Amount - Special Fuel', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = NULL, ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 47393
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'Supplier', strScheduleCode = '', strType = '', strTemplateItemId = 'Supplier-Line28PrevPaymentMF', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '8', strDescription = 'Line 28 Previous Tax Payment for This Reporting Period - Motor Fuel', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = NULL, ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 47394
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'Supplier', strScheduleCode = '', strType = '', strTemplateItemId = 'Supplier-Line28PrevPaymentSF', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '9', strDescription = 'Line 28 Previous Tax Payment for This Reporting Period - Special Fuel', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = NULL, ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 47395
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'Supplier', strScheduleCode = '', strType = '', strTemplateItemId = 'Supplier-Line29CreditMF', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '10', strDescription = 'Line 29 Other Fuel Tax Credit - Motor Fuel', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = NULL, ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 47396
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'Supplier', strScheduleCode = '', strType = '', strTemplateItemId = 'Supplier-Line29CreditSF', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '11', strDescription = 'Line 29 Other Fuel Tax Credit - Special Fuel', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = NULL, ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 47397

	EXEC uspTFUpgradeReportingComponentConfigurations @TaxAuthorityCode = @TaxAuthorityCode, @ReportingComponentConfigurations = @ReportingComponentConfigurations

-- Reporting Component - Output Designer
/* Generate script for Reporting Component - Output Designer. Specify Tax Authority Id to filter out specific Reporting Component - Output Designer only.
select 'UNION ALL SELECT intScheduleColumnId = ' + CAST(0 AS NVARCHAR(10))
	+ CASE WHEN strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END
	+ CASE WHEN strColumn IS NULL THEN ', strColumn = NULL' ELSE ', strColumn = ''' + strColumn + '''' END
	+ CASE WHEN strCaption IS NULL THEN ', strCaption = NULL' ELSE ', strCaption = ''' + strCaption + '''' END
	+ CASE WHEN strFormat IS NULL THEN ', strFormat = NULL' ELSE ', strFormat = ''' + strFormat + '''' END
	+ CASE WHEN strFooter IS NULL THEN ', strFooter = NULL' ELSE ', strFooter = ''' + strFooter + '''' END
	+ CASE WHEN intWidth IS NULL THEN ', intWidth = NULL' ELSE ', intWidth = ' + CAST(intWidth AS NVARCHAR(10)) END
--	+ ', intMasterId = ' + CAST((CASE WHEN ISNULL(RCF.intMasterId, '') = '' THEN intReportingComponentFieldId ELSE RCF.intMasterId END) AS NVARCHAR(20)) -- Old Format
	+ ', intMasterId = ' + CASE WHEN RCF.intMasterId IS NULL THEN CAST(@TaxAuthorityId AS NVARCHAR(20)) + CAST(intReportingComponentFieldId AS NVARCHAR(20)) ELSE CAST(RCF.intMasterId AS NVARCHAR(20)) END -- First 2 digit for TaxAuthorityCodeID
from tblTFReportingComponentField RCF
left join tblTFReportingComponent RC on RC.intReportingComponentId = RCF.intReportingComponentId
where RC.intTaxAuthorityId = @TaxAuthorityId
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
		, intMasterId
	)
	SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712260
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712261
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712262
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712263
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712264
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712265
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712266
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712267
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712268
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712269
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712270
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712271
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712272
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', strColumn = 'dbmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712273
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712274
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712275
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712276
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712277
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712278
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712279
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712280
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712281
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712282
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712283
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712284
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712285
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712286
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712287
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712288
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712289
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712290
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'dbmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712291
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712292
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712293
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712294
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712295
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712296
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712297
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712298
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712299
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712300
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712301
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712302
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712303
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712304
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712305
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712306
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712307
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712308
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', strColumn = 'dbmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712309
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712310
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712311
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712312
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712313
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712314
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712315
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712316
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712317
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712318
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712319
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712320
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712321
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712322
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712323
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712324
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712325
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712326
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'dbmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712327
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712328
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712329
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712330
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712331
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Dyed Speical Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712332
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Dyed Speical Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712333
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Dyed Speical Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712334
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Dyed Speical Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712335
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Dyed Speical Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712336
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Dyed Speical Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712337
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Dyed Speical Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712338
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Dyed Speical Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712339
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712340
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712341
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712342
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Dyed Speical Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712343
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Dyed Speical Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712344
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Dyed Speical Fuel', strColumn = 'dbmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712345
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Dyed Speical Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712346
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Dyed Speical Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712347
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Dyed Speical Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712348
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Dyed Speical Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712349
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712350
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712351
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712352
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712353
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712354
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712355
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712356
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712357
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712358
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712359
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712360
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712361
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712362
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', strColumn = 'dbmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712363
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712364
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712365
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712366
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712367
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712368
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712369
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712370
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712371
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712372
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712373
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712374
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712375
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712376
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712377
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712378
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712379
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712380
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'dbmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712381
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712382
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712383
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712384
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712385
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712386
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712387
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712388
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712389
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712390
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712391
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712392
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712393
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712394
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712395
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712396
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712397
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712398
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', strColumn = 'dbmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712399
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712400
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712401
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712402
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712403
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712404
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712405
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712406
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712407
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712408
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712409
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712410
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712411
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712412
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712413
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712414
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712415
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712416
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'dbmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712417
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712418
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712419
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712420
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712421
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Dyed Speical Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712422
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Dyed Speical Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712423
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Dyed Speical Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712424
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Dyed Speical Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712425
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Dyed Speical Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712426
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Dyed Speical Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712427
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Dyed Speical Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712428
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Dyed Speical Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712429
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712430
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712431
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712432
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Dyed Speical Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712433
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Dyed Speical Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712434
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Dyed Speical Fuel', strColumn = 'dbmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712435
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Dyed Speical Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712436
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Dyed Speical Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712437
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Dyed Speical Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712438
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Dyed Speical Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712439
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712440
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712441
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712442
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712443
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712444
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712445
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712446
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712447
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712448
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712449
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712450
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712451
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712452
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', strColumn = 'dbmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712453
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712454
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712455
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712456
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712457
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712458
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712459
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712460
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712461
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712462
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712463
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712464
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712465
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712466
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712467
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712468
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712469
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712470
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'dbmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712471
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712472
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712473
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712474
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712475
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Dyed Speical Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712476
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Dyed Speical Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712477
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Dyed Speical Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712478
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Dyed Speical Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712479
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Dyed Speical Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712480
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Dyed Speical Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712481
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Dyed Speical Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712482
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Dyed Speical Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712483
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712484
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712485
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712486
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Dyed Speical Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712487
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Dyed Speical Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712488
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Dyed Speical Fuel', strColumn = 'dbmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712489
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Dyed Speical Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712490
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Dyed Speical Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712491
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Dyed Speical Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712492
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Dyed Speical Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712493
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712494
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712495
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712496
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712497
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712498
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712499
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712500
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712501
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712502
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712503
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712504
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712505
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712506
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', strColumn = 'dbmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712507
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712508
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712509
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712510
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712511
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712512
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712513
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712514
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712515
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712516
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712517
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712518
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712519
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712520
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712521
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712522
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712523
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712524
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', strColumn = 'dbmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712525
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712526
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712527
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712528
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712529
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Dyed Speical Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712530
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Dyed Speical Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712531
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Dyed Speical Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712532
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Dyed Speical Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712533
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Dyed Speical Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712534
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Dyed Speical Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712535
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Dyed Speical Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712536
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Dyed Speical Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712537
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712538
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712539
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712540
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Dyed Speical Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712541
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Dyed Speical Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712542
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Dyed Speical Fuel', strColumn = 'dbmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712543
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Dyed Speical Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712544
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Dyed Speical Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712545
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Dyed Speical Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712546
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Dyed Speical Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712547
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712548
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712549
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712550
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712551
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712552
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712553
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712554
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712555
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712556
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712557
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712558
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712559
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712560
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', strColumn = 'dbmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712561
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712562
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712563
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712564
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712565
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712566
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712567
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712568
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712569
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712570
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712571
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712572
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712573
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712574
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712575
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712576
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712577
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712578
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', strColumn = 'dbmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712579
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712580
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712581
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712582
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712583
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Dyed Speical Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712584
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Dyed Speical Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712585
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Dyed Speical Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712586
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Dyed Speical Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712587
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Dyed Speical Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712588
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Dyed Speical Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712589
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Dyed Speical Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712590
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Dyed Speical Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712591
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712592
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712593
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712594
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Dyed Speical Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712595
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Dyed Speical Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712596
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Dyed Speical Fuel', strColumn = 'dbmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712597
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Dyed Speical Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712598
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Dyed Speical Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712599
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Dyed Speical Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712600
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Dyed Speical Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712601
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712602
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712603
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712604
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712605
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712606
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712607
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712608
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712609
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712610
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712611
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712612
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712613
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712614
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', strColumn = 'dbmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712615
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712616
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712617
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712618
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712619
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712620
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712621
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712622
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712623
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712624
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712625
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712626
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712627
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712628
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712629
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712630
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712631
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712632
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', strColumn = 'dbmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712633
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712634
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712635
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712636
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712637
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Dyed Speical Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712638
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Dyed Speical Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712639
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Dyed Speical Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712640
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Dyed Speical Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712641
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Dyed Speical Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712642
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Dyed Speical Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712643
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Dyed Speical Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712644
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Dyed Speical Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712645
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712646
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712647
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712648
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Dyed Speical Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712649
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Dyed Speical Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712650
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Dyed Speical Fuel', strColumn = 'dbmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712651
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Dyed Speical Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712652
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Dyed Speical Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712653
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Dyed Speical Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712654
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Dyed Speical Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712655
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712656
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712657
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712658
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712659
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712660
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712661
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712662
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712663
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712664
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712665
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712666
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712667
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712668
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', strColumn = 'dbmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712669
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712670
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712671
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712672
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712673
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712674
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712675
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712676
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712677
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712678
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712679
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712680
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712681
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712682
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712683
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712684
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712685
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712686
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', strColumn = 'dbmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712687
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712688
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712689
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712690
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712691
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712692
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712693
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712694
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712695
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712696
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712697
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712698
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712699
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712700
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712701
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712702
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712703
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712704
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'dbmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712705
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712706
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712707
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712708
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712709
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Dyed Speical Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712710
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Dyed Speical Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712711
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Dyed Speical Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712712
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Dyed Speical Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712713
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Dyed Speical Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712714
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Dyed Speical Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712715
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Dyed Speical Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712716
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Dyed Speical Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712717
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712718
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712719
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712720
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Dyed Speical Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712721
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Dyed Speical Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712722
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Dyed Speical Fuel', strColumn = 'dbmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712723
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Dyed Speical Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712724
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Dyed Speical Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712725
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Dyed Speical Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712726
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Dyed Speical Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712727
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712728
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712729
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712730
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712731
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712732
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712733
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712734
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712735
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712736
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712737
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712738
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712739
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712740
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', strColumn = 'dbmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712741
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712742
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712743
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712744
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712745
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712746
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712747
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712748
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712749
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712750
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712751
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712752
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712753
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712754
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712755
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712756
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712757
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712758
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'dbmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712759
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712760
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712761
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712762
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712763
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Dyed Speical Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712764
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Dyed Speical Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712765
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Dyed Speical Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712766
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Dyed Speical Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712767
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Dyed Speical Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712768
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Dyed Speical Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712769
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Dyed Speical Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712770
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Dyed Speical Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712771
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712772
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712773
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712774
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Dyed Speical Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712775
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Dyed Speical Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712776
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Dyed Speical Fuel', strColumn = 'dbmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712777
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Dyed Speical Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712778
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Dyed Speical Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712779
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Dyed Speical Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712780
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Dyed Speical Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712781
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712782
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712783
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712784
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712785
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712786
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712787
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712788
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712789
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712790
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712791
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712792
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712793
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712794
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', strColumn = 'dbmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712795
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712796
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712797
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712798
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712799
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Dyed Speical Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712800
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Dyed Speical Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712801
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Dyed Speical Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712802
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Dyed Speical Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712803
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Dyed Speical Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712804
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Dyed Speical Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712805
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Dyed Speical Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712806
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Dyed Speical Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712807
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712808
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712809
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712810
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Dyed Speical Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712811
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Dyed Speical Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712812
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Dyed Speical Fuel', strColumn = 'dbmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712813
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Dyed Speical Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712814
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Dyed Speical Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712815
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Dyed Speical Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712816
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Dyed Speical Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712817
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712818
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712819
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712820
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712821
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712822
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712823
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712824
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712825
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712826
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712827
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712828
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712829
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712830
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', strColumn = 'dbmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712831
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712832
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712833
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712834
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712835
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712836
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712837
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712838
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712839
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712840
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712841
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712842
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712843
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712844
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712845
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712846
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712847
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712848
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', strColumn = 'dbmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712849
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712850
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712851
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712852
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712853
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712854
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712855
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712856
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712857
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712858
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712859
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712860
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712861
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712862
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712863
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712864
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712865
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712866
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'dbmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712867
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712868
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712869
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712870
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712871
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Dyed Speical Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712872
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Dyed Speical Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712873
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Dyed Speical Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712874
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Dyed Speical Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712875
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Dyed Speical Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712876
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Dyed Speical Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712877
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Dyed Speical Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712878
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Dyed Speical Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712879
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712880
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712881
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712882
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Dyed Speical Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712883
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Dyed Speical Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712884
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Dyed Speical Fuel', strColumn = 'dbmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712885
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Dyed Speical Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712886
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Dyed Speical Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712887
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Dyed Speical Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712888
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Dyed Speical Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712889
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712890
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712891
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712892
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712893
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712894
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712895
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712896
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712897
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712898
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712899
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712900
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712901
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712902
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', strColumn = 'dbmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712903
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712904
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712905
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712906
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712907
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712908
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712909
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712910
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712911
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712912
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712913
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712914
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712915
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712916
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712917
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712918
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712919
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712920
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'dbmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712921
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712922
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712923
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712924
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712925
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Dyed Speical Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712926
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Dyed Speical Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712927
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Dyed Speical Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712928
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Dyed Speical Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712929
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Dyed Speical Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712930
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Dyed Speical Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712931
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Dyed Speical Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712932
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Dyed Speical Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712933
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712934
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712935
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Dyed Speical Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712936
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Dyed Speical Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712937
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Dyed Speical Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712938
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Dyed Speical Fuel', strColumn = 'dbmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712939
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Dyed Speical Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712940
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Dyed Speical Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712941
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Dyed Speical Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712942
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Dyed Speical Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712943
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', strColumn = 'strScheduleCode', strCaption = 'Schedule', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712944
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712945
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712946
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712947
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712948
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712949
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712950
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Origin TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712951
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712952
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712953
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', strColumn = 'strDestinationTCN', strCaption = 'Destination TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712954
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712955
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712956
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', strColumn = 'dbmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712957
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', strColumn = 'strBillOfLading', strCaption = 'Document #', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712958
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712959
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712960
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 4712961

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
	SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 473030
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Motor Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 472990
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '1', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 472991
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Dyed Speical Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473020
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '10C', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473019
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '10D', strType = 'Motor Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473021
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Dyed Speical Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473024
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Motor Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473022
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '10F', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473023
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Dyed Speical Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473027
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Motor Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473025
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '10G', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473026
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '13X', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473029
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Dyed Speical Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 472994
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Motor Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 472992
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '2A', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 472993
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Motor Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 472995
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '2B', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 472996
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Dyed Speical Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 472999
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Motor Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 472997
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '3', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 472998
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Dyed Speical Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473002
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Motor Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473000
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '4', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473001
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Dyed Speical Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473005
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Motor Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473003
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '6A', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473004
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Dyed Speical Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473008
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Motor Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473006
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '6D', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473007
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Dyed Speical Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473011
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Motor Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473009
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '6F', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473010
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '6Z', strType = 'Motor Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473012
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Dyed Speical Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473015
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Motor Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473013
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '7', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473014
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Dyed Speical Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473018
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Motor Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473016
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Supplier', strScheduleCode = '8', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 473017

	EXEC uspTFUpgradeFilingPackets @TaxAuthorityCode = @TaxAuthorityCode, @FilingPackets = @FilingPackets

END

GO