DECLARE @TaxAuthorityCode NVARCHAR(10) = 'KS'
	, @TaxAuthorityId INT

SELECT @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = @TaxAuthorityCode AND ysnFilingForThisTA = 1

IF(@TaxAuthorityId IS NOT NULL)
BEGIN

	PRINT ('Deploying Kansas Tax Forms')

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
	SELECT intProductCodeId = 0, strProductCode = '054', strDescription = 'Propane', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 161109
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '065', strDescription = 'Gasoline', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 161110
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '071', strDescription = 'Gasoline MTBE', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 161111
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '072', strDescription = 'Kerosene – Dyed', strProductCodeGroup = 'Special Fuel - Dyed', strNote = NULL, intMasterId = 161112
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '073', strDescription = 'Low Sulfur Kerosene – Dyed', strProductCodeGroup = 'Special Fuel - Dyed', strNote = NULL, intMasterId = 161113
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '074', strDescription = 'High Sulfur Kerosene – Dyed', strProductCodeGroup = 'Special Fuel - Dyed', strNote = NULL, intMasterId = 161114
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '078', strDescription = 'E75', strProductCodeGroup = 'Gasohol', strNote = NULL, intMasterId = 161115
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '079', strDescription = 'E85', strProductCodeGroup = 'Gasohol', strNote = NULL, intMasterId = 161116
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '123', strDescription = 'Alcohol', strProductCodeGroup = 'Gasohol', strNote = NULL, intMasterId = 161117
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '124', strDescription = 'Gasohol', strProductCodeGroup = 'Gasohol', strNote = NULL, intMasterId = 161118
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '125', strDescription = 'Aviation Gasoline', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 161119
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '130', strDescription = 'Jet Fuel', strProductCodeGroup = 'Special Fuel - Undyed', strNote = NULL, intMasterId = 161120
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '139', strDescription = 'Gasohol 10% Ethanol Blend', strProductCodeGroup = 'Gasohol', strNote = NULL, intMasterId = 161121
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '140', strDescription = 'Gasohol 5.7% Ethanol Blend', strProductCodeGroup = 'Gasohol', strNote = NULL, intMasterId = 161122
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '141', strDescription = 'Gasohol 7.7% Ethanol Blend', strProductCodeGroup = 'Gasohol', strNote = NULL, intMasterId = 161123
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '142', strDescription = 'Kerosene – Undyed', strProductCodeGroup = 'Special Fuel - Undyed', strNote = NULL, intMasterId = 161124
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '145', strDescription = 'Low Sulfur Kerosene – Undyed', strProductCodeGroup = 'Special Fuel - Undyed', strNote = NULL, intMasterId = 161125
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '147', strDescription = 'High Sulfur Kerosene – Undyed', strProductCodeGroup = 'Special Fuel - Undyed', strNote = NULL, intMasterId = 161126
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '150', strDescription = 'No. 1 Fuel Oil – Undyed', strProductCodeGroup = 'Special Fuel - Undyed', strNote = NULL, intMasterId = 161127
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '152', strDescription = 'Heating Oil', strProductCodeGroup = 'Special Fuel - Dyed', strNote = NULL, intMasterId = 161128
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '153', strDescription = 'Diesel Fuel #4 – Dyed', strProductCodeGroup = 'Special Fuel - Dyed', strNote = NULL, intMasterId = 161129
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '154', strDescription = 'Diesel Fuel #4 – Undyed ', strProductCodeGroup = 'Special Fuel - Undyed', strNote = NULL, intMasterId = 161130
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '160', strDescription = 'Diesel Fuel – Undyed', strProductCodeGroup = 'Special Fuel - Undyed', strNote = NULL, intMasterId = 161131
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '161', strDescription = 'Low Sulfur Diesel #1 – Undyed', strProductCodeGroup = 'Special Fuel - Undyed', strNote = NULL, intMasterId = 161132
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '167', strDescription = 'Low Sulfur Diesel #2 – Undyed', strProductCodeGroup = 'Special Fuel - Undyed', strNote = NULL, intMasterId = 161133
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '170', strDescription = 'Biodiesel – Undyed', strProductCodeGroup = 'Special Fuel - Undyed', strNote = NULL, intMasterId = 161134
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '171', strDescription = 'Biodiesel – Dyed', strProductCodeGroup = 'Special Fuel - Dyed', strNote = NULL, intMasterId = 161135
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '224', strDescription = 'Compressed Natural Gas', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 161136
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '225', strDescription = 'Liquid Natural Gas', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 161137
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '226', strDescription = 'High Sulfur Diesel – Dyed', strProductCodeGroup = 'Special Fuel - Dyed', strNote = NULL, intMasterId = 161138
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '227', strDescription = 'Low Sulfur Diesel – Dyed', strProductCodeGroup = 'Special Fuel - Dyed', strNote = NULL, intMasterId = 161139
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '228', strDescription = 'Diesel Fuel – Dyed', strProductCodeGroup = 'Special Fuel - Dyed', strNote = NULL, intMasterId = 161140
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '231', strDescription = 'No 1 Diesel – Dyed', strProductCodeGroup = 'Special Fuel - Dyed', strNote = NULL, intMasterId = 161141
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '241', strDescription = 'Ethanol', strProductCodeGroup = 'Gasohol', strNote = NULL, intMasterId = 161142
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '243', strDescription = 'Methanol', strProductCodeGroup = 'Gasohol', strNote = NULL, intMasterId = 161143
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '282', strDescription = '#1 High Sulfur Diesel – Undyed', strProductCodeGroup = 'Special Fuel - Undyed', strNote = NULL, intMasterId = 161144
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '283', strDescription = '#2 High Sulfur Diesel – Undyed', strProductCodeGroup = 'Special Fuel - Undyed', strNote = NULL, intMasterId = 161145
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '284', strDescription = 'Biodiesel – Undyed (B100)', strProductCodeGroup = 'Special Fuel - Undyed', strNote = NULL, intMasterId = 161146

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
	SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '1', strScheduleName = 'Gallons Received, KS Tax Paid', strType = 'Gasoline', strNote = '', strTransactionType = 'Inventory', intSort = 10, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 162298, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '1', strScheduleName = 'Gallons Received, KS Tax Paid', strType = 'Gasohol', strNote = '', strTransactionType = 'Inventory', intSort = 20, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 162299, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '1', strScheduleName = 'Gallons Received, KS Tax Paid', strType = 'Special Fuel - Dyed', strNote = '', strTransactionType = 'Inventory', intSort = 30, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 162300, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '1', strScheduleName = 'Gallons Received, KS Tax Paid', strType = 'Special Fuel - Undyed', strNote = '', strTransactionType = 'Inventory', intSort = 40, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 162301, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '2', strScheduleName = 'Gallons Received from Licensed Distributors, KS Tax Unpaid', strType = 'Gasoline', strNote = '', strTransactionType = 'Inventory', intSort = 50, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 162302, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '2', strScheduleName = 'Gallons Received from Licensed Distributors, KS Tax Unpaid', strType = 'Gasohol', strNote = '', strTransactionType = 'Inventory', intSort = 60, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 162303, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '2', strScheduleName = 'Gallons Received from Licensed Distributors, KS Tax Unpaid', strType = 'Special Fuel - Dyed', strNote = '', strTransactionType = 'Inventory', intSort = 70, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 162304, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '2', strScheduleName = 'Gallons Received from Licensed Distributors, KS Tax Unpaid', strType = 'Special Fuel - Undyed', strNote = '', strTransactionType = 'Inventory', intSort = 80, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 162305, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '3', strScheduleName = 'Gallons Imported from Another State Direct to Customer', strType = 'Gasoline', strNote = '', strTransactionType = 'Inventory', intSort = 90, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 162306, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '3', strScheduleName = 'Gallons Imported from Another State Direct to Customer', strType = 'Gasohol', strNote = '', strTransactionType = 'Inventory', intSort = 100, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 162307, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '3', strScheduleName = 'Gallons Imported from Another State Direct to Customer', strType = 'Special Fuel - Dyed', strNote = '', strTransactionType = 'Inventory', intSort = 110, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 162308, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '3', strScheduleName = 'Gallons Imported from Another State Direct to Customer', strType = 'Special Fuel - Undyed', strNote = '', strTransactionType = 'Inventory', intSort = 120, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 162309, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '5', strScheduleName = 'Gallons Delivered, KS Tax Collected', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 200, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 162310, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '5', strScheduleName = 'Gallons Delivered, KS Tax Collected', strType = 'Gasohol', strNote = '', strTransactionType = 'Invoice', intSort = 210, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 162311, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '5', strScheduleName = 'Gallons Delivered, KS Tax Collected', strType = 'Special Fuel - Dyed', strNote = '', strTransactionType = 'Invoice', intSort = 220, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 162312, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '5', strScheduleName = 'Gallons Delivered, KS Tax Collected', strType = 'Special Fuel - Undyed', strNote = '', strTransactionType = 'Invoice', intSort = 230, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 162313, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '6', strScheduleName = 'Gallons Delivered to Licensed Distributors, KS Tax Uncollected', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 240, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 162314, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '6', strScheduleName = 'Gallons Delivered to Licensed Distributors, KS Tax Uncollected', strType = 'Gasohol', strNote = '', strTransactionType = 'Invoice', intSort = 250, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 162315, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '6', strScheduleName = 'Gallons Delivered to Licensed Distributors, KS Tax Uncollected', strType = 'Special Fuel - Dyed', strNote = '', strTransactionType = 'Invoice', intSort = 260, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 162316, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '6', strScheduleName = 'Gallons Delivered to Licensed Distributors, KS Tax Uncollected', strType = 'Special Fuel - Undyed', strNote = '', strTransactionType = 'Invoice', intSort = 270, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 162317, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '7', strScheduleName = 'Gallons Exported to MO', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 280, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 162318, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '7', strScheduleName = 'Gallons Exported to MO', strType = 'Gasohol', strNote = '', strTransactionType = 'Invoice', intSort = 290, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 162319, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '7', strScheduleName = 'Gallons Exported to MO', strType = 'Special Fuel - Dyed', strNote = '', strTransactionType = 'Invoice', intSort = 300, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 162320, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '7', strScheduleName = 'Gallons Exported to MO', strType = 'Special Fuel - Undyed', strNote = '', strTransactionType = 'Invoice', intSort = 310, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 162321, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '8', strScheduleName = 'Gallons Delivered to US Government, Tax Exempt', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 600, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 162322, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '8', strScheduleName = 'Gallons Delivered to US Government, Tax Exempt', strType = 'Gasohol', strNote = '', strTransactionType = 'Invoice', intSort = 610, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 162323, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '8', strScheduleName = 'Gallons Delivered to US Government, Tax Exempt', strType = 'Special Fuel - Dyed', strNote = '', strTransactionType = 'Invoice', intSort = 620, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 162324, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '8', strScheduleName = 'Gallons Delivered to US Government, Tax Exempt', strType = 'Special Fuel - Undyed', strNote = '', strTransactionType = 'Invoice', intSort = 630, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 162325, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '9', strScheduleName = 'Gallons Delivered to Other Tax Exempt Entities', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 640, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 162326, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '9', strScheduleName = 'Gallons Delivered to Other Tax Exempt Entities', strType = 'Gasohol', strNote = '', strTransactionType = 'Invoice', intSort = 650, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 162327, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '9', strScheduleName = 'Gallons Delivered to Other Tax Exempt Entities', strType = 'Special Fuel - Dyed', strNote = '', strTransactionType = 'Invoice', intSort = 660, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 162328, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '9', strScheduleName = 'Gallons Delivered to Other Tax Exempt Entities', strType = 'Special Fuel - Undyed', strNote = '', strTransactionType = 'Invoice', intSort = 670, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 162329, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '10', strScheduleName = 'Gallons Delivered to Consumers in Tank Car, Transport, or Pipeline Lots', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 680, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 162330, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '10', strScheduleName = 'Gallons Delivered to Consumers in Tank Car, Transport, or Pipeline Lots', strType = 'Gasohol', strNote = '', strTransactionType = 'Invoice', intSort = 690, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 162331, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '10', strScheduleName = 'Gallons Delivered to Consumers in Tank Car, Transport, or Pipeline Lots', strType = 'Special Fuel - Dyed', strNote = '', strTransactionType = 'Invoice', intSort = 700, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 162332, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '10', strScheduleName = 'Gallons Delivered to Consumers in Tank Car, Transport, or Pipeline Lots', strType = 'Special Fuel - Undyed', strNote = '', strTransactionType = 'Invoice', intSort = 710, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 162333, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'MF-52', strFormName = 'Distributor Return', strScheduleCode = '', strScheduleName = 'Main Form', strType = '', strNote = 'Main Form', strTransactionType = '', intSort = 800, strStoredProcedure = '', intMasterId = 162334, intComponentTypeId = 2
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'KS EDI', strFormName = 'Kansas EDI File', strScheduleCode = '', strScheduleName = 'Kansas EDI File', strType = '', strNote = 'EDI File', strTransactionType = '', intSort = 1000, strStoredProcedure = '', intMasterId = 162335, intComponentTypeId = 3

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
	SELECT intTaxCriteriaId = 0, strTaxCategory = 'KS Excise Tax Gasoline', strState = 'KS', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasoline', strCriteria = '<> 0', intMasterId = 161077
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KS Excise Tax Gasohol', strState = 'KS', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasohol', strCriteria = '<> 0', intMasterId = 161078
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KS Excise Tax Diesel Clear', strState = 'KS', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', strCriteria = '<> 0', intMasterId = 161079
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KS Excise Tax Gasoline', strState = 'KS', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', strCriteria = '<> 0', intMasterId = 161080
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KS Excise Tax Gasohol', strState = 'KS', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasoline', strCriteria = '<> 0', intMasterId = 161081
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KS Excise Tax Diesel Clear', strState = 'KS', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', strCriteria = '<> 0', intMasterId = 161082
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KS Excise Tax Gasoline', strState = 'KS', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasohol', strCriteria = '= 0', intMasterId = 161083
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KS Excise Tax Gasohol', strState = 'KS', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasoline', strCriteria = '= 0', intMasterId = 161084
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KS Excise Tax Diesel Clear', strState = 'KS', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', strCriteria = '= 0', intMasterId = 161085
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KS Excise Tax Gasoline', strState = 'KS', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', strCriteria = '= 0', intMasterId = 161086
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KS Excise Tax Gasohol', strState = 'KS', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasoline', strCriteria = '= 0', intMasterId = 161087
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KS Excise Tax Diesel Clear', strState = 'KS', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', strCriteria = '= 0', intMasterId = 161088
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KS Excise Tax Gasoline', strState = 'KS', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasoline', strCriteria = '= 0', intMasterId = 161089
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KS Excise Tax Gasohol', strState = 'KS', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', strCriteria = '= 0', intMasterId = 161090
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KS Excise Tax Diesel Clear', strState = 'KS', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', strCriteria = '= 0', intMasterId = 161091
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KS Excise Tax Gasoline', strState = 'KS', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasoline', strCriteria = '= 0', intMasterId = 161092
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KS Excise Tax Gasohol', strState = 'KS', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', strCriteria = '= 0', intMasterId = 161093
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'KS Excise Tax Diesel Clear', strState = 'KS', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', strCriteria = '= 0', intMasterId = 161094

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
	SELECT intValidProductCodeId = 0, strProductCode = '054', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasoline', intMasterId = 169713
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasoline', intMasterId = 169714
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasoline', intMasterId = 169715
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasoline', intMasterId = 169716
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasoline', intMasterId = 169717
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasoline', intMasterId = 169718
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '054', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasoline', intMasterId = 169719
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasoline', intMasterId = 169720
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasoline', intMasterId = 169721
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasoline', intMasterId = 169722
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasoline', intMasterId = 169723
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasoline', intMasterId = 169724
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '054', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasoline', intMasterId = 169725
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasoline', intMasterId = 169726
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasoline', intMasterId = 169727
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasoline', intMasterId = 169728
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasoline', intMasterId = 169729
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasoline', intMasterId = 169730
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '054', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasoline', intMasterId = 169731
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasoline', intMasterId = 169732
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasoline', intMasterId = 169733
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasoline', intMasterId = 169734
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasoline', intMasterId = 169735
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasoline', intMasterId = 169736
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '054', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasoline', intMasterId = 169737
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasoline', intMasterId = 169738
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasoline', intMasterId = 169739
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasoline', intMasterId = 169740
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasoline', intMasterId = 169741
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasoline', intMasterId = 169742
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '054', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasoline', intMasterId = 169743
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasoline', intMasterId = 169744
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasoline', intMasterId = 169745
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasoline', intMasterId = 169746
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasoline', intMasterId = 169747
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasoline', intMasterId = 169748
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '054', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasoline', intMasterId = 169749
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasoline', intMasterId = 169750
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasoline', intMasterId = 169751
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasoline', intMasterId = 169752
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasoline', intMasterId = 169753
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasoline', intMasterId = 169754
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '054', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasoline', intMasterId = 169755
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasoline', intMasterId = 169756
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasoline', intMasterId = 169757
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasoline', intMasterId = 169758
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasoline', intMasterId = 169759
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasoline', intMasterId = 169760
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '054', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasoline', intMasterId = 169761
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasoline', intMasterId = 169762
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasoline', intMasterId = 169763
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasoline', intMasterId = 169764
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '224', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasoline', intMasterId = 169765
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '225', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasoline', intMasterId = 169766
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '078', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasohol', intMasterId = 169767
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '079', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasohol', intMasterId = 169768
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasohol', intMasterId = 169769
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasohol', intMasterId = 169770
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '139', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasohol', intMasterId = 169771
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '140', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasohol', intMasterId = 169772
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '141', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasohol', intMasterId = 169773
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '241', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasohol', intMasterId = 169774
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '243', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasohol', intMasterId = 169775
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '078', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasohol', intMasterId = 169776
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '079', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasohol', intMasterId = 169777
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasohol', intMasterId = 169778
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasohol', intMasterId = 169779
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '139', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasohol', intMasterId = 169780
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '140', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasohol', intMasterId = 169781
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '141', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasohol', intMasterId = 169782
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '241', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasohol', intMasterId = 169783
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '243', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasohol', intMasterId = 169784
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '078', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasohol', intMasterId = 169785
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '079', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasohol', intMasterId = 169786
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasohol', intMasterId = 169787
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasohol', intMasterId = 169788
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '139', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasohol', intMasterId = 169789
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '140', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasohol', intMasterId = 169790
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '141', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasohol', intMasterId = 169791
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '241', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasohol', intMasterId = 169792
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '243', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasohol', intMasterId = 169793
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '078', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasohol', intMasterId = 169794
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '079', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasohol', intMasterId = 169795
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasohol', intMasterId = 169796
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasohol', intMasterId = 169797
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '139', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasohol', intMasterId = 169798
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '140', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasohol', intMasterId = 169799
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '141', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasohol', intMasterId = 169800
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '241', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasohol', intMasterId = 169801
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '243', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasohol', intMasterId = 169802
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '078', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', intMasterId = 169803
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '079', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', intMasterId = 169804
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', intMasterId = 169805
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', intMasterId = 169806
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '139', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', intMasterId = 169807
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '140', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', intMasterId = 169808
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '141', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', intMasterId = 169809
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '241', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', intMasterId = 169810
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '243', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', intMasterId = 169811
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '078', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', intMasterId = 169812
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '079', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', intMasterId = 169813
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', intMasterId = 169814
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', intMasterId = 169815
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '139', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', intMasterId = 169816
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '140', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', intMasterId = 169817
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '141', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', intMasterId = 169818
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '241', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', intMasterId = 169819
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '243', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', intMasterId = 169820
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '078', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasohol', intMasterId = 169821
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '079', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasohol', intMasterId = 169822
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasohol', intMasterId = 169823
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasohol', intMasterId = 169824
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '139', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasohol', intMasterId = 169825
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '140', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasohol', intMasterId = 169826
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '141', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasohol', intMasterId = 169827
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '241', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasohol', intMasterId = 169828
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '243', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasohol', intMasterId = 169829
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '078', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', intMasterId = 169830
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '079', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', intMasterId = 169831
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', intMasterId = 169832
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', intMasterId = 169833
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '139', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', intMasterId = 169834
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '140', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', intMasterId = 169835
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '141', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', intMasterId = 169836
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '241', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', intMasterId = 169837
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '243', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', intMasterId = 169838
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '078', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', intMasterId = 169839
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '079', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', intMasterId = 169840
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', intMasterId = 169841
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', intMasterId = 169842
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '139', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', intMasterId = 169843
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '140', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', intMasterId = 169844
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '141', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', intMasterId = 169845
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '241', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', intMasterId = 169846
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '243', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', intMasterId = 169847
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', intMasterId = 169848
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', intMasterId = 169849
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', intMasterId = 169850
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', intMasterId = 169851
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', intMasterId = 169852
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '154', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', intMasterId = 169853
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', intMasterId = 169854
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', intMasterId = 169855
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', intMasterId = 169856
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', intMasterId = 169857
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '282', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', intMasterId = 169858
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', intMasterId = 169859
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '284', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', intMasterId = 169860
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', intMasterId = 169861
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', intMasterId = 169862
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', intMasterId = 169863
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', intMasterId = 169864
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', intMasterId = 169865
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '154', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', intMasterId = 169866
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', intMasterId = 169867
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', intMasterId = 169868
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', intMasterId = 169869
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', intMasterId = 169870
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '282', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', intMasterId = 169871
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', intMasterId = 169872
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '284', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', intMasterId = 169873
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', intMasterId = 169874
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', intMasterId = 169875
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', intMasterId = 169876
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', intMasterId = 169877
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', intMasterId = 169878
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '154', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', intMasterId = 169879
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', intMasterId = 169880
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', intMasterId = 169881
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', intMasterId = 169882
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', intMasterId = 169883
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '282', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', intMasterId = 169884
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', intMasterId = 169885
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '284', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', intMasterId = 169886
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', intMasterId = 169887
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', intMasterId = 169888
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', intMasterId = 169889
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', intMasterId = 169890
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', intMasterId = 169891
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '154', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', intMasterId = 169892
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', intMasterId = 169893
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', intMasterId = 169894
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', intMasterId = 169895
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', intMasterId = 169896
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '282', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', intMasterId = 169897
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', intMasterId = 169898
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '284', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', intMasterId = 169899
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', intMasterId = 169900
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', intMasterId = 169901
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', intMasterId = 169902
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', intMasterId = 169903
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', intMasterId = 169904
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '154', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', intMasterId = 169905
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', intMasterId = 169906
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', intMasterId = 169907
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', intMasterId = 169908
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', intMasterId = 169909
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '282', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', intMasterId = 169910
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', intMasterId = 169911
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '284', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', intMasterId = 169912
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', intMasterId = 169913
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', intMasterId = 169914
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', intMasterId = 169915
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', intMasterId = 169916
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', intMasterId = 169917
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '154', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', intMasterId = 169918
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', intMasterId = 169919
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', intMasterId = 169920
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', intMasterId = 169921
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', intMasterId = 169922
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '282', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', intMasterId = 169923
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', intMasterId = 169924
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '284', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', intMasterId = 169925
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', intMasterId = 169926
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', intMasterId = 169927
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', intMasterId = 169928
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', intMasterId = 169929
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', intMasterId = 169930
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '154', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', intMasterId = 169931
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', intMasterId = 169932
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', intMasterId = 169933
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', intMasterId = 169934
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', intMasterId = 169935
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '282', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', intMasterId = 169936
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', intMasterId = 169937
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '284', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', intMasterId = 169938
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', intMasterId = 169939
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', intMasterId = 169940
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', intMasterId = 169941
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', intMasterId = 169942
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', intMasterId = 169943
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '154', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', intMasterId = 169944
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', intMasterId = 169945
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', intMasterId = 169946
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', intMasterId = 169947
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', intMasterId = 169948
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '282', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', intMasterId = 169949
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', intMasterId = 169950
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '284', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', intMasterId = 169951
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', intMasterId = 169952
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', intMasterId = 169953
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', intMasterId = 169954
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', intMasterId = 169955
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', intMasterId = 169956
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '154', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', intMasterId = 169957
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', intMasterId = 169958
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', intMasterId = 169959
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', intMasterId = 169960
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', intMasterId = 169961
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '282', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', intMasterId = 169962
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', intMasterId = 169963
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '284', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', intMasterId = 169964
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Dyed', intMasterId = 169965
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Dyed', intMasterId = 169966
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Dyed', intMasterId = 169967
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Dyed', intMasterId = 169968
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '153', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Dyed', intMasterId = 169969
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '171', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Dyed', intMasterId = 169970
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Dyed', intMasterId = 169971
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Dyed', intMasterId = 169972
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Dyed', intMasterId = 169973
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Dyed', intMasterId = 169974
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', intMasterId = 169975
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', intMasterId = 169976
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', intMasterId = 169977
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', intMasterId = 169978
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '153', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', intMasterId = 169979
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '171', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', intMasterId = 169980
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', intMasterId = 169981
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', intMasterId = 169982
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', intMasterId = 169983
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', intMasterId = 169984
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Dyed', intMasterId = 169985
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Dyed', intMasterId = 169986
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Dyed', intMasterId = 169987
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Dyed', intMasterId = 169988
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '153', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Dyed', intMasterId = 169989
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '171', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Dyed', intMasterId = 169990
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Dyed', intMasterId = 169991
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Dyed', intMasterId = 169992
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Dyed', intMasterId = 169993
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Dyed', intMasterId = 169994
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Dyed', intMasterId = 169995
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Dyed', intMasterId = 169996
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Dyed', intMasterId = 169997
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Dyed', intMasterId = 169998
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '153', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Dyed', intMasterId = 169999
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '171', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Dyed', intMasterId = 1610000
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Dyed', intMasterId = 1610001
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Dyed', intMasterId = 1610002
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Dyed', intMasterId = 1610003
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Dyed', intMasterId = 1610004
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', intMasterId = 1610005
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', intMasterId = 1610006
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', intMasterId = 1610007
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', intMasterId = 1610008
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '153', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', intMasterId = 1610009
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '171', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', intMasterId = 1610010
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', intMasterId = 1610011
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', intMasterId = 1610012
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', intMasterId = 1610013
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', intMasterId = 1610014
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', intMasterId = 1610015
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', intMasterId = 1610016
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', intMasterId = 1610017
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', intMasterId = 1610018
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '153', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', intMasterId = 1610019
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '171', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', intMasterId = 1610020
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', intMasterId = 1610021
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', intMasterId = 1610022
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', intMasterId = 1610023
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', intMasterId = 1610024
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', intMasterId = 1610025
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', intMasterId = 1610026
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', intMasterId = 1610027
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', intMasterId = 1610028
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '153', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', intMasterId = 1610029
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '171', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', intMasterId = 1610030
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', intMasterId = 1610031
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', intMasterId = 1610032
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', intMasterId = 1610033
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', intMasterId = 1610034
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', intMasterId = 1610035
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', intMasterId = 1610036
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', intMasterId = 1610037
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', intMasterId = 1610038
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '153', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', intMasterId = 1610039
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '171', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', intMasterId = 1610040
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', intMasterId = 1610041
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', intMasterId = 1610042
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', intMasterId = 1610043
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', intMasterId = 1610044
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', intMasterId = 1610045
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', intMasterId = 1610046
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', intMasterId = 1610047
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '152', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', intMasterId = 1610048
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '153', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', intMasterId = 1610049
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '171', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', intMasterId = 1610050
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', intMasterId = 1610051
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', intMasterId = 1610052
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', intMasterId = 1610053
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', intMasterId = 1610054


	INSERT INTO @ValidOriginStates(
		intValidOriginStateId
		, strFormCode
		, strScheduleCode
		, strType
		, strState
		, strStatus
		, intMasterId
	)
	SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasohol', strState = 'KS', strStatus = 'Include', intMasterId = 161340
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasoline', strState = 'KS', strStatus = 'Include', intMasterId = 161341
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Dyed', strState = 'KS', strStatus = 'Include', intMasterId = 161342
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', strState = 'KS', strStatus = 'Include', intMasterId = 161343
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasohol', strState = 'KS', strStatus = 'Include', intMasterId = 161344
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasoline', strState = 'KS', strStatus = 'Include', intMasterId = 161345
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Dyed', strState = 'KS', strStatus = 'Include', intMasterId = 161346
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', strState = 'KS', strStatus = 'Include', intMasterId = 161347
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasohol', strState = 'KS', strStatus = 'Exclude', intMasterId = 161348
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasoline', strState = 'KS', strStatus = 'Exclude', intMasterId = 161349
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Dyed', strState = 'KS', strStatus = 'Exclude', intMasterId = 161350
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', strState = 'KS', strStatus = 'Exclude', intMasterId = 161351
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasoline', strState = 'KS', strStatus = 'Include', intMasterId = 161352
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', strState = 'KS', strStatus = 'Include', intMasterId = 161353
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', strState = 'KS', strStatus = 'Include', intMasterId = 161354
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', strState = 'KS', strStatus = 'Include', intMasterId = 161355
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasoline', strState = 'KS', strStatus = 'Include', intMasterId = 161356
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', strState = 'KS', strStatus = 'Include', intMasterId = 161357
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', strState = 'KS', strStatus = 'Include', intMasterId = 161358
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', strState = 'KS', strStatus = 'Include', intMasterId = 161359
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasoline', strState = 'KS', strStatus = 'Include', intMasterId = 161360
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', strState = 'KS', strStatus = 'Include', intMasterId = 161361
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', strState = 'KS', strStatus = 'Include', intMasterId = 161362
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', strState = 'KS', strStatus = 'Include', intMasterId = 161363
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasoline', strState = 'KS', strStatus = 'Include', intMasterId = 161364
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', strState = 'KS', strStatus = 'Include', intMasterId = 161365
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', strState = 'KS', strStatus = 'Include', intMasterId = 161366
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', strState = 'KS', strStatus = 'Include', intMasterId = 161367
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasoline', strState = 'KS', strStatus = 'Include', intMasterId = 161368
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasohol', strState = 'KS', strStatus = 'Include', intMasterId = 161369
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', strState = 'KS', strStatus = 'Include', intMasterId = 161370
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', strState = 'KS', strStatus = 'Include', intMasterId = 161371
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasoline', strState = 'KS', strStatus = 'Include', intMasterId = 161372
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasohol', strState = 'KS', strStatus = 'Include', intMasterId = 161373
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', strState = 'KS', strStatus = 'Include', intMasterId = 161374
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', strState = 'KS', strStatus = 'Include', intMasterId = 161375


	INSERT INTO @ValidDestinationStates(
		intValidDestinationStateId
		, strFormCode
		, strScheduleCode
		, strType
		, strState
		, strStatus
		, intMasterId
	)
	SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasohol', strState = 'KS', strStatus = 'Include', intMasterId = 161228
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasoline', strState = 'KS', strStatus = 'Include', intMasterId = 161229
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Dyed', strState = 'KS', strStatus = 'Include', intMasterId = 161230
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', strState = 'KS', strStatus = 'Include', intMasterId = 161231
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasohol', strState = 'KS', strStatus = 'Include', intMasterId = 161232
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasoline', strState = 'KS', strStatus = 'Include', intMasterId = 161233
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Dyed', strState = 'KS', strStatus = 'Include', intMasterId = 161234
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', strState = 'KS', strStatus = 'Include', intMasterId = 161235
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasohol', strState = 'KS', strStatus = 'Include', intMasterId = 161236
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasoline', strState = 'KS', strStatus = 'Include', intMasterId = 161237
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Dyed', strState = 'KS', strStatus = 'Include', intMasterId = 161238
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', strState = 'KS', strStatus = 'Include', intMasterId = 161239
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasoline', strState = 'KS', strStatus = 'Include', intMasterId = 161240
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', strState = 'KS', strStatus = 'Include', intMasterId = 161241
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', strState = 'KS', strStatus = 'Include', intMasterId = 161242
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', strState = 'KS', strStatus = 'Include', intMasterId = 161243
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasoline', strState = 'KS', strStatus = 'Include', intMasterId = 161244
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', strState = 'KS', strStatus = 'Include', intMasterId = 161245
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', strState = 'KS', strStatus = 'Include', intMasterId = 161246
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', strState = 'KS', strStatus = 'Include', intMasterId = 161247
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasoline', strState = 'KS', strStatus = 'Include', intMasterId = 161248
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', strState = 'KS', strStatus = 'Include', intMasterId = 161249
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', strState = 'KS', strStatus = 'Include', intMasterId = 161250
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', strState = 'KS', strStatus = 'Include', intMasterId = 161251
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasoline', strState = 'KS', strStatus = 'Include', intMasterId = 161252
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', strState = 'KS', strStatus = 'Include', intMasterId = 161253
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', strState = 'KS', strStatus = 'Include', intMasterId = 161254
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', strState = 'KS', strStatus = 'Include', intMasterId = 161255
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasoline', strState = 'KS', strStatus = 'Include', intMasterId = 161256
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasohol', strState = 'KS', strStatus = 'Include', intMasterId = 161257
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', strState = 'KS', strStatus = 'Include', intMasterId = 161258
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', strState = 'KS', strStatus = 'Include', intMasterId = 161259
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasoline', strState = 'MO', strStatus = 'Include', intMasterId = 161260
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasohol', strState = 'MO', strStatus = 'Include', intMasterId = 161261
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', strState = 'MO', strStatus = 'Include', intMasterId = 161262
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', strState = 'MO', strStatus = 'Include', intMasterId = 161263

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
	SELECT intReportTemplateId = 0, strFormCode = 'MF-52', strScheduleCode = '', strType = '', strTemplateItemId = 'KSMF52-Ln7', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '1', strDescription = 'Line 7 Alternative Fuel Deduction', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '1', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 161332
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'MF-52', strScheduleCode = '', strType = '', strTemplateItemId = 'KSMF52-Ln9Gasoline', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '2', strDescription = 'Line 9 Tax Rate - Gasoline', strScheduleList = NULL, strConfiguration = '0.2400', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '2', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 161333
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'MF-52', strScheduleCode = '', strType = '', strTemplateItemId = 'KSMF52-Ln9Gasohol', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '3', strDescription = 'Line 9 Tax Rate - Gasohol', strScheduleList = NULL, strConfiguration = '0.2400', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '3', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 161334
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'MF-52', strScheduleCode = '', strType = '', strTemplateItemId = 'KSMF52-Ln9SF', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '4', strDescription = 'Line 9 Tax Rate - Special Fuel', strScheduleList = NULL, strConfiguration = '0.2600', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '4', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 161335
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-ISA01', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '1', strDescription = 'ISA01 - Authorization Information Qualifier', strScheduleList = NULL, strConfiguration = '00', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '1', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 161336
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-ISA02', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '2', strDescription = 'ISA02 - Authorization Information (10 spaces)', strScheduleList = NULL, strConfiguration = '          ', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '2', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 161337
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-ISA03', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '3', strDescription = 'ISA03 - Security Information Qualifier', strScheduleList = NULL, strConfiguration = '00', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '3', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 161338
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-ISA04', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '4', strDescription = 'ISA04 - Security Information (10 spaces)', strScheduleList = NULL, strConfiguration = '          ', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '4', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 161339
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-ISA05', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '5', strDescription = 'ISA05 - Interchange ID Qualifier', strScheduleList = NULL, strConfiguration = '32', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '5', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 161340
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-ISA07', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '7', strDescription = 'ISA07 - Interchange ID Qualifier', strScheduleList = NULL, strConfiguration = '01', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '7', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 161341
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-ISA08', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '8', strDescription = 'ISA08 - Interchange Receiver ID', strScheduleList = NULL, strConfiguration = '835107079', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '8', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 161342
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-ISA11', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '9', strDescription = 'ISA11 - Repetition Separator', strScheduleList = NULL, strConfiguration = 'U', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '9', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 161343
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-ISA12', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '10', strDescription = 'ISA12 - Interchange Control Version Number', strScheduleList = NULL, strConfiguration = '00305', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '10', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 161344
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-ISA13', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '11', strDescription = 'ISA13 - Interchange Control Number (for next transmission)', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '11', ysnOutputDesigner = 0, strInputType = 'integer', intMasterId = 161345
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-ISA14', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '12', strDescription = 'ISA14 - Acknowledgement Requested', strScheduleList = NULL, strConfiguration = '0', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '12', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 161346
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-ISA15', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '13', strDescription = 'ISA15 - Usage Indicator (P = Production; T = Test)', strScheduleList = NULL, strConfiguration = 'T', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '13', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 161347
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-ISA16', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '14', strDescription = 'ISA16 - Component Sub-element Separator', strScheduleList = NULL, strConfiguration = '~', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '14', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 161348
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-GS01', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '15', strDescription = 'GS01 - Functional Identifier Code', strScheduleList = NULL, strConfiguration = 'TF', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '15', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 161349
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-GS03', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '16', strDescription = 'GS03 - Application Receiver''s Code', strScheduleList = NULL, strConfiguration = 'KS813051R', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '16', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 161350
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-GS06', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '17', strDescription = 'GS06 - Group Control Number (for next transmission)', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '17', ysnOutputDesigner = 0, strInputType = 'integer', intMasterId = 161351
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-GS07', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '18', strDescription = 'GS07 - Responsible Agency Code', strScheduleList = NULL, strConfiguration = 'X', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '18', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 161352
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-GS08', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '19', strDescription = 'GS08 - Version/Release/Industry ID Code', strScheduleList = NULL, strConfiguration = '003050', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '19', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 161353
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-ST01', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '20', strDescription = 'ST01 - Transaction Set Code', strScheduleList = NULL, strConfiguration = '813', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '20', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 161354
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-ST02', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '21', strDescription = 'ST02 - Transaction Set Control Number (for next transmission)', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '21', ysnOutputDesigner = 0, strInputType = 'integer', intMasterId = 161355
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-BTI01', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '22', strDescription = 'BTI01 - Reference Number Qualifier', strScheduleList = NULL, strConfiguration = 'T2', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '22', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 161356
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-BTI02', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '23', strDescription = 'BTI02 - Reference Number', strScheduleList = NULL, strConfiguration = 'KSBTMF52', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '23', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 161357
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-BTI03', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '24', strDescription = 'BTI03 - ID Code Qualifier', strScheduleList = NULL, strConfiguration = '47', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '24', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 161358
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-BTI04', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '25', strDescription = 'BTI04 - ID Code', strScheduleList = NULL, strConfiguration = 'KS', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '25', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 161359
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-BTI07', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '26', strDescription = 'BTI07 - ID Code Qualifier', strScheduleList = NULL, strConfiguration = '24', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '26', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 161360
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-BTI09', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '27', strDescription = 'BTI09 - ID Code Qualifier', strScheduleList = NULL, strConfiguration = '49', ysnConfiguration = '1', ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '27', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 161361
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-BTI10', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '28', strDescription = 'BTI10 - KS Distributor License Number', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '28', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 161362
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', strTemplateItemId = 'KSEDI-BTI12', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '29', strDescription = 'BTI12 - Filing Type (A = Amended; O = Original; S = Supplemental)', strScheduleList = NULL, strConfiguration = 'O', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '29', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 161363

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
	SELECT intScheduleColumnId = 1, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653689
	UNION ALL SELECT intScheduleColumnId = 2, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasohol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653690
	UNION ALL SELECT intScheduleColumnId = 3, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653691
	UNION ALL SELECT intScheduleColumnId = 4, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653692
	UNION ALL SELECT intScheduleColumnId = 5, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasohol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653693
	UNION ALL SELECT intScheduleColumnId = 6, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653694
	UNION ALL SELECT intScheduleColumnId = 7, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasohol', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653695
	UNION ALL SELECT intScheduleColumnId = 8, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653696
	UNION ALL SELECT intScheduleColumnId = 9, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasohol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653697
	UNION ALL SELECT intScheduleColumnId = 10, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasohol', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653698
	UNION ALL SELECT intScheduleColumnId = 11, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653699
	UNION ALL SELECT intScheduleColumnId = 12, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasohol', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653700
	UNION ALL SELECT intScheduleColumnId = 13, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653701
	UNION ALL SELECT intScheduleColumnId = 14, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653702
	UNION ALL SELECT intScheduleColumnId = 15, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653703
	UNION ALL SELECT intScheduleColumnId = 16, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653704
	UNION ALL SELECT intScheduleColumnId = 17, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653705
	UNION ALL SELECT intScheduleColumnId = 18, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653706
	UNION ALL SELECT intScheduleColumnId = 19, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653707
	UNION ALL SELECT intScheduleColumnId = 20, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653708
	UNION ALL SELECT intScheduleColumnId = 21, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653709
	UNION ALL SELECT intScheduleColumnId = 22, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653710
	UNION ALL SELECT intScheduleColumnId = 23, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653711
	UNION ALL SELECT intScheduleColumnId = 24, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653712
	UNION ALL SELECT intScheduleColumnId = 25, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653713
	UNION ALL SELECT intScheduleColumnId = 26, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653714
	UNION ALL SELECT intScheduleColumnId = 27, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Dyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653715
	UNION ALL SELECT intScheduleColumnId = 28, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Dyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653716
	UNION ALL SELECT intScheduleColumnId = 29, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Dyed', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653717
	UNION ALL SELECT intScheduleColumnId = 30, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Dyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653718
	UNION ALL SELECT intScheduleColumnId = 31, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Dyed', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653719
	UNION ALL SELECT intScheduleColumnId = 32, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Dyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653720
	UNION ALL SELECT intScheduleColumnId = 33, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Dyed', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653721
	UNION ALL SELECT intScheduleColumnId = 34, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Dyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653722
	UNION ALL SELECT intScheduleColumnId = 35, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Dyed', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653723
	UNION ALL SELECT intScheduleColumnId = 36, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Dyed', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653724
	UNION ALL SELECT intScheduleColumnId = 37, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Dyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653725
	UNION ALL SELECT intScheduleColumnId = 38, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Dyed', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653726
	UNION ALL SELECT intScheduleColumnId = 39, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Dyed', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653727
	UNION ALL SELECT intScheduleColumnId = 40, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653728
	UNION ALL SELECT intScheduleColumnId = 41, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653729
	UNION ALL SELECT intScheduleColumnId = 42, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653730
	UNION ALL SELECT intScheduleColumnId = 43, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653731
	UNION ALL SELECT intScheduleColumnId = 44, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653732
	UNION ALL SELECT intScheduleColumnId = 45, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653733
	UNION ALL SELECT intScheduleColumnId = 46, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653734
	UNION ALL SELECT intScheduleColumnId = 47, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653735
	UNION ALL SELECT intScheduleColumnId = 48, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653736
	UNION ALL SELECT intScheduleColumnId = 49, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653737
	UNION ALL SELECT intScheduleColumnId = 50, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653738
	UNION ALL SELECT intScheduleColumnId = 51, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653739
	UNION ALL SELECT intScheduleColumnId = 52, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653740
	UNION ALL SELECT intScheduleColumnId = 53, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653741
	UNION ALL SELECT intScheduleColumnId = 54, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasohol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653742
	UNION ALL SELECT intScheduleColumnId = 55, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653743
	UNION ALL SELECT intScheduleColumnId = 56, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653744
	UNION ALL SELECT intScheduleColumnId = 57, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasohol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653745
	UNION ALL SELECT intScheduleColumnId = 58, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653746
	UNION ALL SELECT intScheduleColumnId = 59, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasohol', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653747
	UNION ALL SELECT intScheduleColumnId = 60, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653748
	UNION ALL SELECT intScheduleColumnId = 61, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasohol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653749
	UNION ALL SELECT intScheduleColumnId = 62, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasohol', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653750
	UNION ALL SELECT intScheduleColumnId = 63, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653751
	UNION ALL SELECT intScheduleColumnId = 64, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasohol', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653752
	UNION ALL SELECT intScheduleColumnId = 65, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653753
	UNION ALL SELECT intScheduleColumnId = 66, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653754
	UNION ALL SELECT intScheduleColumnId = 67, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653755
	UNION ALL SELECT intScheduleColumnId = 68, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653756
	UNION ALL SELECT intScheduleColumnId = 69, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653757
	UNION ALL SELECT intScheduleColumnId = 70, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653758
	UNION ALL SELECT intScheduleColumnId = 71, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653759
	UNION ALL SELECT intScheduleColumnId = 72, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653760
	UNION ALL SELECT intScheduleColumnId = 73, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653761
	UNION ALL SELECT intScheduleColumnId = 74, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653762
	UNION ALL SELECT intScheduleColumnId = 75, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653763
	UNION ALL SELECT intScheduleColumnId = 76, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653764
	UNION ALL SELECT intScheduleColumnId = 77, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasoline', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653765
	UNION ALL SELECT intScheduleColumnId = 78, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653766
	UNION ALL SELECT intScheduleColumnId = 79, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Dyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653767
	UNION ALL SELECT intScheduleColumnId = 80, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Dyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653768
	UNION ALL SELECT intScheduleColumnId = 81, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Dyed', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653769
	UNION ALL SELECT intScheduleColumnId = 82, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Dyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653770
	UNION ALL SELECT intScheduleColumnId = 83, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Dyed', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653771
	UNION ALL SELECT intScheduleColumnId = 84, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Dyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653772
	UNION ALL SELECT intScheduleColumnId = 85, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Dyed', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653773
	UNION ALL SELECT intScheduleColumnId = 86, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Dyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653774
	UNION ALL SELECT intScheduleColumnId = 87, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Dyed', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653775
	UNION ALL SELECT intScheduleColumnId = 88, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Dyed', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653776
	UNION ALL SELECT intScheduleColumnId = 89, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Dyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653777
	UNION ALL SELECT intScheduleColumnId = 90, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Dyed', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653778
	UNION ALL SELECT intScheduleColumnId = 91, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Dyed', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653779
	UNION ALL SELECT intScheduleColumnId = 92, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653780
	UNION ALL SELECT intScheduleColumnId = 93, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653781
	UNION ALL SELECT intScheduleColumnId = 94, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653782
	UNION ALL SELECT intScheduleColumnId = 95, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653783
	UNION ALL SELECT intScheduleColumnId = 96, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653784
	UNION ALL SELECT intScheduleColumnId = 97, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653785
	UNION ALL SELECT intScheduleColumnId = 98, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653786
	UNION ALL SELECT intScheduleColumnId = 99, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653787
	UNION ALL SELECT intScheduleColumnId = 100, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653788
	UNION ALL SELECT intScheduleColumnId = 101, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653789
	UNION ALL SELECT intScheduleColumnId = 102, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653790
	UNION ALL SELECT intScheduleColumnId = 103, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653791
	UNION ALL SELECT intScheduleColumnId = 104, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653792
	UNION ALL SELECT intScheduleColumnId = 105, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653793
	UNION ALL SELECT intScheduleColumnId = 106, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasohol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653794
	UNION ALL SELECT intScheduleColumnId = 107, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653795
	UNION ALL SELECT intScheduleColumnId = 108, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653796
	UNION ALL SELECT intScheduleColumnId = 109, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasohol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653797
	UNION ALL SELECT intScheduleColumnId = 110, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653798
	UNION ALL SELECT intScheduleColumnId = 111, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasohol', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653799
	UNION ALL SELECT intScheduleColumnId = 112, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653800
	UNION ALL SELECT intScheduleColumnId = 113, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasohol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653801
	UNION ALL SELECT intScheduleColumnId = 114, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasohol', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653802
	UNION ALL SELECT intScheduleColumnId = 115, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653803
	UNION ALL SELECT intScheduleColumnId = 116, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasohol', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653804
	UNION ALL SELECT intScheduleColumnId = 117, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653805
	UNION ALL SELECT intScheduleColumnId = 118, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653806
	UNION ALL SELECT intScheduleColumnId = 119, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653807
	UNION ALL SELECT intScheduleColumnId = 120, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653808
	UNION ALL SELECT intScheduleColumnId = 121, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653809
	UNION ALL SELECT intScheduleColumnId = 122, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653810
	UNION ALL SELECT intScheduleColumnId = 123, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653811
	UNION ALL SELECT intScheduleColumnId = 124, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653812
	UNION ALL SELECT intScheduleColumnId = 125, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653813
	UNION ALL SELECT intScheduleColumnId = 126, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653814
	UNION ALL SELECT intScheduleColumnId = 127, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653815
	UNION ALL SELECT intScheduleColumnId = 128, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653816
	UNION ALL SELECT intScheduleColumnId = 129, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653817
	UNION ALL SELECT intScheduleColumnId = 130, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653818
	UNION ALL SELECT intScheduleColumnId = 131, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Dyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653819
	UNION ALL SELECT intScheduleColumnId = 132, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Dyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653820
	UNION ALL SELECT intScheduleColumnId = 133, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Dyed', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653821
	UNION ALL SELECT intScheduleColumnId = 134, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Dyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653822
	UNION ALL SELECT intScheduleColumnId = 135, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Dyed', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653823
	UNION ALL SELECT intScheduleColumnId = 136, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Dyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653824
	UNION ALL SELECT intScheduleColumnId = 137, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Dyed', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653825
	UNION ALL SELECT intScheduleColumnId = 138, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Dyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653826
	UNION ALL SELECT intScheduleColumnId = 139, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Dyed', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653827
	UNION ALL SELECT intScheduleColumnId = 140, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Dyed', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653828
	UNION ALL SELECT intScheduleColumnId = 141, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Dyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653829
	UNION ALL SELECT intScheduleColumnId = 142, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Dyed', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653830
	UNION ALL SELECT intScheduleColumnId = 143, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Dyed', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653831
	UNION ALL SELECT intScheduleColumnId = 144, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653832
	UNION ALL SELECT intScheduleColumnId = 145, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653833
	UNION ALL SELECT intScheduleColumnId = 146, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653834
	UNION ALL SELECT intScheduleColumnId = 147, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653835
	UNION ALL SELECT intScheduleColumnId = 148, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653836
	UNION ALL SELECT intScheduleColumnId = 149, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653837
	UNION ALL SELECT intScheduleColumnId = 150, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653838
	UNION ALL SELECT intScheduleColumnId = 151, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653839
	UNION ALL SELECT intScheduleColumnId = 152, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653840
	UNION ALL SELECT intScheduleColumnId = 153, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653841
	UNION ALL SELECT intScheduleColumnId = 154, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653842
	UNION ALL SELECT intScheduleColumnId = 155, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653843
	UNION ALL SELECT intScheduleColumnId = 156, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653844
	UNION ALL SELECT intScheduleColumnId = 157, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653845
	UNION ALL SELECT intScheduleColumnId = 158, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasohol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653846
	UNION ALL SELECT intScheduleColumnId = 159, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653847
	UNION ALL SELECT intScheduleColumnId = 160, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653848
	UNION ALL SELECT intScheduleColumnId = 161, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasohol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653849
	UNION ALL SELECT intScheduleColumnId = 162, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653850
	UNION ALL SELECT intScheduleColumnId = 163, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasohol', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653851
	UNION ALL SELECT intScheduleColumnId = 164, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653852
	UNION ALL SELECT intScheduleColumnId = 165, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653853
	UNION ALL SELECT intScheduleColumnId = 166, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasohol', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653854
	UNION ALL SELECT intScheduleColumnId = 167, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653855
	UNION ALL SELECT intScheduleColumnId = 168, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653856
	UNION ALL SELECT intScheduleColumnId = 169, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasohol', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653857
	UNION ALL SELECT intScheduleColumnId = 170, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653858
	UNION ALL SELECT intScheduleColumnId = 171, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653859
	UNION ALL SELECT intScheduleColumnId = 172, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653860
	UNION ALL SELECT intScheduleColumnId = 173, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653861
	UNION ALL SELECT intScheduleColumnId = 174, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653862
	UNION ALL SELECT intScheduleColumnId = 175, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653863
	UNION ALL SELECT intScheduleColumnId = 176, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653864
	UNION ALL SELECT intScheduleColumnId = 177, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653865
	UNION ALL SELECT intScheduleColumnId = 178, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653866
	UNION ALL SELECT intScheduleColumnId = 179, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653867
	UNION ALL SELECT intScheduleColumnId = 180, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasoline', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653868
	UNION ALL SELECT intScheduleColumnId = 181, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653869
	UNION ALL SELECT intScheduleColumnId = 182, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653870
	UNION ALL SELECT intScheduleColumnId = 183, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653871
	UNION ALL SELECT intScheduleColumnId = 184, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasoline', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653872
	UNION ALL SELECT intScheduleColumnId = 185, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653873
	UNION ALL SELECT intScheduleColumnId = 186, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653874
	UNION ALL SELECT intScheduleColumnId = 187, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653875
	UNION ALL SELECT intScheduleColumnId = 188, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653876
	UNION ALL SELECT intScheduleColumnId = 189, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653877
	UNION ALL SELECT intScheduleColumnId = 190, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653878
	UNION ALL SELECT intScheduleColumnId = 191, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653879
	UNION ALL SELECT intScheduleColumnId = 192, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653880
	UNION ALL SELECT intScheduleColumnId = 193, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653881
	UNION ALL SELECT intScheduleColumnId = 194, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653882
	UNION ALL SELECT intScheduleColumnId = 195, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653883
	UNION ALL SELECT intScheduleColumnId = 196, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653884
	UNION ALL SELECT intScheduleColumnId = 197, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653885
	UNION ALL SELECT intScheduleColumnId = 198, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653886
	UNION ALL SELECT intScheduleColumnId = 199, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653887
	UNION ALL SELECT intScheduleColumnId = 200, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653888
	UNION ALL SELECT intScheduleColumnId = 201, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653889
	UNION ALL SELECT intScheduleColumnId = 202, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653890
	UNION ALL SELECT intScheduleColumnId = 203, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653891
	UNION ALL SELECT intScheduleColumnId = 204, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653892
	UNION ALL SELECT intScheduleColumnId = 205, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653893
	UNION ALL SELECT intScheduleColumnId = 206, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653894
	UNION ALL SELECT intScheduleColumnId = 207, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653895
	UNION ALL SELECT intScheduleColumnId = 208, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653896
	UNION ALL SELECT intScheduleColumnId = 209, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653897
	UNION ALL SELECT intScheduleColumnId = 210, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653898
	UNION ALL SELECT intScheduleColumnId = 211, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653899
	UNION ALL SELECT intScheduleColumnId = 212, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653900
	UNION ALL SELECT intScheduleColumnId = 213, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653901
	UNION ALL SELECT intScheduleColumnId = 214, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653902
	UNION ALL SELECT intScheduleColumnId = 215, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653903
	UNION ALL SELECT intScheduleColumnId = 216, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653904
	UNION ALL SELECT intScheduleColumnId = 217, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653905
	UNION ALL SELECT intScheduleColumnId = 218, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653906
	UNION ALL SELECT intScheduleColumnId = 219, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653907
	UNION ALL SELECT intScheduleColumnId = 220, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653908
	UNION ALL SELECT intScheduleColumnId = 221, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653909
	UNION ALL SELECT intScheduleColumnId = 222, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653910
	UNION ALL SELECT intScheduleColumnId = 223, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653911
	UNION ALL SELECT intScheduleColumnId = 224, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653912
	UNION ALL SELECT intScheduleColumnId = 225, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653913
	UNION ALL SELECT intScheduleColumnId = 226, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653914
	UNION ALL SELECT intScheduleColumnId = 227, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653915
	UNION ALL SELECT intScheduleColumnId = 228, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653916
	UNION ALL SELECT intScheduleColumnId = 229, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653917
	UNION ALL SELECT intScheduleColumnId = 230, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653918
	UNION ALL SELECT intScheduleColumnId = 231, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653919
	UNION ALL SELECT intScheduleColumnId = 232, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653920
	UNION ALL SELECT intScheduleColumnId = 233, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653921
	UNION ALL SELECT intScheduleColumnId = 234, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653922
	UNION ALL SELECT intScheduleColumnId = 235, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653923
	UNION ALL SELECT intScheduleColumnId = 236, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653924
	UNION ALL SELECT intScheduleColumnId = 237, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653925
	UNION ALL SELECT intScheduleColumnId = 238, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653926
	UNION ALL SELECT intScheduleColumnId = 239, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653927
	UNION ALL SELECT intScheduleColumnId = 240, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasoline', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653928
	UNION ALL SELECT intScheduleColumnId = 241, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653929
	UNION ALL SELECT intScheduleColumnId = 242, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653930
	UNION ALL SELECT intScheduleColumnId = 243, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653931
	UNION ALL SELECT intScheduleColumnId = 244, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasoline', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653932
	UNION ALL SELECT intScheduleColumnId = 245, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653933
	UNION ALL SELECT intScheduleColumnId = 246, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653934
	UNION ALL SELECT intScheduleColumnId = 247, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653935
	UNION ALL SELECT intScheduleColumnId = 248, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653936
	UNION ALL SELECT intScheduleColumnId = 249, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653937
	UNION ALL SELECT intScheduleColumnId = 250, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653938
	UNION ALL SELECT intScheduleColumnId = 251, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653939
	UNION ALL SELECT intScheduleColumnId = 252, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653940
	UNION ALL SELECT intScheduleColumnId = 253, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653941
	UNION ALL SELECT intScheduleColumnId = 254, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653942
	UNION ALL SELECT intScheduleColumnId = 255, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653943
	UNION ALL SELECT intScheduleColumnId = 256, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653944
	UNION ALL SELECT intScheduleColumnId = 257, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653945
	UNION ALL SELECT intScheduleColumnId = 258, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653946
	UNION ALL SELECT intScheduleColumnId = 259, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653947
	UNION ALL SELECT intScheduleColumnId = 260, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653948
	UNION ALL SELECT intScheduleColumnId = 261, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653949
	UNION ALL SELECT intScheduleColumnId = 262, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653950
	UNION ALL SELECT intScheduleColumnId = 263, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653951
	UNION ALL SELECT intScheduleColumnId = 264, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653952
	UNION ALL SELECT intScheduleColumnId = 265, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653953
	UNION ALL SELECT intScheduleColumnId = 266, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653954
	UNION ALL SELECT intScheduleColumnId = 267, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653955
	UNION ALL SELECT intScheduleColumnId = 268, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653956
	UNION ALL SELECT intScheduleColumnId = 269, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653957
	UNION ALL SELECT intScheduleColumnId = 270, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653958
	UNION ALL SELECT intScheduleColumnId = 271, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653959
	UNION ALL SELECT intScheduleColumnId = 272, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653960
	UNION ALL SELECT intScheduleColumnId = 273, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653961
	UNION ALL SELECT intScheduleColumnId = 274, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653962
	UNION ALL SELECT intScheduleColumnId = 275, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653963
	UNION ALL SELECT intScheduleColumnId = 276, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653964
	UNION ALL SELECT intScheduleColumnId = 277, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653965
	UNION ALL SELECT intScheduleColumnId = 278, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653966
	UNION ALL SELECT intScheduleColumnId = 279, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653967
	UNION ALL SELECT intScheduleColumnId = 280, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653968
	UNION ALL SELECT intScheduleColumnId = 281, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653969
	UNION ALL SELECT intScheduleColumnId = 282, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653970
	UNION ALL SELECT intScheduleColumnId = 283, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653971
	UNION ALL SELECT intScheduleColumnId = 284, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653972
	UNION ALL SELECT intScheduleColumnId = 285, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653973
	UNION ALL SELECT intScheduleColumnId = 286, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653974
	UNION ALL SELECT intScheduleColumnId = 287, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653975
	UNION ALL SELECT intScheduleColumnId = 288, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653976
	UNION ALL SELECT intScheduleColumnId = 289, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653977
	UNION ALL SELECT intScheduleColumnId = 290, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653978
	UNION ALL SELECT intScheduleColumnId = 291, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653979
	UNION ALL SELECT intScheduleColumnId = 292, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653980
	UNION ALL SELECT intScheduleColumnId = 293, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653981
	UNION ALL SELECT intScheduleColumnId = 294, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653982
	UNION ALL SELECT intScheduleColumnId = 295, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653983
	UNION ALL SELECT intScheduleColumnId = 296, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653984
	UNION ALL SELECT intScheduleColumnId = 297, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653985
	UNION ALL SELECT intScheduleColumnId = 298, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653986
	UNION ALL SELECT intScheduleColumnId = 299, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653987
	UNION ALL SELECT intScheduleColumnId = 300, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653988
	UNION ALL SELECT intScheduleColumnId = 301, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653989
	UNION ALL SELECT intScheduleColumnId = 302, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653990
	UNION ALL SELECT intScheduleColumnId = 303, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653991
	UNION ALL SELECT intScheduleColumnId = 304, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653992
	UNION ALL SELECT intScheduleColumnId = 305, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653993
	UNION ALL SELECT intScheduleColumnId = 306, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653994
	UNION ALL SELECT intScheduleColumnId = 307, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653995
	UNION ALL SELECT intScheduleColumnId = 308, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653996
	UNION ALL SELECT intScheduleColumnId = 309, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653997
	UNION ALL SELECT intScheduleColumnId = 310, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653998
	UNION ALL SELECT intScheduleColumnId = 311, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1653999
	UNION ALL SELECT intScheduleColumnId = 312, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654000
	UNION ALL SELECT intScheduleColumnId = 313, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654001
	UNION ALL SELECT intScheduleColumnId = 314, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654002
	UNION ALL SELECT intScheduleColumnId = 315, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654003
	UNION ALL SELECT intScheduleColumnId = 316, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654004
	UNION ALL SELECT intScheduleColumnId = 317, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654005
	UNION ALL SELECT intScheduleColumnId = 318, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654006
	UNION ALL SELECT intScheduleColumnId = 319, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654007
	UNION ALL SELECT intScheduleColumnId = 320, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654008
	UNION ALL SELECT intScheduleColumnId = 321, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654009
	UNION ALL SELECT intScheduleColumnId = 322, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654010
	UNION ALL SELECT intScheduleColumnId = 323, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654011
	UNION ALL SELECT intScheduleColumnId = 324, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654012
	UNION ALL SELECT intScheduleColumnId = 325, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654013
	UNION ALL SELECT intScheduleColumnId = 326, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654014
	UNION ALL SELECT intScheduleColumnId = 327, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654015
	UNION ALL SELECT intScheduleColumnId = 328, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654016
	UNION ALL SELECT intScheduleColumnId = 329, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654017
	UNION ALL SELECT intScheduleColumnId = 330, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654018
	UNION ALL SELECT intScheduleColumnId = 331, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654019
	UNION ALL SELECT intScheduleColumnId = 332, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654020
	UNION ALL SELECT intScheduleColumnId = 333, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654021
	UNION ALL SELECT intScheduleColumnId = 334, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654022
	UNION ALL SELECT intScheduleColumnId = 335, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654023
	UNION ALL SELECT intScheduleColumnId = 336, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654024
	UNION ALL SELECT intScheduleColumnId = 337, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654025
	UNION ALL SELECT intScheduleColumnId = 338, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasohol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654026
	UNION ALL SELECT intScheduleColumnId = 339, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654027
	UNION ALL SELECT intScheduleColumnId = 340, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654028
	UNION ALL SELECT intScheduleColumnId = 341, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasohol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654029
	UNION ALL SELECT intScheduleColumnId = 342, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654030
	UNION ALL SELECT intScheduleColumnId = 343, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasohol', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654031
	UNION ALL SELECT intScheduleColumnId = 344, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654032
	UNION ALL SELECT intScheduleColumnId = 345, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654033
	UNION ALL SELECT intScheduleColumnId = 346, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasohol', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654034
	UNION ALL SELECT intScheduleColumnId = 347, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654035
	UNION ALL SELECT intScheduleColumnId = 348, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654036
	UNION ALL SELECT intScheduleColumnId = 349, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasohol', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654037
	UNION ALL SELECT intScheduleColumnId = 350, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654038
	UNION ALL SELECT intScheduleColumnId = 351, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654039
	UNION ALL SELECT intScheduleColumnId = 352, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654040
	UNION ALL SELECT intScheduleColumnId = 353, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654041
	UNION ALL SELECT intScheduleColumnId = 354, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654042
	UNION ALL SELECT intScheduleColumnId = 355, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654043
	UNION ALL SELECT intScheduleColumnId = 356, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654044
	UNION ALL SELECT intScheduleColumnId = 357, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654045
	UNION ALL SELECT intScheduleColumnId = 358, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654046
	UNION ALL SELECT intScheduleColumnId = 359, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654047
	UNION ALL SELECT intScheduleColumnId = 360, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654048
	UNION ALL SELECT intScheduleColumnId = 361, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654049
	UNION ALL SELECT intScheduleColumnId = 362, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654050
	UNION ALL SELECT intScheduleColumnId = 363, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654051
	UNION ALL SELECT intScheduleColumnId = 364, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654052
	UNION ALL SELECT intScheduleColumnId = 365, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654053
	UNION ALL SELECT intScheduleColumnId = 366, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654054
	UNION ALL SELECT intScheduleColumnId = 367, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654055
	UNION ALL SELECT intScheduleColumnId = 368, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654056
	UNION ALL SELECT intScheduleColumnId = 369, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654057
	UNION ALL SELECT intScheduleColumnId = 370, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654058
	UNION ALL SELECT intScheduleColumnId = 371, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654059
	UNION ALL SELECT intScheduleColumnId = 372, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654060
	UNION ALL SELECT intScheduleColumnId = 373, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654061
	UNION ALL SELECT intScheduleColumnId = 374, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654062
	UNION ALL SELECT intScheduleColumnId = 375, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654063
	UNION ALL SELECT intScheduleColumnId = 376, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654064
	UNION ALL SELECT intScheduleColumnId = 377, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654065
	UNION ALL SELECT intScheduleColumnId = 378, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654066
	UNION ALL SELECT intScheduleColumnId = 379, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654067
	UNION ALL SELECT intScheduleColumnId = 380, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654068
	UNION ALL SELECT intScheduleColumnId = 381, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654069
	UNION ALL SELECT intScheduleColumnId = 382, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654070
	UNION ALL SELECT intScheduleColumnId = 383, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654071
	UNION ALL SELECT intScheduleColumnId = 384, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654072
	UNION ALL SELECT intScheduleColumnId = 385, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654073
	UNION ALL SELECT intScheduleColumnId = 386, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654074
	UNION ALL SELECT intScheduleColumnId = 387, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654075
	UNION ALL SELECT intScheduleColumnId = 388, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654076
	UNION ALL SELECT intScheduleColumnId = 389, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654077
	UNION ALL SELECT intScheduleColumnId = 390, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654078
	UNION ALL SELECT intScheduleColumnId = 391, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654079
	UNION ALL SELECT intScheduleColumnId = 392, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654080
	UNION ALL SELECT intScheduleColumnId = 393, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654081
	UNION ALL SELECT intScheduleColumnId = 394, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654082
	UNION ALL SELECT intScheduleColumnId = 395, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654083
	UNION ALL SELECT intScheduleColumnId = 396, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654084
	UNION ALL SELECT intScheduleColumnId = 397, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654085
	UNION ALL SELECT intScheduleColumnId = 398, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654086
	UNION ALL SELECT intScheduleColumnId = 399, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654087
	UNION ALL SELECT intScheduleColumnId = 400, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654088
	UNION ALL SELECT intScheduleColumnId = 401, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654089
	UNION ALL SELECT intScheduleColumnId = 402, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654090
	UNION ALL SELECT intScheduleColumnId = 403, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654091
	UNION ALL SELECT intScheduleColumnId = 404, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654092
	UNION ALL SELECT intScheduleColumnId = 405, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654093
	UNION ALL SELECT intScheduleColumnId = 406, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654094
	UNION ALL SELECT intScheduleColumnId = 407, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654095
	UNION ALL SELECT intScheduleColumnId = 408, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654096
	UNION ALL SELECT intScheduleColumnId = 409, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654097
	UNION ALL SELECT intScheduleColumnId = 410, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654098
	UNION ALL SELECT intScheduleColumnId = 411, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654099
	UNION ALL SELECT intScheduleColumnId = 412, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654100
	UNION ALL SELECT intScheduleColumnId = 413, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654101
	UNION ALL SELECT intScheduleColumnId = 414, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654102
	UNION ALL SELECT intScheduleColumnId = 415, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654103
	UNION ALL SELECT intScheduleColumnId = 416, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654104
	UNION ALL SELECT intScheduleColumnId = 417, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654105
	UNION ALL SELECT intScheduleColumnId = 418, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654106
	UNION ALL SELECT intScheduleColumnId = 419, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654107
	UNION ALL SELECT intScheduleColumnId = 420, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654108
	UNION ALL SELECT intScheduleColumnId = 421, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654109
	UNION ALL SELECT intScheduleColumnId = 422, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654110
	UNION ALL SELECT intScheduleColumnId = 423, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654111
	UNION ALL SELECT intScheduleColumnId = 424, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654112
	UNION ALL SELECT intScheduleColumnId = 425, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654113
	UNION ALL SELECT intScheduleColumnId = 426, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654114
	UNION ALL SELECT intScheduleColumnId = 427, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654115
	UNION ALL SELECT intScheduleColumnId = 428, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654116
	UNION ALL SELECT intScheduleColumnId = 429, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654117
	UNION ALL SELECT intScheduleColumnId = 430, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654118
	UNION ALL SELECT intScheduleColumnId = 431, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654119
	UNION ALL SELECT intScheduleColumnId = 432, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654120
	UNION ALL SELECT intScheduleColumnId = 433, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654121
	UNION ALL SELECT intScheduleColumnId = 434, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654122
	UNION ALL SELECT intScheduleColumnId = 435, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654123
	UNION ALL SELECT intScheduleColumnId = 436, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654124
	UNION ALL SELECT intScheduleColumnId = 437, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654125
	UNION ALL SELECT intScheduleColumnId = 438, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654126
	UNION ALL SELECT intScheduleColumnId = 439, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654127
	UNION ALL SELECT intScheduleColumnId = 440, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654128
	UNION ALL SELECT intScheduleColumnId = 441, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654129
	UNION ALL SELECT intScheduleColumnId = 442, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654130
	UNION ALL SELECT intScheduleColumnId = 443, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654131
	UNION ALL SELECT intScheduleColumnId = 444, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654132
	UNION ALL SELECT intScheduleColumnId = 445, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654133
	UNION ALL SELECT intScheduleColumnId = 446, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654134
	UNION ALL SELECT intScheduleColumnId = 447, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654135
	UNION ALL SELECT intScheduleColumnId = 448, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654136
	UNION ALL SELECT intScheduleColumnId = 449, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654137
	UNION ALL SELECT intScheduleColumnId = 450, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654138
	UNION ALL SELECT intScheduleColumnId = 451, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654139
	UNION ALL SELECT intScheduleColumnId = 452, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654140
	UNION ALL SELECT intScheduleColumnId = 453, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654141
	UNION ALL SELECT intScheduleColumnId = 454, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654142
	UNION ALL SELECT intScheduleColumnId = 455, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654143
	UNION ALL SELECT intScheduleColumnId = 456, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654144
	UNION ALL SELECT intScheduleColumnId = 457, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654145
	UNION ALL SELECT intScheduleColumnId = 458, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654146
	UNION ALL SELECT intScheduleColumnId = 459, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654147
	UNION ALL SELECT intScheduleColumnId = 460, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654148
	UNION ALL SELECT intScheduleColumnId = 461, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654149
	UNION ALL SELECT intScheduleColumnId = 462, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654150
	UNION ALL SELECT intScheduleColumnId = 463, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654151
	UNION ALL SELECT intScheduleColumnId = 464, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654152
	UNION ALL SELECT intScheduleColumnId = 465, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654153
	UNION ALL SELECT intScheduleColumnId = 466, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654154
	UNION ALL SELECT intScheduleColumnId = 467, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654155
	UNION ALL SELECT intScheduleColumnId = 468, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654156
	UNION ALL SELECT intScheduleColumnId = 469, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654157
	UNION ALL SELECT intScheduleColumnId = 470, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654158
	UNION ALL SELECT intScheduleColumnId = 471, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654159
	UNION ALL SELECT intScheduleColumnId = 472, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654160
	UNION ALL SELECT intScheduleColumnId = 473, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654161
	UNION ALL SELECT intScheduleColumnId = 474, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654162
	UNION ALL SELECT intScheduleColumnId = 475, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654163
	UNION ALL SELECT intScheduleColumnId = 476, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654164
	UNION ALL SELECT intScheduleColumnId = 477, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654165
	UNION ALL SELECT intScheduleColumnId = 478, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654166
	UNION ALL SELECT intScheduleColumnId = 479, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654167
	UNION ALL SELECT intScheduleColumnId = 480, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasoline', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654168
	UNION ALL SELECT intScheduleColumnId = 481, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654169
	UNION ALL SELECT intScheduleColumnId = 482, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654170
	UNION ALL SELECT intScheduleColumnId = 483, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654171
	UNION ALL SELECT intScheduleColumnId = 484, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasoline', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654172
	UNION ALL SELECT intScheduleColumnId = 485, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654173
	UNION ALL SELECT intScheduleColumnId = 486, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654174
	UNION ALL SELECT intScheduleColumnId = 487, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654175
	UNION ALL SELECT intScheduleColumnId = 488, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654176
	UNION ALL SELECT intScheduleColumnId = 489, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654177
	UNION ALL SELECT intScheduleColumnId = 490, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654178
	UNION ALL SELECT intScheduleColumnId = 491, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654179
	UNION ALL SELECT intScheduleColumnId = 492, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654180
	UNION ALL SELECT intScheduleColumnId = 493, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654181
	UNION ALL SELECT intScheduleColumnId = 494, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654182
	UNION ALL SELECT intScheduleColumnId = 495, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654183
	UNION ALL SELECT intScheduleColumnId = 496, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654184
	UNION ALL SELECT intScheduleColumnId = 497, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654185
	UNION ALL SELECT intScheduleColumnId = 498, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654186
	UNION ALL SELECT intScheduleColumnId = 499, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654187
	UNION ALL SELECT intScheduleColumnId = 500, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654188
	UNION ALL SELECT intScheduleColumnId = 501, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654189
	UNION ALL SELECT intScheduleColumnId = 502, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654190
	UNION ALL SELECT intScheduleColumnId = 503, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654191
	UNION ALL SELECT intScheduleColumnId = 504, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654192
	UNION ALL SELECT intScheduleColumnId = 505, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654193
	UNION ALL SELECT intScheduleColumnId = 506, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654194
	UNION ALL SELECT intScheduleColumnId = 507, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654195
	UNION ALL SELECT intScheduleColumnId = 508, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', strColumn = 'strDestinationCity', strCaption = 'Destination city', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654196
	UNION ALL SELECT intScheduleColumnId = 509, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654197
	UNION ALL SELECT intScheduleColumnId = 510, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654198
	UNION ALL SELECT intScheduleColumnId = 511, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654199
	UNION ALL SELECT intScheduleColumnId = 512, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654200
	UNION ALL SELECT intScheduleColumnId = 513, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654201
	UNION ALL SELECT intScheduleColumnId = 514, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', strColumn = 'strBillofLading', strCaption = 'BoL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654202
	UNION ALL SELECT intScheduleColumnId = 515, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654203
	UNION ALL SELECT intScheduleColumnId = 516, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 1654204

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
	SELECT intFilingPacketId = 0, strFormCode = 'KS EDI', strScheduleCode = '', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 163399
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 163400
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasohol', ysnStatus = 1, intFrequency = 1, intMasterId = 163401
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 163402
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Dyed', ysnStatus = 1, intFrequency = 1, intMasterId = 163403
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '1', strType = 'Special Fuel - Undyed', ysnStatus = 1, intFrequency = 1, intMasterId = 163404
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasohol', ysnStatus = 1, intFrequency = 1, intMasterId = 163405
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 163406
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Dyed', ysnStatus = 1, intFrequency = 1, intMasterId = 163407
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '10', strType = 'Special Fuel - Undyed', ysnStatus = 1, intFrequency = 1, intMasterId = 163408
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasohol', ysnStatus = 1, intFrequency = 1, intMasterId = 163409
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 163410
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Dyed', ysnStatus = 1, intFrequency = 1, intMasterId = 163411
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '2', strType = 'Special Fuel - Undyed', ysnStatus = 1, intFrequency = 1, intMasterId = 163412
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasohol', ysnStatus = 1, intFrequency = 1, intMasterId = 163413
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 163414
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Dyed', ysnStatus = 1, intFrequency = 1, intMasterId = 163415
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '3', strType = 'Special Fuel - Undyed', ysnStatus = 1, intFrequency = 1, intMasterId = 163416
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasohol', ysnStatus = 1, intFrequency = 1, intMasterId = 163417
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 163418
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Dyed', ysnStatus = 1, intFrequency = 1, intMasterId = 163419
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '5', strType = 'Special Fuel - Undyed', ysnStatus = 1, intFrequency = 1, intMasterId = 163420
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasohol', ysnStatus = 1, intFrequency = 1, intMasterId = 163421
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 163422
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Dyed', ysnStatus = 1, intFrequency = 1, intMasterId = 163423
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '6', strType = 'Special Fuel - Undyed', ysnStatus = 1, intFrequency = 1, intMasterId = 163424
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasohol', ysnStatus = 1, intFrequency = 1, intMasterId = 163425
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 163426
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Dyed', ysnStatus = 1, intFrequency = 1, intMasterId = 163427
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '7', strType = 'Special Fuel - Undyed', ysnStatus = 1, intFrequency = 1, intMasterId = 163428
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasohol', ysnStatus = 1, intFrequency = 1, intMasterId = 163429
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 163430
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Dyed', ysnStatus = 1, intFrequency = 1, intMasterId = 163431
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '8', strType = 'Special Fuel - Undyed', ysnStatus = 1, intFrequency = 1, intMasterId = 163432
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasohol', ysnStatus = 1, intFrequency = 1, intMasterId = 163433
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 163434
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Dyed', ysnStatus = 1, intFrequency = 1, intMasterId = 163435
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'MF-52', strScheduleCode = '9', strType = 'Special Fuel - Undyed', ysnStatus = 1, intFrequency = 1, intMasterId = 163436

	EXEC uspTFUpgradeFilingPackets @TaxAuthorityCode = @TaxAuthorityCode, @FilingPackets = @FilingPackets

END

GO