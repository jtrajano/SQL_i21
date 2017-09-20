DECLARE @TaxAuthorityCode NVARCHAR(10) = 'LA'
	, @TaxAuthorityId INT

SELECT @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = @TaxAuthorityCode AND ysnFilingForThisTA = 1

IF(@TaxAuthorityId IS NOT NULL)
BEGIN

PRINT ('Deploying Louisiana Tax Forms')

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
	SELECT intProductCodeId = 2522, strProductCode = '065', strDescription = 'Gasoline', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 182522
	UNION ALL SELECT intProductCodeId = 2523, strProductCode = '123', strDescription = 'Alcohol', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 182523
	UNION ALL SELECT intProductCodeId = 2524, strProductCode = '125', strDescription = 'Aviation Gasoline', strProductCodeGroup = 'Aviation', strNote = NULL, intMasterId = 182524
	UNION ALL SELECT intProductCodeId = 2525, strProductCode = '130', strDescription = 'Jet Fuel', strProductCodeGroup = 'Aviation', strNote = NULL, intMasterId = 182525
	UNION ALL SELECT intProductCodeId = 2526, strProductCode = '124', strDescription = 'Gasohol', strProductCodeGroup = 'Gasohol', strNote = NULL, intMasterId = 182526
	UNION ALL SELECT intProductCodeId = 2527, strProductCode = '142', strDescription = 'Kerosene - Undyed', strProductCodeGroup = 'Diesel - Undyed', strNote = NULL, intMasterId = 182527
	UNION ALL SELECT intProductCodeId = 2528, strProductCode = '160', strDescription = 'Diesel - Undyed', strProductCodeGroup = 'Diesel - Undyed', strNote = NULL, intMasterId = 182528
	UNION ALL SELECT intProductCodeId = 2529, strProductCode = '170', strDescription = 'Biodiesel - Undyed', strProductCodeGroup = 'Diesel - Undyed', strNote = NULL, intMasterId = 182529
	UNION ALL SELECT intProductCodeId = 2530, strProductCode = '072', strDescription = 'Kerosene - Dyed', strProductCodeGroup = 'Diesel - Dyed', strNote = NULL, intMasterId = 182530
	UNION ALL SELECT intProductCodeId = 2531, strProductCode = '228', strDescription = 'Diesel - Dyed', strProductCodeGroup = 'Diesel - Dyed', strNote = NULL, intMasterId = 182531
	UNION ALL SELECT intProductCodeId = 2532, strProductCode = '171', strDescription = 'Biodiesel - Dyed', strProductCodeGroup = 'Diesel - Dyed', strNote = NULL, intMasterId = 182532

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
	-- Insert generated script here. Remove first instance of "UNION ALL "
	SELECT intTaxCategoryId = 2059, strState = 'LA', strTaxCategory = 'LA Excise Tax Gasoline', intMasterId = 182059
	UNION ALL SELECT intTaxCategoryId = 2060, strState = 'LA', strTaxCategory = 'LA Excise Tax Gasohol', intMasterId = 182060
	UNION ALL SELECT intTaxCategoryId = 2061, strState = 'LA', strTaxCategory = 'LA Excise Tax Diesel Clear', intMasterId = 182061
	UNION ALL SELECT intTaxCategoryId = 2062, strState = 'LA', strTaxCategory = 'LA Inspection Fee', intMasterId = 182062

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
	SELECT intReportingComponentId = 2531, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-23', strScheduleName = 'Gallons Transported into LA', strType = 'Gasohol', strNote = '23', strTransactionType = 'Invoice', intSort = 10, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182531, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2532, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-23', strScheduleName = 'Gallons Transported into LA', strType = 'Gasoline', strNote = '23', strTransactionType = 'Invoice', intSort = 20, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182532, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2533, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-23', strScheduleName = 'Gallons Transported into LA', strType = 'Undyed Diesel', strNote = '23', strTransactionType = 'Invoice', intSort = 30, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182533, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2534, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-23', strScheduleName = 'Gallons Transported into LA', strType = 'Dyed Diesel', strNote = '23', strTransactionType = 'Invoice', intSort = 40, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182534, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2535, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-23', strScheduleName = 'Gallons Transported into LA', strType = 'Aviation Fuels', strNote = '23', strTransactionType = 'Invoice', intSort = 50, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182535, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2536, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-24', strScheduleName = 'Gallons Transported out of LA', strType = 'Gasohol', strNote = '24', strTransactionType = 'Invoice', intSort = 60, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182536, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2537, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-24', strScheduleName = 'Gallons Transported out of LA', strType = 'Gasoline', strNote = '24', strTransactionType = 'Invoice', intSort = 70, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182537, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2538, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-24', strScheduleName = 'Gallons Transported out of LA', strType = 'Undyed Diesel', strNote = '24', strTransactionType = 'Invoice', intSort = 80, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182538, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2539, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-24', strScheduleName = 'Gallons Transported out of LA', strType = 'Dyed Diesel', strNote = '24', strTransactionType = 'Invoice', intSort = 90, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182539, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2540, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-24', strScheduleName = 'Gallons Transported out of LA', strType = 'Aviation Fuels', strNote = '24', strTransactionType = 'Invoice', intSort = 100, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182540, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2541, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-25', strScheduleName = 'Gallons Transported within LA', strType = 'Gasohol', strNote = '25', strTransactionType = 'Invoice', intSort = 110, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182541, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2542, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-25', strScheduleName = 'Gallons Transported within LA', strType = 'Gasoline', strNote = '25', strTransactionType = 'Invoice', intSort = 120, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182542, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2543, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-25', strScheduleName = 'Gallons Transported within LA', strType = 'Undyed Diesel', strNote = '25', strTransactionType = 'Invoice', intSort = 130, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182543, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2544, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-25', strScheduleName = 'Gallons Transported within LA', strType = 'Dyed Diesel', strNote = '25', strTransactionType = 'Invoice', intSort = 140, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182544, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2545, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-25', strScheduleName = 'Gallons Transported within LA', strType = 'Aviation Fuels', strNote = '25', strTransactionType = 'Invoice', intSort = 150, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182545, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2546, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = '', strScheduleName = 'Main Form', strType = '', strNote = 'LA R-5346 Transporter Return', strTransactionType = NULL, intSort = 160, strSPInventory = '', strSPInvoice = '', strSPRunReport = 'uspTFGenerateLATransporter', intMasterId = 182546, intComponentTypeId = 2
	UNION ALL SELECT intReportingComponentId = 2547, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'A-1', strScheduleName = 'Gallons Received/Imported, LA Tax and Inspection Fee Paid', strType = 'Gasohol', strNote = '1', strTransactionType = 'Invoice', intSort = 170, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182547, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2548, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'A-1', strScheduleName = 'Gallons Received/Imported, LA Tax and Inspection Fee Paid', strType = 'Gasoline', strNote = '1', strTransactionType = 'Invoice', intSort = 180, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182548, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2549, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'A-1', strScheduleName = 'Gallons Received/Imported, LA Tax and Inspection Fee Paid', strType = 'Undyed Diesel', strNote = '1', strTransactionType = 'Invoice', intSort = 190, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182549, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2550, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'A-2', strScheduleName = 'Gallons Received/Imported, LA Inspection Fee Paid', strType = 'Dyed Diesel', strNote = '2', strTransactionType = 'Invoice', intSort = 200, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182550, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2551, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'A-2', strScheduleName = 'Gallons Received/Imported, LA Inspection Fee Paid', strType = 'Aviation Fuels', strNote = '2', strTransactionType = 'Invoice', intSort = 210, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182551, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2552, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'A-3', strScheduleName = 'Gallons Received/Imported, LA Tax or Fee Unpaid', strType = 'Gasohol', strNote = '3', strTransactionType = 'Invoice', intSort = 220, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182552, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2553, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'A-3', strScheduleName = 'Gallons Received/Imported, LA Tax or Fee Unpaid', strType = 'Gasoline', strNote = '3', strTransactionType = 'Invoice', intSort = 230, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182553, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2554, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'A-3', strScheduleName = 'Gallons Received/Imported, LA Tax or Fee Unpaid', strType = 'Undyed Diesel', strNote = '3', strTransactionType = 'Invoice', intSort = 240, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182554, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2555, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'A-3', strScheduleName = 'Gallons Received/Imported, LA Tax or Fee Unpaid', strType = 'Dyed Diesel', strNote = '3', strTransactionType = 'Invoice', intSort = 250, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182555, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2556, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'A-3', strScheduleName = 'Gallons Received/Imported, LA Tax or Fee Unpaid', strType = 'Aviation Fuels', strNote = '3', strTransactionType = 'Invoice', intSort = 260, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182556, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2557, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'D-21', strScheduleName = 'Gallons Diverted into LA, LA Tax or Fee Unpaid', strType = 'Gasohol', strNote = '21', strTransactionType = 'Invoice', intSort = 370, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182557, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2558, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'D-21', strScheduleName = 'Gallons Diverted into LA, LA Tax or Fee Unpaid', strType = 'Gasoline', strNote = '21', strTransactionType = 'Invoice', intSort = 380, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182558, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2559, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'D-21', strScheduleName = 'Gallons Diverted into LA, LA Tax or Fee Unpaid', strType = 'Undyed Diesel', strNote = '21', strTransactionType = 'Invoice', intSort = 390, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182559, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2560, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'D-21', strScheduleName = 'Gallons Diverted into LA, LA Tax or Fee Unpaid', strType = 'Dyed Diesel', strNote = '21', strTransactionType = 'Invoice', intSort = 400, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182560, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2561, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'D-21', strScheduleName = 'Gallons Diverted into LA, LA Tax or Fee Unpaid', strType = 'Aviation Fuels', strNote = '21', strTransactionType = 'Invoice', intSort = 410, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = '', intMasterId = 182561, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 2562, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = '', strScheduleName = 'Main Form', strType = '', strNote = 'LA R-5399 Importer Return', strTransactionType = NULL, intSort = 420, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateLAImporter', intMasterId = 182562, intComponentTypeId = 2

	EXEC uspTFUpgradeReportingComponents @TaxAuthorityCode = @TaxAuthorityCode, @ReportingComponent = @ReportingComponent

-- Tax Criteria
/* Generate script for Tax Criteria. Specify Tax Authority Id to filter out specific Tax Criteria only.
select 'UNION ALL SELECT intTaxCriteriaId = ' + CAST(intReportingComponentCriteriaId AS NVARCHAR(10))
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
	SELECT intTaxCriteriaId = 355, strTaxCategory = 'LA Excise Tax Gasohol', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strCriteria = '<> 0', intMasterId = 18355
	UNION ALL SELECT intTaxCriteriaId = 356, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strCriteria = '<> 0', intMasterId = 18356
	UNION ALL SELECT intTaxCriteriaId = 357, strTaxCategory = 'LA Excise Tax Gasoline', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strCriteria = '<> 0', intMasterId = 18357
	UNION ALL SELECT intTaxCriteriaId = 358, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strCriteria = '<> 0', intMasterId = 18358
	UNION ALL SELECT intTaxCriteriaId = 359, strTaxCategory = 'LA Excise Tax Diesel Clear', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strCriteria = '<> 0', intMasterId = 18359
	UNION ALL SELECT intTaxCriteriaId = 360, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strCriteria = '<> 0', intMasterId = 18360
	UNION ALL SELECT intTaxCriteriaId = 361, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strCriteria = '<> 0', intMasterId = 18361
	UNION ALL SELECT intTaxCriteriaId = 362, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strCriteria = '<> 0', intMasterId = 18362
	UNION ALL SELECT intTaxCriteriaId = 363, strTaxCategory = 'LA Excise Tax Gasohol', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strCriteria = '= 0', intMasterId = 18363
	UNION ALL SELECT intTaxCriteriaId = 364, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strCriteria = '= 0', intMasterId = 18364
	UNION ALL SELECT intTaxCriteriaId = 365, strTaxCategory = 'LA Excise Tax Gasoline', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strCriteria = '= 0', intMasterId = 18365
	UNION ALL SELECT intTaxCriteriaId = 366, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strCriteria = '= 0', intMasterId = 18366
	UNION ALL SELECT intTaxCriteriaId = 367, strTaxCategory = 'LA Excise Tax Diesel Clear', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strCriteria = '= 0', intMasterId = 18367
	UNION ALL SELECT intTaxCriteriaId = 368, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strCriteria = '= 0', intMasterId = 18368
	UNION ALL SELECT intTaxCriteriaId = 370, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strCriteria = '= 0', intMasterId = 18370
	UNION ALL SELECT intTaxCriteriaId = 371, strTaxCategory = 'LA Excise Tax Gasoline', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strCriteria = '= 0', intMasterId = 18371
	UNION ALL SELECT intTaxCriteriaId = 372, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strCriteria = '= 0', intMasterId = 18372
	UNION ALL SELECT intTaxCriteriaId = 373, strTaxCategory = 'LA Excise Tax Gasohol', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strCriteria = '= 0', intMasterId = 18373
	UNION ALL SELECT intTaxCriteriaId = 374, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strCriteria = '= 0', intMasterId = 18374
	UNION ALL SELECT intTaxCriteriaId = 375, strTaxCategory = 'LA Excise Tax Gasoline', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strCriteria = '= 0', intMasterId = 18375
	UNION ALL SELECT intTaxCriteriaId = 376, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strCriteria = '= 0', intMasterId = 18376
	UNION ALL SELECT intTaxCriteriaId = 377, strTaxCategory = 'LA Excise Tax Diesel Clear', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strCriteria = '= 0', intMasterId = 18377
	UNION ALL SELECT intTaxCriteriaId = 378, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strCriteria = '= 0', intMasterId = 18378
	UNION ALL SELECT intTaxCriteriaId = 380, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strCriteria = '= 0', intMasterId = 18380
	UNION ALL SELECT intTaxCriteriaId = 381, strTaxCategory = 'LA Excise Tax Gasoline', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strCriteria = '= 0', intMasterId = 18381
	UNION ALL SELECT intTaxCriteriaId = 382, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strCriteria = '= 0', intMasterId = 18382
	
	EXEC uspTFUpgradeTaxCriteria @TaxAuthorityCode = @TaxAuthorityCode, @TaxCriteria = @TaxCriteria

-- Reporting Component - Base
/* Generate script for Valid Product Codes. Specify Tax Authority Id to filter out specific Valid Product Codes only.
select 'UNION ALL SELECT intValidProductCodeId = ' + CAST(intReportingComponentProductCodeId AS NVARCHAR(10))
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
select 'UNION ALL SELECT intValidOriginStateId = ' + CAST(intReportingComponentOriginStateId AS NVARCHAR(10))
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
select 'UNION ALL SELECT intValidDestinationStateId = ' + CAST(intReportingComponentDestinationStateId AS NVARCHAR(10))
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
	SELECT intValidProductCodeId = 3549, strProductCode = '130', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', intMasterId = 183549
	UNION ALL SELECT intValidProductCodeId = 3554, strProductCode = '125', strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', intMasterId = 183554
	UNION ALL SELECT intValidProductCodeId = 3547, strProductCode = '130', strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', intMasterId = 183547
	UNION ALL SELECT intValidProductCodeId = 3529, strProductCode = '072', strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', intMasterId = 183529
	UNION ALL SELECT intValidProductCodeId = 3535, strProductCode = '228', strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', intMasterId = 183535
	UNION ALL SELECT intValidProductCodeId = 3541, strProductCode = '171', strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', intMasterId = 183541
	UNION ALL SELECT intValidProductCodeId = 3511, strProductCode = '142', strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', intMasterId = 183511
	UNION ALL SELECT intValidProductCodeId = 3517, strProductCode = '160', strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', intMasterId = 183517
	UNION ALL SELECT intValidProductCodeId = 3523, strProductCode = '170', strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', intMasterId = 183523
	UNION ALL SELECT intValidProductCodeId = 3493, strProductCode = '065', strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', intMasterId = 183493
	UNION ALL SELECT intValidProductCodeId = 3499, strProductCode = '123', strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', intMasterId = 183499
	UNION ALL SELECT intValidProductCodeId = 3505, strProductCode = '124', strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', intMasterId = 183505
	UNION ALL SELECT intValidProductCodeId = 3553, strProductCode = '125', strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', intMasterId = 183553
	UNION ALL SELECT intValidProductCodeId = 3546, strProductCode = '130', strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', intMasterId = 183546
	UNION ALL SELECT intValidProductCodeId = 3528, strProductCode = '072', strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', intMasterId = 183528
	UNION ALL SELECT intValidProductCodeId = 3534, strProductCode = '228', strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', intMasterId = 183534
	UNION ALL SELECT intValidProductCodeId = 3540, strProductCode = '171', strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', intMasterId = 183540
	UNION ALL SELECT intValidProductCodeId = 3510, strProductCode = '142', strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', intMasterId = 183510
	UNION ALL SELECT intValidProductCodeId = 3516, strProductCode = '160', strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', intMasterId = 183516
	UNION ALL SELECT intValidProductCodeId = 3522, strProductCode = '170', strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', intMasterId = 183522
	UNION ALL SELECT intValidProductCodeId = 3492, strProductCode = '065', strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', intMasterId = 183492
	UNION ALL SELECT intValidProductCodeId = 3498, strProductCode = '123', strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', intMasterId = 183498
	UNION ALL SELECT intValidProductCodeId = 3504, strProductCode = '124', strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', intMasterId = 183504
	UNION ALL SELECT intValidProductCodeId = 3552, strProductCode = '125', strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', intMasterId = 183552
	UNION ALL SELECT intValidProductCodeId = 3545, strProductCode = '130', strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', intMasterId = 183545
	UNION ALL SELECT intValidProductCodeId = 3527, strProductCode = '072', strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', intMasterId = 183527
	UNION ALL SELECT intValidProductCodeId = 3533, strProductCode = '228', strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', intMasterId = 183533
	UNION ALL SELECT intValidProductCodeId = 3539, strProductCode = '171', strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', intMasterId = 183539
	UNION ALL SELECT intValidProductCodeId = 3509, strProductCode = '142', strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', intMasterId = 183509
	UNION ALL SELECT intValidProductCodeId = 3515, strProductCode = '160', strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', intMasterId = 183515
	UNION ALL SELECT intValidProductCodeId = 3521, strProductCode = '170', strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', intMasterId = 183521
	UNION ALL SELECT intValidProductCodeId = 3491, strProductCode = '065', strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', intMasterId = 183491
	UNION ALL SELECT intValidProductCodeId = 3497, strProductCode = '123', strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', intMasterId = 183497
	UNION ALL SELECT intValidProductCodeId = 3556, strProductCode = '125', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', intMasterId = 183556
	UNION ALL SELECT intValidProductCodeId = 3543, strProductCode = '171', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', intMasterId = 183543
	UNION ALL SELECT intValidProductCodeId = 3537, strProductCode = '228', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', intMasterId = 183537
	UNION ALL SELECT intValidProductCodeId = 3531, strProductCode = '072', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', intMasterId = 183531
	UNION ALL SELECT intValidProductCodeId = 3525, strProductCode = '170', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', intMasterId = 183525
	UNION ALL SELECT intValidProductCodeId = 3519, strProductCode = '160', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', intMasterId = 183519
	UNION ALL SELECT intValidProductCodeId = 3513, strProductCode = '142', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', intMasterId = 183513
	UNION ALL SELECT intValidProductCodeId = 3501, strProductCode = '123', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', intMasterId = 183501
	UNION ALL SELECT intValidProductCodeId = 3495, strProductCode = '065', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', intMasterId = 183495
	UNION ALL SELECT intValidProductCodeId = 3507, strProductCode = '124', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', intMasterId = 183507
	UNION ALL SELECT intValidProductCodeId = 3548, strProductCode = '130', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', intMasterId = 183548
	UNION ALL SELECT intValidProductCodeId = 3555, strProductCode = '125', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', intMasterId = 183555
	UNION ALL SELECT intValidProductCodeId = 3542, strProductCode = '171', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', intMasterId = 183542
	UNION ALL SELECT intValidProductCodeId = 3536, strProductCode = '228', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', intMasterId = 183536
	UNION ALL SELECT intValidProductCodeId = 3530, strProductCode = '072', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', intMasterId = 183530
	UNION ALL SELECT intValidProductCodeId = 3524, strProductCode = '170', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', intMasterId = 183524
	UNION ALL SELECT intValidProductCodeId = 3518, strProductCode = '160', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', intMasterId = 183518
	UNION ALL SELECT intValidProductCodeId = 3512, strProductCode = '142', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', intMasterId = 183512
	UNION ALL SELECT intValidProductCodeId = 3500, strProductCode = '123', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', intMasterId = 183500
	UNION ALL SELECT intValidProductCodeId = 3494, strProductCode = '065', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', intMasterId = 183494
	UNION ALL SELECT intValidProductCodeId = 3506, strProductCode = '124', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', intMasterId = 183506
	UNION ALL SELECT intValidProductCodeId = 3503, strProductCode = '124', strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', intMasterId = 183503
	UNION ALL SELECT intValidProductCodeId = 3551, strProductCode = '125', strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', intMasterId = 183551
	UNION ALL SELECT intValidProductCodeId = 3544, strProductCode = '130', strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', intMasterId = 183544
	UNION ALL SELECT intValidProductCodeId = 3526, strProductCode = '072', strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', intMasterId = 183526
	UNION ALL SELECT intValidProductCodeId = 3532, strProductCode = '228', strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', intMasterId = 183532
	UNION ALL SELECT intValidProductCodeId = 3538, strProductCode = '171', strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', intMasterId = 183538
	UNION ALL SELECT intValidProductCodeId = 3508, strProductCode = '142', strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', intMasterId = 183508
	UNION ALL SELECT intValidProductCodeId = 3514, strProductCode = '160', strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', intMasterId = 183514
	UNION ALL SELECT intValidProductCodeId = 3520, strProductCode = '170', strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', intMasterId = 183520
	UNION ALL SELECT intValidProductCodeId = 3490, strProductCode = '065', strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', intMasterId = 183490
	UNION ALL SELECT intValidProductCodeId = 3496, strProductCode = '123', strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', intMasterId = 183496
	UNION ALL SELECT intValidProductCodeId = 3502, strProductCode = '124', strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', intMasterId = 183502

	INSERT INTO @ValidOriginStates(
		intValidOriginStateId
		, strFormCode
		, strScheduleCode
		, strType
		, strState
		, strStatus
		, intMasterId
	)
	SELECT intValidOriginStateId = 412, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strState = 'LA', strStatus = 'Exclude', intMasterId = 18412
	UNION ALL SELECT intValidOriginStateId = 413, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strState = 'LA', strStatus = 'Exclude', intMasterId = 18413
	UNION ALL SELECT intValidOriginStateId = 414, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strState = 'LA', strStatus = 'Exclude', intMasterId = 18414
	UNION ALL SELECT intValidOriginStateId = 415, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strState = 'LA', strStatus = 'Exclude', intMasterId = 18415
	UNION ALL SELECT intValidOriginStateId = 416, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strState = 'LA', strStatus = 'Exclude', intMasterId = 18416
	UNION ALL SELECT intValidOriginStateId = 417, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strState = 'LA', strStatus = 'Include', intMasterId = 18417
	UNION ALL SELECT intValidOriginStateId = 418, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strState = 'LA', strStatus = 'Include', intMasterId = 18418
	UNION ALL SELECT intValidOriginStateId = 419, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18419
	UNION ALL SELECT intValidOriginStateId = 420, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18420
	UNION ALL SELECT intValidOriginStateId = 421, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strState = 'LA', strStatus = 'Include', intMasterId = 18421
	UNION ALL SELECT intValidOriginStateId = 422, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strState = 'LA', strStatus = 'Include', intMasterId = 18422
	UNION ALL SELECT intValidOriginStateId = 423, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strState = 'LA', strStatus = 'Include', intMasterId = 18423
	UNION ALL SELECT intValidOriginStateId = 424, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18424
	UNION ALL SELECT intValidOriginStateId = 425, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18425
	UNION ALL SELECT intValidOriginStateId = 426, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strState = 'LA', strStatus = 'Include', intMasterId = 18426

	INSERT INTO @ValidDestinationStates(
		intValidDestinationStateId
		, strFormCode
		, strScheduleCode
		, strType
		, strState
		, strStatus
		, intMasterId
	)
	SELECT intValidDestinationStateId = 467, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strState = 'LA', strStatus = 'Include', intMasterId = 18467
	UNION ALL SELECT intValidDestinationStateId = 468, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strState = 'LA', strStatus = 'Include', intMasterId = 18468
	UNION ALL SELECT intValidDestinationStateId = 469, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18469
	UNION ALL SELECT intValidDestinationStateId = 470, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18470
	UNION ALL SELECT intValidDestinationStateId = 471, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strState = 'LA', strStatus = 'Include', intMasterId = 18471
	UNION ALL SELECT intValidDestinationStateId = 472, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strState = 'LA', strStatus = 'Exclude', intMasterId = 18472
	UNION ALL SELECT intValidDestinationStateId = 473, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strState = 'LA', strStatus = 'Exclude', intMasterId = 18473
	UNION ALL SELECT intValidDestinationStateId = 474, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strState = 'LA', strStatus = 'Exclude', intMasterId = 18474
	UNION ALL SELECT intValidDestinationStateId = 475, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strState = 'LA', strStatus = 'Exclude', intMasterId = 18475
	UNION ALL SELECT intValidDestinationStateId = 476, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strState = 'LA', strStatus = 'Exclude', intMasterId = 18476
	UNION ALL SELECT intValidDestinationStateId = 477, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strState = 'LA', strStatus = 'Include', intMasterId = 18477
	UNION ALL SELECT intValidDestinationStateId = 478, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strState = 'LA', strStatus = 'Include', intMasterId = 18478
	UNION ALL SELECT intValidDestinationStateId = 479, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18479
	UNION ALL SELECT intValidDestinationStateId = 480, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18480
	UNION ALL SELECT intValidDestinationStateId = 481, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strState = 'LA', strStatus = 'Include', intMasterId = 18481
	UNION ALL SELECT intValidDestinationStateId = 482, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strState = 'LA', strStatus = 'Include', intMasterId = 18482
	UNION ALL SELECT intValidDestinationStateId = 483, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strState = 'LA', strStatus = 'Include', intMasterId = 18483
	UNION ALL SELECT intValidDestinationStateId = 484, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18484
	UNION ALL SELECT intValidDestinationStateId = 485, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18485
	UNION ALL SELECT intValidDestinationStateId = 486, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strState = 'LA', strStatus = 'Include', intMasterId = 18486
	UNION ALL SELECT intValidDestinationStateId = 487, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strState = 'LA', strStatus = 'Include', intMasterId = 18487
	UNION ALL SELECT intValidDestinationStateId = 488, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strState = 'LA', strStatus = 'Include', intMasterId = 18488
	UNION ALL SELECT intValidDestinationStateId = 489, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18489
	UNION ALL SELECT intValidDestinationStateId = 490, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18490
	UNION ALL SELECT intValidDestinationStateId = 491, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strState = 'LA', strStatus = 'Include', intMasterId = 18491
	UNION ALL SELECT intValidDestinationStateId = 492, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strState = 'LA', strStatus = 'Include', intMasterId = 18492
	UNION ALL SELECT intValidDestinationStateId = 493, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strState = 'LA', strStatus = 'Include', intMasterId = 18493
	UNION ALL SELECT intValidDestinationStateId = 494, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18494
	UNION ALL SELECT intValidDestinationStateId = 495, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18495
	UNION ALL SELECT intValidDestinationStateId = 496, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strState = 'LA', strStatus = 'Include', intMasterId = 18496

	EXEC uspTFUpgradeValidProductCodes @TaxAuthorityCode = @TaxAuthorityCode, @ValidProductCodes = @ValidProductCodes
	EXEC uspTFUpgradeValidOriginStates @TaxAuthorityCode = @TaxAuthorityCode, @ValidOriginStates = @ValidOriginStates
	EXEC uspTFUpgradeValidDestinationStates @TaxAuthorityCode = @TaxAuthorityCode, @ValidDestinationStates = @ValidDestinationStates

-- Reporting Component - Configuration
/* Generate script for Reporting Component - Configurations. Specify Tax Authority Id to filter out specific Reporting Component - Configurations only.
select 'UNION ALL SELECT intReportTemplateId = ' + CAST(intReportingComponentConfigurationId AS NVARCHAR(10))
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
	SELECT intReportTemplateId = 342, strFormCode = 'R-5346', strScheduleCode = '', strType = '', strTemplateItemId = 'R-5346-AcctNum', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '1', strDescription = 'LA Transporter Account Number', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18342
	UNION ALL SELECT intReportTemplateId = 506, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strTemplateItemId = 'GasRpt7Aviation', strReportSection = '', intReportItemSequence = '0', intTemplateItemNumber = '1', strDescription = 'strOriginAltFacilityNumber', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = NULL, ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18506
	UNION ALL SELECT intReportTemplateId = 507, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strTemplateItemId = 'GasRpt7Aviation', strReportSection = '', intReportItemSequence = '0', intTemplateItemNumber = '2', strDescription = 'strDestinationAltFacilityNumber', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = NULL, ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18507
	UNION ALL SELECT intReportTemplateId = 508, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strTemplateItemId = 'GasRpt7Aviation', strReportSection = '', intReportItemSequence = '0', intTemplateItemNumber = '3', strDescription = 'strOriginCountryCode', strScheduleList = NULL, strConfiguration = 'USA', ysnConfiguration = NULL, ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18508
	UNION ALL SELECT intReportTemplateId = 509, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strTemplateItemId = 'GasRpt7Aviation', strReportSection = '', intReportItemSequence = '0', intTemplateItemNumber = '4', strDescription = 'strDestinationCountryCode', strScheduleList = NULL, strConfiguration = 'USA', ysnConfiguration = NULL, ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18509
	UNION ALL SELECT intReportTemplateId = 510, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strTemplateItemId = 'GasRpt7Jet', strReportSection = '', intReportItemSequence = '0', intTemplateItemNumber = '1', strDescription = 'strOriginAltFacilityNumber', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = NULL, ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18510
	UNION ALL SELECT intReportTemplateId = 511, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strTemplateItemId = 'GasRpt7Jet', strReportSection = '', intReportItemSequence = '0', intTemplateItemNumber = '2', strDescription = 'strDestinationAltFacilityNumber', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = NULL, ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18511
	UNION ALL SELECT intReportTemplateId = 512, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strTemplateItemId = 'GasRpt7Jet', strReportSection = '', intReportItemSequence = '0', intTemplateItemNumber = '3', strDescription = 'strOriginCountryCode', strScheduleList = NULL, strConfiguration = 'USA', ysnConfiguration = NULL, ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18512
	UNION ALL SELECT intReportTemplateId = 513, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strTemplateItemId = 'GasRpt7Jet', strReportSection = '', intReportItemSequence = '0', intTemplateItemNumber = '4', strDescription = 'strDestinationCountryCode', strScheduleList = NULL, strConfiguration = 'USA', ysnConfiguration = NULL, ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18513
	UNION ALL SELECT intReportTemplateId = 514, strFormCode = 'R-5399', strScheduleCode = '', strType = '', strTemplateItemId = 'GasRpt7Ethanol', strReportSection = '', intReportItemSequence = '0', intTemplateItemNumber = '1', strDescription = 'strOriginAltFacilityNumber', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = NULL, ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18514
	UNION ALL SELECT intReportTemplateId = 515, strFormCode = 'R-5399', strScheduleCode = '', strType = '', strTemplateItemId = 'GasRpt7Ethanol', strReportSection = '', intReportItemSequence = '0', intTemplateItemNumber = '2', strDescription = 'strDestinationAltFacilityNumber', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = NULL, ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18515
	UNION ALL SELECT intReportTemplateId = 516, strFormCode = 'R-5399', strScheduleCode = '', strType = '', strTemplateItemId = 'GasRpt7Ethanol', strReportSection = '', intReportItemSequence = '0', intTemplateItemNumber = '3', strDescription = 'strOriginCountryCode', strScheduleList = NULL, strConfiguration = 'USA', ysnConfiguration = NULL, ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18516
	UNION ALL SELECT intReportTemplateId = 517, strFormCode = 'R-5399', strScheduleCode = '', strType = '', strTemplateItemId = 'GasRpt7Ethanol', strReportSection = '', intReportItemSequence = '0', intTemplateItemNumber = '4', strDescription = 'strDestinationCountryCode', strScheduleList = NULL, strConfiguration = 'USA', ysnConfiguration = NULL, ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18517
	UNION ALL SELECT intReportTemplateId = 343, strFormCode = 'R-5399', strScheduleCode = '', strType = '', strTemplateItemId = 'R-5399-AcctNumber', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '1', strDescription = 'LA Importer Account Number', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18343
	UNION ALL SELECT intReportTemplateId = 344, strFormCode = 'R-5399', strScheduleCode = '', strType = '', strTemplateItemId = 'R-5399-TaxRateGasohol', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '2', strDescription = 'Tax Rate - Gasohol', strScheduleList = NULL, strConfiguration = '0.20', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18344
	UNION ALL SELECT intReportTemplateId = 345, strFormCode = 'R-5399', strScheduleCode = '', strType = '', strTemplateItemId = 'R-5399-TaxRateGasoline', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '3', strDescription = 'Tax Rate - Gasoline', strScheduleList = NULL, strConfiguration = '0.20', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18345
	UNION ALL SELECT intReportTemplateId = 346, strFormCode = 'R-5399', strScheduleCode = '', strType = '', strTemplateItemId = 'R-5399-TaxRateUndyedDiesel', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '4', strDescription = 'Tax Rate - Undyed Diesel', strScheduleList = NULL, strConfiguration = '0.20', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18346
	UNION ALL SELECT intReportTemplateId = 347, strFormCode = 'R-5399', strScheduleCode = '', strType = '', strTemplateItemId = 'R-5399-InspRateGasohol', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '5', strDescription = 'Inspection Fee Rate - Gasohol', strScheduleList = NULL, strConfiguration = '0.00125', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18347
	UNION ALL SELECT intReportTemplateId = 348, strFormCode = 'R-5399', strScheduleCode = '', strType = '', strTemplateItemId = 'R-5399-InspRateGasoline', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '6', strDescription = 'Inspection Fee Rate - Gasoline', strScheduleList = NULL, strConfiguration = '0.00125', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18348
	UNION ALL SELECT intReportTemplateId = 349, strFormCode = 'R-5399', strScheduleCode = '', strType = '', strTemplateItemId = 'R-5399-InspRateUndyedDiesel', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '7', strDescription = 'Inspection Fee Rate - Undyed Diesel', strScheduleList = NULL, strConfiguration = '0.00125', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18349
	UNION ALL SELECT intReportTemplateId = 350, strFormCode = 'R-5399', strScheduleCode = '', strType = '', strTemplateItemId = 'R-5399-InspRateDyedDiesel', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '8', strDescription = 'Inspection Fee Rate - Dyed Diesel', strScheduleList = NULL, strConfiguration = '0.00125', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18350
	UNION ALL SELECT intReportTemplateId = 351, strFormCode = 'R-5399', strScheduleCode = '', strType = '', strTemplateItemId = 'R-5399-InspRateAviation', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '9', strDescription = 'Inspection Fee Rate - Aviation Fuels', strScheduleList = NULL, strConfiguration = '0.00125', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18351
	UNION ALL SELECT intReportTemplateId = 352, strFormCode = 'R-5399', strScheduleCode = '', strType = '', strTemplateItemId = 'R-5399-Line7', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '10', strDescription = 'Line 7 Penalty', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18352
	UNION ALL SELECT intReportTemplateId = 353, strFormCode = 'R-5399', strScheduleCode = '', strType = '', strTemplateItemId = 'R-5399-Line8', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '11', strDescription = 'Line 8 Interest', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18353
	UNION ALL SELECT intReportTemplateId = 354, strFormCode = 'R-5399', strScheduleCode = '', strType = '', strTemplateItemId = 'R-5399-Line16Gasohol', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '12', strDescription = 'Line 16 Other - Gasohol', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18354
	UNION ALL SELECT intReportTemplateId = 355, strFormCode = 'R-5399', strScheduleCode = '', strType = '', strTemplateItemId = 'R-5399-Line16Gasoline', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '13', strDescription = 'Line 16 Other - Gasoline', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18355
	UNION ALL SELECT intReportTemplateId = 356, strFormCode = 'R-5399', strScheduleCode = '', strType = '', strTemplateItemId = 'R-5399-Line16UndyedDiesel', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '14', strDescription = 'Line 16 Other - Undyed Diesel', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18356
	UNION ALL SELECT intReportTemplateId = 357, strFormCode = 'R-5399', strScheduleCode = '', strType = '', strTemplateItemId = 'R-5399-Line16DyedDiesel', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '15', strDescription = 'Line 16 Other - Dyed Diesel', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18357
	UNION ALL SELECT intReportTemplateId = 358, strFormCode = 'R-5399', strScheduleCode = '', strType = '', strTemplateItemId = 'R-5399-Line16Aviation', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '16', strDescription = 'Line 16 Other - Aviation Fuels', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 18358
	
	EXEC uspTFUpgradeReportingComponentConfigurations @TaxAuthorityCode = @TaxAuthorityCode, @ReportingComponentConfigurations = @ReportingComponentConfigurations

-- Reporting Component - Output Designer
/* Generate script for Reporting Component - Output Designer. Specify Tax Authority Id to filter out specific Reporting Component - Output Designer only.
select 'UNION ALL SELECT intScheduleColumnId = ' + CAST(intReportingComponentFieldId AS NVARCHAR(10))
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
	SELECT intScheduleColumnId = 9692, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189692
	UNION ALL SELECT intScheduleColumnId = 9693, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189693
	UNION ALL SELECT intScheduleColumnId = 9694, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189694
	UNION ALL SELECT intScheduleColumnId = 9695, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189695
	UNION ALL SELECT intScheduleColumnId = 9696, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller ID', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189696
	UNION ALL SELECT intScheduleColumnId = 9697, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189697
	UNION ALL SELECT intScheduleColumnId = 9698, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189698
	UNION ALL SELECT intScheduleColumnId = 9699, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189699
	UNION ALL SELECT intScheduleColumnId = 9700, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189700
	UNION ALL SELECT intScheduleColumnId = 9701, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189701
	UNION ALL SELECT intScheduleColumnId = 9702, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189702
	UNION ALL SELECT intScheduleColumnId = 9703, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189703
	UNION ALL SELECT intScheduleColumnId = 9704, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189704
	UNION ALL SELECT intScheduleColumnId = 9705, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189705
	UNION ALL SELECT intScheduleColumnId = 9706, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189706
	UNION ALL SELECT intScheduleColumnId = 9707, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189707
	UNION ALL SELECT intScheduleColumnId = 9708, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189708
	UNION ALL SELECT intScheduleColumnId = 9709, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller ID', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189709
	UNION ALL SELECT intScheduleColumnId = 9710, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189710
	UNION ALL SELECT intScheduleColumnId = 9711, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189711
	UNION ALL SELECT intScheduleColumnId = 9712, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189712
	UNION ALL SELECT intScheduleColumnId = 9713, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189713
	UNION ALL SELECT intScheduleColumnId = 9714, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189714
	UNION ALL SELECT intScheduleColumnId = 9715, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189715
	UNION ALL SELECT intScheduleColumnId = 9716, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189716
	UNION ALL SELECT intScheduleColumnId = 9717, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189717
	UNION ALL SELECT intScheduleColumnId = 9718, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189718
	UNION ALL SELECT intScheduleColumnId = 9719, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189719
	UNION ALL SELECT intScheduleColumnId = 9720, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189720
	UNION ALL SELECT intScheduleColumnId = 9721, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189721
	UNION ALL SELECT intScheduleColumnId = 9722, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller ID', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189722
	UNION ALL SELECT intScheduleColumnId = 9723, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189723
	UNION ALL SELECT intScheduleColumnId = 9724, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189724
	UNION ALL SELECT intScheduleColumnId = 9725, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189725
	UNION ALL SELECT intScheduleColumnId = 9726, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189726
	UNION ALL SELECT intScheduleColumnId = 9727, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189727
	UNION ALL SELECT intScheduleColumnId = 9728, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189728
	UNION ALL SELECT intScheduleColumnId = 9729, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189729
	UNION ALL SELECT intScheduleColumnId = 9730, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189730
	UNION ALL SELECT intScheduleColumnId = 9731, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189731
	UNION ALL SELECT intScheduleColumnId = 9732, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189732
	UNION ALL SELECT intScheduleColumnId = 9733, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189733
	UNION ALL SELECT intScheduleColumnId = 9734, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189734
	UNION ALL SELECT intScheduleColumnId = 9735, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller ID', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189735
	UNION ALL SELECT intScheduleColumnId = 9736, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189736
	UNION ALL SELECT intScheduleColumnId = 9737, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189737
	UNION ALL SELECT intScheduleColumnId = 9738, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189738
	UNION ALL SELECT intScheduleColumnId = 9739, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189739
	UNION ALL SELECT intScheduleColumnId = 9740, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189740
	UNION ALL SELECT intScheduleColumnId = 9741, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189741
	UNION ALL SELECT intScheduleColumnId = 9742, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189742
	UNION ALL SELECT intScheduleColumnId = 9743, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189743
	UNION ALL SELECT intScheduleColumnId = 9744, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189744
	UNION ALL SELECT intScheduleColumnId = 9745, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189745
	UNION ALL SELECT intScheduleColumnId = 9746, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189746
	UNION ALL SELECT intScheduleColumnId = 9747, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189747
	UNION ALL SELECT intScheduleColumnId = 9748, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller ID', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189748
	UNION ALL SELECT intScheduleColumnId = 9749, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189749
	UNION ALL SELECT intScheduleColumnId = 9750, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189750
	UNION ALL SELECT intScheduleColumnId = 9751, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189751
	UNION ALL SELECT intScheduleColumnId = 9752, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189752
	UNION ALL SELECT intScheduleColumnId = 9753, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189753
	UNION ALL SELECT intScheduleColumnId = 9754, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189754
	UNION ALL SELECT intScheduleColumnId = 9755, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189755
	UNION ALL SELECT intScheduleColumnId = 9756, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189756
	UNION ALL SELECT intScheduleColumnId = 9757, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189757
	UNION ALL SELECT intScheduleColumnId = 9758, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189758
	UNION ALL SELECT intScheduleColumnId = 9759, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189759
	UNION ALL SELECT intScheduleColumnId = 9760, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189760
	UNION ALL SELECT intScheduleColumnId = 9761, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller ID', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189761
	UNION ALL SELECT intScheduleColumnId = 9762, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189762
	UNION ALL SELECT intScheduleColumnId = 9763, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189763
	UNION ALL SELECT intScheduleColumnId = 9764, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189764
	UNION ALL SELECT intScheduleColumnId = 9765, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189765
	UNION ALL SELECT intScheduleColumnId = 9766, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189766
	UNION ALL SELECT intScheduleColumnId = 9767, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189767
	UNION ALL SELECT intScheduleColumnId = 9768, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189768
	UNION ALL SELECT intScheduleColumnId = 9769, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189769
	UNION ALL SELECT intScheduleColumnId = 9770, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189770
	UNION ALL SELECT intScheduleColumnId = 9771, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189771
	UNION ALL SELECT intScheduleColumnId = 9772, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189772
	UNION ALL SELECT intScheduleColumnId = 9773, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189773
	UNION ALL SELECT intScheduleColumnId = 9774, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller ID', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189774
	UNION ALL SELECT intScheduleColumnId = 9775, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189775
	UNION ALL SELECT intScheduleColumnId = 9776, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189776
	UNION ALL SELECT intScheduleColumnId = 9777, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189777
	UNION ALL SELECT intScheduleColumnId = 9778, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189778
	UNION ALL SELECT intScheduleColumnId = 9779, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189779
	UNION ALL SELECT intScheduleColumnId = 9780, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189780
	UNION ALL SELECT intScheduleColumnId = 9781, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189781
	UNION ALL SELECT intScheduleColumnId = 9782, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189782
	UNION ALL SELECT intScheduleColumnId = 9783, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189783
	UNION ALL SELECT intScheduleColumnId = 9784, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189784
	UNION ALL SELECT intScheduleColumnId = 9785, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189785
	UNION ALL SELECT intScheduleColumnId = 9786, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189786
	UNION ALL SELECT intScheduleColumnId = 9787, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller ID', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189787
	UNION ALL SELECT intScheduleColumnId = 9788, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189788
	UNION ALL SELECT intScheduleColumnId = 9789, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189789
	UNION ALL SELECT intScheduleColumnId = 9790, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189790
	UNION ALL SELECT intScheduleColumnId = 9791, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189791
	UNION ALL SELECT intScheduleColumnId = 9792, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189792
	UNION ALL SELECT intScheduleColumnId = 9793, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189793
	UNION ALL SELECT intScheduleColumnId = 9794, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189794
	UNION ALL SELECT intScheduleColumnId = 9795, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189795
	UNION ALL SELECT intScheduleColumnId = 9796, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189796
	UNION ALL SELECT intScheduleColumnId = 9797, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189797
	UNION ALL SELECT intScheduleColumnId = 9798, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189798
	UNION ALL SELECT intScheduleColumnId = 9799, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189799
	UNION ALL SELECT intScheduleColumnId = 9800, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller ID', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189800
	UNION ALL SELECT intScheduleColumnId = 9801, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189801
	UNION ALL SELECT intScheduleColumnId = 9802, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189802
	UNION ALL SELECT intScheduleColumnId = 9803, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189803
	UNION ALL SELECT intScheduleColumnId = 9804, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189804
	UNION ALL SELECT intScheduleColumnId = 9805, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189805
	UNION ALL SELECT intScheduleColumnId = 9806, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189806
	UNION ALL SELECT intScheduleColumnId = 9807, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189807
	UNION ALL SELECT intScheduleColumnId = 9808, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189808
	UNION ALL SELECT intScheduleColumnId = 9809, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189809
	UNION ALL SELECT intScheduleColumnId = 9810, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189810
	UNION ALL SELECT intScheduleColumnId = 9811, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189811
	UNION ALL SELECT intScheduleColumnId = 9812, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189812
	UNION ALL SELECT intScheduleColumnId = 9813, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller ID', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189813
	UNION ALL SELECT intScheduleColumnId = 9814, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189814
	UNION ALL SELECT intScheduleColumnId = 9815, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189815
	UNION ALL SELECT intScheduleColumnId = 9816, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189816
	UNION ALL SELECT intScheduleColumnId = 9817, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189817
	UNION ALL SELECT intScheduleColumnId = 9818, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189818
	UNION ALL SELECT intScheduleColumnId = 9819, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189819
	UNION ALL SELECT intScheduleColumnId = 9820, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189820
	UNION ALL SELECT intScheduleColumnId = 9821, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189821
	UNION ALL SELECT intScheduleColumnId = 9947, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189947
	UNION ALL SELECT intScheduleColumnId = 9948, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189948
	UNION ALL SELECT intScheduleColumnId = 9949, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189949
	UNION ALL SELECT intScheduleColumnId = 9950, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189950
	UNION ALL SELECT intScheduleColumnId = 9951, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189951
	UNION ALL SELECT intScheduleColumnId = 9952, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189952
	UNION ALL SELECT intScheduleColumnId = 9953, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189953
	UNION ALL SELECT intScheduleColumnId = 9954, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189954
	UNION ALL SELECT intScheduleColumnId = 9955, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189955
	UNION ALL SELECT intScheduleColumnId = 9956, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189956
	UNION ALL SELECT intScheduleColumnId = 9957, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189957
	UNION ALL SELECT intScheduleColumnId = 9958, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189958
	UNION ALL SELECT intScheduleColumnId = 9959, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189959
	UNION ALL SELECT intScheduleColumnId = 9960, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189960
	UNION ALL SELECT intScheduleColumnId = 9961, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189961
	UNION ALL SELECT intScheduleColumnId = 9962, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189962
	UNION ALL SELECT intScheduleColumnId = 9963, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189963
	UNION ALL SELECT intScheduleColumnId = 9964, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189964
	UNION ALL SELECT intScheduleColumnId = 9965, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189965
	UNION ALL SELECT intScheduleColumnId = 9966, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189966
	UNION ALL SELECT intScheduleColumnId = 9967, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189967
	UNION ALL SELECT intScheduleColumnId = 9968, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189968
	UNION ALL SELECT intScheduleColumnId = 9969, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189969
	UNION ALL SELECT intScheduleColumnId = 9970, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189970
	UNION ALL SELECT intScheduleColumnId = 9971, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189971
	UNION ALL SELECT intScheduleColumnId = 9972, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189972
	UNION ALL SELECT intScheduleColumnId = 9973, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189973
	UNION ALL SELECT intScheduleColumnId = 9974, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189974
	UNION ALL SELECT intScheduleColumnId = 9975, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189975
	UNION ALL SELECT intScheduleColumnId = 9976, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189976
	UNION ALL SELECT intScheduleColumnId = 9977, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189977
	UNION ALL SELECT intScheduleColumnId = 9978, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189978
	UNION ALL SELECT intScheduleColumnId = 9979, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189979
	UNION ALL SELECT intScheduleColumnId = 9980, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189980
	UNION ALL SELECT intScheduleColumnId = 9981, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189981
	UNION ALL SELECT intScheduleColumnId = 9982, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189982
	UNION ALL SELECT intScheduleColumnId = 9983, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189983
	UNION ALL SELECT intScheduleColumnId = 9984, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189984
	UNION ALL SELECT intScheduleColumnId = 9985, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189985
	UNION ALL SELECT intScheduleColumnId = 9986, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189986
	UNION ALL SELECT intScheduleColumnId = 9987, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189987
	UNION ALL SELECT intScheduleColumnId = 9988, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189988
	UNION ALL SELECT intScheduleColumnId = 9989, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189989
	UNION ALL SELECT intScheduleColumnId = 9990, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189990
	UNION ALL SELECT intScheduleColumnId = 9991, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189991
	UNION ALL SELECT intScheduleColumnId = 9992, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189992
	UNION ALL SELECT intScheduleColumnId = 9993, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189993
	UNION ALL SELECT intScheduleColumnId = 9994, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189994
	UNION ALL SELECT intScheduleColumnId = 9995, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189995
	UNION ALL SELECT intScheduleColumnId = 9996, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189996
	UNION ALL SELECT intScheduleColumnId = 9997, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189997
	UNION ALL SELECT intScheduleColumnId = 9998, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189998
	UNION ALL SELECT intScheduleColumnId = 9999, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 189999
	UNION ALL SELECT intScheduleColumnId = 10000, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810000
	UNION ALL SELECT intScheduleColumnId = 10001, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810001
	UNION ALL SELECT intScheduleColumnId = 10002, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810002
	UNION ALL SELECT intScheduleColumnId = 10003, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810003
	UNION ALL SELECT intScheduleColumnId = 10004, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810004
	UNION ALL SELECT intScheduleColumnId = 10005, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810005
	UNION ALL SELECT intScheduleColumnId = 10006, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810006
	UNION ALL SELECT intScheduleColumnId = 10007, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810007
	UNION ALL SELECT intScheduleColumnId = 10008, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810008
	UNION ALL SELECT intScheduleColumnId = 10009, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810009
	UNION ALL SELECT intScheduleColumnId = 10010, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810010
	UNION ALL SELECT intScheduleColumnId = 10011, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810011
	UNION ALL SELECT intScheduleColumnId = 10012, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810012
	UNION ALL SELECT intScheduleColumnId = 10013, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810013
	UNION ALL SELECT intScheduleColumnId = 10014, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810014
	UNION ALL SELECT intScheduleColumnId = 10015, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810015
	UNION ALL SELECT intScheduleColumnId = 10016, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810016
	UNION ALL SELECT intScheduleColumnId = 10017, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810017
	UNION ALL SELECT intScheduleColumnId = 10018, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810018
	UNION ALL SELECT intScheduleColumnId = 10019, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810019
	UNION ALL SELECT intScheduleColumnId = 10020, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810020
	UNION ALL SELECT intScheduleColumnId = 10021, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810021
	UNION ALL SELECT intScheduleColumnId = 10022, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810022
	UNION ALL SELECT intScheduleColumnId = 10023, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810023
	UNION ALL SELECT intScheduleColumnId = 10024, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810024
	UNION ALL SELECT intScheduleColumnId = 10025, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810025
	UNION ALL SELECT intScheduleColumnId = 10026, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810026
	UNION ALL SELECT intScheduleColumnId = 10027, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810027
	UNION ALL SELECT intScheduleColumnId = 10028, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810028
	UNION ALL SELECT intScheduleColumnId = 10029, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810029
	UNION ALL SELECT intScheduleColumnId = 10030, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810030
	UNION ALL SELECT intScheduleColumnId = 10031, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810031
	UNION ALL SELECT intScheduleColumnId = 10032, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810032
	UNION ALL SELECT intScheduleColumnId = 10033, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810033
	UNION ALL SELECT intScheduleColumnId = 10034, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810034
	UNION ALL SELECT intScheduleColumnId = 10035, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810035
	UNION ALL SELECT intScheduleColumnId = 10036, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810036
	UNION ALL SELECT intScheduleColumnId = 10037, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810037
	UNION ALL SELECT intScheduleColumnId = 10038, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810038
	UNION ALL SELECT intScheduleColumnId = 10039, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810039
	UNION ALL SELECT intScheduleColumnId = 10040, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810040
	UNION ALL SELECT intScheduleColumnId = 10041, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810041
	UNION ALL SELECT intScheduleColumnId = 10042, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810042
	UNION ALL SELECT intScheduleColumnId = 10043, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810043
	UNION ALL SELECT intScheduleColumnId = 10044, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810044
	UNION ALL SELECT intScheduleColumnId = 10045, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810045
	UNION ALL SELECT intScheduleColumnId = 10046, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810046
	UNION ALL SELECT intScheduleColumnId = 10047, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810047
	UNION ALL SELECT intScheduleColumnId = 10048, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810048
	UNION ALL SELECT intScheduleColumnId = 10049, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810049
	UNION ALL SELECT intScheduleColumnId = 10050, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810050
	UNION ALL SELECT intScheduleColumnId = 10051, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810051
	UNION ALL SELECT intScheduleColumnId = 10052, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810052
	UNION ALL SELECT intScheduleColumnId = 10053, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810053
	UNION ALL SELECT intScheduleColumnId = 10054, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810054
	UNION ALL SELECT intScheduleColumnId = 10055, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810055
	UNION ALL SELECT intScheduleColumnId = 10056, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810056
	UNION ALL SELECT intScheduleColumnId = 10057, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810057
	UNION ALL SELECT intScheduleColumnId = 10058, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810058
	UNION ALL SELECT intScheduleColumnId = 10059, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810059
	UNION ALL SELECT intScheduleColumnId = 10060, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810060
	UNION ALL SELECT intScheduleColumnId = 10061, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810061
	UNION ALL SELECT intScheduleColumnId = 10062, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810062
	UNION ALL SELECT intScheduleColumnId = 10063, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810063
	UNION ALL SELECT intScheduleColumnId = 10064, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810064
	UNION ALL SELECT intScheduleColumnId = 10065, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810065
	UNION ALL SELECT intScheduleColumnId = 10066, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810066
	UNION ALL SELECT intScheduleColumnId = 10067, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810067
	UNION ALL SELECT intScheduleColumnId = 10068, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810068
	UNION ALL SELECT intScheduleColumnId = 10069, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810069
	UNION ALL SELECT intScheduleColumnId = 10070, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810070
	UNION ALL SELECT intScheduleColumnId = 10071, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810071
	UNION ALL SELECT intScheduleColumnId = 10072, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810072
	UNION ALL SELECT intScheduleColumnId = 10073, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810073
	UNION ALL SELECT intScheduleColumnId = 10074, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810074
	UNION ALL SELECT intScheduleColumnId = 10075, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810075
	UNION ALL SELECT intScheduleColumnId = 10076, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810076
	UNION ALL SELECT intScheduleColumnId = 10077, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810077
	UNION ALL SELECT intScheduleColumnId = 10078, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810078
	UNION ALL SELECT intScheduleColumnId = 10079, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810079
	UNION ALL SELECT intScheduleColumnId = 10080, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810080
	UNION ALL SELECT intScheduleColumnId = 10081, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810081
	UNION ALL SELECT intScheduleColumnId = 10082, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810082
	UNION ALL SELECT intScheduleColumnId = 10083, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810083
	UNION ALL SELECT intScheduleColumnId = 10084, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810084
	UNION ALL SELECT intScheduleColumnId = 10085, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810085
	UNION ALL SELECT intScheduleColumnId = 10086, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810086
	UNION ALL SELECT intScheduleColumnId = 10087, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810087
	UNION ALL SELECT intScheduleColumnId = 10088, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810088
	UNION ALL SELECT intScheduleColumnId = 10089, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810089
	UNION ALL SELECT intScheduleColumnId = 10090, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810090
	UNION ALL SELECT intScheduleColumnId = 10091, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810091
	UNION ALL SELECT intScheduleColumnId = 10092, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810092
	UNION ALL SELECT intScheduleColumnId = 10093, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810093
	UNION ALL SELECT intScheduleColumnId = 10094, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810094
	UNION ALL SELECT intScheduleColumnId = 10095, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810095
	UNION ALL SELECT intScheduleColumnId = 10096, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810096
	UNION ALL SELECT intScheduleColumnId = 10097, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810097
	UNION ALL SELECT intScheduleColumnId = 10098, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810098
	UNION ALL SELECT intScheduleColumnId = 10099, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810099
	UNION ALL SELECT intScheduleColumnId = 10100, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810100
	UNION ALL SELECT intScheduleColumnId = 10101, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810101
	UNION ALL SELECT intScheduleColumnId = 10102, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810102
	UNION ALL SELECT intScheduleColumnId = 10103, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810103
	UNION ALL SELECT intScheduleColumnId = 10104, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810104
	UNION ALL SELECT intScheduleColumnId = 10105, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810105
	UNION ALL SELECT intScheduleColumnId = 10106, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810106
	UNION ALL SELECT intScheduleColumnId = 10107, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810107
	UNION ALL SELECT intScheduleColumnId = 10108, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810108
	UNION ALL SELECT intScheduleColumnId = 10109, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810109
	UNION ALL SELECT intScheduleColumnId = 10110, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810110
	UNION ALL SELECT intScheduleColumnId = 10111, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810111
	UNION ALL SELECT intScheduleColumnId = 10112, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810112
	UNION ALL SELECT intScheduleColumnId = 10113, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810113
	UNION ALL SELECT intScheduleColumnId = 10114, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810114
	UNION ALL SELECT intScheduleColumnId = 10115, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810115
	UNION ALL SELECT intScheduleColumnId = 10116, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810116
	UNION ALL SELECT intScheduleColumnId = 10117, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810117
	UNION ALL SELECT intScheduleColumnId = 10118, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810118
	UNION ALL SELECT intScheduleColumnId = 10119, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810119
	UNION ALL SELECT intScheduleColumnId = 10120, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810120
	UNION ALL SELECT intScheduleColumnId = 10121, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810121
	UNION ALL SELECT intScheduleColumnId = 10122, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810122
	UNION ALL SELECT intScheduleColumnId = 10123, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810123
	UNION ALL SELECT intScheduleColumnId = 10124, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810124
	UNION ALL SELECT intScheduleColumnId = 10125, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810125
	UNION ALL SELECT intScheduleColumnId = 10126, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810126
	UNION ALL SELECT intScheduleColumnId = 10127, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810127
	UNION ALL SELECT intScheduleColumnId = 10128, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810128
	UNION ALL SELECT intScheduleColumnId = 10129, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810129
	UNION ALL SELECT intScheduleColumnId = 10130, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810130
	UNION ALL SELECT intScheduleColumnId = 10131, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810131
	UNION ALL SELECT intScheduleColumnId = 10132, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810132
	UNION ALL SELECT intScheduleColumnId = 10133, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'strDiversionOriginalDestinationState', strCaption = 'Manifest Destination', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810133
	UNION ALL SELECT intScheduleColumnId = 10134, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'strDestinationState', strCaption = 'Actual Destination', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810134
	UNION ALL SELECT intScheduleColumnId = 10135, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810135
	UNION ALL SELECT intScheduleColumnId = 10136, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810136
	UNION ALL SELECT intScheduleColumnId = 10137, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810137
	UNION ALL SELECT intScheduleColumnId = 10138, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810138
	UNION ALL SELECT intScheduleColumnId = 10139, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810139
	UNION ALL SELECT intScheduleColumnId = 10140, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'strDiversionNumber', strCaption = 'Diversion Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810140
	UNION ALL SELECT intScheduleColumnId = 10141, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810141
	UNION ALL SELECT intScheduleColumnId = 10142, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810142
	UNION ALL SELECT intScheduleColumnId = 10143, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810143
	UNION ALL SELECT intScheduleColumnId = 10144, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810144
	UNION ALL SELECT intScheduleColumnId = 10145, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810145
	UNION ALL SELECT intScheduleColumnId = 10146, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810146
	UNION ALL SELECT intScheduleColumnId = 10147, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'strDiversionOriginalDestinationState', strCaption = 'Manifest Destination', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810147
	UNION ALL SELECT intScheduleColumnId = 10148, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Actual Destination', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810148
	UNION ALL SELECT intScheduleColumnId = 10149, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'strTerminalControlNumber', strCaption = 'TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810149
	UNION ALL SELECT intScheduleColumnId = 10150, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810150
	UNION ALL SELECT intScheduleColumnId = 10151, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810151
	UNION ALL SELECT intScheduleColumnId = 10152, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810152
	UNION ALL SELECT intScheduleColumnId = 10153, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810153
	UNION ALL SELECT intScheduleColumnId = 10154, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'strDiversionNumber', strCaption = 'Diversion Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810154
	UNION ALL SELECT intScheduleColumnId = 10155, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810155
	UNION ALL SELECT intScheduleColumnId = 10156, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810156
	UNION ALL SELECT intScheduleColumnId = 10157, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810157
	UNION ALL SELECT intScheduleColumnId = 10158, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810158
	UNION ALL SELECT intScheduleColumnId = 10159, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810159
	UNION ALL SELECT intScheduleColumnId = 10160, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810160
	UNION ALL SELECT intScheduleColumnId = 10161, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'strDiversionOriginalDestinationState', strCaption = 'Manifest Destination', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810161
	UNION ALL SELECT intScheduleColumnId = 10162, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'strDestinationState', strCaption = 'Actual Destination', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810162
	UNION ALL SELECT intScheduleColumnId = 10163, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'strTerminalControlNumber', strCaption = 'TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810163
	UNION ALL SELECT intScheduleColumnId = 10164, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810164
	UNION ALL SELECT intScheduleColumnId = 10165, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810165
	UNION ALL SELECT intScheduleColumnId = 10166, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810166
	UNION ALL SELECT intScheduleColumnId = 10167, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810167
	UNION ALL SELECT intScheduleColumnId = 10168, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'strDiversionNumber', strCaption = 'Diversion Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810168
	UNION ALL SELECT intScheduleColumnId = 10169, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810169
	UNION ALL SELECT intScheduleColumnId = 10170, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810170
	UNION ALL SELECT intScheduleColumnId = 10171, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810171
	UNION ALL SELECT intScheduleColumnId = 10172, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810172
	UNION ALL SELECT intScheduleColumnId = 10173, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810173
	UNION ALL SELECT intScheduleColumnId = 10174, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810174
	UNION ALL SELECT intScheduleColumnId = 10175, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'strDiversionOriginalDestinationState', strCaption = 'Manifest Destination', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810175
	UNION ALL SELECT intScheduleColumnId = 10176, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'strDestinationState', strCaption = 'Actual Destination', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810176
	UNION ALL SELECT intScheduleColumnId = 10177, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'strTerminalControlNumber', strCaption = 'TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810177
	UNION ALL SELECT intScheduleColumnId = 10178, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810178
	UNION ALL SELECT intScheduleColumnId = 10179, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810179
	UNION ALL SELECT intScheduleColumnId = 10180, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810180
	UNION ALL SELECT intScheduleColumnId = 10181, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810181
	UNION ALL SELECT intScheduleColumnId = 10182, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'strDiversionNumber', strCaption = 'Diversion Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810182
	UNION ALL SELECT intScheduleColumnId = 10183, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810183
	UNION ALL SELECT intScheduleColumnId = 10184, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810184
	UNION ALL SELECT intScheduleColumnId = 10185, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'dbmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810185
	UNION ALL SELECT intScheduleColumnId = 10186, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810186
	UNION ALL SELECT intScheduleColumnId = 10187, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810187
	UNION ALL SELECT intScheduleColumnId = 10188, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810188
	UNION ALL SELECT intScheduleColumnId = 10189, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'strDiversionOriginalDestinationState', strCaption = 'Manifest Destination', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810189
	UNION ALL SELECT intScheduleColumnId = 10190, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'strDestinationState', strCaption = 'Actual Destination', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810190
	UNION ALL SELECT intScheduleColumnId = 10191, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'TCN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810191
	UNION ALL SELECT intScheduleColumnId = 10192, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810192
	UNION ALL SELECT intScheduleColumnId = 10193, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810193
	UNION ALL SELECT intScheduleColumnId = 10194, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810194
	UNION ALL SELECT intScheduleColumnId = 10195, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810195
	UNION ALL SELECT intScheduleColumnId = 10196, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'strDiversionNumber', strCaption = 'Diversion Number', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 1810196	

	EXEC uspTFUpgradeReportingComponentOutputDesigners @TaxAuthorityCode = @TaxAuthorityCode, @ReportingComponentOutputDesigners = @ReportingComponentOutputDesigners

-- Filing Packet
/* Generate script for Filing Packets. Specify Tax Authority Id to filter out specific Filing Packets only.
select 'UNION ALL SELECT intFilingPacketId = ' + CAST(intFilingPacketId AS NVARCHAR(10))
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
	SELECT intFilingPacketId = 2872, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', ysnStatus = 1, intFrequency = 1, intMasterId = 182872
	UNION ALL SELECT intFilingPacketId = 2873, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 182873
	UNION ALL SELECT intFilingPacketId = 2874, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 182874
	UNION ALL SELECT intFilingPacketId = 2875, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 182875
	UNION ALL SELECT intFilingPacketId = 2876, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 182876
	UNION ALL SELECT intFilingPacketId = 2877, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', ysnStatus = 1, intFrequency = 1, intMasterId = 182877
	UNION ALL SELECT intFilingPacketId = 2878, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 182878
	UNION ALL SELECT intFilingPacketId = 2879, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 182879
	UNION ALL SELECT intFilingPacketId = 2880, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 182880
	UNION ALL SELECT intFilingPacketId = 2881, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 182881
	UNION ALL SELECT intFilingPacketId = 2882, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', ysnStatus = 1, intFrequency = 1, intMasterId = 182882
	UNION ALL SELECT intFilingPacketId = 2883, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 182883
	UNION ALL SELECT intFilingPacketId = 2884, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 182884
	UNION ALL SELECT intFilingPacketId = 2885, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 182885
	UNION ALL SELECT intFilingPacketId = 2886, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 182886
	UNION ALL SELECT intFilingPacketId = 2887, strFormCode = 'R-5346', strScheduleCode = '', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 182887
	UNION ALL SELECT intFilingPacketId = 2888, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', ysnStatus = 1, intFrequency = 1, intMasterId = 182888
	UNION ALL SELECT intFilingPacketId = 2889, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 182889
	UNION ALL SELECT intFilingPacketId = 2890, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 182890
	UNION ALL SELECT intFilingPacketId = 2891, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 182891
	UNION ALL SELECT intFilingPacketId = 2892, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 182892
	UNION ALL SELECT intFilingPacketId = 2893, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', ysnStatus = 1, intFrequency = 1, intMasterId = 182893
	UNION ALL SELECT intFilingPacketId = 2894, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 182894
	UNION ALL SELECT intFilingPacketId = 2895, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 182895
	UNION ALL SELECT intFilingPacketId = 2896, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 182896
	UNION ALL SELECT intFilingPacketId = 2897, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 182897
	UNION ALL SELECT intFilingPacketId = 2898, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', ysnStatus = 1, intFrequency = 1, intMasterId = 182898
	UNION ALL SELECT intFilingPacketId = 2899, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 182899
	UNION ALL SELECT intFilingPacketId = 2900, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 182900
	UNION ALL SELECT intFilingPacketId = 2901, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 182901
	UNION ALL SELECT intFilingPacketId = 2902, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 182902
	UNION ALL SELECT intFilingPacketId = 2903, strFormCode = 'R-5399', strScheduleCode = '', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 182903

	EXEC uspTFUpgradeFilingPackets @TaxAuthorityCode = @TaxAuthorityCode, @FilingPackets = @FilingPackets

END

GO