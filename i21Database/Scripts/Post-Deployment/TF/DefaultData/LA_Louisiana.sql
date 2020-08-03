DECLARE @TaxAuthorityCode NVARCHAR(10) = 'LA'
	, @TaxAuthorityId INT

SELECT @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = @TaxAuthorityCode AND ysnFilingForThisTA = 1

IF(@TaxAuthorityId IS NOT NULL)
BEGIN

	PRINT ('Deploying Louisiana Tax Forms')

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
	SELECT intProductCodeId = 0, strProductCode = '065', strDescription = 'Gasoline', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 182522
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '123', strDescription = 'Alcohol', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 182523
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '125', strDescription = 'Aviation Gasoline', strProductCodeGroup = 'Aviation', strNote = NULL, intMasterId = 182524
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '130', strDescription = 'Jet Fuel', strProductCodeGroup = 'Aviation', strNote = NULL, intMasterId = 182525
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '124', strDescription = 'Gasohol', strProductCodeGroup = 'Gasohol', strNote = NULL, intMasterId = 182526
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '142', strDescription = 'Kerosene - Undyed', strProductCodeGroup = 'Diesel - Undyed', strNote = NULL, intMasterId = 182527
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '160', strDescription = 'Diesel - Undyed', strProductCodeGroup = 'Diesel - Undyed', strNote = NULL, intMasterId = 182528
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '170', strDescription = 'Biodiesel - Undyed', strProductCodeGroup = 'Diesel - Undyed', strNote = NULL, intMasterId = 182529
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '072', strDescription = 'Kerosene - Dyed', strProductCodeGroup = 'Diesel - Dyed', strNote = NULL, intMasterId = 182530
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '228', strDescription = 'Diesel - Dyed', strProductCodeGroup = 'Diesel - Dyed', strNote = NULL, intMasterId = 182531
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '171', strDescription = 'Biodiesel - Dyed', strProductCodeGroup = 'Diesel - Dyed', strNote = NULL, intMasterId = 182532

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
	SELECT intReportingComponentId = 0, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-23', strScheduleName = 'Gallons Transported into LA', strType = 'Gasohol', strNote = '23', strTransactionType = 'Invoice', intSort = 10, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182531, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-23', strScheduleName = 'Gallons Transported into LA', strType = 'Gasoline', strNote = '23', strTransactionType = 'Invoice', intSort = 20, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182532, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-23', strScheduleName = 'Gallons Transported into LA', strType = 'Undyed Diesel', strNote = '23', strTransactionType = 'Invoice', intSort = 30, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182533, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-23', strScheduleName = 'Gallons Transported into LA', strType = 'Dyed Diesel', strNote = '23', strTransactionType = 'Invoice', intSort = 40, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182534, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-23', strScheduleName = 'Gallons Transported into LA', strType = 'Aviation Fuels', strNote = '23', strTransactionType = 'Invoice', intSort = 50, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182535, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-24', strScheduleName = 'Gallons Transported out of LA', strType = 'Gasohol', strNote = '24', strTransactionType = 'Invoice', intSort = 60, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182536, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-24', strScheduleName = 'Gallons Transported out of LA', strType = 'Gasoline', strNote = '24', strTransactionType = 'Invoice', intSort = 70, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182537, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-24', strScheduleName = 'Gallons Transported out of LA', strType = 'Undyed Diesel', strNote = '24', strTransactionType = 'Invoice', intSort = 80, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182538, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-24', strScheduleName = 'Gallons Transported out of LA', strType = 'Dyed Diesel', strNote = '24', strTransactionType = 'Invoice', intSort = 90, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182539, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-24', strScheduleName = 'Gallons Transported out of LA', strType = 'Aviation Fuels', strNote = '24', strTransactionType = 'Invoice', intSort = 100, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182540, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-25', strScheduleName = 'Gallons Transported within LA', strType = 'Gasohol', strNote = '25', strTransactionType = 'Invoice', intSort = 110, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182541, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-25', strScheduleName = 'Gallons Transported within LA', strType = 'Gasoline', strNote = '25', strTransactionType = 'Invoice', intSort = 120, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182542, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-25', strScheduleName = 'Gallons Transported within LA', strType = 'Undyed Diesel', strNote = '25', strTransactionType = 'Invoice', intSort = 130, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182543, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-25', strScheduleName = 'Gallons Transported within LA', strType = 'Dyed Diesel', strNote = '25', strTransactionType = 'Invoice', intSort = 140, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182544, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'G-25', strScheduleName = 'Gallons Transported within LA', strType = 'Aviation Fuels', strNote = '25', strTransactionType = 'Invoice', intSort = 150, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182545, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5346', strFormName = 'Transporter Return', strScheduleCode = 'R5346', strScheduleName = 'Main Form', strType = '', strNote = 'LA R-5346 Transporter Return', strTransactionType = NULL, intSort = 160, strStoredProcedure = 'uspTFGenerateLATransporter', intMasterId = 182546, intComponentTypeId = 2
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'A-1', strScheduleName = 'Gallons Received/Imported, LA Tax and Inspection Fee Paid', strType = 'Gasohol', strNote = '1', strTransactionType = 'Invoice', intSort = 170, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182547, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'A-1', strScheduleName = 'Gallons Received/Imported, LA Tax and Inspection Fee Paid', strType = 'Gasoline', strNote = '1', strTransactionType = 'Invoice', intSort = 180, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182548, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'A-1', strScheduleName = 'Gallons Received/Imported, LA Tax and Inspection Fee Paid', strType = 'Undyed Diesel', strNote = '1', strTransactionType = 'Invoice', intSort = 190, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182549, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'A-2', strScheduleName = 'Gallons Received/Imported, LA Inspection Fee Paid', strType = 'Dyed Diesel', strNote = '2', strTransactionType = 'Invoice', intSort = 200, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182550, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'A-2', strScheduleName = 'Gallons Received/Imported, LA Inspection Fee Paid', strType = 'Aviation Fuels', strNote = '2', strTransactionType = 'Invoice', intSort = 210, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182551, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'A-3', strScheduleName = 'Gallons Received/Imported, LA Tax or Fee Unpaid', strType = 'Gasohol', strNote = '3', strTransactionType = 'Invoice', intSort = 220, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182552, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'A-3', strScheduleName = 'Gallons Received/Imported, LA Tax or Fee Unpaid', strType = 'Gasoline', strNote = '3', strTransactionType = 'Invoice', intSort = 230, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182553, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'A-3', strScheduleName = 'Gallons Received/Imported, LA Tax or Fee Unpaid', strType = 'Undyed Diesel', strNote = '3', strTransactionType = 'Invoice', intSort = 240, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182554, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'A-3', strScheduleName = 'Gallons Received/Imported, LA Tax or Fee Unpaid', strType = 'Dyed Diesel', strNote = '3', strTransactionType = 'Invoice', intSort = 250, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182555, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'A-3', strScheduleName = 'Gallons Received/Imported, LA Tax or Fee Unpaid', strType = 'Aviation Fuels', strNote = '3', strTransactionType = 'Invoice', intSort = 260, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182556, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'D-21', strScheduleName = 'Gallons Diverted into LA, LA Tax or Fee Unpaid', strType = 'Gasohol', strNote = '21', strTransactionType = 'Invoice', intSort = 370, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182557, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'D-21', strScheduleName = 'Gallons Diverted into LA, LA Tax or Fee Unpaid', strType = 'Gasoline', strNote = '21', strTransactionType = 'Invoice', intSort = 380, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182558, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'D-21', strScheduleName = 'Gallons Diverted into LA, LA Tax or Fee Unpaid', strType = 'Undyed Diesel', strNote = '21', strTransactionType = 'Invoice', intSort = 390, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182559, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'D-21', strScheduleName = 'Gallons Diverted into LA, LA Tax or Fee Unpaid', strType = 'Dyed Diesel', strNote = '21', strTransactionType = 'Invoice', intSort = 400, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182560, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'D-21', strScheduleName = 'Gallons Diverted into LA, LA Tax or Fee Unpaid', strType = 'Aviation Fuels', strNote = '21', strTransactionType = 'Invoice', intSort = 410, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 182561, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'R-5399', strFormName = 'Importer Return', strScheduleCode = 'R5399', strScheduleName = 'Main Form', strType = '', strNote = 'LA R-5399 Importer Return', strTransactionType = NULL, intSort = 420, strStoredProcedure = 'uspTFGenerateLAImporter', intMasterId = 182562, intComponentTypeId = 2
	
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
	SELECT intTaxCriteriaId = 0, strTaxCategory = 'LA Excise Tax Gasohol', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strCriteria = '<> 0', intMasterId = 18355
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strCriteria = '<> 0', intMasterId = 18356
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'LA Excise Tax Gasoline', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strCriteria = '<> 0', intMasterId = 18357
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strCriteria = '<> 0', intMasterId = 18358
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'LA Excise Tax Diesel Clear', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strCriteria = '<> 0', intMasterId = 18359
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strCriteria = '<> 0', intMasterId = 18360
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strCriteria = '<> 0', intMasterId = 18361
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strCriteria = '<> 0', intMasterId = 18362
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'LA Excise Tax Gasohol', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strCriteria = '= 0', intMasterId = 18363
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strCriteria = '= 0', intMasterId = 18364
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'LA Excise Tax Gasoline', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strCriteria = '= 0', intMasterId = 18365
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strCriteria = '= 0', intMasterId = 18366
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'LA Excise Tax Diesel Clear', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strCriteria = '= 0', intMasterId = 18367
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strCriteria = '= 0', intMasterId = 18368
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strCriteria = '= 0', intMasterId = 18370
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'LA Excise Tax Gasoline', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strCriteria = '= 0', intMasterId = 18371
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strCriteria = '= 0', intMasterId = 18372
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'LA Excise Tax Gasohol', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strCriteria = '= 0', intMasterId = 18373
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strCriteria = '= 0', intMasterId = 18374
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'LA Excise Tax Gasoline', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strCriteria = '= 0', intMasterId = 18375
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strCriteria = '= 0', intMasterId = 18376
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'LA Excise Tax Diesel Clear', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strCriteria = '= 0', intMasterId = 18377
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strCriteria = '= 0', intMasterId = 18378
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strCriteria = '= 0', intMasterId = 18380
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'LA Excise Tax Gasoline', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strCriteria = '= 0', intMasterId = 18381
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'LA Inspection Fee', strState = 'LA', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strCriteria = '= 0', intMasterId = 18382
	
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
	SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', intMasterId = 183549
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', intMasterId = 183554
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', intMasterId = 183547
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', intMasterId = 183529
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', intMasterId = 183535
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '171', strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', intMasterId = 183541
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', intMasterId = 183511
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', intMasterId = 183517
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', intMasterId = 183523
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', intMasterId = 183493
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', intMasterId = 183499
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', intMasterId = 183505
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', intMasterId = 183553
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', intMasterId = 183546
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', intMasterId = 183528
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', intMasterId = 183534
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '171', strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', intMasterId = 183540
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', intMasterId = 183510
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', intMasterId = 183516
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', intMasterId = 183522
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', intMasterId = 183492
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', intMasterId = 183498
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', intMasterId = 183504
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', intMasterId = 183552
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', intMasterId = 183545
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', intMasterId = 183527
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', intMasterId = 183533
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '171', strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', intMasterId = 183539
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', intMasterId = 183509
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', intMasterId = 183515
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', intMasterId = 183521
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', intMasterId = 183491
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', intMasterId = 183497
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', intMasterId = 183556
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '171', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', intMasterId = 183543
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', intMasterId = 183537
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', intMasterId = 183531
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', intMasterId = 183525
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', intMasterId = 183519
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', intMasterId = 183513
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', intMasterId = 183501
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', intMasterId = 183495
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', intMasterId = 183507
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', intMasterId = 183548
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', intMasterId = 183555
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '171', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', intMasterId = 183542
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', intMasterId = 183536
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', intMasterId = 183530
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', intMasterId = 183524
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', intMasterId = 183518
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', intMasterId = 183512
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', intMasterId = 183500
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', intMasterId = 183494
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', intMasterId = 183506
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', intMasterId = 183503
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', intMasterId = 183551
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', intMasterId = 183544
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', intMasterId = 183526
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', intMasterId = 183532
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '171', strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', intMasterId = 183538
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', intMasterId = 183508
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', intMasterId = 183514
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', intMasterId = 183520
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', intMasterId = 183490
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', intMasterId = 183496
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', intMasterId = 183502

	INSERT INTO @ValidOriginStates(
		intValidOriginStateId
		, strFormCode
		, strScheduleCode
		, strType
		, strState
		, strStatus
		, intMasterId
	)
	SELECT intValidOriginStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strState = 'LA', strStatus = 'Exclude', intMasterId = 18416
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strState = 'LA', strStatus = 'Exclude', intMasterId = 18415
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strState = 'LA', strStatus = 'Exclude', intMasterId = 18412
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strState = 'LA', strStatus = 'Exclude', intMasterId = 18413
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strState = 'LA', strStatus = 'Exclude', intMasterId = 18414
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strState = 'LA', strStatus = 'Include', intMasterId = 18421
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18420
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strState = 'LA', strStatus = 'Include', intMasterId = 18417
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strState = 'LA', strStatus = 'Include', intMasterId = 18418
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18419
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strState = 'LA', strStatus = 'Include', intMasterId = 18426
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18425
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strState = 'LA', strStatus = 'Include', intMasterId = 18422
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strState = 'LA', strStatus = 'Include', intMasterId = 18423
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18424

	INSERT INTO @ValidDestinationStates(
		intValidDestinationStateId
		, strFormCode
		, strScheduleCode
		, strType
		, strState
		, strStatus
		, intMasterId
	)
	SELECT intValidDestinationStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strState = 'LA', strStatus = 'Include', intMasterId = 18471
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18470
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strState = 'LA', strStatus = 'Include', intMasterId = 18467
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strState = 'LA', strStatus = 'Include', intMasterId = 18468
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18469
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strState = 'LA', strStatus = 'Exclude', intMasterId = 18476
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strState = 'LA', strStatus = 'Exclude', intMasterId = 18475
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strState = 'LA', strStatus = 'Exclude', intMasterId = 18472
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strState = 'LA', strStatus = 'Exclude', intMasterId = 18473
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strState = 'LA', strStatus = 'Exclude', intMasterId = 18474
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strState = 'LA', strStatus = 'Include', intMasterId = 18481
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18480
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strState = 'LA', strStatus = 'Include', intMasterId = 18477
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strState = 'LA', strStatus = 'Include', intMasterId = 18478
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18479
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strState = 'LA', strStatus = 'Include', intMasterId = 18482
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strState = 'LA', strStatus = 'Include', intMasterId = 18483
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18484
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strState = 'LA', strStatus = 'Include', intMasterId = 18486
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18485
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strState = 'LA', strStatus = 'Include', intMasterId = 18491
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18490
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strState = 'LA', strStatus = 'Include', intMasterId = 18487
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strState = 'LA', strStatus = 'Include', intMasterId = 18488
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18489
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strState = 'LA', strStatus = 'Include', intMasterId = 18496
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18495
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strState = 'LA', strStatus = 'Include', intMasterId = 18492
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strState = 'LA', strStatus = 'Include', intMasterId = 18493
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strState = 'LA', strStatus = 'Include', intMasterId = 18494

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
	SELECT intReportTemplateId = 0, strFormCode = 'R-5346', strScheduleCode = 'R5346', strType = '', strTemplateItemId = 'R-5346-AcctNum', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '1', strDescription = 'LA Transporter Account Number', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '10', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 18342
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'R-5346', strScheduleCode = 'R5346', strType = '', strTemplateItemId = 'R-5346-Penalty', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '2', strDescription = 'Penalty Amount', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '20', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 18724
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'R-5399', strScheduleCode = 'R5399', strType = '', strTemplateItemId = 'R-5339-Line14Gasohol', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '12', strDescription = 'Line 14 Imported from outside of US - Gasohol', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '120', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 18686
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'R-5399', strScheduleCode = 'R5399', strType = '', strTemplateItemId = 'R-5339-Line14Gasoline', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '13', strDescription = 'Line 14 Imported from outside of US - Gasoline', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '130', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 18687
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'R-5399', strScheduleCode = 'R5399', strType = '', strTemplateItemId = 'R-5339-Line14UndyedDiesel', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '14', strDescription = 'Line 14 Imported from outside of US - Undyed Diesel', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '140', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 18688
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'R-5399', strScheduleCode = 'R5399', strType = '', strTemplateItemId = 'R-5339-Line14DyedDiesel', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '15', strDescription = 'Line 14 Imported from outside of US - Dyed Diesel', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '150', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 18689
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'R-5399', strScheduleCode = 'R5399', strType = '', strTemplateItemId = 'R-5339-Line14Aviation', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '16', strDescription = 'Line 14 Imported from outside of US - Aviation Fuels', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '160', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 18690
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'R-5399', strScheduleCode = 'R5399', strType = '', strTemplateItemId = 'R-5399-AcctNumber', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '1', strDescription = 'LA Importer Account Number', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '10', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 18343
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'R-5399', strScheduleCode = 'R5399', strType = '', strTemplateItemId = 'R-5399-TaxRateGasohol', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '2', strDescription = 'Tax Rate - Gasohol', strScheduleList = NULL, strConfiguration = '0.20', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '20', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 18344
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'R-5399', strScheduleCode = 'R5399', strType = '', strTemplateItemId = 'R-5399-TaxRateGasoline', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '3', strDescription = 'Tax Rate - Gasoline', strScheduleList = NULL, strConfiguration = '0.20', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '30', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 18345
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'R-5399', strScheduleCode = 'R5399', strType = '', strTemplateItemId = 'R-5399-TaxRateUndyedDiesel', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '4', strDescription = 'Tax Rate - Undyed Diesel', strScheduleList = NULL, strConfiguration = '0.20', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '40', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 18346
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'R-5399', strScheduleCode = 'R5399', strType = '', strTemplateItemId = 'R-5399-InspRateGasohol', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '5', strDescription = 'Inspection Fee Rate - Gasohol', strScheduleList = NULL, strConfiguration = '0.00125', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '50', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 18347
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'R-5399', strScheduleCode = 'R5399', strType = '', strTemplateItemId = 'R-5399-InspRateGasoline', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '6', strDescription = 'Inspection Fee Rate - Gasoline', strScheduleList = NULL, strConfiguration = '0.00125', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '60', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 18348
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'R-5399', strScheduleCode = 'R5399', strType = '', strTemplateItemId = 'R-5399-InspRateUndyedDiesel', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '7', strDescription = 'Inspection Fee Rate - Undyed Diesel', strScheduleList = NULL, strConfiguration = '0.00125', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '70', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 18349
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'R-5399', strScheduleCode = 'R5399', strType = '', strTemplateItemId = 'R-5399-InspRateDyedDiesel', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '8', strDescription = 'Inspection Fee Rate - Dyed Diesel', strScheduleList = NULL, strConfiguration = '0.00125', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '80', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 18350
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'R-5399', strScheduleCode = 'R5399', strType = '', strTemplateItemId = 'R-5399-InspRateAviation', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '9', strDescription = 'Inspection Fee Rate - Aviation Fuels', strScheduleList = NULL, strConfiguration = '0.00125', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '90', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 18351
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'R-5399', strScheduleCode = 'R5399', strType = '', strTemplateItemId = 'R-5399-Line7', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '10', strDescription = 'Line 7 Penalty', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '100', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 18352
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'R-5399', strScheduleCode = 'R5399', strType = '', strTemplateItemId = 'R-5399-Line8', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '11', strDescription = 'Line 8 Interest', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '110', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 18353
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'R-5399', strScheduleCode = 'R5399', strType = '', strTemplateItemId = 'R-5399-Line16Gasohol', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '17', strDescription = 'Line 16 Other - Gasohol', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '170', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 18354
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'R-5399', strScheduleCode = 'R5399', strType = '', strTemplateItemId = 'R-5399-Line16Gasoline', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '18', strDescription = 'Line 16 Other - Gasoline', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '180', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 18355
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'R-5399', strScheduleCode = 'R5399', strType = '', strTemplateItemId = 'R-5399-Line16UndyedDiesel', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '19', strDescription = 'Line 16 Other - Undyed Diesel', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '190', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 18356
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'R-5399', strScheduleCode = 'R5399', strType = '', strTemplateItemId = 'R-5399-Line16DyedDiesel', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '20', strDescription = 'Line 16 Other - Dyed Diesel', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '200', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 18357
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'R-5399', strScheduleCode = 'R5399', strType = '', strTemplateItemId = 'R-5399-Line16Aviation', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '21', strDescription = 'Line 16 Other - Aviation Fuels', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '210', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 18358
	
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
	+ CASE WHEN ysnFromConfiguration IS NULL THEN ', ysnFromConfiguration = NULL' ELSE ', ysnFromConfiguration = ' + CAST(ysnFromConfiguration AS NVARCHAR(5)) + ''  END
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
		, ysnFromConfiguration
		, intMasterId
	)
	SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189995
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189996
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189997
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189998
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189999
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810000
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810001
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810002
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810003
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810004
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810005
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810006
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189983
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189984
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189985
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189986
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189987
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189988
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189989
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189990
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189991
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189992
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189993
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189994
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189947
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189948
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189949
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189950
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189951
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189952
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189953
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189954
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189955
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189956
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189957
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189958
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189959
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189960
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189961
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189962
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189963
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189964
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189965
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189966
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189967
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189968
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189969
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189970
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189971
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189972
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189973
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189974
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189975
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189976
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189977
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189978
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189979
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189980
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189981
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189982
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810055
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810056
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810057
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810058
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810059
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810060
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810061
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810062
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810063
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810064
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810065
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810066
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810043
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810044
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810045
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810046
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810047
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810048
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810049
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810050
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810051
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810052
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810053
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810054
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810007
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810008
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810009
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810010
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810011
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810012
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810013
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810014
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810015
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810016
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810017
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810018
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810019
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810020
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810021
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810022
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810023
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810024
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810025
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810026
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810027
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810028
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810029
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810030
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810031
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810032
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810033
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810034
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810035
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810036
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810037
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810038
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810039
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810040
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810041
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810042
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810115
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810116
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810117
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810118
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810119
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810120
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810121
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810122
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810123
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810124
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810125
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810126
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810103
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810104
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810105
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810106
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810107
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810108
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810109
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810110
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810111
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810112
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810113
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810114
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810067
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810068
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810069
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810070
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810071
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810072
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810073
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810074
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810075
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810076
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810077
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810078
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810079
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810080
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810081
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810082
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810083
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810084
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810085
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810086
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810087
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810088
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810089
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810090
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810091
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810092
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810093
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810094
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810095
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810096
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810097
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810098
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810099
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810100
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810101
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810102
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189692
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189693
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189694
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189695
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller ID', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189696
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189697
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189698
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189699
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189700
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189701
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189702
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189703
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189704
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189705
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189706
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189707
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189708
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller ID', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189709
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189710
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189711
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189712
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189713
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189714
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189715
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189716
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189717
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189718
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189719
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189720
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189721
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller ID', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189722
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189723
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189724
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189725
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189726
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189727
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189728
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189729
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189730
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189744
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189745
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189746
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189747
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller ID', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189748
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189749
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189750
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189751
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189752
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189753
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189754
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189755
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189756
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189731
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189732
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189733
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189734
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller ID', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189735
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189736
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189737
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189738
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189739
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189740
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189741
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189742
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189743
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189809
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189810
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189811
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189812
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller ID', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189813
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189814
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189815
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189816
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189817
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189818
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189819
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189820
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189821
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189796
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189797
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189798
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189799
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller ID', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189800
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189801
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189802
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189803
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189804
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189805
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189806
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189807
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189808
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189757
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189758
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189759
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189760
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller ID', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189761
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189762
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189763
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189764
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189765
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189766
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189767
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189768
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189769
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189770
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189771
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189772
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189773
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller ID', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189774
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189775
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189776
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189777
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189778
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189779
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189780
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189781
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189782
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189783
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189784
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189785
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189786
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller ID', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189787
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189788
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189789
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189790
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189791
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189792
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189793
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189794
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 189795
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810183
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810184
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810185
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810186
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810187
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810188
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'strDiversionOriginalDestinationState', strCaption = 'Manifest Destination', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810189
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'strDestinationState', strCaption = 'Actual Destination', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810190
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'TCN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810191
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810192
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810193
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810194
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810195
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', strColumn = 'strDiversionNumber', strCaption = 'Diversion Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810196
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810169
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810170
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810171
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810172
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810173
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810174
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'strDiversionOriginalDestinationState', strCaption = 'Manifest Destination', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810175
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'strDestinationState', strCaption = 'Actual Destination', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810176
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'strTerminalControlNumber', strCaption = 'TCN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810177
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810178
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810179
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810180
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810181
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', strColumn = 'strDiversionNumber', strCaption = 'Diversion Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810182
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810127
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810128
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810129
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810130
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810131
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810132
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'strDiversionOriginalDestinationState', strCaption = 'Manifest Destination', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810133
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'strDestinationState', strCaption = 'Actual Destination', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810134
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'TCN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810135
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810136
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810137
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810138
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810139
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', strColumn = 'strDiversionNumber', strCaption = 'Diversion Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810140
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810141
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810142
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810143
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810144
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810145
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810146
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'strDiversionOriginalDestinationState', strCaption = 'Manifest Destination', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810147
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Actual Destination', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810148
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'strTerminalControlNumber', strCaption = 'TCN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810149
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810150
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810151
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810152
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810153
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', strColumn = 'strDiversionNumber', strCaption = 'Diversion Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810154
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'strReportingComponentNote', strCaption = 'Schedule Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810155
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810156
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810157
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810158
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810159
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810160
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'strDiversionOriginalDestinationState', strCaption = 'Manifest Destination', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810161
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'strDestinationState', strCaption = 'Actual Destination', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810162
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'strTerminalControlNumber', strCaption = 'TCN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810163
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810164
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810165
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810166
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810167
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', strColumn = 'strDiversionNumber', strCaption = 'Diversion Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1810168

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
	SELECT intFilingPacketId = 0, strFormCode = 'R-5346', strScheduleCode = 'R5346', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 182887
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Aviation Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 182876
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Dyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 182875
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasohol', ysnStatus = 1, intFrequency = 1, intMasterId = 182872
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 182873
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-23', strType = 'Undyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 182874
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Aviation Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 182881
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Dyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 182880
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasohol', ysnStatus = 1, intFrequency = 1, intMasterId = 182877
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 182878
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-24', strType = 'Undyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 182879
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Aviation Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 182886
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Dyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 182885
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasohol', ysnStatus = 1, intFrequency = 1, intMasterId = 182882
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 182883
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5346', strScheduleCode = 'G-25', strType = 'Undyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 182884
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5399', strScheduleCode = 'R5399', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 182903
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasohol', ysnStatus = 1, intFrequency = 1, intMasterId = 182888
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 182889
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-1', strType = 'Undyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 182890
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Aviation Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 182892
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-2', strType = 'Dyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 182891
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Aviation Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 182897
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Dyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 182896
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasohol', ysnStatus = 1, intFrequency = 1, intMasterId = 182893
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 182894
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5399', strScheduleCode = 'A-3', strType = 'Undyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 182895
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Aviation Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 182902
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Dyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 182901
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasohol', ysnStatus = 1, intFrequency = 1, intMasterId = 182898
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 182899
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'R-5399', strScheduleCode = 'D-21', strType = 'Undyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 182900

	EXEC uspTFUpgradeFilingPackets @TaxAuthorityCode = @TaxAuthorityCode, @FilingPackets = @FilingPackets

END

GO