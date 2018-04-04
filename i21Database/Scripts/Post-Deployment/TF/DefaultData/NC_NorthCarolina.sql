DECLARE @TaxAuthorityCode NVARCHAR(10) = 'NC'
	, @TaxAuthorityId INT

SELECT @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = @TaxAuthorityCode AND ysnFilingForThisTA = 1

IF(@TaxAuthorityId IS NOT NULL)
BEGIN

PRINT ('Deploying North Carolina Tax Forms')

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
	SELECT intProductCodeId = 0, strProductCode = '054', strDescription = 'Propane', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332586
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '065', strDescription = 'Gasoline', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332587
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '072', strDescription = 'Kerosene - Dyed', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332588
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '123', strDescription = 'Alcohol', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332589
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '124', strDescription = 'Gasohol', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332590
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '125', strDescription = 'Aviation Gasoline', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332591
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '130', strDescription = 'Jet Fuel', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332592
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '142', strDescription = 'Kerosene - Undyed', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332593
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '160', strDescription = 'Diesel - Undyed', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332594
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '224', strDescription = 'Compressed Natural Gas (CNG)', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332595
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '226', strDescription = 'Diesel – High Sulfur Dyed', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332596
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '227', strDescription = 'Diesel – Low Sulfur Dyed', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332597
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '241', strDescription = 'Ethanol', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332598
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '243', strDescription = 'Methanol', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332599
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '284', strDescription = 'BioDiesel – Undyed', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332600
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '290', strDescription = 'Biodiesel – Dyed', strProductCodeGroup = ' ', strNote = NULL, intMasterId = 332601

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
	SELECT intTaxCategoryId = 0, strState = 'NC', strTaxCategory = 'NC Excise Tax Gasoline', intMasterId = 332099
	UNION ALL SELECT intTaxCategoryId = 0, strState = 'NC', strTaxCategory = 'NC Excise Tax Diesel Clear', intMasterId = 332100

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
	SELECT intReportingComponentId = 0, strFormCode = 'Gas-1301', strFormName = 'Transporter Return', strScheduleCode = '14A', strScheduleName = 'Gallons Loaded in NC and Delivered to Another State', strType = '', strNote = '', strTransactionType = '', intSort = 10, strStoredProcedure = NULL, intMasterId = 332690, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1301', strFormName = 'Transporter Return', strScheduleCode = '14B', strScheduleName = 'Gallons Loaded in Another State and Delivered to NC', strType = '', strNote = '', strTransactionType = '', intSort = 20, strStoredProcedure = NULL, intMasterId = 332691, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1301', strFormName = 'Transporter Return', strScheduleCode = '14C', strScheduleName = 'Gallons Loaded in NC and Delivered to NC', strType = '', strNote = '', strTransactionType = '', intSort = 30, strStoredProcedure = NULL, intMasterId = 332692, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1301', strFormName = 'Transporter Return', strScheduleCode = '', strScheduleName = 'NC Transporter Return', strType = '', strNote = 'Main Form', strTransactionType = '', intSort = 35, strStoredProcedure = NULL, intMasterId = 332693, intComponentTypeId = 2
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1239', strFormName = 'Bulk Plant Exporter Return', strScheduleCode = '7F', strScheduleName = 'Bulk Plant Exporter Schedule of Tax-Paid Exports', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 40, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332694, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1239', strFormName = 'Bulk Plant Exporter Return', strScheduleCode = '7F', strScheduleName = 'Bulk Plant Exporter Schedule of Tax-Paid Exports', strType = 'Undyed Diesel', strNote = '', strTransactionType = 'Invoice', intSort = 50, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332695, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1239', strFormName = 'Bulk Plant Exporter Return', strScheduleCode = '7F', strScheduleName = 'Bulk Plant Exporter Schedule of Tax-Paid Exports', strType = 'Dyed Diesel', strNote = '', strTransactionType = 'Invoice', intSort = 60, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332696, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1239', strFormName = 'Bulk Plant Exporter Return', strScheduleCode = '7F', strScheduleName = 'Bulk Plant Exporter Schedule of Tax-Paid Exports', strType = 'Undyed Kerosene', strNote = '', strTransactionType = 'Invoice', intSort = 70, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332697, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1239', strFormName = 'Bulk Plant Exporter Return', strScheduleCode = '7F', strScheduleName = 'Bulk Plant Exporter Schedule of Tax-Paid Exports', strType = 'Dyed Kerosene', strNote = '', strTransactionType = 'Invoice', intSort = 80, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332698, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1239', strFormName = 'Bulk Plant Exporter Return', strScheduleCode = '7F', strScheduleName = 'Bulk Plant Exporter Schedule of Tax-Paid Exports', strType = 'Jet Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 90, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332699, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1239', strFormName = 'Bulk Plant Exporter Return', strScheduleCode = '7F', strScheduleName = 'Bulk Plant Exporter Schedule of Tax-Paid Exports', strType = 'AvGas', strNote = '', strTransactionType = 'Invoice', intSort = 100, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332700, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '5A', strScheduleName = 'Gallons Sold to End-users and Retailers, Tax Collected', strType = 'Propane', strNote = '', strTransactionType = 'Invoice', intSort = 110, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332701, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '5A', strScheduleName = 'Gallons Sold to End-users and Retailers, Tax Collected', strType = 'CNG', strNote = '', strTransactionType = 'Invoice', intSort = 120, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332702, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '8', strScheduleName = 'Gallons Sold to US Government', strType = 'Propane', strNote = '', strTransactionType = 'Invoice', intSort = 130, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332703, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '8', strScheduleName = 'Gallons Sold to US Government', strType = 'CNG', strNote = '', strTransactionType = 'Invoice', intSort = 140, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332704, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '9A', strScheduleName = 'Gallons Sold to State of NC', strType = 'Propane', strNote = '', strTransactionType = 'Invoice', intSort = 150, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332705, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '9A', strScheduleName = 'Gallons Sold to State of NC', strType = 'CNG', strNote = '', strTransactionType = 'Invoice', intSort = 160, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332706, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '9C', strScheduleName = 'Gallons Sold to a NC Local Board of Education', strType = 'Propane', strNote = '', strTransactionType = 'Invoice', intSort = 170, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332707, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '9C', strScheduleName = 'Gallons Sold to a NC Local Board of Education', strType = 'CNG', strNote = '', strTransactionType = 'Invoice', intSort = 180, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332708, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '9E', strScheduleName = 'Gallons Sold to a NC County or Municipility', strType = 'Propane', strNote = '', strTransactionType = 'Invoice', intSort = 190, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332709, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '9E', strScheduleName = 'Gallons Sold to a NC County or Municipility', strType = 'CNG', strNote = '', strTransactionType = 'Invoice', intSort = 200, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332710, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '9F', strScheduleName = 'Gallons Sold to a NC Charter School', strType = 'Propane', strNote = '', strTransactionType = 'Invoice', intSort = 210, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332711, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '9F', strScheduleName = 'Gallons Sold to a NC Charter School', strType = 'CNG', strNote = '', strTransactionType = 'Invoice', intSort = 220, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332712, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '9G', strScheduleName = 'Gallons Sold to a NC Community College', strType = 'Propane', strNote = '', strTransactionType = 'Invoice', intSort = 230, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332713, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1252', strFormName = 'Alternative Fuels Provider Return', strScheduleCode = '9G', strScheduleName = 'Gallons Sold to a NC Community College', strType = 'CNG', strNote = '', strTransactionType = 'Invoice', intSort = 240, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332714, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5R', strScheduleName = 'Dyed Diesel or Dyed Kerosene Delivered to a Local Bus Company', strType = 'Dyed Diesel', strNote = '', strTransactionType = 'Invoice', intSort = 250, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332715, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5R', strScheduleName = 'Dyed Diesel or Dyed Kerosene Delivered to a Local Bus Company', strType = 'Dyed Kerosene', strNote = '', strTransactionType = 'Invoice', intSort = 260, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332716, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5S', strScheduleName = 'Dyed Diesel or Dyed Kerosene Delivered to an Education Organization that is not a Public School', strType = 'Dyed Diesel', strNote = '', strTransactionType = 'Invoice', intSort = 270, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332717, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5S', strScheduleName = 'Dyed Diesel or Dyed Kerosene Delivered to an Education Organization that is not a Public School', strType = 'Dyed Kerosene', strNote = '', strTransactionType = 'Invoice', intSort = 280, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332718, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5U', strScheduleName = 'Gallons of Fuel that were Allowed an Exemption but Used for Taxable Use', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 290, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332719, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5U', strScheduleName = 'Gallons of Fuel that were Allowed an Exemption but Used for Taxable Use', strType = 'Undyed Diesel', strNote = '', strTransactionType = 'Invoice', intSort = 300, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332720, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5U', strScheduleName = 'Gallons of Fuel that were Allowed an Exemption but Used for Taxable Use', strType = 'Dyed Diesel', strNote = '', strTransactionType = 'Invoice', intSort = 310, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332721, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5U', strScheduleName = 'Gallons of Fuel that were Allowed an Exemption but Used for Taxable Use', strType = 'Undyed Kerosene', strNote = '', strTransactionType = 'Invoice', intSort = 320, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332722, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5V', strScheduleName = 'Gallons of Fuel Used to Operate a Highway Vehicle on which a Reful has been Requested', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 330, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332723, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5V', strScheduleName = 'Gallons of Fuel Used to Operate a Highway Vehicle on which a Reful has been Requested', strType = 'Undyed Diesel', strNote = '', strTransactionType = 'Invoice', intSort = 340, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332724, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5V', strScheduleName = 'Gallons of Fuel Used to Operate a Highway Vehicle on which a Reful has been Requested', strType = 'Dyed Diesel', strNote = '', strTransactionType = 'Invoice', intSort = 350, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332725, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5V', strScheduleName = 'Gallons of Fuel Used to Operate a Highway Vehicle on which a Reful has been Requested', strType = 'Undyed Kerosene', strNote = '', strTransactionType = 'Invoice', intSort = 360, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332726, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5W', strScheduleName = 'Gallons Diverted', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 370, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332727, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5W', strScheduleName = 'Gallons Diverted', strType = 'Undyed Diesel', strNote = '', strTransactionType = 'Invoice', intSort = 380, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332728, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5W', strScheduleName = 'Gallons Diverted', strType = 'Dyed Diesel', strNote = '', strTransactionType = 'Invoice', intSort = 390, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332729, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5W', strScheduleName = 'Gallons Diverted', strType = 'Undyed Kerosene', strNote = '', strTransactionType = 'Invoice', intSort = 400, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332730, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5W', strScheduleName = 'Gallons Diverted', strType = 'Dyed Kerosene', strNote = '', strTransactionType = 'Invoice', intSort = 410, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332731, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1259', strFormName = 'Backup Tax Return', strScheduleCode = '5W', strScheduleName = 'Gallons Diverted', strType = 'Jet Fule and Av Gas', strNote = '', strTransactionType = 'Invoice', intSort = 420, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332732, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1206', strFormName = 'Claim for Refund', strScheduleCode = 'USGov', strScheduleName = 'Exempt - U.S. Government', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 430, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332733, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1206', strFormName = 'Claim for Refund', strScheduleCode = 'Muni', strScheduleName = 'Exempt - NC County or Municipility', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 440, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332734, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1206', strFormName = 'Claim for Refund', strScheduleCode = 'Charter', strScheduleName = 'Exempt - NC Charter School', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 450, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332735, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1206', strFormName = 'Claim for Refund', strScheduleCode = 'State', strScheduleName = 'Exempt - State of NC', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 460, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332736, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1206', strFormName = 'Claim for Refund', strScheduleCode = 'Edu', strScheduleName = 'Exempt - NC Local Board of Education', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 470, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332737, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Gas-1206', strFormName = 'Claim for Refund', strScheduleCode = 'College', strScheduleName = 'Exempt - NC Community College', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 480, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 332738, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'NC EDI', strFormName = 'NC EDI File', strScheduleCode = '', strScheduleName = '', strType = '', strNote = 'NC EDI File', strTransactionType = '', intSort = 1000, strStoredProcedure = NULL, intMasterId = 332739, intComponentTypeId = 3
	
	EXEC uspTFUpgradeReportingComponents @TaxAuthorityCode = @TaxAuthorityCode, @ReportingComponent = @ReportingComponent


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
	SELECT intFilingPacketId = 0, strFormCode = 'Gas-1206', strScheduleCode = 'Charter', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 333076
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1206', strScheduleCode = 'College', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 333079
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1206', strScheduleCode = 'Edu', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 333078
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1206', strScheduleCode = 'Muni', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 333075
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1206', strScheduleCode = 'State', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 333077
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1206', strScheduleCode = 'USGov', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 333074
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1239', strScheduleCode = '7F', strType = 'AvGas', ysnStatus = 1, intFrequency = 1, intMasterId = 333041
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1239', strScheduleCode = '7F', strType = 'Dyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 333037
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1239', strScheduleCode = '7F', strType = 'Dyed Kerosene', ysnStatus = 1, intFrequency = 1, intMasterId = 333039
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1239', strScheduleCode = '7F', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 333035
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1239', strScheduleCode = '7F', strType = 'Jet Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 333040
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1239', strScheduleCode = '7F', strType = 'Undyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 333036
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1239', strScheduleCode = '7F', strType = 'Undyed Kerosene', ysnStatus = 1, intFrequency = 1, intMasterId = 333038
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1252', strScheduleCode = '5A', strType = 'CNG', ysnStatus = 1, intFrequency = 1, intMasterId = 333043
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1252', strScheduleCode = '5A', strType = 'Propane', ysnStatus = 1, intFrequency = 1, intMasterId = 333042
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1252', strScheduleCode = '8', strType = 'CNG', ysnStatus = 1, intFrequency = 1, intMasterId = 333045
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1252', strScheduleCode = '8', strType = 'Propane', ysnStatus = 1, intFrequency = 1, intMasterId = 333044
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1252', strScheduleCode = '9A', strType = 'CNG', ysnStatus = 1, intFrequency = 1, intMasterId = 333047
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1252', strScheduleCode = '9A', strType = 'Propane', ysnStatus = 1, intFrequency = 1, intMasterId = 333046
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1252', strScheduleCode = '9C', strType = 'CNG', ysnStatus = 1, intFrequency = 1, intMasterId = 333049
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1252', strScheduleCode = '9C', strType = 'Propane', ysnStatus = 1, intFrequency = 1, intMasterId = 333048
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1252', strScheduleCode = '9E', strType = 'CNG', ysnStatus = 1, intFrequency = 1, intMasterId = 333051
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1252', strScheduleCode = '9E', strType = 'Propane', ysnStatus = 1, intFrequency = 1, intMasterId = 333050
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1252', strScheduleCode = '9F', strType = 'CNG', ysnStatus = 1, intFrequency = 1, intMasterId = 333053
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1252', strScheduleCode = '9F', strType = 'Propane', ysnStatus = 1, intFrequency = 1, intMasterId = 333052
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1252', strScheduleCode = '9G', strType = 'CNG', ysnStatus = 1, intFrequency = 1, intMasterId = 333055
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1252', strScheduleCode = '9G', strType = 'Propane', ysnStatus = 1, intFrequency = 1, intMasterId = 333054
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1259', strScheduleCode = '5R', strType = 'Dyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 333056
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1259', strScheduleCode = '5R', strType = 'Dyed Kerosene', ysnStatus = 1, intFrequency = 1, intMasterId = 333057
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1259', strScheduleCode = '5S', strType = 'Dyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 333058
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1259', strScheduleCode = '5S', strType = 'Dyed Kerosene', ysnStatus = 1, intFrequency = 1, intMasterId = 333059
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1259', strScheduleCode = '5U', strType = 'Dyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 333062
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1259', strScheduleCode = '5U', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 333060
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1259', strScheduleCode = '5U', strType = 'Undyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 333061
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1259', strScheduleCode = '5U', strType = 'Undyed Kerosene', ysnStatus = 1, intFrequency = 1, intMasterId = 333063
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1259', strScheduleCode = '5V', strType = 'Dyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 333066
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1259', strScheduleCode = '5V', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 333064
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1259', strScheduleCode = '5V', strType = 'Undyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 333065
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1259', strScheduleCode = '5V', strType = 'Undyed Kerosene', ysnStatus = 1, intFrequency = 1, intMasterId = 333067
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1259', strScheduleCode = '5W', strType = 'Dyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 333070
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1259', strScheduleCode = '5W', strType = 'Dyed Kerosene', ysnStatus = 1, intFrequency = 1, intMasterId = 333072
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1259', strScheduleCode = '5W', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 333068
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1259', strScheduleCode = '5W', strType = 'Jet Fule and Av Gas', ysnStatus = 1, intFrequency = 1, intMasterId = 333073
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1259', strScheduleCode = '5W', strType = 'Undyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 333069
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1259', strScheduleCode = '5W', strType = 'Undyed Kerosene', ysnStatus = 1, intFrequency = 1, intMasterId = 333071
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1301', strScheduleCode = '', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 333034
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1301', strScheduleCode = '14A', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 333031
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1301', strScheduleCode = '14B', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 333032
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Gas-1301', strScheduleCode = '14C', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 333033
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'NC EDI', strScheduleCode = '', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 333080

	EXEC uspTFUpgradeFilingPackets @TaxAuthorityCode = @TaxAuthorityCode, @FilingPackets = @FilingPackets

END

GO