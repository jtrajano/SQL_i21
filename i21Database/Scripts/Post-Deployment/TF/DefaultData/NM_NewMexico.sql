DECLARE @TaxAuthorityCode NVARCHAR(10) = 'NM'
	, @TaxAuthorityId INT

SELECT @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = @TaxAuthorityCode AND ysnFilingForThisTA = 1

IF(@TaxAuthorityId IS NOT NULL)
BEGIN

	PRINT ('Deploying New Mexico Tax Forms')

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
	SELECT intProductCodeId = 0, strProductCode = '065', strDescription = 'Gasoline', strProductCodeGroup = 'Gas', strNote = '065 - Gasoline (Gas)', intMasterId = 31847
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '071', strDescription = 'Gasoline MTBE', strProductCodeGroup = 'Gas', strNote = '071 - Gasoline MTBE (Gas)', intMasterId = 31848
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '124', strDescription = 'Gasohol', strProductCodeGroup = 'Ethanol', strNote = '124 - Gasohol (Eth)', intMasterId = 31850
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '125', strDescription = 'Aviation Gasoline', strProductCodeGroup = 'Gas', strNote = '125 - Aviation Gasoline (Gas)', intMasterId = 31851
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '142', strDescription = 'Kerosene Undyed', strProductCodeGroup = 'Special Fuels', strNote = '142 - Kerosene-Undyed (Spf)', intMasterId = 31852
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '145', strDescription = 'Lo Sulfur Kero Undyed', strProductCodeGroup = 'Special Fuels', strNote = '145 - Lo Sulf Kero-Undyed(Spf)', intMasterId = 31853
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '147', strDescription = 'Hi Sulfur Kero Undyed', strProductCodeGroup = 'Special Fuels', strNote = '147 - Hi Sulf Kero-Undyed(Spf)', intMasterId = 31855
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '150', strDescription = '#1 Fuel Oil Undyed', strProductCodeGroup = 'Special Fuels', strNote = '150 - #1 Fuel Oil-Undyed (Spf)', intMasterId = 31856
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '154', strDescription = 'Diesel #4 Undyed', strProductCodeGroup = 'Special Fuels', strNote = '154 - Diesel #4-Undyed (Spf)', intMasterId = 31857
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '160', strDescription = 'Diesel Undyed', strProductCodeGroup = 'Special Fuels', strNote = '160 - Diesel-Undyed (Spf)', intMasterId = 31858
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '161', strDescription = 'Lo Sulfur #1 Undyed', strProductCodeGroup = 'Speical Fuels', strNote = '161 - Lo Sulfur #1-Undyed(Spf)', intMasterId = 31859
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '167', strDescription = 'Lo Sulfur #2 Undyed', strProductCodeGroup = 'Speical Fuels', strNote = '167 - Lo Sulfur #2-Undyed(Spf)', intMasterId = 31860
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '170', strDescription = 'Biodiesel Undyed', strProductCodeGroup = 'Speical Fuels', strNote = '170 - Biodiesel - Undyed (Spf)', intMasterId = 31861
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '282', strDescription = 'High Sulfur #1 Undyed', strProductCodeGroup = 'Speical Fuels', strNote = '282 - High Sulf #1-Undyed(Spf)', intMasterId = 31863
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '283', strDescription = 'High Sulfur #2 Undyed', strProductCodeGroup = 'Speical Fuels', strNote = '283 - High Sulf #2-Undyed(Spf)', intMasterId = 31864
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'B00', strDescription = 'Biodiesel - 100%', strProductCodeGroup = 'Speical Fuels', strNote = 'B00 - Biodiesel (100)', intMasterId = 31865
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'B02', strDescription = 'Biodiesel - 2%', strProductCodeGroup = 'Speical Fuels', strNote = 'B02 - Biodiesel (02)', intMasterId = 31866
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'B05', strDescription = 'Biodiesel - 5%', strProductCodeGroup = 'Speical Fuels', strNote = 'B05 - Biodiesel (05)', intMasterId = 31867
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'B20', strDescription = 'Biodiesel - 20%', strProductCodeGroup = 'Speical Fuels', strNote = 'B20 - Biodiesel (20)', intMasterId = 31868
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'B99', strDescription = 'Biodiesel - 99%', strProductCodeGroup = 'Speical Fuels', strNote = 'B99 - Biodiesel (99)', intMasterId = 31869
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'E75', strDescription = 'Ethanol - 75%', strProductCodeGroup = 'Ethanol', strNote = 'E75 - Ethanol (Eth)', intMasterId = 31870
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'E85', strDescription = 'Ethanol - 85%', strProductCodeGroup = 'Ethanol', strNote = 'E85 - Ethanol (Eth)', intMasterId = 31871
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'LPG', strDescription = 'LPG', strProductCodeGroup = 'Alternative Fuels', strNote = NULL, intMasterId = 31872
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'CNG', strDescription = 'CNG', strProductCodeGroup = 'Alternative Fuels', strNote = NULL, intMasterId = 31873
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'LNG', strDescription = 'LNG', strProductCodeGroup = 'Alternative Fuels', strNote = NULL, intMasterId = 31874
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'A-55', strDescription = 'A-55', strProductCodeGroup = 'Alternative Fuels', strNote = NULL, intMasterId = 31875
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '072', strDescription = 'Kerosene Dyed', strProductCodeGroup = 'Special Fuels', strNote = '072 - Kerosene-dye added(Spf)', intMasterId = 31876
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '073', strDescription = 'Lo Sulfur Kero Dyed', strProductCodeGroup = 'Special Fuels', strNote = '073 - LoSulf Kero-dye add(Spf)', intMasterId = 31877
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '074', strDescription = 'Hi Sulfur Kero Dyed', strProductCodeGroup = 'Special Fuels', strNote = '074 - HiSulf Kero-dye add(Spf)', intMasterId = 31878
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '092', strDescription = 'Undefined Products', strProductCodeGroup = 'Undefined', strNote = '092 - Undefined Products', intMasterId = 31879
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '153', strDescription = '#4 Diesel Dyed', strProductCodeGroup = 'Special Fuels', strNote = '153 - #4 Diesel-Dye Added(Spf)', intMasterId = 31880
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '171', strDescription = 'Biodiesel Dyed', strProductCodeGroup = 'Special Fuels', strNote = '171 - Biodiesel - Dyed (Spf)', intMasterId = 31881
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '226', strDescription = 'Hi Sulfur Dyed', strProductCodeGroup = 'Special Fuels', strNote = '226 - Hi Sulfur - Dye Add(Spf)', intMasterId = 31882
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '227', strDescription = 'Lo Sulfur Dyed', strProductCodeGroup = 'Special Fuels', strNote = '227 - Lo Sulfur - Dye Add(Spf)', intMasterId = 31883
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '228', strDescription = 'Diesel Dyed', strProductCodeGroup = 'Special Fuels', strNote = '228 - Diesel Fuel-Dye Add(Spf)', intMasterId = 31884
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '231', strDescription = '#1 Diesel Dyed', strProductCodeGroup = 'Special Fuels', strNote = '231 - #1 Diesel-Dye Added(Spf)', intMasterId = 31885
	UNION ALL SELECT intProductCodeId = 0, strProductCode = '284', strDescription = 'Biodiesel', strProductCodeGroup = 'Special Fuels', strNote = '284 - BioDiesel Fuel', intMasterId = 31886
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'D05', strDescription = 'Biodiesel Dyed - 5%', strProductCodeGroup = 'Special Fuels', strNote = 'D05 - BioDiesel/Dyed (D05)', intMasterId = 31888
	UNION ALL SELECT intProductCodeId = 0, strProductCode = 'E00', strDescription = 'Ethanol - 100%', strProductCodeGroup = 'Ethanol', strNote = 'E00 - Ethanol (100)', intMasterId = 31889

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
	SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '1', strScheduleName = 'Gallons Acquired,  Tax Paid', strType = 'Gasoline', strNote = '', strTransactionType = 'Inventory', intSort = 10, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 311147, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '1', strScheduleName = 'Gallons Acquired,  Tax Paid', strType = 'Ethanol', strNote = '', strTransactionType = 'Inventory', intSort = 20, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 311148, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '1', strScheduleName = 'Gallons Acquired,  Tax Paid', strType = 'Special Fuel', strNote = '', strTransactionType = 'Inventory', intSort = 30, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 311149, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '1A', strScheduleName = 'Gallons Received in NM from TX Terminal, NM Tax Paid', strType = 'Gasoline', strNote = '', strTransactionType = 'Inventory', intSort = 40, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 311150, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '1A', strScheduleName = 'Gallons Received in NM from TX Terminal, NM Tax Paid', strType = 'Ethanol', strNote = '', strTransactionType = 'Inventory', intSort = 50, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 311151, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '1A', strScheduleName = 'Gallons Received in NM from TX Terminal, NM Tax Paid', strType = 'Special Fuel', strNote = '', strTransactionType = 'Inventory', intSort = 60, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 311152, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '2A', strScheduleName = 'Gallons Received from a NM Terminal', strType = 'Gasoline', strNote = '', strTransactionType = 'Inventory', intSort = 70, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 311153, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '2A', strScheduleName = 'Gallons Received from a NM Terminal', strType = 'Ethanol', strNote = '', strTransactionType = 'Inventory', intSort = 80, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 311154, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '2A', strScheduleName = 'Gallons Received from a NM Terminal', strType = 'Special Fuel', strNote = '', strTransactionType = 'Inventory', intSort = 90, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 311155, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '2B', strScheduleName = 'Gallons Produced and/or Blended', strType = 'Gasoline', strNote = '', strTransactionType = 'Inventory', intSort = 100, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 311156, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '2B', strScheduleName = 'Gallons Produced and/or Blended', strType = 'Ethanol', strNote = '', strTransactionType = 'Inventory', intSort = 110, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 311157, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '2B', strScheduleName = 'Gallons Produced and/or Blended', strType = 'Special Fuel', strNote = '', strTransactionType = 'Inventory', intSort = 120, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 311158, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '2C', strScheduleName = 'Gallons Received when Transported Off Indian Land', strType = 'Gasoline', strNote = '', strTransactionType = 'Inventory', intSort = 130, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 311159, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '2C', strScheduleName = 'Gallons Received when Transported Off Indian Land', strType = 'Ethanol', strNote = '', strTransactionType = 'Inventory', intSort = 140, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 311160, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '2C', strScheduleName = 'Gallons Received when Transported Off Indian Land', strType = 'Special Fuel', strNote = '', strTransactionType = 'Inventory', intSort = 150, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 311161, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '3', strScheduleName = 'Gallons Imported from Another State', strType = 'Gasoline', strNote = '', strTransactionType = 'Inventory', intSort = 160, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 311162, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '3', strScheduleName = 'Gallons Imported from Another State', strType = 'Ethanol', strNote = '', strTransactionType = 'Inventory', intSort = 170, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 311163, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '3', strScheduleName = 'Gallons Imported from Another State', strType = 'Special Fuel', strNote = '', strTransactionType = 'Inventory', intSort = 180, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 311164, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '4', strScheduleName = 'Gallons Imported Directly into NM Indiana Land, Tax Exempt', strType = 'Gasoline', strNote = '', strTransactionType = 'Inventory', intSort = 190, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 311165, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '4', strScheduleName = 'Gallons Imported Directly into NM Indiana Land, Tax Exempt', strType = 'Ethanol', strNote = '', strTransactionType = 'Inventory', intSort = 200, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 311166, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '4', strScheduleName = 'Gallons Imported Directly into NM Indiana Land, Tax Exempt', strType = 'Special Fuel', strNote = '', strTransactionType = 'Inventory', intSort = 210, strStoredProcedure = 'uspTFGetInventoryTax', intMasterId = 311167, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '5A', strScheduleName = 'Gallons Sold to Retailers/Consumers in NM, Tax Included', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 220, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311168, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '5A', strScheduleName = 'Gallons Sold to Retailers/Consumers in NM, Tax Included', strType = 'Ethanol', strNote = '', strTransactionType = 'Invoice', intSort = 230, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311169, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '5A', strScheduleName = 'Gallons Sold to Retailers/Consumers in NM, Tax Included', strType = 'Special Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 240, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311170, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '5B', strScheduleName = 'Gallons Sold to Distributors/Suppliers/Wholesalers, Tax Included', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 250, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311171, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '5B', strScheduleName = 'Gallons Sold to Distributors/Suppliers/Wholesalers, Tax Included', strType = 'Ethanol', strNote = '', strTransactionType = 'Invoice', intSort = 260, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311172, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '5B', strScheduleName = 'Gallons Sold to Distributors/Suppliers/Wholesalers, Tax Included', strType = 'Special Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 270, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311173, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '6J', strScheduleName = 'Gallons of Biodiesel Delivered to NM Terminals', strType = 'Special Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 280, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311174, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '7', strScheduleName = 'Gallons Exported out of NM', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 290, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311175, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '7', strScheduleName = 'Gallons Exported out of NM', strType = 'Ethanol', strNote = '', strTransactionType = 'Invoice', intSort = 300, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311176, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '7', strScheduleName = 'Gallons Exported out of NM', strType = 'Special Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 310, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311177, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '8', strScheduleName = 'Gallons Sold to US Government, NATO, or Indian Tribes', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 320, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311178, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '8', strScheduleName = 'Gallons Sold to US Government, NATO, or Indian Tribes', strType = 'Ethanol', strNote = '', strTransactionType = 'Invoice', intSort = 330, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311179, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '8', strScheduleName = 'Gallons Sold to US Government, NATO, or Indian Tribes', strType = 'Special Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 340, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311180, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '9', strScheduleName = 'Gallons Sold to NM State and Local Governments', strType = 'Special Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 350, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311181, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '10T', strScheduleName = 'Gallons Sold at Retail on Indian Land by a Registered Indian Tribal Distributor', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 360, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311182, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '10T', strScheduleName = 'Gallons Sold at Retail on Indian Land by a Registered Indian Tribal Distributor', strType = 'Ethanol', strNote = '', strTransactionType = 'Invoice', intSort = 370, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311183, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '6V', strScheduleName = 'Gallons Sold at Retail on Indian Land by Other Than a Registered Indian Tribal Distributor', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 380, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311184, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '6V', strScheduleName = 'Gallons Sold at Retail on Indian Land by Other Than a Registered Indian Tribal Distributor', strType = 'Ethanol', strNote = '', strTransactionType = 'Invoice', intSort = 390, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311185, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '10F', strScheduleName = 'Gallons of Undyed Special Fuel Sold for Off-road Use', strType = 'Special Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 400, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311186, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '10G', strScheduleName = 'Gallons of Undyed and Dyed Special Fuel Sold for School Bus Use', strType = 'Special Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 410, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311187, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '10A', strScheduleName = 'Gallons of Dyed Gasoline, Ethanol, and Special Fuel Sold, Excluding for School Bus Use', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intSort = 420, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311188, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '10A', strScheduleName = 'Gallons of Dyed Gasoline, Ethanol, and Special Fuel Sold, Excluding for School Bus Use', strType = 'Ethanol', strNote = '', strTransactionType = 'Invoice', intSort = 430, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311189, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = '10A', strScheduleName = 'Gallons of Dyed Gasoline, Ethanol, and Special Fuel Sold, Excluding for School Bus Use', strType = 'Special Fuel', strNote = '', strTransactionType = 'Invoice', intSort = 440, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311190, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41164', strFormName = 'Alternative Fuels Excise Tax Return (Quarterly)', strScheduleCode = 'Disbursed', strScheduleName = 'Gallons Disbursed', strType = 'LPG', strNote = '', strTransactionType = 'Invoice', intSort = 500, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311191, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41164', strFormName = 'Alternative Fuels Excise Tax Return (Quarterly)', strScheduleCode = 'Disbursed', strScheduleName = 'Gallons Disbursed', strType = 'CNG', strNote = '', strTransactionType = 'Invoice', intSort = 510, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311192, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41164', strFormName = 'Alternative Fuels Excise Tax Return (Quarterly)', strScheduleCode = 'Disbursed', strScheduleName = 'Gallons Disbursed', strType = 'LNG', strNote = '', strTransactionType = 'Invoice', intSort = 520, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311193, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41164', strFormName = 'Alternative Fuels Excise Tax Return (Quarterly)', strScheduleCode = 'Disbursed', strScheduleName = 'Gallons Disbursed', strType = 'A-55', strNote = '', strTransactionType = 'Invoice', intSort = 530, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311194, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41164', strFormName = 'Alternative Fuels Excise Tax Return (Quarterly)', strScheduleCode = 'Exemptions', strScheduleName = 'Gallons for Exemptions', strType = 'LPG', strNote = '', strTransactionType = 'Invoice', intSort = 540, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311195, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41164', strFormName = 'Alternative Fuels Excise Tax Return (Quarterly)', strScheduleCode = 'Exemptions', strScheduleName = 'Gallons for Exemptions', strType = 'CNG', strNote = '', strTransactionType = 'Invoice', intSort = 550, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311196, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41164', strFormName = 'Alternative Fuels Excise Tax Return (Quarterly)', strScheduleCode = 'Exemptions', strScheduleName = 'Gallons for Exemptions', strType = 'LNG', strNote = '', strTransactionType = 'Invoice', intSort = 560, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311197, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41164', strFormName = 'Alternative Fuels Excise Tax Return (Quarterly)', strScheduleCode = 'Exemptions', strScheduleName = 'Gallons for Exemptions', strType = 'A-55', strNote = '', strTransactionType = 'Invoice', intSort = 570, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311198, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41164', strFormName = 'Alternative Fuels Excise Tax Return (Quarterly)', strScheduleCode = 'Deductions', strScheduleName = 'Gallons for Deductions', strType = 'LPG', strNote = '', strTransactionType = 'Invoice', intSort = 580, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311199, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41164', strFormName = 'Alternative Fuels Excise Tax Return (Quarterly)', strScheduleCode = 'Deductions', strScheduleName = 'Gallons for Deductions', strType = 'CNG', strNote = '', strTransactionType = 'Invoice', intSort = 590, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311200, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41164', strFormName = 'Alternative Fuels Excise Tax Return (Quarterly)', strScheduleCode = 'Deductions', strScheduleName = 'Gallons for Deductions', strType = 'LNG', strNote = '', strTransactionType = 'Invoice', intSort = 600, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311201, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41164', strFormName = 'Alternative Fuels Excise Tax Return (Quarterly)', strScheduleCode = 'Deductions', strScheduleName = 'Gallons for Deductions', strType = 'A-55', strNote = '', strTransactionType = 'Invoice', intSort = 610, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311202, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41164', strFormName = 'Alternative Fuels Excise Tax Return (Quarterly)', strScheduleCode = 'Form41164', strScheduleName = 'Main Form', strType = '', strNote = 'Alternative Fuels Excise Tax Return Main Form', strTransactionType = 'Inventory', intSort = 620, strStoredProcedure = '', intMasterId = 311203, intComponentTypeId = 2
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = 'A', strScheduleName = 'Gasoline and Ethanol Blended Fuel Sales Delivered into Counties/Locations', strType = '', strNote = '', strTransactionType = 'Invoice', intSort = 450, strStoredProcedure = 'uspTFGetInvoiceTax', intMasterId = 311204, intComponentTypeId = 1
	UNION ALL SELECT intReportingComponentId = 0, strFormCode = 'Form 41306', strFormName = 'Combined Fuel Tax Report', strScheduleCode = 'Form-41306', strScheduleName = 'Excel Export', strType = '', strNote = '', strTransactionType = '', intSort = 460, strStoredProcedure = 'uspTFGenerateNMCombined', intMasterId = 311205, intComponentTypeId = 4
	
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
	SELECT intTaxCriteriaId = 0, strTaxCategory = 'NM Excise Tax Gasoline', strState = 'NM', strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Gasoline', strCriteria = '<> 0', intMasterId = 31516
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'NM Excise Tax Gasoline', strState = 'NM', strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Ethanol', strCriteria = '<> 0', intMasterId = 31517
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'NM Excise Tax Diesel Clear', strState = 'NM', strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', strCriteria = '<> 0', intMasterId = 31518
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'NM Excise Tax Gasoline', strState = 'NM', strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Gasoline', strCriteria = '<> 0', intMasterId = 31519
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'NM Excise Tax Gasoline', strState = 'NM', strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Ethanol', strCriteria = '<> 0', intMasterId = 31520
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'NM Excise Tax Diesel Clear', strState = 'NM', strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', strCriteria = '<> 0', intMasterId = 31521
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'NM Excise Tax Gasoline', strState = 'NM', strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Gasoline', strCriteria = '= 0', intMasterId = 31522
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'NM Excise Tax Gasoline', strState = 'NM', strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Ethanol', strCriteria = '= 0', intMasterId = 31523
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'NM Excise Tax Diesel Clear', strState = 'NM', strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', strCriteria = '= 0', intMasterId = 31524
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'NM Excise Tax Gasoline', strState = 'NM', strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Gasoline', strCriteria = '<> 0', intMasterId = 31525
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'NM Excise Tax Gasoline', strState = 'NM', strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Ethanol', strCriteria = '<> 0', intMasterId = 31526
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'NM Excise Tax Diesel Clear', strState = 'NM', strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', strCriteria = '<> 0', intMasterId = 31527
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'NM Excise Tax Gasoline', strState = 'NM', strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Gasoline', strCriteria = '<> 0', intMasterId = 31528
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'NM Excise Tax Gasoline', strState = 'NM', strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Ethanol', strCriteria = '<> 0', intMasterId = 31529
	UNION ALL SELECT intTaxCriteriaId = 0, strTaxCategory = 'NM Excise Tax Diesel Clear', strState = 'NM', strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', strCriteria = '<> 0', intMasterId = 31530

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
	SELECT intValidProductCodeId = 0, strProductCode = 'A-55', strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'A-55', intMasterId = 317163
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'CNG', strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'CNG', intMasterId = 317157
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'LNG', strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'LNG', intMasterId = 317160
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'LPG', strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'LPG', intMasterId = 317154
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'A-55', strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'A-55', intMasterId = 317164
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'CNG', strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'CNG', intMasterId = 317158
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'LNG', strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'LNG', intMasterId = 317161
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'LPG', strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'LPG', intMasterId = 317155
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'A-55', strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'A-55', intMasterId = 317165
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'CNG', strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'CNG', intMasterId = 317159
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'LNG', strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'LNG', intMasterId = 317162
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'LPG', strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'LPG', intMasterId = 317156
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Ethanol', intMasterId = 316856
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E75', strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Ethanol', intMasterId = 316870
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Ethanol', intMasterId = 316884
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Gasoline', intMasterId = 316814
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Gasoline', intMasterId = 316828
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Gasoline', intMasterId = 316842
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', intMasterId = 316898
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', intMasterId = 316914
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', intMasterId = 316930
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', intMasterId = 316946
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '154', strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', intMasterId = 316962
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', intMasterId = 316978
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', intMasterId = 316994
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', intMasterId = 317010
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', intMasterId = 317026
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '282', strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', intMasterId = 317042
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', intMasterId = 317058
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', intMasterId = 317074
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B02', strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', intMasterId = 317090
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', intMasterId = 317106
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', intMasterId = 317122
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', intMasterId = 317138
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Ethanol', intMasterId = 316857
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E75', strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Ethanol', intMasterId = 316871
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Ethanol', intMasterId = 316885
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Gasoline', intMasterId = 316827
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Gasoline', intMasterId = 316841
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Special Fuel', intMasterId = 317178
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Special Fuel', intMasterId = 317179
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Special Fuel', intMasterId = 317180
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '153', strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Special Fuel', intMasterId = 317181
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '171', strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Special Fuel', intMasterId = 317182
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Special Fuel', intMasterId = 317183
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Special Fuel', intMasterId = 317184
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Special Fuel', intMasterId = 317185
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Special Fuel', intMasterId = 317186
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '284', strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Special Fuel', intMasterId = 317187
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D05', strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Special Fuel', intMasterId = 317188
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', intMasterId = 316900
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', intMasterId = 316916
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', intMasterId = 316932
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', intMasterId = 316948
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '154', strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', intMasterId = 316964
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', intMasterId = 316980
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', intMasterId = 316996
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', intMasterId = 317012
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', intMasterId = 317028
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '282', strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', intMasterId = 317044
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', intMasterId = 317060
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', intMasterId = 317076
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B02', strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', intMasterId = 317092
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', intMasterId = 317108
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', intMasterId = 317124
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', intMasterId = 317140
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 317192
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 317193
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 317194
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 317195
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '154', strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 317197
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 317198
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 317199
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 317200
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 317201
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '282', strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 317207
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 317208
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 317077
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B02', strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 317093
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 317109
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 317125
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 317141
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '072', strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 317189
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 317190
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '074', strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 317191
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '153', strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 317196
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '171', strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 317202
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '226', strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 317203
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 317204
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '228', strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 317205
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '231', strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 317206
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'D05', strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', intMasterId = 317209
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Ethanol', intMasterId = 316858
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E75', strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Ethanol', intMasterId = 316872
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Ethanol', intMasterId = 316886
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Gasoline', intMasterId = 316825
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Gasoline', intMasterId = 316839
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Gasoline', intMasterId = 316853
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Ethanol', intMasterId = 316859
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E75', strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Ethanol', intMasterId = 316873
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Ethanol', intMasterId = 316887
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Gasoline', intMasterId = 316815
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Gasoline', intMasterId = 316829
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Gasoline', intMasterId = 316843
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', intMasterId = 316902
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', intMasterId = 316918
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', intMasterId = 316934
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', intMasterId = 316950
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '154', strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', intMasterId = 316966
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', intMasterId = 316982
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', intMasterId = 316998
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', intMasterId = 317014
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', intMasterId = 317030
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '282', strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', intMasterId = 317046
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', intMasterId = 317062
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', intMasterId = 317078
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B02', strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', intMasterId = 317094
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', intMasterId = 317110
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', intMasterId = 317126
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', intMasterId = 317142
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Ethanol', intMasterId = 316860
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E75', strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Ethanol', intMasterId = 316874
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Ethanol', intMasterId = 316888
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Ethanol', intMasterId = 317172
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Gasoline', intMasterId = 316816
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Gasoline', intMasterId = 316830
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Gasoline', intMasterId = 316844
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', intMasterId = 316903
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', intMasterId = 316919
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', intMasterId = 316935
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', intMasterId = 316951
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '154', strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', intMasterId = 316967
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', intMasterId = 316983
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', intMasterId = 316999
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', intMasterId = 317015
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', intMasterId = 317031
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '282', strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', intMasterId = 317047
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', intMasterId = 317063
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', intMasterId = 317079
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B02', strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', intMasterId = 317095
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', intMasterId = 317111
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', intMasterId = 317127
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', intMasterId = 317143
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Ethanol', intMasterId = 316861
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E75', strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Ethanol', intMasterId = 316875
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Ethanol', intMasterId = 316889
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Ethanol', intMasterId = 317173
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Gasoline', intMasterId = 316817
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Gasoline', intMasterId = 316831
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Gasoline', intMasterId = 316845
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', intMasterId = 316904
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', intMasterId = 316920
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', intMasterId = 316936
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', intMasterId = 316952
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '154', strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', intMasterId = 316968
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', intMasterId = 316984
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', intMasterId = 317000
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', intMasterId = 317016
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', intMasterId = 317032
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '282', strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', intMasterId = 317048
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', intMasterId = 317064
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', intMasterId = 317080
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B02', strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', intMasterId = 317096
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', intMasterId = 317112
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', intMasterId = 317128
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', intMasterId = 317144
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Ethanol', intMasterId = 316862
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E75', strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Ethanol', intMasterId = 316876
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Ethanol', intMasterId = 316890
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Ethanol', intMasterId = 317174
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Gasoline', intMasterId = 316818
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Gasoline', intMasterId = 316832
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Gasoline', intMasterId = 316846
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', intMasterId = 316905
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', intMasterId = 316921
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', intMasterId = 316937
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', intMasterId = 316953
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '154', strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', intMasterId = 316969
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', intMasterId = 316985
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', intMasterId = 317001
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', intMasterId = 317017
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', intMasterId = 317033
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '282', strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', intMasterId = 317049
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', intMasterId = 317065
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', intMasterId = 317081
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B02', strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', intMasterId = 317097
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', intMasterId = 317113
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', intMasterId = 317129
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', intMasterId = 317145
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Ethanol', intMasterId = 316863
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E75', strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Ethanol', intMasterId = 316877
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Ethanol', intMasterId = 316891
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Ethanol', intMasterId = 317175
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Gasoline', intMasterId = 316819
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Gasoline', intMasterId = 316833
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Gasoline', intMasterId = 316847
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', intMasterId = 316906
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', intMasterId = 316922
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', intMasterId = 316938
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', intMasterId = 316954
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '154', strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', intMasterId = 316970
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', intMasterId = 316986
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', intMasterId = 317002
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', intMasterId = 317018
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', intMasterId = 317034
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '282', strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', intMasterId = 317050
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', intMasterId = 317066
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', intMasterId = 317082
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B02', strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', intMasterId = 317098
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', intMasterId = 317114
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', intMasterId = 317130
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', intMasterId = 317146
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Ethanol', intMasterId = 316864
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E75', strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Ethanol', intMasterId = 316878
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Ethanol', intMasterId = 316892
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E00', strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Ethanol', intMasterId = 317176
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Gasoline', intMasterId = 316820
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Gasoline', intMasterId = 316834
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Gasoline', intMasterId = 316848
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', intMasterId = 316907
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', intMasterId = 316923
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', intMasterId = 316939
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', intMasterId = 316955
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '154', strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', intMasterId = 316971
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', intMasterId = 316987
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', intMasterId = 317003
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', intMasterId = 317019
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', intMasterId = 317035
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '282', strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', intMasterId = 317051
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', intMasterId = 317067
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', intMasterId = 317083
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B02', strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', intMasterId = 317099
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', intMasterId = 317115
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', intMasterId = 317131
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', intMasterId = 317147
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Ethanol', intMasterId = 316865
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E75', strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Ethanol', intMasterId = 316879
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Ethanol', intMasterId = 316893
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Gasoline', intMasterId = 316821
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Gasoline', intMasterId = 316835
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Gasoline', intMasterId = 316849
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', intMasterId = 316908
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', intMasterId = 316924
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', intMasterId = 316940
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', intMasterId = 316956
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '154', strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', intMasterId = 316972
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', intMasterId = 316988
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', intMasterId = 317004
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', intMasterId = 317020
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', intMasterId = 317036
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '282', strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', intMasterId = 317052
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', intMasterId = 317068
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', intMasterId = 317084
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B02', strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', intMasterId = 317100
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', intMasterId = 317116
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', intMasterId = 317132
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', intMasterId = 317148
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Ethanol', intMasterId = 316866
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E75', strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Ethanol', intMasterId = 316880
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Ethanol', intMasterId = 316894
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Gasoline', intMasterId = 316822
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Gasoline', intMasterId = 316836
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Gasoline', intMasterId = 316850
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', intMasterId = 316909
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', intMasterId = 316925
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', intMasterId = 316941
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', intMasterId = 316957
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '154', strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', intMasterId = 316973
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', intMasterId = 316989
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', intMasterId = 317005
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', intMasterId = 317021
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', intMasterId = 317037
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '282', strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', intMasterId = 317053
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', intMasterId = 317069
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', intMasterId = 317085
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B02', strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', intMasterId = 317101
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', intMasterId = 317117
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', intMasterId = 317133
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', intMasterId = 317149
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Form 41306', strScheduleCode = '6J', strType = 'Special Fuel', intMasterId = 317177
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Form 41306', strScheduleCode = '6J', strType = 'Special Fuel', intMasterId = 317150
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Ethanol', intMasterId = 316867
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E75', strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Ethanol', intMasterId = 316881
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Ethanol', intMasterId = 316895
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Gasoline', intMasterId = 316826
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Gasoline', intMasterId = 316840
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Gasoline', intMasterId = 316854
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Ethanol', intMasterId = 316868
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E75', strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Ethanol', intMasterId = 316882
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Ethanol', intMasterId = 316896
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Gasoline', intMasterId = 316823
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Gasoline', intMasterId = 316837
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Gasoline', intMasterId = 316851
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', intMasterId = 316911
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', intMasterId = 316927
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', intMasterId = 316943
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', intMasterId = 316959
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '154', strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', intMasterId = 316975
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', intMasterId = 316991
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', intMasterId = 317007
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', intMasterId = 317023
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', intMasterId = 317039
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '282', strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', intMasterId = 317055
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', intMasterId = 317071
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', intMasterId = 317087
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B02', strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', intMasterId = 317103
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', intMasterId = 317119
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', intMasterId = 317135
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', intMasterId = 317151
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Ethanol', intMasterId = 316869
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E75', strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Ethanol', intMasterId = 316883
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Ethanol', intMasterId = 316897
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Gasoline', intMasterId = 316824
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Gasoline', intMasterId = 316838
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Gasoline', intMasterId = 316852
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', intMasterId = 316912
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', intMasterId = 316928
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', intMasterId = 316944
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', intMasterId = 316960
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '154', strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', intMasterId = 316976
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', intMasterId = 316992
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', intMasterId = 317008
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', intMasterId = 317024
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', intMasterId = 317040
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '282', strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', intMasterId = 317056
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', intMasterId = 317072
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', intMasterId = 317088
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B02', strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', intMasterId = 317104
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', intMasterId = 317120
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', intMasterId = 317136
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', intMasterId = 317152
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', intMasterId = 316913
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '145', strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', intMasterId = 316929
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '147', strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', intMasterId = 316945
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '150', strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', intMasterId = 316961
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '154', strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', intMasterId = 316977
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', intMasterId = 316993
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '161', strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', intMasterId = 317009
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '167', strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', intMasterId = 317025
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', intMasterId = 317041
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '282', strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', intMasterId = 317057
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '283', strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', intMasterId = 317073
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B00', strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', intMasterId = 317089
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B02', strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', intMasterId = 317105
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B05', strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', intMasterId = 317121
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B20', strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', intMasterId = 317137
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'B99', strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', intMasterId = 317153
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'Form 41306', strScheduleCode = 'A', strType = '', intMasterId = 317166
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '071', strFormCode = 'Form 41306', strScheduleCode = 'A', strType = '', intMasterId = 317167
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'Form 41306', strScheduleCode = 'A', strType = '', intMasterId = 317169
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'Form 41306', strScheduleCode = 'A', strType = '', intMasterId = 317168
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E75', strFormCode = 'Form 41306', strScheduleCode = 'A', strType = '', intMasterId = 317170
	UNION ALL SELECT intValidProductCodeId = 0, strProductCode = 'E85', strFormCode = 'Form 41306', strScheduleCode = 'A', strType = '', intMasterId = 317171

	INSERT INTO @ValidOriginStates(
		intValidOriginStateId
		, strFormCode
		, strScheduleCode
		, strType
		, strState
		, strStatus
		, intMasterId
	)
	SELECT intValidOriginStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Ethanol', strState = 'NM', strStatus = 'Include', intMasterId = 31575
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Gasoline', strState = 'NM', strStatus = 'Include', intMasterId = 31574
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', strState = 'NM', strStatus = 'Include', intMasterId = 31576
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Ethanol', strState = 'TX', strStatus = 'Include', intMasterId = 31578
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Gasoline', strState = 'TX', strStatus = 'Include', intMasterId = 31577
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', strState = 'TX', strStatus = 'Include', intMasterId = 31579
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Ethanol', strState = 'NM', strStatus = 'Include', intMasterId = 31581
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Gasoline', strState = 'NM', strStatus = 'Include', intMasterId = 31580
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', strState = 'NM', strStatus = 'Include', intMasterId = 31582
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Ethanol', strState = 'NM', strStatus = 'Exclude', intMasterId = 31584
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Gasoline', strState = 'NM', strStatus = 'Exclude', intMasterId = 31583
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', strState = 'NM', strStatus = 'Exclude', intMasterId = 31585
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Ethanol', strState = 'NM', strStatus = 'Include', intMasterId = 31587
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Gasoline', strState = 'NM', strStatus = 'Include', intMasterId = 31586
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', strState = 'NM', strStatus = 'Include', intMasterId = 31588
	--UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Ethanol', strState = 'NM', strStatus = 'Include', intMasterId = 31590
	--UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Gasoline', strState = 'NM', strStatus = 'Include', intMasterId = 31589
	--UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', strState = 'NM', strStatus = 'Include', intMasterId = 31591
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '6J', strType = 'Special Fuel', strState = 'NM', strStatus = 'Include', intMasterId = 31592
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Ethanol', strState = 'NM', strStatus = 'Exclude', intMasterId = 31602
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Gasoline', strState = 'NM', strStatus = 'Exclude', intMasterId = 31601
	UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', strState = 'NM', strStatus = 'Exclude', intMasterId = 31595
	--UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', strState = 'NM', strStatus = 'Include', intMasterId = 31598
	
	INSERT INTO @ValidDestinationStates(
		intValidDestinationStateId
		, strFormCode
		, strScheduleCode
		, strType
		, strState
		, strStatus
		, intMasterId
	)
	SELECT intValidDestinationStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Ethanol', strState = 'NM', strStatus = 'Include', intMasterId = 31575
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Gasoline', strState = 'NM', strStatus = 'Include', intMasterId = 31574
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', strState = 'NM', strStatus = 'Include', intMasterId = 31576
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Ethanol', strState = 'NM', strStatus = 'Include', intMasterId = 31578
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Gasoline', strState = 'NM', strStatus = 'Include', intMasterId = 31577
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', strState = 'NM', strStatus = 'Include', intMasterId = 31579
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Ethanol', strState = 'NM', strStatus = 'Include', intMasterId = 31581
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Gasoline', strState = 'NM', strStatus = 'Include', intMasterId = 31580
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', strState = 'NM', strStatus = 'Include', intMasterId = 31582
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Ethanol', strState = 'NM', strStatus = 'Include', intMasterId = 31584
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Gasoline', strState = 'NM', strStatus = 'Include', intMasterId = 31583
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', strState = 'NM', strStatus = 'Include', intMasterId = 31585
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Ethanol', strState = 'NM', strStatus = 'Include', intMasterId = 31587
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Gasoline', strState = 'NM', strStatus = 'Include', intMasterId = 31586
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', strState = 'NM', strStatus = 'Include', intMasterId = 31588
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Ethanol', strState = 'NM', strStatus = 'Include', intMasterId = 31590
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Gasoline', strState = 'NM', strStatus = 'Include', intMasterId = 31589
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', strState = 'NM', strStatus = 'Include', intMasterId = 31591
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '6J', strType = 'Special Fuel', strState = 'NM', strStatus = 'Include', intMasterId = 31592
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Ethanol', strState = 'NM', strStatus = 'Exclude', intMasterId = 31602
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Gasoline', strState = 'NM', strStatus = 'Exclude', intMasterId = 31601
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', strState = 'NM', strStatus = 'Exclude', intMasterId = 31595
	UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', strState = 'NM', strStatus = 'Include', intMasterId = 31598

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
	+ CASE WHEN intConfigurationSequence IS NULL THEN ', intConfigurationSequence = ' + CAST(intTemplateItemNumber AS NVARCHAR(10)) ELSE ', intConfigurationSequence = ''' + CAST(intConfigurationSequence AS NVARCHAR(10)) + ''''  END
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
	SELECT intReportTemplateId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Form41164', strType = '', strTemplateItemId = 'NMAlt-TaxRateLPG', strReportSection = '', intReportItemSequence = '0', intTemplateItemNumber = '1', strDescription = 'Tax Rate - LPG', strScheduleList = NULL, strConfiguration = '0.120', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '1', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 31878
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Form41164', strType = '', strTemplateItemId = 'NMAlt-TaxRateCNG', strReportSection = '', intReportItemSequence = '0', intTemplateItemNumber = '2', strDescription = 'Tax Rate - CNG', strScheduleList = NULL, strConfiguration = '0.133', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '2', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 31879
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Form41164', strType = '', strTemplateItemId = 'NMAlt-TaxRateLNG', strReportSection = '', intReportItemSequence = '0', intTemplateItemNumber = '3', strDescription = 'Tax Rate - LNG', strScheduleList = NULL, strConfiguration = '0.206', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '3', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 31880
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Form41164', strType = '', strTemplateItemId = 'NMAlt-TaxRateA55', strReportSection = '', intReportItemSequence = '0', intTemplateItemNumber = '4', strDescription = 'Tax Rate - A-55', strScheduleList = NULL, strConfiguration = '0.120', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '4', ysnOutputDesigner = 0, strInputType = 'double', intMasterId = 31881	
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'Form 41306', strScheduleCode = 'A', strType = '', strTemplateItemId = 'NMSchA-County', strReportSection = '', intReportItemSequence = '0', intTemplateItemNumber = '0', strDescription = 'strNMCounty', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = NULL, ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '2', ysnOutputDesigner = 1, strInputType = NULL, intMasterId = 31885
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'Form 41306', strScheduleCode = 'A', strType = '', strTemplateItemId = 'NMSchA-Location', strReportSection = '', intReportItemSequence = '0', intTemplateItemNumber = '0', strDescription = 'strNMLocation', strScheduleList = NULL, strConfiguration = '', ysnConfiguration = NULL, ysnUserDefinedValue = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '3', ysnOutputDesigner = 1, strInputType = NULL, intMasterId = 31886
	UNION ALL SELECT intReportTemplateId = 0, strFormCode = 'Form 41306', strScheduleCode = 'A', strType = '', strTemplateItemId = 'NMSchA-GrossNet', strReportSection = '', intReportItemSequence = '0', intTemplateItemNumber = '1', strDescription = 'Reporting Gross or Net', strScheduleList = NULL, strConfiguration = 'Net', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '1', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 31887
		
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
	SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115310
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115311
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115312
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115313
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115314
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115315
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115316
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115317
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115318
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115319
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115320
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'strBillofLading', strCaption = 'BOL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115321
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115322
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115323
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115324
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115325
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115326
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115327
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Ethanol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115328
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115329
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Ethanol', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115330
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115331
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Ethanol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115332
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Ethanol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115333
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115334
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Ethanol', strColumn = 'strBillofLading', strCaption = 'BOL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115335
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Ethanol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115336
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115337
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115338
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115339
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115340
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115341
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115342
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115343
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115344
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115345
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115346
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115347
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115348
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'strBillofLading', strCaption = 'BOL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115349
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115350
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115351
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115352
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115353
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115354
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115355
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115356
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115357
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115358
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115359
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115360
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115361
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115362
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strBillofLading', strCaption = 'BOL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115363
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115364
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115365
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115366
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115367
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115368
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115369
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Ethanol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115370
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115371
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Ethanol', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115372
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115373
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Ethanol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115374
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Ethanol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115375
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115376
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Ethanol', strColumn = 'strBillofLading', strCaption = 'BOL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115377
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Ethanol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115378
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115379
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115380
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115381
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115382
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115383
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115384
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115385
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115386
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115387
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115388
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115389
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115390
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strBillofLading', strCaption = 'BOL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115391
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115392
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115393
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115394
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115395
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115396
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115397
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115398
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115399
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115400
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115401
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115402
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115403
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115404
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strBillofLading', strCaption = 'BOL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115405
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115406
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115407
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115408
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115409
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115410
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115411
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Ethanol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115412
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115413
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Ethanol', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115414
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115415
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Ethanol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115416
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Ethanol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115417
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115418
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Ethanol', strColumn = 'strBillofLading', strCaption = 'BOL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115419
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Ethanol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115420
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115421
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115422
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115423
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115424
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115425
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115426
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115427
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115428
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115429
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115430
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115431
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115432
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strBillofLading', strCaption = 'BOL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115433
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115434
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115435
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115436
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115437
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115438
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115439
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115440
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115441
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115442
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115443
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Gasoline', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115444
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115445
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115446
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Gasoline', strColumn = 'strBillofLading', strCaption = 'BOL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115447
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115448
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115449
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115450
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115451
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115452
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115453
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Ethanol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115454
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115455
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Ethanol', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115456
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115457
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Ethanol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115458
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Ethanol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115459
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115460
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Ethanol', strColumn = 'strBillofLading', strCaption = 'BOL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115461
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Ethanol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115462
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115463
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115464
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115465
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115466
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115467
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115468
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115469
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115470
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115471
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115472
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115473
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115474
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'strBillofLading', strCaption = 'BOL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115475
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115476
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115477
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115478
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115479
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115480
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115481
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115482
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115483
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115484
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115485
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Gasoline', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115486
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115487
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115488
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Gasoline', strColumn = 'strBillofLading', strCaption = 'BOL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115489
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115490
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115491
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115492
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115493
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115494
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115495
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Ethanol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115496
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115497
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Ethanol', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115498
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115499
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Ethanol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115500
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Ethanol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115501
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115502
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Ethanol', strColumn = 'strBillofLading', strCaption = 'BOL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115503
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Ethanol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115504
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115505
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115506
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115507
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115508
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115509
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115510
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115511
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115512
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115513
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115514
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115515
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115516
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', strColumn = 'strBillofLading', strCaption = 'BOL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115517
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115518
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115519
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115520
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115521
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115522
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115523
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115524
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115525
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115526
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115527
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115528
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115529
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115530
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'strBillofLading', strCaption = 'BOL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115531
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115532
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115533
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115534
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115535
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115536
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115537
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115538
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115539
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115540
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115541
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115542
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115543
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115544
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strBillofLading', strCaption = 'BOL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115545
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115546
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115547
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115548
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115549
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115550
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115551
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115552
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115553
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115554
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115555
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115556
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115557
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115558
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'strBillofLading', strCaption = 'BOL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115559
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115560
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115561
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115562
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115563
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115564
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115565
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115566
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115567
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115568
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115569
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Gasoline', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115570
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115571
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115572
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Gasoline', strColumn = 'strBillofLading', strCaption = 'BOL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115573
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115574
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115575
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115576
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115577
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115578
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115579
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Ethanol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115580
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115581
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Ethanol', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115582
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115583
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Ethanol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115584
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Ethanol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115585
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115586
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Ethanol', strColumn = 'strBillofLading', strCaption = 'BOL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115587
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Ethanol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115588
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115589
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115590
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115591
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115592
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115593
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115594
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115595
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115596
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115597
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115598
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115599
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115600
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'strBillofLading', strCaption = 'BOL', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115601
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115602
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115603
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115604
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115605
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115606
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115607
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115608
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115609
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115610
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115611
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115612
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115613
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115614
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Gasoline', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115615
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115616
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115617
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115618
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115619
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115620
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115621
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Ethanol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115622
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115623
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Ethanol', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115624
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115625
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Ethanol', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115626
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115627
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115628
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Ethanol', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115629
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Ethanol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115630
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115631
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115632
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115633
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115634
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115635
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115636
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115637
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115638
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115639
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115640
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115641
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115642
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115643
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115644
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115645
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115646
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115647
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115648
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115649
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115650
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115651
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115652
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115653
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115654
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115655
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115656
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Gasoline', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115657
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115658
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115659
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115660
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115661
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115662
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115663
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Ethanol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115664
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115665
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Ethanol', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115666
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115667
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Ethanol', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115668
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115669
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115670
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Ethanol', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115671
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Ethanol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115672
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115673
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115674
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115675
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115676
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115677
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115678
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115679
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115680
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115681
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115682
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115683
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115684
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115685
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115686
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115687
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6J', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115688
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6J', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115689
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6J', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115690
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6J', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115691
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6J', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115692
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6J', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115693
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6J', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115694
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6J', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115695
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6J', strType = 'Special Fuel', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115696
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6J', strType = 'Special Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115697
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6J', strType = 'Special Fuel', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115698
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6J', strType = 'Special Fuel', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115699
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6J', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115700
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6J', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115701
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115702
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115703
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115704
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115705
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115706
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115707
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115708
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115709
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115710
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115711
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115712
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115713
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115714
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115715
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115716
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115717
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115718
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115719
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115720
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115721
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115722
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115723
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115724
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115725
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115726
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115727
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115728
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115729
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115730
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115731
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115732
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115733
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115734
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115735
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115736
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115737
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115738
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115739
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115740
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115741
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115742
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115743
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115744
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115745
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115746
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115747
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115748
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115749
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115750
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115751
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115752
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115753
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115754
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115755
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115756
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115757
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115758
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115759
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115760
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115761
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115762
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115763
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115764
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115765
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115766
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115767
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115768
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115769
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115770
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115771
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115772
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115773
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115774
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115775
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115776
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115777
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115778
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115779
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115780
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115781
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115782
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115783
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115784
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115785
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115786
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115787
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115788
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115789
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115790
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115791
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115792
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115793
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115794
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115795
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115796
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115797
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115798
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115799
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115800
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115801
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115802
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115803
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115804
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115805
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115806
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115807
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115808
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115809
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115810
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Gasoline', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115811
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115812
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115813
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115814
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115815
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115816
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115817
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Ethanol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115818
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115819
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Ethanol', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115820
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115821
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Ethanol', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115822
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115823
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115824
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Ethanol', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115825
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Ethanol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115826
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115827
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115828
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115829
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115830
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115831
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115832
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115833
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115834
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115835
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115836
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115837
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115838
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Gasoline', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115839
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115840
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115841
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115842
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115843
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115844
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115845
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Ethanol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115846
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115847
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Ethanol', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115848
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115849
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Ethanol', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115850
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115851
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115852
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Ethanol', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115853
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Ethanol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115854
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115855
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115856
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115857
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115858
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115859
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115860
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115861
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115862
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115863
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115864
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115865
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115866
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115867
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115868
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115869
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115870
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115871
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115872
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115873
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115874
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115875
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115876
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115877
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115878
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115879
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115880
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115881
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115882
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115883
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115884
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115885
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115886
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115887
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Gasoline', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115888
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115889
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Gasoline', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115890
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115891
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115892
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115893
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115894
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Gasoline', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115895
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115896
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115897
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115898
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115899
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115900
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115901
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Ethanol', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115902
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115903
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Ethanol', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115904
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115905
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Ethanol', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115906
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115907
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115908
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Ethanol', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115909
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Ethanol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115910
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115911
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115912
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Special Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115913
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Special Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115914
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115915
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Special Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115916
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115917
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Special Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115918
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115919
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Special Fuel', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115920
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Special Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115921
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Special Fuel', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115922
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Special Fuel', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115923
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115924
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115925
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'LPG', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115926
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'LPG', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115927
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'LPG', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115928
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'LPG', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115929
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'LPG', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115930
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'LPG', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115931
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'LPG', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115932
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'CNG', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115933
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'CNG', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115934
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'CNG', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115935
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'CNG', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115936
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'CNG', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115937
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'CNG', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115938
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'CNG', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115939
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'LNG', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115940
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'LNG', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115941
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'LNG', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115942
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'LNG', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115943
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'LNG', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115944
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'LNG', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115945
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'LNG', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115946
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'A-55', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115947
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'A-55', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115948
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'A-55', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115949
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'A-55', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115950
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'A-55', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115951
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'A-55', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115952
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'A-55', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115953
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'LPG', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115954
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'LPG', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115955
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'LPG', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115956
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'LPG', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115957
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'LPG', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115958
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'LPG', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115959
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'LPG', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115960
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'CNG', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115961
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'CNG', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115962
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'CNG', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115963
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'CNG', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115964
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'CNG', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115965
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'CNG', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115966
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'CNG', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115967
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'LNG', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115968
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'LNG', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115969
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'LNG', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115970
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'LNG', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115971
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'LNG', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115972
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'LNG', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115973
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'LNG', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115974
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'A-55', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115975
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'A-55', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115976
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'A-55', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115977
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'A-55', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115978
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'A-55', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115979
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'A-55', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115980
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'A-55', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115981
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'LPG', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115982
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'LPG', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115983
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'LPG', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115984
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'LPG', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115985
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'LPG', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115986
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'LPG', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115987
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'LPG', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115988
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'CNG', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115989
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'CNG', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115990
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'CNG', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115991
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'CNG', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115992
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'CNG', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115993
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'CNG', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115994
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'CNG', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115995
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'LNG', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115996
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'LNG', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115997
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'LNG', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115998
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'LNG', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3115999
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'LNG', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3116000
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'LNG', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3116001
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'LNG', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3116002
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'A-55', strColumn = 'strProductCode', strCaption = 'Product Type', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3116003
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'A-55', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3116004
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'A-55', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3116005
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'A-55', strColumn = 'dtmDate', strCaption = 'Date Shipped', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3116006
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'A-55', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3116007
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'A-55', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3116008
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'A-55', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3116009
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = 'A', strType = '', strColumn = 'strNMCounty', strCaption = 'County', strFormat = NULL, strFooter = NULL, intWidth = NULL, ysnFromConfiguration = 1, intMasterId = 3116010
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = 'A', strType = '', strColumn = 'strNMLocation', strCaption = 'Location', strFormat = NULL, strFooter = NULL, intWidth = NULL, ysnFromConfiguration = 1, intMasterId = 3116011
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = 'A', strType = '', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3116012
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = 'A', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3116013
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = 'A', strType = '', strColumn = 'strInvoiceNumber', strCaption = 'Invoice Number', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3116014
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = 'A', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3116015
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = 'A', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3116016
	UNION ALL SELECT intScheduleColumnId = 0, strFormCode = 'Form 41306', strScheduleCode = 'A', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, ysnFromConfiguration = 0, intMasterId = 3116017

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
	SELECT intFilingPacketId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'A-55', ysnStatus = 1, intFrequency = 1, intMasterId = 311807
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'CNG', ysnStatus = 1, intFrequency = 1, intMasterId = 311805
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'LNG', ysnStatus = 1, intFrequency = 1, intMasterId = 311806
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Deductions', strType = 'LPG', ysnStatus = 1, intFrequency = 1, intMasterId = 311804
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'A-55', ysnStatus = 1, intFrequency = 1, intMasterId = 311799
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'CNG', ysnStatus = 1, intFrequency = 1, intMasterId = 311797
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'LNG', ysnStatus = 1, intFrequency = 1, intMasterId = 311798
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Disbursed', strType = 'LPG', ysnStatus = 1, intFrequency = 1, intMasterId = 311796
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'A-55', ysnStatus = 1, intFrequency = 1, intMasterId = 311803
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'CNG', ysnStatus = 1, intFrequency = 1, intMasterId = 311801
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'LNG', ysnStatus = 1, intFrequency = 1, intMasterId = 311802
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Exemptions', strType = 'LPG', ysnStatus = 1, intFrequency = 1, intMasterId = 311800
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41164', strScheduleCode = 'Form41164', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 311808
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Ethanol', ysnStatus = 1, intFrequency = 1, intMasterId = 311753
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 311752
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '1', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 311754
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Ethanol', ysnStatus = 1, intFrequency = 1, intMasterId = 311794
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 311793
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '10A', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 311795
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '10F', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 311791
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '10G', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 311792
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Ethanol', ysnStatus = 1, intFrequency = 1, intMasterId = 311788
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '10T', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 311787
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Ethanol', ysnStatus = 1, intFrequency = 1, intMasterId = 311756
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 311755
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '1A', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 311757
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Ethanol', ysnStatus = 1, intFrequency = 1, intMasterId = 311759
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 311758
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '2A', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 311760
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Ethanol', ysnStatus = 1, intFrequency = 1, intMasterId = 311762
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 311761
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '2B', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 311763
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Ethanol', ysnStatus = 1, intFrequency = 1, intMasterId = 311765
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 311764
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '2C', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 311766
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Ethanol', ysnStatus = 1, intFrequency = 1, intMasterId = 311768
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 311767
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '3', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 311769
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Ethanol', ysnStatus = 1, intFrequency = 1, intMasterId = 311771
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 311770
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '4', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 311772
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Ethanol', ysnStatus = 1, intFrequency = 1, intMasterId = 311774
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 311773
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '5A', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 311775
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Ethanol', ysnStatus = 1, intFrequency = 1, intMasterId = 311777
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 311776
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '5B', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 311778
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '6J', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 311779
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Ethanol', ysnStatus = 1, intFrequency = 1, intMasterId = 311790
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '6V', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 311789
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Ethanol', ysnStatus = 1, intFrequency = 1, intMasterId = 311781
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 311780
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '7', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 311782
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Ethanol', ysnStatus = 1, intFrequency = 1, intMasterId = 311784
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 311783
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '8', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 311785
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = '9', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 311786
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = 'A', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 311809
	UNION ALL SELECT intFilingPacketId = 0, strFormCode = 'Form 41306', strScheduleCode = 'Form-41306', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 311810

	EXEC uspTFUpgradeFilingPackets @TaxAuthorityCode = @TaxAuthorityCode, @FilingPackets = @FilingPackets

-- NM County Location

	SELECT *
	INTO #tmpCompanyLocation
	FROM (
	SELECT intCountyLocationId = 1, strCounty = 'Bernalillo County', strLocation = 'Albuquerque'
	UNION ALL SELECT intCountyLocationId = 2, strCounty = 'Bernalillo County', strLocation = 'Bernalillo County, Remainder'
	UNION ALL SELECT intCountyLocationId = 3, strCounty = 'Bernalillo County', strLocation = 'Los Ranchos de Albuquerque'
	UNION ALL SELECT intCountyLocationId = 4, strCounty = 'Bernalillo County', strLocation = 'Rio Rancho (Bernalillo)'
	UNION ALL SELECT intCountyLocationId = 5, strCounty = 'Bernalillo County', strLocation = 'Tijeras'
	UNION ALL SELECT intCountyLocationId = 6, strCounty = 'Catron County', strLocation = 'Catron County, Remainder'
	UNION ALL SELECT intCountyLocationId = 7, strCounty = 'Catron County', strLocation = 'Reserve'
	UNION ALL SELECT intCountyLocationId = 8, strCounty = 'Chaves County', strLocation = 'Chaves County, Remainder'
	UNION ALL SELECT intCountyLocationId = 9, strCounty = 'Chaves County', strLocation = 'Dexter'
	UNION ALL SELECT intCountyLocationId = 10, strCounty = 'Chaves County', strLocation = 'Hagerman'
	UNION ALL SELECT intCountyLocationId = 11, strCounty = 'Chaves County', strLocation = 'Lake Arthur'
	UNION ALL SELECT intCountyLocationId = 12, strCounty = 'Chaves County', strLocation = 'Roswell'
	UNION ALL SELECT intCountyLocationId = 13, strCounty = 'Cibola County', strLocation = 'Cibola County, Remainder'
	UNION ALL SELECT intCountyLocationId = 14, strCounty = 'Cibola County', strLocation = 'Grants'
	UNION ALL SELECT intCountyLocationId = 15, strCounty = 'Cibola County', strLocation = 'Milan'
	UNION ALL SELECT intCountyLocationId = 16, strCounty = 'Colfax County', strLocation = 'Angel Fire'
	UNION ALL SELECT intCountyLocationId = 17, strCounty = 'Colfax County', strLocation = 'Cimarron'
	UNION ALL SELECT intCountyLocationId = 18, strCounty = 'Colfax County', strLocation = 'Colfax County, Remainder'
	UNION ALL SELECT intCountyLocationId = 19, strCounty = 'Colfax County', strLocation = 'Eagle Nest'
	UNION ALL SELECT intCountyLocationId = 20, strCounty = 'Colfax County', strLocation = 'Maxwell'
	UNION ALL SELECT intCountyLocationId = 21, strCounty = 'Colfax County', strLocation = 'Raton'
	UNION ALL SELECT intCountyLocationId = 22, strCounty = 'Colfax County', strLocation = 'Springer'
	UNION ALL SELECT intCountyLocationId = 23, strCounty = 'Curry County', strLocation = 'Clovis'
	UNION ALL SELECT intCountyLocationId = 24, strCounty = 'Curry County', strLocation = 'Curry County, Remainder'
	UNION ALL SELECT intCountyLocationId = 25, strCounty = 'Curry County', strLocation = 'Grady'
	UNION ALL SELECT intCountyLocationId = 26, strCounty = 'Curry County', strLocation = 'Melrose'
	UNION ALL SELECT intCountyLocationId = 27, strCounty = 'Curry County', strLocation = 'Texico'
	UNION ALL SELECT intCountyLocationId = 28, strCounty = 'De Baca County', strLocation = 'De Baca County, Remainder'
	UNION ALL SELECT intCountyLocationId = 29, strCounty = 'De Baca County', strLocation = 'Fort Sumner'
	UNION ALL SELECT intCountyLocationId = 30, strCounty = 'Dona Ana County', strLocation = 'Anthony'
	UNION ALL SELECT intCountyLocationId = 31, strCounty = 'Dona Ana County', strLocation = 'Dona Ana County, Remainder'
	UNION ALL SELECT intCountyLocationId = 32, strCounty = 'Dona Ana County', strLocation = 'Hatch'
	UNION ALL SELECT intCountyLocationId = 33, strCounty = 'Dona Ana County', strLocation = 'Las Cruces'
	UNION ALL SELECT intCountyLocationId = 34, strCounty = 'Dona Ana County', strLocation = 'Mesilla'
	UNION ALL SELECT intCountyLocationId = 35, strCounty = 'Dona Ana County', strLocation = 'Sunland Park'
	UNION ALL SELECT intCountyLocationId = 36, strCounty = 'Eddy County', strLocation = 'Artesia'
	UNION ALL SELECT intCountyLocationId = 37, strCounty = 'Eddy County', strLocation = 'Carlsbad'
	UNION ALL SELECT intCountyLocationId = 38, strCounty = 'Eddy County', strLocation = 'Eddy County, Remainder'
	UNION ALL SELECT intCountyLocationId = 39, strCounty = 'Eddy County', strLocation = 'Hope'
	UNION ALL SELECT intCountyLocationId = 40, strCounty = 'Eddy County', strLocation = 'Loving'
	UNION ALL SELECT intCountyLocationId = 41, strCounty = 'Grant County', strLocation = 'Bayard'
	UNION ALL SELECT intCountyLocationId = 42, strCounty = 'Grant County', strLocation = 'Grant County, Remainder'
	UNION ALL SELECT intCountyLocationId = 43, strCounty = 'Grant County', strLocation = 'Hurley'
	UNION ALL SELECT intCountyLocationId = 44, strCounty = 'Grant County', strLocation = 'Santa Clara'
	UNION ALL SELECT intCountyLocationId = 45, strCounty = 'Grant County', strLocation = 'Silver City'
	UNION ALL SELECT intCountyLocationId = 46, strCounty = 'Guadalupe County', strLocation = 'Guadalupe County, Remainder'
	UNION ALL SELECT intCountyLocationId = 47, strCounty = 'Guadalupe County', strLocation = 'Santa Rosa'
	UNION ALL SELECT intCountyLocationId = 48, strCounty = 'Guadalupe County', strLocation = 'Vaughn'
	UNION ALL SELECT intCountyLocationId = 49, strCounty = 'Harding County', strLocation = 'Harding County, Remainder'
	UNION ALL SELECT intCountyLocationId = 50, strCounty = 'Harding County', strLocation = 'Mosquero (Harding)'
	UNION ALL SELECT intCountyLocationId = 51, strCounty = 'Harding County', strLocation = 'Roy'
	UNION ALL SELECT intCountyLocationId = 52, strCounty = 'Hidalgo County', strLocation = 'Hidalgo County, Remainder'
	UNION ALL SELECT intCountyLocationId = 53, strCounty = 'Hidalgo County', strLocation = 'Lordsburg'
	UNION ALL SELECT intCountyLocationId = 54, strCounty = 'Hidalgo County', strLocation = 'Virden'
	UNION ALL SELECT intCountyLocationId = 55, strCounty = 'Lea County', strLocation = 'Eunice'
	UNION ALL SELECT intCountyLocationId = 56, strCounty = 'Lea County', strLocation = 'Hobbs'
	UNION ALL SELECT intCountyLocationId = 57, strCounty = 'Lea County', strLocation = 'Jal'
	UNION ALL SELECT intCountyLocationId = 58, strCounty = 'Lea County', strLocation = 'Lea County, Remainder'
	UNION ALL SELECT intCountyLocationId = 59, strCounty = 'Lea County', strLocation = 'Lovington'
	UNION ALL SELECT intCountyLocationId = 60, strCounty = 'Lea County', strLocation = 'Tatum'
	UNION ALL SELECT intCountyLocationId = 61, strCounty = 'Lincoln County', strLocation = 'Capitan'
	UNION ALL SELECT intCountyLocationId = 62, strCounty = 'Lincoln County', strLocation = 'Carrizozo'
	UNION ALL SELECT intCountyLocationId = 63, strCounty = 'Lincoln County', strLocation = 'Corona'
	UNION ALL SELECT intCountyLocationId = 64, strCounty = 'Lincoln County', strLocation = 'Lincoln County, Remainder'
	UNION ALL SELECT intCountyLocationId = 65, strCounty = 'Lincoln County', strLocation = 'Ruidoso'
	UNION ALL SELECT intCountyLocationId = 66, strCounty = 'Lincoln County', strLocation = 'Ruidoso Downs'
	UNION ALL SELECT intCountyLocationId = 67, strCounty = 'Los Alamos', strLocation = 'Los Alamos (city & county)'
	UNION ALL SELECT intCountyLocationId = 68, strCounty = 'Luna County', strLocation = 'Columbus'
	UNION ALL SELECT intCountyLocationId = 69, strCounty = 'Luna County', strLocation = 'Deming'
	UNION ALL SELECT intCountyLocationId = 70, strCounty = 'Luna County', strLocation = 'Luna County, Remainder'
	UNION ALL SELECT intCountyLocationId = 71, strCounty = 'McKinley County', strLocation = 'Gallup'
	UNION ALL SELECT intCountyLocationId = 72, strCounty = 'McKinley County', strLocation = 'McKinley County, Remainder'
	UNION ALL SELECT intCountyLocationId = 73, strCounty = 'Mora County', strLocation = 'Mora County, Remainder'
	UNION ALL SELECT intCountyLocationId = 74, strCounty = 'Mora County', strLocation = 'Wagon Mound'
	UNION ALL SELECT intCountyLocationId = 75, strCounty = 'Otero County', strLocation = 'Alamogordo'
	UNION ALL SELECT intCountyLocationId = 76, strCounty = 'Otero County', strLocation = 'Cloudcroft'
	UNION ALL SELECT intCountyLocationId = 77, strCounty = 'Otero County', strLocation = 'Otero County, Remainder'
	UNION ALL SELECT intCountyLocationId = 78, strCounty = 'Otero County', strLocation = 'Tularosa'
	UNION ALL SELECT intCountyLocationId = 79, strCounty = 'Quay County', strLocation = 'House'
	UNION ALL SELECT intCountyLocationId = 80, strCounty = 'Quay County', strLocation = 'Logan'
	UNION ALL SELECT intCountyLocationId = 81, strCounty = 'Quay County', strLocation = 'Quay County, Remainder'
	UNION ALL SELECT intCountyLocationId = 82, strCounty = 'Quay County', strLocation = 'San Jon'
	UNION ALL SELECT intCountyLocationId = 83, strCounty = 'Quay County', strLocation = 'Tucumcari'
	UNION ALL SELECT intCountyLocationId = 84, strCounty = 'Rio Arriba County', strLocation = 'Chama'
	UNION ALL SELECT intCountyLocationId = 85, strCounty = 'Rio Arriba County', strLocation = 'Espanola (Rio Arriba)'
	UNION ALL SELECT intCountyLocationId = 86, strCounty = 'Rio Arriba County', strLocation = 'Rio Arriba County, Remainder'
	UNION ALL SELECT intCountyLocationId = 87, strCounty = 'Roosevelt County', strLocation = 'Causey'
	UNION ALL SELECT intCountyLocationId = 88, strCounty = 'Roosevelt County', strLocation = 'Dora'
	UNION ALL SELECT intCountyLocationId = 89, strCounty = 'Roosevelt County', strLocation = 'Elida'
	UNION ALL SELECT intCountyLocationId = 90, strCounty = 'Roosevelt County', strLocation = 'Floyd'
	UNION ALL SELECT intCountyLocationId = 91, strCounty = 'Roosevelt County', strLocation = 'Portales'
	UNION ALL SELECT intCountyLocationId = 92, strCounty = 'Roosevelt County', strLocation = 'Roosevelt County, Remainder'
	UNION ALL SELECT intCountyLocationId = 93, strCounty = 'San Juan County', strLocation = 'Aztec'
	UNION ALL SELECT intCountyLocationId = 94, strCounty = 'San Juan County', strLocation = 'Bloomfield'
	UNION ALL SELECT intCountyLocationId = 95, strCounty = 'San Juan County', strLocation = 'Farmington'
	UNION ALL SELECT intCountyLocationId = 96, strCounty = 'San Juan County', strLocation = 'San Juan County, Remainder'
	UNION ALL SELECT intCountyLocationId = 97, strCounty = 'San Miguel County', strLocation = 'Las Vegas'
	UNION ALL SELECT intCountyLocationId = 98, strCounty = 'San Miguel County', strLocation = 'Mosquero (San Miguel)'
	UNION ALL SELECT intCountyLocationId = 99, strCounty = 'San Miguel County', strLocation = 'Pecos'
	UNION ALL SELECT intCountyLocationId = 100, strCounty = 'San Miguel County', strLocation = 'San Miguel County, Remainder'
	UNION ALL SELECT intCountyLocationId = 101, strCounty = 'Sandoval County', strLocation = 'Bernalillo (city)'
	UNION ALL SELECT intCountyLocationId = 102, strCounty = 'Sandoval County', strLocation = 'Corrales (Sandoval)'
	UNION ALL SELECT intCountyLocationId = 103, strCounty = 'Sandoval County', strLocation = 'Cuba'
	UNION ALL SELECT intCountyLocationId = 104, strCounty = 'Sandoval County', strLocation = 'Jemez Springs'
	UNION ALL SELECT intCountyLocationId = 105, strCounty = 'Sandoval County', strLocation = 'Rio Rancho (Sandoval)'
	UNION ALL SELECT intCountyLocationId = 106, strCounty = 'Sandoval County', strLocation = 'San Ysidro'
	UNION ALL SELECT intCountyLocationId = 107, strCounty = 'Sandoval County', strLocation = 'Sandoval County, Remainder'
	UNION ALL SELECT intCountyLocationId = 108, strCounty = 'Santa Fe County', strLocation = 'Edgewood'
	UNION ALL SELECT intCountyLocationId = 109, strCounty = 'Santa Fe County', strLocation = 'Espanola (Santa Fe)'
	UNION ALL SELECT intCountyLocationId = 110, strCounty = 'Santa Fe County', strLocation = 'Santa Fe (city)'
	UNION ALL SELECT intCountyLocationId = 111, strCounty = 'Santa Fe County', strLocation = 'Santa Fe County, Remainder'
	UNION ALL SELECT intCountyLocationId = 112, strCounty = 'Sierra County', strLocation = 'Elephant Butte'
	UNION ALL SELECT intCountyLocationId = 113, strCounty = 'Sierra County', strLocation = 'Sierra County, Remainder'
	UNION ALL SELECT intCountyLocationId = 114, strCounty = 'Sierra County', strLocation = 'Truth or Consequences'
	UNION ALL SELECT intCountyLocationId = 115, strCounty = 'Sierra County', strLocation = 'Williamsburg'
	UNION ALL SELECT intCountyLocationId = 116, strCounty = 'Socorro County', strLocation = 'Magdalena'
	UNION ALL SELECT intCountyLocationId = 117, strCounty = 'Socorro County', strLocation = 'Socorro (city)'
	UNION ALL SELECT intCountyLocationId = 118, strCounty = 'Socorro County', strLocation = 'Socorro County, Remainder'
	UNION ALL SELECT intCountyLocationId = 119, strCounty = 'Taos County', strLocation = 'Questa'
	UNION ALL SELECT intCountyLocationId = 120, strCounty = 'Taos County', strLocation = 'Red River'
	UNION ALL SELECT intCountyLocationId = 121, strCounty = 'Taos County', strLocation = 'Taos (city)'
	UNION ALL SELECT intCountyLocationId = 122, strCounty = 'Taos County', strLocation = 'Taos County, Remainder'
	UNION ALL SELECT intCountyLocationId = 123, strCounty = 'Taos County', strLocation = 'Taos Ski Valley'
	UNION ALL SELECT intCountyLocationId = 124, strCounty = 'Torrance County', strLocation = 'Encino'
	UNION ALL SELECT intCountyLocationId = 125, strCounty = 'Torrance County', strLocation = 'Estancia'
	UNION ALL SELECT intCountyLocationId = 126, strCounty = 'Torrance County', strLocation = 'Moriarty'
	UNION ALL SELECT intCountyLocationId = 127, strCounty = 'Torrance County', strLocation = 'Mountainair'
	UNION ALL SELECT intCountyLocationId = 128, strCounty = 'Torrance County', strLocation = 'Torrance County, Remainder'
	UNION ALL SELECT intCountyLocationId = 129, strCounty = 'Torrance County', strLocation = 'Willard'
	UNION ALL SELECT intCountyLocationId = 130, strCounty = 'Union County', strLocation = 'Clayton'
	UNION ALL SELECT intCountyLocationId = 131, strCounty = 'Union County', strLocation = 'Des Moines'
	UNION ALL SELECT intCountyLocationId = 132, strCounty = 'Union County', strLocation = 'Folsom'
	UNION ALL SELECT intCountyLocationId = 133, strCounty = 'Union County', strLocation = 'Grenville'
	UNION ALL SELECT intCountyLocationId = 134, strCounty = 'Union County', strLocation = 'Union County, Remainder'
	UNION ALL SELECT intCountyLocationId = 135, strCounty = 'Valencia County', strLocation = 'Belen'
	UNION ALL SELECT intCountyLocationId = 136, strCounty = 'Valencia County', strLocation = 'Bosque Farms'
	UNION ALL SELECT intCountyLocationId = 137, strCounty = 'Valencia County', strLocation = 'Los Lunas'
	UNION ALL SELECT intCountyLocationId = 138, strCounty = 'Valencia County', strLocation = 'Peralta'
	UNION ALL SELECT intCountyLocationId = 139, strCounty = 'Valencia County', strLocation = 'Valencia County, Remainder'
	) NMCompanyLocation

	SET IDENTITY_INSERT tblTFCountyLocation ON

	MERGE	
	INTO	tblTFCountyLocation 
	WITH	(HOLDLOCK) 
	AS		TARGET
	USING (
		SELECT * FROM #tmpCompanyLocation
	) AS SOURCE
		ON TARGET.intCountyLocationId = SOURCE.intCountyLocationId
	WHEN MATCHED THEN 
		UPDATE
		SET strCounty		 = SOURCE.strCounty
			, strLocation	 = SOURCE.strLocation
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (
			intCountyLocationId
			,strCounty
			,strLocation
		)
		VALUES (
			SOURCE.intCountyLocationId
			, SOURCE.strCounty
			, SOURCE.strLocation
		)
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;

	SET IDENTITY_INSERT tblTFCountyLocation OFF

	DROP TABLE #tmpCompanyLocation
END

GO