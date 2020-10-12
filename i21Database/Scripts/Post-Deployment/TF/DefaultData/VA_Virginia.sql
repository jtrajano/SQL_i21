
IF EXISTS(SELECT TOP 1 intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'VA' AND ysnFilingForThisTA = 1)
BEGIN
	PRINT ('Deploying Virginia Tax Forms')
END
GO

DECLARE @TaxAuthorityCode NVARCHAR(10) = 'VA'
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
	SELECT intProductCodeId = 0, strProductCode = '125', strDescription = 'Aviation Gasoline', strProductCodeGroup = 'Aviation Gasoline', strNote = NULL, intMasterId = 4600001
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '130', strDescription = 'Aviation Jet Fuel', strProductCodeGroup = 'Aviation Jet Fuel', strNote = NULL, intMasterId = 4600002
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '122', strDescription = 'Blending Components', strProductCodeGroup = 'Blending Components', strNote = NULL, intMasterId = 4600003
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '224', strDescription = 'Compressed Natural Gas', strProductCodeGroup = 'Compressed Natural Gas', strNote = NULL, intMasterId = 4600004
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '228', strDescription = 'Diesel - Dyed', strProductCodeGroup = 'Dyed Diesel', strNote = NULL, intMasterId = 4600005
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '153', strDescription = 'Diesel Fuel #4 - Dyed', strProductCodeGroup = 'Dyed Diesel', strNote = NULL, intMasterId = 4600006
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '226', strDescription = 'High Sulphur Diesel - Dyed', strProductCodeGroup = 'Dyed Diesel', strNote = NULL, intMasterId = 4600007
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '227', strDescription = 'Low Sulphur Diesel - Dyed', strProductCodeGroup = 'Dyed Diesel', strNote = NULL, intMasterId = 4600008
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '231', strDescription = 'No. 1 Diesel - Dyed', strProductCodeGroup = 'Dyed Diesel', strNote = NULL, intMasterId = 4600009
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '171', strDescription = '100% Biodiesel - Dyed', strProductCodeGroup = 'Dyed Diesel', strNote = NULL, intMasterId = 4600010
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '092', strDescription = 'Other(undefined)', strProductCodeGroup = 'Dyed Diesel', strNote = NULL, intMasterId = 4600011
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '279', strDescription = 'Marine Diesel Oil', strProductCodeGroup = 'Dyed Diesel', strNote = NULL, intMasterId = 4600012
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '241', strDescription = 'Ethanol', strProductCodeGroup = 'Ethanol', strNote = NULL, intMasterId = 4600013
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '123', strDescription = 'Alcohol', strProductCodeGroup = 'Fuel Alcohol', strNote = NULL, intMasterId = 4600014
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '078', strDescription = 'E75', strProductCodeGroup = 'Gasoline/Gasohol', strNote = NULL, intMasterId = 4600015
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '079', strDescription = 'E85', strProductCodeGroup = 'Gasoline/Gasohol', strNote = NULL, intMasterId = 4600016
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '124', strDescription = 'Gasohol', strProductCodeGroup = 'Gasoline/Gasohol', strNote = NULL, intMasterId = 4600017
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '065', strDescription = 'Gasoline', strProductCodeGroup = 'Gasoline/Gasohol', strNote = NULL, intMasterId = 4600018
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '071', strDescription = 'Gasoline MTBE', strProductCodeGroup = 'Gasoline/Gasohol', strNote = NULL, intMasterId = 4600019
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '123', strDescription = 'Alcohol', strProductCodeGroup = 'Gasoline/Gasohol', strNote = NULL, intMasterId = 4600020
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '241', strDescription = 'Ethanol', strProductCodeGroup = 'Gasoline/Gasohol', strNote = NULL, intMasterId = 4600021
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '280', strDescription = 'Marine Gas Oil', strProductCodeGroup = 'Gasoline/Gasohol', strNote = NULL, intMasterId = 4600022
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '243', strDescription = 'Methanol', strProductCodeGroup = 'Gasoline/Gasohol', strNote = NULL, intMasterId = 4600023
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '224', strDescription = 'Compressed Natural Gas', strProductCodeGroup = 'Gasoline/Gasohol', strNote = NULL, intMasterId = 4600024
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '225', strDescription = 'Liquid Natural Gas', strProductCodeGroup = 'Gasoline/Gasohol', strNote = NULL, intMasterId = 4600025
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '054', strDescription = 'Propane', strProductCodeGroup = 'Gasoline/Gasohol', strNote = NULL, intMasterId = 4600026
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '152', strDescription = 'Heating Oil', strProductCodeGroup = 'Heating Oil', strNote = NULL, intMasterId = 4600027
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '147', strDescription = 'High Sulphur Kerosene - Undyed', strProductCodeGroup = 'Kerosene', strNote = NULL, intMasterId = 4600028
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '142', strDescription = 'Kerosene - Undyed', strProductCodeGroup = 'Kerosene', strNote = NULL, intMasterId = 4600029
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '145', strDescription = 'Low Sulphur Kerosene - Undyed', strProductCodeGroup = 'Kerosene', strNote = NULL, intMasterId = 4600030
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '225', strDescription = 'Liquid Natural Gas', strProductCodeGroup = 'Liquefied Natural Gas', strNote = NULL, intMasterId = 4600031
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '243', strDescription = 'Methanol', strProductCodeGroup = 'Methanol', strNote = NULL, intMasterId = 4600032
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '259', strDescription = 'Hydrogen', strProductCodeGroup = 'Other Products', strNote = NULL, intMasterId = 4600033
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '092', strDescription = 'Other(undefined)', strProductCodeGroup = 'Other Products', strNote = NULL, intMasterId = 4600034
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '123', strDescription = 'Alcohol', strProductCodeGroup = 'Other Products', strNote = NULL, intMasterId = 4600035
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '122', strDescription = 'Blending Components', strProductCodeGroup = 'Other Products', strNote = NULL, intMasterId = 4600036
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '241', strDescription = 'Ethanol', strProductCodeGroup = 'Other Products', strNote = NULL, intMasterId = 4600037
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '074', strDescription = 'High Sulphur Kerosene - Dyed', strProductCodeGroup = 'Other Products', strNote = NULL, intMasterId = 4600038
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '072', strDescription = 'Kerosene - Dyed', strProductCodeGroup = 'Other Products', strNote = NULL, intMasterId = 4600039
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '073', strDescription = 'Low Sulphur Kerosene - Dyed', strProductCodeGroup = 'Other Products', strNote = NULL, intMasterId = 4600040
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '279', strDescription = 'Marine Diesel Oil', strProductCodeGroup = 'Other Products', strNote = NULL, intMasterId = 4600041
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '280', strDescription = 'Marine Gas Oil', strProductCodeGroup = 'Other Products', strNote = NULL, intMasterId = 4600042
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '243', strDescription = 'Methanol', strProductCodeGroup = 'Other Products', strNote = NULL, intMasterId = 4600043
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '175', strDescription = 'Residual Fuel Oil', strProductCodeGroup = 'Other Products', strNote = NULL, intMasterId = 4600044
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '171', strDescription = '100% Biodiesel - Dyed', strProductCodeGroup = 'Other Products', strNote = NULL, intMasterId = 4600045
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '100', strDescription = 'Transmix', strProductCodeGroup = 'Other Products', strNote = NULL, intMasterId = 4600046
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '054', strDescription = 'Propane', strProductCodeGroup = 'Propane', strNote = NULL, intMasterId = 4600047
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '282', strDescription = '#1 High Sulphur Diesel - Undyed', strProductCodeGroup = 'Undyed Diesel', strNote = NULL, intMasterId = 4600048
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '283', strDescription = '#2 High Sulphur Diesel - Undyed', strProductCodeGroup = 'Undyed Diesel', strNote = NULL, intMasterId = 4600049
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '160', strDescription = 'Diesel - Undyed', strProductCodeGroup = 'Undyed Diesel', strNote = NULL, intMasterId = 4600050
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '154', strDescription = 'Diesel Fuel #4 - Undyed', strProductCodeGroup = 'Undyed Diesel', strNote = NULL, intMasterId = 4600051
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '161', strDescription = 'Low Sulphur Diesel #1 - Undyed', strProductCodeGroup = 'Undyed Diesel', strNote = NULL, intMasterId = 4600052
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '167', strDescription = 'Low Sulphur Diesel #2 - Undyed', strProductCodeGroup = 'Undyed Diesel', strNote = NULL, intMasterId = 4600053
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '150', strDescription = 'No. 1 Fuel Oil - Undyed', strProductCodeGroup = 'Undyed Diesel', strNote = NULL, intMasterId = 4600054
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '170', strDescription = '100% Biodiesel - Undyed', strProductCodeGroup = 'Undyed Diesel', strNote = NULL, intMasterId = 4600055
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '147', strDescription = 'High Sulphur Kerosene - Undyed', strProductCodeGroup = 'Undyed Diesel', strNote = NULL, intMasterId = 4600056
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '142', strDescription = 'Kerosene - Undyed', strProductCodeGroup = 'Undyed Diesel', strNote = NULL, intMasterId = 4600057
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '145', strDescription = 'Low Sulphur Kerosene - Undyed', strProductCodeGroup = 'Undyed Diesel', strNote = NULL, intMasterId = 4600058
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '279', strDescription = 'Marine Diesel Oil', strProductCodeGroup = 'Undyed Diesel', strNote = NULL, intMasterId = 4600059
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '092', strDescription = 'Other(undefined)', strProductCodeGroup = 'Undyed Diesel', strNote = NULL, intMasterId = 4600060

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

END
GO