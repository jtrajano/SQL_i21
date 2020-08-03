DECLARE @TaxAuthorityCode NVARCHAR(10) = 'TX'
	, @TaxAuthorityId INT

SELECT @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = @TaxAuthorityCode AND ysnFilingForThisTA = 1

IF(@TaxAuthorityId IS NOT NULL)
BEGIN

	PRINT ('Deploying Texas Tax Forms')

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
	SELECT intProductCodeId = 0, strProductCode = '072', strDescription = 'Kerosene - Dyed', strProductCodeGroup = 'Diesel', strNote = NULL, intMasterId = 431097
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '130', strDescription = 'Jet Fuel', strProductCodeGroup = 'Diesel', strNote = NULL, intMasterId = 431098
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '142', strDescription = 'Kerosene - Clear', strProductCodeGroup = 'Diesel', strNote = NULL, intMasterId = 431099
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '160', strDescription = 'Diesel - Clear', strProductCodeGroup = 'Diesel', strNote = NULL, intMasterId = 431100
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '228', strDescription = 'Diesel - Dyed', strProductCodeGroup = 'Diesel', strNote = NULL, intMasterId = 431101
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '065', strDescription = 'Gasoline', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 431102
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '124', strDescription = 'Gasohol', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 431103
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '125', strDescription = 'Aviation Gasoline', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 431104
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '122', strDescription = 'Blending Materials', strProductCodeGroup = 'Blending Materials', strNote = NULL, intMasterId = 431105
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '274', strDescription = 'Water', strProductCodeGroup = 'Blending Materials', strNote = NULL, intMasterId = 431106
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '241', strDescription = 'Ethanol', strProductCodeGroup = 'Blending Materials', strNote = NULL, intMasterId = 431107
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '284', strDescription = 'Biodiesel - Clear', strProductCodeGroup = 'Blending Materials', strNote = NULL, intMasterId = 431108

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
	SELECT intReportingComponentId = 0, strFormCode = '06-168GD', strFormName = 'Gasoline Distributors Return', strScheduleCode = '06-146', strScheduleName = 'Gallons Removed from Terminal, TX Tax Paid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 10, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 432264, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '06-168GD', strFormName = 'Gasoline Distributors Return', strScheduleCode = '06-148', strScheduleName = 'Gallons Imported, TX Tax Unpaid', strType = 'Gasoline', strNote = '', strTransactionType = 'Inventory', intSort = 20, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 432265, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '06-168GD', strFormName = 'Gasoline Distributors Return', strScheduleCode = '06-149', strScheduleName = 'Gallons Imported, TX Tax Paid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 30, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 432266, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '06-168GD', strFormName = 'Gasoline Distributors Return', strScheduleCode = '06-150', strScheduleName = 'Taxable Blending Materials', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 40, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 432267, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '06-168GD', strFormName = 'Gasoline Distributors Return', strScheduleCode = '06-152', strScheduleName = 'Blended Gallons Sold', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 50, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 432268, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '06-168GD', strFormName = 'Gasoline Distributors Return', strScheduleCode = '06-156', strScheduleName = 'Gallons Sold to Aviation Fuel Dealers, TX Tax Not Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 60, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 432269, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '06-168GD', strFormName = 'Gasoline Distributors Return', strScheduleCode = '06-157', strScheduleName = 'Gallons Exported', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 70, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 432270, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '06-168GD', strFormName = 'Gasoline Distributors Return', strScheduleCode = '06-158', strScheduleName = 'Gallons Sold for Export, TX Tax Not Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 80, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 432271, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '06-168GD', strFormName = 'Gasoline Distributors Return', strScheduleCode = '06-190', strScheduleName = 'Gallons Subsequently Sold Prior To Export, TX Tax Not Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 90, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 432272, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '06-168GD', strFormName = 'Gasoline Distributors Return', strScheduleCode = '06-159', strScheduleName = 'Gallons Sold to Exempt Entities, TX Tax Not Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 100, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 432273, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '06-168GD', strFormName = 'Gasoline Distributors Return', strScheduleCode = '06-161', strScheduleName = 'State Diversions of Gasoline', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 110, strStoredProcedure = 'uspTFGetDiversionTax', intMasterId = 432274, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '06-168DD', strFormName = 'Diesel Distributors Return', strScheduleCode = '06-145', strScheduleName = 'Gallons of Dyed Diesel Purchased, TX Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 200, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 432275, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '06-168DD', strFormName = 'Diesel Distributors Return', strScheduleCode = '06-146', strScheduleName = 'Gallons Removed from Terminal, TX Tax Paid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 210, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 432276, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '06-168DD', strFormName = 'Diesel Distributors Return', strScheduleCode = '06-148', strScheduleName = 'Gallons Imported, TX Tax Unpaid', strType = 'Dyed Diesel', strNote = '', strTransactionType = 'Inventory', intSort = 220, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 432277, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '06-168DD', strFormName = 'Diesel Distributors Return', strScheduleCode = '06-148', strScheduleName = 'Gallons Imported, TX Tax Unpaid', strType = 'Undyed Diesel', strNote = '', strTransactionType = 'Inventory', intSort = 230, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 432278, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '06-168DD', strFormName = 'Diesel Distributors Return', strScheduleCode = '06-149', strScheduleName = 'Gallons Imported, TX Tax Paid', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 240, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 432279, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '06-168DD', strFormName = 'Diesel Distributors Return', strScheduleCode = '06-150', strScheduleName = 'Taxable Blending Materials', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 250, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 432280, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '06-168DD', strFormName = 'Diesel Distributors Return', strScheduleCode = '06-151', strScheduleName = 'Tax Exempt Blending Material - Diesel Fuel', strType = '', strNote = '', strTransactionType = 'Inventory', intSort = 260, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 432281, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '06-168DD', strFormName = 'Diesel Distributors Return', strScheduleCode = '06-152', strScheduleName = 'Blended Gallons Sold', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 270, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 432282, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '06-168DD', strFormName = 'Diesel Distributors Return', strScheduleCode = '06-155', strScheduleName = 'Gallons of Dyed Diesel Sold Tax Free to Licensed Holders or Removed from Terminal', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 280, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 432283, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '06-168DD', strFormName = 'Diesel Distributors Return', strScheduleCode = '06-156', strScheduleName = 'Gallons Sold to Aviation Fuel Dealers, TX Tax Not Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 290, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 432284, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '06-168DD', strFormName = 'Diesel Distributors Return', strScheduleCode = '06-157', strScheduleName = 'Gallons Exported', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 300, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 432285, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '06-168DD', strFormName = 'Diesel Distributors Return', strScheduleCode = '06-158', strScheduleName = 'Gallons Sold for Export, TX Tax Not Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 310, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 432286, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '06-168DD', strFormName = 'Diesel Distributors Return', strScheduleCode = '06-190', strScheduleName = 'Gallons Subsequently Sold Prior To Export, TX Tax Not Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 320, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 432287, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '06-168DD', strFormName = 'Diesel Distributors Return', strScheduleCode = '06-159', strScheduleName = 'Gallons Sold to Exempt Entities, TX Tax Not Collected', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 330, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 432288, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '06-168DD', strFormName = 'Diesel Distributors Return', strScheduleCode = '06-160', strScheduleName = 'Gallons of Dyed Diesel Sold on a Signed Statement', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 340, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 432289, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = '06-168DD', strFormName = 'Diesel Distributors Return', strScheduleCode = '06-161', strScheduleName = 'State Diversions of Undyed Diesel', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 350, strStoredProcedure = 'uspTFGetDiversionTax', intMasterId = 432290, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'TX E-file', strFormName = 'Texas E-file (txt files)', strScheduleCode = '', strScheduleName = '', strType = '', strNote = 'Texas E-file (txt files)', strTransactionType = '', intSort = 500, strStoredProcedure = '', intMasterId = 432291, intComponentTypeId = 4

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
	SELECT intTaxCriteriaId = 0, strTaxCategory = 'TX Excise Tax Diesel', strState = 'TX', strFormCode = '06-168DD', strScheduleCode = '06-146', strType = '', strCriteria = '<> 0', intMasterId = 431037
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'TX Excise Tax Diesel', strState = 'TX', strFormCode = '06-168DD', strScheduleCode = '06-149', strType = '', strCriteria = '<> 0', intMasterId = 431038
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'TX Excise Tax Gasoline', strState = 'TX', strFormCode = '06-168GD', strScheduleCode = '06-146', strType = '', strCriteria = '<> 0', intMasterId = 431039
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'TX Excise Tax Gasoline', strState = 'TX', strFormCode = '06-168GD', strScheduleCode = '06-149', strType = '', strCriteria = '<> 0', intMasterId = 431040
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'TX Excise Tax Diesel', strState = 'TX', strFormCode = '06-168DD', strScheduleCode = '06-145', strType = '', strCriteria = '= 0', intMasterId = 431041
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'TX Excise Tax Diesel', strState = 'TX', strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Dyed Diesel', strCriteria = '= 0', intMasterId = 431042
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'TX Excise Tax Diesel', strState = 'TX', strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Undyed Diesel', strCriteria = '= 0', intMasterId = 431043
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'TX Excise Tax Gasoline', strState = 'TX', strFormCode = '06-168GD', strScheduleCode = '06-148', strType = 'Gasoline', strCriteria = '= 0', intMasterId = 431044
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'TX Excise Tax Diesel', strState = 'TX', strFormCode = '06-168DD', strScheduleCode = '06-156', strType = '', strCriteria = '= 0', intMasterId = 431045
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'TX Excise Tax Diesel', strState = 'TX', strFormCode = '06-168DD', strScheduleCode = '06-158', strType = '', strCriteria = '= 0', intMasterId = 431046
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'TX Excise Tax Diesel', strState = 'TX', strFormCode = '06-168DD', strScheduleCode = '06-159', strType = '', strCriteria = '= 0', intMasterId = 431047
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'TX Excise Tax Diesel', strState = 'TX', strFormCode = '06-168DD', strScheduleCode = '06-190', strType = '', strCriteria = '= 0', intMasterId = 431048
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'TX Excise Tax Gasoline', strState = 'TX', strFormCode = '06-168GD', strScheduleCode = '06-156', strType = '', strCriteria = '= 0', intMasterId = 431049
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'TX Excise Tax Gasoline', strState = 'TX', strFormCode = '06-168GD', strScheduleCode = '06-158', strType = '', strCriteria = '= 0', intMasterId = 431050
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'TX Excise Tax Gasoline', strState = 'TX', strFormCode = '06-168GD', strScheduleCode = '06-159', strType = '', strCriteria = '= 0', intMasterId = 431051
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'TX Excise Tax Gasoline', strState = 'TX', strFormCode = '06-168GD', strScheduleCode = '06-190', strType = '', strCriteria = '= 0', intMasterId = 431052

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
	SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '06-168GD', strScheduleCode = '06-146', strType = '', intMasterId = 439599
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '06-168GD', strScheduleCode = '06-146', strType = '', intMasterId = 439600
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '06-168GD', strScheduleCode = '06-146', strType = '', intMasterId = 439601
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '06-168GD', strScheduleCode = '06-148', strType = 'Gasoline', intMasterId = 439602
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '06-168GD', strScheduleCode = '06-148', strType = 'Gasoline', intMasterId = 439603
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '06-168GD', strScheduleCode = '06-148', strType = 'Gasoline', intMasterId = 439604
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '06-168GD', strScheduleCode = '06-149', strType = '', intMasterId = 439605
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '06-168GD', strScheduleCode = '06-149', strType = '', intMasterId = 439606
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '06-168GD', strScheduleCode = '06-149', strType = '', intMasterId = 439607
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '06-168GD', strScheduleCode = '06-152', strType = '', intMasterId = 439608
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '06-168GD', strScheduleCode = '06-152', strType = '', intMasterId = 439609
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '06-168GD', strScheduleCode = '06-152', strType = '', intMasterId = 439610
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '06-168GD', strScheduleCode = '06-156', strType = '', intMasterId = 439611
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '06-168GD', strScheduleCode = '06-156', strType = '', intMasterId = 439612
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '06-168GD', strScheduleCode = '06-156', strType = '', intMasterId = 439613
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '06-168GD', strScheduleCode = '06-157', strType = '', intMasterId = 439614
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '06-168GD', strScheduleCode = '06-157', strType = '', intMasterId = 439615
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '06-168GD', strScheduleCode = '06-157', strType = '', intMasterId = 439616
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '06-168GD', strScheduleCode = '06-158', strType = '', intMasterId = 439617
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '06-168GD', strScheduleCode = '06-158', strType = '', intMasterId = 439618
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '06-168GD', strScheduleCode = '06-158', strType = '', intMasterId = 439619
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '06-168GD', strScheduleCode = '06-159', strType = '', intMasterId = 439620
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '06-168GD', strScheduleCode = '06-159', strType = '', intMasterId = 439621
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '06-168GD', strScheduleCode = '06-159', strType = '', intMasterId = 439622
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '06-168GD', strScheduleCode = '06-161', strType = '', intMasterId = 439623
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '06-168GD', strScheduleCode = '06-161', strType = '', intMasterId = 439624
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '06-168GD', strScheduleCode = '06-161', strType = '', intMasterId = 439625
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = '06-168GD', strScheduleCode = '06-190', strType = '', intMasterId = 439626
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = '06-168GD', strScheduleCode = '06-190', strType = '', intMasterId = 439627
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = '06-168GD', strScheduleCode = '06-190', strType = '', intMasterId = 439628
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '06-168GD', strScheduleCode = '06-150', strType = '', intMasterId = 439629
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '122', strFormCode = '06-168DD', strScheduleCode = '06-150', strType = '', intMasterId = 439630
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '06-168DD', strScheduleCode = '06-145', strType = '', intMasterId = 439631
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '06-168DD', strScheduleCode = '06-145', strType = '', intMasterId = 439632
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '06-168DD', strScheduleCode = '06-155', strType = '', intMasterId = 439633
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '06-168DD', strScheduleCode = '06-155', strType = '', intMasterId = 439634
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '06-168DD', strScheduleCode = '06-160', strType = '', intMasterId = 439635
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '06-168DD', strScheduleCode = '06-160', strType = '', intMasterId = 439636
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '06-168DD', strScheduleCode = '06-152', strType = '', intMasterId = 439637
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '06-168DD', strScheduleCode = '06-152', strType = '', intMasterId = 439638
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = '06-168DD', strScheduleCode = '06-152', strType = '', intMasterId = 439639
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '06-168DD', strScheduleCode = '06-152', strType = '', intMasterId = 439640
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '06-168DD', strScheduleCode = '06-152', strType = '', intMasterId = 439641
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '06-168DD', strScheduleCode = '06-156', strType = '', intMasterId = 439642
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '06-168DD', strScheduleCode = '06-156', strType = '', intMasterId = 439643
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = '06-168DD', strScheduleCode = '06-156', strType = '', intMasterId = 439644
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '06-168DD', strScheduleCode = '06-156', strType = '', intMasterId = 439645
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '06-168DD', strScheduleCode = '06-156', strType = '', intMasterId = 439646
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '06-168DD', strScheduleCode = '06-157', strType = '', intMasterId = 439647
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '06-168DD', strScheduleCode = '06-157', strType = '', intMasterId = 439648
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = '06-168DD', strScheduleCode = '06-157', strType = '', intMasterId = 439649
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '06-168DD', strScheduleCode = '06-157', strType = '', intMasterId = 439650
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '06-168DD', strScheduleCode = '06-157', strType = '', intMasterId = 439651
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '06-168DD', strScheduleCode = '06-158', strType = '', intMasterId = 439652
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '06-168DD', strScheduleCode = '06-158', strType = '', intMasterId = 439653
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = '06-168DD', strScheduleCode = '06-158', strType = '', intMasterId = 439654
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '06-168DD', strScheduleCode = '06-158', strType = '', intMasterId = 439655
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '06-168DD', strScheduleCode = '06-158', strType = '', intMasterId = 439656
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '06-168DD', strScheduleCode = '06-159', strType = '', intMasterId = 439657
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '06-168DD', strScheduleCode = '06-159', strType = '', intMasterId = 439658
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = '06-168DD', strScheduleCode = '06-159', strType = '', intMasterId = 439659
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '06-168DD', strScheduleCode = '06-159', strType = '', intMasterId = 439660
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '06-168DD', strScheduleCode = '06-159', strType = '', intMasterId = 439661
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '06-168DD', strScheduleCode = '06-190', strType = '', intMasterId = 439662
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '06-168DD', strScheduleCode = '06-190', strType = '', intMasterId = 439663
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = '06-168DD', strScheduleCode = '06-190', strType = '', intMasterId = 439664
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '06-168DD', strScheduleCode = '06-190', strType = '', intMasterId = 439665
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '06-168DD', strScheduleCode = '06-190', strType = '', intMasterId = 439666
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = '06-168DD', strScheduleCode = '06-146', strType = '', intMasterId = 439667
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '06-168DD', strScheduleCode = '06-146', strType = '', intMasterId = 439668
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '06-168DD', strScheduleCode = '06-146', strType = '', intMasterId = 439669
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = '06-168DD', strScheduleCode = '06-149', strType = '', intMasterId = 439670
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '06-168DD', strScheduleCode = '06-149', strType = '', intMasterId = 439671
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '06-168DD', strScheduleCode = '06-149', strType = '', intMasterId = 439672
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = '06-168DD', strScheduleCode = '06-161', strType = '', intMasterId = 439673
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '06-168DD', strScheduleCode = '06-161', strType = '', intMasterId = 439674
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '06-168DD', strScheduleCode = '06-161', strType = '', intMasterId = 439675
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '274', strFormCode = '06-168DD', strScheduleCode = '06-151', strType = '', intMasterId = 439676
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '241', strFormCode = '06-168DD', strScheduleCode = '06-151', strType = '', intMasterId = 439677
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '284', strFormCode = '06-168DD', strScheduleCode = '06-151', strType = '', intMasterId = 439678
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Dyed Diesel', intMasterId = 439679
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Dyed Diesel', intMasterId = 439680
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Undyed Diesel', intMasterId = 439681
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Undyed Diesel', intMasterId = 439682
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Undyed Diesel', intMasterId = 439683

	INSERT INTO @ValidOriginStates(
		intValidOriginStateId
		, strFormCode
		, strScheduleCode
		, strType
		, strState
		, strStatus
		, intMasterId
	)
	SELECT intValidOriginStateId = 0, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Dyed Diesel', strState = 'TX', strStatus = 'Exclude', intMasterId = 431273
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Undyed Diesel', strState = 'TX', strStatus = 'Exclude', intMasterId = 431274
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '06-168DD', strScheduleCode = '06-149', strType = '', strState = 'TX', strStatus = 'Exclude', intMasterId = 431275
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '06-168GD', strScheduleCode = '06-148', strType = 'Gasoline', strState = 'TX', strStatus = 'Exclude', intMasterId = 431276
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '06-168GD', strScheduleCode = '06-149', strType = '', strState = 'TX', strStatus = 'Exclude', intMasterId = 431277
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '06-168GD', strScheduleCode = '06-152', strType = '', strState = 'TX', strStatus = 'Include', intMasterId = 431278
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '06-168GD', strScheduleCode = '06-156', strType = '', strState = 'TX', strStatus = 'Include', intMasterId = 431279
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '06-168DD', strScheduleCode = '06-157', strType = '', strState = 'TX', strStatus = 'Include', intMasterId = 431280
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '06-168GD', strScheduleCode = '06-157', strType = '', strState = 'TX', strStatus = 'Include', intMasterId = 431281
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '06-168GD', strScheduleCode = '06-158', strType = '', strState = 'TX', strStatus = 'Include', intMasterId = 431282
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '06-168GD', strScheduleCode = '06-190', strType = '', strState = 'TX', strStatus = 'Include', intMasterId = 431283
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '06-168GD', strScheduleCode = '06-159', strType = '', strState = 'TX', strStatus = 'Include', intMasterId = 431284
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '06-168DD', strScheduleCode = '06-158', strType = '', strState = 'TX', strStatus = 'Include', intMasterId = 431285
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '06-168DD', strScheduleCode = '06-190', strType = '', strState = 'TX', strStatus = 'Include', intMasterId = 431286
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '06-168DD', strScheduleCode = '06-159', strType = '', strState = 'TX', strStatus = 'Include', intMasterId = 431287
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '06-168DD', strScheduleCode = '06-152', strType = '', strState = 'TX', strStatus = 'Include', intMasterId = 431288
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '06-168DD', strScheduleCode = '06-155', strType = '', strState = 'TX', strStatus = 'Include', intMasterId = 431289
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '06-168DD', strScheduleCode = '06-156', strType = '', strState = 'TX', strStatus = 'Include', intMasterId = 431290
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = '06-168DD', strScheduleCode = '06-160', strType = '', strState = 'TX', strStatus = 'Include', intMasterId = 431291

	INSERT INTO @ValidDestinationStates(
		intValidDestinationStateId
		, strFormCode
		, strScheduleCode
		, strType
		, strState
		, strStatus
		, intMasterId
	)
	SELECT intValidDestinationStateId = 0, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Dyed Diesel', strState = 'TX', strStatus = 'Include', intMasterId = 431209
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Undyed Diesel', strState = 'TX', strStatus = 'Include', intMasterId = 431210
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '06-168DD', strScheduleCode = '06-149', strType = '', strState = 'TX', strStatus = 'Include', intMasterId = 431211
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '06-168GD', strScheduleCode = '06-148', strType = 'Gasoline', strState = 'TX', strStatus = 'Include', intMasterId = 431212
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '06-168GD', strScheduleCode = '06-149', strType = '', strState = 'TX', strStatus = 'Include', intMasterId = 431213
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '06-168GD', strScheduleCode = '06-146', strType = '', strState = 'TX', strStatus = 'Include', intMasterId = 431214
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '06-168GD', strScheduleCode = '06-150', strType = '', strState = 'TX', strStatus = 'Include', intMasterId = 431215
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '06-168DD', strScheduleCode = '06-157', strType = '', strState = 'TX', strStatus = 'Exclude', intMasterId = 431216
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '06-168GD', strScheduleCode = '06-157', strType = '', strState = 'TX', strStatus = 'Exclude', intMasterId = 431217
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '06-168DD', strScheduleCode = '06-145', strType = '', strState = 'TX', strStatus = 'Include', intMasterId = 431218
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '06-168DD', strScheduleCode = '06-146', strType = '', strState = 'TX', strStatus = 'Include', intMasterId = 431219
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '06-168DD', strScheduleCode = '06-150', strType = '', strState = 'TX', strStatus = 'Include', intMasterId = 431220
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = '06-168DD', strScheduleCode = '06-151', strType = '', strState = 'TX', strStatus = 'Include', intMasterId = 431221

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
	SELECT intReportTemplateId = 0, strFormCode = '06-168DD', strScheduleCode = '06-160', strType = '', strTemplateItemId = NULL, strReportSection = '', intReportItemSequence = NULL, intTemplateItemNumber = '0', strDescription = 'strTXPurchaserSignedStatementNumber', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = NULL, ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, ysnOutputDesigner = 1, strInputType = NULL, intMasterId = 431331

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
	SELECT intScheduleColumnId = 1, strFormCode = '06-168DD', strScheduleCode = '06-145', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328778
	UNION ALL SELECT intScheduleColumnId = 2, strFormCode = '06-168DD', strScheduleCode = '06-145', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328779
	UNION ALL SELECT intScheduleColumnId = 3, strFormCode = '06-168DD', strScheduleCode = '06-145', strType = '', strColumn = 'strTransporterLicense', strCaption = 'Carrier License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328780
	UNION ALL SELECT intScheduleColumnId = 4, strFormCode = '06-168DD', strScheduleCode = '06-145', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328781
	UNION ALL SELECT intScheduleColumnId = 5, strFormCode = '06-168DD', strScheduleCode = '06-145', strType = '', strColumn = 'strCustomerLicenseNumber', strCaption = 'Buyer License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328782
	UNION ALL SELECT intScheduleColumnId = 6, strFormCode = '06-168DD', strScheduleCode = '06-145', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328783
	UNION ALL SELECT intScheduleColumnId = 7, strFormCode = '06-168DD', strScheduleCode = '06-145', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328784
	UNION ALL SELECT intScheduleColumnId = 8, strFormCode = '06-168DD', strScheduleCode = '06-145', strType = '', strColumn = 'strBillofLading', strCaption = 'Doc Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328785
	UNION ALL SELECT intScheduleColumnId = 9, strFormCode = '06-168DD', strScheduleCode = '06-145', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328786
	UNION ALL SELECT intScheduleColumnId = 10, strFormCode = '06-168DD', strScheduleCode = '06-145', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328787
	UNION ALL SELECT intScheduleColumnId = 11, strFormCode = '06-168DD', strScheduleCode = '06-146', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328788
	UNION ALL SELECT intScheduleColumnId = 12, strFormCode = '06-168DD', strScheduleCode = '06-146', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328789
	UNION ALL SELECT intScheduleColumnId = 13, strFormCode = '06-168DD', strScheduleCode = '06-146', strType = '', strColumn = 'strTransporterLicense', strCaption = 'Carrier License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328790
	UNION ALL SELECT intScheduleColumnId = 14, strFormCode = '06-168DD', strScheduleCode = '06-146', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328791
	UNION ALL SELECT intScheduleColumnId = 15, strFormCode = '06-168DD', strScheduleCode = '06-146', strType = '', strColumn = 'strVendorLicenseNumber', strCaption = 'Seller License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328792
	UNION ALL SELECT intScheduleColumnId = 16, strFormCode = '06-168DD', strScheduleCode = '06-146', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328793
	UNION ALL SELECT intScheduleColumnId = 17, strFormCode = '06-168DD', strScheduleCode = '06-146', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328794
	UNION ALL SELECT intScheduleColumnId = 18, strFormCode = '06-168DD', strScheduleCode = '06-146', strType = '', strColumn = 'strBillofLading', strCaption = 'Doc Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328795
	UNION ALL SELECT intScheduleColumnId = 19, strFormCode = '06-168DD', strScheduleCode = '06-146', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328796
	UNION ALL SELECT intScheduleColumnId = 20, strFormCode = '06-168DD', strScheduleCode = '06-146', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328797
	UNION ALL SELECT intScheduleColumnId = 21, strFormCode = '06-168GD', strScheduleCode = '06-146', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328798
	UNION ALL SELECT intScheduleColumnId = 22, strFormCode = '06-168GD', strScheduleCode = '06-146', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328799
	UNION ALL SELECT intScheduleColumnId = 23, strFormCode = '06-168GD', strScheduleCode = '06-146', strType = '', strColumn = 'strTransporterLicense', strCaption = 'Carrier License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328800
	UNION ALL SELECT intScheduleColumnId = 24, strFormCode = '06-168GD', strScheduleCode = '06-146', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328801
	UNION ALL SELECT intScheduleColumnId = 25, strFormCode = '06-168GD', strScheduleCode = '06-146', strType = '', strColumn = 'strVendorLicenseNumber', strCaption = 'Seller License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328802
	UNION ALL SELECT intScheduleColumnId = 26, strFormCode = '06-168GD', strScheduleCode = '06-146', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328803
	UNION ALL SELECT intScheduleColumnId = 27, strFormCode = '06-168GD', strScheduleCode = '06-146', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328804
	UNION ALL SELECT intScheduleColumnId = 28, strFormCode = '06-168GD', strScheduleCode = '06-146', strType = '', strColumn = 'strBillofLading', strCaption = 'Doc Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328805
	UNION ALL SELECT intScheduleColumnId = 29, strFormCode = '06-168GD', strScheduleCode = '06-146', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328806
	UNION ALL SELECT intScheduleColumnId = 30, strFormCode = '06-168GD', strScheduleCode = '06-146', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328807
	UNION ALL SELECT intScheduleColumnId = 31, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Dyed Diesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328808
	UNION ALL SELECT intScheduleColumnId = 32, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Dyed Diesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328809
	UNION ALL SELECT intScheduleColumnId = 33, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Dyed Diesel', strColumn = 'strTransporterLicense', strCaption = 'Carrier License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328810
	UNION ALL SELECT intScheduleColumnId = 34, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Dyed Diesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328811
	UNION ALL SELECT intScheduleColumnId = 35, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Dyed Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328812
	UNION ALL SELECT intScheduleColumnId = 36, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Dyed Diesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328813
	UNION ALL SELECT intScheduleColumnId = 37, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Dyed Diesel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328814
	UNION ALL SELECT intScheduleColumnId = 38, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Dyed Diesel', strColumn = 'strImportVerificationNumber', strCaption = 'Import Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328815
	UNION ALL SELECT intScheduleColumnId = 39, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Dyed Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328816
	UNION ALL SELECT intScheduleColumnId = 40, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Dyed Diesel', strColumn = 'strBillofLading', strCaption = 'Doc Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328817
	UNION ALL SELECT intScheduleColumnId = 41, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Dyed Diesel', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328818
	UNION ALL SELECT intScheduleColumnId = 42, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Dyed Diesel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328819
	UNION ALL SELECT intScheduleColumnId = 43, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Undyed Diesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328820
	UNION ALL SELECT intScheduleColumnId = 44, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Undyed Diesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328821
	UNION ALL SELECT intScheduleColumnId = 45, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Undyed Diesel', strColumn = 'strTransporterLicense', strCaption = 'Carrier License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328822
	UNION ALL SELECT intScheduleColumnId = 46, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Undyed Diesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328823
	UNION ALL SELECT intScheduleColumnId = 47, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Undyed Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328824
	UNION ALL SELECT intScheduleColumnId = 48, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Undyed Diesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328825
	UNION ALL SELECT intScheduleColumnId = 49, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Undyed Diesel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328826
	UNION ALL SELECT intScheduleColumnId = 50, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Undyed Diesel', strColumn = 'strImportVerificationNumber', strCaption = 'Import Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328827
	UNION ALL SELECT intScheduleColumnId = 51, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Undyed Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328828
	UNION ALL SELECT intScheduleColumnId = 52, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Undyed Diesel', strColumn = 'strBillofLading', strCaption = 'Doc Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328829
	UNION ALL SELECT intScheduleColumnId = 53, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Undyed Diesel', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328830
	UNION ALL SELECT intScheduleColumnId = 54, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Undyed Diesel', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328831
	UNION ALL SELECT intScheduleColumnId = 55, strFormCode = '06-168GD', strScheduleCode = '06-148', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328832
	UNION ALL SELECT intScheduleColumnId = 56, strFormCode = '06-168GD', strScheduleCode = '06-148', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328833
	UNION ALL SELECT intScheduleColumnId = 57, strFormCode = '06-168GD', strScheduleCode = '06-148', strType = 'Gasoline', strColumn = 'strTransporterLicense', strCaption = 'Carrier License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328834
	UNION ALL SELECT intScheduleColumnId = 58, strFormCode = '06-168GD', strScheduleCode = '06-148', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328835
	UNION ALL SELECT intScheduleColumnId = 59, strFormCode = '06-168GD', strScheduleCode = '06-148', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328836
	UNION ALL SELECT intScheduleColumnId = 60, strFormCode = '06-168GD', strScheduleCode = '06-148', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328837
	UNION ALL SELECT intScheduleColumnId = 61, strFormCode = '06-168GD', strScheduleCode = '06-148', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328838
	UNION ALL SELECT intScheduleColumnId = 62, strFormCode = '06-168GD', strScheduleCode = '06-148', strType = 'Gasoline', strColumn = 'strImportVerificationNumber', strCaption = 'Import Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328839
	UNION ALL SELECT intScheduleColumnId = 63, strFormCode = '06-168GD', strScheduleCode = '06-148', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328840
	UNION ALL SELECT intScheduleColumnId = 64, strFormCode = '06-168GD', strScheduleCode = '06-148', strType = 'Gasoline', strColumn = 'strBillofLading', strCaption = 'Doc Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328841
	UNION ALL SELECT intScheduleColumnId = 65, strFormCode = '06-168GD', strScheduleCode = '06-148', strType = 'Gasoline', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328842
	UNION ALL SELECT intScheduleColumnId = 66, strFormCode = '06-168GD', strScheduleCode = '06-148', strType = 'Gasoline', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328843
	UNION ALL SELECT intScheduleColumnId = 67, strFormCode = '06-168DD', strScheduleCode = '06-149', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328844
	UNION ALL SELECT intScheduleColumnId = 68, strFormCode = '06-168DD', strScheduleCode = '06-149', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328845
	UNION ALL SELECT intScheduleColumnId = 69, strFormCode = '06-168DD', strScheduleCode = '06-149', strType = '', strColumn = 'strTransporterLicense', strCaption = 'Carrier License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328846
	UNION ALL SELECT intScheduleColumnId = 70, strFormCode = '06-168DD', strScheduleCode = '06-149', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328847
	UNION ALL SELECT intScheduleColumnId = 71, strFormCode = '06-168DD', strScheduleCode = '06-149', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328848
	UNION ALL SELECT intScheduleColumnId = 72, strFormCode = '06-168DD', strScheduleCode = '06-149', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328849
	UNION ALL SELECT intScheduleColumnId = 73, strFormCode = '06-168DD', strScheduleCode = '06-149', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328850
	UNION ALL SELECT intScheduleColumnId = 74, strFormCode = '06-168DD', strScheduleCode = '06-149', strType = '', strColumn = 'strImportVerificationNumber', strCaption = 'Import Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328851
	UNION ALL SELECT intScheduleColumnId = 75, strFormCode = '06-168DD', strScheduleCode = '06-149', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328852
	UNION ALL SELECT intScheduleColumnId = 76, strFormCode = '06-168DD', strScheduleCode = '06-149', strType = '', strColumn = 'strBillofLading', strCaption = 'Doc Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328853
	UNION ALL SELECT intScheduleColumnId = 77, strFormCode = '06-168DD', strScheduleCode = '06-149', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328854
	UNION ALL SELECT intScheduleColumnId = 78, strFormCode = '06-168DD', strScheduleCode = '06-149', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328855
	UNION ALL SELECT intScheduleColumnId = 79, strFormCode = '06-168GD', strScheduleCode = '06-149', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328856
	UNION ALL SELECT intScheduleColumnId = 80, strFormCode = '06-168GD', strScheduleCode = '06-149', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328857
	UNION ALL SELECT intScheduleColumnId = 81, strFormCode = '06-168GD', strScheduleCode = '06-149', strType = '', strColumn = 'strTransporterLicense', strCaption = 'Carrier License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328858
	UNION ALL SELECT intScheduleColumnId = 82, strFormCode = '06-168GD', strScheduleCode = '06-149', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328859
	UNION ALL SELECT intScheduleColumnId = 83, strFormCode = '06-168GD', strScheduleCode = '06-149', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328860
	UNION ALL SELECT intScheduleColumnId = 84, strFormCode = '06-168GD', strScheduleCode = '06-149', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328861
	UNION ALL SELECT intScheduleColumnId = 85, strFormCode = '06-168GD', strScheduleCode = '06-149', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328862
	UNION ALL SELECT intScheduleColumnId = 86, strFormCode = '06-168GD', strScheduleCode = '06-149', strType = '', strColumn = 'strImportVerificationNumber', strCaption = 'Import Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328863
	UNION ALL SELECT intScheduleColumnId = 87, strFormCode = '06-168GD', strScheduleCode = '06-149', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328864
	UNION ALL SELECT intScheduleColumnId = 88, strFormCode = '06-168GD', strScheduleCode = '06-149', strType = '', strColumn = 'strBillofLading', strCaption = 'Doc Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328865
	UNION ALL SELECT intScheduleColumnId = 89, strFormCode = '06-168GD', strScheduleCode = '06-149', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328866
	UNION ALL SELECT intScheduleColumnId = 90, strFormCode = '06-168GD', strScheduleCode = '06-149', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328867
	UNION ALL SELECT intScheduleColumnId = 91, strFormCode = '06-168DD', strScheduleCode = '06-150', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328868
	UNION ALL SELECT intScheduleColumnId = 92, strFormCode = '06-168DD', strScheduleCode = '06-150', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328869
	UNION ALL SELECT intScheduleColumnId = 93, strFormCode = '06-168DD', strScheduleCode = '06-150', strType = '', strColumn = 'strTransporterLicense', strCaption = 'Carrier License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328870
	UNION ALL SELECT intScheduleColumnId = 94, strFormCode = '06-168DD', strScheduleCode = '06-150', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328871
	UNION ALL SELECT intScheduleColumnId = 95, strFormCode = '06-168DD', strScheduleCode = '06-150', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328872
	UNION ALL SELECT intScheduleColumnId = 96, strFormCode = '06-168DD', strScheduleCode = '06-150', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328873
	UNION ALL SELECT intScheduleColumnId = 97, strFormCode = '06-168GD', strScheduleCode = '06-150', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328874
	UNION ALL SELECT intScheduleColumnId = 98, strFormCode = '06-168GD', strScheduleCode = '06-150', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328875
	UNION ALL SELECT intScheduleColumnId = 99, strFormCode = '06-168GD', strScheduleCode = '06-150', strType = '', strColumn = 'strTransporterLicense', strCaption = 'Carrier License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328876
	UNION ALL SELECT intScheduleColumnId = 100, strFormCode = '06-168GD', strScheduleCode = '06-150', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328877
	UNION ALL SELECT intScheduleColumnId = 101, strFormCode = '06-168GD', strScheduleCode = '06-150', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328878
	UNION ALL SELECT intScheduleColumnId = 102, strFormCode = '06-168GD', strScheduleCode = '06-150', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328879
	UNION ALL SELECT intScheduleColumnId = 103, strFormCode = '06-168DD', strScheduleCode = '06-151', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328880
	UNION ALL SELECT intScheduleColumnId = 104, strFormCode = '06-168DD', strScheduleCode = '06-151', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328881
	UNION ALL SELECT intScheduleColumnId = 105, strFormCode = '06-168DD', strScheduleCode = '06-151', strType = '', strColumn = 'strTransporterLicense', strCaption = 'Carrier License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328882
	UNION ALL SELECT intScheduleColumnId = 106, strFormCode = '06-168DD', strScheduleCode = '06-151', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328883
	UNION ALL SELECT intScheduleColumnId = 107, strFormCode = '06-168DD', strScheduleCode = '06-151', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328884
	UNION ALL SELECT intScheduleColumnId = 108, strFormCode = '06-168DD', strScheduleCode = '06-151', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328885
	UNION ALL SELECT intScheduleColumnId = 109, strFormCode = '06-168DD', strScheduleCode = '06-152', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328886
	UNION ALL SELECT intScheduleColumnId = 110, strFormCode = '06-168DD', strScheduleCode = '06-152', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328887
	UNION ALL SELECT intScheduleColumnId = 111, strFormCode = '06-168DD', strScheduleCode = '06-152', strType = '', strColumn = 'strCustomerLicenseNumber', strCaption = 'Buyer License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328888
	UNION ALL SELECT intScheduleColumnId = 112, strFormCode = '06-168DD', strScheduleCode = '06-152', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328889
	UNION ALL SELECT intScheduleColumnId = 113, strFormCode = '06-168DD', strScheduleCode = '06-152', strType = '', strColumn = 'strBillofLading', strCaption = 'Doc Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328890
	UNION ALL SELECT intScheduleColumnId = 114, strFormCode = '06-168DD', strScheduleCode = '06-152', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328891
	UNION ALL SELECT intScheduleColumnId = 115, strFormCode = '06-168GD', strScheduleCode = '06-152', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328892
	UNION ALL SELECT intScheduleColumnId = 116, strFormCode = '06-168GD', strScheduleCode = '06-152', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328893
	UNION ALL SELECT intScheduleColumnId = 117, strFormCode = '06-168GD', strScheduleCode = '06-152', strType = '', strColumn = 'strCustomerLicenseNumber', strCaption = 'Buyer License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328894
	UNION ALL SELECT intScheduleColumnId = 118, strFormCode = '06-168GD', strScheduleCode = '06-152', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328895
	UNION ALL SELECT intScheduleColumnId = 119, strFormCode = '06-168GD', strScheduleCode = '06-152', strType = '', strColumn = 'strBillofLading', strCaption = 'Doc Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328896
	UNION ALL SELECT intScheduleColumnId = 120, strFormCode = '06-168GD', strScheduleCode = '06-152', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328897
	UNION ALL SELECT intScheduleColumnId = 121, strFormCode = '06-168DD', strScheduleCode = '06-155', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328898
	UNION ALL SELECT intScheduleColumnId = 122, strFormCode = '06-168DD', strScheduleCode = '06-155', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328899
	UNION ALL SELECT intScheduleColumnId = 123, strFormCode = '06-168DD', strScheduleCode = '06-155', strType = '', strColumn = 'strTransporterLicense', strCaption = 'Carrier License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328900
	UNION ALL SELECT intScheduleColumnId = 124, strFormCode = '06-168DD', strScheduleCode = '06-155', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328901
	UNION ALL SELECT intScheduleColumnId = 125, strFormCode = '06-168DD', strScheduleCode = '06-155', strType = '', strColumn = 'strCustomerLicenseNumber', strCaption = 'Buyer License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328902
	UNION ALL SELECT intScheduleColumnId = 126, strFormCode = '06-168DD', strScheduleCode = '06-155', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328903
	UNION ALL SELECT intScheduleColumnId = 127, strFormCode = '06-168DD', strScheduleCode = '06-155', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328904
	UNION ALL SELECT intScheduleColumnId = 128, strFormCode = '06-168DD', strScheduleCode = '06-155', strType = '', strColumn = 'strBillofLading', strCaption = 'Doc Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328905
	UNION ALL SELECT intScheduleColumnId = 129, strFormCode = '06-168DD', strScheduleCode = '06-155', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328906
	UNION ALL SELECT intScheduleColumnId = 130, strFormCode = '06-168DD', strScheduleCode = '06-155', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328907
	UNION ALL SELECT intScheduleColumnId = 131, strFormCode = '06-168DD', strScheduleCode = '06-156', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328908
	UNION ALL SELECT intScheduleColumnId = 132, strFormCode = '06-168DD', strScheduleCode = '06-156', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328909
	UNION ALL SELECT intScheduleColumnId = 133, strFormCode = '06-168DD', strScheduleCode = '06-156', strType = '', strColumn = 'strTransporterLicense', strCaption = 'Carrier License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328910
	UNION ALL SELECT intScheduleColumnId = 134, strFormCode = '06-168DD', strScheduleCode = '06-156', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328911
	UNION ALL SELECT intScheduleColumnId = 135, strFormCode = '06-168DD', strScheduleCode = '06-156', strType = '', strColumn = 'strCustomerLicenseNumber', strCaption = 'Buyer License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328912
	UNION ALL SELECT intScheduleColumnId = 136, strFormCode = '06-168DD', strScheduleCode = '06-156', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328913
	UNION ALL SELECT intScheduleColumnId = 137, strFormCode = '06-168DD', strScheduleCode = '06-156', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328914
	UNION ALL SELECT intScheduleColumnId = 138, strFormCode = '06-168DD', strScheduleCode = '06-156', strType = '', strColumn = 'strBillofLading', strCaption = 'Doc Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328915
	UNION ALL SELECT intScheduleColumnId = 139, strFormCode = '06-168DD', strScheduleCode = '06-156', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328916
	UNION ALL SELECT intScheduleColumnId = 140, strFormCode = '06-168DD', strScheduleCode = '06-156', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328917
	UNION ALL SELECT intScheduleColumnId = 141, strFormCode = '06-168GD', strScheduleCode = '06-156', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328918
	UNION ALL SELECT intScheduleColumnId = 142, strFormCode = '06-168GD', strScheduleCode = '06-156', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328919
	UNION ALL SELECT intScheduleColumnId = 143, strFormCode = '06-168GD', strScheduleCode = '06-156', strType = '', strColumn = 'strTransporterLicense', strCaption = 'Carrier License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328920
	UNION ALL SELECT intScheduleColumnId = 144, strFormCode = '06-168GD', strScheduleCode = '06-156', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328921
	UNION ALL SELECT intScheduleColumnId = 145, strFormCode = '06-168GD', strScheduleCode = '06-156', strType = '', strColumn = 'strCustomerLicenseNumber', strCaption = 'Buyer License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328922
	UNION ALL SELECT intScheduleColumnId = 146, strFormCode = '06-168GD', strScheduleCode = '06-156', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328923
	UNION ALL SELECT intScheduleColumnId = 147, strFormCode = '06-168GD', strScheduleCode = '06-156', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328924
	UNION ALL SELECT intScheduleColumnId = 148, strFormCode = '06-168GD', strScheduleCode = '06-156', strType = '', strColumn = 'strBillofLading', strCaption = 'Doc Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328925
	UNION ALL SELECT intScheduleColumnId = 149, strFormCode = '06-168GD', strScheduleCode = '06-156', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328926
	UNION ALL SELECT intScheduleColumnId = 150, strFormCode = '06-168GD', strScheduleCode = '06-156', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328927
	UNION ALL SELECT intScheduleColumnId = 151, strFormCode = '06-168DD', strScheduleCode = '06-157', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328928
	UNION ALL SELECT intScheduleColumnId = 152, strFormCode = '06-168DD', strScheduleCode = '06-157', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328929
	UNION ALL SELECT intScheduleColumnId = 153, strFormCode = '06-168DD', strScheduleCode = '06-157', strType = '', strColumn = 'strTransporterLicense', strCaption = 'Carrier License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328930
	UNION ALL SELECT intScheduleColumnId = 154, strFormCode = '06-168DD', strScheduleCode = '06-157', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328931
	UNION ALL SELECT intScheduleColumnId = 155, strFormCode = '06-168DD', strScheduleCode = '06-157', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328932
	UNION ALL SELECT intScheduleColumnId = 156, strFormCode = '06-168DD', strScheduleCode = '06-157', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328933
	UNION ALL SELECT intScheduleColumnId = 157, strFormCode = '06-168DD', strScheduleCode = '06-157', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328934
	UNION ALL SELECT intScheduleColumnId = 158, strFormCode = '06-168DD', strScheduleCode = '06-157', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328935
	UNION ALL SELECT intScheduleColumnId = 159, strFormCode = '06-168DD', strScheduleCode = '06-157', strType = '', strColumn = 'strBillofLading', strCaption = 'Doc Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328936
	UNION ALL SELECT intScheduleColumnId = 160, strFormCode = '06-168DD', strScheduleCode = '06-157', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328937
	UNION ALL SELECT intScheduleColumnId = 161, strFormCode = '06-168DD', strScheduleCode = '06-157', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328938
	UNION ALL SELECT intScheduleColumnId = 162, strFormCode = '06-168GD', strScheduleCode = '06-157', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328939
	UNION ALL SELECT intScheduleColumnId = 163, strFormCode = '06-168GD', strScheduleCode = '06-157', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328940
	UNION ALL SELECT intScheduleColumnId = 164, strFormCode = '06-168GD', strScheduleCode = '06-157', strType = '', strColumn = 'strTransporterLicense', strCaption = 'Carrier License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328941
	UNION ALL SELECT intScheduleColumnId = 165, strFormCode = '06-168GD', strScheduleCode = '06-157', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328942
	UNION ALL SELECT intScheduleColumnId = 166, strFormCode = '06-168GD', strScheduleCode = '06-157', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328943
	UNION ALL SELECT intScheduleColumnId = 167, strFormCode = '06-168GD', strScheduleCode = '06-157', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328944
	UNION ALL SELECT intScheduleColumnId = 168, strFormCode = '06-168GD', strScheduleCode = '06-157', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328945
	UNION ALL SELECT intScheduleColumnId = 169, strFormCode = '06-168GD', strScheduleCode = '06-157', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328946
	UNION ALL SELECT intScheduleColumnId = 170, strFormCode = '06-168GD', strScheduleCode = '06-157', strType = '', strColumn = 'strBillofLading', strCaption = 'Doc Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328947
	UNION ALL SELECT intScheduleColumnId = 171, strFormCode = '06-168GD', strScheduleCode = '06-157', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328948
	UNION ALL SELECT intScheduleColumnId = 172, strFormCode = '06-168GD', strScheduleCode = '06-157', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328949
	UNION ALL SELECT intScheduleColumnId = 173, strFormCode = '06-168DD', strScheduleCode = '06-158', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328950
	UNION ALL SELECT intScheduleColumnId = 174, strFormCode = '06-168DD', strScheduleCode = '06-158', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328951
	UNION ALL SELECT intScheduleColumnId = 175, strFormCode = '06-168DD', strScheduleCode = '06-158', strType = '', strColumn = 'strTransporterLicense', strCaption = 'Carrier License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328952
	UNION ALL SELECT intScheduleColumnId = 176, strFormCode = '06-168DD', strScheduleCode = '06-158', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328953
	UNION ALL SELECT intScheduleColumnId = 177, strFormCode = '06-168DD', strScheduleCode = '06-158', strType = '', strColumn = 'strCustomerLicenseNumber', strCaption = 'Buyer License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328954
	UNION ALL SELECT intScheduleColumnId = 178, strFormCode = '06-168DD', strScheduleCode = '06-158', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328955
	UNION ALL SELECT intScheduleColumnId = 179, strFormCode = '06-168DD', strScheduleCode = '06-158', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328956
	UNION ALL SELECT intScheduleColumnId = 180, strFormCode = '06-168DD', strScheduleCode = '06-158', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328957
	UNION ALL SELECT intScheduleColumnId = 181, strFormCode = '06-168DD', strScheduleCode = '06-158', strType = '', strColumn = 'strBillofLading', strCaption = 'Doc Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328958
	UNION ALL SELECT intScheduleColumnId = 182, strFormCode = '06-168DD', strScheduleCode = '06-158', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328959
	UNION ALL SELECT intScheduleColumnId = 183, strFormCode = '06-168DD', strScheduleCode = '06-158', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328960
	UNION ALL SELECT intScheduleColumnId = 184, strFormCode = '06-168GD', strScheduleCode = '06-158', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328961
	UNION ALL SELECT intScheduleColumnId = 185, strFormCode = '06-168GD', strScheduleCode = '06-158', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328962
	UNION ALL SELECT intScheduleColumnId = 186, strFormCode = '06-168GD', strScheduleCode = '06-158', strType = '', strColumn = 'strTransporterLicense', strCaption = 'Carrier License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328963
	UNION ALL SELECT intScheduleColumnId = 187, strFormCode = '06-168GD', strScheduleCode = '06-158', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328964
	UNION ALL SELECT intScheduleColumnId = 188, strFormCode = '06-168GD', strScheduleCode = '06-158', strType = '', strColumn = 'strCustomerLicenseNumber', strCaption = 'Buyer License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328965
	UNION ALL SELECT intScheduleColumnId = 189, strFormCode = '06-168GD', strScheduleCode = '06-158', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328966
	UNION ALL SELECT intScheduleColumnId = 190, strFormCode = '06-168GD', strScheduleCode = '06-158', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328967
	UNION ALL SELECT intScheduleColumnId = 191, strFormCode = '06-168GD', strScheduleCode = '06-158', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328968
	UNION ALL SELECT intScheduleColumnId = 192, strFormCode = '06-168GD', strScheduleCode = '06-158', strType = '', strColumn = 'strBillofLading', strCaption = 'Doc Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328969
	UNION ALL SELECT intScheduleColumnId = 193, strFormCode = '06-168GD', strScheduleCode = '06-158', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328970
	UNION ALL SELECT intScheduleColumnId = 194, strFormCode = '06-168GD', strScheduleCode = '06-158', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328971
	UNION ALL SELECT intScheduleColumnId = 195, strFormCode = '06-168DD', strScheduleCode = '06-159', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328972
	UNION ALL SELECT intScheduleColumnId = 196, strFormCode = '06-168DD', strScheduleCode = '06-159', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328973
	UNION ALL SELECT intScheduleColumnId = 197, strFormCode = '06-168DD', strScheduleCode = '06-159', strType = '', strColumn = 'strTransporterLicense', strCaption = 'Carrier License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328974
	UNION ALL SELECT intScheduleColumnId = 198, strFormCode = '06-168DD', strScheduleCode = '06-159', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328975
	UNION ALL SELECT intScheduleColumnId = 199, strFormCode = '06-168DD', strScheduleCode = '06-159', strType = '', strColumn = 'strCustomerLicenseNumber', strCaption = 'Buyer License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328976
	UNION ALL SELECT intScheduleColumnId = 200, strFormCode = '06-168DD', strScheduleCode = '06-159', strType = '', strColumn = 'strCustomerAccountStatusCode', strCaption = 'Exempt Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328977
	UNION ALL SELECT intScheduleColumnId = 201, strFormCode = '06-168DD', strScheduleCode = '06-159', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328978
	UNION ALL SELECT intScheduleColumnId = 202, strFormCode = '06-168DD', strScheduleCode = '06-159', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328979
	UNION ALL SELECT intScheduleColumnId = 203, strFormCode = '06-168DD', strScheduleCode = '06-159', strType = '', strColumn = 'strBillofLading', strCaption = 'Doc Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328980
	UNION ALL SELECT intScheduleColumnId = 204, strFormCode = '06-168DD', strScheduleCode = '06-159', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328981
	UNION ALL SELECT intScheduleColumnId = 205, strFormCode = '06-168GD', strScheduleCode = '06-159', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328982
	UNION ALL SELECT intScheduleColumnId = 206, strFormCode = '06-168GD', strScheduleCode = '06-159', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328983
	UNION ALL SELECT intScheduleColumnId = 207, strFormCode = '06-168GD', strScheduleCode = '06-159', strType = '', strColumn = 'strTransporterLicense', strCaption = 'Carrier License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328984
	UNION ALL SELECT intScheduleColumnId = 208, strFormCode = '06-168GD', strScheduleCode = '06-159', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328985
	UNION ALL SELECT intScheduleColumnId = 209, strFormCode = '06-168GD', strScheduleCode = '06-159', strType = '', strColumn = 'strCustomerLicenseNumber', strCaption = 'Buyer License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328986
	UNION ALL SELECT intScheduleColumnId = 210, strFormCode = '06-168GD', strScheduleCode = '06-159', strType = '', strColumn = 'strCustomerAccountStatusCode', strCaption = 'Exempt Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328987
	UNION ALL SELECT intScheduleColumnId = 211, strFormCode = '06-168GD', strScheduleCode = '06-159', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328988
	UNION ALL SELECT intScheduleColumnId = 212, strFormCode = '06-168GD', strScheduleCode = '06-159', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328989
	UNION ALL SELECT intScheduleColumnId = 213, strFormCode = '06-168GD', strScheduleCode = '06-159', strType = '', strColumn = 'strBillofLading', strCaption = 'Doc Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328990
	UNION ALL SELECT intScheduleColumnId = 214, strFormCode = '06-168GD', strScheduleCode = '06-159', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328991
	UNION ALL SELECT intScheduleColumnId = 215, strFormCode = '06-168DD', strScheduleCode = '06-160', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328992
	UNION ALL SELECT intScheduleColumnId = 216, strFormCode = '06-168DD', strScheduleCode = '06-160', strType = '', strColumn = 'strTXPurchaserSignedStatementNumber', strCaption = 'Purchaser Signed Statement Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328993
	UNION ALL SELECT intScheduleColumnId = 217, strFormCode = '06-168DD', strScheduleCode = '06-160', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328994
	UNION ALL SELECT intScheduleColumnId = 218, strFormCode = '06-168DD', strScheduleCode = '06-161', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328995
	UNION ALL SELECT intScheduleColumnId = 219, strFormCode = '06-168DD', strScheduleCode = '06-161', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328996
	UNION ALL SELECT intScheduleColumnId = 220, strFormCode = '06-168DD', strScheduleCode = '06-161', strType = '', strColumn = 'strTransporterLicense', strCaption = 'Carrier License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328997
	UNION ALL SELECT intScheduleColumnId = 221, strFormCode = '06-168DD', strScheduleCode = '06-161', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328998
	UNION ALL SELECT intScheduleColumnId = 222, strFormCode = '06-168DD', strScheduleCode = '06-161', strType = '', strColumn = 'strCustomerLicenseNumber', strCaption = 'Buyer License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4328999
	UNION ALL SELECT intScheduleColumnId = 223, strFormCode = '06-168DD', strScheduleCode = '06-161', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329000
	UNION ALL SELECT intScheduleColumnId = 224, strFormCode = '06-168DD', strScheduleCode = '06-161', strType = '', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329001
	UNION ALL SELECT intScheduleColumnId = 225, strFormCode = '06-168DD', strScheduleCode = '06-161', strType = '', strColumn = 'strDestinationState', strCaption = 'Revised Destination', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329002
	UNION ALL SELECT intScheduleColumnId = 226, strFormCode = '06-168DD', strScheduleCode = '06-161', strType = '', strColumn = 'strDiversionNumber', strCaption = 'Diversion Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329003
	UNION ALL SELECT intScheduleColumnId = 227, strFormCode = '06-168DD', strScheduleCode = '06-161', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329004
	UNION ALL SELECT intScheduleColumnId = 228, strFormCode = '06-168DD', strScheduleCode = '06-161', strType = '', strColumn = 'strBillofLading', strCaption = 'Doc Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329005
	UNION ALL SELECT intScheduleColumnId = 229, strFormCode = '06-168DD', strScheduleCode = '06-161', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329006
	UNION ALL SELECT intScheduleColumnId = 230, strFormCode = '06-168DD', strScheduleCode = '06-161', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329007
	UNION ALL SELECT intScheduleColumnId = 231, strFormCode = '06-168GD', strScheduleCode = '06-161', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329008
	UNION ALL SELECT intScheduleColumnId = 232, strFormCode = '06-168GD', strScheduleCode = '06-161', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329009
	UNION ALL SELECT intScheduleColumnId = 233, strFormCode = '06-168GD', strScheduleCode = '06-161', strType = '', strColumn = 'strTransporterLicense', strCaption = 'Carrier License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329010
	UNION ALL SELECT intScheduleColumnId = 234, strFormCode = '06-168GD', strScheduleCode = '06-161', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329011
	UNION ALL SELECT intScheduleColumnId = 235, strFormCode = '06-168GD', strScheduleCode = '06-161', strType = '', strColumn = 'strCustomerLicenseNumber', strCaption = 'Buyer License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329012
	UNION ALL SELECT intScheduleColumnId = 236, strFormCode = '06-168GD', strScheduleCode = '06-161', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329013
	UNION ALL SELECT intScheduleColumnId = 237, strFormCode = '06-168GD', strScheduleCode = '06-161', strType = '', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329014
	UNION ALL SELECT intScheduleColumnId = 238, strFormCode = '06-168GD', strScheduleCode = '06-161', strType = '', strColumn = 'strDestinationState', strCaption = 'Revised Destination', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329015
	UNION ALL SELECT intScheduleColumnId = 239, strFormCode = '06-168GD', strScheduleCode = '06-161', strType = '', strColumn = 'strDiversionNumber', strCaption = 'Diversion Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329016
	UNION ALL SELECT intScheduleColumnId = 240, strFormCode = '06-168GD', strScheduleCode = '06-161', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329017
	UNION ALL SELECT intScheduleColumnId = 241, strFormCode = '06-168GD', strScheduleCode = '06-161', strType = '', strColumn = 'strBillofLading', strCaption = 'Doc Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329018
	UNION ALL SELECT intScheduleColumnId = 242, strFormCode = '06-168GD', strScheduleCode = '06-161', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329019
	UNION ALL SELECT intScheduleColumnId = 243, strFormCode = '06-168GD', strScheduleCode = '06-161', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329020
	UNION ALL SELECT intScheduleColumnId = 244, strFormCode = '06-168DD', strScheduleCode = '06-190', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329021
	UNION ALL SELECT intScheduleColumnId = 245, strFormCode = '06-168DD', strScheduleCode = '06-190', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329022
	UNION ALL SELECT intScheduleColumnId = 246, strFormCode = '06-168DD', strScheduleCode = '06-190', strType = '', strColumn = 'strTransporterLicense', strCaption = 'Carrier License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329023
	UNION ALL SELECT intScheduleColumnId = 247, strFormCode = '06-168DD', strScheduleCode = '06-190', strType = '', strColumn = 'strVendorName', strCaption = 'Purchased From Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329024
	UNION ALL SELECT intScheduleColumnId = 248, strFormCode = '06-168DD', strScheduleCode = '06-190', strType = '', strColumn = 'strVendorLicenseNumber', strCaption = 'Purchased From Licesne Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329025
	UNION ALL SELECT intScheduleColumnId = 249, strFormCode = '06-168DD', strScheduleCode = '06-190', strType = '', strColumn = 'strCustomerName', strCaption = 'Sold To Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329026
	UNION ALL SELECT intScheduleColumnId = 250, strFormCode = '06-168DD', strScheduleCode = '06-190', strType = '', strColumn = 'strCustomerLicenseNumber', strCaption = 'Sold To License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329027
	UNION ALL SELECT intScheduleColumnId = 251, strFormCode = '06-168DD', strScheduleCode = '06-190', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329028
	UNION ALL SELECT intScheduleColumnId = 252, strFormCode = '06-168DD', strScheduleCode = '06-190', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329029
	UNION ALL SELECT intScheduleColumnId = 253, strFormCode = '06-168DD', strScheduleCode = '06-190', strType = '', strColumn = 'dtmDate', strCaption = 'Date Removed', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329030
	UNION ALL SELECT intScheduleColumnId = 254, strFormCode = '06-168DD', strScheduleCode = '06-190', strType = '', strColumn = 'strBillofLading', strCaption = 'Doc Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329031
	UNION ALL SELECT intScheduleColumnId = 255, strFormCode = '06-168DD', strScheduleCode = '06-190', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329032
	UNION ALL SELECT intScheduleColumnId = 256, strFormCode = '06-168DD', strScheduleCode = '06-190', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329033
	UNION ALL SELECT intScheduleColumnId = 257, strFormCode = '06-168DD', strScheduleCode = '06-190', strType = '', strColumn = 'dtmDate', strCaption = 'Date Sold', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329034
	UNION ALL SELECT intScheduleColumnId = 258, strFormCode = '06-168GD', strScheduleCode = '06-190', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329035
	UNION ALL SELECT intScheduleColumnId = 259, strFormCode = '06-168GD', strScheduleCode = '06-190', strType = '', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329036
	UNION ALL SELECT intScheduleColumnId = 260, strFormCode = '06-168GD', strScheduleCode = '06-190', strType = '', strColumn = 'strTransporterLicense', strCaption = 'Carrier License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329037
	UNION ALL SELECT intScheduleColumnId = 261, strFormCode = '06-168GD', strScheduleCode = '06-190', strType = '', strColumn = 'strVendorName', strCaption = 'Purchased From Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329038
	UNION ALL SELECT intScheduleColumnId = 262, strFormCode = '06-168GD', strScheduleCode = '06-190', strType = '', strColumn = 'strVendorLicenseNumber', strCaption = 'Purchased From Licesne Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329039
	UNION ALL SELECT intScheduleColumnId = 263, strFormCode = '06-168GD', strScheduleCode = '06-190', strType = '', strColumn = 'strCustomerName', strCaption = 'Sold To Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329040
	UNION ALL SELECT intScheduleColumnId = 264, strFormCode = '06-168GD', strScheduleCode = '06-190', strType = '', strColumn = 'strCustomerLicenseNumber', strCaption = 'Sold To License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329041
	UNION ALL SELECT intScheduleColumnId = 265, strFormCode = '06-168GD', strScheduleCode = '06-190', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329042
	UNION ALL SELECT intScheduleColumnId = 266, strFormCode = '06-168GD', strScheduleCode = '06-190', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329043
	UNION ALL SELECT intScheduleColumnId = 267, strFormCode = '06-168GD', strScheduleCode = '06-190', strType = '', strColumn = 'dtmDate', strCaption = 'Date Removed', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329044
	UNION ALL SELECT intScheduleColumnId = 268, strFormCode = '06-168GD', strScheduleCode = '06-190', strType = '', strColumn = 'strBillofLading', strCaption = 'Doc Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329045
	UNION ALL SELECT intScheduleColumnId = 269, strFormCode = '06-168GD', strScheduleCode = '06-190', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329046
	UNION ALL SELECT intScheduleColumnId = 270, strFormCode = '06-168GD', strScheduleCode = '06-190', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329047
	UNION ALL SELECT intScheduleColumnId = 271, strFormCode = '06-168GD', strScheduleCode = '06-190', strType = '', strColumn = 'dtmDate', strCaption = 'Date Sold', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329048
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = '06-168DD', strScheduleCode = '06-146', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329049
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Dyed Diesel', strColumn = 'strVendorLicenseNumber', strCaption = 'Seller License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329050
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Undyed Diesel', strColumn = 'strVendorLicenseNumber', strCaption = 'Seller License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329051
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = '06-168GD', strScheduleCode = '06-149', strType = '', strColumn = 'strVendorLicenseNumber', strCaption = 'Seller License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329052
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = '06-168DD', strScheduleCode = '06-149', strType = '', strColumn = 'strVendorLicenseNumber', strCaption = 'Seller License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329053
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = '06-168DD', strScheduleCode = '06-150', strType = '', strColumn = 'strVendorLicenseNumber', strCaption = 'Seller License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329054
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = '06-168GD', strScheduleCode = '06-150', strType = '', strColumn = 'strVendorLicenseNumber', strCaption = 'Seller License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329055
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = '06-168DD', strScheduleCode = '06-151', strType = '', strColumn = 'strVendorLicenseNumber', strCaption = 'Seller License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329056
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = '06-168DD', strScheduleCode = '06-157', strType = '', strColumn = 'strVendorLicenseNumber', strCaption = 'Seller License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329057
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = '06-168GD', strScheduleCode = '06-157', strType = '', strColumn = 'strVendorLicenseNumber', strCaption = 'Seller License Num', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329058
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = '06-168GD', strScheduleCode = '06-190', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Purchased From FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329059
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = '06-168DD', strScheduleCode = '06-190', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Purchased From FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 4329060


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
	SELECT intFilingPacketId = 0, strFormCode = '06-168DD', strScheduleCode = '06-145', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 433365
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '06-168DD', strScheduleCode = '06-146', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 433366
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Dyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 433367
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '06-168DD', strScheduleCode = '06-148', strType = 'Undyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 433368
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '06-168DD', strScheduleCode = '06-149', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 433369
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '06-168DD', strScheduleCode = '06-150', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 433370
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '06-168DD', strScheduleCode = '06-151', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 433371
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '06-168DD', strScheduleCode = '06-152', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 433372
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '06-168DD', strScheduleCode = '06-155', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 433373
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '06-168DD', strScheduleCode = '06-156', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 433374
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '06-168DD', strScheduleCode = '06-157', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 433375
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '06-168DD', strScheduleCode = '06-158', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 433376
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '06-168DD', strScheduleCode = '06-159', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 433377
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '06-168DD', strScheduleCode = '06-160', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 433378
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '06-168DD', strScheduleCode = '06-161', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 433379
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '06-168DD', strScheduleCode = '06-190', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 433380
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '06-168GD', strScheduleCode = '06-146', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 433381
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '06-168GD', strScheduleCode = '06-148', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 433382
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '06-168GD', strScheduleCode = '06-149', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 433383
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '06-168GD', strScheduleCode = '06-150', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 433384
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '06-168GD', strScheduleCode = '06-152', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 433385
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '06-168GD', strScheduleCode = '06-156', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 433386
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '06-168GD', strScheduleCode = '06-157', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 433387
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '06-168GD', strScheduleCode = '06-158', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 433388
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '06-168GD', strScheduleCode = '06-159', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 433389
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '06-168GD', strScheduleCode = '06-161', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 433390
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = '06-168GD', strScheduleCode = '06-190', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 433391
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'TX E-file', strScheduleCode = '', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 433392

	EXEC uspTFUpgradeFilingPackets @TaxAuthorityCode = @TaxAuthorityCode, @FilingPackets = @FilingPackets

END

GO