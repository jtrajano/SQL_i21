-- Declare the Tax Authority Code that will be used all throughout Pennsylvania Default Data
DECLARE @TaxAuthorityCode NVARCHAR(10) = 'PA'
	, @TaxAuthorityId INT

SELECT @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = @TaxAuthorityCode

IF(@TaxAuthorityId IS NOT NULL)
BEGIN

	PRINT ('Deploying Pennsylvania Tax Forms')

	-- Product Codes
	/* Generate script for Product Codes. Specify Tax Authority Id to filter out specific Product Codes only.
select strQuery = 'UNION ALL SELECT intProductCodeId = ' + CAST(intProductCodeId AS NVARCHAR(10)) 
		+ CASE WHEN strProductCode IS NULL THEN ', strProductCode = NULL' ELSE ', strProductCode = ''' + strProductCode + ''''  END
		+ CASE WHEN strDescription IS NULL THEN ', strDescription = NULL' ELSE ', strDescription = ''' + strDescription + ''''  END
		+ CASE WHEN strProductCodeGroup IS NULL THEN ', strProductCodeGroup = NULL' ELSE ', strProductCodeGroup = ''' + strProductCodeGroup + ''''  END
		+ CASE WHEN strNote IS NULL THEN ', strNote = NULL' ELSE ', strNote = ''' + strNote + '''' END 
		+ ', intMasterId = ' + CASE WHEN intMasterId IS NULL THEN CAST(38 AS NVARCHAR(20)) + CAST(intProductCodeId AS NVARCHAR(20)) ELSE CAST(intMasterId AS NVARCHAR(20)) END -- First 2 digit for TaxAuthorityCodeID
	from tblTFProductCode
	where intTaxAuthorityId = 38
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
	-- Insert generated script here. Remove first instance of "UNION ALL "
 SELECT intProductCodeId = 913, strProductCode = '065', strDescription = 'Gasoline', strProductCodeGroup = '', strNote = NULL, intMasterId = 38913
 UNION ALL SELECT intProductCodeId = 914, strProductCode = '124', strDescription = 'Gasohol', strProductCodeGroup = '', strNote = NULL, intMasterId = 38914
 UNION ALL SELECT intProductCodeId = 915, strProductCode = '125', strDescription = 'Aviation Gasoline', strProductCodeGroup = '', strNote = NULL, intMasterId = 38915
 UNION ALL SELECT intProductCodeId = 916, strProductCode = '130', strDescription = 'Jet Fuel', strProductCodeGroup = '', strNote = NULL, intMasterId = 38916
 UNION ALL SELECT intProductCodeId = 917, strProductCode = '123', strDescription = 'Ethanol', strProductCodeGroup = '', strNote = NULL, intMasterId = 38917
 UNION ALL SELECT intProductCodeId = 918, strProductCode = '142', strDescription = 'Kerosene - Clear', strProductCodeGroup = '', strNote = NULL, intMasterId = 38918
 UNION ALL SELECT intProductCodeId = 919, strProductCode = '073', strDescription = 'Low Sulfur Kerosene - Dyed', strProductCodeGroup = '', strNote = NULL, intMasterId = 38919
 UNION ALL SELECT intProductCodeId = 920, strProductCode = '160', strDescription = 'Low Sulfur Diesel - Clear', strProductCodeGroup = '', strNote = NULL, intMasterId = 38920
 UNION ALL SELECT intProductCodeId = 921, strProductCode = '227', strDescription = 'Low Sulfur Diesel - Dyed', strProductCodeGroup = '', strNote = NULL, intMasterId = 38921
 UNION ALL SELECT intProductCodeId = 922, strProductCode = '170', strDescription = 'Biodiesel - Clear', strProductCodeGroup = '', strNote = NULL, intMasterId = 38922
 

EXEC uspTFUpgradeProductCodes @TaxAuthorityCode = @TaxAuthorityCode, @ProductCodes = @ProductCodes


	-- Reporting Component
	/* Generate script for Reporting Components. Specify Tax Authority Id to filter out specific Reporting Components only.
select strQuery = 'UNION ALL SELECT intReportingComponentId = ' + CAST(intReportingComponentId AS NVARCHAR(10))
		+ CASE WHEN strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
		+ CASE WHEN strFormName IS NULL THEN ', strFormName = NULL' ELSE ', strFormName = ''' + strFormName + ''''  END
		+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
		+ CASE WHEN strScheduleName IS NULL THEN ', strScheduleName = NULL' ELSE ', strScheduleName = ''' + strScheduleName + '''' END 
		+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END
		+ CASE WHEN strNote IS NULL THEN ', strNote = NULL' ELSE ', strNote = ''' + strNote + '''' END
		+ CASE WHEN strTransactionType IS NULL THEN ', strTransactionType = NULL' ELSE ', strTransactionType = ''' + strTransactionType + '''' END
		+ CASE WHEN strStoredProcedure IS NULL THEN ', strStoredProcedure = NULL' ELSE ', strStoredProcedure = ''' + strStoredProcedure + '''' END
		+ CASE WHEN intSort IS NULL THEN ', intSort = NULL' ELSE ', intSort = ''' + CAST(intSort AS NVARCHAR(10)) + ''''  END
		+ CASE WHEN intComponentTypeId IS NULL THEN ', intComponentTypeId = NULL' ELSE ', intComponentTypeId = ''' + CAST(intComponentTypeId AS NVARCHAR(10)) + ''''  END
		+ ', intMasterId = ' + CASE WHEN intMasterId IS NULL THEN CAST(38 AS NVARCHAR(20)) + CAST(intReportingComponentId AS NVARCHAR(20)) ELSE CAST(intMasterId AS NVARCHAR(20)) END
	from tblTFReportingComponent
	where intTaxAuthorityId = 38
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
		, strStoredProcedure
		, intSort
		, intComponentTypeId
		, intMasterId
	)
	-- Insert generated script here. Remove first instance of "UNION ALL "
 SELECT intReportingComponentId = 1668, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '1', strScheduleName = 'Gallons Received into Inventory, PA Tax Paid', strType = 'Aviation Gas', strNote = '', strTransactionType = 'Inventory', strStoredProcedure = 'uspTFGetInventoryTax', intSort = '40', intComponentTypeId = '1', intMasterId = 381668
 UNION ALL SELECT intReportingComponentId = 1666, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '1', strScheduleName = 'Gallons Received into Inventory, PA Tax Paid', strType = 'Fuels', strNote = '', strTransactionType = 'Inventory', strStoredProcedure = 'uspTFGetInventoryTax', intSort = '20', intComponentTypeId = '1', intMasterId = 381666
 UNION ALL SELECT intReportingComponentId = 1667, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '1', strScheduleName = 'Gallons Received into Inventory, PA Tax Paid', strType = 'Jet Fuel', strNote = '', strTransactionType = 'Inventory', strStoredProcedure = 'uspTFGetInventoryTax', intSort = '30', intComponentTypeId = '1', intMasterId = 381667
 UNION ALL SELECT intReportingComponentId = 1665, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '1', strScheduleName = 'Gallons Received into Inventory, PA Tax Paid', strType = 'Liquid Fuels', strNote = '', strTransactionType = 'Inventory', strStoredProcedure = 'uspTFGetInventoryTax', intSort = '10', intComponentTypeId = '1', intMasterId = 381665
 UNION ALL SELECT intReportingComponentId = 1716, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '10', strScheduleName = 'Gallons Delivered to Other Exempt Entities, Tax Exempt', strType = 'Aviation Gas', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '640', intComponentTypeId = '1', intMasterId = 381716
 UNION ALL SELECT intReportingComponentId = 1714, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '10', strScheduleName = 'Gallons Delivered to Other Exempt Entities, Tax Exempt', strType = 'Fuels', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '620', intComponentTypeId = '1', intMasterId = 381714
 UNION ALL SELECT intReportingComponentId = 1715, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '10', strScheduleName = 'Gallons Delivered to Other Exempt Entities, Tax Exempt', strType = 'Jet Fuel', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '630', intComponentTypeId = '1', intMasterId = 381715
 UNION ALL SELECT intReportingComponentId = 1713, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '10', strScheduleName = 'Gallons Delivered to Other Exempt Entities, Tax Exempt', strType = 'Liquid Fuels', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '610', intComponentTypeId = '1', intMasterId = 381713
 UNION ALL SELECT intReportingComponentId = 1672, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '1F', strScheduleName = 'Gallons Received and Direct Shipped to Customers, PA Tax Paid', strType = 'Aviation Gas', strNote = '', strTransactionType = 'Inventory', strStoredProcedure = 'uspTFGetInventoryTax', intSort = '80', intComponentTypeId = '1', intMasterId = 381672
 UNION ALL SELECT intReportingComponentId = 1670, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '1F', strScheduleName = 'Gallons Received and Direct Shipped to Customers, PA Tax Paid', strType = 'Fuels', strNote = '', strTransactionType = 'Inventory', strStoredProcedure = 'uspTFGetInventoryTax', intSort = '60', intComponentTypeId = '1', intMasterId = 381670
 UNION ALL SELECT intReportingComponentId = 1671, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '1F', strScheduleName = 'Gallons Received and Direct Shipped to Customers, PA Tax Paid', strType = 'Jet Fuel', strNote = '', strTransactionType = 'Inventory', strStoredProcedure = 'uspTFGetInventoryTax', intSort = '70', intComponentTypeId = '1', intMasterId = 381671
 UNION ALL SELECT intReportingComponentId = 1669, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '1F', strScheduleName = 'Gallons Received and Direct Shipped to Customers, PA Tax Paid', strType = 'Liquid Fuels', strNote = '', strTransactionType = 'Inventory', strStoredProcedure = 'uspTFGetInventoryTax', intSort = '50', intComponentTypeId = '1', intMasterId = 381669
 UNION ALL SELECT intReportingComponentId = 1676, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '2', strScheduleName = 'Gallons Received into Inventory, PA Tax Unpaid', strType = 'Aviation Gas', strNote = '', strTransactionType = 'Inventory', strStoredProcedure = 'uspTFGetInventoryTax', intSort = '120', intComponentTypeId = '1', intMasterId = 381676
 UNION ALL SELECT intReportingComponentId = 1674, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '2', strScheduleName = 'Gallons Received into Inventory, PA Tax Unpaid', strType = 'Fuels', strNote = '', strTransactionType = 'Inventory', strStoredProcedure = 'uspTFGetInventoryTax', intSort = '100', intComponentTypeId = '1', intMasterId = 381674
 UNION ALL SELECT intReportingComponentId = 1675, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '2', strScheduleName = 'Gallons Received into Inventory, PA Tax Unpaid', strType = 'Jet Fuel', strNote = '', strTransactionType = 'Inventory', strStoredProcedure = 'uspTFGetInventoryTax', intSort = '110', intComponentTypeId = '1', intMasterId = 381675
 UNION ALL SELECT intReportingComponentId = 1673, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '2', strScheduleName = 'Gallons Received into Inventory, PA Tax Unpaid', strType = 'Liquid Fuels', strNote = '', strTransactionType = 'Inventory', strStoredProcedure = 'uspTFGetInventoryTax', intSort = '90', intComponentTypeId = '1', intMasterId = 381673
 UNION ALL SELECT intReportingComponentId = 1680, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '2F', strScheduleName = 'Gallons Received and Direct Shipped to Customers, PA Tax Unpaid', strType = 'Aviation Gas', strNote = '', strTransactionType = 'Inventory', strStoredProcedure = 'uspTFGetInventoryTax', intSort = '160', intComponentTypeId = '1', intMasterId = 381680
 UNION ALL SELECT intReportingComponentId = 1678, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '2F', strScheduleName = 'Gallons Received and Direct Shipped to Customers, PA Tax Unpaid', strType = 'Fuels', strNote = '', strTransactionType = 'Inventory', strStoredProcedure = 'uspTFGetInventoryTax', intSort = '140', intComponentTypeId = '1', intMasterId = 381678
 UNION ALL SELECT intReportingComponentId = 1679, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '2F', strScheduleName = 'Gallons Received and Direct Shipped to Customers, PA Tax Unpaid', strType = 'Jet Fuel', strNote = '', strTransactionType = 'Inventory', strStoredProcedure = 'uspTFGetInventoryTax', intSort = '150', intComponentTypeId = '1', intMasterId = 381679
 UNION ALL SELECT intReportingComponentId = 1677, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '2F', strScheduleName = 'Gallons Received and Direct Shipped to Customers, PA Tax Unpaid', strType = 'Liquid Fuels', strNote = '', strTransactionType = 'Inventory', strStoredProcedure = 'uspTFGetInventoryTax', intSort = '130', intComponentTypeId = '1', intMasterId = 381677
 UNION ALL SELECT intReportingComponentId = 1684, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '3', strScheduleName = 'Gallons Imported and Direct Shipped to PA Customers', strType = 'Aviation Gas', strNote = '', strTransactionType = 'Inventory', strStoredProcedure = 'uspTFGetInventoryTax', intSort = '200', intComponentTypeId = '1', intMasterId = 381684
 UNION ALL SELECT intReportingComponentId = 1682, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '3', strScheduleName = 'Gallons Imported and Direct Shipped to PA Customers', strType = 'Fuels', strNote = '', strTransactionType = 'Inventory', strStoredProcedure = 'uspTFGetInventoryTax', intSort = '180', intComponentTypeId = '1', intMasterId = 381682
 UNION ALL SELECT intReportingComponentId = 1683, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '3', strScheduleName = 'Gallons Imported and Direct Shipped to PA Customers', strType = 'Jet Fuel', strNote = '', strTransactionType = 'Inventory', strStoredProcedure = 'uspTFGetInventoryTax', intSort = '190', intComponentTypeId = '1', intMasterId = 381683
 UNION ALL SELECT intReportingComponentId = 1681, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '3', strScheduleName = 'Gallons Imported and Direct Shipped to PA Customers', strType = 'Liquid Fuels', strNote = '', strTransactionType = 'Inventory', strStoredProcedure = 'uspTFGetInventoryTax', intSort = '170', intComponentTypeId = '1', intMasterId = 381681
 UNION ALL SELECT intReportingComponentId = 1688, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '4', strScheduleName = 'Gallons Imported into Tax-Free Storage in PA', strType = 'Aviation Gas', strNote = '', strTransactionType = 'Inventory', strStoredProcedure = 'uspTFGetInventoryTax', intSort = '240', intComponentTypeId = '1', intMasterId = 381688
 UNION ALL SELECT intReportingComponentId = 1686, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '4', strScheduleName = 'Gallons Imported into Tax-Free Storage in PA', strType = 'Fuels', strNote = '', strTransactionType = 'Inventory', strStoredProcedure = 'uspTFGetInventoryTax', intSort = '220', intComponentTypeId = '1', intMasterId = 381686
 UNION ALL SELECT intReportingComponentId = 1687, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '4', strScheduleName = 'Gallons Imported into Tax-Free Storage in PA', strType = 'Jet Fuel', strNote = '', strTransactionType = 'Inventory', strStoredProcedure = 'uspTFGetInventoryTax', intSort = '230', intComponentTypeId = '1', intMasterId = 381687
 UNION ALL SELECT intReportingComponentId = 1685, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '4', strScheduleName = 'Gallons Imported into Tax-Free Storage in PA', strType = 'Liquid Fuels', strNote = '', strTransactionType = 'Inventory', strStoredProcedure = 'uspTFGetInventoryTax', intSort = '210', intComponentTypeId = '1', intMasterId = 381685
 UNION ALL SELECT intReportingComponentId = 1692, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '5', strScheduleName = 'Gallons Delivered, Tax Collected', strType = 'Aviation Gas', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '280', intComponentTypeId = '1', intMasterId = 381692
 UNION ALL SELECT intReportingComponentId = 1690, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '5', strScheduleName = 'Gallons Delivered, Tax Collected', strType = 'Fuels', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '260', intComponentTypeId = '1', intMasterId = 381690
 UNION ALL SELECT intReportingComponentId = 1691, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '5', strScheduleName = 'Gallons Delivered, Tax Collected', strType = 'Jet Fuel', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '270', intComponentTypeId = '1', intMasterId = 381691
 UNION ALL SELECT intReportingComponentId = 1689, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '5', strScheduleName = 'Gallons Delivered, Tax Collected', strType = 'Liquid Fuels', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '250', intComponentTypeId = '1', intMasterId = 381689
 UNION ALL SELECT intReportingComponentId = 1696, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '5Q', strScheduleName = 'Taxable Use', strType = 'Aviation Gas', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '320', intComponentTypeId = '1', intMasterId = 381696
 UNION ALL SELECT intReportingComponentId = 1694, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '5Q', strScheduleName = 'Taxable Use', strType = 'Fuels', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '300', intComponentTypeId = '1', intMasterId = 381694
 UNION ALL SELECT intReportingComponentId = 1695, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '5Q', strScheduleName = 'Taxable Use', strType = 'Jet Fuel', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '310', intComponentTypeId = '1', intMasterId = 381695
 UNION ALL SELECT intReportingComponentId = 1693, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '5Q', strScheduleName = 'Taxable Use', strType = 'Liquid Fuels', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '290', intComponentTypeId = '1', intMasterId = 381693
 UNION ALL SELECT intReportingComponentId = 1700, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '6', strScheduleName = 'Gallons Delivered to PA Distributors, Tax Not Collected', strType = 'Aviation Gas', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '360', intComponentTypeId = '1', intMasterId = 381700
 UNION ALL SELECT intReportingComponentId = 1698, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '6', strScheduleName = 'Gallons Delivered to PA Distributors, Tax Not Collected', strType = 'Fuels', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '340', intComponentTypeId = '1', intMasterId = 381698
 UNION ALL SELECT intReportingComponentId = 1699, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '6', strScheduleName = 'Gallons Delivered to PA Distributors, Tax Not Collected', strType = 'Jet Fuel', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '350', intComponentTypeId = '1', intMasterId = 381699
 UNION ALL SELECT intReportingComponentId = 1697, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '6', strScheduleName = 'Gallons Delivered to PA Distributors, Tax Not Collected', strType = 'Liquid Fuels', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '330', intComponentTypeId = '1', intMasterId = 381697
 UNION ALL SELECT intReportingComponentId = 1704, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '7', strScheduleName = 'Gallons Exported to __', strType = 'Aviation Gas', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '520', intComponentTypeId = '1', intMasterId = 381704
 UNION ALL SELECT intReportingComponentId = 1702, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '7', strScheduleName = 'Gallons Exported to __', strType = 'Fuels', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '420', intComponentTypeId = '1', intMasterId = 381702
 UNION ALL SELECT intReportingComponentId = 1703, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '7', strScheduleName = 'Gallons Exported to __', strType = 'Jet Fuel', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '470', intComponentTypeId = '1', intMasterId = 381703
 UNION ALL SELECT intReportingComponentId = 1701, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '7', strScheduleName = 'Gallons Exported to __', strType = 'Liquid Fuels', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '370', intComponentTypeId = '1', intMasterId = 381701
 UNION ALL SELECT intReportingComponentId = 1708, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '8', strScheduleName = 'Gallons Delivered to US Government, Tax Exempt', strType = 'Aviation Gas', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '560', intComponentTypeId = '1', intMasterId = 381708
 UNION ALL SELECT intReportingComponentId = 1706, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '8', strScheduleName = 'Gallons Delivered to US Government, Tax Exempt', strType = 'Fuels', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '540', intComponentTypeId = '1', intMasterId = 381706
 UNION ALL SELECT intReportingComponentId = 1707, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '8', strScheduleName = 'Gallons Delivered to US Government, Tax Exempt', strType = 'Jet Fuel', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '550', intComponentTypeId = '1', intMasterId = 381707
 UNION ALL SELECT intReportingComponentId = 1705, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '8', strScheduleName = 'Gallons Delivered to US Government, Tax Exempt', strType = 'Liquid Fuels', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '530', intComponentTypeId = '1', intMasterId = 381705
 UNION ALL SELECT intReportingComponentId = 1712, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '9', strScheduleName = 'Gallons Delivered to PA and Political Subs, Tax Exempt', strType = 'Aviation Gas', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '600', intComponentTypeId = '1', intMasterId = 381712
 UNION ALL SELECT intReportingComponentId = 1710, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '9', strScheduleName = 'Gallons Delivered to PA and Political Subs, Tax Exempt', strType = 'Fuels', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '580', intComponentTypeId = '1', intMasterId = 381710
 UNION ALL SELECT intReportingComponentId = 1711, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '9', strScheduleName = 'Gallons Delivered to PA and Political Subs, Tax Exempt', strType = 'Jet Fuel', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '590', intComponentTypeId = '1', intMasterId = 381711
 UNION ALL SELECT intReportingComponentId = 1709, strFormCode = '1096', strFormName = 'Motor Fuels Monthly Return', strScheduleCode = '9', strScheduleName = 'Gallons Delivered to PA and Political Subs, Tax Exempt', strType = 'Liquid Fuels', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetInvoiceTax', intSort = '570', intComponentTypeId = '1', intMasterId = 381709
 UNION ALL SELECT intReportingComponentId = 1717, strFormCode = 'DMF-26', strFormName = 'Carrier Monthly Return', strScheduleCode = '1A', strScheduleName = 'Deliveries Exported from PA', strType = '', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intSort = '700', intComponentTypeId = '1', intMasterId = 381717
 UNION ALL SELECT intReportingComponentId = 1718, strFormCode = 'DMF-26', strFormName = 'Carrier Monthly Return', strScheduleCode = '2A', strScheduleName = 'Deliveries Imported into PA', strType = '', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax', intSort = '710', intComponentTypeId = '1', intMasterId = 381718
 UNION ALL SELECT intReportingComponentId = 1719, strFormCode = 'DMF-26', strFormName = 'Carrier Monthly Return', strScheduleCode = '3A', strScheduleName = 'Intrastate Deliveries', strType = '', strNote = '', strTransactionType = 'Invoice', strStoredProcedure = 'uspTFGetTransporterCustomerInvoiceTax	', intSort = '720', intComponentTypeId = '1', intMasterId = 381719
 UNION ALL SELECT intReportingComponentId = 1720, strFormCode = 'PA Efile', strFormName = 'PA Electronic File', strScheduleCode = 'PA E File', strScheduleName = 'PA E File', strType = '', strNote = 'PA CSV File', strTransactionType = '', strStoredProcedure = '', intSort = '1000', intComponentTypeId = '4', intMasterId = 381720
 

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
	-- Insert generated script here. Remove first instance of "UNION ALL "
 SELECT intTaxCriteriaId = 547, strTaxCategory = 'PA Excise Tax Liquid Fuels (Gasoline and Gasohol)', strState = 'PA', strFormCode = '1096', strScheduleCode = '1', strType = 'Liquid Fuels', strCriteria = '<> 0', intMasterId = 38547
 UNION ALL SELECT intTaxCriteriaId = 548, strTaxCategory = 'PA Excise Tax Diesel Clear', strState = 'PA', strFormCode = '1096', strScheduleCode = '1', strType = 'Fuels', strCriteria = '<> 0', intMasterId = 38548
 UNION ALL SELECT intTaxCriteriaId = 549, strTaxCategory = 'PA Excise Tax Jet Fuel', strState = 'PA', strFormCode = '1096', strScheduleCode = '1', strType = 'Jet Fuel', strCriteria = '<> 0', intMasterId = 38549
 UNION ALL SELECT intTaxCriteriaId = 550, strTaxCategory = 'PA Excise Tax Aviation Gasoline', strState = 'PA', strFormCode = '1096', strScheduleCode = '1', strType = 'Aviation Gas', strCriteria = '<> 0', intMasterId = 38550
 UNION ALL SELECT intTaxCriteriaId = 551, strTaxCategory = 'PA Excise Tax Liquid Fuels (Gasoline and Gasohol)', strState = 'PA', strFormCode = '1096', strScheduleCode = '1F', strType = 'Liquid Fuels', strCriteria = '<> 0', intMasterId = 38551
 UNION ALL SELECT intTaxCriteriaId = 552, strTaxCategory = 'PA Excise Tax Diesel Clear', strState = 'PA', strFormCode = '1096', strScheduleCode = '1F', strType = 'Fuels', strCriteria = '<> 0', intMasterId = 38552
 UNION ALL SELECT intTaxCriteriaId = 553, strTaxCategory = 'PA Excise Tax Jet Fuel', strState = 'PA', strFormCode = '1096', strScheduleCode = '1F', strType = 'Jet Fuel', strCriteria = '<> 0', intMasterId = 38553
 UNION ALL SELECT intTaxCriteriaId = 554, strTaxCategory = 'PA Excise Tax Aviation Gasoline', strState = 'PA', strFormCode = '1096', strScheduleCode = '1F', strType = 'Aviation Gas', strCriteria = '<> 0', intMasterId = 38554
 UNION ALL SELECT intTaxCriteriaId = 555, strTaxCategory = 'PA Excise Tax Liquid Fuels (Gasoline and Gasohol)', strState = 'PA', strFormCode = '1096', strScheduleCode = '5', strType = 'Liquid Fuels', strCriteria = '<> 0', intMasterId = 38555
 UNION ALL SELECT intTaxCriteriaId = 556, strTaxCategory = 'PA Excise Tax Diesel Clear', strState = 'PA', strFormCode = '1096', strScheduleCode = '5', strType = 'Fuels', strCriteria = '<> 0', intMasterId = 38556
 UNION ALL SELECT intTaxCriteriaId = 557, strTaxCategory = 'PA Excise Tax Jet Fuel', strState = 'PA', strFormCode = '1096', strScheduleCode = '5', strType = 'Jet Fuel', strCriteria = '<> 0', intMasterId = 38557
 UNION ALL SELECT intTaxCriteriaId = 558, strTaxCategory = 'PA Excise Tax Aviation Gasoline', strState = 'PA', strFormCode = '1096', strScheduleCode = '5', strType = 'Aviation Gas', strCriteria = '<> 0', intMasterId = 38558
 UNION ALL SELECT intTaxCriteriaId = 559, strTaxCategory = 'PA Excise Tax Liquid Fuels (Gasoline and Gasohol)', strState = 'PA', strFormCode = '1096', strScheduleCode = '5Q', strType = 'Liquid Fuels', strCriteria = '<> 0', intMasterId = 38559
 UNION ALL SELECT intTaxCriteriaId = 560, strTaxCategory = 'PA Excise Tax Diesel Clear', strState = 'PA', strFormCode = '1096', strScheduleCode = '5Q', strType = 'Fuels', strCriteria = '<> 0', intMasterId = 38560
 UNION ALL SELECT intTaxCriteriaId = 561, strTaxCategory = 'PA Excise Tax Jet Fuel', strState = 'PA', strFormCode = '1096', strScheduleCode = '5Q', strType = 'Jet Fuel', strCriteria = '<> 0', intMasterId = 38561
 UNION ALL SELECT intTaxCriteriaId = 562, strTaxCategory = 'PA Excise Tax Aviation Gasoline', strState = 'PA', strFormCode = '1096', strScheduleCode = '5Q', strType = 'Aviation Gas', strCriteria = '<> 0', intMasterId = 38562
 UNION ALL SELECT intTaxCriteriaId = 563, strTaxCategory = 'PA Excise Tax Liquid Fuels (Gasoline and Gasohol)', strState = 'PA', strFormCode = '1096', strScheduleCode = '2', strType = 'Liquid Fuels', strCriteria = '= 0', intMasterId = 38563
 UNION ALL SELECT intTaxCriteriaId = 564, strTaxCategory = 'PA Excise Tax Diesel Clear', strState = 'PA', strFormCode = '1096', strScheduleCode = '2', strType = 'Fuels', strCriteria = '= 0', intMasterId = 38564
 UNION ALL SELECT intTaxCriteriaId = 565, strTaxCategory = 'PA Excise Tax Jet Fuel', strState = 'PA', strFormCode = '1096', strScheduleCode = '2', strType = 'Jet Fuel', strCriteria = '= 0', intMasterId = 38565
 UNION ALL SELECT intTaxCriteriaId = 566, strTaxCategory = 'PA Excise Tax Aviation Gasoline', strState = 'PA', strFormCode = '1096', strScheduleCode = '2', strType = 'Aviation Gas', strCriteria = '= 0', intMasterId = 38566
 UNION ALL SELECT intTaxCriteriaId = 567, strTaxCategory = 'PA Excise Tax Liquid Fuels (Gasoline and Gasohol)', strState = 'PA', strFormCode = '1096', strScheduleCode = '2F', strType = 'Liquid Fuels', strCriteria = '= 0', intMasterId = 38567
 UNION ALL SELECT intTaxCriteriaId = 568, strTaxCategory = 'PA Excise Tax Diesel Clear', strState = 'PA', strFormCode = '1096', strScheduleCode = '2F', strType = 'Fuels', strCriteria = '= 0', intMasterId = 38568
 UNION ALL SELECT intTaxCriteriaId = 569, strTaxCategory = 'PA Excise Tax Jet Fuel', strState = 'PA', strFormCode = '1096', strScheduleCode = '2F', strType = 'Jet Fuel', strCriteria = '= 0', intMasterId = 38569
 UNION ALL SELECT intTaxCriteriaId = 570, strTaxCategory = 'PA Excise Tax Aviation Gasoline', strState = 'PA', strFormCode = '1096', strScheduleCode = '2F', strType = 'Aviation Gas', strCriteria = '= 0', intMasterId = 38570
 UNION ALL SELECT intTaxCriteriaId = 571, strTaxCategory = 'PA Excise Tax Liquid Fuels (Gasoline and Gasohol)', strState = 'PA', strFormCode = '1096', strScheduleCode = '6', strType = 'Liquid Fuels', strCriteria = '= 0', intMasterId = 38571
 UNION ALL SELECT intTaxCriteriaId = 572, strTaxCategory = 'PA Excise Tax Diesel Clear', strState = 'PA', strFormCode = '1096', strScheduleCode = '6', strType = 'Fuels', strCriteria = '= 0', intMasterId = 38572
 UNION ALL SELECT intTaxCriteriaId = 573, strTaxCategory = 'PA Excise Tax Jet Fuel', strState = 'PA', strFormCode = '1096', strScheduleCode = '6', strType = 'Jet Fuel', strCriteria = '= 0', intMasterId = 38573
 UNION ALL SELECT intTaxCriteriaId = 574, strTaxCategory = 'PA Excise Tax Aviation Gasoline', strState = 'PA', strFormCode = '1096', strScheduleCode = '6', strType = 'Aviation Gas', strCriteria = '= 0', intMasterId = 38574
 UNION ALL SELECT intTaxCriteriaId = 575, strTaxCategory = 'PA Excise Tax Liquid Fuels (Gasoline and Gasohol)', strState = 'PA', strFormCode = '1096', strScheduleCode = '8', strType = 'Liquid Fuels', strCriteria = '= 0', intMasterId = 38575
 UNION ALL SELECT intTaxCriteriaId = 576, strTaxCategory = 'PA Excise Tax Diesel Clear', strState = 'PA', strFormCode = '1096', strScheduleCode = '8', strType = 'Fuels', strCriteria = '= 0', intMasterId = 38576
 UNION ALL SELECT intTaxCriteriaId = 577, strTaxCategory = 'PA Excise Tax Jet Fuel', strState = 'PA', strFormCode = '1096', strScheduleCode = '8', strType = 'Jet Fuel', strCriteria = '= 0', intMasterId = 38577
 UNION ALL SELECT intTaxCriteriaId = 578, strTaxCategory = 'PA Excise Tax Aviation Gasoline', strState = 'PA', strFormCode = '1096', strScheduleCode = '8', strType = 'Aviation Gas', strCriteria = '= 0', intMasterId = 38578
 UNION ALL SELECT intTaxCriteriaId = 579, strTaxCategory = 'PA Excise Tax Liquid Fuels (Gasoline and Gasohol)', strState = 'PA', strFormCode = '1096', strScheduleCode = '9', strType = 'Liquid Fuels', strCriteria = '= 0', intMasterId = 38579
 UNION ALL SELECT intTaxCriteriaId = 580, strTaxCategory = 'PA Excise Tax Diesel Clear', strState = 'PA', strFormCode = '1096', strScheduleCode = '9', strType = 'Fuels', strCriteria = '= 0', intMasterId = 38580
 UNION ALL SELECT intTaxCriteriaId = 581, strTaxCategory = 'PA Excise Tax Jet Fuel', strState = 'PA', strFormCode = '1096', strScheduleCode = '9', strType = 'Jet Fuel', strCriteria = '= 0', intMasterId = 38581
 UNION ALL SELECT intTaxCriteriaId = 582, strTaxCategory = 'PA Excise Tax Aviation Gasoline', strState = 'PA', strFormCode = '1096', strScheduleCode = '9', strType = 'Aviation Gas', strCriteria = '= 0', intMasterId = 38582
 UNION ALL SELECT intTaxCriteriaId = 583, strTaxCategory = 'PA Excise Tax Liquid Fuels (Gasoline and Gasohol)', strState = 'PA', strFormCode = '1096', strScheduleCode = '10', strType = 'Liquid Fuels', strCriteria = '= 0', intMasterId = 38583
 UNION ALL SELECT intTaxCriteriaId = 584, strTaxCategory = 'PA Excise Tax Diesel Clear', strState = 'PA', strFormCode = '1096', strScheduleCode = '10', strType = 'Fuels', strCriteria = '= 0', intMasterId = 38584
 UNION ALL SELECT intTaxCriteriaId = 585, strTaxCategory = 'PA Excise Tax Jet Fuel', strState = 'PA', strFormCode = '1096', strScheduleCode = '10', strType = 'Jet Fuel', strCriteria = '= 0', intMasterId = 38585
 UNION ALL SELECT intTaxCriteriaId = 586, strTaxCategory = 'PA Excise Tax Aviation Gasoline', strState = 'PA', strFormCode = '1096', strScheduleCode = '10', strType = 'Aviation Gas', strCriteria = '= 0', intMasterId = 38586
 

EXEC uspTFUpgradeTaxCriteria @TaxAuthorityCode = @TaxAuthorityCode, @TaxCriteria = @TaxCriteria

	-- Reporting Component - Base
	/* Generate script for Valid Product Codes. Specify Tax Authority Id to filter out specific Valid Product Codes only.
select strQuery = 'UNION ALL SELECT intValidProductCodeId = ' + CAST(intReportingComponentProductCodeId AS NVARCHAR(10))
		+ CASE WHEN PC.strProductCode IS NULL THEN ', strProductCode = NULL' ELSE ', strProductCode = ''' + PC.strProductCode + ''''  END
		+ CASE WHEN RC.strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
		+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
		+ CASE WHEN RC.strType IS NULL THEN ', strType = ''''' ELSE ', strType = ''' + RC.strType + '''' END
		+ ', intMasterId = ' + CASE WHEN RCPC.intMasterId IS NULL THEN CAST(38 AS NVARCHAR(20)) + CAST(intReportingComponentProductCodeId AS NVARCHAR(20)) ELSE CAST(RCPC.intMasterId AS NVARCHAR(20)) END
	from tblTFReportingComponentProductCode RCPC
	left join tblTFProductCode PC ON PC.intProductCodeId= RCPC.intProductCodeId
	left join tblTFReportingComponent RC ON RC.intReportingComponentId = RCPC.intReportingComponentId
	where RC.intTaxAuthorityId = 38
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
	-- Insert generated script here. Remove first instance of "UNION ALL "
 SELECT intValidProductCodeId = 7028, strProductCode = '125', strFormCode = '1096', strScheduleCode = '1', strType = 'Aviation Gas', intMasterId = 387028
 UNION ALL SELECT intValidProductCodeId = 7041, strProductCode = '142', strFormCode = '1096', strScheduleCode = '1', strType = 'Fuels', intMasterId = 387041
 UNION ALL SELECT intValidProductCodeId = 7042, strProductCode = '073', strFormCode = '1096', strScheduleCode = '1', strType = 'Fuels', intMasterId = 387042
 UNION ALL SELECT intValidProductCodeId = 7043, strProductCode = '160', strFormCode = '1096', strScheduleCode = '1', strType = 'Fuels', intMasterId = 387043
 UNION ALL SELECT intValidProductCodeId = 7044, strProductCode = '227', strFormCode = '1096', strScheduleCode = '1', strType = 'Fuels', intMasterId = 387044
 UNION ALL SELECT intValidProductCodeId = 7045, strProductCode = '170', strFormCode = '1096', strScheduleCode = '1', strType = 'Fuels', intMasterId = 387045
 UNION ALL SELECT intValidProductCodeId = 7015, strProductCode = '130', strFormCode = '1096', strScheduleCode = '1', strType = 'Jet Fuel', intMasterId = 387015
 UNION ALL SELECT intValidProductCodeId = 6976, strProductCode = '065', strFormCode = '1096', strScheduleCode = '1', strType = 'Liquid Fuels', intMasterId = 386976
 UNION ALL SELECT intValidProductCodeId = 6977, strProductCode = '124', strFormCode = '1096', strScheduleCode = '1', strType = 'Liquid Fuels', intMasterId = 386977
 UNION ALL SELECT intValidProductCodeId = 7002, strProductCode = '123', strFormCode = '1096', strScheduleCode = '1', strType = 'Liquid Fuels', intMasterId = 387002
 UNION ALL SELECT intValidProductCodeId = 7029, strProductCode = '125', strFormCode = '1096', strScheduleCode = '10', strType = 'Aviation Gas', intMasterId = 387029
 UNION ALL SELECT intValidProductCodeId = 7046, strProductCode = '142', strFormCode = '1096', strScheduleCode = '10', strType = 'Fuels', intMasterId = 387046
 UNION ALL SELECT intValidProductCodeId = 7047, strProductCode = '073', strFormCode = '1096', strScheduleCode = '10', strType = 'Fuels', intMasterId = 387047
 UNION ALL SELECT intValidProductCodeId = 7048, strProductCode = '160', strFormCode = '1096', strScheduleCode = '10', strType = 'Fuels', intMasterId = 387048
 UNION ALL SELECT intValidProductCodeId = 7049, strProductCode = '227', strFormCode = '1096', strScheduleCode = '10', strType = 'Fuels', intMasterId = 387049
 UNION ALL SELECT intValidProductCodeId = 7050, strProductCode = '170', strFormCode = '1096', strScheduleCode = '10', strType = 'Fuels', intMasterId = 387050
 UNION ALL SELECT intValidProductCodeId = 7016, strProductCode = '130', strFormCode = '1096', strScheduleCode = '10', strType = 'Jet Fuel', intMasterId = 387016
 UNION ALL SELECT intValidProductCodeId = 6978, strProductCode = '065', strFormCode = '1096', strScheduleCode = '10', strType = 'Liquid Fuels', intMasterId = 386978
 UNION ALL SELECT intValidProductCodeId = 6979, strProductCode = '124', strFormCode = '1096', strScheduleCode = '10', strType = 'Liquid Fuels', intMasterId = 386979
 UNION ALL SELECT intValidProductCodeId = 7003, strProductCode = '123', strFormCode = '1096', strScheduleCode = '10', strType = 'Liquid Fuels', intMasterId = 387003
 UNION ALL SELECT intValidProductCodeId = 7030, strProductCode = '125', strFormCode = '1096', strScheduleCode = '1F', strType = 'Aviation Gas', intMasterId = 387030
 UNION ALL SELECT intValidProductCodeId = 7051, strProductCode = '142', strFormCode = '1096', strScheduleCode = '1F', strType = 'Fuels', intMasterId = 387051
 UNION ALL SELECT intValidProductCodeId = 7052, strProductCode = '073', strFormCode = '1096', strScheduleCode = '1F', strType = 'Fuels', intMasterId = 387052
 UNION ALL SELECT intValidProductCodeId = 7053, strProductCode = '160', strFormCode = '1096', strScheduleCode = '1F', strType = 'Fuels', intMasterId = 387053
 UNION ALL SELECT intValidProductCodeId = 7054, strProductCode = '227', strFormCode = '1096', strScheduleCode = '1F', strType = 'Fuels', intMasterId = 387054
 UNION ALL SELECT intValidProductCodeId = 7055, strProductCode = '170', strFormCode = '1096', strScheduleCode = '1F', strType = 'Fuels', intMasterId = 387055
 UNION ALL SELECT intValidProductCodeId = 7017, strProductCode = '130', strFormCode = '1096', strScheduleCode = '1F', strType = 'Jet Fuel', intMasterId = 387017
 UNION ALL SELECT intValidProductCodeId = 6980, strProductCode = '065', strFormCode = '1096', strScheduleCode = '1F', strType = 'Liquid Fuels', intMasterId = 386980
 UNION ALL SELECT intValidProductCodeId = 6981, strProductCode = '124', strFormCode = '1096', strScheduleCode = '1F', strType = 'Liquid Fuels', intMasterId = 386981
 UNION ALL SELECT intValidProductCodeId = 7004, strProductCode = '123', strFormCode = '1096', strScheduleCode = '1F', strType = 'Liquid Fuels', intMasterId = 387004
 UNION ALL SELECT intValidProductCodeId = 7031, strProductCode = '125', strFormCode = '1096', strScheduleCode = '2', strType = 'Aviation Gas', intMasterId = 387031
 UNION ALL SELECT intValidProductCodeId = 7056, strProductCode = '142', strFormCode = '1096', strScheduleCode = '2', strType = 'Fuels', intMasterId = 387056
 UNION ALL SELECT intValidProductCodeId = 7057, strProductCode = '073', strFormCode = '1096', strScheduleCode = '2', strType = 'Fuels', intMasterId = 387057
 UNION ALL SELECT intValidProductCodeId = 7058, strProductCode = '160', strFormCode = '1096', strScheduleCode = '2', strType = 'Fuels', intMasterId = 387058
 UNION ALL SELECT intValidProductCodeId = 7059, strProductCode = '227', strFormCode = '1096', strScheduleCode = '2', strType = 'Fuels', intMasterId = 387059
 UNION ALL SELECT intValidProductCodeId = 7060, strProductCode = '170', strFormCode = '1096', strScheduleCode = '2', strType = 'Fuels', intMasterId = 387060
 UNION ALL SELECT intValidProductCodeId = 7018, strProductCode = '130', strFormCode = '1096', strScheduleCode = '2', strType = 'Jet Fuel', intMasterId = 387018
 UNION ALL SELECT intValidProductCodeId = 6982, strProductCode = '065', strFormCode = '1096', strScheduleCode = '2', strType = 'Liquid Fuels', intMasterId = 386982
 UNION ALL SELECT intValidProductCodeId = 6983, strProductCode = '124', strFormCode = '1096', strScheduleCode = '2', strType = 'Liquid Fuels', intMasterId = 386983
 UNION ALL SELECT intValidProductCodeId = 7005, strProductCode = '123', strFormCode = '1096', strScheduleCode = '2', strType = 'Liquid Fuels', intMasterId = 387005
 UNION ALL SELECT intValidProductCodeId = 7032, strProductCode = '125', strFormCode = '1096', strScheduleCode = '2F', strType = 'Aviation Gas', intMasterId = 387032
 UNION ALL SELECT intValidProductCodeId = 7061, strProductCode = '142', strFormCode = '1096', strScheduleCode = '2F', strType = 'Fuels', intMasterId = 387061
 UNION ALL SELECT intValidProductCodeId = 7062, strProductCode = '073', strFormCode = '1096', strScheduleCode = '2F', strType = 'Fuels', intMasterId = 387062
 UNION ALL SELECT intValidProductCodeId = 7063, strProductCode = '160', strFormCode = '1096', strScheduleCode = '2F', strType = 'Fuels', intMasterId = 387063
 UNION ALL SELECT intValidProductCodeId = 7064, strProductCode = '227', strFormCode = '1096', strScheduleCode = '2F', strType = 'Fuels', intMasterId = 387064
 UNION ALL SELECT intValidProductCodeId = 7065, strProductCode = '170', strFormCode = '1096', strScheduleCode = '2F', strType = 'Fuels', intMasterId = 387065
 UNION ALL SELECT intValidProductCodeId = 7019, strProductCode = '130', strFormCode = '1096', strScheduleCode = '2F', strType = 'Jet Fuel', intMasterId = 387019
 UNION ALL SELECT intValidProductCodeId = 6984, strProductCode = '065', strFormCode = '1096', strScheduleCode = '2F', strType = 'Liquid Fuels', intMasterId = 386984
 UNION ALL SELECT intValidProductCodeId = 6985, strProductCode = '124', strFormCode = '1096', strScheduleCode = '2F', strType = 'Liquid Fuels', intMasterId = 386985
 UNION ALL SELECT intValidProductCodeId = 7006, strProductCode = '123', strFormCode = '1096', strScheduleCode = '2F', strType = 'Liquid Fuels', intMasterId = 387006
 UNION ALL SELECT intValidProductCodeId = 7033, strProductCode = '125', strFormCode = '1096', strScheduleCode = '3', strType = 'Aviation Gas', intMasterId = 387033
 UNION ALL SELECT intValidProductCodeId = 7066, strProductCode = '142', strFormCode = '1096', strScheduleCode = '3', strType = 'Fuels', intMasterId = 387066
 UNION ALL SELECT intValidProductCodeId = 7067, strProductCode = '073', strFormCode = '1096', strScheduleCode = '3', strType = 'Fuels', intMasterId = 387067
 UNION ALL SELECT intValidProductCodeId = 7068, strProductCode = '160', strFormCode = '1096', strScheduleCode = '3', strType = 'Fuels', intMasterId = 387068
 UNION ALL SELECT intValidProductCodeId = 7069, strProductCode = '227', strFormCode = '1096', strScheduleCode = '3', strType = 'Fuels', intMasterId = 387069
 UNION ALL SELECT intValidProductCodeId = 7070, strProductCode = '170', strFormCode = '1096', strScheduleCode = '3', strType = 'Fuels', intMasterId = 387070
 UNION ALL SELECT intValidProductCodeId = 7020, strProductCode = '130', strFormCode = '1096', strScheduleCode = '3', strType = 'Jet Fuel', intMasterId = 387020
 UNION ALL SELECT intValidProductCodeId = 6986, strProductCode = '065', strFormCode = '1096', strScheduleCode = '3', strType = 'Liquid Fuels', intMasterId = 386986
 UNION ALL SELECT intValidProductCodeId = 6987, strProductCode = '124', strFormCode = '1096', strScheduleCode = '3', strType = 'Liquid Fuels', intMasterId = 386987
 UNION ALL SELECT intValidProductCodeId = 7007, strProductCode = '123', strFormCode = '1096', strScheduleCode = '3', strType = 'Liquid Fuels', intMasterId = 387007
 UNION ALL SELECT intValidProductCodeId = 7034, strProductCode = '125', strFormCode = '1096', strScheduleCode = '4', strType = 'Aviation Gas', intMasterId = 387034
 UNION ALL SELECT intValidProductCodeId = 7071, strProductCode = '142', strFormCode = '1096', strScheduleCode = '4', strType = 'Fuels', intMasterId = 387071
 UNION ALL SELECT intValidProductCodeId = 7072, strProductCode = '073', strFormCode = '1096', strScheduleCode = '4', strType = 'Fuels', intMasterId = 387072
 UNION ALL SELECT intValidProductCodeId = 7073, strProductCode = '160', strFormCode = '1096', strScheduleCode = '4', strType = 'Fuels', intMasterId = 387073
 UNION ALL SELECT intValidProductCodeId = 7074, strProductCode = '227', strFormCode = '1096', strScheduleCode = '4', strType = 'Fuels', intMasterId = 387074
 UNION ALL SELECT intValidProductCodeId = 7075, strProductCode = '170', strFormCode = '1096', strScheduleCode = '4', strType = 'Fuels', intMasterId = 387075
 UNION ALL SELECT intValidProductCodeId = 7021, strProductCode = '130', strFormCode = '1096', strScheduleCode = '4', strType = 'Jet Fuel', intMasterId = 387021
 UNION ALL SELECT intValidProductCodeId = 6988, strProductCode = '065', strFormCode = '1096', strScheduleCode = '4', strType = 'Liquid Fuels', intMasterId = 386988
 UNION ALL SELECT intValidProductCodeId = 6989, strProductCode = '124', strFormCode = '1096', strScheduleCode = '4', strType = 'Liquid Fuels', intMasterId = 386989
 UNION ALL SELECT intValidProductCodeId = 7008, strProductCode = '123', strFormCode = '1096', strScheduleCode = '4', strType = 'Liquid Fuels', intMasterId = 387008
 UNION ALL SELECT intValidProductCodeId = 7035, strProductCode = '125', strFormCode = '1096', strScheduleCode = '5', strType = 'Aviation Gas', intMasterId = 387035
 UNION ALL SELECT intValidProductCodeId = 7076, strProductCode = '142', strFormCode = '1096', strScheduleCode = '5', strType = 'Fuels', intMasterId = 387076
 UNION ALL SELECT intValidProductCodeId = 7077, strProductCode = '073', strFormCode = '1096', strScheduleCode = '5', strType = 'Fuels', intMasterId = 387077
 UNION ALL SELECT intValidProductCodeId = 7078, strProductCode = '160', strFormCode = '1096', strScheduleCode = '5', strType = 'Fuels', intMasterId = 387078
 UNION ALL SELECT intValidProductCodeId = 7079, strProductCode = '227', strFormCode = '1096', strScheduleCode = '5', strType = 'Fuels', intMasterId = 387079
 UNION ALL SELECT intValidProductCodeId = 7080, strProductCode = '170', strFormCode = '1096', strScheduleCode = '5', strType = 'Fuels', intMasterId = 387080
 UNION ALL SELECT intValidProductCodeId = 7022, strProductCode = '130', strFormCode = '1096', strScheduleCode = '5', strType = 'Jet Fuel', intMasterId = 387022
 UNION ALL SELECT intValidProductCodeId = 6990, strProductCode = '065', strFormCode = '1096', strScheduleCode = '5', strType = 'Liquid Fuels', intMasterId = 386990
 UNION ALL SELECT intValidProductCodeId = 6991, strProductCode = '124', strFormCode = '1096', strScheduleCode = '5', strType = 'Liquid Fuels', intMasterId = 386991
 UNION ALL SELECT intValidProductCodeId = 7009, strProductCode = '123', strFormCode = '1096', strScheduleCode = '5', strType = 'Liquid Fuels', intMasterId = 387009
 UNION ALL SELECT intValidProductCodeId = 7036, strProductCode = '125', strFormCode = '1096', strScheduleCode = '5Q', strType = 'Aviation Gas', intMasterId = 387036
 UNION ALL SELECT intValidProductCodeId = 7081, strProductCode = '142', strFormCode = '1096', strScheduleCode = '5Q', strType = 'Fuels', intMasterId = 387081
 UNION ALL SELECT intValidProductCodeId = 7082, strProductCode = '073', strFormCode = '1096', strScheduleCode = '5Q', strType = 'Fuels', intMasterId = 387082
 UNION ALL SELECT intValidProductCodeId = 7083, strProductCode = '160', strFormCode = '1096', strScheduleCode = '5Q', strType = 'Fuels', intMasterId = 387083
 UNION ALL SELECT intValidProductCodeId = 7084, strProductCode = '227', strFormCode = '1096', strScheduleCode = '5Q', strType = 'Fuels', intMasterId = 387084
 UNION ALL SELECT intValidProductCodeId = 7085, strProductCode = '170', strFormCode = '1096', strScheduleCode = '5Q', strType = 'Fuels', intMasterId = 387085
 UNION ALL SELECT intValidProductCodeId = 7023, strProductCode = '130', strFormCode = '1096', strScheduleCode = '5Q', strType = 'Jet Fuel', intMasterId = 387023
 UNION ALL SELECT intValidProductCodeId = 6992, strProductCode = '065', strFormCode = '1096', strScheduleCode = '5Q', strType = 'Liquid Fuels', intMasterId = 386992
 UNION ALL SELECT intValidProductCodeId = 6993, strProductCode = '124', strFormCode = '1096', strScheduleCode = '5Q', strType = 'Liquid Fuels', intMasterId = 386993
 UNION ALL SELECT intValidProductCodeId = 7010, strProductCode = '123', strFormCode = '1096', strScheduleCode = '5Q', strType = 'Liquid Fuels', intMasterId = 387010
 UNION ALL SELECT intValidProductCodeId = 7037, strProductCode = '125', strFormCode = '1096', strScheduleCode = '6', strType = 'Aviation Gas', intMasterId = 387037
 UNION ALL SELECT intValidProductCodeId = 7086, strProductCode = '142', strFormCode = '1096', strScheduleCode = '6', strType = 'Fuels', intMasterId = 387086
 UNION ALL SELECT intValidProductCodeId = 7087, strProductCode = '073', strFormCode = '1096', strScheduleCode = '6', strType = 'Fuels', intMasterId = 387087
 UNION ALL SELECT intValidProductCodeId = 7088, strProductCode = '160', strFormCode = '1096', strScheduleCode = '6', strType = 'Fuels', intMasterId = 387088
 UNION ALL SELECT intValidProductCodeId = 7089, strProductCode = '227', strFormCode = '1096', strScheduleCode = '6', strType = 'Fuels', intMasterId = 387089
 UNION ALL SELECT intValidProductCodeId = 7090, strProductCode = '170', strFormCode = '1096', strScheduleCode = '6', strType = 'Fuels', intMasterId = 387090
 UNION ALL SELECT intValidProductCodeId = 7024, strProductCode = '130', strFormCode = '1096', strScheduleCode = '6', strType = 'Jet Fuel', intMasterId = 387024
 UNION ALL SELECT intValidProductCodeId = 6994, strProductCode = '065', strFormCode = '1096', strScheduleCode = '6', strType = 'Liquid Fuels', intMasterId = 386994
 UNION ALL SELECT intValidProductCodeId = 6995, strProductCode = '124', strFormCode = '1096', strScheduleCode = '6', strType = 'Liquid Fuels', intMasterId = 386995
 UNION ALL SELECT intValidProductCodeId = 7011, strProductCode = '123', strFormCode = '1096', strScheduleCode = '6', strType = 'Liquid Fuels', intMasterId = 387011
 UNION ALL SELECT intValidProductCodeId = 7038, strProductCode = '125', strFormCode = '1096', strScheduleCode = '7', strType = 'Aviation Gas', intMasterId = 387038
 UNION ALL SELECT intValidProductCodeId = 7091, strProductCode = '142', strFormCode = '1096', strScheduleCode = '7', strType = 'Fuels', intMasterId = 387091
 UNION ALL SELECT intValidProductCodeId = 7092, strProductCode = '073', strFormCode = '1096', strScheduleCode = '7', strType = 'Fuels', intMasterId = 387092
 UNION ALL SELECT intValidProductCodeId = 7093, strProductCode = '160', strFormCode = '1096', strScheduleCode = '7', strType = 'Fuels', intMasterId = 387093
 UNION ALL SELECT intValidProductCodeId = 7094, strProductCode = '227', strFormCode = '1096', strScheduleCode = '7', strType = 'Fuels', intMasterId = 387094
 UNION ALL SELECT intValidProductCodeId = 7095, strProductCode = '170', strFormCode = '1096', strScheduleCode = '7', strType = 'Fuels', intMasterId = 387095
 UNION ALL SELECT intValidProductCodeId = 7025, strProductCode = '130', strFormCode = '1096', strScheduleCode = '7', strType = 'Jet Fuel', intMasterId = 387025
 UNION ALL SELECT intValidProductCodeId = 6996, strProductCode = '065', strFormCode = '1096', strScheduleCode = '7', strType = 'Liquid Fuels', intMasterId = 386996
 UNION ALL SELECT intValidProductCodeId = 6997, strProductCode = '124', strFormCode = '1096', strScheduleCode = '7', strType = 'Liquid Fuels', intMasterId = 386997
 UNION ALL SELECT intValidProductCodeId = 7012, strProductCode = '123', strFormCode = '1096', strScheduleCode = '7', strType = 'Liquid Fuels', intMasterId = 387012
 UNION ALL SELECT intValidProductCodeId = 7039, strProductCode = '125', strFormCode = '1096', strScheduleCode = '8', strType = 'Aviation Gas', intMasterId = 387039
 UNION ALL SELECT intValidProductCodeId = 7096, strProductCode = '142', strFormCode = '1096', strScheduleCode = '8', strType = 'Fuels', intMasterId = 387096
 UNION ALL SELECT intValidProductCodeId = 7097, strProductCode = '073', strFormCode = '1096', strScheduleCode = '8', strType = 'Fuels', intMasterId = 387097
 UNION ALL SELECT intValidProductCodeId = 7098, strProductCode = '160', strFormCode = '1096', strScheduleCode = '8', strType = 'Fuels', intMasterId = 387098
 UNION ALL SELECT intValidProductCodeId = 7099, strProductCode = '227', strFormCode = '1096', strScheduleCode = '8', strType = 'Fuels', intMasterId = 387099
 UNION ALL SELECT intValidProductCodeId = 7100, strProductCode = '170', strFormCode = '1096', strScheduleCode = '8', strType = 'Fuels', intMasterId = 387100
 UNION ALL SELECT intValidProductCodeId = 7026, strProductCode = '130', strFormCode = '1096', strScheduleCode = '8', strType = 'Jet Fuel', intMasterId = 387026
 UNION ALL SELECT intValidProductCodeId = 6998, strProductCode = '065', strFormCode = '1096', strScheduleCode = '8', strType = 'Liquid Fuels', intMasterId = 386998
 UNION ALL SELECT intValidProductCodeId = 6999, strProductCode = '124', strFormCode = '1096', strScheduleCode = '8', strType = 'Liquid Fuels', intMasterId = 386999
 UNION ALL SELECT intValidProductCodeId = 7013, strProductCode = '123', strFormCode = '1096', strScheduleCode = '8', strType = 'Liquid Fuels', intMasterId = 387013
 UNION ALL SELECT intValidProductCodeId = 7040, strProductCode = '125', strFormCode = '1096', strScheduleCode = '9', strType = 'Aviation Gas', intMasterId = 387040
 UNION ALL SELECT intValidProductCodeId = 7101, strProductCode = '142', strFormCode = '1096', strScheduleCode = '9', strType = 'Fuels', intMasterId = 387101
 UNION ALL SELECT intValidProductCodeId = 7102, strProductCode = '073', strFormCode = '1096', strScheduleCode = '9', strType = 'Fuels', intMasterId = 387102
 UNION ALL SELECT intValidProductCodeId = 7103, strProductCode = '160', strFormCode = '1096', strScheduleCode = '9', strType = 'Fuels', intMasterId = 387103
 UNION ALL SELECT intValidProductCodeId = 7104, strProductCode = '227', strFormCode = '1096', strScheduleCode = '9', strType = 'Fuels', intMasterId = 387104
 UNION ALL SELECT intValidProductCodeId = 7105, strProductCode = '170', strFormCode = '1096', strScheduleCode = '9', strType = 'Fuels', intMasterId = 387105
 UNION ALL SELECT intValidProductCodeId = 7027, strProductCode = '130', strFormCode = '1096', strScheduleCode = '9', strType = 'Jet Fuel', intMasterId = 387027
 UNION ALL SELECT intValidProductCodeId = 7000, strProductCode = '065', strFormCode = '1096', strScheduleCode = '9', strType = 'Liquid Fuels', intMasterId = 387000
 UNION ALL SELECT intValidProductCodeId = 7001, strProductCode = '124', strFormCode = '1096', strScheduleCode = '9', strType = 'Liquid Fuels', intMasterId = 387001
 UNION ALL SELECT intValidProductCodeId = 7014, strProductCode = '123', strFormCode = '1096', strScheduleCode = '9', strType = 'Liquid Fuels', intMasterId = 387014
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', intMasterId = 387106
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', intMasterId = 387107
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', intMasterId = 387108
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', intMasterId = 387109
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', intMasterId = 387110
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', intMasterId = 387111
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', intMasterId = 387112
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', intMasterId = 387113
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', intMasterId = 387114
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', intMasterId = 387115
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', intMasterId = 387116
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', intMasterId = 387117
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', intMasterId = 387118
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', intMasterId = 387119
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', intMasterId = 387120
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', intMasterId = 387121
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', intMasterId = 387122
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', intMasterId = 387123
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', intMasterId = 387124
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', intMasterId = 387125
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '065', strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', intMasterId = 387126
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '073', strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', intMasterId = 387127
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '123', strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', intMasterId = 387128
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '124', strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', intMasterId = 387129
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '125', strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', intMasterId = 387130
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '130', strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', intMasterId = 387131
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '142', strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', intMasterId = 387132
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '160', strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', intMasterId = 387133
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '170', strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', intMasterId = 387134
 UNION ALL SELECT intValidProductCodeId = 0, strProductCode = '227', strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', intMasterId = 387135

EXEC uspTFUpgradeValidProductCodes @TaxAuthorityCode = @TaxAuthorityCode, @ValidProductCodes = @ValidProductCodes

	/* Generate script for Valid Origin States. Specify Tax Authority Id to filter out specific Valid Origin States only.
select strQuery = 'UNION ALL SELECT intValidOriginStateId = ' + CAST(intReportingComponentOriginStateId AS NVARCHAR(10))
		+ CASE WHEN RC.strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + RC.strFormCode + ''''  END
		+ CASE WHEN RC.strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + RC.strScheduleCode + ''''  END
		+ CASE WHEN RC.strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + RC.strType + '''' END
		+ CASE WHEN ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS IS NULL THEN ', strState = NULL' ELSE ', strState = ''' + ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS + ''''  END
		+ CASE WHEN RCOS.strType IS NULL THEN ', strStatus = NULL' ELSE ', strStatus = ''' + RCOS.strType + ''''  END
		+ ', intMasterId = ' + CASE WHEN RCOS.intMasterId IS NULL THEN CAST(38 AS NVARCHAR(20)) + CAST(intReportingComponentOriginStateId AS NVARCHAR(20)) ELSE CAST(RCOS.intMasterId AS NVARCHAR(20)) END
	from tblTFReportingComponentOriginState RCOS
	left join tblTFOriginDestinationState ODS ON ODS.intOriginDestinationStateId= RCOS.intOriginDestinationStateId
	left join tblTFReportingComponent RC ON RC.intReportingComponentId = RCOS.intReportingComponentId
	where RC.intTaxAuthorityId = 38
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
	-- Insert generated script here. Remove first instance of "UNION ALL "
 SELECT intValidOriginStateId = 579, strFormCode = '1096', strScheduleCode = '1', strType = 'Aviation Gas', strState = 'PA', strStatus = 'Include', intMasterId = 38579
 UNION ALL SELECT intValidOriginStateId = 577, strFormCode = '1096', strScheduleCode = '1', strType = 'Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38577
 UNION ALL SELECT intValidOriginStateId = 578, strFormCode = '1096', strScheduleCode = '1', strType = 'Jet Fuel', strState = 'PA', strStatus = 'Include', intMasterId = 38578
 UNION ALL SELECT intValidOriginStateId = 576, strFormCode = '1096', strScheduleCode = '1', strType = 'Liquid Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38576
 UNION ALL SELECT intValidOriginStateId = 583, strFormCode = '1096', strScheduleCode = '1F', strType = 'Aviation Gas', strState = 'PA', strStatus = 'Include', intMasterId = 38583
 UNION ALL SELECT intValidOriginStateId = 581, strFormCode = '1096', strScheduleCode = '1F', strType = 'Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38581
 UNION ALL SELECT intValidOriginStateId = 582, strFormCode = '1096', strScheduleCode = '1F', strType = 'Jet Fuel', strState = 'PA', strStatus = 'Include', intMasterId = 38582
 UNION ALL SELECT intValidOriginStateId = 580, strFormCode = '1096', strScheduleCode = '1F', strType = 'Liquid Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38580
 UNION ALL SELECT intValidOriginStateId = 587, strFormCode = '1096', strScheduleCode = '2', strType = 'Aviation Gas', strState = 'PA', strStatus = 'Include', intMasterId = 38587
 UNION ALL SELECT intValidOriginStateId = 585, strFormCode = '1096', strScheduleCode = '2', strType = 'Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38585
 UNION ALL SELECT intValidOriginStateId = 586, strFormCode = '1096', strScheduleCode = '2', strType = 'Jet Fuel', strState = 'PA', strStatus = 'Include', intMasterId = 38586
 UNION ALL SELECT intValidOriginStateId = 584, strFormCode = '1096', strScheduleCode = '2', strType = 'Liquid Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38584
 UNION ALL SELECT intValidOriginStateId = 591, strFormCode = '1096', strScheduleCode = '2F', strType = 'Aviation Gas', strState = 'PA', strStatus = 'Include', intMasterId = 38591
 UNION ALL SELECT intValidOriginStateId = 589, strFormCode = '1096', strScheduleCode = '2F', strType = 'Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38589
 UNION ALL SELECT intValidOriginStateId = 590, strFormCode = '1096', strScheduleCode = '2F', strType = 'Jet Fuel', strState = 'PA', strStatus = 'Include', intMasterId = 38590
 UNION ALL SELECT intValidOriginStateId = 588, strFormCode = '1096', strScheduleCode = '2F', strType = 'Liquid Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38588
 UNION ALL SELECT intValidOriginStateId = 595, strFormCode = '1096', strScheduleCode = '3', strType = 'Aviation Gas', strState = 'PA', strStatus = 'Exclude', intMasterId = 38595
 UNION ALL SELECT intValidOriginStateId = 593, strFormCode = '1096', strScheduleCode = '3', strType = 'Fuels', strState = 'PA', strStatus = 'Exclude', intMasterId = 38593
 UNION ALL SELECT intValidOriginStateId = 594, strFormCode = '1096', strScheduleCode = '3', strType = 'Jet Fuel', strState = 'PA', strStatus = 'Exclude', intMasterId = 38594
 UNION ALL SELECT intValidOriginStateId = 592, strFormCode = '1096', strScheduleCode = '3', strType = 'Liquid Fuels', strState = 'PA', strStatus = 'Exclude', intMasterId = 38592
 UNION ALL SELECT intValidOriginStateId = 599, strFormCode = '1096', strScheduleCode = '4', strType = 'Aviation Gas', strState = 'PA', strStatus = 'Exclude', intMasterId = 38599
 UNION ALL SELECT intValidOriginStateId = 597, strFormCode = '1096', strScheduleCode = '4', strType = 'Fuels', strState = 'PA', strStatus = 'Exclude', intMasterId = 38597
 UNION ALL SELECT intValidOriginStateId = 598, strFormCode = '1096', strScheduleCode = '4', strType = 'Jet Fuel', strState = 'PA', strStatus = 'Exclude', intMasterId = 38598
 UNION ALL SELECT intValidOriginStateId = 596, strFormCode = '1096', strScheduleCode = '4', strType = 'Liquid Fuels', strState = 'PA', strStatus = 'Exclude', intMasterId = 38596
 UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', strState = 'PA', strStatus = 'Include', intMasterId = 38600
 UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', strState = 'PA', strStatus = 'Exclude', intMasterId = 38601
 UNION ALL SELECT intValidOriginStateId = 0, strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', strState = 'PA', strStatus = 'Include', intMasterId = 38602

EXEC uspTFUpgradeValidOriginStates @TaxAuthorityCode = @TaxAuthorityCode, @ValidOriginStates = @ValidOriginStates

	/* Generate script for Valid Destination States. Specify Tax Authority Id to filter out specific Valid Destination States only.
select strQuery = 'UNION ALL SELECT intValidDestinationStateId = ' + CAST(intReportingComponentDestinationStateId AS NVARCHAR(10))
		+ CASE WHEN RC.strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + RC.strFormCode + ''''  END
		+ CASE WHEN RC.strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + RC.strScheduleCode + ''''  END
		+ CASE WHEN RC.strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + RC.strType + '''' END
		+ CASE WHEN ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS IS NULL THEN ', strState = NULL' ELSE ', strState = ''' + ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS + ''''  END
		+ CASE WHEN RCDS.strType IS NULL THEN ', strStatus = NULL' ELSE ', strStatus = ''' + RCDS.strType + ''''  END
		+ ', intMasterId = ' + CASE WHEN RCDS.intMasterId IS NULL THEN CAST(38 AS NVARCHAR(20)) + CAST(intReportingComponentDestinationStateId AS NVARCHAR(20)) ELSE CAST(RCDS.intMasterId AS NVARCHAR(20)) END
	from tblTFReportingComponentDestinationState RCDS
	left join tblTFOriginDestinationState ODS ON ODS.intOriginDestinationStateId= RCDS.intOriginDestinationStateId
	left join tblTFReportingComponent RC ON RC.intReportingComponentId = RCDS.intReportingComponentId
	where RC.intTaxAuthorityId = 38
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
	
	-- Insert generated script here. Remove first instance of "UNION ALL "
 SELECT intValidDestinationStateId = 601, strFormCode = '1096', strScheduleCode = '1', strType = 'Aviation Gas', strState = 'PA', strStatus = 'Include', intMasterId = 38601
 UNION ALL SELECT intValidDestinationStateId = 599, strFormCode = '1096', strScheduleCode = '1', strType = 'Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38599
 UNION ALL SELECT intValidDestinationStateId = 600, strFormCode = '1096', strScheduleCode = '1', strType = 'Jet Fuel', strState = 'PA', strStatus = 'Include', intMasterId = 38600
 UNION ALL SELECT intValidDestinationStateId = 598, strFormCode = '1096', strScheduleCode = '1', strType = 'Liquid Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38598
 UNION ALL SELECT intValidDestinationStateId = 637, strFormCode = '1096', strScheduleCode = '10', strType = 'Aviation Gas', strState = 'PA', strStatus = 'Include', intMasterId = 38637
 UNION ALL SELECT intValidDestinationStateId = 635, strFormCode = '1096', strScheduleCode = '10', strType = 'Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38635
 UNION ALL SELECT intValidDestinationStateId = 636, strFormCode = '1096', strScheduleCode = '10', strType = 'Jet Fuel', strState = 'PA', strStatus = 'Include', intMasterId = 38636
 UNION ALL SELECT intValidDestinationStateId = 634, strFormCode = '1096', strScheduleCode = '10', strType = 'Liquid Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38634
 UNION ALL SELECT intValidDestinationStateId = 605, strFormCode = '1096', strScheduleCode = '1F', strType = 'Aviation Gas', strState = 'PA', strStatus = 'Include', intMasterId = 38605
 UNION ALL SELECT intValidDestinationStateId = 603, strFormCode = '1096', strScheduleCode = '1F', strType = 'Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38603
 UNION ALL SELECT intValidDestinationStateId = 604, strFormCode = '1096', strScheduleCode = '1F', strType = 'Jet Fuel', strState = 'PA', strStatus = 'Include', intMasterId = 38604
 UNION ALL SELECT intValidDestinationStateId = 602, strFormCode = '1096', strScheduleCode = '1F', strType = 'Liquid Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38602
 UNION ALL SELECT intValidDestinationStateId = 609, strFormCode = '1096', strScheduleCode = '2', strType = 'Aviation Gas', strState = 'PA', strStatus = 'Include', intMasterId = 38609
 UNION ALL SELECT intValidDestinationStateId = 607, strFormCode = '1096', strScheduleCode = '2', strType = 'Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38607
 UNION ALL SELECT intValidDestinationStateId = 608, strFormCode = '1096', strScheduleCode = '2', strType = 'Jet Fuel', strState = 'PA', strStatus = 'Include', intMasterId = 38608
 UNION ALL SELECT intValidDestinationStateId = 606, strFormCode = '1096', strScheduleCode = '2', strType = 'Liquid Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38606
 UNION ALL SELECT intValidDestinationStateId = 613, strFormCode = '1096', strScheduleCode = '2F', strType = 'Aviation Gas', strState = 'PA', strStatus = 'Include', intMasterId = 38613
 UNION ALL SELECT intValidDestinationStateId = 611, strFormCode = '1096', strScheduleCode = '2F', strType = 'Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38611
 UNION ALL SELECT intValidDestinationStateId = 612, strFormCode = '1096', strScheduleCode = '2F', strType = 'Jet Fuel', strState = 'PA', strStatus = 'Include', intMasterId = 38612
 UNION ALL SELECT intValidDestinationStateId = 610, strFormCode = '1096', strScheduleCode = '2F', strType = 'Liquid Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38610
 UNION ALL SELECT intValidDestinationStateId = 617, strFormCode = '1096', strScheduleCode = '3', strType = 'Aviation Gas', strState = 'PA', strStatus = 'Include', intMasterId = 38617
 UNION ALL SELECT intValidDestinationStateId = 615, strFormCode = '1096', strScheduleCode = '3', strType = 'Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38615
 UNION ALL SELECT intValidDestinationStateId = 616, strFormCode = '1096', strScheduleCode = '3', strType = 'Jet Fuel', strState = 'PA', strStatus = 'Include', intMasterId = 38616
 UNION ALL SELECT intValidDestinationStateId = 614, strFormCode = '1096', strScheduleCode = '3', strType = 'Liquid Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38614
 UNION ALL SELECT intValidDestinationStateId = 621, strFormCode = '1096', strScheduleCode = '4', strType = 'Aviation Gas', strState = 'PA', strStatus = 'Include', intMasterId = 38621
 UNION ALL SELECT intValidDestinationStateId = 619, strFormCode = '1096', strScheduleCode = '4', strType = 'Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38619
 UNION ALL SELECT intValidDestinationStateId = 620, strFormCode = '1096', strScheduleCode = '4', strType = 'Jet Fuel', strState = 'PA', strStatus = 'Include', intMasterId = 38620
 UNION ALL SELECT intValidDestinationStateId = 618, strFormCode = '1096', strScheduleCode = '4', strType = 'Liquid Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38618
 UNION ALL SELECT intValidDestinationStateId = 625, strFormCode = '1096', strScheduleCode = '6', strType = 'Aviation Gas', strState = 'PA', strStatus = 'Include', intMasterId = 38625
 UNION ALL SELECT intValidDestinationStateId = 623, strFormCode = '1096', strScheduleCode = '6', strType = 'Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38623
 UNION ALL SELECT intValidDestinationStateId = 624, strFormCode = '1096', strScheduleCode = '6', strType = 'Jet Fuel', strState = 'PA', strStatus = 'Include', intMasterId = 38624
 UNION ALL SELECT intValidDestinationStateId = 622, strFormCode = '1096', strScheduleCode = '6', strType = 'Liquid Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38622
 UNION ALL SELECT intValidDestinationStateId = 629, strFormCode = '1096', strScheduleCode = '8', strType = 'Aviation Gas', strState = 'PA', strStatus = 'Include', intMasterId = 38629
 UNION ALL SELECT intValidDestinationStateId = 627, strFormCode = '1096', strScheduleCode = '8', strType = 'Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38627
 UNION ALL SELECT intValidDestinationStateId = 628, strFormCode = '1096', strScheduleCode = '8', strType = 'Jet Fuel', strState = 'PA', strStatus = 'Include', intMasterId = 38628
 UNION ALL SELECT intValidDestinationStateId = 626, strFormCode = '1096', strScheduleCode = '8', strType = 'Liquid Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38626
 UNION ALL SELECT intValidDestinationStateId = 633, strFormCode = '1096', strScheduleCode = '9', strType = 'Aviation Gas', strState = 'PA', strStatus = 'Include', intMasterId = 38633
 UNION ALL SELECT intValidDestinationStateId = 631, strFormCode = '1096', strScheduleCode = '9', strType = 'Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38631
 UNION ALL SELECT intValidDestinationStateId = 632, strFormCode = '1096', strScheduleCode = '9', strType = 'Jet Fuel', strState = 'PA', strStatus = 'Include', intMasterId = 38632
 UNION ALL SELECT intValidDestinationStateId = 630, strFormCode = '1096', strScheduleCode = '9', strType = 'Liquid Fuels', strState = 'PA', strStatus = 'Include', intMasterId = 38630
 UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', strState = 'PA', strStatus = 'Exclude', intMasterId = 38638
 UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', strState = 'PA', strStatus = 'Include', intMasterId = 38639
 UNION ALL SELECT intValidDestinationStateId = 0, strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', strState = 'PA', strStatus = 'Include', intMasterId = 38640


EXEC uspTFUpgradeValidDestinationStates @TaxAuthorityCode = @TaxAuthorityCode, @ValidDestinationStates = @ValidDestinationStates

-- Reporting Component - Configuration
/* Generate script for Reporting Component - Configurations. Specify Tax Authority Id to filter out specific Reporting Component - Configurations only.
	select strQuery = 'UNION ALL SELECT intReportTemplateId = ' + CAST(intReportingComponentConfigurationId AS NVARCHAR(10))
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
	+ ', intMasterId = ' + CASE WHEN Config.intMasterId IS NULL THEN CAST(38 AS NVARCHAR(20)) + CAST(intReportingComponentConfigurationId AS NVARCHAR(20)) ELSE CAST(Config.intMasterId AS NVARCHAR(20)) END
from tblTFReportingComponentConfiguration Config
left join tblTFReportingComponent RC ON RC.intReportingComponentId = Config.intReportingComponentId
WHERE RC.intTaxAuthorityId = 38
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
	-- Insert generated script here. Remove first instance of "UNION ALL "
 	SELECT intReportTemplateId = 901, strFormCode = 'PA Efile', strScheduleCode = 'PA E File', strType = '', strTemplateItemId = 'PAEFile-GrossOrNet', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '1', strDescription = 'Reporting Gross or Net', strScheduleList = NULL, strConfiguration = 'Gross', ysnConfiguration = '1', ysnUserDefinedValue = '1', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '1', ysnOutputDesigner = 0, strInputType = NULL, intMasterId = 38901
 

	EXEC uspTFUpgradeReportingComponentConfigurations @TaxAuthorityCode = @TaxAuthorityCode, @ReportingComponentConfigurations = @ReportingComponentConfigurations

	-- Reporting Component - Output Designer
	/* Generate script for Reporting Component - Output Designer. Specify Tax Authority Id to filter out specific Reporting Component - Output Designer only.
select strQuery = 'UNION ALL SELECT intScheduleColumnId = ' + CAST(intReportingComponentFieldId AS NVARCHAR(10))
		+ CASE WHEN strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
		+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
		+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END
		+ CASE WHEN strColumn IS NULL THEN ', strColumn = NULL' ELSE ', strColumn = ''' + strColumn + '''' END
		+ CASE WHEN strCaption IS NULL THEN ', strCaption = NULL' ELSE ', strCaption = ''' + strCaption + '''' END
		+ CASE WHEN strFormat IS NULL THEN ', strFormat = NULL' ELSE ', strFormat = ''' + strFormat + '''' END
		+ CASE WHEN strFooter IS NULL THEN ', strFooter = NULL' ELSE ', strFooter = ''' + strFooter + '''' END
		+ CASE WHEN intWidth IS NULL THEN ', intWidth = NULL' ELSE ', intWidth = ' + CAST(intWidth AS NVARCHAR(10)) END
		+ ', intMasterId = ' + CASE WHEN RCF.intMasterId IS NULL THEN CAST(38 AS NVARCHAR(20)) + CAST(intReportingComponentFieldId AS NVARCHAR(20)) ELSE CAST(RCF.intMasterId AS NVARCHAR(20)) END
	from tblTFReportingComponentField RCF
	left join tblTFReportingComponent RC on RC.intReportingComponentId = RCF.intReportingComponentId
	where RC.intTaxAuthorityId = 38
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
	-- Insert generated script here. Remove first instance of "UNION ALL "
 SELECT intScheduleColumnId = 20385, strFormCode = '1096', strScheduleCode = '2F', strType = 'Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820385
 UNION ALL SELECT intScheduleColumnId = 20384, strFormCode = '1096', strScheduleCode = '2F', strType = 'Jet Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820384
 UNION ALL SELECT intScheduleColumnId = 20382, strFormCode = '1096', strScheduleCode = '2F', strType = 'Jet Fuel', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820382
 UNION ALL SELECT intScheduleColumnId = 20383, strFormCode = '1096', strScheduleCode = '2F', strType = 'Jet Fuel', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820383
 UNION ALL SELECT intScheduleColumnId = 20378, strFormCode = '1096', strScheduleCode = '2F', strType = 'Jet Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820378
 UNION ALL SELECT intScheduleColumnId = 20379, strFormCode = '1096', strScheduleCode = '2F', strType = 'Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820379
 UNION ALL SELECT intScheduleColumnId = 20376, strFormCode = '1096', strScheduleCode = '2F', strType = 'Jet Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820376
 UNION ALL SELECT intScheduleColumnId = 20377, strFormCode = '1096', strScheduleCode = '2F', strType = 'Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820377
 UNION ALL SELECT intScheduleColumnId = 20371, strFormCode = '1096', strScheduleCode = '2F', strType = 'Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820371
 UNION ALL SELECT intScheduleColumnId = 20375, strFormCode = '1096', strScheduleCode = '2F', strType = 'Jet Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820375
 UNION ALL SELECT intScheduleColumnId = 20374, strFormCode = '1096', strScheduleCode = '2F', strType = 'Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820374
 UNION ALL SELECT intScheduleColumnId = 20373, strFormCode = '1096', strScheduleCode = '2F', strType = 'Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820373
 UNION ALL SELECT intScheduleColumnId = 20372, strFormCode = '1096', strScheduleCode = '2F', strType = 'Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820372
 UNION ALL SELECT intScheduleColumnId = 20381, strFormCode = '1096', strScheduleCode = '2F', strType = 'Jet Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820381
 UNION ALL SELECT intScheduleColumnId = 20380, strFormCode = '1096', strScheduleCode = '2F', strType = 'Jet Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820380
 UNION ALL SELECT intScheduleColumnId = 20355, strFormCode = '1096', strScheduleCode = '2F', strType = 'Liquid Fuels', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820355
 UNION ALL SELECT intScheduleColumnId = 20354, strFormCode = '1096', strScheduleCode = '2F', strType = 'Liquid Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820354
 UNION ALL SELECT intScheduleColumnId = 20352, strFormCode = '1096', strScheduleCode = '2F', strType = 'Liquid Fuels', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820352
 UNION ALL SELECT intScheduleColumnId = 20353, strFormCode = '1096', strScheduleCode = '2F', strType = 'Liquid Fuels', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820353
 UNION ALL SELECT intScheduleColumnId = 20348, strFormCode = '1096', strScheduleCode = '2F', strType = 'Liquid Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820348
 UNION ALL SELECT intScheduleColumnId = 20349, strFormCode = '1096', strScheduleCode = '2F', strType = 'Liquid Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820349
 UNION ALL SELECT intScheduleColumnId = 20346, strFormCode = '1096', strScheduleCode = '2F', strType = 'Liquid Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820346
 UNION ALL SELECT intScheduleColumnId = 20347, strFormCode = '1096', strScheduleCode = '2F', strType = 'Liquid Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820347
 UNION ALL SELECT intScheduleColumnId = 20341, strFormCode = '1096', strScheduleCode = '2F', strType = 'Liquid Fuels', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820341
 UNION ALL SELECT intScheduleColumnId = 20345, strFormCode = '1096', strScheduleCode = '2F', strType = 'Liquid Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820345
 UNION ALL SELECT intScheduleColumnId = 20344, strFormCode = '1096', strScheduleCode = '2F', strType = 'Liquid Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820344
 UNION ALL SELECT intScheduleColumnId = 20343, strFormCode = '1096', strScheduleCode = '2F', strType = 'Liquid Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820343
 UNION ALL SELECT intScheduleColumnId = 20342, strFormCode = '1096', strScheduleCode = '2F', strType = 'Liquid Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820342
 UNION ALL SELECT intScheduleColumnId = 20351, strFormCode = '1096', strScheduleCode = '2F', strType = 'Liquid Fuels', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820351
 UNION ALL SELECT intScheduleColumnId = 20350, strFormCode = '1096', strScheduleCode = '2F', strType = 'Liquid Fuels', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820350
 UNION ALL SELECT intScheduleColumnId = 20460, strFormCode = '1096', strScheduleCode = '3', strType = 'Aviation Gas', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820460
 UNION ALL SELECT intScheduleColumnId = 20459, strFormCode = '1096', strScheduleCode = '3', strType = 'Aviation Gas', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820459
 UNION ALL SELECT intScheduleColumnId = 20457, strFormCode = '1096', strScheduleCode = '3', strType = 'Aviation Gas', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820457
 UNION ALL SELECT intScheduleColumnId = 20458, strFormCode = '1096', strScheduleCode = '3', strType = 'Aviation Gas', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820458
 UNION ALL SELECT intScheduleColumnId = 20453, strFormCode = '1096', strScheduleCode = '3', strType = 'Aviation Gas', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820453
 UNION ALL SELECT intScheduleColumnId = 20454, strFormCode = '1096', strScheduleCode = '3', strType = 'Aviation Gas', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820454
 UNION ALL SELECT intScheduleColumnId = 20451, strFormCode = '1096', strScheduleCode = '3', strType = 'Aviation Gas', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820451
 UNION ALL SELECT intScheduleColumnId = 20452, strFormCode = '1096', strScheduleCode = '3', strType = 'Aviation Gas', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820452
 UNION ALL SELECT intScheduleColumnId = 20446, strFormCode = '1096', strScheduleCode = '3', strType = 'Aviation Gas', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820446
 UNION ALL SELECT intScheduleColumnId = 20450, strFormCode = '1096', strScheduleCode = '3', strType = 'Aviation Gas', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820450
 UNION ALL SELECT intScheduleColumnId = 20449, strFormCode = '1096', strScheduleCode = '3', strType = 'Aviation Gas', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820449
 UNION ALL SELECT intScheduleColumnId = 20448, strFormCode = '1096', strScheduleCode = '3', strType = 'Aviation Gas', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820448
 UNION ALL SELECT intScheduleColumnId = 20447, strFormCode = '1096', strScheduleCode = '3', strType = 'Aviation Gas', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820447
 UNION ALL SELECT intScheduleColumnId = 20456, strFormCode = '1096', strScheduleCode = '3', strType = 'Aviation Gas', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820456
 UNION ALL SELECT intScheduleColumnId = 20455, strFormCode = '1096', strScheduleCode = '3', strType = 'Aviation Gas', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820455
 UNION ALL SELECT intScheduleColumnId = 20430, strFormCode = '1096', strScheduleCode = '3', strType = 'Fuels', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820430
 UNION ALL SELECT intScheduleColumnId = 20429, strFormCode = '1096', strScheduleCode = '3', strType = 'Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820429
 UNION ALL SELECT intScheduleColumnId = 20427, strFormCode = '1096', strScheduleCode = '3', strType = 'Fuels', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820427
 UNION ALL SELECT intScheduleColumnId = 20428, strFormCode = '1096', strScheduleCode = '3', strType = 'Fuels', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820428
 UNION ALL SELECT intScheduleColumnId = 20423, strFormCode = '1096', strScheduleCode = '3', strType = 'Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820423
 UNION ALL SELECT intScheduleColumnId = 20424, strFormCode = '1096', strScheduleCode = '3', strType = 'Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820424
 UNION ALL SELECT intScheduleColumnId = 20421, strFormCode = '1096', strScheduleCode = '3', strType = 'Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820421
 UNION ALL SELECT intScheduleColumnId = 20422, strFormCode = '1096', strScheduleCode = '3', strType = 'Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820422
 UNION ALL SELECT intScheduleColumnId = 20416, strFormCode = '1096', strScheduleCode = '3', strType = 'Fuels', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820416
 UNION ALL SELECT intScheduleColumnId = 20420, strFormCode = '1096', strScheduleCode = '3', strType = 'Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820420
 UNION ALL SELECT intScheduleColumnId = 20419, strFormCode = '1096', strScheduleCode = '3', strType = 'Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820419
 UNION ALL SELECT intScheduleColumnId = 20418, strFormCode = '1096', strScheduleCode = '3', strType = 'Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820418
 UNION ALL SELECT intScheduleColumnId = 20417, strFormCode = '1096', strScheduleCode = '3', strType = 'Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820417
 UNION ALL SELECT intScheduleColumnId = 20426, strFormCode = '1096', strScheduleCode = '3', strType = 'Fuels', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820426
 UNION ALL SELECT intScheduleColumnId = 20425, strFormCode = '1096', strScheduleCode = '3', strType = 'Fuels', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820425
 UNION ALL SELECT intScheduleColumnId = 20445, strFormCode = '1096', strScheduleCode = '3', strType = 'Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820445
 UNION ALL SELECT intScheduleColumnId = 20444, strFormCode = '1096', strScheduleCode = '3', strType = 'Jet Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820444
 UNION ALL SELECT intScheduleColumnId = 20442, strFormCode = '1096', strScheduleCode = '3', strType = 'Jet Fuel', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820442
 UNION ALL SELECT intScheduleColumnId = 20443, strFormCode = '1096', strScheduleCode = '3', strType = 'Jet Fuel', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820443
 UNION ALL SELECT intScheduleColumnId = 20438, strFormCode = '1096', strScheduleCode = '3', strType = 'Jet Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820438
 UNION ALL SELECT intScheduleColumnId = 20439, strFormCode = '1096', strScheduleCode = '3', strType = 'Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820439
 UNION ALL SELECT intScheduleColumnId = 20436, strFormCode = '1096', strScheduleCode = '3', strType = 'Jet Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820436
 UNION ALL SELECT intScheduleColumnId = 20437, strFormCode = '1096', strScheduleCode = '3', strType = 'Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820437
 UNION ALL SELECT intScheduleColumnId = 20431, strFormCode = '1096', strScheduleCode = '3', strType = 'Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820431
 UNION ALL SELECT intScheduleColumnId = 20435, strFormCode = '1096', strScheduleCode = '3', strType = 'Jet Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820435
 UNION ALL SELECT intScheduleColumnId = 20434, strFormCode = '1096', strScheduleCode = '3', strType = 'Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820434
 UNION ALL SELECT intScheduleColumnId = 20433, strFormCode = '1096', strScheduleCode = '3', strType = 'Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820433
 UNION ALL SELECT intScheduleColumnId = 20432, strFormCode = '1096', strScheduleCode = '3', strType = 'Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820432
 UNION ALL SELECT intScheduleColumnId = 20441, strFormCode = '1096', strScheduleCode = '3', strType = 'Jet Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820441
 UNION ALL SELECT intScheduleColumnId = 20440, strFormCode = '1096', strScheduleCode = '3', strType = 'Jet Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820440
 UNION ALL SELECT intScheduleColumnId = 20415, strFormCode = '1096', strScheduleCode = '3', strType = 'Liquid Fuels', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820415
 UNION ALL SELECT intScheduleColumnId = 20414, strFormCode = '1096', strScheduleCode = '3', strType = 'Liquid Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820414
 UNION ALL SELECT intScheduleColumnId = 20412, strFormCode = '1096', strScheduleCode = '3', strType = 'Liquid Fuels', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820412
 UNION ALL SELECT intScheduleColumnId = 20413, strFormCode = '1096', strScheduleCode = '3', strType = 'Liquid Fuels', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820413
 UNION ALL SELECT intScheduleColumnId = 20408, strFormCode = '1096', strScheduleCode = '3', strType = 'Liquid Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820408
 UNION ALL SELECT intScheduleColumnId = 20409, strFormCode = '1096', strScheduleCode = '3', strType = 'Liquid Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820409
 UNION ALL SELECT intScheduleColumnId = 20406, strFormCode = '1096', strScheduleCode = '3', strType = 'Liquid Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820406
 UNION ALL SELECT intScheduleColumnId = 20407, strFormCode = '1096', strScheduleCode = '3', strType = 'Liquid Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820407
 UNION ALL SELECT intScheduleColumnId = 20401, strFormCode = '1096', strScheduleCode = '3', strType = 'Liquid Fuels', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820401
 UNION ALL SELECT intScheduleColumnId = 20405, strFormCode = '1096', strScheduleCode = '3', strType = 'Liquid Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820405
 UNION ALL SELECT intScheduleColumnId = 20404, strFormCode = '1096', strScheduleCode = '3', strType = 'Liquid Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820404
 UNION ALL SELECT intScheduleColumnId = 20403, strFormCode = '1096', strScheduleCode = '3', strType = 'Liquid Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820403
 UNION ALL SELECT intScheduleColumnId = 20402, strFormCode = '1096', strScheduleCode = '3', strType = 'Liquid Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820402
 UNION ALL SELECT intScheduleColumnId = 20411, strFormCode = '1096', strScheduleCode = '3', strType = 'Liquid Fuels', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820411
 UNION ALL SELECT intScheduleColumnId = 20410, strFormCode = '1096', strScheduleCode = '3', strType = 'Liquid Fuels', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820410
 UNION ALL SELECT intScheduleColumnId = 20520, strFormCode = '1096', strScheduleCode = '4', strType = 'Aviation Gas', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820520
 UNION ALL SELECT intScheduleColumnId = 20519, strFormCode = '1096', strScheduleCode = '4', strType = 'Aviation Gas', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820519
 UNION ALL SELECT intScheduleColumnId = 20517, strFormCode = '1096', strScheduleCode = '4', strType = 'Aviation Gas', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820517
 UNION ALL SELECT intScheduleColumnId = 20518, strFormCode = '1096', strScheduleCode = '4', strType = 'Aviation Gas', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820518
 UNION ALL SELECT intScheduleColumnId = 20513, strFormCode = '1096', strScheduleCode = '4', strType = 'Aviation Gas', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820513
 UNION ALL SELECT intScheduleColumnId = 20514, strFormCode = '1096', strScheduleCode = '4', strType = 'Aviation Gas', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820514
 UNION ALL SELECT intScheduleColumnId = 20511, strFormCode = '1096', strScheduleCode = '4', strType = 'Aviation Gas', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820511
 UNION ALL SELECT intScheduleColumnId = 20512, strFormCode = '1096', strScheduleCode = '4', strType = 'Aviation Gas', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820512
 UNION ALL SELECT intScheduleColumnId = 20506, strFormCode = '1096', strScheduleCode = '4', strType = 'Aviation Gas', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820506
 UNION ALL SELECT intScheduleColumnId = 20510, strFormCode = '1096', strScheduleCode = '4', strType = 'Aviation Gas', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820510
 UNION ALL SELECT intScheduleColumnId = 20509, strFormCode = '1096', strScheduleCode = '4', strType = 'Aviation Gas', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820509
 UNION ALL SELECT intScheduleColumnId = 20508, strFormCode = '1096', strScheduleCode = '4', strType = 'Aviation Gas', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820508
 UNION ALL SELECT intScheduleColumnId = 20507, strFormCode = '1096', strScheduleCode = '4', strType = 'Aviation Gas', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820507
 UNION ALL SELECT intScheduleColumnId = 20516, strFormCode = '1096', strScheduleCode = '4', strType = 'Aviation Gas', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820516
 UNION ALL SELECT intScheduleColumnId = 20515, strFormCode = '1096', strScheduleCode = '4', strType = 'Aviation Gas', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820515
 UNION ALL SELECT intScheduleColumnId = 20490, strFormCode = '1096', strScheduleCode = '4', strType = 'Fuels', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820490
 UNION ALL SELECT intScheduleColumnId = 20489, strFormCode = '1096', strScheduleCode = '4', strType = 'Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820489
 UNION ALL SELECT intScheduleColumnId = 20487, strFormCode = '1096', strScheduleCode = '4', strType = 'Fuels', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820487
 UNION ALL SELECT intScheduleColumnId = 20488, strFormCode = '1096', strScheduleCode = '4', strType = 'Fuels', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820488
 UNION ALL SELECT intScheduleColumnId = 20483, strFormCode = '1096', strScheduleCode = '4', strType = 'Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820483
 UNION ALL SELECT intScheduleColumnId = 20484, strFormCode = '1096', strScheduleCode = '4', strType = 'Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820484
 UNION ALL SELECT intScheduleColumnId = 20481, strFormCode = '1096', strScheduleCode = '4', strType = 'Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820481
 UNION ALL SELECT intScheduleColumnId = 20482, strFormCode = '1096', strScheduleCode = '4', strType = 'Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820482
 UNION ALL SELECT intScheduleColumnId = 20476, strFormCode = '1096', strScheduleCode = '4', strType = 'Fuels', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820476
 UNION ALL SELECT intScheduleColumnId = 20480, strFormCode = '1096', strScheduleCode = '4', strType = 'Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820480
 UNION ALL SELECT intScheduleColumnId = 20479, strFormCode = '1096', strScheduleCode = '4', strType = 'Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820479
 UNION ALL SELECT intScheduleColumnId = 20478, strFormCode = '1096', strScheduleCode = '4', strType = 'Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820478
 UNION ALL SELECT intScheduleColumnId = 20477, strFormCode = '1096', strScheduleCode = '4', strType = 'Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820477
 UNION ALL SELECT intScheduleColumnId = 20486, strFormCode = '1096', strScheduleCode = '4', strType = 'Fuels', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820486
 UNION ALL SELECT intScheduleColumnId = 20485, strFormCode = '1096', strScheduleCode = '4', strType = 'Fuels', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820485
 UNION ALL SELECT intScheduleColumnId = 20505, strFormCode = '1096', strScheduleCode = '4', strType = 'Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820505
 UNION ALL SELECT intScheduleColumnId = 20504, strFormCode = '1096', strScheduleCode = '4', strType = 'Jet Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820504
 UNION ALL SELECT intScheduleColumnId = 20502, strFormCode = '1096', strScheduleCode = '4', strType = 'Jet Fuel', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820502
 UNION ALL SELECT intScheduleColumnId = 20503, strFormCode = '1096', strScheduleCode = '4', strType = 'Jet Fuel', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820503
 UNION ALL SELECT intScheduleColumnId = 20498, strFormCode = '1096', strScheduleCode = '4', strType = 'Jet Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820498
 UNION ALL SELECT intScheduleColumnId = 20499, strFormCode = '1096', strScheduleCode = '4', strType = 'Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820499
 UNION ALL SELECT intScheduleColumnId = 20496, strFormCode = '1096', strScheduleCode = '4', strType = 'Jet Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820496
 UNION ALL SELECT intScheduleColumnId = 20956, strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820956
 UNION ALL SELECT intScheduleColumnId = 20953, strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', strColumn = 'dtmDate', strCaption = 'Date Delivered', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820953
 UNION ALL SELECT intScheduleColumnId = 20954, strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820954
 UNION ALL SELECT intScheduleColumnId = 20952, strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820952
 UNION ALL SELECT intScheduleColumnId = 20948, strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820948
 UNION ALL SELECT intScheduleColumnId = 20949, strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', strColumn = 'strCustomerStreetAddress', strCaption = 'Buyer Address', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820949
 UNION ALL SELECT intScheduleColumnId = 20950, strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', strColumn = 'strDestinationCity', strCaption = 'Buyer City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820950
 UNION ALL SELECT intScheduleColumnId = 20951, strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', strColumn = 'strDestinationState', strCaption = 'Buyer State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820951
 UNION ALL SELECT intScheduleColumnId = 20946, strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820946
 UNION ALL SELECT intScheduleColumnId = 20947, strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820947
 UNION ALL SELECT intScheduleColumnId = 20941, strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820941
 UNION ALL SELECT intScheduleColumnId = 20945, strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820945
 UNION ALL SELECT intScheduleColumnId = 20944, strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820944
 UNION ALL SELECT intScheduleColumnId = 20943, strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820943
 UNION ALL SELECT intScheduleColumnId = 20942, strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820942
 UNION ALL SELECT intScheduleColumnId = 20971, strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820971
 UNION ALL SELECT intScheduleColumnId = 20972, strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820972
 UNION ALL SELECT intScheduleColumnId = 20969, strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', strColumn = 'dtmDate', strCaption = 'Date Delivered', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820969
 UNION ALL SELECT intScheduleColumnId = 20970, strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820970
 UNION ALL SELECT intScheduleColumnId = 20968, strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820968
 UNION ALL SELECT intScheduleColumnId = 20964, strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820964
 UNION ALL SELECT intScheduleColumnId = 20965, strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', strColumn = 'strCustomerStreetAddress', strCaption = 'Buyer Address', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820965
 UNION ALL SELECT intScheduleColumnId = 20966, strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', strColumn = 'strDestinationCity', strCaption = 'Buyer City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820966
 UNION ALL SELECT intScheduleColumnId = 20967, strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', strColumn = 'strDestinationState', strCaption = 'Buyer State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820967
 UNION ALL SELECT intScheduleColumnId = 20962, strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820962
 UNION ALL SELECT intScheduleColumnId = 20963, strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820963
 UNION ALL SELECT intScheduleColumnId = 20957, strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820957
 UNION ALL SELECT intScheduleColumnId = 20961, strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820961
 UNION ALL SELECT intScheduleColumnId = 20960, strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820960
 UNION ALL SELECT intScheduleColumnId = 20959, strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820959
 UNION ALL SELECT intScheduleColumnId = 20958, strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820958
 UNION ALL SELECT intScheduleColumnId = 20987, strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820987
 UNION ALL SELECT intScheduleColumnId = 20988, strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820988
 UNION ALL SELECT intScheduleColumnId = 20985, strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', strColumn = 'dtmDate', strCaption = 'Date Delivered', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820985
 UNION ALL SELECT intScheduleColumnId = 20986, strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820986
 UNION ALL SELECT intScheduleColumnId = 20984, strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820984
 UNION ALL SELECT intScheduleColumnId = 20980, strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820980
 UNION ALL SELECT intScheduleColumnId = 20981, strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', strColumn = 'strCustomerStreetAddress', strCaption = 'Buyer Address', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820981
 UNION ALL SELECT intScheduleColumnId = 20982, strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', strColumn = 'strDestinationCity', strCaption = 'Buyer City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820982
 UNION ALL SELECT intScheduleColumnId = 20983, strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', strColumn = 'strDestinationState', strCaption = 'Buyer State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820983
 UNION ALL SELECT intScheduleColumnId = 20978, strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820978
 UNION ALL SELECT intScheduleColumnId = 20979, strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820979
 UNION ALL SELECT intScheduleColumnId = 20973, strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820973
 UNION ALL SELECT intScheduleColumnId = 20977, strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820977
 UNION ALL SELECT intScheduleColumnId = 20976, strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820976
 UNION ALL SELECT intScheduleColumnId = 20975, strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820975
 UNION ALL SELECT intScheduleColumnId = 20974, strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820974
 UNION ALL SELECT intScheduleColumnId = 20220, strFormCode = '1096', strScheduleCode = '1', strType = 'Aviation Gas', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820220
 UNION ALL SELECT intScheduleColumnId = 20219, strFormCode = '1096', strScheduleCode = '1', strType = 'Aviation Gas', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820219
 UNION ALL SELECT intScheduleColumnId = 20217, strFormCode = '1096', strScheduleCode = '1', strType = 'Aviation Gas', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820217
 UNION ALL SELECT intScheduleColumnId = 20218, strFormCode = '1096', strScheduleCode = '1', strType = 'Aviation Gas', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820218
 UNION ALL SELECT intScheduleColumnId = 20213, strFormCode = '1096', strScheduleCode = '1', strType = 'Aviation Gas', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820213
 UNION ALL SELECT intScheduleColumnId = 20214, strFormCode = '1096', strScheduleCode = '1', strType = 'Aviation Gas', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820214
 UNION ALL SELECT intScheduleColumnId = 20211, strFormCode = '1096', strScheduleCode = '1', strType = 'Aviation Gas', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820211
 UNION ALL SELECT intScheduleColumnId = 20212, strFormCode = '1096', strScheduleCode = '1', strType = 'Aviation Gas', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820212
 UNION ALL SELECT intScheduleColumnId = 20206, strFormCode = '1096', strScheduleCode = '1', strType = 'Aviation Gas', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820206
 UNION ALL SELECT intScheduleColumnId = 20210, strFormCode = '1096', strScheduleCode = '1', strType = 'Aviation Gas', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820210
 UNION ALL SELECT intScheduleColumnId = 20209, strFormCode = '1096', strScheduleCode = '1', strType = 'Aviation Gas', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820209
 UNION ALL SELECT intScheduleColumnId = 20208, strFormCode = '1096', strScheduleCode = '1', strType = 'Aviation Gas', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820208
 UNION ALL SELECT intScheduleColumnId = 20207, strFormCode = '1096', strScheduleCode = '1', strType = 'Aviation Gas', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820207
 UNION ALL SELECT intScheduleColumnId = 20216, strFormCode = '1096', strScheduleCode = '1', strType = 'Aviation Gas', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820216
 UNION ALL SELECT intScheduleColumnId = 20215, strFormCode = '1096', strScheduleCode = '1', strType = 'Aviation Gas', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820215
 UNION ALL SELECT intScheduleColumnId = 20190, strFormCode = '1096', strScheduleCode = '1', strType = 'Fuels', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820190
 UNION ALL SELECT intScheduleColumnId = 20497, strFormCode = '1096', strScheduleCode = '4', strType = 'Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820497
 UNION ALL SELECT intScheduleColumnId = 20491, strFormCode = '1096', strScheduleCode = '4', strType = 'Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820491
 UNION ALL SELECT intScheduleColumnId = 20495, strFormCode = '1096', strScheduleCode = '4', strType = 'Jet Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820495
 UNION ALL SELECT intScheduleColumnId = 20494, strFormCode = '1096', strScheduleCode = '4', strType = 'Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820494
 UNION ALL SELECT intScheduleColumnId = 20493, strFormCode = '1096', strScheduleCode = '4', strType = 'Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820493
 UNION ALL SELECT intScheduleColumnId = 20492, strFormCode = '1096', strScheduleCode = '4', strType = 'Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820492
 UNION ALL SELECT intScheduleColumnId = 20501, strFormCode = '1096', strScheduleCode = '4', strType = 'Jet Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820501
 UNION ALL SELECT intScheduleColumnId = 20500, strFormCode = '1096', strScheduleCode = '4', strType = 'Jet Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820500
 UNION ALL SELECT intScheduleColumnId = 20475, strFormCode = '1096', strScheduleCode = '4', strType = 'Liquid Fuels', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820475
 UNION ALL SELECT intScheduleColumnId = 20474, strFormCode = '1096', strScheduleCode = '4', strType = 'Liquid Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820474
 UNION ALL SELECT intScheduleColumnId = 20472, strFormCode = '1096', strScheduleCode = '4', strType = 'Liquid Fuels', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820472
 UNION ALL SELECT intScheduleColumnId = 20473, strFormCode = '1096', strScheduleCode = '4', strType = 'Liquid Fuels', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820473
 UNION ALL SELECT intScheduleColumnId = 20468, strFormCode = '1096', strScheduleCode = '4', strType = 'Liquid Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820468
 UNION ALL SELECT intScheduleColumnId = 20469, strFormCode = '1096', strScheduleCode = '4', strType = 'Liquid Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820469
 UNION ALL SELECT intScheduleColumnId = 20466, strFormCode = '1096', strScheduleCode = '4', strType = 'Liquid Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820466
 UNION ALL SELECT intScheduleColumnId = 20467, strFormCode = '1096', strScheduleCode = '4', strType = 'Liquid Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820467
 UNION ALL SELECT intScheduleColumnId = 20461, strFormCode = '1096', strScheduleCode = '4', strType = 'Liquid Fuels', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820461
 UNION ALL SELECT intScheduleColumnId = 20465, strFormCode = '1096', strScheduleCode = '4', strType = 'Liquid Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820465
 UNION ALL SELECT intScheduleColumnId = 20464, strFormCode = '1096', strScheduleCode = '4', strType = 'Liquid Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820464
 UNION ALL SELECT intScheduleColumnId = 20463, strFormCode = '1096', strScheduleCode = '4', strType = 'Liquid Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820463
 UNION ALL SELECT intScheduleColumnId = 20462, strFormCode = '1096', strScheduleCode = '4', strType = 'Liquid Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820462
 UNION ALL SELECT intScheduleColumnId = 20471, strFormCode = '1096', strScheduleCode = '4', strType = 'Liquid Fuels', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820471
 UNION ALL SELECT intScheduleColumnId = 20470, strFormCode = '1096', strScheduleCode = '4', strType = 'Liquid Fuels', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820470
 UNION ALL SELECT intScheduleColumnId = 20580, strFormCode = '1096', strScheduleCode = '5', strType = 'Aviation Gas', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820580
 UNION ALL SELECT intScheduleColumnId = 20579, strFormCode = '1096', strScheduleCode = '5', strType = 'Aviation Gas', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820579
 UNION ALL SELECT intScheduleColumnId = 20577, strFormCode = '1096', strScheduleCode = '5', strType = 'Aviation Gas', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820577
 UNION ALL SELECT intScheduleColumnId = 20578, strFormCode = '1096', strScheduleCode = '5', strType = 'Aviation Gas', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820578
 UNION ALL SELECT intScheduleColumnId = 20576, strFormCode = '1096', strScheduleCode = '5', strType = 'Aviation Gas', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820576
 UNION ALL SELECT intScheduleColumnId = 20575, strFormCode = '1096', strScheduleCode = '5', strType = 'Aviation Gas', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820575
 UNION ALL SELECT intScheduleColumnId = 20572, strFormCode = '1096', strScheduleCode = '5', strType = 'Aviation Gas', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820572
 UNION ALL SELECT intScheduleColumnId = 20573, strFormCode = '1096', strScheduleCode = '5', strType = 'Aviation Gas', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820573
 UNION ALL SELECT intScheduleColumnId = 20570, strFormCode = '1096', strScheduleCode = '5', strType = 'Aviation Gas', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820570
 UNION ALL SELECT intScheduleColumnId = 20571, strFormCode = '1096', strScheduleCode = '5', strType = 'Aviation Gas', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820571
 UNION ALL SELECT intScheduleColumnId = 20566, strFormCode = '1096', strScheduleCode = '5', strType = 'Aviation Gas', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820566
 UNION ALL SELECT intScheduleColumnId = 20574, strFormCode = '1096', strScheduleCode = '5', strType = 'Aviation Gas', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820574
 UNION ALL SELECT intScheduleColumnId = 20569, strFormCode = '1096', strScheduleCode = '5', strType = 'Aviation Gas', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820569
 UNION ALL SELECT intScheduleColumnId = 20568, strFormCode = '1096', strScheduleCode = '5', strType = 'Aviation Gas', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820568
 UNION ALL SELECT intScheduleColumnId = 20567, strFormCode = '1096', strScheduleCode = '5', strType = 'Aviation Gas', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820567
 UNION ALL SELECT intScheduleColumnId = 20550, strFormCode = '1096', strScheduleCode = '5', strType = 'Fuels', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820550
 UNION ALL SELECT intScheduleColumnId = 20549, strFormCode = '1096', strScheduleCode = '5', strType = 'Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820549
 UNION ALL SELECT intScheduleColumnId = 20547, strFormCode = '1096', strScheduleCode = '5', strType = 'Fuels', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820547
 UNION ALL SELECT intScheduleColumnId = 20548, strFormCode = '1096', strScheduleCode = '5', strType = 'Fuels', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820548
 UNION ALL SELECT intScheduleColumnId = 20546, strFormCode = '1096', strScheduleCode = '5', strType = 'Fuels', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820546
 UNION ALL SELECT intScheduleColumnId = 20545, strFormCode = '1096', strScheduleCode = '5', strType = 'Fuels', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820545
 UNION ALL SELECT intScheduleColumnId = 20542, strFormCode = '1096', strScheduleCode = '5', strType = 'Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820542
 UNION ALL SELECT intScheduleColumnId = 20543, strFormCode = '1096', strScheduleCode = '5', strType = 'Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820543
 UNION ALL SELECT intScheduleColumnId = 20540, strFormCode = '1096', strScheduleCode = '5', strType = 'Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820540
 UNION ALL SELECT intScheduleColumnId = 20541, strFormCode = '1096', strScheduleCode = '5', strType = 'Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820541
 UNION ALL SELECT intScheduleColumnId = 20536, strFormCode = '1096', strScheduleCode = '5', strType = 'Fuels', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820536
 UNION ALL SELECT intScheduleColumnId = 20544, strFormCode = '1096', strScheduleCode = '5', strType = 'Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820544
 UNION ALL SELECT intScheduleColumnId = 20539, strFormCode = '1096', strScheduleCode = '5', strType = 'Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820539
 UNION ALL SELECT intScheduleColumnId = 20538, strFormCode = '1096', strScheduleCode = '5', strType = 'Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820538
 UNION ALL SELECT intScheduleColumnId = 20537, strFormCode = '1096', strScheduleCode = '5', strType = 'Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820537
 UNION ALL SELECT intScheduleColumnId = 20565, strFormCode = '1096', strScheduleCode = '5', strType = 'Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820565
 UNION ALL SELECT intScheduleColumnId = 20564, strFormCode = '1096', strScheduleCode = '5', strType = 'Jet Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820564
 UNION ALL SELECT intScheduleColumnId = 20562, strFormCode = '1096', strScheduleCode = '5', strType = 'Jet Fuel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820562
 UNION ALL SELECT intScheduleColumnId = 20563, strFormCode = '1096', strScheduleCode = '5', strType = 'Jet Fuel', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820563
 UNION ALL SELECT intScheduleColumnId = 20561, strFormCode = '1096', strScheduleCode = '5', strType = 'Jet Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820561
 UNION ALL SELECT intScheduleColumnId = 20560, strFormCode = '1096', strScheduleCode = '5', strType = 'Jet Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820560
 UNION ALL SELECT intScheduleColumnId = 20557, strFormCode = '1096', strScheduleCode = '5', strType = 'Jet Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820557
 UNION ALL SELECT intScheduleColumnId = 20558, strFormCode = '1096', strScheduleCode = '5', strType = 'Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820558
 UNION ALL SELECT intScheduleColumnId = 20555, strFormCode = '1096', strScheduleCode = '5', strType = 'Jet Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820555
 UNION ALL SELECT intScheduleColumnId = 20556, strFormCode = '1096', strScheduleCode = '5', strType = 'Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820556
 UNION ALL SELECT intScheduleColumnId = 20551, strFormCode = '1096', strScheduleCode = '5', strType = 'Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820551
 UNION ALL SELECT intScheduleColumnId = 20559, strFormCode = '1096', strScheduleCode = '5', strType = 'Jet Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820559
 UNION ALL SELECT intScheduleColumnId = 20554, strFormCode = '1096', strScheduleCode = '5', strType = 'Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820554
 UNION ALL SELECT intScheduleColumnId = 20553, strFormCode = '1096', strScheduleCode = '5', strType = 'Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820553
 UNION ALL SELECT intScheduleColumnId = 20552, strFormCode = '1096', strScheduleCode = '5', strType = 'Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820552
 UNION ALL SELECT intScheduleColumnId = 20535, strFormCode = '1096', strScheduleCode = '5', strType = 'Liquid Fuels', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820535
 UNION ALL SELECT intScheduleColumnId = 20534, strFormCode = '1096', strScheduleCode = '5', strType = 'Liquid Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820534
 UNION ALL SELECT intScheduleColumnId = 20532, strFormCode = '1096', strScheduleCode = '5', strType = 'Liquid Fuels', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820532
 UNION ALL SELECT intScheduleColumnId = 20533, strFormCode = '1096', strScheduleCode = '5', strType = 'Liquid Fuels', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820533
 UNION ALL SELECT intScheduleColumnId = 20531, strFormCode = '1096', strScheduleCode = '5', strType = 'Liquid Fuels', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820531
 UNION ALL SELECT intScheduleColumnId = 20530, strFormCode = '1096', strScheduleCode = '5', strType = 'Liquid Fuels', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820530
 UNION ALL SELECT intScheduleColumnId = 20527, strFormCode = '1096', strScheduleCode = '5', strType = 'Liquid Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820527
 UNION ALL SELECT intScheduleColumnId = 20528, strFormCode = '1096', strScheduleCode = '5', strType = 'Liquid Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820528
 UNION ALL SELECT intScheduleColumnId = 20525, strFormCode = '1096', strScheduleCode = '5', strType = 'Liquid Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820525
 UNION ALL SELECT intScheduleColumnId = 20526, strFormCode = '1096', strScheduleCode = '5', strType = 'Liquid Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820526
 UNION ALL SELECT intScheduleColumnId = 20521, strFormCode = '1096', strScheduleCode = '5', strType = 'Liquid Fuels', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820521
 UNION ALL SELECT intScheduleColumnId = 20529, strFormCode = '1096', strScheduleCode = '5', strType = 'Liquid Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820529
 UNION ALL SELECT intScheduleColumnId = 20524, strFormCode = '1096', strScheduleCode = '5', strType = 'Liquid Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820524
 UNION ALL SELECT intScheduleColumnId = 20523, strFormCode = '1096', strScheduleCode = '5', strType = 'Liquid Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820523
 UNION ALL SELECT intScheduleColumnId = 20522, strFormCode = '1096', strScheduleCode = '5', strType = 'Liquid Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820522
 UNION ALL SELECT intScheduleColumnId = 20640, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Aviation Gas', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820640
 UNION ALL SELECT intScheduleColumnId = 20639, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Aviation Gas', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820639
 UNION ALL SELECT intScheduleColumnId = 20637, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Aviation Gas', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820637
 UNION ALL SELECT intScheduleColumnId = 20638, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Aviation Gas', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820638
 UNION ALL SELECT intScheduleColumnId = 20636, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Aviation Gas', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820636
 UNION ALL SELECT intScheduleColumnId = 20635, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Aviation Gas', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820635
 UNION ALL SELECT intScheduleColumnId = 20632, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Aviation Gas', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820632
 UNION ALL SELECT intScheduleColumnId = 20633, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Aviation Gas', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820633
 UNION ALL SELECT intScheduleColumnId = 20630, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Aviation Gas', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820630
 UNION ALL SELECT intScheduleColumnId = 20631, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Aviation Gas', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820631
 UNION ALL SELECT intScheduleColumnId = 20626, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Aviation Gas', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820626
 UNION ALL SELECT intScheduleColumnId = 20634, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Aviation Gas', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820634
 UNION ALL SELECT intScheduleColumnId = 20629, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Aviation Gas', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820629
 UNION ALL SELECT intScheduleColumnId = 20628, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Aviation Gas', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820628
 UNION ALL SELECT intScheduleColumnId = 20627, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Aviation Gas', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820627
 UNION ALL SELECT intScheduleColumnId = 20610, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Fuels', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820610
 UNION ALL SELECT intScheduleColumnId = 20609, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820609
 UNION ALL SELECT intScheduleColumnId = 20607, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Fuels', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820607
 UNION ALL SELECT intScheduleColumnId = 20608, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Fuels', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820608
 UNION ALL SELECT intScheduleColumnId = 20606, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Fuels', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820606
 UNION ALL SELECT intScheduleColumnId = 20605, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Fuels', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820605
 UNION ALL SELECT intScheduleColumnId = 20602, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820602
 UNION ALL SELECT intScheduleColumnId = 20603, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820603
 UNION ALL SELECT intScheduleColumnId = 20600, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820600
 UNION ALL SELECT intScheduleColumnId = 20601, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820601
 UNION ALL SELECT intScheduleColumnId = 20596, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Fuels', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820596
 UNION ALL SELECT intScheduleColumnId = 20604, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820604
 UNION ALL SELECT intScheduleColumnId = 20599, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820599
 UNION ALL SELECT intScheduleColumnId = 20598, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820598
 UNION ALL SELECT intScheduleColumnId = 20597, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820597
 UNION ALL SELECT intScheduleColumnId = 20625, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820625
 UNION ALL SELECT intScheduleColumnId = 20624, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Jet Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820624
 UNION ALL SELECT intScheduleColumnId = 20622, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Jet Fuel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820622
 UNION ALL SELECT intScheduleColumnId = 20623, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Jet Fuel', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820623
 UNION ALL SELECT intScheduleColumnId = 20621, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Jet Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820621
 UNION ALL SELECT intScheduleColumnId = 20620, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Jet Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820620
 UNION ALL SELECT intScheduleColumnId = 20617, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Jet Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820617
 UNION ALL SELECT intScheduleColumnId = 20618, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820618
 UNION ALL SELECT intScheduleColumnId = 20615, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Jet Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820615
 UNION ALL SELECT intScheduleColumnId = 20616, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820616
 UNION ALL SELECT intScheduleColumnId = 20611, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820611
 UNION ALL SELECT intScheduleColumnId = 20619, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Jet Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820619
 UNION ALL SELECT intScheduleColumnId = 20614, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820614
 UNION ALL SELECT intScheduleColumnId = 20613, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820613
 UNION ALL SELECT intScheduleColumnId = 20612, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820612
 UNION ALL SELECT intScheduleColumnId = 20189, strFormCode = '1096', strScheduleCode = '1', strType = 'Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820189
 UNION ALL SELECT intScheduleColumnId = 20187, strFormCode = '1096', strScheduleCode = '1', strType = 'Fuels', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820187
 UNION ALL SELECT intScheduleColumnId = 20188, strFormCode = '1096', strScheduleCode = '1', strType = 'Fuels', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820188
 UNION ALL SELECT intScheduleColumnId = 20183, strFormCode = '1096', strScheduleCode = '1', strType = 'Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820183
 UNION ALL SELECT intScheduleColumnId = 20184, strFormCode = '1096', strScheduleCode = '1', strType = 'Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820184
 UNION ALL SELECT intScheduleColumnId = 20181, strFormCode = '1096', strScheduleCode = '1', strType = 'Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820181
 UNION ALL SELECT intScheduleColumnId = 20182, strFormCode = '1096', strScheduleCode = '1', strType = 'Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820182
 UNION ALL SELECT intScheduleColumnId = 20176, strFormCode = '1096', strScheduleCode = '1', strType = 'Fuels', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820176
 UNION ALL SELECT intScheduleColumnId = 20180, strFormCode = '1096', strScheduleCode = '1', strType = 'Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820180
 UNION ALL SELECT intScheduleColumnId = 20179, strFormCode = '1096', strScheduleCode = '1', strType = 'Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820179
 UNION ALL SELECT intScheduleColumnId = 20178, strFormCode = '1096', strScheduleCode = '1', strType = 'Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820178
 UNION ALL SELECT intScheduleColumnId = 20177, strFormCode = '1096', strScheduleCode = '1', strType = 'Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820177
 UNION ALL SELECT intScheduleColumnId = 20186, strFormCode = '1096', strScheduleCode = '1', strType = 'Fuels', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820186
 UNION ALL SELECT intScheduleColumnId = 20185, strFormCode = '1096', strScheduleCode = '1', strType = 'Fuels', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820185
 UNION ALL SELECT intScheduleColumnId = 20205, strFormCode = '1096', strScheduleCode = '1', strType = 'Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820205
 UNION ALL SELECT intScheduleColumnId = 20204, strFormCode = '1096', strScheduleCode = '1', strType = 'Jet Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820204
 UNION ALL SELECT intScheduleColumnId = 20202, strFormCode = '1096', strScheduleCode = '1', strType = 'Jet Fuel', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820202
 UNION ALL SELECT intScheduleColumnId = 20203, strFormCode = '1096', strScheduleCode = '1', strType = 'Jet Fuel', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820203
 UNION ALL SELECT intScheduleColumnId = 20198, strFormCode = '1096', strScheduleCode = '1', strType = 'Jet Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820198
 UNION ALL SELECT intScheduleColumnId = 20199, strFormCode = '1096', strScheduleCode = '1', strType = 'Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820199
 UNION ALL SELECT intScheduleColumnId = 20196, strFormCode = '1096', strScheduleCode = '1', strType = 'Jet Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820196
 UNION ALL SELECT intScheduleColumnId = 20197, strFormCode = '1096', strScheduleCode = '1', strType = 'Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820197
 UNION ALL SELECT intScheduleColumnId = 20191, strFormCode = '1096', strScheduleCode = '1', strType = 'Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820191
 UNION ALL SELECT intScheduleColumnId = 20195, strFormCode = '1096', strScheduleCode = '1', strType = 'Jet Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820195
 UNION ALL SELECT intScheduleColumnId = 20194, strFormCode = '1096', strScheduleCode = '1', strType = 'Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820194
 UNION ALL SELECT intScheduleColumnId = 20193, strFormCode = '1096', strScheduleCode = '1', strType = 'Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820193
 UNION ALL SELECT intScheduleColumnId = 20192, strFormCode = '1096', strScheduleCode = '1', strType = 'Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820192
 UNION ALL SELECT intScheduleColumnId = 20201, strFormCode = '1096', strScheduleCode = '1', strType = 'Jet Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820201
 UNION ALL SELECT intScheduleColumnId = 20200, strFormCode = '1096', strScheduleCode = '1', strType = 'Jet Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820200
 UNION ALL SELECT intScheduleColumnId = 20175, strFormCode = '1096', strScheduleCode = '1', strType = 'Liquid Fuels', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820175
 UNION ALL SELECT intScheduleColumnId = 20174, strFormCode = '1096', strScheduleCode = '1', strType = 'Liquid Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820174
 UNION ALL SELECT intScheduleColumnId = 20172, strFormCode = '1096', strScheduleCode = '1', strType = 'Liquid Fuels', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820172
 UNION ALL SELECT intScheduleColumnId = 20173, strFormCode = '1096', strScheduleCode = '1', strType = 'Liquid Fuels', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820173
 UNION ALL SELECT intScheduleColumnId = 20168, strFormCode = '1096', strScheduleCode = '1', strType = 'Liquid Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820168
 UNION ALL SELECT intScheduleColumnId = 20169, strFormCode = '1096', strScheduleCode = '1', strType = 'Liquid Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820169
 UNION ALL SELECT intScheduleColumnId = 20166, strFormCode = '1096', strScheduleCode = '1', strType = 'Liquid Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820166
 UNION ALL SELECT intScheduleColumnId = 20167, strFormCode = '1096', strScheduleCode = '1', strType = 'Liquid Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820167
 UNION ALL SELECT intScheduleColumnId = 20161, strFormCode = '1096', strScheduleCode = '1', strType = 'Liquid Fuels', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820161
 UNION ALL SELECT intScheduleColumnId = 20165, strFormCode = '1096', strScheduleCode = '1', strType = 'Liquid Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820165
 UNION ALL SELECT intScheduleColumnId = 20164, strFormCode = '1096', strScheduleCode = '1', strType = 'Liquid Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820164
 UNION ALL SELECT intScheduleColumnId = 20163, strFormCode = '1096', strScheduleCode = '1', strType = 'Liquid Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820163
 UNION ALL SELECT intScheduleColumnId = 20162, strFormCode = '1096', strScheduleCode = '1', strType = 'Liquid Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820162
 UNION ALL SELECT intScheduleColumnId = 20171, strFormCode = '1096', strScheduleCode = '1', strType = 'Liquid Fuels', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820171
 UNION ALL SELECT intScheduleColumnId = 20170, strFormCode = '1096', strScheduleCode = '1', strType = 'Liquid Fuels', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820170
 UNION ALL SELECT intScheduleColumnId = 20940, strFormCode = '1096', strScheduleCode = '10', strType = 'Aviation Gas', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820940
 UNION ALL SELECT intScheduleColumnId = 20939, strFormCode = '1096', strScheduleCode = '10', strType = 'Aviation Gas', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820939
 UNION ALL SELECT intScheduleColumnId = 20937, strFormCode = '1096', strScheduleCode = '10', strType = 'Aviation Gas', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820937
 UNION ALL SELECT intScheduleColumnId = 20938, strFormCode = '1096', strScheduleCode = '10', strType = 'Aviation Gas', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820938
 UNION ALL SELECT intScheduleColumnId = 20936, strFormCode = '1096', strScheduleCode = '10', strType = 'Aviation Gas', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820936
 UNION ALL SELECT intScheduleColumnId = 20935, strFormCode = '1096', strScheduleCode = '10', strType = 'Aviation Gas', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820935
 UNION ALL SELECT intScheduleColumnId = 20932, strFormCode = '1096', strScheduleCode = '10', strType = 'Aviation Gas', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820932
 UNION ALL SELECT intScheduleColumnId = 20933, strFormCode = '1096', strScheduleCode = '10', strType = 'Aviation Gas', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820933
 UNION ALL SELECT intScheduleColumnId = 20930, strFormCode = '1096', strScheduleCode = '10', strType = 'Aviation Gas', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820930
 UNION ALL SELECT intScheduleColumnId = 20931, strFormCode = '1096', strScheduleCode = '10', strType = 'Aviation Gas', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820931
 UNION ALL SELECT intScheduleColumnId = 20926, strFormCode = '1096', strScheduleCode = '10', strType = 'Aviation Gas', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820926
 UNION ALL SELECT intScheduleColumnId = 20934, strFormCode = '1096', strScheduleCode = '10', strType = 'Aviation Gas', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820934
 UNION ALL SELECT intScheduleColumnId = 20929, strFormCode = '1096', strScheduleCode = '10', strType = 'Aviation Gas', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820929
 UNION ALL SELECT intScheduleColumnId = 20928, strFormCode = '1096', strScheduleCode = '10', strType = 'Aviation Gas', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820928
 UNION ALL SELECT intScheduleColumnId = 20927, strFormCode = '1096', strScheduleCode = '10', strType = 'Aviation Gas', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820927
 UNION ALL SELECT intScheduleColumnId = 20910, strFormCode = '1096', strScheduleCode = '10', strType = 'Fuels', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820910
 UNION ALL SELECT intScheduleColumnId = 20909, strFormCode = '1096', strScheduleCode = '10', strType = 'Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820909
 UNION ALL SELECT intScheduleColumnId = 20907, strFormCode = '1096', strScheduleCode = '10', strType = 'Fuels', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820907
 UNION ALL SELECT intScheduleColumnId = 20908, strFormCode = '1096', strScheduleCode = '10', strType = 'Fuels', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820908
 UNION ALL SELECT intScheduleColumnId = 20906, strFormCode = '1096', strScheduleCode = '10', strType = 'Fuels', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820906
 UNION ALL SELECT intScheduleColumnId = 20905, strFormCode = '1096', strScheduleCode = '10', strType = 'Fuels', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820905
 UNION ALL SELECT intScheduleColumnId = 20902, strFormCode = '1096', strScheduleCode = '10', strType = 'Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820902
 UNION ALL SELECT intScheduleColumnId = 20903, strFormCode = '1096', strScheduleCode = '10', strType = 'Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820903
 UNION ALL SELECT intScheduleColumnId = 20900, strFormCode = '1096', strScheduleCode = '10', strType = 'Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820900
 UNION ALL SELECT intScheduleColumnId = 20901, strFormCode = '1096', strScheduleCode = '10', strType = 'Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820901
 UNION ALL SELECT intScheduleColumnId = 20896, strFormCode = '1096', strScheduleCode = '10', strType = 'Fuels', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820896
 UNION ALL SELECT intScheduleColumnId = 20904, strFormCode = '1096', strScheduleCode = '10', strType = 'Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820904
 UNION ALL SELECT intScheduleColumnId = 20899, strFormCode = '1096', strScheduleCode = '10', strType = 'Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820899
 UNION ALL SELECT intScheduleColumnId = 20898, strFormCode = '1096', strScheduleCode = '10', strType = 'Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820898
 UNION ALL SELECT intScheduleColumnId = 20897, strFormCode = '1096', strScheduleCode = '10', strType = 'Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820897
 UNION ALL SELECT intScheduleColumnId = 20925, strFormCode = '1096', strScheduleCode = '10', strType = 'Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820925
 UNION ALL SELECT intScheduleColumnId = 20924, strFormCode = '1096', strScheduleCode = '10', strType = 'Jet Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820924
 UNION ALL SELECT intScheduleColumnId = 20922, strFormCode = '1096', strScheduleCode = '10', strType = 'Jet Fuel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820922
 UNION ALL SELECT intScheduleColumnId = 20923, strFormCode = '1096', strScheduleCode = '10', strType = 'Jet Fuel', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820923
 UNION ALL SELECT intScheduleColumnId = 20921, strFormCode = '1096', strScheduleCode = '10', strType = 'Jet Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820921
 UNION ALL SELECT intScheduleColumnId = 20920, strFormCode = '1096', strScheduleCode = '10', strType = 'Jet Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820920
 UNION ALL SELECT intScheduleColumnId = 20917, strFormCode = '1096', strScheduleCode = '10', strType = 'Jet Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820917
 UNION ALL SELECT intScheduleColumnId = 20918, strFormCode = '1096', strScheduleCode = '10', strType = 'Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820918
 UNION ALL SELECT intScheduleColumnId = 20915, strFormCode = '1096', strScheduleCode = '10', strType = 'Jet Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820915
 UNION ALL SELECT intScheduleColumnId = 20916, strFormCode = '1096', strScheduleCode = '10', strType = 'Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820916
 UNION ALL SELECT intScheduleColumnId = 20911, strFormCode = '1096', strScheduleCode = '10', strType = 'Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820911
 UNION ALL SELECT intScheduleColumnId = 20919, strFormCode = '1096', strScheduleCode = '10', strType = 'Jet Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820919
 UNION ALL SELECT intScheduleColumnId = 20914, strFormCode = '1096', strScheduleCode = '10', strType = 'Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820914
 UNION ALL SELECT intScheduleColumnId = 20913, strFormCode = '1096', strScheduleCode = '10', strType = 'Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820913
 UNION ALL SELECT intScheduleColumnId = 20912, strFormCode = '1096', strScheduleCode = '10', strType = 'Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820912
 UNION ALL SELECT intScheduleColumnId = 20895, strFormCode = '1096', strScheduleCode = '10', strType = 'Liquid Fuels', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820895
 UNION ALL SELECT intScheduleColumnId = 20894, strFormCode = '1096', strScheduleCode = '10', strType = 'Liquid Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820894
 UNION ALL SELECT intScheduleColumnId = 20892, strFormCode = '1096', strScheduleCode = '10', strType = 'Liquid Fuels', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820892
 UNION ALL SELECT intScheduleColumnId = 20893, strFormCode = '1096', strScheduleCode = '10', strType = 'Liquid Fuels', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820893
 UNION ALL SELECT intScheduleColumnId = 20891, strFormCode = '1096', strScheduleCode = '10', strType = 'Liquid Fuels', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820891
 UNION ALL SELECT intScheduleColumnId = 20890, strFormCode = '1096', strScheduleCode = '10', strType = 'Liquid Fuels', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820890
 UNION ALL SELECT intScheduleColumnId = 20887, strFormCode = '1096', strScheduleCode = '10', strType = 'Liquid Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820887
 UNION ALL SELECT intScheduleColumnId = 20888, strFormCode = '1096', strScheduleCode = '10', strType = 'Liquid Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820888
 UNION ALL SELECT intScheduleColumnId = 20885, strFormCode = '1096', strScheduleCode = '10', strType = 'Liquid Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820885
 UNION ALL SELECT intScheduleColumnId = 20886, strFormCode = '1096', strScheduleCode = '10', strType = 'Liquid Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820886
 UNION ALL SELECT intScheduleColumnId = 20881, strFormCode = '1096', strScheduleCode = '10', strType = 'Liquid Fuels', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820881
 UNION ALL SELECT intScheduleColumnId = 20889, strFormCode = '1096', strScheduleCode = '10', strType = 'Liquid Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820889
 UNION ALL SELECT intScheduleColumnId = 20884, strFormCode = '1096', strScheduleCode = '10', strType = 'Liquid Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820884
 UNION ALL SELECT intScheduleColumnId = 20883, strFormCode = '1096', strScheduleCode = '10', strType = 'Liquid Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820883
 UNION ALL SELECT intScheduleColumnId = 20882, strFormCode = '1096', strScheduleCode = '10', strType = 'Liquid Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820882
 UNION ALL SELECT intScheduleColumnId = 20280, strFormCode = '1096', strScheduleCode = '1F', strType = 'Aviation Gas', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820280
 UNION ALL SELECT intScheduleColumnId = 20279, strFormCode = '1096', strScheduleCode = '1F', strType = 'Aviation Gas', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820279
 UNION ALL SELECT intScheduleColumnId = 20277, strFormCode = '1096', strScheduleCode = '1F', strType = 'Aviation Gas', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820277
 UNION ALL SELECT intScheduleColumnId = 20278, strFormCode = '1096', strScheduleCode = '1F', strType = 'Aviation Gas', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820278
 UNION ALL SELECT intScheduleColumnId = 20273, strFormCode = '1096', strScheduleCode = '1F', strType = 'Aviation Gas', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820273
 UNION ALL SELECT intScheduleColumnId = 20274, strFormCode = '1096', strScheduleCode = '1F', strType = 'Aviation Gas', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820274
 UNION ALL SELECT intScheduleColumnId = 20271, strFormCode = '1096', strScheduleCode = '1F', strType = 'Aviation Gas', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820271
 UNION ALL SELECT intScheduleColumnId = 20272, strFormCode = '1096', strScheduleCode = '1F', strType = 'Aviation Gas', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820272
 UNION ALL SELECT intScheduleColumnId = 20266, strFormCode = '1096', strScheduleCode = '1F', strType = 'Aviation Gas', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820266
 UNION ALL SELECT intScheduleColumnId = 20270, strFormCode = '1096', strScheduleCode = '1F', strType = 'Aviation Gas', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820270
 UNION ALL SELECT intScheduleColumnId = 20269, strFormCode = '1096', strScheduleCode = '1F', strType = 'Aviation Gas', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820269
 UNION ALL SELECT intScheduleColumnId = 20268, strFormCode = '1096', strScheduleCode = '1F', strType = 'Aviation Gas', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820268
 UNION ALL SELECT intScheduleColumnId = 20267, strFormCode = '1096', strScheduleCode = '1F', strType = 'Aviation Gas', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820267
 UNION ALL SELECT intScheduleColumnId = 20276, strFormCode = '1096', strScheduleCode = '1F', strType = 'Aviation Gas', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820276
 UNION ALL SELECT intScheduleColumnId = 20275, strFormCode = '1096', strScheduleCode = '1F', strType = 'Aviation Gas', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820275
 UNION ALL SELECT intScheduleColumnId = 20250, strFormCode = '1096', strScheduleCode = '1F', strType = 'Fuels', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820250
 UNION ALL SELECT intScheduleColumnId = 20249, strFormCode = '1096', strScheduleCode = '1F', strType = 'Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820249
 UNION ALL SELECT intScheduleColumnId = 20247, strFormCode = '1096', strScheduleCode = '1F', strType = 'Fuels', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820247
 UNION ALL SELECT intScheduleColumnId = 20248, strFormCode = '1096', strScheduleCode = '1F', strType = 'Fuels', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820248
 UNION ALL SELECT intScheduleColumnId = 20243, strFormCode = '1096', strScheduleCode = '1F', strType = 'Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820243
 UNION ALL SELECT intScheduleColumnId = 20244, strFormCode = '1096', strScheduleCode = '1F', strType = 'Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820244
 UNION ALL SELECT intScheduleColumnId = 20241, strFormCode = '1096', strScheduleCode = '1F', strType = 'Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820241
 UNION ALL SELECT intScheduleColumnId = 20242, strFormCode = '1096', strScheduleCode = '1F', strType = 'Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820242
 UNION ALL SELECT intScheduleColumnId = 20595, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Liquid Fuels', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820595
 UNION ALL SELECT intScheduleColumnId = 20594, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Liquid Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820594
 UNION ALL SELECT intScheduleColumnId = 20592, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Liquid Fuels', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820592
 UNION ALL SELECT intScheduleColumnId = 20593, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Liquid Fuels', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820593
 UNION ALL SELECT intScheduleColumnId = 20591, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Liquid Fuels', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820591
 UNION ALL SELECT intScheduleColumnId = 20590, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Liquid Fuels', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820590
 UNION ALL SELECT intScheduleColumnId = 20587, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Liquid Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820587
 UNION ALL SELECT intScheduleColumnId = 20588, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Liquid Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820588
 UNION ALL SELECT intScheduleColumnId = 20585, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Liquid Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820585
 UNION ALL SELECT intScheduleColumnId = 20586, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Liquid Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820586
 UNION ALL SELECT intScheduleColumnId = 20581, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Liquid Fuels', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820581
 UNION ALL SELECT intScheduleColumnId = 20589, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Liquid Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820589
 UNION ALL SELECT intScheduleColumnId = 20584, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Liquid Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820584
 UNION ALL SELECT intScheduleColumnId = 20583, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Liquid Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820583
 UNION ALL SELECT intScheduleColumnId = 20582, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Liquid Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820582
 UNION ALL SELECT intScheduleColumnId = 20700, strFormCode = '1096', strScheduleCode = '6', strType = 'Aviation Gas', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820700
 UNION ALL SELECT intScheduleColumnId = 20699, strFormCode = '1096', strScheduleCode = '6', strType = 'Aviation Gas', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820699
 UNION ALL SELECT intScheduleColumnId = 20697, strFormCode = '1096', strScheduleCode = '6', strType = 'Aviation Gas', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820697
 UNION ALL SELECT intScheduleColumnId = 20698, strFormCode = '1096', strScheduleCode = '6', strType = 'Aviation Gas', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820698
 UNION ALL SELECT intScheduleColumnId = 20696, strFormCode = '1096', strScheduleCode = '6', strType = 'Aviation Gas', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820696
 UNION ALL SELECT intScheduleColumnId = 20695, strFormCode = '1096', strScheduleCode = '6', strType = 'Aviation Gas', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820695
 UNION ALL SELECT intScheduleColumnId = 20692, strFormCode = '1096', strScheduleCode = '6', strType = 'Aviation Gas', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820692
 UNION ALL SELECT intScheduleColumnId = 20693, strFormCode = '1096', strScheduleCode = '6', strType = 'Aviation Gas', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820693
 UNION ALL SELECT intScheduleColumnId = 20690, strFormCode = '1096', strScheduleCode = '6', strType = 'Aviation Gas', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820690
 UNION ALL SELECT intScheduleColumnId = 20691, strFormCode = '1096', strScheduleCode = '6', strType = 'Aviation Gas', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820691
 UNION ALL SELECT intScheduleColumnId = 20686, strFormCode = '1096', strScheduleCode = '6', strType = 'Aviation Gas', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820686
 UNION ALL SELECT intScheduleColumnId = 20694, strFormCode = '1096', strScheduleCode = '6', strType = 'Aviation Gas', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820694
 UNION ALL SELECT intScheduleColumnId = 20689, strFormCode = '1096', strScheduleCode = '6', strType = 'Aviation Gas', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820689
 UNION ALL SELECT intScheduleColumnId = 20688, strFormCode = '1096', strScheduleCode = '6', strType = 'Aviation Gas', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820688
 UNION ALL SELECT intScheduleColumnId = 20687, strFormCode = '1096', strScheduleCode = '6', strType = 'Aviation Gas', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820687
 UNION ALL SELECT intScheduleColumnId = 20670, strFormCode = '1096', strScheduleCode = '6', strType = 'Fuels', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820670
 UNION ALL SELECT intScheduleColumnId = 20669, strFormCode = '1096', strScheduleCode = '6', strType = 'Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820669
 UNION ALL SELECT intScheduleColumnId = 20667, strFormCode = '1096', strScheduleCode = '6', strType = 'Fuels', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820667
 UNION ALL SELECT intScheduleColumnId = 20668, strFormCode = '1096', strScheduleCode = '6', strType = 'Fuels', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820668
 UNION ALL SELECT intScheduleColumnId = 20666, strFormCode = '1096', strScheduleCode = '6', strType = 'Fuels', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820666
 UNION ALL SELECT intScheduleColumnId = 20665, strFormCode = '1096', strScheduleCode = '6', strType = 'Fuels', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820665
 UNION ALL SELECT intScheduleColumnId = 20662, strFormCode = '1096', strScheduleCode = '6', strType = 'Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820662
 UNION ALL SELECT intScheduleColumnId = 20663, strFormCode = '1096', strScheduleCode = '6', strType = 'Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820663
 UNION ALL SELECT intScheduleColumnId = 20660, strFormCode = '1096', strScheduleCode = '6', strType = 'Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820660
 UNION ALL SELECT intScheduleColumnId = 20661, strFormCode = '1096', strScheduleCode = '6', strType = 'Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820661
 UNION ALL SELECT intScheduleColumnId = 20656, strFormCode = '1096', strScheduleCode = '6', strType = 'Fuels', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820656
 UNION ALL SELECT intScheduleColumnId = 20664, strFormCode = '1096', strScheduleCode = '6', strType = 'Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820664
 UNION ALL SELECT intScheduleColumnId = 20659, strFormCode = '1096', strScheduleCode = '6', strType = 'Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820659
 UNION ALL SELECT intScheduleColumnId = 20658, strFormCode = '1096', strScheduleCode = '6', strType = 'Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820658
 UNION ALL SELECT intScheduleColumnId = 20657, strFormCode = '1096', strScheduleCode = '6', strType = 'Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820657
 UNION ALL SELECT intScheduleColumnId = 20685, strFormCode = '1096', strScheduleCode = '6', strType = 'Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820685
 UNION ALL SELECT intScheduleColumnId = 20684, strFormCode = '1096', strScheduleCode = '6', strType = 'Jet Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820684
 UNION ALL SELECT intScheduleColumnId = 20682, strFormCode = '1096', strScheduleCode = '6', strType = 'Jet Fuel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820682
 UNION ALL SELECT intScheduleColumnId = 20683, strFormCode = '1096', strScheduleCode = '6', strType = 'Jet Fuel', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820683
 UNION ALL SELECT intScheduleColumnId = 20681, strFormCode = '1096', strScheduleCode = '6', strType = 'Jet Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820681
 UNION ALL SELECT intScheduleColumnId = 20680, strFormCode = '1096', strScheduleCode = '6', strType = 'Jet Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820680
 UNION ALL SELECT intScheduleColumnId = 20677, strFormCode = '1096', strScheduleCode = '6', strType = 'Jet Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820677
 UNION ALL SELECT intScheduleColumnId = 20678, strFormCode = '1096', strScheduleCode = '6', strType = 'Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820678
 UNION ALL SELECT intScheduleColumnId = 20675, strFormCode = '1096', strScheduleCode = '6', strType = 'Jet Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820675
 UNION ALL SELECT intScheduleColumnId = 20676, strFormCode = '1096', strScheduleCode = '6', strType = 'Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820676
 UNION ALL SELECT intScheduleColumnId = 20671, strFormCode = '1096', strScheduleCode = '6', strType = 'Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820671
 UNION ALL SELECT intScheduleColumnId = 20679, strFormCode = '1096', strScheduleCode = '6', strType = 'Jet Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820679
 UNION ALL SELECT intScheduleColumnId = 20674, strFormCode = '1096', strScheduleCode = '6', strType = 'Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820674
 UNION ALL SELECT intScheduleColumnId = 20673, strFormCode = '1096', strScheduleCode = '6', strType = 'Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820673
 UNION ALL SELECT intScheduleColumnId = 20672, strFormCode = '1096', strScheduleCode = '6', strType = 'Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820672
 UNION ALL SELECT intScheduleColumnId = 20655, strFormCode = '1096', strScheduleCode = '6', strType = 'Liquid Fuels', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820655
 UNION ALL SELECT intScheduleColumnId = 20654, strFormCode = '1096', strScheduleCode = '6', strType = 'Liquid Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820654
 UNION ALL SELECT intScheduleColumnId = 20652, strFormCode = '1096', strScheduleCode = '6', strType = 'Liquid Fuels', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820652
 UNION ALL SELECT intScheduleColumnId = 20653, strFormCode = '1096', strScheduleCode = '6', strType = 'Liquid Fuels', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820653
 UNION ALL SELECT intScheduleColumnId = 20651, strFormCode = '1096', strScheduleCode = '6', strType = 'Liquid Fuels', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820651
 UNION ALL SELECT intScheduleColumnId = 20650, strFormCode = '1096', strScheduleCode = '6', strType = 'Liquid Fuels', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820650
 UNION ALL SELECT intScheduleColumnId = 20647, strFormCode = '1096', strScheduleCode = '6', strType = 'Liquid Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820647
 UNION ALL SELECT intScheduleColumnId = 20648, strFormCode = '1096', strScheduleCode = '6', strType = 'Liquid Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820648
 UNION ALL SELECT intScheduleColumnId = 20645, strFormCode = '1096', strScheduleCode = '6', strType = 'Liquid Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820645
 UNION ALL SELECT intScheduleColumnId = 20646, strFormCode = '1096', strScheduleCode = '6', strType = 'Liquid Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820646
 UNION ALL SELECT intScheduleColumnId = 20641, strFormCode = '1096', strScheduleCode = '6', strType = 'Liquid Fuels', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820641
 UNION ALL SELECT intScheduleColumnId = 20649, strFormCode = '1096', strScheduleCode = '6', strType = 'Liquid Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820649
 UNION ALL SELECT intScheduleColumnId = 20644, strFormCode = '1096', strScheduleCode = '6', strType = 'Liquid Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820644
 UNION ALL SELECT intScheduleColumnId = 20643, strFormCode = '1096', strScheduleCode = '6', strType = 'Liquid Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820643
 UNION ALL SELECT intScheduleColumnId = 20642, strFormCode = '1096', strScheduleCode = '6', strType = 'Liquid Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820642
 UNION ALL SELECT intScheduleColumnId = 20760, strFormCode = '1096', strScheduleCode = '7', strType = 'Aviation Gas', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820760
 UNION ALL SELECT intScheduleColumnId = 20759, strFormCode = '1096', strScheduleCode = '7', strType = 'Aviation Gas', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820759
 UNION ALL SELECT intScheduleColumnId = 20757, strFormCode = '1096', strScheduleCode = '7', strType = 'Aviation Gas', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820757
 UNION ALL SELECT intScheduleColumnId = 20758, strFormCode = '1096', strScheduleCode = '7', strType = 'Aviation Gas', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820758
 UNION ALL SELECT intScheduleColumnId = 20756, strFormCode = '1096', strScheduleCode = '7', strType = 'Aviation Gas', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820756
 UNION ALL SELECT intScheduleColumnId = 20755, strFormCode = '1096', strScheduleCode = '7', strType = 'Aviation Gas', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820755
 UNION ALL SELECT intScheduleColumnId = 20752, strFormCode = '1096', strScheduleCode = '7', strType = 'Aviation Gas', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820752
 UNION ALL SELECT intScheduleColumnId = 20753, strFormCode = '1096', strScheduleCode = '7', strType = 'Aviation Gas', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820753
 UNION ALL SELECT intScheduleColumnId = 20750, strFormCode = '1096', strScheduleCode = '7', strType = 'Aviation Gas', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820750
 UNION ALL SELECT intScheduleColumnId = 20751, strFormCode = '1096', strScheduleCode = '7', strType = 'Aviation Gas', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820751
 UNION ALL SELECT intScheduleColumnId = 20746, strFormCode = '1096', strScheduleCode = '7', strType = 'Aviation Gas', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820746
 UNION ALL SELECT intScheduleColumnId = 20754, strFormCode = '1096', strScheduleCode = '7', strType = 'Aviation Gas', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820754
 UNION ALL SELECT intScheduleColumnId = 20749, strFormCode = '1096', strScheduleCode = '7', strType = 'Aviation Gas', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820749
 UNION ALL SELECT intScheduleColumnId = 20748, strFormCode = '1096', strScheduleCode = '7', strType = 'Aviation Gas', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820748
 UNION ALL SELECT intScheduleColumnId = 20747, strFormCode = '1096', strScheduleCode = '7', strType = 'Aviation Gas', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820747
 UNION ALL SELECT intScheduleColumnId = 20730, strFormCode = '1096', strScheduleCode = '7', strType = 'Fuels', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820730
 UNION ALL SELECT intScheduleColumnId = 20729, strFormCode = '1096', strScheduleCode = '7', strType = 'Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820729
 UNION ALL SELECT intScheduleColumnId = 20727, strFormCode = '1096', strScheduleCode = '7', strType = 'Fuels', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820727
 UNION ALL SELECT intScheduleColumnId = 20728, strFormCode = '1096', strScheduleCode = '7', strType = 'Fuels', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820728
 UNION ALL SELECT intScheduleColumnId = 20726, strFormCode = '1096', strScheduleCode = '7', strType = 'Fuels', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820726
 UNION ALL SELECT intScheduleColumnId = 20725, strFormCode = '1096', strScheduleCode = '7', strType = 'Fuels', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820725
 UNION ALL SELECT intScheduleColumnId = 20722, strFormCode = '1096', strScheduleCode = '7', strType = 'Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820722
 UNION ALL SELECT intScheduleColumnId = 20723, strFormCode = '1096', strScheduleCode = '7', strType = 'Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820723
 UNION ALL SELECT intScheduleColumnId = 20720, strFormCode = '1096', strScheduleCode = '7', strType = 'Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820720
 UNION ALL SELECT intScheduleColumnId = 20721, strFormCode = '1096', strScheduleCode = '7', strType = 'Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820721
 UNION ALL SELECT intScheduleColumnId = 20716, strFormCode = '1096', strScheduleCode = '7', strType = 'Fuels', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820716
 UNION ALL SELECT intScheduleColumnId = 20724, strFormCode = '1096', strScheduleCode = '7', strType = 'Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820724
 UNION ALL SELECT intScheduleColumnId = 20719, strFormCode = '1096', strScheduleCode = '7', strType = 'Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820719
 UNION ALL SELECT intScheduleColumnId = 20718, strFormCode = '1096', strScheduleCode = '7', strType = 'Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820718
 UNION ALL SELECT intScheduleColumnId = 20717, strFormCode = '1096', strScheduleCode = '7', strType = 'Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820717
 UNION ALL SELECT intScheduleColumnId = 20745, strFormCode = '1096', strScheduleCode = '7', strType = 'Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820745
 UNION ALL SELECT intScheduleColumnId = 20744, strFormCode = '1096', strScheduleCode = '7', strType = 'Jet Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820744
 UNION ALL SELECT intScheduleColumnId = 20742, strFormCode = '1096', strScheduleCode = '7', strType = 'Jet Fuel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820742
 UNION ALL SELECT intScheduleColumnId = 20743, strFormCode = '1096', strScheduleCode = '7', strType = 'Jet Fuel', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820743
 UNION ALL SELECT intScheduleColumnId = 20741, strFormCode = '1096', strScheduleCode = '7', strType = 'Jet Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820741
 UNION ALL SELECT intScheduleColumnId = 20740, strFormCode = '1096', strScheduleCode = '7', strType = 'Jet Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820740
 UNION ALL SELECT intScheduleColumnId = 20737, strFormCode = '1096', strScheduleCode = '7', strType = 'Jet Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820737
 UNION ALL SELECT intScheduleColumnId = 20738, strFormCode = '1096', strScheduleCode = '7', strType = 'Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820738
 UNION ALL SELECT intScheduleColumnId = 20735, strFormCode = '1096', strScheduleCode = '7', strType = 'Jet Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820735
 UNION ALL SELECT intScheduleColumnId = 20736, strFormCode = '1096', strScheduleCode = '7', strType = 'Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820736
 UNION ALL SELECT intScheduleColumnId = 20731, strFormCode = '1096', strScheduleCode = '7', strType = 'Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820731
 UNION ALL SELECT intScheduleColumnId = 20739, strFormCode = '1096', strScheduleCode = '7', strType = 'Jet Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820739
 UNION ALL SELECT intScheduleColumnId = 20734, strFormCode = '1096', strScheduleCode = '7', strType = 'Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820734
 UNION ALL SELECT intScheduleColumnId = 20733, strFormCode = '1096', strScheduleCode = '7', strType = 'Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820733
 UNION ALL SELECT intScheduleColumnId = 20732, strFormCode = '1096', strScheduleCode = '7', strType = 'Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820732
 UNION ALL SELECT intScheduleColumnId = 20715, strFormCode = '1096', strScheduleCode = '7', strType = 'Liquid Fuels', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820715
 UNION ALL SELECT intScheduleColumnId = 20714, strFormCode = '1096', strScheduleCode = '7', strType = 'Liquid Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820714
 UNION ALL SELECT intScheduleColumnId = 20712, strFormCode = '1096', strScheduleCode = '7', strType = 'Liquid Fuels', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820712
 UNION ALL SELECT intScheduleColumnId = 20713, strFormCode = '1096', strScheduleCode = '7', strType = 'Liquid Fuels', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820713
 UNION ALL SELECT intScheduleColumnId = 20711, strFormCode = '1096', strScheduleCode = '7', strType = 'Liquid Fuels', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820711
 UNION ALL SELECT intScheduleColumnId = 20710, strFormCode = '1096', strScheduleCode = '7', strType = 'Liquid Fuels', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820710
 UNION ALL SELECT intScheduleColumnId = 20707, strFormCode = '1096', strScheduleCode = '7', strType = 'Liquid Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820707
 UNION ALL SELECT intScheduleColumnId = 20708, strFormCode = '1096', strScheduleCode = '7', strType = 'Liquid Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820708
 UNION ALL SELECT intScheduleColumnId = 20236, strFormCode = '1096', strScheduleCode = '1F', strType = 'Fuels', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820236
 UNION ALL SELECT intScheduleColumnId = 20240, strFormCode = '1096', strScheduleCode = '1F', strType = 'Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820240
 UNION ALL SELECT intScheduleColumnId = 20239, strFormCode = '1096', strScheduleCode = '1F', strType = 'Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820239
 UNION ALL SELECT intScheduleColumnId = 20238, strFormCode = '1096', strScheduleCode = '1F', strType = 'Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820238
 UNION ALL SELECT intScheduleColumnId = 20237, strFormCode = '1096', strScheduleCode = '1F', strType = 'Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820237
 UNION ALL SELECT intScheduleColumnId = 20246, strFormCode = '1096', strScheduleCode = '1F', strType = 'Fuels', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820246
 UNION ALL SELECT intScheduleColumnId = 20245, strFormCode = '1096', strScheduleCode = '1F', strType = 'Fuels', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820245
 UNION ALL SELECT intScheduleColumnId = 20265, strFormCode = '1096', strScheduleCode = '1F', strType = 'Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820265
 UNION ALL SELECT intScheduleColumnId = 20264, strFormCode = '1096', strScheduleCode = '1F', strType = 'Jet Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820264
 UNION ALL SELECT intScheduleColumnId = 20262, strFormCode = '1096', strScheduleCode = '1F', strType = 'Jet Fuel', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820262
 UNION ALL SELECT intScheduleColumnId = 20263, strFormCode = '1096', strScheduleCode = '1F', strType = 'Jet Fuel', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820263
 UNION ALL SELECT intScheduleColumnId = 20258, strFormCode = '1096', strScheduleCode = '1F', strType = 'Jet Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820258
 UNION ALL SELECT intScheduleColumnId = 20259, strFormCode = '1096', strScheduleCode = '1F', strType = 'Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820259
 UNION ALL SELECT intScheduleColumnId = 20256, strFormCode = '1096', strScheduleCode = '1F', strType = 'Jet Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820256
 UNION ALL SELECT intScheduleColumnId = 20257, strFormCode = '1096', strScheduleCode = '1F', strType = 'Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820257
 UNION ALL SELECT intScheduleColumnId = 20251, strFormCode = '1096', strScheduleCode = '1F', strType = 'Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820251
 UNION ALL SELECT intScheduleColumnId = 20255, strFormCode = '1096', strScheduleCode = '1F', strType = 'Jet Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820255
 UNION ALL SELECT intScheduleColumnId = 20254, strFormCode = '1096', strScheduleCode = '1F', strType = 'Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820254
 UNION ALL SELECT intScheduleColumnId = 20253, strFormCode = '1096', strScheduleCode = '1F', strType = 'Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820253
 UNION ALL SELECT intScheduleColumnId = 20252, strFormCode = '1096', strScheduleCode = '1F', strType = 'Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820252
 UNION ALL SELECT intScheduleColumnId = 20261, strFormCode = '1096', strScheduleCode = '1F', strType = 'Jet Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820261
 UNION ALL SELECT intScheduleColumnId = 20260, strFormCode = '1096', strScheduleCode = '1F', strType = 'Jet Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820260
 UNION ALL SELECT intScheduleColumnId = 20235, strFormCode = '1096', strScheduleCode = '1F', strType = 'Liquid Fuels', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820235
 UNION ALL SELECT intScheduleColumnId = 20234, strFormCode = '1096', strScheduleCode = '1F', strType = 'Liquid Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820234
 UNION ALL SELECT intScheduleColumnId = 20232, strFormCode = '1096', strScheduleCode = '1F', strType = 'Liquid Fuels', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820232
 UNION ALL SELECT intScheduleColumnId = 20233, strFormCode = '1096', strScheduleCode = '1F', strType = 'Liquid Fuels', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820233
 UNION ALL SELECT intScheduleColumnId = 20228, strFormCode = '1096', strScheduleCode = '1F', strType = 'Liquid Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820228
 UNION ALL SELECT intScheduleColumnId = 20229, strFormCode = '1096', strScheduleCode = '1F', strType = 'Liquid Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820229
 UNION ALL SELECT intScheduleColumnId = 20226, strFormCode = '1096', strScheduleCode = '1F', strType = 'Liquid Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820226
 UNION ALL SELECT intScheduleColumnId = 20227, strFormCode = '1096', strScheduleCode = '1F', strType = 'Liquid Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820227
 UNION ALL SELECT intScheduleColumnId = 20221, strFormCode = '1096', strScheduleCode = '1F', strType = 'Liquid Fuels', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820221
 UNION ALL SELECT intScheduleColumnId = 20225, strFormCode = '1096', strScheduleCode = '1F', strType = 'Liquid Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820225
 UNION ALL SELECT intScheduleColumnId = 20224, strFormCode = '1096', strScheduleCode = '1F', strType = 'Liquid Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820224
 UNION ALL SELECT intScheduleColumnId = 20223, strFormCode = '1096', strScheduleCode = '1F', strType = 'Liquid Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820223
 UNION ALL SELECT intScheduleColumnId = 20222, strFormCode = '1096', strScheduleCode = '1F', strType = 'Liquid Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820222
 UNION ALL SELECT intScheduleColumnId = 20231, strFormCode = '1096', strScheduleCode = '1F', strType = 'Liquid Fuels', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820231
 UNION ALL SELECT intScheduleColumnId = 20230, strFormCode = '1096', strScheduleCode = '1F', strType = 'Liquid Fuels', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820230
 UNION ALL SELECT intScheduleColumnId = 20340, strFormCode = '1096', strScheduleCode = '2', strType = 'Aviation Gas', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820340
 UNION ALL SELECT intScheduleColumnId = 20339, strFormCode = '1096', strScheduleCode = '2', strType = 'Aviation Gas', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820339
 UNION ALL SELECT intScheduleColumnId = 20337, strFormCode = '1096', strScheduleCode = '2', strType = 'Aviation Gas', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820337
 UNION ALL SELECT intScheduleColumnId = 20338, strFormCode = '1096', strScheduleCode = '2', strType = 'Aviation Gas', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820338
 UNION ALL SELECT intScheduleColumnId = 20333, strFormCode = '1096', strScheduleCode = '2', strType = 'Aviation Gas', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820333
 UNION ALL SELECT intScheduleColumnId = 20334, strFormCode = '1096', strScheduleCode = '2', strType = 'Aviation Gas', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820334
 UNION ALL SELECT intScheduleColumnId = 20331, strFormCode = '1096', strScheduleCode = '2', strType = 'Aviation Gas', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820331
 UNION ALL SELECT intScheduleColumnId = 20332, strFormCode = '1096', strScheduleCode = '2', strType = 'Aviation Gas', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820332
 UNION ALL SELECT intScheduleColumnId = 20326, strFormCode = '1096', strScheduleCode = '2', strType = 'Aviation Gas', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820326
 UNION ALL SELECT intScheduleColumnId = 20330, strFormCode = '1096', strScheduleCode = '2', strType = 'Aviation Gas', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820330
 UNION ALL SELECT intScheduleColumnId = 20329, strFormCode = '1096', strScheduleCode = '2', strType = 'Aviation Gas', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820329
 UNION ALL SELECT intScheduleColumnId = 20328, strFormCode = '1096', strScheduleCode = '2', strType = 'Aviation Gas', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820328
 UNION ALL SELECT intScheduleColumnId = 20327, strFormCode = '1096', strScheduleCode = '2', strType = 'Aviation Gas', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820327
 UNION ALL SELECT intScheduleColumnId = 20336, strFormCode = '1096', strScheduleCode = '2', strType = 'Aviation Gas', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820336
 UNION ALL SELECT intScheduleColumnId = 20335, strFormCode = '1096', strScheduleCode = '2', strType = 'Aviation Gas', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820335
 UNION ALL SELECT intScheduleColumnId = 20310, strFormCode = '1096', strScheduleCode = '2', strType = 'Fuels', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820310
 UNION ALL SELECT intScheduleColumnId = 20309, strFormCode = '1096', strScheduleCode = '2', strType = 'Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820309
 UNION ALL SELECT intScheduleColumnId = 20307, strFormCode = '1096', strScheduleCode = '2', strType = 'Fuels', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820307
 UNION ALL SELECT intScheduleColumnId = 20308, strFormCode = '1096', strScheduleCode = '2', strType = 'Fuels', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820308
 UNION ALL SELECT intScheduleColumnId = 20303, strFormCode = '1096', strScheduleCode = '2', strType = 'Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820303
 UNION ALL SELECT intScheduleColumnId = 20304, strFormCode = '1096', strScheduleCode = '2', strType = 'Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820304
 UNION ALL SELECT intScheduleColumnId = 20301, strFormCode = '1096', strScheduleCode = '2', strType = 'Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820301
 UNION ALL SELECT intScheduleColumnId = 20302, strFormCode = '1096', strScheduleCode = '2', strType = 'Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820302
 UNION ALL SELECT intScheduleColumnId = 20296, strFormCode = '1096', strScheduleCode = '2', strType = 'Fuels', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820296
 UNION ALL SELECT intScheduleColumnId = 20300, strFormCode = '1096', strScheduleCode = '2', strType = 'Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820300
 UNION ALL SELECT intScheduleColumnId = 20299, strFormCode = '1096', strScheduleCode = '2', strType = 'Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820299
 UNION ALL SELECT intScheduleColumnId = 20298, strFormCode = '1096', strScheduleCode = '2', strType = 'Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820298
 UNION ALL SELECT intScheduleColumnId = 20297, strFormCode = '1096', strScheduleCode = '2', strType = 'Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820297
 UNION ALL SELECT intScheduleColumnId = 20306, strFormCode = '1096', strScheduleCode = '2', strType = 'Fuels', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820306
 UNION ALL SELECT intScheduleColumnId = 20305, strFormCode = '1096', strScheduleCode = '2', strType = 'Fuels', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820305
 UNION ALL SELECT intScheduleColumnId = 20325, strFormCode = '1096', strScheduleCode = '2', strType = 'Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820325
 UNION ALL SELECT intScheduleColumnId = 20324, strFormCode = '1096', strScheduleCode = '2', strType = 'Jet Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820324
 UNION ALL SELECT intScheduleColumnId = 20322, strFormCode = '1096', strScheduleCode = '2', strType = 'Jet Fuel', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820322
 UNION ALL SELECT intScheduleColumnId = 20323, strFormCode = '1096', strScheduleCode = '2', strType = 'Jet Fuel', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820323
 UNION ALL SELECT intScheduleColumnId = 20318, strFormCode = '1096', strScheduleCode = '2', strType = 'Jet Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820318
 UNION ALL SELECT intScheduleColumnId = 20319, strFormCode = '1096', strScheduleCode = '2', strType = 'Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820319
 UNION ALL SELECT intScheduleColumnId = 20316, strFormCode = '1096', strScheduleCode = '2', strType = 'Jet Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820316
 UNION ALL SELECT intScheduleColumnId = 20317, strFormCode = '1096', strScheduleCode = '2', strType = 'Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820317
 UNION ALL SELECT intScheduleColumnId = 20311, strFormCode = '1096', strScheduleCode = '2', strType = 'Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820311
 UNION ALL SELECT intScheduleColumnId = 20315, strFormCode = '1096', strScheduleCode = '2', strType = 'Jet Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820315
 UNION ALL SELECT intScheduleColumnId = 20314, strFormCode = '1096', strScheduleCode = '2', strType = 'Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820314
 UNION ALL SELECT intScheduleColumnId = 20313, strFormCode = '1096', strScheduleCode = '2', strType = 'Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820313
 UNION ALL SELECT intScheduleColumnId = 20312, strFormCode = '1096', strScheduleCode = '2', strType = 'Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820312
 UNION ALL SELECT intScheduleColumnId = 20321, strFormCode = '1096', strScheduleCode = '2', strType = 'Jet Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820321
 UNION ALL SELECT intScheduleColumnId = 20320, strFormCode = '1096', strScheduleCode = '2', strType = 'Jet Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820320
 UNION ALL SELECT intScheduleColumnId = 20295, strFormCode = '1096', strScheduleCode = '2', strType = 'Liquid Fuels', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820295
 UNION ALL SELECT intScheduleColumnId = 20294, strFormCode = '1096', strScheduleCode = '2', strType = 'Liquid Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820294
 UNION ALL SELECT intScheduleColumnId = 20292, strFormCode = '1096', strScheduleCode = '2', strType = 'Liquid Fuels', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820292
 UNION ALL SELECT intScheduleColumnId = 20293, strFormCode = '1096', strScheduleCode = '2', strType = 'Liquid Fuels', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820293
 UNION ALL SELECT intScheduleColumnId = 20288, strFormCode = '1096', strScheduleCode = '2', strType = 'Liquid Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820288
 UNION ALL SELECT intScheduleColumnId = 20289, strFormCode = '1096', strScheduleCode = '2', strType = 'Liquid Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820289
 UNION ALL SELECT intScheduleColumnId = 20286, strFormCode = '1096', strScheduleCode = '2', strType = 'Liquid Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820286
 UNION ALL SELECT intScheduleColumnId = 20287, strFormCode = '1096', strScheduleCode = '2', strType = 'Liquid Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820287
 UNION ALL SELECT intScheduleColumnId = 20281, strFormCode = '1096', strScheduleCode = '2', strType = 'Liquid Fuels', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820281
 UNION ALL SELECT intScheduleColumnId = 20285, strFormCode = '1096', strScheduleCode = '2', strType = 'Liquid Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820285
 UNION ALL SELECT intScheduleColumnId = 20284, strFormCode = '1096', strScheduleCode = '2', strType = 'Liquid Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820284
 UNION ALL SELECT intScheduleColumnId = 20283, strFormCode = '1096', strScheduleCode = '2', strType = 'Liquid Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820283
 UNION ALL SELECT intScheduleColumnId = 20282, strFormCode = '1096', strScheduleCode = '2', strType = 'Liquid Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820282
 UNION ALL SELECT intScheduleColumnId = 20291, strFormCode = '1096', strScheduleCode = '2', strType = 'Liquid Fuels', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820291
 UNION ALL SELECT intScheduleColumnId = 20290, strFormCode = '1096', strScheduleCode = '2', strType = 'Liquid Fuels', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820290
 UNION ALL SELECT intScheduleColumnId = 20400, strFormCode = '1096', strScheduleCode = '2F', strType = 'Aviation Gas', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820400
 UNION ALL SELECT intScheduleColumnId = 20399, strFormCode = '1096', strScheduleCode = '2F', strType = 'Aviation Gas', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820399
 UNION ALL SELECT intScheduleColumnId = 20397, strFormCode = '1096', strScheduleCode = '2F', strType = 'Aviation Gas', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820397
 UNION ALL SELECT intScheduleColumnId = 20398, strFormCode = '1096', strScheduleCode = '2F', strType = 'Aviation Gas', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820398
 UNION ALL SELECT intScheduleColumnId = 20393, strFormCode = '1096', strScheduleCode = '2F', strType = 'Aviation Gas', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820393
 UNION ALL SELECT intScheduleColumnId = 20394, strFormCode = '1096', strScheduleCode = '2F', strType = 'Aviation Gas', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820394
 UNION ALL SELECT intScheduleColumnId = 20391, strFormCode = '1096', strScheduleCode = '2F', strType = 'Aviation Gas', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820391
 UNION ALL SELECT intScheduleColumnId = 20392, strFormCode = '1096', strScheduleCode = '2F', strType = 'Aviation Gas', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820392
 UNION ALL SELECT intScheduleColumnId = 20386, strFormCode = '1096', strScheduleCode = '2F', strType = 'Aviation Gas', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820386
 UNION ALL SELECT intScheduleColumnId = 20390, strFormCode = '1096', strScheduleCode = '2F', strType = 'Aviation Gas', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820390
 UNION ALL SELECT intScheduleColumnId = 20389, strFormCode = '1096', strScheduleCode = '2F', strType = 'Aviation Gas', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820389
 UNION ALL SELECT intScheduleColumnId = 20388, strFormCode = '1096', strScheduleCode = '2F', strType = 'Aviation Gas', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820388
 UNION ALL SELECT intScheduleColumnId = 20387, strFormCode = '1096', strScheduleCode = '2F', strType = 'Aviation Gas', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820387
 UNION ALL SELECT intScheduleColumnId = 20396, strFormCode = '1096', strScheduleCode = '2F', strType = 'Aviation Gas', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820396
 UNION ALL SELECT intScheduleColumnId = 20395, strFormCode = '1096', strScheduleCode = '2F', strType = 'Aviation Gas', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820395
 UNION ALL SELECT intScheduleColumnId = 20370, strFormCode = '1096', strScheduleCode = '2F', strType = 'Fuels', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820370
 UNION ALL SELECT intScheduleColumnId = 20369, strFormCode = '1096', strScheduleCode = '2F', strType = 'Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820369
 UNION ALL SELECT intScheduleColumnId = 20367, strFormCode = '1096', strScheduleCode = '2F', strType = 'Fuels', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820367
 UNION ALL SELECT intScheduleColumnId = 20368, strFormCode = '1096', strScheduleCode = '2F', strType = 'Fuels', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820368
 UNION ALL SELECT intScheduleColumnId = 20363, strFormCode = '1096', strScheduleCode = '2F', strType = 'Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820363
 UNION ALL SELECT intScheduleColumnId = 20364, strFormCode = '1096', strScheduleCode = '2F', strType = 'Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820364
 UNION ALL SELECT intScheduleColumnId = 20361, strFormCode = '1096', strScheduleCode = '2F', strType = 'Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820361
 UNION ALL SELECT intScheduleColumnId = 20362, strFormCode = '1096', strScheduleCode = '2F', strType = 'Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820362
 UNION ALL SELECT intScheduleColumnId = 20356, strFormCode = '1096', strScheduleCode = '2F', strType = 'Fuels', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820356
 UNION ALL SELECT intScheduleColumnId = 20360, strFormCode = '1096', strScheduleCode = '2F', strType = 'Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820360
 UNION ALL SELECT intScheduleColumnId = 20359, strFormCode = '1096', strScheduleCode = '2F', strType = 'Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820359
 UNION ALL SELECT intScheduleColumnId = 20358, strFormCode = '1096', strScheduleCode = '2F', strType = 'Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820358
 UNION ALL SELECT intScheduleColumnId = 20357, strFormCode = '1096', strScheduleCode = '2F', strType = 'Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820357
 UNION ALL SELECT intScheduleColumnId = 20366, strFormCode = '1096', strScheduleCode = '2F', strType = 'Fuels', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820366
 UNION ALL SELECT intScheduleColumnId = 20365, strFormCode = '1096', strScheduleCode = '2F', strType = 'Fuels', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820365
 UNION ALL SELECT intScheduleColumnId = 20705, strFormCode = '1096', strScheduleCode = '7', strType = 'Liquid Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820705
 UNION ALL SELECT intScheduleColumnId = 20706, strFormCode = '1096', strScheduleCode = '7', strType = 'Liquid Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820706
 UNION ALL SELECT intScheduleColumnId = 20701, strFormCode = '1096', strScheduleCode = '7', strType = 'Liquid Fuels', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820701
 UNION ALL SELECT intScheduleColumnId = 20709, strFormCode = '1096', strScheduleCode = '7', strType = 'Liquid Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820709
 UNION ALL SELECT intScheduleColumnId = 20704, strFormCode = '1096', strScheduleCode = '7', strType = 'Liquid Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820704
 UNION ALL SELECT intScheduleColumnId = 20703, strFormCode = '1096', strScheduleCode = '7', strType = 'Liquid Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820703
 UNION ALL SELECT intScheduleColumnId = 20702, strFormCode = '1096', strScheduleCode = '7', strType = 'Liquid Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820702
 UNION ALL SELECT intScheduleColumnId = 20820, strFormCode = '1096', strScheduleCode = '8', strType = 'Aviation Gas', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820820
 UNION ALL SELECT intScheduleColumnId = 20819, strFormCode = '1096', strScheduleCode = '8', strType = 'Aviation Gas', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820819
 UNION ALL SELECT intScheduleColumnId = 20817, strFormCode = '1096', strScheduleCode = '8', strType = 'Aviation Gas', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820817
 UNION ALL SELECT intScheduleColumnId = 20818, strFormCode = '1096', strScheduleCode = '8', strType = 'Aviation Gas', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820818
 UNION ALL SELECT intScheduleColumnId = 20816, strFormCode = '1096', strScheduleCode = '8', strType = 'Aviation Gas', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820816
 UNION ALL SELECT intScheduleColumnId = 20815, strFormCode = '1096', strScheduleCode = '8', strType = 'Aviation Gas', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820815
 UNION ALL SELECT intScheduleColumnId = 20812, strFormCode = '1096', strScheduleCode = '8', strType = 'Aviation Gas', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820812
 UNION ALL SELECT intScheduleColumnId = 20813, strFormCode = '1096', strScheduleCode = '8', strType = 'Aviation Gas', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820813
 UNION ALL SELECT intScheduleColumnId = 20810, strFormCode = '1096', strScheduleCode = '8', strType = 'Aviation Gas', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820810
 UNION ALL SELECT intScheduleColumnId = 20811, strFormCode = '1096', strScheduleCode = '8', strType = 'Aviation Gas', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820811
 UNION ALL SELECT intScheduleColumnId = 20806, strFormCode = '1096', strScheduleCode = '8', strType = 'Aviation Gas', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820806
 UNION ALL SELECT intScheduleColumnId = 20814, strFormCode = '1096', strScheduleCode = '8', strType = 'Aviation Gas', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820814
 UNION ALL SELECT intScheduleColumnId = 20809, strFormCode = '1096', strScheduleCode = '8', strType = 'Aviation Gas', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820809
 UNION ALL SELECT intScheduleColumnId = 20808, strFormCode = '1096', strScheduleCode = '8', strType = 'Aviation Gas', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820808
 UNION ALL SELECT intScheduleColumnId = 20807, strFormCode = '1096', strScheduleCode = '8', strType = 'Aviation Gas', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820807
 UNION ALL SELECT intScheduleColumnId = 20790, strFormCode = '1096', strScheduleCode = '8', strType = 'Fuels', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820790
 UNION ALL SELECT intScheduleColumnId = 20789, strFormCode = '1096', strScheduleCode = '8', strType = 'Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820789
 UNION ALL SELECT intScheduleColumnId = 20787, strFormCode = '1096', strScheduleCode = '8', strType = 'Fuels', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820787
 UNION ALL SELECT intScheduleColumnId = 20788, strFormCode = '1096', strScheduleCode = '8', strType = 'Fuels', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820788
 UNION ALL SELECT intScheduleColumnId = 20786, strFormCode = '1096', strScheduleCode = '8', strType = 'Fuels', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820786
 UNION ALL SELECT intScheduleColumnId = 20785, strFormCode = '1096', strScheduleCode = '8', strType = 'Fuels', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820785
 UNION ALL SELECT intScheduleColumnId = 20782, strFormCode = '1096', strScheduleCode = '8', strType = 'Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820782
 UNION ALL SELECT intScheduleColumnId = 20783, strFormCode = '1096', strScheduleCode = '8', strType = 'Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820783
 UNION ALL SELECT intScheduleColumnId = 20780, strFormCode = '1096', strScheduleCode = '8', strType = 'Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820780
 UNION ALL SELECT intScheduleColumnId = 20781, strFormCode = '1096', strScheduleCode = '8', strType = 'Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820781
 UNION ALL SELECT intScheduleColumnId = 20776, strFormCode = '1096', strScheduleCode = '8', strType = 'Fuels', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820776
 UNION ALL SELECT intScheduleColumnId = 20784, strFormCode = '1096', strScheduleCode = '8', strType = 'Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820784
 UNION ALL SELECT intScheduleColumnId = 20779, strFormCode = '1096', strScheduleCode = '8', strType = 'Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820779
 UNION ALL SELECT intScheduleColumnId = 20778, strFormCode = '1096', strScheduleCode = '8', strType = 'Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820778
 UNION ALL SELECT intScheduleColumnId = 20777, strFormCode = '1096', strScheduleCode = '8', strType = 'Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820777
 UNION ALL SELECT intScheduleColumnId = 20805, strFormCode = '1096', strScheduleCode = '8', strType = 'Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820805
 UNION ALL SELECT intScheduleColumnId = 20804, strFormCode = '1096', strScheduleCode = '8', strType = 'Jet Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820804
 UNION ALL SELECT intScheduleColumnId = 20802, strFormCode = '1096', strScheduleCode = '8', strType = 'Jet Fuel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820802
 UNION ALL SELECT intScheduleColumnId = 20803, strFormCode = '1096', strScheduleCode = '8', strType = 'Jet Fuel', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820803
 UNION ALL SELECT intScheduleColumnId = 20801, strFormCode = '1096', strScheduleCode = '8', strType = 'Jet Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820801
 UNION ALL SELECT intScheduleColumnId = 20800, strFormCode = '1096', strScheduleCode = '8', strType = 'Jet Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820800
 UNION ALL SELECT intScheduleColumnId = 20797, strFormCode = '1096', strScheduleCode = '8', strType = 'Jet Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820797
 UNION ALL SELECT intScheduleColumnId = 20798, strFormCode = '1096', strScheduleCode = '8', strType = 'Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820798
 UNION ALL SELECT intScheduleColumnId = 20795, strFormCode = '1096', strScheduleCode = '8', strType = 'Jet Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820795
 UNION ALL SELECT intScheduleColumnId = 20796, strFormCode = '1096', strScheduleCode = '8', strType = 'Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820796
 UNION ALL SELECT intScheduleColumnId = 20791, strFormCode = '1096', strScheduleCode = '8', strType = 'Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820791
 UNION ALL SELECT intScheduleColumnId = 20799, strFormCode = '1096', strScheduleCode = '8', strType = 'Jet Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820799
 UNION ALL SELECT intScheduleColumnId = 20794, strFormCode = '1096', strScheduleCode = '8', strType = 'Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820794
 UNION ALL SELECT intScheduleColumnId = 20793, strFormCode = '1096', strScheduleCode = '8', strType = 'Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820793
 UNION ALL SELECT intScheduleColumnId = 20792, strFormCode = '1096', strScheduleCode = '8', strType = 'Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820792
 UNION ALL SELECT intScheduleColumnId = 20775, strFormCode = '1096', strScheduleCode = '8', strType = 'Liquid Fuels', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820775
 UNION ALL SELECT intScheduleColumnId = 20774, strFormCode = '1096', strScheduleCode = '8', strType = 'Liquid Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820774
 UNION ALL SELECT intScheduleColumnId = 20772, strFormCode = '1096', strScheduleCode = '8', strType = 'Liquid Fuels', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820772
 UNION ALL SELECT intScheduleColumnId = 20773, strFormCode = '1096', strScheduleCode = '8', strType = 'Liquid Fuels', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820773
 UNION ALL SELECT intScheduleColumnId = 20771, strFormCode = '1096', strScheduleCode = '8', strType = 'Liquid Fuels', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820771
 UNION ALL SELECT intScheduleColumnId = 20770, strFormCode = '1096', strScheduleCode = '8', strType = 'Liquid Fuels', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820770
 UNION ALL SELECT intScheduleColumnId = 20767, strFormCode = '1096', strScheduleCode = '8', strType = 'Liquid Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820767
 UNION ALL SELECT intScheduleColumnId = 20768, strFormCode = '1096', strScheduleCode = '8', strType = 'Liquid Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820768
 UNION ALL SELECT intScheduleColumnId = 20765, strFormCode = '1096', strScheduleCode = '8', strType = 'Liquid Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820765
 UNION ALL SELECT intScheduleColumnId = 20766, strFormCode = '1096', strScheduleCode = '8', strType = 'Liquid Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820766
 UNION ALL SELECT intScheduleColumnId = 20761, strFormCode = '1096', strScheduleCode = '8', strType = 'Liquid Fuels', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820761
 UNION ALL SELECT intScheduleColumnId = 20769, strFormCode = '1096', strScheduleCode = '8', strType = 'Liquid Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820769
 UNION ALL SELECT intScheduleColumnId = 20764, strFormCode = '1096', strScheduleCode = '8', strType = 'Liquid Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820764
 UNION ALL SELECT intScheduleColumnId = 20763, strFormCode = '1096', strScheduleCode = '8', strType = 'Liquid Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820763
 UNION ALL SELECT intScheduleColumnId = 20762, strFormCode = '1096', strScheduleCode = '8', strType = 'Liquid Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820762
 UNION ALL SELECT intScheduleColumnId = 20880, strFormCode = '1096', strScheduleCode = '9', strType = 'Aviation Gas', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820880
 UNION ALL SELECT intScheduleColumnId = 20879, strFormCode = '1096', strScheduleCode = '9', strType = 'Aviation Gas', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820879
 UNION ALL SELECT intScheduleColumnId = 20877, strFormCode = '1096', strScheduleCode = '9', strType = 'Aviation Gas', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820877
 UNION ALL SELECT intScheduleColumnId = 20878, strFormCode = '1096', strScheduleCode = '9', strType = 'Aviation Gas', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820878
 UNION ALL SELECT intScheduleColumnId = 20876, strFormCode = '1096', strScheduleCode = '9', strType = 'Aviation Gas', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820876
 UNION ALL SELECT intScheduleColumnId = 20875, strFormCode = '1096', strScheduleCode = '9', strType = 'Aviation Gas', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820875
 UNION ALL SELECT intScheduleColumnId = 20872, strFormCode = '1096', strScheduleCode = '9', strType = 'Aviation Gas', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820872
 UNION ALL SELECT intScheduleColumnId = 20873, strFormCode = '1096', strScheduleCode = '9', strType = 'Aviation Gas', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820873
 UNION ALL SELECT intScheduleColumnId = 20870, strFormCode = '1096', strScheduleCode = '9', strType = 'Aviation Gas', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820870
 UNION ALL SELECT intScheduleColumnId = 20871, strFormCode = '1096', strScheduleCode = '9', strType = 'Aviation Gas', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820871
 UNION ALL SELECT intScheduleColumnId = 20866, strFormCode = '1096', strScheduleCode = '9', strType = 'Aviation Gas', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820866
 UNION ALL SELECT intScheduleColumnId = 20874, strFormCode = '1096', strScheduleCode = '9', strType = 'Aviation Gas', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820874
 UNION ALL SELECT intScheduleColumnId = 20869, strFormCode = '1096', strScheduleCode = '9', strType = 'Aviation Gas', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820869
 UNION ALL SELECT intScheduleColumnId = 20868, strFormCode = '1096', strScheduleCode = '9', strType = 'Aviation Gas', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820868
 UNION ALL SELECT intScheduleColumnId = 20867, strFormCode = '1096', strScheduleCode = '9', strType = 'Aviation Gas', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820867
 UNION ALL SELECT intScheduleColumnId = 20850, strFormCode = '1096', strScheduleCode = '9', strType = 'Fuels', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820850
 UNION ALL SELECT intScheduleColumnId = 20849, strFormCode = '1096', strScheduleCode = '9', strType = 'Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820849
 UNION ALL SELECT intScheduleColumnId = 20847, strFormCode = '1096', strScheduleCode = '9', strType = 'Fuels', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820847
 UNION ALL SELECT intScheduleColumnId = 20848, strFormCode = '1096', strScheduleCode = '9', strType = 'Fuels', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820848
 UNION ALL SELECT intScheduleColumnId = 20846, strFormCode = '1096', strScheduleCode = '9', strType = 'Fuels', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820846
 UNION ALL SELECT intScheduleColumnId = 20845, strFormCode = '1096', strScheduleCode = '9', strType = 'Fuels', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820845
 UNION ALL SELECT intScheduleColumnId = 20842, strFormCode = '1096', strScheduleCode = '9', strType = 'Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820842
 UNION ALL SELECT intScheduleColumnId = 20843, strFormCode = '1096', strScheduleCode = '9', strType = 'Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820843
 UNION ALL SELECT intScheduleColumnId = 20840, strFormCode = '1096', strScheduleCode = '9', strType = 'Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820840
 UNION ALL SELECT intScheduleColumnId = 20841, strFormCode = '1096', strScheduleCode = '9', strType = 'Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820841
 UNION ALL SELECT intScheduleColumnId = 20836, strFormCode = '1096', strScheduleCode = '9', strType = 'Fuels', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820836
 UNION ALL SELECT intScheduleColumnId = 20844, strFormCode = '1096', strScheduleCode = '9', strType = 'Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820844
 UNION ALL SELECT intScheduleColumnId = 20839, strFormCode = '1096', strScheduleCode = '9', strType = 'Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820839
 UNION ALL SELECT intScheduleColumnId = 20838, strFormCode = '1096', strScheduleCode = '9', strType = 'Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820838
 UNION ALL SELECT intScheduleColumnId = 20837, strFormCode = '1096', strScheduleCode = '9', strType = 'Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820837
 UNION ALL SELECT intScheduleColumnId = 20865, strFormCode = '1096', strScheduleCode = '9', strType = 'Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820865
 UNION ALL SELECT intScheduleColumnId = 20864, strFormCode = '1096', strScheduleCode = '9', strType = 'Jet Fuel', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820864
 UNION ALL SELECT intScheduleColumnId = 20862, strFormCode = '1096', strScheduleCode = '9', strType = 'Jet Fuel', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820862
 UNION ALL SELECT intScheduleColumnId = 20863, strFormCode = '1096', strScheduleCode = '9', strType = 'Jet Fuel', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820863
 UNION ALL SELECT intScheduleColumnId = 20861, strFormCode = '1096', strScheduleCode = '9', strType = 'Jet Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820861
 UNION ALL SELECT intScheduleColumnId = 20860, strFormCode = '1096', strScheduleCode = '9', strType = 'Jet Fuel', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820860
 UNION ALL SELECT intScheduleColumnId = 20857, strFormCode = '1096', strScheduleCode = '9', strType = 'Jet Fuel', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820857
 UNION ALL SELECT intScheduleColumnId = 20858, strFormCode = '1096', strScheduleCode = '9', strType = 'Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820858
 UNION ALL SELECT intScheduleColumnId = 20855, strFormCode = '1096', strScheduleCode = '9', strType = 'Jet Fuel', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820855
 UNION ALL SELECT intScheduleColumnId = 20856, strFormCode = '1096', strScheduleCode = '9', strType = 'Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820856
 UNION ALL SELECT intScheduleColumnId = 20851, strFormCode = '1096', strScheduleCode = '9', strType = 'Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820851
 UNION ALL SELECT intScheduleColumnId = 20859, strFormCode = '1096', strScheduleCode = '9', strType = 'Jet Fuel', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820859
 UNION ALL SELECT intScheduleColumnId = 20854, strFormCode = '1096', strScheduleCode = '9', strType = 'Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820854
 UNION ALL SELECT intScheduleColumnId = 20853, strFormCode = '1096', strScheduleCode = '9', strType = 'Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820853
 UNION ALL SELECT intScheduleColumnId = 20852, strFormCode = '1096', strScheduleCode = '9', strType = 'Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820852
 UNION ALL SELECT intScheduleColumnId = 20835, strFormCode = '1096', strScheduleCode = '9', strType = 'Liquid Fuels', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820835
 UNION ALL SELECT intScheduleColumnId = 20834, strFormCode = '1096', strScheduleCode = '9', strType = 'Liquid Fuels', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820834
 UNION ALL SELECT intScheduleColumnId = 20832, strFormCode = '1096', strScheduleCode = '9', strType = 'Liquid Fuels', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820832
 UNION ALL SELECT intScheduleColumnId = 20833, strFormCode = '1096', strScheduleCode = '9', strType = 'Liquid Fuels', strColumn = 'strBillofLading', strCaption = 'Document No', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820833
 UNION ALL SELECT intScheduleColumnId = 20831, strFormCode = '1096', strScheduleCode = '9', strType = 'Liquid Fuels', strColumn = 'strCustomerFederalTaxId', strCaption = 'Buyer FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820831
 UNION ALL SELECT intScheduleColumnId = 20830, strFormCode = '1096', strScheduleCode = '9', strType = 'Liquid Fuels', strColumn = 'strCustomerName', strCaption = 'Buyer Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820830
 UNION ALL SELECT intScheduleColumnId = 20827, strFormCode = '1096', strScheduleCode = '9', strType = 'Liquid Fuels', strColumn = 'strDestinationCity', strCaption = 'Destination City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820827
 UNION ALL SELECT intScheduleColumnId = 20828, strFormCode = '1096', strScheduleCode = '9', strType = 'Liquid Fuels', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820828
 UNION ALL SELECT intScheduleColumnId = 20825, strFormCode = '1096', strScheduleCode = '9', strType = 'Liquid Fuels', strColumn = 'strOriginCity', strCaption = 'Origin City', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820825
 UNION ALL SELECT intScheduleColumnId = 20826, strFormCode = '1096', strScheduleCode = '9', strType = 'Liquid Fuels', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820826
 UNION ALL SELECT intScheduleColumnId = 20821, strFormCode = '1096', strScheduleCode = '9', strType = 'Liquid Fuels', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820821
 UNION ALL SELECT intScheduleColumnId = 20829, strFormCode = '1096', strScheduleCode = '9', strType = 'Liquid Fuels', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820829
 UNION ALL SELECT intScheduleColumnId = 20824, strFormCode = '1096', strScheduleCode = '9', strType = 'Liquid Fuels', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820824
 UNION ALL SELECT intScheduleColumnId = 20823, strFormCode = '1096', strScheduleCode = '9', strType = 'Liquid Fuels', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820823
 UNION ALL SELECT intScheduleColumnId = 20822, strFormCode = '1096', strScheduleCode = '9', strType = 'Liquid Fuels', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820822
 UNION ALL SELECT intScheduleColumnId = 20955, strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0, intMasterId = 3820955
 

EXEC uspTFUpgradeReportingComponentOutputDesigners @TaxAuthorityCode = @TaxAuthorityCode, @ReportingComponentOutputDesigners = @ReportingComponentOutputDesigners

	-- Filing Packet
	/* Generate script for Filing Packets. Specify Tax Authority Id to filter out specific Filing Packets only.
select strQuery = 'UNION ALL SELECT intFilingPacketId = ' + CAST(intFilingPacketId AS NVARCHAR(10))
		+ CASE WHEN strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
		+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
		+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END
		+ CASE WHEN ysnStatus IS NULL THEN ', ysnStatus = NULL' ELSE ', ysnStatus = ' + CAST(ysnStatus AS NVARCHAR) END
		+ CASE WHEN intFrequency IS NULL THEN ', intFrequency = NULL' ELSE ', intFrequency = ' + CAST(intFrequency AS NVARCHAR(10)) END
		+ ', intMasterId = ' + CASE WHEN FP.intMasterId IS NULL THEN CAST(38 AS NVARCHAR(20)) + CAST(intFilingPacketId AS NVARCHAR(20)) ELSE CAST(FP.intMasterId AS NVARCHAR(20)) END
	from tblTFFilingPacket FP
	left join tblTFReportingComponent RC on RC.intReportingComponentId = FP.intReportingComponentId
	where FP.intTaxAuthorityId = 38
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
	-- Insert generated script here. Remove first instance of "UNION ALL "
 SELECT intFilingPacketId = 2422, strFormCode = '1096', strScheduleCode = '1', strType = 'Aviation Gas', ysnStatus = 1, intFrequency = 1, intMasterId = 382422
 UNION ALL SELECT intFilingPacketId = 2423, strFormCode = '1096', strScheduleCode = '1', strType = 'Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 382423
 UNION ALL SELECT intFilingPacketId = 2424, strFormCode = '1096', strScheduleCode = '1', strType = 'Jet Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 382424
 UNION ALL SELECT intFilingPacketId = 2425, strFormCode = '1096', strScheduleCode = '1', strType = 'Liquid Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 382425
 UNION ALL SELECT intFilingPacketId = 2426, strFormCode = '1096', strScheduleCode = '10', strType = 'Aviation Gas', ysnStatus = 1, intFrequency = 1, intMasterId = 382426
 UNION ALL SELECT intFilingPacketId = 2427, strFormCode = '1096', strScheduleCode = '10', strType = 'Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 382427
 UNION ALL SELECT intFilingPacketId = 2428, strFormCode = '1096', strScheduleCode = '10', strType = 'Jet Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 382428
 UNION ALL SELECT intFilingPacketId = 2429, strFormCode = '1096', strScheduleCode = '10', strType = 'Liquid Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 382429
 UNION ALL SELECT intFilingPacketId = 2430, strFormCode = '1096', strScheduleCode = '1F', strType = 'Aviation Gas', ysnStatus = 1, intFrequency = 1, intMasterId = 382430
 UNION ALL SELECT intFilingPacketId = 2431, strFormCode = '1096', strScheduleCode = '1F', strType = 'Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 382431
 UNION ALL SELECT intFilingPacketId = 2432, strFormCode = '1096', strScheduleCode = '1F', strType = 'Jet Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 382432
 UNION ALL SELECT intFilingPacketId = 2433, strFormCode = '1096', strScheduleCode = '1F', strType = 'Liquid Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 382433
 UNION ALL SELECT intFilingPacketId = 2434, strFormCode = '1096', strScheduleCode = '2', strType = 'Aviation Gas', ysnStatus = 1, intFrequency = 1, intMasterId = 382434
 UNION ALL SELECT intFilingPacketId = 2435, strFormCode = '1096', strScheduleCode = '2', strType = 'Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 382435
 UNION ALL SELECT intFilingPacketId = 2436, strFormCode = '1096', strScheduleCode = '2', strType = 'Jet Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 382436
 UNION ALL SELECT intFilingPacketId = 2437, strFormCode = '1096', strScheduleCode = '2', strType = 'Liquid Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 382437
 UNION ALL SELECT intFilingPacketId = 2438, strFormCode = '1096', strScheduleCode = '2F', strType = 'Aviation Gas', ysnStatus = 1, intFrequency = 1, intMasterId = 382438
 UNION ALL SELECT intFilingPacketId = 2439, strFormCode = '1096', strScheduleCode = '2F', strType = 'Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 382439
 UNION ALL SELECT intFilingPacketId = 2440, strFormCode = '1096', strScheduleCode = '2F', strType = 'Jet Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 382440
 UNION ALL SELECT intFilingPacketId = 2441, strFormCode = '1096', strScheduleCode = '2F', strType = 'Liquid Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 382441
 UNION ALL SELECT intFilingPacketId = 2442, strFormCode = '1096', strScheduleCode = '3', strType = 'Aviation Gas', ysnStatus = 1, intFrequency = 1, intMasterId = 382442
 UNION ALL SELECT intFilingPacketId = 2443, strFormCode = '1096', strScheduleCode = '3', strType = 'Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 382443
 UNION ALL SELECT intFilingPacketId = 2444, strFormCode = '1096', strScheduleCode = '3', strType = 'Jet Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 382444
 UNION ALL SELECT intFilingPacketId = 2445, strFormCode = '1096', strScheduleCode = '3', strType = 'Liquid Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 382445
 UNION ALL SELECT intFilingPacketId = 2446, strFormCode = '1096', strScheduleCode = '4', strType = 'Aviation Gas', ysnStatus = 1, intFrequency = 1, intMasterId = 382446
 UNION ALL SELECT intFilingPacketId = 2447, strFormCode = '1096', strScheduleCode = '4', strType = 'Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 382447
 UNION ALL SELECT intFilingPacketId = 2448, strFormCode = '1096', strScheduleCode = '4', strType = 'Jet Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 382448
 UNION ALL SELECT intFilingPacketId = 2449, strFormCode = '1096', strScheduleCode = '4', strType = 'Liquid Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 382449
 UNION ALL SELECT intFilingPacketId = 2450, strFormCode = '1096', strScheduleCode = '5', strType = 'Aviation Gas', ysnStatus = 1, intFrequency = 1, intMasterId = 382450
 UNION ALL SELECT intFilingPacketId = 2451, strFormCode = '1096', strScheduleCode = '5', strType = 'Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 382451
 UNION ALL SELECT intFilingPacketId = 2452, strFormCode = '1096', strScheduleCode = '5', strType = 'Jet Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 382452
 UNION ALL SELECT intFilingPacketId = 2453, strFormCode = '1096', strScheduleCode = '5', strType = 'Liquid Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 382453
 UNION ALL SELECT intFilingPacketId = 2454, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Aviation Gas', ysnStatus = 1, intFrequency = 1, intMasterId = 382454
 UNION ALL SELECT intFilingPacketId = 2455, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 382455
 UNION ALL SELECT intFilingPacketId = 2456, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Jet Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 382456
 UNION ALL SELECT intFilingPacketId = 2457, strFormCode = '1096', strScheduleCode = '5Q', strType = 'Liquid Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 382457
 UNION ALL SELECT intFilingPacketId = 2458, strFormCode = '1096', strScheduleCode = '6', strType = 'Aviation Gas', ysnStatus = 1, intFrequency = 1, intMasterId = 382458
 UNION ALL SELECT intFilingPacketId = 2459, strFormCode = '1096', strScheduleCode = '6', strType = 'Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 382459
 UNION ALL SELECT intFilingPacketId = 2460, strFormCode = '1096', strScheduleCode = '6', strType = 'Jet Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 382460
 UNION ALL SELECT intFilingPacketId = 2461, strFormCode = '1096', strScheduleCode = '6', strType = 'Liquid Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 382461
 UNION ALL SELECT intFilingPacketId = 2462, strFormCode = '1096', strScheduleCode = '7', strType = 'Aviation Gas', ysnStatus = 1, intFrequency = 1, intMasterId = 382462
 UNION ALL SELECT intFilingPacketId = 2463, strFormCode = '1096', strScheduleCode = '7', strType = 'Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 382463
 UNION ALL SELECT intFilingPacketId = 2464, strFormCode = '1096', strScheduleCode = '7', strType = 'Jet Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 382464
 UNION ALL SELECT intFilingPacketId = 2465, strFormCode = '1096', strScheduleCode = '7', strType = 'Liquid Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 382465
 UNION ALL SELECT intFilingPacketId = 2466, strFormCode = '1096', strScheduleCode = '8', strType = 'Aviation Gas', ysnStatus = 1, intFrequency = 1, intMasterId = 382466
 UNION ALL SELECT intFilingPacketId = 2467, strFormCode = '1096', strScheduleCode = '8', strType = 'Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 382467
 UNION ALL SELECT intFilingPacketId = 2468, strFormCode = '1096', strScheduleCode = '8', strType = 'Jet Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 382468
 UNION ALL SELECT intFilingPacketId = 2469, strFormCode = '1096', strScheduleCode = '8', strType = 'Liquid Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 382469
 UNION ALL SELECT intFilingPacketId = 2470, strFormCode = '1096', strScheduleCode = '9', strType = 'Aviation Gas', ysnStatus = 1, intFrequency = 1, intMasterId = 382470
 UNION ALL SELECT intFilingPacketId = 2471, strFormCode = '1096', strScheduleCode = '9', strType = 'Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 382471
 UNION ALL SELECT intFilingPacketId = 2472, strFormCode = '1096', strScheduleCode = '9', strType = 'Jet Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 382472
 UNION ALL SELECT intFilingPacketId = 2473, strFormCode = '1096', strScheduleCode = '9', strType = 'Liquid Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 382473
 UNION ALL SELECT intFilingPacketId = 2474, strFormCode = 'DMF-26', strScheduleCode = '1A', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 382474
 UNION ALL SELECT intFilingPacketId = 2475, strFormCode = 'DMF-26', strScheduleCode = '2A', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 382475
 UNION ALL SELECT intFilingPacketId = 2476, strFormCode = 'DMF-26', strScheduleCode = '3A', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 382476
 UNION ALL SELECT intFilingPacketId = 2477, strFormCode = 'PA Efile', strScheduleCode = 'PA E File', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 382477
 

EXEC uspTFUpgradeFilingPackets @TaxAuthorityCode = @TaxAuthorityCode, @FilingPackets = @FilingPackets

END
GO