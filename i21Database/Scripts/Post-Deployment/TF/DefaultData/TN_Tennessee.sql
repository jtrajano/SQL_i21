DECLARE @TaxAuthorityCode NVARCHAR(10) = 'TN'
	, @TaxAuthorityId INT

SELECT @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = @TaxAuthorityCode AND ysnFilingForThisTA = 1

IF(@TaxAuthorityId IS NOT NULL)
BEGIN

	PRINT ('Deploying Tennessee Tax Forms')

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
	SELECT intProductCodeId = 0, strProductCode = '065', strDescription = 'Gasoline', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 421147
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '071', strDescription = 'Gasoline MTBE', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 421148
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '072', strDescription = 'Kerosene - Dyed', strProductCodeGroup = 'Kerosene', strNote = NULL, intMasterId = 421149
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '073', strDescription = 'Low Sulfur Kerosene - Dyed', strProductCodeGroup = 'Kerosene', strNote = NULL, intMasterId = 421150
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '074', strDescription = 'High Sulfur Kerosene - Dyed', strProductCodeGroup = 'Kerosene', strNote = NULL, intMasterId = 421151
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '090', strDescription = 'Additives - Miscellaneous', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 421152
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '093', strDescription = 'MTBE', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 421153
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '100', strDescription = 'Transmix', strProductCodeGroup = 'Kerosene', strNote = NULL, intMasterId = 421154
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '122', strDescription = 'Blend Components', strProductCodeGroup = 'Kerosene', strNote = NULL, intMasterId = 421155
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '123', strDescription = 'Alcohol', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 421156
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '124', strDescription = 'Gasohol', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 421157
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '125', strDescription = 'Aviation Gasoline', strProductCodeGroup = 'Aviation Gas', strNote = NULL, intMasterId = 421158
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '130', strDescription = 'Jet Fuel', strProductCodeGroup = 'Jet Fuel', strNote = NULL, intMasterId = 421159
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '139', strDescription = 'Gasohol 10%', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 421160
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '140', strDescription = 'Gasohol 5.7%', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 421161
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '141', strDescription = 'Gasohol 7.7%', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 421162
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '142', strDescription = 'Kerosene – Undyed', strProductCodeGroup = 'Kerosene', strNote = NULL, intMasterId = 421163
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '145', strDescription = 'Low Sulfur Kerosene – Undyed', strProductCodeGroup = 'Kerosene', strNote = NULL, intMasterId = 421164
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '147', strDescription = 'High Sulfur Kerosene – Undyed', strProductCodeGroup = 'Kerosene', strNote = NULL, intMasterId = 421165
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '150', strDescription = 'No. 1 Fuel Oil –Undyed', strProductCodeGroup = 'Kerosene', strNote = NULL, intMasterId = 421166
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '160', strDescription = 'Diesel Fuel – Undyed', strProductCodeGroup = 'Diesel Undyed', strNote = NULL, intMasterId = 421167
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '161', strDescription = 'Low Sulfur Diesel Fuel #1 – Undyed', strProductCodeGroup = 'Diesel Undyed', strNote = NULL, intMasterId = 421168
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '167', strDescription = 'Low Sulfur Diesel Fuel #2 – Undyed', strProductCodeGroup = 'Diesel Undyed', strNote = NULL, intMasterId = 421169
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '226', strDescription = 'High Sulfur Diesel Fuel - Dyed', strProductCodeGroup = 'Diesel Dyed', strNote = NULL, intMasterId = 421170
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '227', strDescription = 'Low Sulfur Diesel Fuel - Dyed', strProductCodeGroup = 'Diesel Dyed', strNote = NULL, intMasterId = 421171
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '228', strDescription = 'Diesel Fuel - Dyed', strProductCodeGroup = 'Diesel Dyed', strNote = NULL, intMasterId = 421172
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '231', strDescription = 'No 1 Diesel - Dyed', strProductCodeGroup = 'Diesel Dyed', strNote = NULL, intMasterId = 421173
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '241', strDescription = 'Ethanol', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 421174
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '243', strDescription = 'Methanol', strProductCodeGroup = 'Kerosene', strNote = NULL, intMasterId = 421175
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '249', strDescription = 'ETBE', strProductCodeGroup = 'Gasoline', strNote = NULL, intMasterId = 421176
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '284', strDescription = 'Biodiesel', strProductCodeGroup = 'Kerosene', strNote = NULL, intMasterId = 421177

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
	SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '1IN', strScheduleName = 'Gals Exported to IN, IN Tax Paid to Vendor', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 10, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422336, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '1IN', strScheduleName = 'Gals Exported to IN, IN Tax Paid to Vendor', strType = 'Diesel Dyed', strNote = '', strTransactionType = 'Invoice', intSort = 40, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422337, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '1IN', strScheduleName = 'Gals Exported to IN, IN Tax Paid to Vendor', strType = 'Diesel Undyed', strNote = '', strTransactionType = 'Invoice', intSort = 70, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422338, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '1IN', strScheduleName = 'Gals Exported to IN, IN Tax Paid to Vendor', strType = 'Kerosene', strNote = '', strTransactionType = 'Invoice', intSort = 100, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422339, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '1IN', strScheduleName = 'Gals Exported to IN, IN Tax Paid to Vendor', strType = 'Jet Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 130, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422340, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '1IN', strScheduleName = 'Gals Exported to IN, IN Tax Paid to Vendor', strType = 'Aviation Gas', strNote = '', strTransactionType = 'Invoice', intSort = 160, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422341, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '1KY', strScheduleName = 'Gals Exported to KY, KY Tax Paid to Vendor', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 190, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422342, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '1KY', strScheduleName = 'Gals Exported to KY, KY Tax Paid to Vendor', strType = 'Diesel Dyed', strNote = '', strTransactionType = 'Invoice', intSort = 220, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422343, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '1KY', strScheduleName = 'Gals Exported to KY, KY Tax Paid to Vendor', strType = 'Diesel Undyed', strNote = '', strTransactionType = 'Invoice', intSort = 250, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422344, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '1KY', strScheduleName = 'Gals Exported to KY, KY Tax Paid to Vendor', strType = 'Kerosene', strNote = '', strTransactionType = 'Invoice', intSort = 280, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422345, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '1KY', strScheduleName = 'Gals Exported to KY, KY Tax Paid to Vendor', strType = 'Jet Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 310, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422346, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '1KY', strScheduleName = 'Gals Exported to KY, KY Tax Paid to Vendor', strType = 'Aviation Gas', strNote = '', strTransactionType = 'Invoice', intSort = 340, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422347, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '2IN', strScheduleName = 'Gals Exported to IN, IN Tax Not Paid to Vendor', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 370, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422348, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '2IN', strScheduleName = 'Gals Exported to IN, IN Tax Not Paid to Vendor', strType = 'Diesel Dyed', strNote = '', strTransactionType = 'Invoice', intSort = 400, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422349, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '2IN', strScheduleName = 'Gals Exported to IN, IN Tax Not Paid to Vendor', strType = 'Diesel Undyed', strNote = '', strTransactionType = 'Invoice', intSort = 430, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422350, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '2IN', strScheduleName = 'Gals Exported to IN, IN Tax Not Paid to Vendor', strType = 'Kerosene', strNote = '', strTransactionType = 'Invoice', intSort = 460, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422351, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '2IN', strScheduleName = 'Gals Exported to IN, IN Tax Not Paid to Vendor', strType = 'Jet Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 490, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422352, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '2IN', strScheduleName = 'Gals Exported to IN, IN Tax Not Paid to Vendor', strType = 'Aviation Gas', strNote = '', strTransactionType = 'Invoice', intSort = 520, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422353, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '2KY', strScheduleName = 'Gals Exported to KY, KY Tax Not Paid to Vendor', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 550, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422354, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '2KY', strScheduleName = 'Gals Exported to KY, KY Tax Not Paid to Vendor', strType = 'Diesel Dyed', strNote = '', strTransactionType = 'Invoice', intSort = 580, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422355, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '2KY', strScheduleName = 'Gals Exported to KY, KY Tax Not Paid to Vendor', strType = 'Diesel Undyed', strNote = '', strTransactionType = 'Invoice', intSort = 610, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422356, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '2KY', strScheduleName = 'Gals Exported to KY, KY Tax Not Paid to Vendor', strType = 'Kerosene', strNote = '', strTransactionType = 'Invoice', intSort = 640, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422357, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '2KY', strScheduleName = 'Gals Exported to KY, KY Tax Not Paid to Vendor', strType = 'Jet Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 670, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422358, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '2KY', strScheduleName = 'Gals Exported to KY, KY Tax Not Paid to Vendor', strType = 'Aviation Gas', strNote = '', strTransactionType = 'Invoice', intSort = 700, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422359, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '4', strScheduleName = 'Gals Exported, TN Tax Paid to Vendor', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 730, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422360, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '4', strScheduleName = 'Gals Exported, TN Tax Paid to Vendor', strType = 'Diesel Dyed', strNote = '', strTransactionType = 'Invoice', intSort = 760, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422361, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '4', strScheduleName = 'Gals Exported, TN Tax Paid to Vendor', strType = 'Diesel Undyed', strNote = '', strTransactionType = 'Invoice', intSort = 790, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422362, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '4', strScheduleName = 'Gals Exported, TN Tax Paid to Vendor', strType = 'Kerosene', strNote = '', strTransactionType = 'Invoice', intSort = 820, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422363, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '4', strScheduleName = 'Gals Exported, TN Tax Paid to Vendor', strType = 'Jet Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 850, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422364, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '4', strScheduleName = 'Gals Exported, TN Tax Paid to Vendor', strType = 'Aviation Gas', strNote = '', strTransactionType = 'Invoice', intSort = 880, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 422365, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = '', strScheduleName = 'Main Form', strType = '', strNote = 'Main Form', strTransactionType = '', intSort = 1900, strStoredProcedure = '', intMasterId = 422366, intComponentTypeId = 2
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'TN EXCEL FILE', strFormName = 'Tennessee Excel File', strScheduleCode = '', strScheduleName = 'Tennessee Excel File', strType = '', strNote = 'EFile', strTransactionType = '', intSort = 2000, strStoredProcedure = '', intMasterId = 422367, intComponentTypeId = 4
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = 'DivIntoTN', strScheduleName = 'Diversion into TN', strType = 'Gasoline', strNote = '', strTransactionType = 'Inventory', intSort = 1000, strStoredProcedure = 'uspTFGetDiversionTax', intMasterId = 422368, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = 'DivIntoTN', strScheduleName = 'Diversion into TN', strType = 'Diesel Dyed', strNote = '', strTransactionType = 'Inventory', intSort = 1010, strStoredProcedure = 'uspTFGetDiversionTax', intMasterId = 422369, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = 'DivIntoTN', strScheduleName = 'Diversion into TN', strType = 'Diesel Undyed', strNote = '', strTransactionType = 'Inventory', intSort = 1020, strStoredProcedure = 'uspTFGetDiversionTax', intMasterId = 422370, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = 'DivIntoTN', strScheduleName = 'Diversion into TN', strType = 'Kerosene', strNote = '', strTransactionType = 'Inventory', intSort = 1030, strStoredProcedure = 'uspTFGetDiversionTax', intMasterId = 422371, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = 'DivIntoTN', strScheduleName = 'Diversion into TN', strType = 'Jet Fuel', strNote = '', strTransactionType = 'Inventory', intSort = 1040, strStoredProcedure = 'uspTFGetDiversionTax', intMasterId = 422372, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = 'DivIntoTN', strScheduleName = 'Diversion into TN', strType = 'Aviation Gas', strNote = '', strTransactionType = 'Inventory', intSort = 1050, strStoredProcedure = 'uspTFGetDiversionTax', intMasterId = 422373, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = 'DivFromTN', strScheduleName = 'Diversion from TN', strType = 'Gasoline', strNote = '', strTransactionType = 'Inventory', intSort = 1060, strStoredProcedure = 'uspTFGetDiversionTax', intMasterId = 422374, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = 'DivFromTN', strScheduleName = 'Diversion from TN', strType = 'Diesel Dyed', strNote = '', strTransactionType = 'Inventory', intSort = 1070, strStoredProcedure = 'uspTFGetDiversionTax', intMasterId = 422375, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = 'DivFromTN', strScheduleName = 'Diversion from TN', strType = 'Diesel Undyed', strNote = '', strTransactionType = 'Inventory', intSort = 1080, strStoredProcedure = 'uspTFGetDiversionTax', intMasterId = 422376, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = 'DivFromTN', strScheduleName = 'Diversion from TN', strType = 'Kerosene', strNote = '', strTransactionType = 'Inventory', intSort = 1090, strStoredProcedure = 'uspTFGetDiversionTax', intMasterId = 422377, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = 'DivFromTN', strScheduleName = 'Diversion from TN', strType = 'Jet Fuel', strNote = '', strTransactionType = 'Inventory', intSort = 1100, strStoredProcedure = 'uspTFGetDiversionTax', intMasterId = 422378, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'PET377', strFormName = 'Exporter Return', strScheduleCode = 'DivFromTN', strScheduleName = 'Diversion from TN', strType = 'Aviation Gas', strNote = '', strTransactionType = 'Inventory', intSort = 1110, strStoredProcedure = 'uspTFGetDiversionTax', intMasterId = 422379, intComponentTypeId = 1

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

	--INSERT INTO @TaxCriteria(
	--	intTaxCriteriaId
	--	, strTaxCategory
	--	, strState
	--	, strFormCode
	--	, strScheduleCode
	--	, strType
	--	, strCriteria
	--	, intMasterId
	--)

	--EXEC uspTFUpgradeTaxCriteria @TaxAuthorityCode = @TaxAuthorityCode, @TaxCriteria = @TaxCriteria


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
	
	--DECLARE @ValidProductCodes AS TFValidProductCodes
	--DECLARE @ValidOriginStates AS TFValidOriginStates
	--DECLARE @ValidDestinationStates AS TFValidDestinationStates

	--INSERT INTO @ValidProductCodes(
	--	intValidProductCodeId
	--	, strProductCode
	--	, strFormCode
	--	, strScheduleCode
	--	, strType
	--	, intMasterId
	--)

	--INSERT INTO @ValidOriginStates(
	--	intValidOriginStateId
	--	, strFormCode
	--	, strScheduleCode
	--	, strType
	--	, strState
	--	, strStatus
	--	, intMasterId
	--)

	--INSERT INTO @ValidDestinationStates(
	--	intValidDestinationStateId
	--	, strFormCode
	--	, strScheduleCode
	--	, strType
	--	, strState
	--	, strStatus
	--	, intMasterId
	--)

	--EXEC uspTFUpgradeValidProductCodes @TaxAuthorityCode = @TaxAuthorityCode, @ValidProductCodes = @ValidProductCodes
	--EXEC uspTFUpgradeValidOriginStates @TaxAuthorityCode = @TaxAuthorityCode, @ValidOriginStates = @ValidOriginStates
	--EXEC uspTFUpgradeValidDestinationStates @TaxAuthorityCode = @TaxAuthorityCode, @ValidDestinationStates = @ValidDestinationStates

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
	--DECLARE @ReportingComponentConfigurations AS TFReportingComponentConfigurations

	--INSERT INTO @ReportingComponentConfigurations(
	--	intReportTemplateId
	--	, strFormCode
	--	, strScheduleCode
	--	, strType
	--	, strTemplateItemId
	--	, strReportSection
	--	, intReportItemSequence
	--	, intTemplateItemNumber
	--	, strDescription
	--	, strScheduleList
	--	, strConfiguration
	--	, ysnConfiguration
	--	, ysnUserDefinedValue
	--	, strLastIndexOf
	--	, strSegment
	--	, intSort
	--	, ysnOutputDesigner
	--	, intMasterId
	--)

	--EXEC uspTFUpgradeReportingComponentConfigurations @TaxAuthorityCode = @TaxAuthorityCode, @ReportingComponentConfigurations = @ReportingComponentConfigurations


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
	--DECLARE @ReportingComponentOutputDesigners AS TFReportingComponentOutputDesigners

	--INSERT INTO @ReportingComponentOutputDesigners(
	--	intScheduleColumnId
	--	, strFormCode
	--	, strScheduleCode
	--	, strType
	--	, strColumn
	--	, strCaption
	--	, strFormat
	--	, strFooter
	--	, intWidth
	--	, ysnFromConfiguration
	--	, intMasterId
	--)

	--EXEC uspTFUpgradeReportingComponentOutputDesigners @TaxAuthorityCode = @TaxAuthorityCode, @ReportingComponentOutputDesigners = @ReportingComponentOutputDesigners


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
	SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 423437
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '1IN', strType = 'Aviation Gas', ysnStatus = 1, intFrequency = 1, intMasterId = 423438
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '1IN', strType = 'Diesel Dyed', ysnStatus = 1, intFrequency = 1, intMasterId = 423439
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '1IN', strType = 'Diesel Undyed', ysnStatus = 1, intFrequency = 1, intMasterId = 423440
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '1IN', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 423441
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '1IN', strType = 'Jet Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 423442
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '1IN', strType = 'Kerosene', ysnStatus = 1, intFrequency = 1, intMasterId = 423443
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '1KY', strType = 'Aviation Gas', ysnStatus = 1, intFrequency = 1, intMasterId = 423444
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '1KY', strType = 'Diesel Dyed', ysnStatus = 1, intFrequency = 1, intMasterId = 423445
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '1KY', strType = 'Diesel Undyed', ysnStatus = 1, intFrequency = 1, intMasterId = 423446
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '1KY', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 423447
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '1KY', strType = 'Jet Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 423448
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '1KY', strType = 'Kerosene', ysnStatus = 1, intFrequency = 1, intMasterId = 423449
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '2IN', strType = 'Aviation Gas', ysnStatus = 1, intFrequency = 1, intMasterId = 423450
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '2IN', strType = 'Diesel Dyed', ysnStatus = 1, intFrequency = 1, intMasterId = 423451
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '2IN', strType = 'Diesel Undyed', ysnStatus = 1, intFrequency = 1, intMasterId = 423452
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '2IN', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 423453
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '2IN', strType = 'Jet Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 423454
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '2IN', strType = 'Kerosene', ysnStatus = 1, intFrequency = 1, intMasterId = 423455
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '2KY', strType = 'Aviation Gas', ysnStatus = 1, intFrequency = 1, intMasterId = 423456
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '2KY', strType = 'Diesel Dyed', ysnStatus = 1, intFrequency = 1, intMasterId = 423457
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '2KY', strType = 'Diesel Undyed', ysnStatus = 1, intFrequency = 1, intMasterId = 423458
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '2KY', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 423459
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '2KY', strType = 'Jet Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 423460
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '2KY', strType = 'Kerosene', ysnStatus = 1, intFrequency = 1, intMasterId = 423461
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '4', strType = 'Aviation Gas', ysnStatus = 1, intFrequency = 1, intMasterId = 423462
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '4', strType = 'Diesel Dyed', ysnStatus = 1, intFrequency = 1, intMasterId = 423463
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '4', strType = 'Diesel Undyed', ysnStatus = 1, intFrequency = 1, intMasterId = 423464
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '4', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 423465
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '4', strType = 'Jet Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 423466
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = '4', strType = 'Kerosene', ysnStatus = 1, intFrequency = 1, intMasterId = 423467
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = 'DivFromTN', strType = 'Aviation Gas', ysnStatus = 1, intFrequency = 1, intMasterId = 423480
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = 'DivFromTN', strType = 'Diesel Dyed', ysnStatus = 1, intFrequency = 1, intMasterId = 423476
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = 'DivFromTN', strType = 'Diesel Undyed', ysnStatus = 1, intFrequency = 1, intMasterId = 423477
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = 'DivFromTN', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 423475
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = 'DivFromTN', strType = 'Jet Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 423479
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = 'DivFromTN', strType = 'Kerosene', ysnStatus = 1, intFrequency = 1, intMasterId = 423478
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = 'DivIntoTN', strType = 'Aviation Gas', ysnStatus = 1, intFrequency = 1, intMasterId = 423474
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = 'DivIntoTN', strType = 'Diesel Dyed', ysnStatus = 1, intFrequency = 1, intMasterId = 423470
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = 'DivIntoTN', strType = 'Diesel Undyed', ysnStatus = 1, intFrequency = 1, intMasterId = 423471
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = 'DivIntoTN', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 423469
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = 'DivIntoTN', strType = 'Jet Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 423473
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'PET377', strScheduleCode = 'DivIntoTN', strType = 'Kerosene', ysnStatus = 1, intFrequency = 1, intMasterId = 423472
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'TN EXCEL FILE', strScheduleCode = '', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 423468

	EXEC uspTFUpgradeFilingPackets @TaxAuthorityCode = @TaxAuthorityCode, @FilingPackets = @FilingPackets

END

GO