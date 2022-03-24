IF EXISTS(SELECT TOP 1 intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'DC' AND ysnFilingForThisTA = 1)
BEGIN
	PRINT ('Deploying District of Columbia Tax Forms')
END
GO

DECLARE @TaxAuthorityCode NVARCHAR(10) = 'DC'
	, @TaxAuthorityId INT

SELECT @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = @TaxAuthorityCode AND ysnFilingForThisTA = 1

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
	SELECT intProductCodeId = 0, strProductCode = '065', strDescription = 'Gasoline', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 5200001
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '228', strDescription = 'Diesel', strProductCodeGroup = 'Diesel', strNote = NULL, intMasterId = 5200002

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
	SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '2_P', strScheduleName = 'Receipts at Marketing Locations in DC from Sources outside DC, Tax Paid', strType = 'Gasoline', strNote = '', strTransactionType = 'Inventory', intSort = 10,strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 5200001,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '2_P', strScheduleName = 'Receipts at Marketing Locations in DC from Sources outside DC, Tax Paid', strType = 'Diesel', strNote = '', strTransactionType = 'Inventory', intSort = 20,strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 5200002,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '2_U', strScheduleName = 'Receipts at Marketing Locations in DC from Sources outside DC, Tax Unpaid', strType = 'Gasoline', strNote = '', strTransactionType = 'Inventory', intSort = 30,strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 5200003,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '2_U', strScheduleName = 'Receipts at Marketing Locations in DC from Sources outside DC, Tax Unpaid', strType = 'Diesel', strNote = '', strTransactionType = 'Inventory', intSort = 40,strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 5200004,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '3_P', strScheduleName = 'Receipts at Marketing Locations in DC from Sources within DC, Tax Paid', strType = 'Gasoline', strNote = '', strTransactionType = 'Inventory', intSort = 50,strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 5200005,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '3_P', strScheduleName = 'Receipts at Marketing Locations in DC from Sources within DC, Tax Paid', strType = 'Diesel', strNote = '', strTransactionType = 'Inventory', intSort = 60,strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 5200006,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '3_U', strScheduleName = 'Receipts at Marketing Locations in DC from Sources within DC, Tax Unpaid', strType = 'Gasoline', strNote = '', strTransactionType = 'Inventory', intSort = 70,strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 5200007,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '3_U', strScheduleName = 'Receipts at Marketing Locations in DC from Sources within DC, Tax Unpaid', strType = 'Diesel', strNote = '', strTransactionType = 'Inventory', intSort = 80,strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 5200008,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '4_P', strScheduleName = 'Direct Delivery to Other States, Tax Paid', strType = 'Gasoline', strNote = '', strTransactionType = 'Inventory', intSort = 90,strStoredProcedure = 'uspTFGetTransporterInventoryTax', intMasterId = 5200009,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '4_P', strScheduleName = 'Direct Delivery to Other States, Tax Paid', strType = 'Diesel', strNote = '', strTransactionType = 'Inventory', intSort = 100,strStoredProcedure = 'uspTFGetTransporterInventoryTax', intMasterId = 5200010,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '4_U', strScheduleName = 'Direct Delivery to Other States, Tax Unpaid', strType = 'Gasoline', strNote = '', strTransactionType = 'Inventory', intSort = 110,strStoredProcedure = 'uspTFGetTransporterInventoryTax', intMasterId = 5200011,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '4_U', strScheduleName = 'Direct Delivery to Other States, Tax Unpaid', strType = 'Diesel', strNote = '', strTransactionType = 'Inventory', intSort = 120,strStoredProcedure = 'uspTFGetTransporterInventoryTax', intMasterId = 5200012,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '5_P', strScheduleName = 'Direct Delivery to Customers in DC, Tax Paid', strType = 'Gasoline', strNote = '', strTransactionType = 'Inventory', intSort = 130,strStoredProcedure = 'uspTFGetTransporterInventoryTax', intMasterId = 5200013,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '5_P', strScheduleName = 'Direct Delivery to Customers in DC, Tax Paid', strType = 'Diesel', strNote = '', strTransactionType = 'Inventory', intSort = 140,strStoredProcedure = 'uspTFGetTransporterInventoryTax', intMasterId = 5200014,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '5_U', strScheduleName = 'Direct Delivery to Customers in DC, Tax Unpaid', strType = 'Gasoline', strNote = '', strTransactionType = 'Inventory', intSort = 150,strStoredProcedure = 'uspTFGetTransporterInventoryTax', intMasterId = 5200015,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '5_U', strScheduleName = 'Direct Delivery to Customers in DC, Tax Unpaid', strType = 'Diesel', strNote = '', strTransactionType = 'Inventory', intSort = 160,strStoredProcedure = 'uspTFGetTransporterInventoryTax', intMasterId = 5200016,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '6', strScheduleName = 'Other Receipts', strType = 'Gasoline', strNote = '', strTransactionType = 'Inventory', intSort = 170,strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 5200017,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '6', strScheduleName = 'Other Receipts', strType = 'Diesel', strNote = '', strTransactionType = 'Inventory', intSort = 180,strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 5200018,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '10', strScheduleName = 'Sales and Transfers out of DC', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 190,strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 5200019,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '10', strScheduleName = 'Sales and Transfers out of DC', strType = 'Diesel', strNote = '', strTransactionType = 'Invoice', intSort = 200,strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 5200020,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '11', strScheduleName = 'Sales to Licensed Importers in DC', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 210,strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 5200021,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '11', strScheduleName = 'Sales to Licensed Importers in DC', strType = 'Diesel', strNote = '', strTransactionType = 'Invoice', intSort = 220,strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 5200022,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '12_US', strScheduleName = 'Sales to US Government', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 230,strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 5200023,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '12_US', strScheduleName = 'Sales to US Government', strType = 'Diesel', strNote = '', strTransactionType = 'Invoice', intSort = 240,strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 5200024,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '12_DC', strScheduleName = 'Sales to DC Government', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 250,strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 5200025,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '12_DC', strScheduleName = 'Sales to DC Government', strType = 'Diesel', strNote = '', strTransactionType = 'Invoice', intSort = 260,strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 5200026,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '13', strScheduleName = 'Other Non-taxable Distributions', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 270,strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 5200027,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '13', strScheduleName = 'Other Non-taxable Distributions', strType = 'Diesel', strNote = '', strTransactionType = 'Invoice', intSort = 280,strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 5200028,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '22_P', strScheduleName = 'Sales and Use of Diesel Fuel, Fuel Oil, or Motor Vehicle Fuel Other than Gasoline, Taxable', strType = 'Diesel', strNote = '', strTransactionType = 'Invoice', intSort = 290,strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 5200029,  intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'FR-400M', strFormName = 'DC Motor Fuel Tax Return', strScheduleCode = '22_U', strScheduleName = 'Sales and Use of Diesel Fuel, Fuel Oil, or Motor Vehicle Fuel Other than Gasoline, Tax Exempt', strType = 'Diesel', strNote = '', strTransactionType = 'Invoice', intSort = 300,strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 5200030,  intComponentTypeId = 1

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
	SELECT intTaxCriteriaId = 0, strTaxCategory = 'DC Excise Gasoline', strState = 'DC', strFormCode = 'FR-400M',  strScheduleCode = '2_P', strType = 'Gasoline', strCriteria = '<> 0', intMasterId =  5200001
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'DC Excise Diesel', strState = 'DC', strFormCode = 'FR-400M',  strScheduleCode = '2_P', strType = 'Diesel', strCriteria = '<> 0', intMasterId =  5200002
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'DC Excise Gasoline', strState = 'DC', strFormCode = 'FR-400M',  strScheduleCode = '2_U', strType = 'Gasoline', strCriteria = '= 0', intMasterId =  5200003
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'DC Excise Diesel', strState = 'DC', strFormCode = 'FR-400M',  strScheduleCode = '2_U', strType = 'Diesel', strCriteria = '= 0', intMasterId =  5200004
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'DC Excise Gasoline', strState = 'DC', strFormCode = 'FR-400M',  strScheduleCode = '3_P', strType = 'Gasoline', strCriteria = '<> 0', intMasterId =  5200005
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'DC Excise Diesel', strState = 'DC', strFormCode = 'FR-400M',  strScheduleCode = '3_P', strType = 'Diesel', strCriteria = '<> 0', intMasterId =  5200006
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'DC Excise Gasoline', strState = 'DC', strFormCode = 'FR-400M',  strScheduleCode = '3_U', strType = 'Gasoline', strCriteria = '= 0', intMasterId =  5200007
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'DC Excise Diesel', strState = 'DC', strFormCode = 'FR-400M',  strScheduleCode = '3_U', strType = 'Diesel', strCriteria = '= 0', intMasterId =  5200008
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'DC Excise Gasoline', strState = 'DC', strFormCode = 'FR-400M',  strScheduleCode = '4_P', strType = 'Gasoline', strCriteria = '<> 0', intMasterId =  5200009
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'DC Excise Diesel', strState = 'DC', strFormCode = 'FR-400M',  strScheduleCode = '4_P', strType = 'Diesel', strCriteria = '<> 0', intMasterId =  5200010
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'DC Excise Gasoline', strState = 'DC', strFormCode = 'FR-400M',  strScheduleCode = '4_U', strType = 'Gasoline', strCriteria = '= 0', intMasterId =  5200011
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'DC Excise Diesel', strState = 'DC', strFormCode = 'FR-400M',  strScheduleCode = '4_U', strType = 'Diesel', strCriteria = '= 0', intMasterId =  5200012
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'DC Excise Gasoline', strState = 'DC', strFormCode = 'FR-400M',  strScheduleCode = '5_P', strType = 'Gasoline', strCriteria = '<> 0', intMasterId =  5200013
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'DC Excise Diesel', strState = 'DC', strFormCode = 'FR-400M',  strScheduleCode = '5_P', strType = 'Diesel', strCriteria = '<> 0', intMasterId =  5200014
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'DC Excise Gasoline', strState = 'DC', strFormCode = 'FR-400M',  strScheduleCode = '5_U', strType = 'Gasoline', strCriteria = '= 0', intMasterId =  5200015
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'DC Excise Diesel', strState = 'DC', strFormCode = 'FR-400M',  strScheduleCode = '5_U', strType = 'Diesel', strCriteria = '= 0', intMasterId =  5200016
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'DC Excise Gasoline', strState = 'DC', strFormCode = 'FR-400M',  strScheduleCode = '12_US', strType = 'Gasoline', strCriteria = '= 0', intMasterId =  5200017
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'DC Excise Diesel', strState = 'DC', strFormCode = 'FR-400M',  strScheduleCode = '12_US', strType = 'Diesel', strCriteria = '= 0', intMasterId =  5200018
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'DC Excise Gasoline', strState = 'DC', strFormCode = 'FR-400M',  strScheduleCode = '12_DC', strType = 'Gasoline', strCriteria = '= 0', intMasterId =  5200019
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'DC Excise Diesel', strState = 'DC', strFormCode = 'FR-400M',  strScheduleCode = '12_DC', strType = 'Diesel', strCriteria = '= 0', intMasterId =  5200020
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'DC Excise Gasoline', strState = 'DC', strFormCode = 'FR-400M',  strScheduleCode = '13', strType = 'Gasoline', strCriteria = '= 0', intMasterId =  5200021
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'DC Excise Diesel', strState = 'DC', strFormCode = 'FR-400M',  strScheduleCode = '13', strType = 'Diesel', strCriteria = '= 0', intMasterId =  5200022
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'DC Excise Diesel', strState = 'DC', strFormCode = 'FR-400M',  strScheduleCode = '22_P', strType = 'Diesel', strCriteria = '<> 0', intMasterId =  5200023
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'DC Excise Diesel', strState = 'DC', strFormCode = 'FR-400M',  strScheduleCode = '22_U', strType = 'Diesel', strCriteria = '= 0', intMasterId =  5200024

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
	DECLARE @ValidProductCodes AS TFValidProductCodes

	INSERT INTO @ValidProductCodes(
		intValidProductCodeId
		, strProductCode
		, strFormCode
		, strScheduleCode
		, strType
		, intMasterId
	)
	SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Gasoline', intMasterId = 5200001
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Diesel', intMasterId = 5200002
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Gasoline', intMasterId = 5200003
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Diesel', intMasterId = 5200004
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Gasoline', intMasterId = 5200005
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Diesel', intMasterId = 5200006
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Gasoline', intMasterId = 5200007
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Diesel', intMasterId = 5200008
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Gasoline', intMasterId = 5200009
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Diesel', intMasterId = 5200010
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Gasoline', intMasterId = 5200011
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Diesel', intMasterId = 5200012
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Gasoline', intMasterId = 5200013
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Diesel', intMasterId = 5200014
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Gasoline', intMasterId = 5200015
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Diesel', intMasterId = 5200016
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'FR-400M', strScheduleCode = '6', strType = 'Gasoline', intMasterId = 5200017
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'FR-400M', strScheduleCode = '6', strType = 'Diesel', intMasterId = 5200018
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Gasoline', intMasterId = 5200019
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Diesel', intMasterId = 5200020
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Gasoline', intMasterId = 5200021
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Diesel', intMasterId = 5200022
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'FR-400M', strScheduleCode = '12_US', strType = 'Gasoline', intMasterId = 5200023
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'FR-400M', strScheduleCode = '12_US', strType = 'Diesel', intMasterId = 5200024
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'FR-400M', strScheduleCode = '12_DC', strType = 'Gasoline', intMasterId = 5200025
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'FR-400M', strScheduleCode = '12_DC', strType = 'Diesel', intMasterId = 5200026
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'FR-400M', strScheduleCode = '13', strType = 'Gasoline', intMasterId = 5200027
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'FR-400M', strScheduleCode = '13', strType = 'Diesel', intMasterId = 5200028
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'FR-400M', strScheduleCode = '22_P', strType = 'Diesel', intMasterId = 5200029
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'FR-400M', strScheduleCode = '22_U', strType = 'Diesel', intMasterId = 5200030

	EXEC uspTFUpgradeValidProductCodes @TaxAuthorityCode = @TaxAuthorityCode, @ValidProductCodes = @ValidProductCodes


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
	DECLARE @ValidOriginStates AS TFValidOriginStates

	INSERT INTO @ValidOriginStates(
		intValidOriginStateId
		, strFormCode
		, strScheduleCode
		, strType
		, strState
		, strStatus
		, intMasterId
	)
	SELECT intValidOriginStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Gasoline', strState = 'DC', strStatus = 'Include', intMasterId = 5200001
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Diesel', strState = 'DC', strStatus = 'Include', intMasterId = 5200002
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Gasoline', strState = 'DC', strStatus = 'Include', intMasterId = 5200003
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Diesel', strState = 'DC', strStatus = 'Include', intMasterId = 5200004
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Gasoline', strState = 'DC', strStatus = 'Include', intMasterId = 5200005
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Diesel', strState = 'DC', strStatus = 'Include', intMasterId = 5200006
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Gasoline', strState = 'DC', strStatus = 'Exclude', intMasterId = 5200007
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Diesel', strState = 'DC', strStatus = 'Exclude', intMasterId = 5200008
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Gasoline', strState = 'DC', strStatus = 'Exclude', intMasterId = 5200009
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Diesel', strState = 'DC', strStatus = 'Exclude', intMasterId = 5200010

	EXEC uspTFUpgradeValidOriginStates @TaxAuthorityCode = @TaxAuthorityCode, @ValidOriginStates = @ValidOriginStates
	

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
	DECLARE @ValidDestinationStates AS TFValidDestinationStates

	INSERT INTO @ValidDestinationStates(
		intValidDestinationStateId
		, strFormCode
		, strScheduleCode
		, strType
		, strState
		, strStatus
		, intMasterId
	)
	SELECT intValidDestinationStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Gasoline', strState = 'DC', strStatus = 'Include', intMasterId = 5200001
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Diesel', strState = 'DC', strStatus = 'Include', intMasterId = 5200002
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Gasoline', strState = 'DC', strStatus = 'Include', intMasterId = 5200003
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Diesel', strState = 'DC', strStatus = 'Include', intMasterId = 5200004
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Gasoline', strState = 'DC', strStatus = 'Include', intMasterId = 5200005
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Diesel', strState = 'DC', strStatus = 'Include', intMasterId = 5200006
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Gasoline', strState = 'DC', strStatus = 'Include', intMasterId = 5200007
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Diesel', strState = 'DC', strStatus = 'Include', intMasterId = 5200008
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Gasoline', strState = 'DC', strStatus = 'Include', intMasterId = 5200009
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Diesel', strState = 'DC', strStatus = 'Include', intMasterId = 5200010
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Gasoline', strState = 'DC', strStatus = 'Include', intMasterId = 5200011
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Diesel', strState = 'DC', strStatus = 'Include', intMasterId = 5200012
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Gasoline', strState = 'DC', strStatus = 'Include', intMasterId = 5200013
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Diesel', strState = 'DC', strStatus = 'Include', intMasterId = 5200014
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Gasoline', strState = 'DC', strStatus = 'Exclude', intMasterId = 5200015
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Diesel', strState = 'DC', strStatus = 'Exclude', intMasterId = 5200016
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Gasoline', strState = 'DC', strStatus = 'Exclude', intMasterId = 5200017
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Diesel', strState = 'DC', strStatus = 'Exclude', intMasterId = 5200018
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Gasoline', strState = 'DC', strStatus = 'Exclude', intMasterId = 5200019
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Diesel', strState = 'DC', strStatus = 'Exclude', intMasterId = 5200020

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
	SELECT intScheduleColumnId = 1, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200001
	UNION ALL SELECT intScheduleColumnId = 2, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Gasoline', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200002
	UNION ALL SELECT intScheduleColumnId = 3, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200003
	UNION ALL SELECT intScheduleColumnId = 4, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Method of Delivery', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200004
	UNION ALL SELECT intScheduleColumnId = 5, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Gasoline', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200005
	UNION ALL SELECT intScheduleColumnId = 6, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Purchased From', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200006
	UNION ALL SELECT intScheduleColumnId = 7, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Purchased From FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200007
	UNION ALL SELECT intScheduleColumnId = 8, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Point of Shipment City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200008
	UNION ALL SELECT intScheduleColumnId = 9, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Point of Shipment State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200009
	UNION ALL SELECT intScheduleColumnId = 10, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Point of Delivery City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200010
	UNION ALL SELECT intScheduleColumnId = 11, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Point of Delivery State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200011
	UNION ALL SELECT intScheduleColumnId = 12, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Gasoline', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200012
	UNION ALL SELECT intScheduleColumnId = 13, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Diesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200013
	UNION ALL SELECT intScheduleColumnId = 14, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Diesel', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200014
	UNION ALL SELECT intScheduleColumnId = 15, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200015
	UNION ALL SELECT intScheduleColumnId = 16, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Diesel', strColumn = 'strTransportationMode', strCaption = 'Method of Delivery', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200016
	UNION ALL SELECT intScheduleColumnId = 17, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Diesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200017
	UNION ALL SELECT intScheduleColumnId = 18, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Diesel', strColumn = 'strVendorName', strCaption = 'Purchased From', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200018
	UNION ALL SELECT intScheduleColumnId = 19, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Purchased From FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200019
	UNION ALL SELECT intScheduleColumnId = 20, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Diesel', strColumn = 'strOriginCity', strCaption = 'Point of Shipment City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200020
	UNION ALL SELECT intScheduleColumnId = 21, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Diesel', strColumn = 'strOriginState', strCaption = 'Point of Shipment State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200021
	UNION ALL SELECT intScheduleColumnId = 22, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Diesel', strColumn = 'strDestinationCity', strCaption = 'Point of Delivery City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200022
	UNION ALL SELECT intScheduleColumnId = 23, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Diesel', strColumn = 'strDestinationState', strCaption = 'Point of Delivery State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200023
	UNION ALL SELECT intScheduleColumnId = 24, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Diesel', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200024
	UNION ALL SELECT intScheduleColumnId = 25, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200025
	UNION ALL SELECT intScheduleColumnId = 26, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Gasoline', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200026
	UNION ALL SELECT intScheduleColumnId = 27, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200027
	UNION ALL SELECT intScheduleColumnId = 28, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Method of Delivery', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200028
	UNION ALL SELECT intScheduleColumnId = 29, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Gasoline', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200029
	UNION ALL SELECT intScheduleColumnId = 30, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Purchased From', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200030
	UNION ALL SELECT intScheduleColumnId = 31, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Purchased From FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200031
	UNION ALL SELECT intScheduleColumnId = 32, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Point of Shipment City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200032
	UNION ALL SELECT intScheduleColumnId = 33, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Point of Shipment State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200033
	UNION ALL SELECT intScheduleColumnId = 34, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Point of Delivery City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200034
	UNION ALL SELECT intScheduleColumnId = 35, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Point of Delivery State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200035
	UNION ALL SELECT intScheduleColumnId = 36, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Gasoline', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200036
	UNION ALL SELECT intScheduleColumnId = 37, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Diesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200037
	UNION ALL SELECT intScheduleColumnId = 38, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Diesel', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200038
	UNION ALL SELECT intScheduleColumnId = 39, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200039
	UNION ALL SELECT intScheduleColumnId = 40, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Diesel', strColumn = 'strTransportationMode', strCaption = 'Method of Delivery', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200040
	UNION ALL SELECT intScheduleColumnId = 41, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Diesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200041
	UNION ALL SELECT intScheduleColumnId = 42, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Diesel', strColumn = 'strVendorName', strCaption = 'Purchased From', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200042
	UNION ALL SELECT intScheduleColumnId = 43, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Purchased From FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200043
	UNION ALL SELECT intScheduleColumnId = 44, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Diesel', strColumn = 'strOriginCity', strCaption = 'Point of Shipment City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200044
	UNION ALL SELECT intScheduleColumnId = 45, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Diesel', strColumn = 'strOriginState', strCaption = 'Point of Shipment State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200045
	UNION ALL SELECT intScheduleColumnId = 46, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Diesel', strColumn = 'strDestinationCity', strCaption = 'Point of Delivery City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200046
	UNION ALL SELECT intScheduleColumnId = 47, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Diesel', strColumn = 'strDestinationState', strCaption = 'Point of Delivery State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200047
	UNION ALL SELECT intScheduleColumnId = 48, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Diesel', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200048
	UNION ALL SELECT intScheduleColumnId = 49, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200049
	UNION ALL SELECT intScheduleColumnId = 50, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Gasoline', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200050
	UNION ALL SELECT intScheduleColumnId = 51, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200051
	UNION ALL SELECT intScheduleColumnId = 52, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Method of Delivery', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200052
	UNION ALL SELECT intScheduleColumnId = 53, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Gasoline', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200053
	UNION ALL SELECT intScheduleColumnId = 54, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Purchased From', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200054
	UNION ALL SELECT intScheduleColumnId = 55, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Purchased From FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200055
	UNION ALL SELECT intScheduleColumnId = 56, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Point of Shipment City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200056
	UNION ALL SELECT intScheduleColumnId = 57, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Point of Shipment State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200057
	UNION ALL SELECT intScheduleColumnId = 58, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Point of Delivery City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200058
	UNION ALL SELECT intScheduleColumnId = 59, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Point of Delivery State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200059
	UNION ALL SELECT intScheduleColumnId = 60, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Gasoline', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200060
	UNION ALL SELECT intScheduleColumnId = 61, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Diesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200061
	UNION ALL SELECT intScheduleColumnId = 62, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Diesel', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200062
	UNION ALL SELECT intScheduleColumnId = 63, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200063
	UNION ALL SELECT intScheduleColumnId = 64, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Diesel', strColumn = 'strTransportationMode', strCaption = 'Method of Delivery', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200064
	UNION ALL SELECT intScheduleColumnId = 65, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Diesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200065
	UNION ALL SELECT intScheduleColumnId = 66, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Diesel', strColumn = 'strVendorName', strCaption = 'Purchased From', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200066
	UNION ALL SELECT intScheduleColumnId = 67, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Purchased From FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200067
	UNION ALL SELECT intScheduleColumnId = 68, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Diesel', strColumn = 'strOriginCity', strCaption = 'Point of Shipment City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200068
	UNION ALL SELECT intScheduleColumnId = 69, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Diesel', strColumn = 'strOriginState', strCaption = 'Point of Shipment State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200069
	UNION ALL SELECT intScheduleColumnId = 70, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Diesel', strColumn = 'strDestinationCity', strCaption = 'Point of Delivery City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200070
	UNION ALL SELECT intScheduleColumnId = 71, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Diesel', strColumn = 'strDestinationState', strCaption = 'Point of Delivery State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200071
	UNION ALL SELECT intScheduleColumnId = 72, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Diesel', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200072
	UNION ALL SELECT intScheduleColumnId = 73, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200073
	UNION ALL SELECT intScheduleColumnId = 74, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Gasoline', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200074
	UNION ALL SELECT intScheduleColumnId = 75, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200075
	UNION ALL SELECT intScheduleColumnId = 76, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Method of Delivery', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200076
	UNION ALL SELECT intScheduleColumnId = 77, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Gasoline', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200077
	UNION ALL SELECT intScheduleColumnId = 78, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Purchased From', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200078
	UNION ALL SELECT intScheduleColumnId = 79, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Purchased From FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200079
	UNION ALL SELECT intScheduleColumnId = 80, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Point of Shipment City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200080
	UNION ALL SELECT intScheduleColumnId = 81, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Point of Shipment State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200081
	UNION ALL SELECT intScheduleColumnId = 82, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Point of Delivery City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200082
	UNION ALL SELECT intScheduleColumnId = 83, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Point of Delivery State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200083
	UNION ALL SELECT intScheduleColumnId = 84, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Gasoline', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200084
	UNION ALL SELECT intScheduleColumnId = 85, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Diesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200085
	UNION ALL SELECT intScheduleColumnId = 86, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Diesel', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200086
	UNION ALL SELECT intScheduleColumnId = 87, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200087
	UNION ALL SELECT intScheduleColumnId = 88, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Diesel', strColumn = 'strTransportationMode', strCaption = 'Method of Delivery', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200088
	UNION ALL SELECT intScheduleColumnId = 89, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Diesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200089
	UNION ALL SELECT intScheduleColumnId = 90, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Diesel', strColumn = 'strVendorName', strCaption = 'Purchased From', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200090
	UNION ALL SELECT intScheduleColumnId = 91, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Purchased From FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200091
	UNION ALL SELECT intScheduleColumnId = 92, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Diesel', strColumn = 'strOriginCity', strCaption = 'Point of Shipment City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200092
	UNION ALL SELECT intScheduleColumnId = 93, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Diesel', strColumn = 'strOriginState', strCaption = 'Point of Shipment State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200093
	UNION ALL SELECT intScheduleColumnId = 94, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Diesel', strColumn = 'strDestinationCity', strCaption = 'Point of Delivery City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200094
	UNION ALL SELECT intScheduleColumnId = 95, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Diesel', strColumn = 'strDestinationState', strCaption = 'Point of Delivery State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200095
	UNION ALL SELECT intScheduleColumnId = 96, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Diesel', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200096
	UNION ALL SELECT intScheduleColumnId = 97, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200097
	UNION ALL SELECT intScheduleColumnId = 98, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Gasoline', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200098
	UNION ALL SELECT intScheduleColumnId = 99, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200099
	UNION ALL SELECT intScheduleColumnId = 100, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Method of Delivery', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200100
	UNION ALL SELECT intScheduleColumnId = 101, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Gasoline', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200101
	UNION ALL SELECT intScheduleColumnId = 102, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Purchased From', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200102
	UNION ALL SELECT intScheduleColumnId = 103, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Purchased From FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200103
	UNION ALL SELECT intScheduleColumnId = 104, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Point of Shipment City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200104
	UNION ALL SELECT intScheduleColumnId = 105, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Point of Shipment State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200105
	UNION ALL SELECT intScheduleColumnId = 106, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200106
	UNION ALL SELECT intScheduleColumnId = 107, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Sold To FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200107
	UNION ALL SELECT intScheduleColumnId = 108, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Point of Delivery City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200108
	UNION ALL SELECT intScheduleColumnId = 109, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Point of Delivery State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200109
	UNION ALL SELECT intScheduleColumnId = 110, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Gasoline', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200110
	UNION ALL SELECT intScheduleColumnId = 111, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Diesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200111
	UNION ALL SELECT intScheduleColumnId = 112, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Diesel', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200112
	UNION ALL SELECT intScheduleColumnId = 113, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200113
	UNION ALL SELECT intScheduleColumnId = 114, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Diesel', strColumn = 'strTransportationMode', strCaption = 'Method of Delivery', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200114
	UNION ALL SELECT intScheduleColumnId = 115, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Diesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200115
	UNION ALL SELECT intScheduleColumnId = 116, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Diesel', strColumn = 'strVendorName', strCaption = 'Purchased From', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200116
	UNION ALL SELECT intScheduleColumnId = 117, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Purchased From FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200117
	UNION ALL SELECT intScheduleColumnId = 118, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Diesel', strColumn = 'strOriginCity', strCaption = 'Point of Shipment City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200118
	UNION ALL SELECT intScheduleColumnId = 119, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Diesel', strColumn = 'strOriginState', strCaption = 'Point of Shipment State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200119
	UNION ALL SELECT intScheduleColumnId = 120, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Diesel', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200120
	UNION ALL SELECT intScheduleColumnId = 121, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Diesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Sold To FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200121
	UNION ALL SELECT intScheduleColumnId = 122, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Diesel', strColumn = 'strDestinationCity', strCaption = 'Point of Delivery City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200122
	UNION ALL SELECT intScheduleColumnId = 123, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Diesel', strColumn = 'strDestinationState', strCaption = 'Point of Delivery State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200123
	UNION ALL SELECT intScheduleColumnId = 124, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Diesel', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200124
	UNION ALL SELECT intScheduleColumnId = 125, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200125
	UNION ALL SELECT intScheduleColumnId = 126, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Gasoline', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200126
	UNION ALL SELECT intScheduleColumnId = 127, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200127
	UNION ALL SELECT intScheduleColumnId = 128, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Method of Delivery', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200128
	UNION ALL SELECT intScheduleColumnId = 129, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Gasoline', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200129
	UNION ALL SELECT intScheduleColumnId = 130, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Purchased From', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200130
	UNION ALL SELECT intScheduleColumnId = 131, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Purchased From FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200131
	UNION ALL SELECT intScheduleColumnId = 132, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Point of Shipment City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200132
	UNION ALL SELECT intScheduleColumnId = 133, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Point of Shipment State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200133
	UNION ALL SELECT intScheduleColumnId = 134, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200134
	UNION ALL SELECT intScheduleColumnId = 135, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Sold To FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200135
	UNION ALL SELECT intScheduleColumnId = 136, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Point of Delivery City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200136
	UNION ALL SELECT intScheduleColumnId = 137, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Point of Delivery State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200137
	UNION ALL SELECT intScheduleColumnId = 138, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Gasoline', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200138
	UNION ALL SELECT intScheduleColumnId = 139, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Diesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200139
	UNION ALL SELECT intScheduleColumnId = 140, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Diesel', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200140
	UNION ALL SELECT intScheduleColumnId = 141, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200141
	UNION ALL SELECT intScheduleColumnId = 142, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Diesel', strColumn = 'strTransportationMode', strCaption = 'Method of Delivery', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200142
	UNION ALL SELECT intScheduleColumnId = 143, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Diesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200143
	UNION ALL SELECT intScheduleColumnId = 144, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Diesel', strColumn = 'strVendorName', strCaption = 'Purchased From', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200144
	UNION ALL SELECT intScheduleColumnId = 145, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Purchased From FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200145
	UNION ALL SELECT intScheduleColumnId = 146, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Diesel', strColumn = 'strOriginCity', strCaption = 'Point of Shipment City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200146
	UNION ALL SELECT intScheduleColumnId = 147, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Diesel', strColumn = 'strOriginState', strCaption = 'Point of Shipment State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200147
	UNION ALL SELECT intScheduleColumnId = 148, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Diesel', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200148
	UNION ALL SELECT intScheduleColumnId = 149, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Diesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Sold To FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200149
	UNION ALL SELECT intScheduleColumnId = 150, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Diesel', strColumn = 'strDestinationCity', strCaption = 'Point of Delivery City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200150
	UNION ALL SELECT intScheduleColumnId = 151, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Diesel', strColumn = 'strDestinationState', strCaption = 'Point of Delivery State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200151
	UNION ALL SELECT intScheduleColumnId = 152, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Diesel', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200152
	UNION ALL SELECT intScheduleColumnId = 153, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200153
	UNION ALL SELECT intScheduleColumnId = 154, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Gasoline', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200154
	UNION ALL SELECT intScheduleColumnId = 155, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200155
	UNION ALL SELECT intScheduleColumnId = 156, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Method of Delivery', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200156
	UNION ALL SELECT intScheduleColumnId = 157, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Gasoline', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200157
	UNION ALL SELECT intScheduleColumnId = 158, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Purchased From', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200158
	UNION ALL SELECT intScheduleColumnId = 159, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Purchased From FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200159
	UNION ALL SELECT intScheduleColumnId = 160, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Point of Shipment City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200160
	UNION ALL SELECT intScheduleColumnId = 161, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Point of Shipment State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200161
	UNION ALL SELECT intScheduleColumnId = 162, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200162
	UNION ALL SELECT intScheduleColumnId = 163, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Sold To FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200163
	UNION ALL SELECT intScheduleColumnId = 164, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Point of Delivery City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200164
	UNION ALL SELECT intScheduleColumnId = 165, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Point of Delivery State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200165
	UNION ALL SELECT intScheduleColumnId = 166, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Gasoline', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200166
	UNION ALL SELECT intScheduleColumnId = 167, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Diesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200167
	UNION ALL SELECT intScheduleColumnId = 168, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Diesel', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200168
	UNION ALL SELECT intScheduleColumnId = 169, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200169
	UNION ALL SELECT intScheduleColumnId = 170, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Diesel', strColumn = 'strTransportationMode', strCaption = 'Method of Delivery', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200170
	UNION ALL SELECT intScheduleColumnId = 171, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Diesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200171
	UNION ALL SELECT intScheduleColumnId = 172, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Diesel', strColumn = 'strVendorName', strCaption = 'Purchased From', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200172
	UNION ALL SELECT intScheduleColumnId = 173, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Purchased From FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200173
	UNION ALL SELECT intScheduleColumnId = 174, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Diesel', strColumn = 'strOriginCity', strCaption = 'Point of Shipment City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200174
	UNION ALL SELECT intScheduleColumnId = 175, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Diesel', strColumn = 'strOriginState', strCaption = 'Point of Shipment State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200175
	UNION ALL SELECT intScheduleColumnId = 176, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Diesel', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200176
	UNION ALL SELECT intScheduleColumnId = 177, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Diesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Sold To FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200177
	UNION ALL SELECT intScheduleColumnId = 178, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Diesel', strColumn = 'strDestinationCity', strCaption = 'Point of Delivery City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200178
	UNION ALL SELECT intScheduleColumnId = 179, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Diesel', strColumn = 'strDestinationState', strCaption = 'Point of Delivery State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200179
	UNION ALL SELECT intScheduleColumnId = 180, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Diesel', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200180
	UNION ALL SELECT intScheduleColumnId = 181, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200181
	UNION ALL SELECT intScheduleColumnId = 182, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Gasoline', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200182
	UNION ALL SELECT intScheduleColumnId = 183, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200183
	UNION ALL SELECT intScheduleColumnId = 184, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Method of Delivery', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200184
	UNION ALL SELECT intScheduleColumnId = 185, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Gasoline', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200185
	UNION ALL SELECT intScheduleColumnId = 186, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Purchased From', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200186
	UNION ALL SELECT intScheduleColumnId = 187, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Purchased From FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200187
	UNION ALL SELECT intScheduleColumnId = 188, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Point of Shipment City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200188
	UNION ALL SELECT intScheduleColumnId = 189, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Point of Shipment State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200189
	UNION ALL SELECT intScheduleColumnId = 190, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200190
	UNION ALL SELECT intScheduleColumnId = 191, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Sold To FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200191
	UNION ALL SELECT intScheduleColumnId = 192, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Point of Delivery City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200192
	UNION ALL SELECT intScheduleColumnId = 193, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Point of Delivery State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200193
	UNION ALL SELECT intScheduleColumnId = 194, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Gasoline', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200194
	UNION ALL SELECT intScheduleColumnId = 195, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Diesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200195
	UNION ALL SELECT intScheduleColumnId = 196, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Diesel', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200196
	UNION ALL SELECT intScheduleColumnId = 197, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200197
	UNION ALL SELECT intScheduleColumnId = 198, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Diesel', strColumn = 'strTransportationMode', strCaption = 'Method of Delivery', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200198
	UNION ALL SELECT intScheduleColumnId = 199, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Diesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200199
	UNION ALL SELECT intScheduleColumnId = 200, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Diesel', strColumn = 'strVendorName', strCaption = 'Purchased From', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200200
	UNION ALL SELECT intScheduleColumnId = 201, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Purchased From FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200201
	UNION ALL SELECT intScheduleColumnId = 202, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Diesel', strColumn = 'strOriginCity', strCaption = 'Point of Shipment City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200202
	UNION ALL SELECT intScheduleColumnId = 203, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Diesel', strColumn = 'strOriginState', strCaption = 'Point of Shipment State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200203
	UNION ALL SELECT intScheduleColumnId = 204, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Diesel', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200204
	UNION ALL SELECT intScheduleColumnId = 205, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Diesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Sold To FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200205
	UNION ALL SELECT intScheduleColumnId = 206, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Diesel', strColumn = 'strDestinationCity', strCaption = 'Point of Delivery City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200206
	UNION ALL SELECT intScheduleColumnId = 207, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Diesel', strColumn = 'strDestinationState', strCaption = 'Point of Delivery State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200207
	UNION ALL SELECT intScheduleColumnId = 208, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Diesel', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200208
	UNION ALL SELECT intScheduleColumnId = 209, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200209
	UNION ALL SELECT intScheduleColumnId = 210, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Gasoline', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200210
	UNION ALL SELECT intScheduleColumnId = 211, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200211
	UNION ALL SELECT intScheduleColumnId = 212, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Method of Delivery', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200212
	UNION ALL SELECT intScheduleColumnId = 213, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200213
	UNION ALL SELECT intScheduleColumnId = 214, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Sold To FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200214
	UNION ALL SELECT intScheduleColumnId = 215, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Point of Shipment City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200215
	UNION ALL SELECT intScheduleColumnId = 216, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Point of Shipment State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200216
	UNION ALL SELECT intScheduleColumnId = 217, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Point of Delivery City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200217
	UNION ALL SELECT intScheduleColumnId = 218, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Point of Delivery State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200218
	UNION ALL SELECT intScheduleColumnId = 219, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Gasoline', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200219
	UNION ALL SELECT intScheduleColumnId = 220, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Diesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200220
	UNION ALL SELECT intScheduleColumnId = 221, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Diesel', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200221
	UNION ALL SELECT intScheduleColumnId = 222, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200222
	UNION ALL SELECT intScheduleColumnId = 223, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Diesel', strColumn = 'strTransportationMode', strCaption = 'Method of Delivery', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200223
	UNION ALL SELECT intScheduleColumnId = 224, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Diesel', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200224
	UNION ALL SELECT intScheduleColumnId = 225, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Diesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Sold To FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200225
	UNION ALL SELECT intScheduleColumnId = 226, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Diesel', strColumn = 'strOriginCity', strCaption = 'Point of Shipment City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200226
	UNION ALL SELECT intScheduleColumnId = 227, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Diesel', strColumn = 'strOriginState', strCaption = 'Point of Shipment State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200227
	UNION ALL SELECT intScheduleColumnId = 228, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Diesel', strColumn = 'strDestinationCity', strCaption = 'Point of Delivery City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200228
	UNION ALL SELECT intScheduleColumnId = 229, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Diesel', strColumn = 'strDestinationState', strCaption = 'Point of Delivery State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200229
	UNION ALL SELECT intScheduleColumnId = 230, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Diesel', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200230
	UNION ALL SELECT intScheduleColumnId = 231, strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200231
	UNION ALL SELECT intScheduleColumnId = 232, strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Gasoline', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200232
	UNION ALL SELECT intScheduleColumnId = 233, strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200233
	UNION ALL SELECT intScheduleColumnId = 234, strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Method of Delivery', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200234
	UNION ALL SELECT intScheduleColumnId = 235, strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200235
	UNION ALL SELECT intScheduleColumnId = 236, strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Sold To FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200236
	UNION ALL SELECT intScheduleColumnId = 237, strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Point of Shipment City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200237
	UNION ALL SELECT intScheduleColumnId = 238, strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Point of Shipment State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200238
	UNION ALL SELECT intScheduleColumnId = 239, strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Point of Delivery City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200239
	UNION ALL SELECT intScheduleColumnId = 240, strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Point of Delivery State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200240
	UNION ALL SELECT intScheduleColumnId = 241, strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Gasoline', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200241
	UNION ALL SELECT intScheduleColumnId = 242, strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Diesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200242
	UNION ALL SELECT intScheduleColumnId = 243, strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Diesel', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200243
	UNION ALL SELECT intScheduleColumnId = 244, strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200244
	UNION ALL SELECT intScheduleColumnId = 245, strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Diesel', strColumn = 'strTransportationMode', strCaption = 'Method of Delivery', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200245
	UNION ALL SELECT intScheduleColumnId = 246, strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Diesel', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200246
	UNION ALL SELECT intScheduleColumnId = 247, strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Diesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Sold To FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200247
	UNION ALL SELECT intScheduleColumnId = 248, strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Diesel', strColumn = 'strOriginCity', strCaption = 'Point of Shipment City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200248
	UNION ALL SELECT intScheduleColumnId = 249, strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Diesel', strColumn = 'strOriginState', strCaption = 'Point of Shipment State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200249
	UNION ALL SELECT intScheduleColumnId = 250, strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Diesel', strColumn = 'strDestinationCity', strCaption = 'Point of Delivery City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200250
	UNION ALL SELECT intScheduleColumnId = 251, strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Diesel', strColumn = 'strDestinationState', strCaption = 'Point of Delivery State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200251
	UNION ALL SELECT intScheduleColumnId = 252, strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Diesel', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200252
	UNION ALL SELECT intScheduleColumnId = 253, strFormCode = 'FR-400M', strScheduleCode = '12_US', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200253
	UNION ALL SELECT intScheduleColumnId = 254, strFormCode = 'FR-400M', strScheduleCode = '12_US', strType = 'Gasoline', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200254
	UNION ALL SELECT intScheduleColumnId = 255, strFormCode = 'FR-400M', strScheduleCode = '12_US', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200255
	UNION ALL SELECT intScheduleColumnId = 256, strFormCode = 'FR-400M', strScheduleCode = '12_US', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Method of Delivery', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200256
	UNION ALL SELECT intScheduleColumnId = 257, strFormCode = 'FR-400M', strScheduleCode = '12_US', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200257
	UNION ALL SELECT intScheduleColumnId = 258, strFormCode = 'FR-400M', strScheduleCode = '12_US', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Sold To FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200258
	UNION ALL SELECT intScheduleColumnId = 259, strFormCode = 'FR-400M', strScheduleCode = '12_US', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Point of Shipment City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200259
	UNION ALL SELECT intScheduleColumnId = 260, strFormCode = 'FR-400M', strScheduleCode = '12_US', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Point of Shipment State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200260
	UNION ALL SELECT intScheduleColumnId = 261, strFormCode = 'FR-400M', strScheduleCode = '12_US', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Point of Delivery City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200261
	UNION ALL SELECT intScheduleColumnId = 262, strFormCode = 'FR-400M', strScheduleCode = '12_US', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Point of Delivery State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200262
	UNION ALL SELECT intScheduleColumnId = 263, strFormCode = 'FR-400M', strScheduleCode = '12_US', strType = 'Gasoline', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200263
	UNION ALL SELECT intScheduleColumnId = 264, strFormCode = 'FR-400M', strScheduleCode = '12_US', strType = 'Diesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200264
	UNION ALL SELECT intScheduleColumnId = 265, strFormCode = 'FR-400M', strScheduleCode = '12_US', strType = 'Diesel', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200265
	UNION ALL SELECT intScheduleColumnId = 266, strFormCode = 'FR-400M', strScheduleCode = '12_US', strType = 'Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200266
	UNION ALL SELECT intScheduleColumnId = 267, strFormCode = 'FR-400M', strScheduleCode = '12_US', strType = 'Diesel', strColumn = 'strTransportationMode', strCaption = 'Method of Delivery', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200267
	UNION ALL SELECT intScheduleColumnId = 268, strFormCode = 'FR-400M', strScheduleCode = '12_US', strType = 'Diesel', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200268
	UNION ALL SELECT intScheduleColumnId = 269, strFormCode = 'FR-400M', strScheduleCode = '12_US', strType = 'Diesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Sold To FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200269
	UNION ALL SELECT intScheduleColumnId = 270, strFormCode = 'FR-400M', strScheduleCode = '12_US', strType = 'Diesel', strColumn = 'strOriginCity', strCaption = 'Point of Shipment City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200270
	UNION ALL SELECT intScheduleColumnId = 271, strFormCode = 'FR-400M', strScheduleCode = '12_US', strType = 'Diesel', strColumn = 'strOriginState', strCaption = 'Point of Shipment State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200271
	UNION ALL SELECT intScheduleColumnId = 272, strFormCode = 'FR-400M', strScheduleCode = '12_US', strType = 'Diesel', strColumn = 'strDestinationCity', strCaption = 'Point of Delivery City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200272
	UNION ALL SELECT intScheduleColumnId = 273, strFormCode = 'FR-400M', strScheduleCode = '12_US', strType = 'Diesel', strColumn = 'strDestinationState', strCaption = 'Point of Delivery State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200273
	UNION ALL SELECT intScheduleColumnId = 274, strFormCode = 'FR-400M', strScheduleCode = '12_US', strType = 'Diesel', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200274
	UNION ALL SELECT intScheduleColumnId = 275, strFormCode = 'FR-400M', strScheduleCode = '12_DC', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200275
	UNION ALL SELECT intScheduleColumnId = 276, strFormCode = 'FR-400M', strScheduleCode = '12_DC', strType = 'Gasoline', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200276
	UNION ALL SELECT intScheduleColumnId = 277, strFormCode = 'FR-400M', strScheduleCode = '12_DC', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200277
	UNION ALL SELECT intScheduleColumnId = 278, strFormCode = 'FR-400M', strScheduleCode = '12_DC', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Method of Delivery', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200278
	UNION ALL SELECT intScheduleColumnId = 279, strFormCode = 'FR-400M', strScheduleCode = '12_DC', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200279
	UNION ALL SELECT intScheduleColumnId = 280, strFormCode = 'FR-400M', strScheduleCode = '12_DC', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Sold To FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200280
	UNION ALL SELECT intScheduleColumnId = 281, strFormCode = 'FR-400M', strScheduleCode = '12_DC', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Point of Shipment City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200281
	UNION ALL SELECT intScheduleColumnId = 282, strFormCode = 'FR-400M', strScheduleCode = '12_DC', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Point of Shipment State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200282
	UNION ALL SELECT intScheduleColumnId = 283, strFormCode = 'FR-400M', strScheduleCode = '12_DC', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Point of Delivery City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200283
	UNION ALL SELECT intScheduleColumnId = 284, strFormCode = 'FR-400M', strScheduleCode = '12_DC', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Point of Delivery State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200284
	UNION ALL SELECT intScheduleColumnId = 285, strFormCode = 'FR-400M', strScheduleCode = '12_DC', strType = 'Gasoline', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200285
	UNION ALL SELECT intScheduleColumnId = 286, strFormCode = 'FR-400M', strScheduleCode = '12_DC', strType = 'Diesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200286
	UNION ALL SELECT intScheduleColumnId = 287, strFormCode = 'FR-400M', strScheduleCode = '12_DC', strType = 'Diesel', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200287
	UNION ALL SELECT intScheduleColumnId = 288, strFormCode = 'FR-400M', strScheduleCode = '12_DC', strType = 'Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200288
	UNION ALL SELECT intScheduleColumnId = 289, strFormCode = 'FR-400M', strScheduleCode = '12_DC', strType = 'Diesel', strColumn = 'strTransportationMode', strCaption = 'Method of Delivery', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200289
	UNION ALL SELECT intScheduleColumnId = 290, strFormCode = 'FR-400M', strScheduleCode = '12_DC', strType = 'Diesel', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200290
	UNION ALL SELECT intScheduleColumnId = 291, strFormCode = 'FR-400M', strScheduleCode = '12_DC', strType = 'Diesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Sold To FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200291
	UNION ALL SELECT intScheduleColumnId = 292, strFormCode = 'FR-400M', strScheduleCode = '12_DC', strType = 'Diesel', strColumn = 'strOriginCity', strCaption = 'Point of Shipment City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200292
	UNION ALL SELECT intScheduleColumnId = 293, strFormCode = 'FR-400M', strScheduleCode = '12_DC', strType = 'Diesel', strColumn = 'strOriginState', strCaption = 'Point of Shipment State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200293
	UNION ALL SELECT intScheduleColumnId = 294, strFormCode = 'FR-400M', strScheduleCode = '12_DC', strType = 'Diesel', strColumn = 'strDestinationCity', strCaption = 'Point of Delivery City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200294
	UNION ALL SELECT intScheduleColumnId = 295, strFormCode = 'FR-400M', strScheduleCode = '12_DC', strType = 'Diesel', strColumn = 'strDestinationState', strCaption = 'Point of Delivery State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200295
	UNION ALL SELECT intScheduleColumnId = 296, strFormCode = 'FR-400M', strScheduleCode = '12_DC', strType = 'Diesel', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200296
	UNION ALL SELECT intScheduleColumnId = 297, strFormCode = 'FR-400M', strScheduleCode = '22_P', strType = 'Diesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200297
	UNION ALL SELECT intScheduleColumnId = 298, strFormCode = 'FR-400M', strScheduleCode = '22_P', strType = 'Diesel', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200298
	UNION ALL SELECT intScheduleColumnId = 299, strFormCode = 'FR-400M', strScheduleCode = '22_P', strType = 'Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200299
	UNION ALL SELECT intScheduleColumnId = 300, strFormCode = 'FR-400M', strScheduleCode = '22_P', strType = 'Diesel', strColumn = 'strTransportationMode', strCaption = 'Method of Delivery', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200300
	UNION ALL SELECT intScheduleColumnId = 301, strFormCode = 'FR-400M', strScheduleCode = '22_P', strType = 'Diesel', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200301
	UNION ALL SELECT intScheduleColumnId = 302, strFormCode = 'FR-400M', strScheduleCode = '22_P', strType = 'Diesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Sold To FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200302
	UNION ALL SELECT intScheduleColumnId = 303, strFormCode = 'FR-400M', strScheduleCode = '22_P', strType = 'Diesel', strColumn = 'strOriginCity', strCaption = 'Point of Shipment City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200303
	UNION ALL SELECT intScheduleColumnId = 304, strFormCode = 'FR-400M', strScheduleCode = '22_P', strType = 'Diesel', strColumn = 'strOriginState', strCaption = 'Point of Shipment State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200304
	UNION ALL SELECT intScheduleColumnId = 305, strFormCode = 'FR-400M', strScheduleCode = '22_P', strType = 'Diesel', strColumn = 'strDestinationCity', strCaption = 'Point of Delivery City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200305
	UNION ALL SELECT intScheduleColumnId = 306, strFormCode = 'FR-400M', strScheduleCode = '22_P', strType = 'Diesel', strColumn = 'strDestinationState', strCaption = 'Point of Delivery State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200306
	UNION ALL SELECT intScheduleColumnId = 307, strFormCode = 'FR-400M', strScheduleCode = '22_P', strType = 'Diesel', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200307
	UNION ALL SELECT intScheduleColumnId = 308, strFormCode = 'FR-400M', strScheduleCode = '22_U', strType = 'Diesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200308
	UNION ALL SELECT intScheduleColumnId = 309, strFormCode = 'FR-400M', strScheduleCode = '22_U', strType = 'Diesel', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200309
	UNION ALL SELECT intScheduleColumnId = 310, strFormCode = 'FR-400M', strScheduleCode = '22_U', strType = 'Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200310
	UNION ALL SELECT intScheduleColumnId = 311, strFormCode = 'FR-400M', strScheduleCode = '22_U', strType = 'Diesel', strColumn = 'strTransportationMode', strCaption = 'Method of Delivery', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200311
	UNION ALL SELECT intScheduleColumnId = 312, strFormCode = 'FR-400M', strScheduleCode = '22_U', strType = 'Diesel', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200312
	UNION ALL SELECT intScheduleColumnId = 313, strFormCode = 'FR-400M', strScheduleCode = '22_U', strType = 'Diesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Sold To FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200313
	UNION ALL SELECT intScheduleColumnId = 314, strFormCode = 'FR-400M', strScheduleCode = '22_U', strType = 'Diesel', strColumn = 'strOriginCity', strCaption = 'Point of Shipment City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200314
	UNION ALL SELECT intScheduleColumnId = 315, strFormCode = 'FR-400M', strScheduleCode = '22_U', strType = 'Diesel', strColumn = 'strOriginState', strCaption = 'Point of Shipment State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200315
	UNION ALL SELECT intScheduleColumnId = 316, strFormCode = 'FR-400M', strScheduleCode = '22_U', strType = 'Diesel', strColumn = 'strDestinationCity', strCaption = 'Point of Delivery City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200316
	UNION ALL SELECT intScheduleColumnId = 317, strFormCode = 'FR-400M', strScheduleCode = '22_U', strType = 'Diesel', strColumn = 'strDestinationState', strCaption = 'Point of Delivery State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200317
	UNION ALL SELECT intScheduleColumnId = 318, strFormCode = 'FR-400M', strScheduleCode = '22_U', strType = 'Diesel', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200318
	UNION ALL SELECT intScheduleColumnId = 319, strFormCode = 'FR-400M', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200319
	UNION ALL SELECT intScheduleColumnId = 320, strFormCode = 'FR-400M', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200320
	UNION ALL SELECT intScheduleColumnId = 321, strFormCode = 'FR-400M', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'strReason', strCaption = 'Explanation', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200321
	UNION ALL SELECT intScheduleColumnId = 322, strFormCode = 'FR-400M', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200322
	UNION ALL SELECT intScheduleColumnId = 323, strFormCode = 'FR-400M', strScheduleCode = '6', strType = 'Diesel', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200323
	UNION ALL SELECT intScheduleColumnId = 324, strFormCode = 'FR-400M', strScheduleCode = '6', strType = 'Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200324
	UNION ALL SELECT intScheduleColumnId = 325, strFormCode = 'FR-400M', strScheduleCode = '6', strType = 'Diesel', strColumn = 'strReason', strCaption = 'Explanation', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200325
	UNION ALL SELECT intScheduleColumnId = 326, strFormCode = 'FR-400M', strScheduleCode = '6', strType = 'Diesel', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200326
	UNION ALL SELECT intScheduleColumnId = 327, strFormCode = 'FR-400M', strScheduleCode = '13', strType = 'Gasoline', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200327
	UNION ALL SELECT intScheduleColumnId = 328, strFormCode = 'FR-400M', strScheduleCode = '13', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200328
	UNION ALL SELECT intScheduleColumnId = 329, strFormCode = 'FR-400M', strScheduleCode = '13', strType = 'Gasoline', strColumn = 'strReason', strCaption = 'Explanation', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200329
	UNION ALL SELECT intScheduleColumnId = 330, strFormCode = 'FR-400M', strScheduleCode = '13', strType = 'Gasoline', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200330
	UNION ALL SELECT intScheduleColumnId = 331, strFormCode = 'FR-400M', strScheduleCode = '13', strType = 'Diesel', strColumn = 'strScheduleCode', strCaption = 'Schedule Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200331
	UNION ALL SELECT intScheduleColumnId = 332, strFormCode = 'FR-400M', strScheduleCode = '13', strType = 'Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200332
	UNION ALL SELECT intScheduleColumnId = 333, strFormCode = 'FR-400M', strScheduleCode = '13', strType = 'Diesel', strColumn = 'strReason', strCaption = 'Explanation', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200333
	UNION ALL SELECT intScheduleColumnId = 334, strFormCode = 'FR-400M', strScheduleCode = '13', strType = 'Diesel', strColumn = 'dblBillQty', strCaption = 'Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 5200334

	EXEC uspTFUpgradeReportingComponentOutputDesigners @TaxAuthorityCode = @TaxAuthorityCode, @ReportingComponentOutputDesigners = @ReportingComponentOutputDesigners


-- Filing Packet
/* Generate script for Filing Packets. Specify Tax Authority Id to filter out specific Filing Packets only.
select strQuery = 'UNION ALL SELECT intFilingPacketId = ' + CAST(intFilingPacketId AS NVARCHAR(10))
	+ CASE WHEN strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END
	+ CASE WHEN ysnStatus IS NULL THEN ', ysnStatus = NULL' ELSE ', ysnStatus = ' + CAST(ysnStatus AS NVARCHAR) END
	+ CASE WHEN intFrequency IS NULL THEN ', intFrequency = NULL' ELSE ', intFrequency = ' + CAST(intFrequency AS NVARCHAR(10)) END
	+ ', intMasterId = ' + CASE WHEN FP.intMasterId IS NULL THEN CAST(22 AS NVARCHAR(20)) + CAST(intFilingPacketId AS NVARCHAR(20)) ELSE CAST(FP.intMasterId AS NVARCHAR(20)) END
from tblTFFilingPacket FP
left join tblTFReportingComponent RC on RC.intReportingComponentId = FP.intReportingComponentId
where FP.intTaxAuthorityId = 22
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
	SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 5200001
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '2_P', strType = 'Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 5200002
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 5200003
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '2_U', strType = 'Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 5200004
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 5200005
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '3_P', strType = 'Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 5200006
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 5200007
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '3_U', strType = 'Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 5200008
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 5200009
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '4_P', strType = 'Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 5200010
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 5200011
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '4_U', strType = 'Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 5200012
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 5200013
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '5_P', strType = 'Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 5200014
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 5200015
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '5_U', strType = 'Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 5200016
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '6', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 5200017
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '6', strType = 'Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 5200018
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 5200019
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '10', strType = 'Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 5200020
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 5200021
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '11', strType = 'Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 5200022
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '12_US', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 5200023
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '12_US', strType = 'Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 5200024
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '12_DC', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 5200025
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '12_DC', strType = 'Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 5200026
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '13', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 5200027
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '13', strType = 'Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 5200028
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '22_P', strType = 'Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 5200029
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'FR-400M', strScheduleCode = '22_U', strType = 'Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 5200030

	EXEC uspTFUpgradeFilingPackets @TaxAuthorityCode = @TaxAuthorityCode, @FilingPackets = @FilingPackets

END
GO
