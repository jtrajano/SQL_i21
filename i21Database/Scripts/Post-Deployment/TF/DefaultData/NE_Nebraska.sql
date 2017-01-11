﻿-- Declare the Tax Authority Code that will be used all throughout Nebraska Default Data
PRINT ('Deploying Nebraska Tax Forms')
DECLARE @TaxAuthorityCode NVARCHAR(10) = 'NE'


-- Product Codes
/* Generate script for Product Codes. Specify Tax Authority Id to filter out specific Product Codes only.
select 'UNION ALL SELECT intProductCodeId = ' + CAST(intProductCodeId AS NVARCHAR(10)) 
	+ CASE WHEN strProductCode IS NULL THEN ', strProductCode = NULL' ELSE ', strProductCode = ''' + strProductCode + ''''  END
	+ CASE WHEN strDescription IS NULL THEN ', strDescription = NULL' ELSE ', strDescription = ''' + strDescription + ''''  END
	+ CASE WHEN strProductCodeGroup IS NULL THEN ', strProductCodeGroup = NULL' ELSE ', strProductCodeGroup = ''' + strProductCodeGroup + ''''  END
	+ CASE WHEN strNote IS NULL THEN ', strNote = NULL' ELSE ', strNote = ''' + strNote + '''' END 
from tblTFProductCode
where intTaxAuthorityId = 
*/
DECLARE @ProductCodes AS TFProductCodes

INSERT INTO @ProductCodes (
	intProductCodeId
    , strProductCode
    , strDescription
    , strProductCodeGroup
    , strNote
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intProductCodeId = 408, strProductCode = '054', strDescription = 'Propane (LPG)', strProductCodeGroup = ' ', strNote = NULL
UNION ALL SELECT intProductCodeId = 409, strProductCode = '061', strDescription = 'Natural gas Denaturant', strProductCodeGroup = ' ', strNote = NULL
UNION ALL SELECT intProductCodeId = 410, strProductCode = '065', strDescription = 'Gasoline', strProductCodeGroup = ' ', strNote = NULL
UNION ALL SELECT intProductCodeId = 411, strProductCode = '123', strDescription = 'Ethanol-Alcohol', strProductCodeGroup = ' ', strNote = NULL
UNION ALL SELECT intProductCodeId = 412, strProductCode = '124', strDescription = 'Gasohol', strProductCodeGroup = ' ', strNote = NULL
UNION ALL SELECT intProductCodeId = 413, strProductCode = '125', strDescription = 'Aviation Gasoline', strProductCodeGroup = ' ', strNote = NULL
UNION ALL SELECT intProductCodeId = 414, strProductCode = '130', strDescription = 'Aviation Jet Fuel', strProductCodeGroup = ' ', strNote = NULL
UNION ALL SELECT intProductCodeId = 415, strProductCode = '142', strDescription = 'Undyed Kerosene', strProductCodeGroup = ' ', strNote = NULL
UNION ALL SELECT intProductCodeId = 416, strProductCode = '160', strDescription = 'Undyed Diesel', strProductCodeGroup = ' ', strNote = NULL
UNION ALL SELECT intProductCodeId = 417, strProductCode = '170', strDescription = 'Undyed Biodiesel Blend', strProductCodeGroup = ' ', strNote = NULL
UNION ALL SELECT intProductCodeId = 418, strProductCode = '171', strDescription = 'Dyed Biodiesel Blend', strProductCodeGroup = ' ', strNote = NULL
UNION ALL SELECT intProductCodeId = 419, strProductCode = '224', strDescription = 'Compressed Natural Gas (CNG)', strProductCodeGroup = ' ', strNote = NULL
UNION ALL SELECT intProductCodeId = 420, strProductCode = '228', strDescription = 'Dyed Diesel', strProductCodeGroup = ' ', strNote = NULL
UNION ALL SELECT intProductCodeId = 1408, strProductCode = 'B00', strDescription = 'Undyed Bioeiesel', strProductCodeGroup = ' ', strNote = NULL
UNION ALL SELECT intProductCodeId = 1409, strProductCode = 'D00', strDescription = 'Dyed Biodiesel', strProductCodeGroup = ' ', strNote = NULL

EXEC uspTFUpgradeProductCodes @TaxAuthorityCode = @TaxAuthorityCode, @ProductCodes = @ProductCodes


-- Terminal Control Numbers
/* Generate script for Terminal Control Numbers. Specify Tax Authority Id to filter out specific Terminal Control Numbers only.
select 'UNION ALL SELECT intTerminalControlNumberId = ' + CAST(intTerminalControlNumberId AS NVARCHAR(10)) 
	+ CASE WHEN strTerminalControlNumber IS NULL THEN ', strTerminalControlNumber = NULL' ELSE ', strTerminalControlNumber = ''' + strTerminalControlNumber + ''''  END
	+ CASE WHEN strName IS NULL THEN ', strName = NULL' ELSE ', strName = ''' + strName + ''''  END
	+ CASE WHEN strAddress IS NULL THEN ', strAddress = NULL' ELSE ', strAddress = ''' + strAddress + ''''  END
	+ CASE WHEN strCity IS NULL THEN ', strCity = NULL' ELSE ', strCity = ''' + strCity + '''' END 
	+ CASE WHEN dtmApprovedDate IS NULL THEN ', dtmApprovedDate = NULL' ELSE ', dtmApprovedDate = ''' + CAST(dtmApprovedDate AS NVARCHAR(50)) + '''' END 
	+ CASE WHEN strZip IS NULL THEN ', strZip = NULL' ELSE ', strZip = ''' + strZip + '''' END 
from tblTFTerminalControlNumber
where intTaxAuthorityId = 
*/
DECLARE @TerminalControlNumbers AS TFTerminalControlNumbers

INSERT INTO @TerminalControlNumbers(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intTerminalControlNumberId = 515, strTerminalControlNumber = 'T-39-NE-3604', strName = 'Signature Flight Support Corp.', strAddress = '3636 Wilbur Plaza', strCity = 'Omaha', dtmApprovedDate = NULL, strZip = '68110'
UNION ALL SELECT intTerminalControlNumberId = 516, strTerminalControlNumber = 'T-39-NE-3612', strName = 'Magellan Pipeline Company, L.P.', strAddress = '13029 S 13th St', strCity = 'Bellevue', dtmApprovedDate = NULL, strZip = '68123'
UNION ALL SELECT intTerminalControlNumberId = 517, strTerminalControlNumber = 'T-39-NE-3613', strName = 'Truman Arnold Co. - TAC Air', strAddress = '3737 Orville Plaza', strCity = 'Omaha', dtmApprovedDate = NULL, strZip = '68110'
UNION ALL SELECT intTerminalControlNumberId = 518, strTerminalControlNumber = 'T-39-NE-3614', strName = 'Union Pacific Railroad Co.', strAddress = '6000 West Front St.', strCity = 'North Platte', dtmApprovedDate = NULL, strZip = '69101'
UNION ALL SELECT intTerminalControlNumberId = 519, strTerminalControlNumber = 'T-39-NE-3615', strName = 'BNSF - Lincoln', strAddress = '201 North 7th Street', strCity = 'Lincoln', dtmApprovedDate = NULL, strZip = '68508'
UNION ALL SELECT intTerminalControlNumberId = 520, strTerminalControlNumber = 'T-47-NE-3600', strName = 'NuStar Pipeline Operating Partnership, L.P. - Columbus', strAddress = 'R R 5, Box 27 BB', strCity = 'Columbus', dtmApprovedDate = NULL, strZip = '68601-'
UNION ALL SELECT intTerminalControlNumberId = 521, strTerminalControlNumber = 'T-47-NE-3601', strName = 'NuStar Pipeline Operating Partnership, L.P. - Geneva', strAddress = 'U S Highway 81', strCity = 'Geneva', dtmApprovedDate = NULL, strZip = '68361-'
UNION ALL SELECT intTerminalControlNumberId = 522, strTerminalControlNumber = 'T-47-NE-3602', strName = 'Magellan Pipeline Company, L.P.', strAddress = '12275 South US Hwy 281', strCity = 'Doniphan', dtmApprovedDate = NULL, strZip = '68832-'
UNION ALL SELECT intTerminalControlNumberId = 523, strTerminalControlNumber = 'T-47-NE-3603', strName = 'Phillips 66 PL - Lincoln', strAddress = '1345 Saltillo Rd.', strCity = 'Roca', dtmApprovedDate = NULL, strZip = '68430'
UNION ALL SELECT intTerminalControlNumberId = 524, strTerminalControlNumber = 'T-47-NE-3605', strName = 'Magellan Pipeline Company, L.P.', strAddress = '2000 Saltillo Road', strCity = 'Roca', dtmApprovedDate = NULL, strZip = '68430'
UNION ALL SELECT intTerminalControlNumberId = 525, strTerminalControlNumber = 'T-47-NE-3606', strName = 'NuStar Pipeline Operating Partnership, L.P. - Norfolk', strAddress = 'Highway 81', strCity = 'Norfolk', dtmApprovedDate = NULL, strZip = '68701'
UNION ALL SELECT intTerminalControlNumberId = 526, strTerminalControlNumber = 'T-47-NE-3607', strName = 'NuStar Pipeline Operating Partnership, L.P. - North Platte', strAddress = 'Rural Route Four', strCity = 'North Platte', dtmApprovedDate = NULL, strZip = '69101'
UNION ALL SELECT intTerminalControlNumberId = 527, strTerminalControlNumber = 'T-47-NE-3608', strName = 'Magellan Pipeline Company, L.P.', strAddress = '2205 N 11th St', strCity = 'Omaha', dtmApprovedDate = NULL, strZip = '68110'
UNION ALL SELECT intTerminalControlNumberId = 528, strTerminalControlNumber = 'T-47-NE-3610', strName = 'NuStar Pipeline Operating Partnership, L.P. - Osceola', strAddress = 'Rural Route 1', strCity = 'Osceola', dtmApprovedDate = NULL, strZip = '68651'

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = @TaxAuthorityCode, @TerminalControlNumbers = @TerminalControlNumbers


-- Tax Category
/* Generate script for Tax Categories. Specify Tax Authority Id to filter out specific Tax Categories only.
select 'UNION ALL SELECT intTaxCategoryId = ' + CAST(intTaxCategoryId AS NVARCHAR(10))
	+ CASE WHEN strState IS NULL THEN ', strState = NULL' ELSE ', strState = ''' + strState + ''''  END
	+ CASE WHEN strTaxCategory IS NULL THEN ', strTaxCategory = NULL' ELSE ', strTaxCategory = ''' + strTaxCategory + ''''  END
from tblTFTaxCategory
where intTaxAuthorityId = 
*/
DECLARE @TaxCategories AS TFTaxCategories

INSERT INTO @TaxCategories(
	intTaxCategoryId
	, strState
	, strTaxCategory
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intTaxCategoryId = 18, strState = 'NE', strTaxCategory = 'NE Excise Tax Gasoline'
UNION ALL SELECT intTaxCategoryId = 19, strState = 'NE', strTaxCategory = 'NE Excise Tax Diesel Clear'
UNION ALL SELECT intTaxCategoryId = 20, strState = 'NE', strTaxCategory = 'NE PRF Fee Gasoline'
UNION ALL SELECT intTaxCategoryId = 21, strState = 'NE', strTaxCategory = 'NE PRF Fee Diesel Clear'
UNION ALL SELECT intTaxCategoryId = 24, strState = 'NE', strTaxCategory = 'NE Excise Tax Gasohol'
UNION ALL SELECT intTaxCategoryId = 25, strState = 'NE', strTaxCategory = 'NE Excise Tax Ethanol'
UNION ALL SELECT intTaxCategoryId = 26, strState = 'NE', strTaxCategory = 'NE Excise Tax Compressed Fuels'
UNION ALL SELECT intTaxCategoryId = 27, strState = 'NE', strTaxCategory = 'NE Excise Tax Aviation Gasoline'
UNION ALL SELECT intTaxCategoryId = 28, strState = 'NE', strTaxCategory = 'NE Excise Tax Jet Fuel'
UNION ALL SELECT intTaxCategoryId = 29, strState = 'NE', strTaxCategory = 'NE PRF Fee Gasohol'
UNION ALL SELECT intTaxCategoryId = 30, strState = 'NE', strTaxCategory = 'NE PRF Fee Ethanol'
UNION ALL SELECT intTaxCategoryId = 31, strState = 'NE', strTaxCategory = 'NE PRF Fee Aviation Gasoline'
UNION ALL SELECT intTaxCategoryId = 33, strState = 'NE', strTaxCategory = 'NE PRF Fee Jet Fuel'
UNION ALL SELECT intTaxCategoryId = 34, strState = 'NE', strTaxCategory = 'NE PRF Fee All Other Petroleum Products'

EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = @TaxAuthorityCode, @TaxCategories = @TaxCategories


-- Reporting Component
/* Generate script for Reporting Components. Specify Tax Authority Id to filter out specific Reporting Components only.
select 'UNION ALL SELECT intReportingComponentId = ' + CAST(intReportingComponentId AS NVARCHAR(10))
	+ CASE WHEN strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strFormName IS NULL THEN ', strFormName = NULL' ELSE ', strFormName = ''' + strFormName + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN strScheduleName IS NULL THEN ', strScheduleName = NULL' ELSE ', strScheduleName = ''' + strScheduleName + '''' END 
	+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END
	+ CASE WHEN strNote IS NULL THEN ', strNote = NULL' ELSE ', strNote = ''' + strNote + '''' END
	+ CASE WHEN strTransactionType IS NULL THEN ', strTransactionType = NULL' ELSE ', strTransactionType = ''' + strTransactionType + '''' END
	+ CASE WHEN intPositionId IS NULL THEN ', intPositionId = NULL' ELSE ', intPositionId = ' + CAST(intPositionId AS NVARCHAR(10)) END
	+ CASE WHEN strSPInventory IS NULL THEN ', strSPInventory = NULL' ELSE ', strSPInventory = ''' + strSPInventory + '''' END
	+ CASE WHEN strSPInvoice IS NULL THEN ', strSPInvoice = NULL' ELSE ', strSPInvoice = ''' + strSPInvoice + '''' END
	+ CASE WHEN strSPRunReport IS NULL THEN ', strSPRunReport = NULL' ELSE ', strSPRunReport = ''' + strSPRunReport + '''' END
from tblTFReportingComponent
where intTaxAuthorityId = 
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
	, intPositionId
	, strSPInventory
	, strSPInvoice
	, strSPRunReport
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intReportingComponentId = 89, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '1', strScheduleName = 'Gross Gallons Received with Tax and PRF Fee Paid', strType = 'Gasoline / Gasohol / Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 10, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 90, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '1', strScheduleName = 'Gross Gallons Received with Tax and PRF Fee Paid', strType = 'Undyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 20, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 95, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '1', strScheduleName = 'Gross Gallons Received with Tax and PRF Fee Paid', strType = 'Aviation Gasoline', strNote = '', strTransactionType = 'Inventory', intPositionId = 30, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1091, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '1', strScheduleName = 'Gross Gallons Received with Tax and PRF Fee Paid', strType = 'Aviation Jet Fuel', strNote = '', strTransactionType = 'Inventory', intPositionId = 40, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1092, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '2', strScheduleName = 'Gross Gallons Received without Tax or PRF Fee Paid', strType = 'Gasoline / Gasohol / Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 50, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1093, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '2', strScheduleName = 'Gross Gallons Received without Tax or PRF Fee Paid', strType = 'Undyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 60, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1094, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '2', strScheduleName = 'Gross Gallons Received without Tax or PRF Fee Paid', strType = 'Dyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 70, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1095, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '2', strScheduleName = 'Gross Gallons Received without Tax or PRF Fee Paid', strType = 'Aviation Gasoline', strNote = '', strTransactionType = 'Inventory', intPositionId = 80, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1096, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '2', strScheduleName = 'Gross Gallons Received without Tax or PRF Fee Paid', strType = 'Aviation Jet Fuel', strNote = '', strTransactionType = 'Inventory', intPositionId = 90, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1097, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '3', strScheduleName = 'Gross Gallons Imported without Tax or PRF Fee Paid', strType = 'Gasoline / Gasohol / Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 100, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1098, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '3', strScheduleName = 'Gross Gallons Imported without Tax or PRF Fee Paid', strType = 'Undyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 110, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1099, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '3', strScheduleName = 'Gross Gallons Imported without Tax or PRF Fee Paid', strType = 'Dyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 120, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1100, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '3', strScheduleName = 'Gross Gallons Imported without Tax or PRF Fee Paid', strType = 'Aviation Gasoline', strNote = '', strTransactionType = 'Inventory', intPositionId = 130, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1101, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '3', strScheduleName = 'Gross Gallons Imported without Tax or PRF Fee Paid', strType = 'Aviation Jet Fuel', strNote = '', strTransactionType = 'Inventory', intPositionId = 140, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1102, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '5', strScheduleName = 'Gross Gallons Delivered with Tax and PRF Fee Paid', strType = 'Gasoline / Gasohol / Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 150, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1103, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '5', strScheduleName = 'Gross Gallons Delivered with Tax and PRF Fee Paid', strType = 'Undyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 160, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1104, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '5', strScheduleName = 'Gross Gallons Delivered with Tax and PRF Fee Paid', strType = 'Undyed or Dyed Kerosene', strNote = '', strTransactionType = 'Inventory', intPositionId = 170, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1105, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '5', strScheduleName = 'Gross Gallons Delivered with Tax and PRF Fee Paid', strType = 'Aviation Gasoline', strNote = '', strTransactionType = 'Inventory', intPositionId = 180, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1106, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '5', strScheduleName = 'Gross Gallons Delivered with Tax and PRF Fee Paid', strType = 'Aviation Jet Fuel', strNote = '', strTransactionType = 'Inventory', intPositionId = 190, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1107, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '6', strScheduleName = 'Gross Gallons Disbursed without Tax or PRF Fee', strType = 'Gasoline / Gasohol / Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 200, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1108, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '6', strScheduleName = 'Gross Gallons Disbursed without Tax or PRF Fee', strType = 'Undyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 210, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1109, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '6', strScheduleName = 'Gross Gallons Disbursed without Tax or PRF Fee', strType = 'Dyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 220, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1110, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '6', strScheduleName = 'Gross Gallons Disbursed without Tax or PRF Fee', strType = 'Aviation Gasoline', strNote = '', strTransactionType = 'Inventory', intPositionId = 230, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1111, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '6', strScheduleName = 'Gross Gallons Disbursed without Tax or PRF Fee', strType = 'Aviation Jet Fuel', strNote = '', strTransactionType = 'Inventory', intPositionId = 240, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1112, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '7', strScheduleName = 'Gross Gallons Exported without Tax or PRF Fee to Another State', strType = 'Gasoline / Gasohol / Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 250, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1113, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '7', strScheduleName = 'Gross Gallons Exported without Tax or PRF Fee to Another State', strType = 'Undyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 260, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1114, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '7', strScheduleName = 'Gross Gallons Exported without Tax or PRF Fee to Another State', strType = 'Dyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 270, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1115, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '7', strScheduleName = 'Gross Gallons Exported without Tax or PRF Fee to Another State', strType = 'Aviation Gasoline', strNote = '', strTransactionType = 'Inventory', intPositionId = 280, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1116, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '7', strScheduleName = 'Gross Gallons Exported without Tax or PRF Fee to Another State', strType = 'Aviation Jet Fuel', strNote = '', strTransactionType = 'Inventory', intPositionId = 290, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1117, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '8', strScheduleName = 'Gross Gallons Delivered to US Government or Metro Transit Authority', strType = 'Gasoline / Gasohol / Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 300, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1118, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '8', strScheduleName = 'Gross Gallons Delivered to US Government or Metro Transit Authority', strType = 'Undyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 310, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1119, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '8', strScheduleName = 'Gross Gallons Delivered to US Government or Metro Transit Authority', strType = 'Dyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 320, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1120, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '8', strScheduleName = 'Gross Gallons Delivered to US Government or Metro Transit Authority', strType = 'Aviation Gasoline', strNote = '', strTransactionType = 'Inventory', intPositionId = 330, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1121, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '8', strScheduleName = 'Gross Gallons Delivered to US Government or Metro Transit Authority', strType = 'Aviation Jet Fuel', strNote = '', strTransactionType = 'Inventory', intPositionId = 340, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1122, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '10', strScheduleName = 'Gross Gallons Delivered to Native Americans', strType = 'Gasoline / Gasohol / Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 350, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1123, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '10', strScheduleName = 'Gross Gallons Delivered to Native Americans', strType = 'Undyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 360, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1125, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '10', strScheduleName = 'Gross Gallons Delivered to Native Americans', strType = 'Aviation Gasoline', strNote = '', strTransactionType = 'Inventory', intPositionId = 370, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1126, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '10', strScheduleName = 'Gross Gallons Delivered to Native Americans', strType = 'Aviation Jet Fuel', strNote = '', strTransactionType = 'Inventory', intPositionId = 380, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1127, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '13C', strScheduleName = 'Credit for Tax-Paid Fuel Sold to US Government', strType = 'Gasoline / Gasohol / Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 390, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1128, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '13C', strScheduleName = 'Credit for Tax-Paid Fuel Sold to US Government', strType = 'Undyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 400, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1136, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '13J', strScheduleName = 'Credit for Tax-Paid Fuel Sold Pursuant to Form 91EX', strType = 'Gasoline / Gasohol / Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 410, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1137, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '13J', strScheduleName = 'Credit for Tax-Paid Fuel Sold Pursuant to Form 91EX', strType = 'Undyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 420, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1138, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '', strScheduleName = 'Main Form', strType = '', strNote = 'Form 73', strTransactionType = 'Inventory', intPositionId = 430, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1139, strFormCode = 'Form 83', strFormName = 'Ethnol and Biodiesel Producer''s Return', strScheduleCode = '2', strScheduleName = 'Gross Gallons Received without Tax or PRF Fee Paid', strType = 'Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 440, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1140, strFormCode = 'Form 83', strFormName = 'Ethnol and Biodiesel Producer''s Return', strScheduleCode = '2', strScheduleName = 'Gross Gallons Received without Tax or PRF Fee Paid', strType = 'Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 450, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1141, strFormCode = 'Form 83', strFormName = 'Ethnol and Biodiesel Producer''s Return', strScheduleCode = '3', strScheduleName = 'Gross Gallons Imported without Tax or PRF Fee Paid', strType = 'Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 460, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1142, strFormCode = 'Form 83', strFormName = 'Ethnol and Biodiesel Producer''s Return', strScheduleCode = '3', strScheduleName = 'Gross Gallons Imported without Tax or PRF Fee Paid', strType = 'Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 470, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1143, strFormCode = 'Form 83', strFormName = 'Ethnol and Biodiesel Producer''s Return', strScheduleCode = '5', strScheduleName = 'Gross Gallons Delivered Tax Paid', strType = 'Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 480, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1144, strFormCode = 'Form 83', strFormName = 'Ethnol and Biodiesel Producer''s Return', strScheduleCode = '5', strScheduleName = 'Gross Gallons Delivered Tax Paid', strType = 'Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 490, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1145, strFormCode = 'Form 83', strFormName = 'Ethnol and Biodiesel Producer''s Return', strScheduleCode = '6', strScheduleName = 'Gross Gallons Disbursed without Tax Paid', strType = 'Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 500, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1146, strFormCode = 'Form 83', strFormName = 'Ethnol and Biodiesel Producer''s Return', strScheduleCode = '6', strScheduleName = 'Gross Gallons Disbursed without Tax Paid', strType = 'Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 510, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1147, strFormCode = 'Form 83', strFormName = 'Ethnol and Biodiesel Producer''s Return', strScheduleCode = '6R', strScheduleName = 'Gross Gallons Transferred to Another Producer''s NE Storage', strType = 'Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 520, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1148, strFormCode = 'Form 83', strFormName = 'Ethnol and Biodiesel Producer''s Return', strScheduleCode = '6R', strScheduleName = 'Gross Gallons Transferred to Another Producer''s NE Storage', strType = 'Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 530, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1149, strFormCode = 'Form 83', strFormName = 'Ethnol and Biodiesel Producer''s Return', strScheduleCode = '7', strScheduleName = 'Gross Gallons Exported without Tax to Another State', strType = 'Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 540, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1150, strFormCode = 'Form 83', strFormName = 'Ethnol and Biodiesel Producer''s Return', strScheduleCode = '7', strScheduleName = 'Gross Gallons Exported without Tax to Another State', strType = 'Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 550, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1151, strFormCode = 'Form 83', strFormName = 'Ethnol and Biodiesel Producer''s Return', strScheduleCode = '8', strScheduleName = 'Gross Gallons Delivered to US Government or Metropolitan Transit Authority', strType = 'Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 560, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1152, strFormCode = 'Form 83', strFormName = 'Ethnol and Biodiesel Producer''s Return', strScheduleCode = '8', strScheduleName = 'Gross Gallons Delivered to US Government or Metropolitan Transit Authority', strType = 'Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 570, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1153, strFormCode = 'Form 83', strFormName = 'Ethnol and Biodiesel Producer''s Return', strScheduleCode = '10', strScheduleName = 'Gross Gallons Delivered to Native Americans', strType = 'Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 580, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1154, strFormCode = 'Form 83', strFormName = 'Ethnol and Biodiesel Producer''s Return', strScheduleCode = '10', strScheduleName = 'Gross Gallons Delivered to Native Americans', strType = 'Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 590, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1155, strFormCode = 'Form 83', strFormName = 'Ethnol and Biodiesel Producer''s Return', strScheduleCode = '', strScheduleName = 'Main Form', strType = '', strNote = 'Form 83', strTransactionType = 'Inventory', intPositionId = 600, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 1156, strFormCode = 'EDI', strFormName = 'Electronic file', strScheduleCode = '', strScheduleName = 'NE EDI file', strType = 'EDI', strNote = '', strTransactionType = '', intPositionId = 700, strSPInventory = '', strSPInvoice = '', strSPRunReport = ''

EXEC uspTFUpgradeReportingComponents @TaxAuthorityCode = @TaxAuthorityCode, @ReportingComponent = @ReportingComponent


-- Tax Criteria
/* Generate script for Tax Criteria. Specify Tax Authority Id to filter out specific Tax Criteria only.
select 'UNION ALL SELECT intTaxCriteriaId = ' + CAST(intTaxCriteriaId AS NVARCHAR(10))
	+ CASE WHEN TaxCat.strTaxCategory IS NULL THEN ', strTaxCategory = NULL' ELSE ', strTaxCategory = ''' + TaxCat.strTaxCategory + ''''  END
	+ CASE WHEN TaxCat.strState IS NULL THEN ', strState = NULL' ELSE ', strState = ''' + TaxCat.strState + ''''  END
	+ CASE WHEN strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END
	+ CASE WHEN strCriteria IS NULL THEN ', strCriteria = NULL' ELSE ', strCriteria = ''' + strCriteria + '''' END
from tblTFTaxCriteria TaxCrit
left join tblTFTaxCategory TaxCat ON TaxCat.intTaxCategoryId = TaxCrit.intTaxCategoryId
left join tblTFReportingComponent RC ON RC.intReportingComponentId = TaxCrit.intReportingComponentId
where RC.intTaxAuthorityId =  and TaxCat.intTaxAuthorityId = 
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
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intTaxCriteriaId = 31, strTaxCategory = 'NE Excise Tax Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 32, strTaxCategory = 'NE PRF Fee Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 67, strTaxCategory = 'NE Excise Tax Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 68, strTaxCategory = 'NE PRF Fee Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 69, strTaxCategory = 'NE Excise Tax Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 70, strTaxCategory = 'NE PRF Fee Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 71, strTaxCategory = 'NE Excise Tax Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 72, strTaxCategory = 'NE PRF Fee Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 73, strTaxCategory = 'NE Excise Tax Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 74, strTaxCategory = 'NE PRF Fee Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 77, strTaxCategory = 'NE PRF Fee Diesel Clear', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 78, strTaxCategory = 'NE Excise Tax Diesel Clear', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 79, strTaxCategory = 'NE PRF Fee Diesel Clear', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 80, strTaxCategory = 'NE Excise Tax Diesel Clear', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 81, strTaxCategory = 'NE PRF Fee Diesel Clear', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 82, strTaxCategory = 'NE Excise Tax Diesel Clear', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 83, strTaxCategory = 'NE PRF Fee Diesel Clear', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 84, strTaxCategory = 'NE Excise Tax Diesel Clear', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 85, strTaxCategory = 'NE PRF Fee Diesel Clear', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 86, strTaxCategory = 'NE Excise Tax Diesel Clear', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 89, strTaxCategory = 'NE Excise Tax Aviation Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 90, strTaxCategory = 'NE PRF Fee Aviation Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 91, strTaxCategory = 'NE Excise Tax Aviation Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 92, strTaxCategory = 'NE PRF Fee Aviation Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 93, strTaxCategory = 'NE Excise Tax Aviation Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 94, strTaxCategory = 'NE PRF Fee Aviation Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 95, strTaxCategory = 'NE Excise Tax Aviation Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 96, strTaxCategory = 'NE PRF Fee Aviation Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 97, strTaxCategory = 'NE Excise Tax Aviation Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 98, strTaxCategory = 'NE PRF Fee Aviation Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 101, strTaxCategory = 'NE Excise Tax Jet Fuel', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 102, strTaxCategory = 'NE PRF Fee Jet Fuel', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 103, strTaxCategory = 'NE Excise Tax Jet Fuel', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 104, strTaxCategory = 'NE PRF Fee Jet Fuel', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 105, strTaxCategory = 'NE Excise Tax Jet Fuel', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 106, strTaxCategory = 'NE PRF Fee Jet Fuel', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 107, strTaxCategory = 'NE Excise Tax Jet Fuel', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 108, strTaxCategory = 'NE PRF Fee Jet Fuel', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 109, strTaxCategory = 'NE Excise Tax Jet Fuel', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 110, strTaxCategory = 'NE PRF Fee Jet Fuel', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 113, strTaxCategory = 'NE Excise Tax Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 114, strTaxCategory = 'NE PRF Fee Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 115, strTaxCategory = 'NE Excise Tax Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 116, strTaxCategory = 'NE PRF Fee Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 117, strTaxCategory = 'NE Excise Tax Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 118, strTaxCategory = 'NE PRF Fee Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 119, strTaxCategory = 'NE Excise Tax Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 120, strTaxCategory = 'NE PRF Fee Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 121, strTaxCategory = 'NE Excise Tax Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strCriteria = '= 0 '
UNION ALL SELECT intTaxCriteriaId = 122, strTaxCategory = 'NE PRF Fee Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strCriteria = '= 0 '
UNION ALL SELECT intTaxCriteriaId = 123, strTaxCategory = 'NE Excise Tax Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strCriteria = '= 0 '
UNION ALL SELECT intTaxCriteriaId = 124, strTaxCategory = 'NE PRF Fee Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strCriteria = '= 0 '
UNION ALL SELECT intTaxCriteriaId = 125, strTaxCategory = 'NE Excise Tax Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 126, strTaxCategory = 'NE PRF Fee Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 127, strTaxCategory = 'NE Excise Tax Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 128, strTaxCategory = 'NE PRF Fee Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strCriteria = '<> 0'

EXEC uspTFUpgradeTaxCriteria @TaxAuthorityCode = @TaxAuthorityCode, @TaxCriteria = @TaxCriteria


-- Reporting Component - Base
/* Generate script for Valid Product Codes. Specify Tax Authority Id to filter out specific Valid Product Codes only.
select 'UNION ALL SELECT intValidProductCodeId = ' + CAST(intValidProductCodeId AS NVARCHAR(10))
	+ CASE WHEN PC.strProductCode IS NULL THEN ', strProductCode = NULL' ELSE ', strProductCode = ''' + PC.strProductCode + ''''  END
	+ CASE WHEN RC.strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END
	+ CASE WHEN strFilter IS NULL THEN ', strFilter = NULL' ELSE ', strFilter = ''' + strFilter + '''' END
from tblTFValidProductCode VPC
left join tblTFProductCode PC ON PC.intProductCodeId= VPC.intProductCode
left join tblTFReportingComponent RC ON RC.intReportingComponentId = VPC.intReportingComponentId
where RC.intTaxAuthorityId =
*/
/* Generate script for Valid Origin States. Specify Tax Authority Id to filter out specific Valid Origin States only.
select 'UNION ALL SELECT intValidOriginStateId = ' + CAST(intValidOriginStateId AS NVARCHAR(10))
	+ CASE WHEN RC.strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + RC.strFormCode + ''''  END
	+ CASE WHEN RC.strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + RC.strScheduleCode + ''''  END
	+ CASE WHEN RC.strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + RC.strType + '''' END
	+ CASE WHEN ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS IS NULL THEN ', strState = NULL' ELSE ', strState = ''' + ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS + ''''  END
	+ CASE WHEN VOS.strType IS NULL THEN ', strStatus = NULL' ELSE ', strStatus = ''' + VOS.strType + ''''  END
	+ CASE WHEN strFilter IS NULL THEN ', strFilter = NULL' ELSE ', strFilter = ''' + strFilter + '''' END
from tblTFValidOriginState VOS
left join tblTFOriginDestinationState ODS ON ODS.intOriginDestinationStateId= VOS.intOriginDestinationStateId
left join tblTFReportingComponent RC ON RC.intReportingComponentId = VOS.intReportingComponentId
where RC.intTaxAuthorityId =
*/
/* Generate script for Valid Destination States. Specify Tax Authority Id to filter out specific Valid Destination States only.
select 'UNION ALL SELECT intValidDestinationStateId = ' + CAST(intValidDestinationStateId AS NVARCHAR(10))
	+ CASE WHEN RC.strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + RC.strFormCode + ''''  END
	+ CASE WHEN RC.strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + RC.strScheduleCode + ''''  END
	+ CASE WHEN RC.strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + RC.strType + '''' END
	+ CASE WHEN ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS IS NULL THEN ', strState = NULL' ELSE ', strState = ''' + ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS + ''''  END
	+ CASE WHEN VDS.strStatus IS NULL THEN ', strStatus = NULL' ELSE ', strStatus = ''' + VDS.strStatus + ''''  END
from tblTFValidDestinationState VDS
left join tblTFOriginDestinationState ODS ON ODS.intOriginDestinationStateId= VDS.intOriginDestinationStateId
left join tblTFReportingComponent RC ON RC.intReportingComponentId = VDS.intReportingComponentId
where RC.intTaxAuthorityId =
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
	, strFilter
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intValidProductCodeId = 1105, strProductCode = '061', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1106, strProductCode = '065', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1107, strProductCode = '123', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1108, strProductCode = '124', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1109, strProductCode = '061', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1110, strProductCode = '065', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1111, strProductCode = '123', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1112, strProductCode = '124', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1113, strProductCode = '061', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1114, strProductCode = '065', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1115, strProductCode = '123', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1116, strProductCode = '124', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1117, strProductCode = '061', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1118, strProductCode = '065', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1119, strProductCode = '123', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1120, strProductCode = '124', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1121, strProductCode = '061', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1122, strProductCode = '065', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1123, strProductCode = '123', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1124, strProductCode = '124', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1125, strProductCode = '061', strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1126, strProductCode = '065', strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1127, strProductCode = '123', strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1128, strProductCode = '124', strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1129, strProductCode = '061', strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1130, strProductCode = '065', strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1131, strProductCode = '123', strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1132, strProductCode = '124', strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1133, strProductCode = '061', strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1134, strProductCode = '065', strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1135, strProductCode = '123', strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1136, strProductCode = '124', strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1137, strProductCode = '061', strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1138, strProductCode = '065', strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1139, strProductCode = '123', strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1140, strProductCode = '124', strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1141, strProductCode = '061', strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1142, strProductCode = '065', strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1143, strProductCode = '123', strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1144, strProductCode = '124', strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1145, strProductCode = '160', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1146, strProductCode = 'B00', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1147, strProductCode = '170', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1188, strProductCode = '160', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1189, strProductCode = 'B00', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1190, strProductCode = '170', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1191, strProductCode = '160', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1192, strProductCode = '170', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1193, strProductCode = 'B00', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1194, strProductCode = '160', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1195, strProductCode = '170', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1196, strProductCode = 'B00', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1197, strProductCode = '160', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1198, strProductCode = '170', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1199, strProductCode = 'B00', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1200, strProductCode = '160', strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1201, strProductCode = '170', strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1202, strProductCode = 'B00', strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1203, strProductCode = '160', strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1204, strProductCode = '170', strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1205, strProductCode = 'B00', strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1206, strProductCode = '160', strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1207, strProductCode = '170', strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1208, strProductCode = 'B00', strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1209, strProductCode = '160', strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1210, strProductCode = '170', strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1211, strProductCode = 'B00', strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1212, strProductCode = '160', strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1213, strProductCode = '170', strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1214, strProductCode = 'B00', strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1215, strProductCode = '125', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1216, strProductCode = '125', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1217, strProductCode = '125', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1218, strProductCode = '125', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1219, strProductCode = '125', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1220, strProductCode = '125', strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1221, strProductCode = '125', strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Gasoline', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1222, strProductCode = '125', strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Gasoline', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1223, strProductCode = '130', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1224, strProductCode = '130', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1225, strProductCode = '130', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1226, strProductCode = '130', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1227, strProductCode = '130', strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1228, strProductCode = '130', strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Jet Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1229, strProductCode = '130', strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Jet Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1230, strProductCode = '130', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1231, strProductCode = '171', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1232, strProductCode = '228', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1233, strProductCode = 'D00', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1234, strProductCode = '171', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1235, strProductCode = '228', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1236, strProductCode = 'D00', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1237, strProductCode = '171', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1238, strProductCode = '228', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1239, strProductCode = 'D00', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1240, strProductCode = '171', strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1241, strProductCode = '228', strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1242, strProductCode = 'D00', strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1243, strProductCode = '171', strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1244, strProductCode = '228', strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1245, strProductCode = 'D00', strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1246, strProductCode = '142', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed or Dyed Kerosene', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1247, strProductCode = '061', strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1248, strProductCode = '123', strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1249, strProductCode = '061', strFormCode = 'Form 73', strScheduleCode = '', strType = '', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1250, strProductCode = '123', strFormCode = 'Form 73', strScheduleCode = '', strType = '', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1251, strProductCode = '061', strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1252, strProductCode = '123', strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1253, strProductCode = '061', strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1254, strProductCode = '123', strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1255, strProductCode = '061', strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Ethanol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1256, strProductCode = '123', strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Ethanol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1257, strProductCode = '061', strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1258, strProductCode = '123', strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1259, strProductCode = '061', strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Ethanol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1260, strProductCode = '123', strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Ethanol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1261, strProductCode = '061', strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Ethanol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1262, strProductCode = '123', strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Ethanol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1263, strProductCode = '061', strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1264, strProductCode = '123', strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1265, strProductCode = '170', strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1266, strProductCode = 'B00', strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1267, strProductCode = '170', strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1268, strProductCode = 'B00', strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1269, strProductCode = '170', strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1270, strProductCode = 'B00', strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1271, strProductCode = '170', strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1272, strProductCode = 'B00', strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1273, strProductCode = '170', strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1274, strProductCode = 'B00', strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1275, strProductCode = '170', strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1276, strProductCode = 'B00', strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1277, strProductCode = '170', strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1278, strProductCode = 'B00', strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1279, strProductCode = '170', strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Biodiesel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1280, strProductCode = 'B00', strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Biodiesel', strFilter = ''

INSERT INTO @ValidOriginStates(
	intValidOriginStateId
	, strFormCode
	, strScheduleCode
	, strType
	, strState
	, strStatus
	, strFilter
)
SELECT intValidOriginStateId = 57, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strState = 'NE', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 58, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strState = 'NE', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 59, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strState = 'NE', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 60, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strState = 'NE', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 61, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strState = 'NE', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 62, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strState = 'NE', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 63, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strState = 'NE', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 64, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strState = 'NE', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 65, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strState = 'NE', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 66, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strState = 'NE', strStatus = '', strFilter = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 67, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strState = 'NE', strStatus = '', strFilter = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 68, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strState = 'NE', strStatus = '', strFilter = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 69, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strState = 'NE', strStatus = '', strFilter = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 70, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strState = 'NE', strStatus = '', strFilter = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 71, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strState = 'NE', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 72, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strState = 'NE', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 73, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strState = 'NE', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 74, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', strState = 'NE', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 75, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', strState = 'NE', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 76, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strState = 'NE', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 77, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strState = 'NE', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 78, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strState = 'NE', strStatus = '', strFilter = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 79, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strState = 'NE', strStatus = '', strFilter = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 80, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strState = 'NE', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 81, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strState = 'NE', strStatus = '', strFilter = 'Include'

INSERT INTO @ValidDestinationStates(
	intValidDestinationStateId
	, strFormCode
	, strScheduleCode
	, strType
	, strState
	, strStatus
)
SELECT intValidDestinationStateId = 56, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 57, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 58, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 59, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 60, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 61, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 62, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 63, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 64, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 65, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 66, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 67, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 68, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 69, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 70, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strState = 'NE', strStatus = 'Exclude'
UNION ALL SELECT intValidDestinationStateId = 71, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strState = 'NE', strStatus = 'Exclude'
UNION ALL SELECT intValidDestinationStateId = 72, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strState = 'NE', strStatus = 'Exclude'
UNION ALL SELECT intValidDestinationStateId = 73, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', strState = 'NE', strStatus = 'Exclude'
UNION ALL SELECT intValidDestinationStateId = 74, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', strState = 'NE', strStatus = 'Exclude'
UNION ALL SELECT intValidDestinationStateId = 75, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 76, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 77, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 78, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 79, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strState = 'NE', strStatus = 'Exclude'
UNION ALL SELECT intValidDestinationStateId = 80, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strState = 'NE', strStatus = 'Exclude'

EXEC uspTFUpgradeValidProductCodes @ValidProductCodes = @ValidProductCodes
EXEC uspTFUpgradeValidOriginStates @ValidOriginStates = @ValidOriginStates
EXEC uspTFUpgradeValidDestinationStates @ValidDestinationStates = @ValidDestinationStates


-- Reporting Component - Configuration
/* Generate script for Reporting Component - Configurations. Specify Tax Authority Id to filter out specific Reporting Component - Configurations only.
select 'UNION ALL SELECT intReportTemplateId = ' + CAST(intReportTemplateId AS NVARCHAR(10))
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
	+ CASE WHEN ysnDynamicConfiguration IS NULL THEN ', ysnDynamicConfiguration = NULL' ELSE ', ysnDynamicConfiguration = ''' + CAST(ysnDynamicConfiguration AS NVARCHAR(5)) + ''''  END
	+ CASE WHEN strLastIndexOf IS NULL THEN ', strLastIndexOf = NULL' ELSE ', strLastIndexOf = ''' + strLastIndexOf + ''''  END
	+ CASE WHEN strSegment IS NULL THEN ', strSegment = NULL' ELSE ', strSegment = ''' + strSegment + ''''  END
	+ CASE WHEN intConfigurationSequence IS NULL THEN ', intConfigurationSequence = NULL' ELSE ', intConfigurationSequence = ''' + CAST(intConfigurationSequence AS NVARCHAR(10)) + ''''  END
from tblTFTaxReportTemplate Config
left join tblTFReportingComponent RC ON RC.intReportingComponentId = Config.intReportingComponentId
WHERE RC.intTaxAuthorityId =
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
--	, ysnDynamicConfiguration
--	, strLastIndexOf
--	, strSegment
--	, intSort
--)
-- Insert generated script here. Remove first instance of "UNION ALL "


--EXEC uspTFUpgradeReportingComponentConfigurations @TaxAuthorityCode = @TaxAuthorityCode, @ReportingComponentConfigurations = @ReportingComponentConfigurations

-- Reporting Component - Output Designer
/* Generate script for Reporting Component - Output Designer. Specify Tax Authority Id to filter out specific Reporting Component - Output Designer only.
select 'UNION ALL SELECT intScheduleColumnId = ' + CAST(intScheduleColumnId AS NVARCHAR(10))
	+ CASE WHEN strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END
	+ CASE WHEN strColumn IS NULL THEN ', strColumn = NULL' ELSE ', strColumn = ''' + strColumn + '''' END
	+ CASE WHEN strCaption IS NULL THEN ', strCaption = NULL' ELSE ', strCaption = ''' + strCaption + '''' END
	+ CASE WHEN strFormat IS NULL THEN ', strFormat = NULL' ELSE ', strFormat = ''' + strFormat + '''' END
	+ CASE WHEN strFooter IS NULL THEN ', strFooter = NULL' ELSE ', strFooter = ''' + strFooter + '''' END
	+ CASE WHEN intWidth IS NULL THEN ', intWidth = NULL' ELSE ', intWidth = ' + CAST(intWidth AS NVARCHAR(10)) END
from tblTFScheduleFields TRP
left join tblTFReportingComponent RC on RC.intReportingComponentId = TRP.intReportingComponentId
where RC.intTaxAuthorityId =
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
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intScheduleColumnId = 10367, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10368, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10369, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10370, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10371, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10372, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10373, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10374, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10375, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10376, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10377, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10378, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10379, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10380, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10381, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10382, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10383, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10384, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10385, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10386, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10387, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10388, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10389, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10390, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10391, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10392, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10393, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10394, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10395, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10396, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10397, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10398, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10399, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10400, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10401, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10402, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10403, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10404, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10405, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10406, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10407, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10408, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10409, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10410, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10411, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10412, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10413, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10414, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10415, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10416, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10417, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10418, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10419, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10420, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10421, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10422, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10423, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10424, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10425, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10426, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10427, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10428, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10429, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10430, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10431, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10432, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10433, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10434, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10435, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10436, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10437, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10438, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10439, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10440, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10441, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10442, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10443, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10444, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10445, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10446, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10447, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10448, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10449, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10450, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10451, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10452, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10453, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10454, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10455, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10456, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10457, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10458, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10459, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10460, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10461, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10462, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10463, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10464, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10465, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10466, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10467, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10468, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10469, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10470, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10471, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10472, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10473, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10474, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10475, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10476, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10477, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10478, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10479, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10480, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10481, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10482, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10483, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10484, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10485, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10486, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10487, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10488, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10489, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10490, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10491, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10492, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10493, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10494, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10495, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10496, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10497, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10498, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10499, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10500, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10501, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10502, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10503, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10504, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10505, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10506, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10507, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10508, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10509, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10510, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10511, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10512, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10513, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10514, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10515, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10516, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10517, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10518, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10519, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10520, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10521, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10522, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10523, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10524, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10525, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10526, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10527, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10528, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10529, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10530, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10531, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10554, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10555, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10556, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10557, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10558, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10559, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10560, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10561, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10562, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10563, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10564, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10565, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed or Dyed Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10566, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed or Dyed Kerosene', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10567, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed or Dyed Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10568, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed or Dyed Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10569, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed or Dyed Kerosene', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10570, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed or Dyed Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10571, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed or Dyed Kerosene', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10572, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed or Dyed Kerosene', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10573, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed or Dyed Kerosene', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10574, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed or Dyed Kerosene', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10575, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed or Dyed Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10576, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10577, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10578, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10579, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10580, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10581, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10582, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10583, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10584, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10585, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10586, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10587, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10588, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10589, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10590, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10591, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10592, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10593, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10594, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10595, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10596, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10597, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10598, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10599, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10600, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10601, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10602, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10603, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10604, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10605, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10606, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10607, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10608, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10609, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10610, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10611, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10612, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10613, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10614, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10615, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10616, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10617, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10618, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10619, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10620, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10621, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10622, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10623, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10624, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10625, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10626, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10627, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10628, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10629, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10630, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10631, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10632, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10633, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10634, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10635, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10636, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10637, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10638, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10639, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10640, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10641, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10642, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10643, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10644, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10645, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10646, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10647, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10648, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10649, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10650, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10651, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10652, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10653, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10654, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10655, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10656, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10657, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10658, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10659, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10660, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10661, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10662, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10663, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10664, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10665, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10666, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10667, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10668, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10669, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10670, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10671, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10672, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10673, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10674, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10675, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10676, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10677, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10678, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10679, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10680, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10681, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10682, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10683, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10684, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10685, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10686, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10687, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10688, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10689, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10690, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10691, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10692, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10693, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10694, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10695, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10696, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10697, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10698, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10699, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10700, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10701, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10702, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10703, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10704, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10705, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10706, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10707, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10708, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10709, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10710, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10711, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10712, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10713, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10714, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10715, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10716, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10717, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10718, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10719, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10720, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10721, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10722, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10723, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10724, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10725, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10726, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10727, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10728, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10729, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10730, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10731, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10732, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10733, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10734, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10735, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10736, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10737, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10738, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10739, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10740, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10741, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10742, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10743, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10744, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10745, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Gasoline', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10746, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10747, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Gasoline', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10748, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10749, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Gasoline', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10750, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Gasoline', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10751, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10752, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10753, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10754, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10755, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10756, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10757, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10758, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Jet Fuel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10759, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Jet Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10760, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Jet Fuel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10761, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Jet Fuel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10762, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10763, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10764, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10765, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10766, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10767, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10768, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10769, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10770, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10771, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10772, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10773, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10774, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10775, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10776, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10777, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10778, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10779, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10780, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10781, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10782, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10783, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10784, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10785, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10786, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10787, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10788, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10789, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Gasoline', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10790, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10791, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Gasoline', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10792, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10793, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Gasoline', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10794, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Gasoline', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10795, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10796, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10797, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10798, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10799, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10800, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10801, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10802, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Jet Fuel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10803, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Jet Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10804, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Jet Fuel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10805, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Jet Fuel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10806, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10807, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10808, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10809, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10810, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10811, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10812, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10813, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10814, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10815, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10816, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10817, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10818, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10819, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10820, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10821, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10822, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10823, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10824, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10825, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10826, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10827, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10828, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10829, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10830, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10831, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10832, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10833, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10834, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10835, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10836, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10837, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10838, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10839, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10840, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10841, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10842, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10843, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10844, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10845, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10846, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10847, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10848, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10849, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10850, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10851, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10852, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10853, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10854, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10855, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10856, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10857, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10858, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10859, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10860, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10861, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10862, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10863, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10864, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10865, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10866, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10867, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10868, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10869, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10870, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10871, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10872, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10901, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10902, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10983, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10984, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10985, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10986, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10987, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10988, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10989, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10990, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10991, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10992, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10993, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10994, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10995, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10996, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10997, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10998, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10999, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11000, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11001, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11002, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11003, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11004, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11005, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11006, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11007, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11008, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11009, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11010, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11011, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11012, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11013, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11014, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11015, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11016, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11017, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11018, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11019, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11020, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11021, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11022, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11023, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11024, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11025, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11026, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11291, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11292, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11293, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11294, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11295, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11296, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11297, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11298, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11299, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11300, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11301, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11302, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11303, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11304, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11305, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11306, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11307, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11308, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11309, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11310, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11311, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11312, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11313, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11314, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11315, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11316, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11317, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11318, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11319, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Ethanol', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11320, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11321, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11322, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11323, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11324, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11325, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11326, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11327, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11328, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11329, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11330, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11331, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11332, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11333, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11334, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11335, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11336, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11337, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11338, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11339, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11340, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11341, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11342, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11343, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11344, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11345, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11346, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11347, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11348, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11349, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11350, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11351, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11352, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11353, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11354, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11355, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11356, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11357, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11358, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11359, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11360, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11361, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11362, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11363, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11364, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11365, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11366, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11367, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11368, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11369, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11370, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11371, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11372, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11373, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11374, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11375, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11376, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11377, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11378, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11379, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11380, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11381, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11382, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11383, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11384, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11385, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Ethanol', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11386, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11387, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11388, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11389, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11390, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11391, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11392, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11393, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11394, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11395, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11396, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11397, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11398, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11399, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11400, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0

EXEC uspTFUpgradeReportingComponentOutputDesigners @ReportingComponentOutputDesigners = @ReportingComponentOutputDesigners


-- Filing Packet
/* Generate script for Filing Packets. Specify Tax Authority Id to filter out specific Filing Packets only.
select 'UNION ALL SELECT intFilingPacketId = ' + CAST(intFilingPacketId AS NVARCHAR(10))
	+ CASE WHEN strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END
	+ CASE WHEN ysnStatus IS NULL THEN ', ysnStatus = NULL' ELSE ', ysnStatus = ' + CAST(ysnStatus AS NVARCHAR) END
	+ CASE WHEN intFrequency IS NULL THEN ', intFrequency = NULL' ELSE ', intFrequency = ' + CAST(intFrequency AS NVARCHAR(10)) END
from tblTFFilingPacket FP
left join tblTFReportingComponent RC on RC.intReportingComponentId = FP.intReportingComponentId
where FP.intTaxAuthorityId = 
*/
DECLARE @FilingPackets AS TFFilingPackets

INSERT INTO @FilingPackets(
	intFilingPacketId
	, strFormCode
	, strScheduleCode
	, strType
	, ysnStatus
	, intFrequency
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intFilingPacketId = 89, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 90, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 95, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1090, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1091, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1092, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1093, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1094, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1095, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1096, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1097, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1098, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1099, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1100, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1101, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1102, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed or Dyed Kerosene', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1103, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1104, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1105, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1106, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1107, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1108, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1109, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1110, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1111, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1112, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1113, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1114, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1115, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1116, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1117, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1118, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Gasoline', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1119, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Jet Fuel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1120, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1121, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1122, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Gasoline', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1123, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Jet Fuel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1124, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1125, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1126, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1127, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1129, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1130, strFormCode = 'Form 73', strScheduleCode = '', strType = '', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1131, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1132, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1133, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1134, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1135, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1136, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1137, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1138, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1139, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Ethanol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1140, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Biodiesel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1141, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1142, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1143, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Ethanol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1144, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Biodiesel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1145, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Ethanol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1146, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Biodiesel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1147, strFormCode = 'Form 83', strScheduleCode = '', strType = '', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 1148, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', ysnStatus = 1, intFrequency = 2

EXEC uspTFUpgradeFilingPackets @TaxAuthorityCode = @TaxAuthorityCode, @FilingPackets = @FilingPackets

GO