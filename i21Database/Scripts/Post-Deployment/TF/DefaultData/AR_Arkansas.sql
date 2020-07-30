DECLARE @TaxAuthorityCode NVARCHAR(10) = 'AR'
	, @TaxAuthorityId INT

SELECT @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = @TaxAuthorityCode AND ysnFilingForThisTA = 1

IF(@TaxAuthorityId IS NOT NULL)
BEGIN

	PRINT ('Deploying Arkansas Tax Forms')

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
	SELECT intProductCodeId = 0, strProductCode = '65', strDescription = 'Gasoline', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 41054
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '124', strDescription = 'Gasohol', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 41055
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '125', strDescription = 'Aviation Gas', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 41056
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '130', strDescription = 'Jet Fuel', strProductCodeGroup = 'Diesel', strNote = NULL, intMasterId = 41057
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '142', strDescription = 'Kerosene', strProductCodeGroup = 'Diesel', strNote = NULL, intMasterId = 41058
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '160', strDescription = 'Diesel - Undyed', strProductCodeGroup = 'Diesel', strNote = NULL, intMasterId = 41059
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '228', strDescription = 'Diesel - Dyed', strProductCodeGroup = 'Diesel', strNote = NULL, intMasterId = 41060
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '54', strDescription = 'Propane', strProductCodeGroup = 'LP', strNote = NULL, intMasterId = 41061

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
	SELECT intReportingComponentId = 0, strFormCode = 'AR R', strFormName = 'AR Receipt Schedules', strScheduleCode = '1', strScheduleName = 'Gallons Received, AR Tax Paid', strType = 'Gasoline', strNote = '', strTransactionType = 'Inventory', intSort = 10, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 42096, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR R', strFormName = 'AR Receipt Schedules', strScheduleCode = '1', strScheduleName = 'Gallons Received, AR Tax Paid', strType = 'Diesel Dyed', strNote = '', strTransactionType = 'Inventory', intSort = 20, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 42097, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR R', strFormName = 'AR Receipt Schedules', strScheduleCode = '1', strScheduleName = 'Gallons Received, AR Tax Paid', strType = 'Diesel Undyed', strNote = '', strTransactionType = 'Inventory', intSort = 30, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 42098, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR R', strFormName = 'AR Receipt Schedules', strScheduleCode = '1', strScheduleName = 'Gallons Received, AR Tax Paid', strType = 'LP', strNote = '', strTransactionType = 'Inventory', intSort = 40, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 42099, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR R', strFormName = 'AR Receipt Schedules', strScheduleCode = '2', strScheduleName = 'Gallons Received, AR Tax Unpaid', strType = 'Gasoline', strNote = '', strTransactionType = 'Inventory', intSort = 50, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 42100, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR R', strFormName = 'AR Receipt Schedules', strScheduleCode = '2', strScheduleName = 'Gallons Received, AR Tax Unpaid', strType = 'Diesel Dyed', strNote = '', strTransactionType = 'Inventory', intSort = 60, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 42101, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR R', strFormName = 'AR Receipt Schedules', strScheduleCode = '2', strScheduleName = 'Gallons Received, AR Tax Unpaid', strType = 'Diesel Undyed', strNote = '', strTransactionType = 'Inventory', intSort = 70, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 42102, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR R', strFormName = 'AR Receipt Schedules', strScheduleCode = '2', strScheduleName = 'Gallons Received, AR Tax Unpaid', strType = 'LP', strNote = '', strTransactionType = 'Inventory', intSort = 80, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 42103, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR R', strFormName = 'AR Receipt Schedules', strScheduleCode = '3', strScheduleName = 'Gallons Imported', strType = 'Gasoline', strNote = '', strTransactionType = 'Inventory', intSort = 90, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 42104, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR R', strFormName = 'AR Receipt Schedules', strScheduleCode = '3', strScheduleName = 'Gallons Imported', strType = 'Diesel Dyed', strNote = '', strTransactionType = 'Inventory', intSort = 100, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 42105, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR R', strFormName = 'AR Receipt Schedules', strScheduleCode = '3', strScheduleName = 'Gallons Imported', strType = 'Diesel Undyed', strNote = '', strTransactionType = 'Inventory', intSort = 110, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 42106, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR R', strFormName = 'AR Receipt Schedules', strScheduleCode = '3', strScheduleName = 'Gallons Imported', strType = 'LP', strNote = '', strTransactionType = 'Inventory', intSort = 120, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 42107, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '5J', strScheduleName = 'Gallons Sold at OK Rate', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 200, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42108, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '5J', strScheduleName = 'Gallons Sold at OK Rate', strType = 'Diesel Dyed', strNote = '', strTransactionType = 'Invoice', intSort = 210, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42109, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '5J', strScheduleName = 'Gallons Sold at OK Rate', strType = 'Diesel Undyed', strNote = '', strTransactionType = 'Invoice', intSort = 220, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42110, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '5J', strScheduleName = 'Gallons Sold at OK Rate', strType = 'LP', strNote = '', strTransactionType = 'Invoice', intSort = 230, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42111, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '6', strScheduleName = 'Gallons Delivered to Licensed Distributors, AR Tax Uncollected', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 240, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42112, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '6', strScheduleName = 'Gallons Delivered to Licensed Distributors, AR Tax Uncollected', strType = 'Diesel Dyed', strNote = '', strTransactionType = 'Invoice', intSort = 250, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42113, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '6', strScheduleName = 'Gallons Delivered to Licensed Distributors, AR Tax Uncollected', strType = 'Diesel Undyed', strNote = '', strTransactionType = 'Invoice', intSort = 260, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42114, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '6', strScheduleName = 'Gallons Delivered to Licensed Distributors, AR Tax Uncollected', strType = 'LP', strNote = '', strTransactionType = 'Invoice', intSort = 270, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42115, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '7IL', strScheduleName = 'Gallons Exported to IL', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 280, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42116, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '7IL', strScheduleName = 'Gallons Exported to IL', strType = 'Diesel Dyed', strNote = '', strTransactionType = 'Invoice', intSort = 290, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42117, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '7IL', strScheduleName = 'Gallons Exported to IL', strType = 'Diesel Undyed', strNote = '', strTransactionType = 'Invoice', intSort = 300, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42118, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '7IL', strScheduleName = 'Gallons Exported to IL', strType = 'LP', strNote = '', strTransactionType = 'Invoice', intSort = 310, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42119, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '7MO', strScheduleName = 'Gallons Exported to MO', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 320, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42120, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '7MO', strScheduleName = 'Gallons Exported to MO', strType = 'Diesel Dyed', strNote = '', strTransactionType = 'Invoice', intSort = 330, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42121, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '7MO', strScheduleName = 'Gallons Exported to MO', strType = 'Diesel Undyed', strNote = '', strTransactionType = 'Invoice', intSort = 340, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42122, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '7MO', strScheduleName = 'Gallons Exported to MO', strType = 'LP', strNote = '', strTransactionType = 'Invoice', intSort = 350, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42123, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '7OK', strScheduleName = 'Gallons Exported to OK', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 360, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42124, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '7OK', strScheduleName = 'Gallons Exported to OK', strType = 'Diesel Dyed', strNote = '', strTransactionType = 'Invoice', intSort = 370, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42125, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '7OK', strScheduleName = 'Gallons Exported to OK', strType = 'Diesel Undyed', strNote = '', strTransactionType = 'Invoice', intSort = 380, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42126, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '7OK', strScheduleName = 'Gallons Exported to OK', strType = 'LP', strNote = '', strTransactionType = 'Invoice', intSort = 390, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42127, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '8', strScheduleName = 'Gallons Delivered to US Government, Tax Exempt', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 400, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42128, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '8', strScheduleName = 'Gallons Delivered to US Government, Tax Exempt', strType = 'Diesel Dyed', strNote = '', strTransactionType = 'Invoice', intSort = 410, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42129, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '8', strScheduleName = 'Gallons Delivered to US Government, Tax Exempt', strType = 'Diesel Undyed', strNote = '', strTransactionType = 'Invoice', intSort = 420, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42130, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '8', strScheduleName = 'Gallons Delivered to US Government, Tax Exempt', strType = 'LP', strNote = '', strTransactionType = 'Invoice', intSort = 430, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42131, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '10A', strScheduleName = 'Gallons Delivered to Exempt Customers for Non-highway Use', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 440, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42132, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '10A', strScheduleName = 'Gallons Delivered to Exempt Customers for Non-highway Use', strType = 'Diesel Dyed', strNote = '', strTransactionType = 'Invoice', intSort = 450, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42133, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '10A', strScheduleName = 'Gallons Delivered to Exempt Customers for Non-highway Use', strType = 'Diesel Undyed', strNote = '', strTransactionType = 'Invoice', intSort = 460, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42134, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR D', strFormName = 'AR Disbursement Schedules', strScheduleCode = '10A', strScheduleName = 'Gallons Delivered to Exempt Customers for Non-highway Use', strType = 'LP', strNote = '', strTransactionType = 'Invoice', intSort = 470, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 42135, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'AR EDI', strFormName = 'AR EDI File', strScheduleCode = '', strScheduleName = '', strType = '', strNote = '', strTransactionType = '', intSort = 600, strStoredProcedure = '', intMasterId = 42136, intComponentTypeId = 3

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
	SELECT intTaxCriteriaId = 0, strTaxCategory = 'AR Excise Tax Gasoline', strState = 'AR', strFormCode = 'AR R', strScheduleCode = '1', strType = 'Gasoline', strCriteria = '<> 0', intMasterId = 4937
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'AR Excise Tax Diesel Clear', strState = 'AR', strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Undyed', strCriteria = '<> 0', intMasterId = 4938
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'AR Excise Tax Diesel Dyed', strState = 'AR', strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Dyed', strCriteria = '<> 0', intMasterId = 4939
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'AR Excise Tax LPG', strState = 'AR', strFormCode = 'AR R', strScheduleCode = '1', strType = 'LP', strCriteria = '<> 0', intMasterId = 4940
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'AR Excise Tax Gasoline', strState = 'AR', strFormCode = 'AR R', strScheduleCode = '2', strType = 'Gasoline', strCriteria = '= 0', intMasterId = 4941
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'AR Excise Tax Diesel Clear', strState = 'AR', strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Undyed', strCriteria = '= 0', intMasterId = 4942
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'AR Excise Tax Diesel Dyed', strState = 'AR', strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Dyed', strCriteria = '= 0', intMasterId = 4943
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'AR Excise Tax LPG', strState = 'AR', strFormCode = 'AR R', strScheduleCode = '2', strType = 'LP', strCriteria = '= 0', intMasterId = 4944
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'AR Excise Tax LPG', strState = 'AR', strFormCode = 'AR D', strScheduleCode = '10A', strType = 'LP', strCriteria = '= 0', intMasterId = 4957
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'AR Excise Tax LPG', strState = 'AR', strFormCode = 'AR D', strScheduleCode = '6', strType = 'LP', strCriteria = '= 0', intMasterId = 4958
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'AR Excise Tax LPG', strState = 'AR', strFormCode = 'AR D', strScheduleCode = '8', strType = 'LP', strCriteria = '= 0', intMasterId = 4959
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'AR Excise Tax Gasoline', strState = 'AR', strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Gasoline', strCriteria = '= 0', intMasterId = 4960
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'AR Excise Tax Gasoline', strState = 'AR', strFormCode = 'AR D', strScheduleCode = '6', strType = 'Gasoline', strCriteria = '= 0', intMasterId = 4961
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'AR Excise Tax Gasoline', strState = 'AR', strFormCode = 'AR D', strScheduleCode = '8', strType = 'Gasoline', strCriteria = '= 0', intMasterId = 4962
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'AR Excise Tax Diesel Clear', strState = 'AR', strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Undyed', strCriteria = '= 0', intMasterId = 4963
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'AR Excise Tax Diesel Clear', strState = 'AR', strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Undyed', strCriteria = '= 0', intMasterId = 4964
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'AR Excise Tax Diesel Clear', strState = 'AR', strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Undyed', strCriteria = '= 0', intMasterId = 4965
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'AR Excise Tax Diesel Dyed', strState = 'AR', strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Dyed', strCriteria = '= 0', intMasterId = 4966
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'AR Excise Tax Diesel Dyed', strState = 'AR', strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Dyed', strCriteria = '= 0', intMasterId = 4967
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'AR Excise Tax Diesel Dyed', strState = 'AR', strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Dyed', strCriteria = '= 0', intMasterId = 4968
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'OK Excise Tax Gasoline', strState = 'OK', strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Gasoline', strCriteria = '<> 0', intMasterId = 4969
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'OK Excise Tax Diesel Clear', strState = 'OK', strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Undyed', strCriteria = '<> 0', intMasterId = 4970

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
	SELECT intValidProductCodeId = 0, strProductCode = '65', strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Gasoline', intMasterId = 49129
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Gasoline', intMasterId = 49130
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Gasoline', intMasterId = 49131
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '65', strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Gasoline', intMasterId = 49132
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Gasoline', intMasterId = 49133
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Gasoline', intMasterId = 49134
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '65', strFormCode = 'AR D', strScheduleCode = '6', strType = 'Gasoline', intMasterId = 49135
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'AR D', strScheduleCode = '6', strType = 'Gasoline', intMasterId = 49136
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'AR D', strScheduleCode = '6', strType = 'Gasoline', intMasterId = 49137
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '65', strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Gasoline', intMasterId = 49138
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Gasoline', intMasterId = 49139
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Gasoline', intMasterId = 49140
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '65', strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Gasoline', intMasterId = 49141
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Gasoline', intMasterId = 49142
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Gasoline', intMasterId = 49143
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '65', strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Gasoline', intMasterId = 49144
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Gasoline', intMasterId = 49145
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Gasoline', intMasterId = 49146
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '65', strFormCode = 'AR D', strScheduleCode = '8', strType = 'Gasoline', intMasterId = 49147
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'AR D', strScheduleCode = '8', strType = 'Gasoline', intMasterId = 49148
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'AR D', strScheduleCode = '8', strType = 'Gasoline', intMasterId = 49149
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '65', strFormCode = 'AR R', strScheduleCode = '1', strType = 'Gasoline', intMasterId = 49150
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'AR R', strScheduleCode = '1', strType = 'Gasoline', intMasterId = 49151
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'AR R', strScheduleCode = '1', strType = 'Gasoline', intMasterId = 49152
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '65', strFormCode = 'AR R', strScheduleCode = '2', strType = 'Gasoline', intMasterId = 49153
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'AR R', strScheduleCode = '2', strType = 'Gasoline', intMasterId = 49154
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'AR R', strScheduleCode = '2', strType = 'Gasoline', intMasterId = 49155
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '65', strFormCode = 'AR R', strScheduleCode = '3', strType = 'Gasoline', intMasterId = 49156
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'AR R', strScheduleCode = '3', strType = 'Gasoline', intMasterId = 49157
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'AR R', strScheduleCode = '3', strType = 'Gasoline', intMasterId = 49158
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Dyed', intMasterId = 49189
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Dyed', intMasterId = 49190
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Dyed', intMasterId = 49191
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Dyed', intMasterId = 49192
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Dyed', intMasterId = 49193
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Dyed', intMasterId = 49194
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Dyed', intMasterId = 49195
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Dyed', intMasterId = 49196
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Dyed', intMasterId = 49197
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Dyed', intMasterId = 49198
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Undyed', intMasterId = 49199
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Undyed', intMasterId = 49200
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Undyed', intMasterId = 49201
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Undyed', intMasterId = 49202
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Undyed', intMasterId = 49203
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Undyed', intMasterId = 49204
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Undyed', intMasterId = 49205
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Undyed', intMasterId = 49206
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Undyed', intMasterId = 49207
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Undyed', intMasterId = 49208
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Undyed', intMasterId = 49209
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Undyed', intMasterId = 49210
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Undyed', intMasterId = 49211
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Undyed', intMasterId = 49212
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Undyed', intMasterId = 49213
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Undyed', intMasterId = 49214
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Undyed', intMasterId = 49215
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Undyed', intMasterId = 49216
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Undyed', intMasterId = 49217
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Undyed', intMasterId = 49218
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Undyed', intMasterId = 49219
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Undyed', intMasterId = 49220
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Undyed', intMasterId = 49221
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Undyed', intMasterId = 49222
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Undyed', intMasterId = 49223
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Undyed', intMasterId = 49224
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Undyed', intMasterId = 49225
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Undyed', intMasterId = 49226
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Undyed', intMasterId = 49227
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Undyed', intMasterId = 49228
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '54', strFormCode = 'AR D', strScheduleCode = '10A', strType = 'LP', intMasterId = 49229
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '54', strFormCode = 'AR D', strScheduleCode = '5J', strType = 'LP', intMasterId = 49230
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '54', strFormCode = 'AR D', strScheduleCode = '6', strType = 'LP', intMasterId = 49231
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '54', strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'LP', intMasterId = 49232
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '54', strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'LP', intMasterId = 49233
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '54', strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'LP', intMasterId = 49234
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '54', strFormCode = 'AR D', strScheduleCode = '8', strType = 'LP', intMasterId = 49235
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '54', strFormCode = 'AR R', strScheduleCode = '1', strType = 'LP', intMasterId = 49236
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '54', strFormCode = 'AR R', strScheduleCode = '2', strType = 'LP', intMasterId = 49237
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '54', strFormCode = 'AR R', strScheduleCode = '3', strType = 'LP', intMasterId = 49238

	INSERT INTO @ValidOriginStates(
		intValidOriginStateId
		, strFormCode
		, strScheduleCode
		, strType
		, strState
		, strStatus
		, intMasterId
	)
	SELECT intValidOriginStateId = 0, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Gasoline', strState = 'AR', strStatus = 'Include', intMasterId = 41110
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Dyed', strState = 'AR', strStatus = 'Include', intMasterId = 41111
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Undyed', strState = 'AR', strStatus = 'Include', intMasterId = 41112
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR R', strScheduleCode = '1', strType = 'LP', strState = 'AR', strStatus = 'Include', intMasterId = 41113
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Gasoline', strState = 'AR', strStatus = 'Include', intMasterId = 41114
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Dyed', strState = 'AR', strStatus = 'Include', intMasterId = 41115
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Undyed', strState = 'AR', strStatus = 'Include', intMasterId = 41116
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR R', strScheduleCode = '2', strType = 'LP', strState = 'AR', strStatus = 'Include', intMasterId = 41117
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Gasoline', strState = 'AR', strStatus = 'Exclude', intMasterId = 41118
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Dyed', strState = 'AR', strStatus = 'Exclude', intMasterId = 41119
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Undyed', strState = 'AR', strStatus = 'Exclude', intMasterId = 41120
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR R', strScheduleCode = '3', strType = 'LP', strState = 'AR', strStatus = 'Exclude', intMasterId = 41121
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Gasoline', strState = 'AR', strStatus = 'Include', intMasterId = 41122
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Dyed', strState = 'AR', strStatus = 'Include', intMasterId = 41123
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Undyed', strState = 'AR', strStatus = 'Include', intMasterId = 41124
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'LP', strState = 'AR', strStatus = 'Include', intMasterId = 41125
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Gasoline', strState = 'AR', strStatus = 'Include', intMasterId = 41126
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Dyed', strState = 'AR', strStatus = 'Include', intMasterId = 41127
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Undyed', strState = 'AR', strStatus = 'Include', intMasterId = 41128
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '6', strType = 'LP', strState = 'AR', strStatus = 'Include', intMasterId = 41129
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Gasoline', strState = 'AR', strStatus = 'Include', intMasterId = 41130
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Dyed', strState = 'AR', strStatus = 'Include', intMasterId = 41131
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Undyed', strState = 'AR', strStatus = 'Include', intMasterId = 41132
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'LP', strState = 'AR', strStatus = 'Include', intMasterId = 41133
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Gasoline', strState = 'AR', strStatus = 'Include', intMasterId = 41134
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Dyed', strState = 'AR', strStatus = 'Include', intMasterId = 41135
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Undyed', strState = 'AR', strStatus = 'Include', intMasterId = 41136
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'LP', strState = 'AR', strStatus = 'Include', intMasterId = 41137
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Gasoline', strState = 'AR', strStatus = 'Include', intMasterId = 41138
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Dyed', strState = 'AR', strStatus = 'Include', intMasterId = 41139
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Undyed', strState = 'AR', strStatus = 'Include', intMasterId = 41140
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'LP', strState = 'AR', strStatus = 'Include', intMasterId = 41141
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Gasoline', strState = 'AR', strStatus = 'Include', intMasterId = 41142
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Dyed', strState = 'AR', strStatus = 'Include', intMasterId = 41143
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Undyed', strState = 'AR', strStatus = 'Include', intMasterId = 41144
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '8', strType = 'LP', strState = 'AR', strStatus = 'Include', intMasterId = 41145
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Gasoline', strState = 'AR', strStatus = 'Include', intMasterId = 41146
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Dyed', strState = 'AR', strStatus = 'Include', intMasterId = 41147
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Undyed', strState = 'AR', strStatus = 'Include', intMasterId = 41148
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'LP', strState = 'AR', strStatus = 'Include', intMasterId = 41149

	INSERT INTO @ValidDestinationStates(
		intValidDestinationStateId
		, strFormCode
		, strScheduleCode
		, strType
		, strState
		, strStatus
		, intMasterId
	)
	SELECT intValidDestinationStateId = 0, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Gasoline', strState = 'AR', strStatus = 'Include', intMasterId = 41073
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Dyed', strState = 'AR', strStatus = 'Include', intMasterId = 41074
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Undyed', strState = 'AR', strStatus = 'Include', intMasterId = 41075
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'AR R', strScheduleCode = '1', strType = 'LP', strState = 'AR', strStatus = 'Include', intMasterId = 41076
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Gasoline', strState = 'AR', strStatus = 'Include', intMasterId = 41077
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Dyed', strState = 'AR', strStatus = 'Include', intMasterId = 41078
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Undyed', strState = 'AR', strStatus = 'Include', intMasterId = 41079
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'AR R', strScheduleCode = '2', strType = 'LP', strState = 'AR', strStatus = 'Include', intMasterId = 41080
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Gasoline', strState = 'AR', strStatus = 'Include', intMasterId = 41081
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Dyed', strState = 'AR', strStatus = 'Include', intMasterId = 41082
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Undyed', strState = 'AR', strStatus = 'Include', intMasterId = 41083
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'AR R', strScheduleCode = '3', strType = 'LP', strState = 'AR', strStatus = 'Include', intMasterId = 41084
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Gasoline', strState = 'IL', strStatus = 'Include', intMasterId = 41085
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Dyed', strState = 'IL', strStatus = 'Include', intMasterId = 41086
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Undyed', strState = 'IL', strStatus = 'Include', intMasterId = 41087
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'LP', strState = 'IL', strStatus = 'Include', intMasterId = 41088
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Gasoline', strState = 'MO', strStatus = 'Include', intMasterId = 41089
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Dyed', strState = 'MO', strStatus = 'Include', intMasterId = 41090
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Undyed', strState = 'MO', strStatus = 'Include', intMasterId = 41091
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'LP', strState = 'MO', strStatus = 'Include', intMasterId = 41092
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Gasoline', strState = 'OK', strStatus = 'Include', intMasterId = 41093
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Dyed', strState = 'OK', strStatus = 'Include', intMasterId = 41094
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Undyed', strState = 'OK', strStatus = 'Include', intMasterId = 41095
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'LP', strState = 'OK', strStatus = 'Include', intMasterId = 41096

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
	SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-ISA01', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '1', strDescription = 'Authorization Information Qualifier', strScheduleList = NULL, strConfiguration = '3', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '1', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41249
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-ISA02', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '2', strDescription = 'Authorization Information (10 characters)', strScheduleList = NULL, strConfiguration = 'AR813051PP', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '2', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41250
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-ISA03', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '3', strDescription = 'Security Information Qualifier', strScheduleList = NULL, strConfiguration = '0', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '3', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41251
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-ISA04', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '4', strDescription = 'Security Information (10 characters)', strScheduleList = NULL, strConfiguration = '          ', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '4', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41252
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-ISA05', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '5', strDescription = 'Interchange ID Qualifier', strScheduleList = NULL, strConfiguration = '1', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '5', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41253
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-ISA06', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '6', strDescription = 'Interchange Sender ID', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '6', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41254
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-ISA07', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '7', strDescription = 'Interchange ID Qualifier', strScheduleList = NULL, strConfiguration = '1', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '7', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41255
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-ISA08', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '8', strDescription = 'Interchange Receiver ID', strScheduleList = NULL, strConfiguration = '174169771', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '8', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41256
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-ISA11', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '9', strDescription = 'Repetition Separator', strScheduleList = NULL, strConfiguration = 'U', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '9', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41257
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-ISA12', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '10', strDescription = 'Interchange Control Version Number', strScheduleList = NULL, strConfiguration = '305', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '10', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41258
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-ISA13', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '11', strDescription = 'Interchange Control Number (for next transmission)', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '11', ysnOutputDesigner = 0, strInputType = 'integer', intMasterId = 41259
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-ISA14', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '12', strDescription = 'Acknowledgement Requested', strScheduleList = NULL, strConfiguration = '0', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '12', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41260
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-ISA15', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '13', strDescription = 'Usage Indicator (P = Production; T = Test)', strScheduleList = NULL, strConfiguration = 'P', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '13', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41261
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-ISA16', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '14', strDescription = 'Component Sub-element Separator', strScheduleList = NULL, strConfiguration = ':', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '14', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41262
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-GS01', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '15', strDescription = 'Functional Identifier Code', strScheduleList = NULL, strConfiguration = 'TF', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '15', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41263
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-GS06', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '16', strDescription = 'Group Control Number (for next transmission)', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '16', ysnOutputDesigner = 0, strInputType = 'integer', intMasterId = 41264
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-GS07', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '17', strDescription = 'Responsible Agency Code', strScheduleList = NULL, strConfiguration = 'X', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '17', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41265
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-GS08', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '18', strDescription = 'Version/Release/Industry ID Code', strScheduleList = NULL, strConfiguration = '3050', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '18', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41266
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-ST01', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '19', strDescription = 'Transaction Set Code', strScheduleList = NULL, strConfiguration = '813', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '19', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41267
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-ST02', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '20', strDescription = 'Transaction Set Control Number (for next transmission)', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '20', ysnOutputDesigner = 0, strInputType = 'integer', intMasterId = 41268
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-BTI01', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '21', strDescription = 'Reference Number Qualifier', strScheduleList = NULL, strConfiguration = 'T6', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '21', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41269
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-BTI02', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '22', strDescription = 'Reference Number (Tax Type Code)', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '22', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41270
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-BTI03', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '23', strDescription = 'ID Code Qualifier', strScheduleList = NULL, strConfiguration = '47', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '23', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41271
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-BTI04', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '24', strDescription = 'ID Code', strScheduleList = NULL, strConfiguration = 'AR', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '24', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41272
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-BTI07', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '25', strDescription = 'ID Code Qualifier', strScheduleList = NULL, strConfiguration = '24', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '25', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41273
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-BTI09', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '26', strDescription = 'ID Code Qualifier', strScheduleList = NULL, strConfiguration = '49', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '26', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41274
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-ARLicTypeG', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '27', strDescription = 'AR License Type for Gasoline', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '27', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41275
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-ARLicG', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '28', strDescription = 'AR License Number for Gasoline', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '28', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41276
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-ARLicTypeD', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '29', strDescription = 'AR License Type for Diesel', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '29', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41277
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-ARLicD', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '30', strDescription = 'AR License Number for Diesel', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '30', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41278
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-ARLicTypeP', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '31', strDescription = 'AR License Type for Propane', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '31', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41279
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-ARLicP', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '32', strDescription = 'AR License Number for Propane', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '32', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41280
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'AREDI-ST03', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '20', strDescription = ' Implementation Convention Reference', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '20', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 41281

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
	SELECT intScheduleColumnId = 1, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426483
	UNION ALL SELECT intScheduleColumnId = 2, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426484
	UNION ALL SELECT intScheduleColumnId = 3, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426485
	UNION ALL SELECT intScheduleColumnId = 4, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426486
	UNION ALL SELECT intScheduleColumnId = 5, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426487
	UNION ALL SELECT intScheduleColumnId = 6, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426488
	UNION ALL SELECT intScheduleColumnId = 7, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426489
	UNION ALL SELECT intScheduleColumnId = 8, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426490
	UNION ALL SELECT intScheduleColumnId = 9, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426491
	UNION ALL SELECT intScheduleColumnId = 10, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426492
	UNION ALL SELECT intScheduleColumnId = 11, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426493
	UNION ALL SELECT intScheduleColumnId = 12, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Dyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426494
	UNION ALL SELECT intScheduleColumnId = 13, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Dyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426495
	UNION ALL SELECT intScheduleColumnId = 14, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Dyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426496
	UNION ALL SELECT intScheduleColumnId = 15, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Dyed', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426497
	UNION ALL SELECT intScheduleColumnId = 16, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Dyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426498
	UNION ALL SELECT intScheduleColumnId = 17, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Dyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426499
	UNION ALL SELECT intScheduleColumnId = 18, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Dyed', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426500
	UNION ALL SELECT intScheduleColumnId = 19, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Dyed', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426501
	UNION ALL SELECT intScheduleColumnId = 20, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Dyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426502
	UNION ALL SELECT intScheduleColumnId = 21, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Dyed', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426503
	UNION ALL SELECT intScheduleColumnId = 22, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Dyed', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426504
	UNION ALL SELECT intScheduleColumnId = 23, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Undyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426505
	UNION ALL SELECT intScheduleColumnId = 24, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Undyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426506
	UNION ALL SELECT intScheduleColumnId = 25, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Undyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426507
	UNION ALL SELECT intScheduleColumnId = 26, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Undyed', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426508
	UNION ALL SELECT intScheduleColumnId = 27, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Undyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426509
	UNION ALL SELECT intScheduleColumnId = 28, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Undyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426510
	UNION ALL SELECT intScheduleColumnId = 29, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Undyed', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426511
	UNION ALL SELECT intScheduleColumnId = 30, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Undyed', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426512
	UNION ALL SELECT intScheduleColumnId = 31, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Undyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426513
	UNION ALL SELECT intScheduleColumnId = 32, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Undyed', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426514
	UNION ALL SELECT intScheduleColumnId = 33, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Undyed', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426515
	UNION ALL SELECT intScheduleColumnId = 34, strFormCode = 'AR R', strScheduleCode = '1', strType = 'LP', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426516
	UNION ALL SELECT intScheduleColumnId = 35, strFormCode = 'AR R', strScheduleCode = '1', strType = 'LP', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426517
	UNION ALL SELECT intScheduleColumnId = 36, strFormCode = 'AR R', strScheduleCode = '1', strType = 'LP', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426518
	UNION ALL SELECT intScheduleColumnId = 37, strFormCode = 'AR R', strScheduleCode = '1', strType = 'LP', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426519
	UNION ALL SELECT intScheduleColumnId = 38, strFormCode = 'AR R', strScheduleCode = '1', strType = 'LP', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426520
	UNION ALL SELECT intScheduleColumnId = 39, strFormCode = 'AR R', strScheduleCode = '1', strType = 'LP', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426521
	UNION ALL SELECT intScheduleColumnId = 40, strFormCode = 'AR R', strScheduleCode = '1', strType = 'LP', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426522
	UNION ALL SELECT intScheduleColumnId = 41, strFormCode = 'AR R', strScheduleCode = '1', strType = 'LP', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426523
	UNION ALL SELECT intScheduleColumnId = 42, strFormCode = 'AR R', strScheduleCode = '1', strType = 'LP', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426524
	UNION ALL SELECT intScheduleColumnId = 43, strFormCode = 'AR R', strScheduleCode = '1', strType = 'LP', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426525
	UNION ALL SELECT intScheduleColumnId = 44, strFormCode = 'AR R', strScheduleCode = '1', strType = 'LP', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426526
	UNION ALL SELECT intScheduleColumnId = 45, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426527
	UNION ALL SELECT intScheduleColumnId = 46, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426528
	UNION ALL SELECT intScheduleColumnId = 47, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426529
	UNION ALL SELECT intScheduleColumnId = 48, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Gasoline', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426530
	UNION ALL SELECT intScheduleColumnId = 49, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426531
	UNION ALL SELECT intScheduleColumnId = 50, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426532
	UNION ALL SELECT intScheduleColumnId = 51, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426533
	UNION ALL SELECT intScheduleColumnId = 52, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426534
	UNION ALL SELECT intScheduleColumnId = 53, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426535
	UNION ALL SELECT intScheduleColumnId = 54, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Gasoline', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426536
	UNION ALL SELECT intScheduleColumnId = 55, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426537
	UNION ALL SELECT intScheduleColumnId = 56, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Dyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426538
	UNION ALL SELECT intScheduleColumnId = 57, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Dyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426539
	UNION ALL SELECT intScheduleColumnId = 58, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Dyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426540
	UNION ALL SELECT intScheduleColumnId = 59, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Dyed', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426541
	UNION ALL SELECT intScheduleColumnId = 60, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Dyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426542
	UNION ALL SELECT intScheduleColumnId = 61, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Dyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426543
	UNION ALL SELECT intScheduleColumnId = 62, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Dyed', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426544
	UNION ALL SELECT intScheduleColumnId = 63, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Dyed', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426545
	UNION ALL SELECT intScheduleColumnId = 64, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Dyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426546
	UNION ALL SELECT intScheduleColumnId = 65, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Dyed', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426547
	UNION ALL SELECT intScheduleColumnId = 66, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Dyed', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426548
	UNION ALL SELECT intScheduleColumnId = 67, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Undyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426549
	UNION ALL SELECT intScheduleColumnId = 68, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Undyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426550
	UNION ALL SELECT intScheduleColumnId = 69, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Undyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426551
	UNION ALL SELECT intScheduleColumnId = 70, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Undyed', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426552
	UNION ALL SELECT intScheduleColumnId = 71, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Undyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426553
	UNION ALL SELECT intScheduleColumnId = 72, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Undyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426554
	UNION ALL SELECT intScheduleColumnId = 73, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Undyed', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426555
	UNION ALL SELECT intScheduleColumnId = 74, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Undyed', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426556
	UNION ALL SELECT intScheduleColumnId = 75, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Undyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426557
	UNION ALL SELECT intScheduleColumnId = 76, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Undyed', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426558
	UNION ALL SELECT intScheduleColumnId = 77, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Undyed', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426559
	UNION ALL SELECT intScheduleColumnId = 78, strFormCode = 'AR R', strScheduleCode = '2', strType = 'LP', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426560
	UNION ALL SELECT intScheduleColumnId = 79, strFormCode = 'AR R', strScheduleCode = '2', strType = 'LP', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426561
	UNION ALL SELECT intScheduleColumnId = 80, strFormCode = 'AR R', strScheduleCode = '2', strType = 'LP', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426562
	UNION ALL SELECT intScheduleColumnId = 81, strFormCode = 'AR R', strScheduleCode = '2', strType = 'LP', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426563
	UNION ALL SELECT intScheduleColumnId = 82, strFormCode = 'AR R', strScheduleCode = '2', strType = 'LP', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426564
	UNION ALL SELECT intScheduleColumnId = 83, strFormCode = 'AR R', strScheduleCode = '2', strType = 'LP', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426565
	UNION ALL SELECT intScheduleColumnId = 84, strFormCode = 'AR R', strScheduleCode = '2', strType = 'LP', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426566
	UNION ALL SELECT intScheduleColumnId = 85, strFormCode = 'AR R', strScheduleCode = '2', strType = 'LP', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426567
	UNION ALL SELECT intScheduleColumnId = 86, strFormCode = 'AR R', strScheduleCode = '2', strType = 'LP', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426568
	UNION ALL SELECT intScheduleColumnId = 87, strFormCode = 'AR R', strScheduleCode = '2', strType = 'LP', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426569
	UNION ALL SELECT intScheduleColumnId = 88, strFormCode = 'AR R', strScheduleCode = '2', strType = 'LP', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426570
	UNION ALL SELECT intScheduleColumnId = 89, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426571
	UNION ALL SELECT intScheduleColumnId = 90, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426572
	UNION ALL SELECT intScheduleColumnId = 91, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426573
	UNION ALL SELECT intScheduleColumnId = 92, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426574
	UNION ALL SELECT intScheduleColumnId = 93, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426575
	UNION ALL SELECT intScheduleColumnId = 94, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426576
	UNION ALL SELECT intScheduleColumnId = 95, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426577
	UNION ALL SELECT intScheduleColumnId = 96, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426578
	UNION ALL SELECT intScheduleColumnId = 97, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426579
	UNION ALL SELECT intScheduleColumnId = 98, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426580
	UNION ALL SELECT intScheduleColumnId = 99, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426581
	UNION ALL SELECT intScheduleColumnId = 100, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Dyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426582
	UNION ALL SELECT intScheduleColumnId = 101, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Dyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426583
	UNION ALL SELECT intScheduleColumnId = 102, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Dyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426584
	UNION ALL SELECT intScheduleColumnId = 103, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Dyed', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426585
	UNION ALL SELECT intScheduleColumnId = 104, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Dyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426586
	UNION ALL SELECT intScheduleColumnId = 105, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Dyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426587
	UNION ALL SELECT intScheduleColumnId = 106, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Dyed', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426588
	UNION ALL SELECT intScheduleColumnId = 107, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Dyed', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426589
	UNION ALL SELECT intScheduleColumnId = 108, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Dyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426590
	UNION ALL SELECT intScheduleColumnId = 109, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Dyed', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426591
	UNION ALL SELECT intScheduleColumnId = 110, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Dyed', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426592
	UNION ALL SELECT intScheduleColumnId = 111, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Undyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426593
	UNION ALL SELECT intScheduleColumnId = 112, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Undyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426594
	UNION ALL SELECT intScheduleColumnId = 113, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Undyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426595
	UNION ALL SELECT intScheduleColumnId = 114, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Undyed', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426596
	UNION ALL SELECT intScheduleColumnId = 115, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Undyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426597
	UNION ALL SELECT intScheduleColumnId = 116, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Undyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426598
	UNION ALL SELECT intScheduleColumnId = 117, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Undyed', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426599
	UNION ALL SELECT intScheduleColumnId = 118, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Undyed', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426600
	UNION ALL SELECT intScheduleColumnId = 119, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Undyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426601
	UNION ALL SELECT intScheduleColumnId = 120, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Undyed', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426602
	UNION ALL SELECT intScheduleColumnId = 121, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Undyed', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426603
	UNION ALL SELECT intScheduleColumnId = 122, strFormCode = 'AR R', strScheduleCode = '3', strType = 'LP', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426604
	UNION ALL SELECT intScheduleColumnId = 123, strFormCode = 'AR R', strScheduleCode = '3', strType = 'LP', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426605
	UNION ALL SELECT intScheduleColumnId = 124, strFormCode = 'AR R', strScheduleCode = '3', strType = 'LP', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426606
	UNION ALL SELECT intScheduleColumnId = 125, strFormCode = 'AR R', strScheduleCode = '3', strType = 'LP', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426607
	UNION ALL SELECT intScheduleColumnId = 126, strFormCode = 'AR R', strScheduleCode = '3', strType = 'LP', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426608
	UNION ALL SELECT intScheduleColumnId = 127, strFormCode = 'AR R', strScheduleCode = '3', strType = 'LP', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426609
	UNION ALL SELECT intScheduleColumnId = 128, strFormCode = 'AR R', strScheduleCode = '3', strType = 'LP', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426610
	UNION ALL SELECT intScheduleColumnId = 129, strFormCode = 'AR R', strScheduleCode = '3', strType = 'LP', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426611
	UNION ALL SELECT intScheduleColumnId = 130, strFormCode = 'AR R', strScheduleCode = '3', strType = 'LP', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426612
	UNION ALL SELECT intScheduleColumnId = 131, strFormCode = 'AR R', strScheduleCode = '3', strType = 'LP', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426613
	UNION ALL SELECT intScheduleColumnId = 132, strFormCode = 'AR R', strScheduleCode = '3', strType = 'LP', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426614
	UNION ALL SELECT intScheduleColumnId = 133, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426616
	UNION ALL SELECT intScheduleColumnId = 134, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426617
	UNION ALL SELECT intScheduleColumnId = 135, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426618
	UNION ALL SELECT intScheduleColumnId = 136, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426619
	UNION ALL SELECT intScheduleColumnId = 137, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426620
	UNION ALL SELECT intScheduleColumnId = 138, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426621
	UNION ALL SELECT intScheduleColumnId = 139, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426622
	UNION ALL SELECT intScheduleColumnId = 140, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426623
	UNION ALL SELECT intScheduleColumnId = 141, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Gasoline', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426624
	UNION ALL SELECT intScheduleColumnId = 142, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426625
	UNION ALL SELECT intScheduleColumnId = 143, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Dyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426626
	UNION ALL SELECT intScheduleColumnId = 144, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Dyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426627
	UNION ALL SELECT intScheduleColumnId = 145, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Dyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426628
	UNION ALL SELECT intScheduleColumnId = 146, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Dyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426629
	UNION ALL SELECT intScheduleColumnId = 147, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Dyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426630
	UNION ALL SELECT intScheduleColumnId = 148, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Dyed', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426631
	UNION ALL SELECT intScheduleColumnId = 149, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Dyed', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426632
	UNION ALL SELECT intScheduleColumnId = 150, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Dyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426633
	UNION ALL SELECT intScheduleColumnId = 151, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Dyed', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426634
	UNION ALL SELECT intScheduleColumnId = 152, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Dyed', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426635
	UNION ALL SELECT intScheduleColumnId = 153, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Undyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426636
	UNION ALL SELECT intScheduleColumnId = 154, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Undyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426637
	UNION ALL SELECT intScheduleColumnId = 155, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Undyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426638
	UNION ALL SELECT intScheduleColumnId = 156, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Undyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426639
	UNION ALL SELECT intScheduleColumnId = 157, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Undyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426640
	UNION ALL SELECT intScheduleColumnId = 158, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Undyed', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426641
	UNION ALL SELECT intScheduleColumnId = 159, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Undyed', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426642
	UNION ALL SELECT intScheduleColumnId = 160, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Undyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426643
	UNION ALL SELECT intScheduleColumnId = 161, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Undyed', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426644
	UNION ALL SELECT intScheduleColumnId = 162, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Undyed', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426645
	UNION ALL SELECT intScheduleColumnId = 163, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'LP', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426646
	UNION ALL SELECT intScheduleColumnId = 164, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'LP', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426647
	UNION ALL SELECT intScheduleColumnId = 165, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'LP', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426648
	UNION ALL SELECT intScheduleColumnId = 166, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'LP', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426649
	UNION ALL SELECT intScheduleColumnId = 167, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'LP', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426650
	UNION ALL SELECT intScheduleColumnId = 168, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'LP', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426651
	UNION ALL SELECT intScheduleColumnId = 169, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'LP', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426652
	UNION ALL SELECT intScheduleColumnId = 170, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'LP', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426653
	UNION ALL SELECT intScheduleColumnId = 171, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'LP', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426654
	UNION ALL SELECT intScheduleColumnId = 172, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'LP', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426655
	UNION ALL SELECT intScheduleColumnId = 173, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426656
	UNION ALL SELECT intScheduleColumnId = 174, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426657
	UNION ALL SELECT intScheduleColumnId = 175, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426658
	UNION ALL SELECT intScheduleColumnId = 176, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426659
	UNION ALL SELECT intScheduleColumnId = 177, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426660
	UNION ALL SELECT intScheduleColumnId = 178, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426661
	UNION ALL SELECT intScheduleColumnId = 179, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426662
	UNION ALL SELECT intScheduleColumnId = 180, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426663
	UNION ALL SELECT intScheduleColumnId = 181, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426664
	UNION ALL SELECT intScheduleColumnId = 182, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426665
	UNION ALL SELECT intScheduleColumnId = 183, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Dyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426666
	UNION ALL SELECT intScheduleColumnId = 184, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Dyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426667
	UNION ALL SELECT intScheduleColumnId = 185, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Dyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426668
	UNION ALL SELECT intScheduleColumnId = 186, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Dyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426669
	UNION ALL SELECT intScheduleColumnId = 187, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Dyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426670
	UNION ALL SELECT intScheduleColumnId = 188, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Dyed', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426671
	UNION ALL SELECT intScheduleColumnId = 189, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Dyed', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426672
	UNION ALL SELECT intScheduleColumnId = 190, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Dyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426673
	UNION ALL SELECT intScheduleColumnId = 191, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Dyed', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426674
	UNION ALL SELECT intScheduleColumnId = 192, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Dyed', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426675
	UNION ALL SELECT intScheduleColumnId = 193, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Undyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426676
	UNION ALL SELECT intScheduleColumnId = 194, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Undyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426677
	UNION ALL SELECT intScheduleColumnId = 195, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Undyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426678
	UNION ALL SELECT intScheduleColumnId = 196, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Undyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426679
	UNION ALL SELECT intScheduleColumnId = 197, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Undyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426680
	UNION ALL SELECT intScheduleColumnId = 198, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Undyed', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426681
	UNION ALL SELECT intScheduleColumnId = 199, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Undyed', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426682
	UNION ALL SELECT intScheduleColumnId = 200, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Undyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426683
	UNION ALL SELECT intScheduleColumnId = 201, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Undyed', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426684
	UNION ALL SELECT intScheduleColumnId = 202, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Undyed', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426685
	UNION ALL SELECT intScheduleColumnId = 203, strFormCode = 'AR D', strScheduleCode = '6', strType = 'LP', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426686
	UNION ALL SELECT intScheduleColumnId = 204, strFormCode = 'AR D', strScheduleCode = '6', strType = 'LP', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426687
	UNION ALL SELECT intScheduleColumnId = 205, strFormCode = 'AR D', strScheduleCode = '6', strType = 'LP', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426688
	UNION ALL SELECT intScheduleColumnId = 206, strFormCode = 'AR D', strScheduleCode = '6', strType = 'LP', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426689
	UNION ALL SELECT intScheduleColumnId = 207, strFormCode = 'AR D', strScheduleCode = '6', strType = 'LP', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426690
	UNION ALL SELECT intScheduleColumnId = 208, strFormCode = 'AR D', strScheduleCode = '6', strType = 'LP', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426691
	UNION ALL SELECT intScheduleColumnId = 209, strFormCode = 'AR D', strScheduleCode = '6', strType = 'LP', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426692
	UNION ALL SELECT intScheduleColumnId = 210, strFormCode = 'AR D', strScheduleCode = '6', strType = 'LP', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426693
	UNION ALL SELECT intScheduleColumnId = 211, strFormCode = 'AR D', strScheduleCode = '6', strType = 'LP', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426694
	UNION ALL SELECT intScheduleColumnId = 212, strFormCode = 'AR D', strScheduleCode = '6', strType = 'LP', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426695
	UNION ALL SELECT intScheduleColumnId = 213, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426696
	UNION ALL SELECT intScheduleColumnId = 214, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426697
	UNION ALL SELECT intScheduleColumnId = 215, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426698
	UNION ALL SELECT intScheduleColumnId = 216, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426699
	UNION ALL SELECT intScheduleColumnId = 217, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426700
	UNION ALL SELECT intScheduleColumnId = 218, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426701
	UNION ALL SELECT intScheduleColumnId = 219, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426702
	UNION ALL SELECT intScheduleColumnId = 220, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426703
	UNION ALL SELECT intScheduleColumnId = 221, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Gasoline', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426704
	UNION ALL SELECT intScheduleColumnId = 222, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426705
	UNION ALL SELECT intScheduleColumnId = 223, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Dyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426706
	UNION ALL SELECT intScheduleColumnId = 224, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Dyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426707
	UNION ALL SELECT intScheduleColumnId = 225, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Dyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426708
	UNION ALL SELECT intScheduleColumnId = 226, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Dyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426709
	UNION ALL SELECT intScheduleColumnId = 227, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Dyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426710
	UNION ALL SELECT intScheduleColumnId = 228, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Dyed', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426711
	UNION ALL SELECT intScheduleColumnId = 229, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Dyed', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426712
	UNION ALL SELECT intScheduleColumnId = 230, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Dyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426713
	UNION ALL SELECT intScheduleColumnId = 231, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Dyed', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426714
	UNION ALL SELECT intScheduleColumnId = 232, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Dyed', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426715
	UNION ALL SELECT intScheduleColumnId = 233, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Undyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426716
	UNION ALL SELECT intScheduleColumnId = 234, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Undyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426717
	UNION ALL SELECT intScheduleColumnId = 235, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Undyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426718
	UNION ALL SELECT intScheduleColumnId = 236, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Undyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426719
	UNION ALL SELECT intScheduleColumnId = 237, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Undyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426720
	UNION ALL SELECT intScheduleColumnId = 238, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Undyed', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426721
	UNION ALL SELECT intScheduleColumnId = 239, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Undyed', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426722
	UNION ALL SELECT intScheduleColumnId = 240, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Undyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426723
	UNION ALL SELECT intScheduleColumnId = 241, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Undyed', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426724
	UNION ALL SELECT intScheduleColumnId = 242, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Undyed', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426725
	UNION ALL SELECT intScheduleColumnId = 243, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'LP', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426726
	UNION ALL SELECT intScheduleColumnId = 244, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'LP', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426727
	UNION ALL SELECT intScheduleColumnId = 245, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'LP', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426728
	UNION ALL SELECT intScheduleColumnId = 246, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'LP', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426729
	UNION ALL SELECT intScheduleColumnId = 247, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'LP', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426730
	UNION ALL SELECT intScheduleColumnId = 248, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'LP', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426731
	UNION ALL SELECT intScheduleColumnId = 249, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'LP', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426732
	UNION ALL SELECT intScheduleColumnId = 250, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'LP', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426733
	UNION ALL SELECT intScheduleColumnId = 251, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'LP', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426734
	UNION ALL SELECT intScheduleColumnId = 252, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'LP', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426735
	UNION ALL SELECT intScheduleColumnId = 253, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426736
	UNION ALL SELECT intScheduleColumnId = 254, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426737
	UNION ALL SELECT intScheduleColumnId = 255, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426738
	UNION ALL SELECT intScheduleColumnId = 256, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426739
	UNION ALL SELECT intScheduleColumnId = 257, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426740
	UNION ALL SELECT intScheduleColumnId = 258, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426741
	UNION ALL SELECT intScheduleColumnId = 259, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426742
	UNION ALL SELECT intScheduleColumnId = 260, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426743
	UNION ALL SELECT intScheduleColumnId = 261, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Gasoline', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426744
	UNION ALL SELECT intScheduleColumnId = 262, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426745
	UNION ALL SELECT intScheduleColumnId = 263, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Dyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426746
	UNION ALL SELECT intScheduleColumnId = 264, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Dyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426747
	UNION ALL SELECT intScheduleColumnId = 265, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Dyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426748
	UNION ALL SELECT intScheduleColumnId = 266, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Dyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426749
	UNION ALL SELECT intScheduleColumnId = 267, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Dyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426750
	UNION ALL SELECT intScheduleColumnId = 268, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Dyed', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426751
	UNION ALL SELECT intScheduleColumnId = 269, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Dyed', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426752
	UNION ALL SELECT intScheduleColumnId = 270, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Dyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426753
	UNION ALL SELECT intScheduleColumnId = 271, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Dyed', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426754
	UNION ALL SELECT intScheduleColumnId = 272, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Dyed', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426755
	UNION ALL SELECT intScheduleColumnId = 273, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Undyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426756
	UNION ALL SELECT intScheduleColumnId = 274, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Undyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426757
	UNION ALL SELECT intScheduleColumnId = 275, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Undyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426758
	UNION ALL SELECT intScheduleColumnId = 276, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Undyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426759
	UNION ALL SELECT intScheduleColumnId = 277, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Undyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426760
	UNION ALL SELECT intScheduleColumnId = 278, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Undyed', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426761
	UNION ALL SELECT intScheduleColumnId = 279, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Undyed', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426762
	UNION ALL SELECT intScheduleColumnId = 280, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Undyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426763
	UNION ALL SELECT intScheduleColumnId = 281, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Undyed', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426764
	UNION ALL SELECT intScheduleColumnId = 282, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Undyed', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426765
	UNION ALL SELECT intScheduleColumnId = 283, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'LP', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426766
	UNION ALL SELECT intScheduleColumnId = 284, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'LP', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426767
	UNION ALL SELECT intScheduleColumnId = 285, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'LP', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426768
	UNION ALL SELECT intScheduleColumnId = 286, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'LP', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426769
	UNION ALL SELECT intScheduleColumnId = 287, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'LP', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426770
	UNION ALL SELECT intScheduleColumnId = 288, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'LP', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426771
	UNION ALL SELECT intScheduleColumnId = 289, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'LP', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426772
	UNION ALL SELECT intScheduleColumnId = 290, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'LP', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426773
	UNION ALL SELECT intScheduleColumnId = 291, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'LP', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426774
	UNION ALL SELECT intScheduleColumnId = 292, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'LP', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426775
	UNION ALL SELECT intScheduleColumnId = 293, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426776
	UNION ALL SELECT intScheduleColumnId = 294, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426777
	UNION ALL SELECT intScheduleColumnId = 295, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426778
	UNION ALL SELECT intScheduleColumnId = 296, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426779
	UNION ALL SELECT intScheduleColumnId = 297, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426780
	UNION ALL SELECT intScheduleColumnId = 298, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426781
	UNION ALL SELECT intScheduleColumnId = 299, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426782
	UNION ALL SELECT intScheduleColumnId = 300, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426783
	UNION ALL SELECT intScheduleColumnId = 301, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Gasoline', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426784
	UNION ALL SELECT intScheduleColumnId = 302, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426785
	UNION ALL SELECT intScheduleColumnId = 303, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Dyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426786
	UNION ALL SELECT intScheduleColumnId = 304, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Dyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426787
	UNION ALL SELECT intScheduleColumnId = 305, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Dyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426788
	UNION ALL SELECT intScheduleColumnId = 306, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Dyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426789
	UNION ALL SELECT intScheduleColumnId = 307, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Dyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426790
	UNION ALL SELECT intScheduleColumnId = 308, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Dyed', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426791
	UNION ALL SELECT intScheduleColumnId = 309, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Dyed', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426792
	UNION ALL SELECT intScheduleColumnId = 310, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Dyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426793
	UNION ALL SELECT intScheduleColumnId = 311, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Dyed', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426794
	UNION ALL SELECT intScheduleColumnId = 312, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Dyed', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426795
	UNION ALL SELECT intScheduleColumnId = 313, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Undyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426796
	UNION ALL SELECT intScheduleColumnId = 314, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Undyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426797
	UNION ALL SELECT intScheduleColumnId = 315, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Undyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426798
	UNION ALL SELECT intScheduleColumnId = 316, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Undyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426799
	UNION ALL SELECT intScheduleColumnId = 317, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Undyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426800
	UNION ALL SELECT intScheduleColumnId = 318, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Undyed', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426801
	UNION ALL SELECT intScheduleColumnId = 319, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Undyed', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426802
	UNION ALL SELECT intScheduleColumnId = 320, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Undyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426803
	UNION ALL SELECT intScheduleColumnId = 321, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Undyed', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426804
	UNION ALL SELECT intScheduleColumnId = 322, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Undyed', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426805
	UNION ALL SELECT intScheduleColumnId = 323, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'LP', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426806
	UNION ALL SELECT intScheduleColumnId = 324, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'LP', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426807
	UNION ALL SELECT intScheduleColumnId = 325, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'LP', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426808
	UNION ALL SELECT intScheduleColumnId = 326, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'LP', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426809
	UNION ALL SELECT intScheduleColumnId = 327, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'LP', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426810
	UNION ALL SELECT intScheduleColumnId = 328, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'LP', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426811
	UNION ALL SELECT intScheduleColumnId = 329, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'LP', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426812
	UNION ALL SELECT intScheduleColumnId = 330, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'LP', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426813
	UNION ALL SELECT intScheduleColumnId = 331, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'LP', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426814
	UNION ALL SELECT intScheduleColumnId = 332, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'LP', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426815
	UNION ALL SELECT intScheduleColumnId = 333, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426816
	UNION ALL SELECT intScheduleColumnId = 334, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426817
	UNION ALL SELECT intScheduleColumnId = 335, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426818
	UNION ALL SELECT intScheduleColumnId = 336, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426819
	UNION ALL SELECT intScheduleColumnId = 337, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426820
	UNION ALL SELECT intScheduleColumnId = 338, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426821
	UNION ALL SELECT intScheduleColumnId = 339, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426822
	UNION ALL SELECT intScheduleColumnId = 340, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426823
	UNION ALL SELECT intScheduleColumnId = 341, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426824
	UNION ALL SELECT intScheduleColumnId = 342, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426825
	UNION ALL SELECT intScheduleColumnId = 343, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Dyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426826
	UNION ALL SELECT intScheduleColumnId = 344, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Dyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426827
	UNION ALL SELECT intScheduleColumnId = 345, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Dyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426828
	UNION ALL SELECT intScheduleColumnId = 346, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Dyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426829
	UNION ALL SELECT intScheduleColumnId = 347, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Dyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426830
	UNION ALL SELECT intScheduleColumnId = 348, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Dyed', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426831
	UNION ALL SELECT intScheduleColumnId = 349, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Dyed', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426832
	UNION ALL SELECT intScheduleColumnId = 350, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Dyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426833
	UNION ALL SELECT intScheduleColumnId = 351, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Dyed', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426834
	UNION ALL SELECT intScheduleColumnId = 352, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Dyed', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426835
	UNION ALL SELECT intScheduleColumnId = 353, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Undyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426836
	UNION ALL SELECT intScheduleColumnId = 354, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Undyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426837
	UNION ALL SELECT intScheduleColumnId = 355, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Undyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426838
	UNION ALL SELECT intScheduleColumnId = 356, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Undyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426839
	UNION ALL SELECT intScheduleColumnId = 357, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Undyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426840
	UNION ALL SELECT intScheduleColumnId = 358, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Undyed', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426841
	UNION ALL SELECT intScheduleColumnId = 359, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Undyed', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426842
	UNION ALL SELECT intScheduleColumnId = 360, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Undyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426843
	UNION ALL SELECT intScheduleColumnId = 361, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Undyed', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426844
	UNION ALL SELECT intScheduleColumnId = 362, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Undyed', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426845
	UNION ALL SELECT intScheduleColumnId = 363, strFormCode = 'AR D', strScheduleCode = '8', strType = 'LP', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426846
	UNION ALL SELECT intScheduleColumnId = 364, strFormCode = 'AR D', strScheduleCode = '8', strType = 'LP', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426847
	UNION ALL SELECT intScheduleColumnId = 365, strFormCode = 'AR D', strScheduleCode = '8', strType = 'LP', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426848
	UNION ALL SELECT intScheduleColumnId = 366, strFormCode = 'AR D', strScheduleCode = '8', strType = 'LP', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426849
	UNION ALL SELECT intScheduleColumnId = 367, strFormCode = 'AR D', strScheduleCode = '8', strType = 'LP', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426850
	UNION ALL SELECT intScheduleColumnId = 368, strFormCode = 'AR D', strScheduleCode = '8', strType = 'LP', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426851
	UNION ALL SELECT intScheduleColumnId = 369, strFormCode = 'AR D', strScheduleCode = '8', strType = 'LP', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426852
	UNION ALL SELECT intScheduleColumnId = 370, strFormCode = 'AR D', strScheduleCode = '8', strType = 'LP', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426853
	UNION ALL SELECT intScheduleColumnId = 371, strFormCode = 'AR D', strScheduleCode = '8', strType = 'LP', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426854
	UNION ALL SELECT intScheduleColumnId = 372, strFormCode = 'AR D', strScheduleCode = '8', strType = 'LP', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426855
	UNION ALL SELECT intScheduleColumnId = 373, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426856
	UNION ALL SELECT intScheduleColumnId = 374, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426857
	UNION ALL SELECT intScheduleColumnId = 375, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426858
	UNION ALL SELECT intScheduleColumnId = 376, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426859
	UNION ALL SELECT intScheduleColumnId = 377, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426860
	UNION ALL SELECT intScheduleColumnId = 378, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426861
	UNION ALL SELECT intScheduleColumnId = 379, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426862
	UNION ALL SELECT intScheduleColumnId = 380, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426863
	UNION ALL SELECT intScheduleColumnId = 381, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Gasoline', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426864
	UNION ALL SELECT intScheduleColumnId = 382, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426865
	UNION ALL SELECT intScheduleColumnId = 383, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Dyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426866
	UNION ALL SELECT intScheduleColumnId = 384, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Dyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426867
	UNION ALL SELECT intScheduleColumnId = 385, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Dyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426868
	UNION ALL SELECT intScheduleColumnId = 386, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Dyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426869
	UNION ALL SELECT intScheduleColumnId = 387, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Dyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426870
	UNION ALL SELECT intScheduleColumnId = 388, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Dyed', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426871
	UNION ALL SELECT intScheduleColumnId = 389, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Dyed', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426872
	UNION ALL SELECT intScheduleColumnId = 390, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Dyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426873
	UNION ALL SELECT intScheduleColumnId = 391, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Dyed', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426874
	UNION ALL SELECT intScheduleColumnId = 392, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Dyed', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426875
	UNION ALL SELECT intScheduleColumnId = 393, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Undyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426876
	UNION ALL SELECT intScheduleColumnId = 394, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Undyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426877
	UNION ALL SELECT intScheduleColumnId = 395, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Undyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426878
	UNION ALL SELECT intScheduleColumnId = 396, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Undyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426879
	UNION ALL SELECT intScheduleColumnId = 397, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Undyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426880
	UNION ALL SELECT intScheduleColumnId = 398, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Undyed', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426881
	UNION ALL SELECT intScheduleColumnId = 399, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Undyed', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426882
	UNION ALL SELECT intScheduleColumnId = 400, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Undyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426883
	UNION ALL SELECT intScheduleColumnId = 401, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Undyed', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426884
	UNION ALL SELECT intScheduleColumnId = 402, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Undyed', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426885
	UNION ALL SELECT intScheduleColumnId = 403, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'LP', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426886
	UNION ALL SELECT intScheduleColumnId = 404, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'LP', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426887
	UNION ALL SELECT intScheduleColumnId = 405, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'LP', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426888
	UNION ALL SELECT intScheduleColumnId = 406, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'LP', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426889
	UNION ALL SELECT intScheduleColumnId = 407, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'LP', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426890
	UNION ALL SELECT intScheduleColumnId = 408, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'LP', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426891
	UNION ALL SELECT intScheduleColumnId = 409, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'LP', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426892
	UNION ALL SELECT intScheduleColumnId = 410, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'LP', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426893
	UNION ALL SELECT intScheduleColumnId = 411, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'LP', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426894
	UNION ALL SELECT intScheduleColumnId = 412, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'LP', strColumn = 'dblNet', strCaption = 'Net  Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 426895

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
	SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Dyed', ysnStatus = 1, intFrequency = 1, intMasterId = 43234
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Diesel Undyed', ysnStatus = 1, intFrequency = 1, intMasterId = 43235
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 43233
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '10A', strType = 'LP', ysnStatus = 1, intFrequency = 1, intMasterId = 43236
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Dyed', ysnStatus = 1, intFrequency = 1, intMasterId = 43210
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Diesel Undyed', ysnStatus = 1, intFrequency = 1, intMasterId = 43211
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 43209
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '5J', strType = 'LP', ysnStatus = 1, intFrequency = 1, intMasterId = 43212
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Dyed', ysnStatus = 1, intFrequency = 1, intMasterId = 43214
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Diesel Undyed', ysnStatus = 1, intFrequency = 1, intMasterId = 43215
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '6', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 43213
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '6', strType = 'LP', ysnStatus = 1, intFrequency = 1, intMasterId = 43216
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Dyed', ysnStatus = 1, intFrequency = 1, intMasterId = 43218
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Diesel Undyed', ysnStatus = 1, intFrequency = 1, intMasterId = 43219
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 43217
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '7IL', strType = 'LP', ysnStatus = 1, intFrequency = 1, intMasterId = 43220
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Dyed', ysnStatus = 1, intFrequency = 1, intMasterId = 43222
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Diesel Undyed', ysnStatus = 1, intFrequency = 1, intMasterId = 43223
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 43221
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '7MO', strType = 'LP', ysnStatus = 1, intFrequency = 1, intMasterId = 43224
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Dyed', ysnStatus = 1, intFrequency = 1, intMasterId = 43226
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Diesel Undyed', ysnStatus = 1, intFrequency = 1, intMasterId = 43227
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 43225
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '7OK', strType = 'LP', ysnStatus = 1, intFrequency = 1, intMasterId = 43228
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Dyed', ysnStatus = 1, intFrequency = 1, intMasterId = 43230
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Diesel Undyed', ysnStatus = 1, intFrequency = 1, intMasterId = 43231
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '8', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 43229
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR D', strScheduleCode = '8', strType = 'LP', ysnStatus = 1, intFrequency = 1, intMasterId = 43232
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR EDI', strScheduleCode = '', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 43237
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Dyed', ysnStatus = 1, intFrequency = 1, intMasterId = 43198
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Diesel Undyed', ysnStatus = 1, intFrequency = 1, intMasterId = 43199
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR R', strScheduleCode = '1', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 43197
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR R', strScheduleCode = '1', strType = 'LP', ysnStatus = 1, intFrequency = 1, intMasterId = 43200
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Dyed', ysnStatus = 1, intFrequency = 1, intMasterId = 43202
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Diesel Undyed', ysnStatus = 1, intFrequency = 1, intMasterId = 43203
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR R', strScheduleCode = '2', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 43201
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR R', strScheduleCode = '2', strType = 'LP', ysnStatus = 1, intFrequency = 1, intMasterId = 43204
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Dyed', ysnStatus = 1, intFrequency = 1, intMasterId = 43206
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Diesel Undyed', ysnStatus = 1, intFrequency = 1, intMasterId = 43207
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR R', strScheduleCode = '3', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 43205
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'AR R', strScheduleCode = '3', strType = 'LP', ysnStatus = 1, intFrequency = 1, intMasterId = 43208

	EXEC uspTFUpgradeFilingPackets @TaxAuthorityCode = @TaxAuthorityCode, @FilingPackets = @FilingPackets

END

GO