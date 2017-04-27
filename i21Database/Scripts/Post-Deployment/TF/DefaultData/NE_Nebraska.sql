-- Declare the Tax Authority Code that will be used all throughout Nebraska Default Data
PRINT ('Deploying Nebraska Tax Forms')
DECLARE @TaxAuthorityCode NVARCHAR(10) = 'NE'
		, @TaxAuthorityId INT
SELECT @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = @TaxAuthorityCode


-- Product Codes
/* Generate script for Product Codes. Specify Tax Authority Id to filter out specific Product Codes only.
select 'UNION ALL SELECT intProductCodeId = ' + CAST(intProductCodeId AS NVARCHAR(10)) 
	+ CASE WHEN strProductCode IS NULL THEN ', strProductCode = NULL' ELSE ', strProductCode = ''' + strProductCode + ''''  END
	+ CASE WHEN strDescription IS NULL THEN ', strDescription = NULL' ELSE ', strDescription = ''' + strDescription + ''''  END
	+ CASE WHEN strProductCodeGroup IS NULL THEN ', strProductCodeGroup = NULL' ELSE ', strProductCodeGroup = ''' + strProductCodeGroup + ''''  END
	+ CASE WHEN strNote IS NULL THEN ', strNote = NULL' ELSE ', strNote = ''' + strNote + '''' END 
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
where intTaxAuthorityId = @TaxAuthorityId
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
where intTaxAuthorityId = @TaxAuthorityId
*/
DECLARE @TaxCategory AS TFTaxCategory

INSERT INTO @TaxCategory(
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

EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = @TaxAuthorityCode, @TaxCategories = @TaxCategory


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
	, intPositionId
	, strSPInventory
	, strSPInvoice
	, strSPRunReport
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intReportingComponentId = 89, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '1', strScheduleName = 'Gross Gallons Received with Tax and PRF Fee Paid', strType = 'Gasoline / Gasohol / Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 10, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 90, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '1', strScheduleName = 'Gross Gallons Received with Tax and PRF Fee Paid', strType = 'Undyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 20, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 95, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '1', strScheduleName = 'Gross Gallons Received with Tax and PRF Fee Paid', strType = 'Aviation Gasoline', strNote = '', strTransactionType = 'Inventory', intPositionId = 30, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1091, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '1', strScheduleName = 'Gross Gallons Received with Tax and PRF Fee Paid', strType = 'Aviation Jet Fuel', strNote = '', strTransactionType = 'Inventory', intPositionId = 40, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1092, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '2', strScheduleName = 'Gross Gallons Received without Tax or PRF Fee Paid', strType = 'Gasoline / Gasohol / Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 50, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1093, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '2', strScheduleName = 'Gross Gallons Received without Tax or PRF Fee Paid', strType = 'Undyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 60, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1094, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '2', strScheduleName = 'Gross Gallons Received without Tax or PRF Fee Paid', strType = 'Dyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 70, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1095, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '2', strScheduleName = 'Gross Gallons Received without Tax or PRF Fee Paid', strType = 'Aviation Gasoline', strNote = '', strTransactionType = 'Inventory', intPositionId = 80, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1096, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '2', strScheduleName = 'Gross Gallons Received without Tax or PRF Fee Paid', strType = 'Aviation Jet Fuel', strNote = '', strTransactionType = 'Inventory', intPositionId = 90, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1097, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '3', strScheduleName = 'Gross Gallons Imported without Tax or PRF Fee Paid', strType = 'Gasoline / Gasohol / Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 100, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1098, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '3', strScheduleName = 'Gross Gallons Imported without Tax or PRF Fee Paid', strType = 'Undyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 110, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1099, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '3', strScheduleName = 'Gross Gallons Imported without Tax or PRF Fee Paid', strType = 'Dyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 120, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1100, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '3', strScheduleName = 'Gross Gallons Imported without Tax or PRF Fee Paid', strType = 'Aviation Gasoline', strNote = '', strTransactionType = 'Inventory', intPositionId = 130, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1101, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '3', strScheduleName = 'Gross Gallons Imported without Tax or PRF Fee Paid', strType = 'Aviation Jet Fuel', strNote = '', strTransactionType = 'Inventory', intPositionId = 140, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1102, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '5', strScheduleName = 'Gross Gallons Delivered with Tax and PRF Fee Paid', strType = 'Gasoline / Gasohol / Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 150, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1103, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '5', strScheduleName = 'Gross Gallons Delivered with Tax and PRF Fee Paid', strType = 'Undyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 160, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1104, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '5', strScheduleName = 'Gross Gallons Delivered with Tax and PRF Fee Paid', strType = 'Undyed or Dyed Kerosene', strNote = '', strTransactionType = 'Inventory', intPositionId = 170, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1105, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '5', strScheduleName = 'Gross Gallons Delivered with Tax and PRF Fee Paid', strType = 'Aviation Gasoline', strNote = '', strTransactionType = 'Inventory', intPositionId = 180, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1106, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '5', strScheduleName = 'Gross Gallons Delivered with Tax and PRF Fee Paid', strType = 'Aviation Jet Fuel', strNote = '', strTransactionType = 'Inventory', intPositionId = 190, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1107, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '6', strScheduleName = 'Gross Gallons Disbursed without Tax or PRF Fee', strType = 'Gasoline / Gasohol / Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 200, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1108, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '6', strScheduleName = 'Gross Gallons Disbursed without Tax or PRF Fee', strType = 'Undyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 210, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1109, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '6', strScheduleName = 'Gross Gallons Disbursed without Tax or PRF Fee', strType = 'Dyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 220, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1110, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '6', strScheduleName = 'Gross Gallons Disbursed without Tax or PRF Fee', strType = 'Aviation Gasoline', strNote = '', strTransactionType = 'Inventory', intPositionId = 230, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1111, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '6', strScheduleName = 'Gross Gallons Disbursed without Tax or PRF Fee', strType = 'Aviation Jet Fuel', strNote = '', strTransactionType = 'Inventory', intPositionId = 240, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1112, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '7', strScheduleName = 'Gross Gallons Exported without Tax or PRF Fee to Another State', strType = 'Gasoline / Gasohol / Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 250, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1113, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '7', strScheduleName = 'Gross Gallons Exported without Tax or PRF Fee to Another State', strType = 'Undyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 260, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1114, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '7', strScheduleName = 'Gross Gallons Exported without Tax or PRF Fee to Another State', strType = 'Dyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 270, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1115, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '7', strScheduleName = 'Gross Gallons Exported without Tax or PRF Fee to Another State', strType = 'Aviation Gasoline', strNote = '', strTransactionType = 'Inventory', intPositionId = 280, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1116, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '7', strScheduleName = 'Gross Gallons Exported without Tax or PRF Fee to Another State', strType = 'Aviation Jet Fuel', strNote = '', strTransactionType = 'Inventory', intPositionId = 290, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1117, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '8', strScheduleName = 'Gross Gallons Delivered to US Government or Metro Transit Authority', strType = 'Gasoline / Gasohol / Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 300, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1118, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '8', strScheduleName = 'Gross Gallons Delivered to US Government or Metro Transit Authority', strType = 'Undyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 310, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1119, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '8', strScheduleName = 'Gross Gallons Delivered to US Government or Metro Transit Authority', strType = 'Dyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 320, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1120, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '8', strScheduleName = 'Gross Gallons Delivered to US Government or Metro Transit Authority', strType = 'Aviation Gasoline', strNote = '', strTransactionType = 'Inventory', intPositionId = 330, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1121, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '8', strScheduleName = 'Gross Gallons Delivered to US Government or Metro Transit Authority', strType = 'Aviation Jet Fuel', strNote = '', strTransactionType = 'Inventory', intPositionId = 340, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1122, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '10', strScheduleName = 'Gross Gallons Delivered to Native Americans', strType = 'Gasoline / Gasohol / Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 350, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1123, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '10', strScheduleName = 'Gross Gallons Delivered to Native Americans', strType = 'Undyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 360, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1125, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '10', strScheduleName = 'Gross Gallons Delivered to Native Americans', strType = 'Aviation Gasoline', strNote = '', strTransactionType = 'Inventory', intPositionId = 370, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1126, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '10', strScheduleName = 'Gross Gallons Delivered to Native Americans', strType = 'Aviation Jet Fuel', strNote = '', strTransactionType = 'Inventory', intPositionId = 380, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1127, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '13C', strScheduleName = 'Credit for Tax-Paid Fuel Sold to US Government', strType = 'Gasoline / Gasohol / Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 390, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1128, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '13C', strScheduleName = 'Credit for Tax-Paid Fuel Sold to US Government', strType = 'Undyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 400, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1136, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '13J', strScheduleName = 'Credit for Tax-Paid Fuel Sold Pursuant to Form 91EX', strType = 'Gasoline / Gasohol / Ethanol', strNote = '', strTransactionType = 'Inventory', intPositionId = 410, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1137, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '13J', strScheduleName = 'Credit for Tax-Paid Fuel Sold Pursuant to Form 91EX', strType = 'Undyed Diesel / Biodiesel', strNote = '', strTransactionType = 'Inventory', intPositionId = 420, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
UNION ALL SELECT intReportingComponentId = 1138, strFormCode = 'Form 73', strFormName = 'Monthly Fuels Tax Return', strScheduleCode = '', strScheduleName = 'Main Form', strType = '', strNote = 'Form 73', strTransactionType = 'Inventory', intPositionId = 430, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateForm73'
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
select 'UNION ALL SELECT intTaxCriteriaId = ' + CAST(intReportingComponentCriteriaId AS NVARCHAR(10))
	+ CASE WHEN TaxCat.strTaxCategory IS NULL THEN ', strTaxCategory = NULL' ELSE ', strTaxCategory = ''' + TaxCat.strTaxCategory + ''''  END
	+ CASE WHEN TaxCat.strState IS NULL THEN ', strState = NULL' ELSE ', strState = ''' + TaxCat.strState + ''''  END
	+ CASE WHEN strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END
	+ CASE WHEN strCriteria IS NULL THEN ', strCriteria = NULL' ELSE ', strCriteria = ''' + strCriteria + '''' END
from tblTFReportingComponentCriteria TaxCrit
left join tblTFTaxCategory TaxCat ON TaxCat.intTaxCategoryId = TaxCrit.intTaxCategoryId
left join tblTFReportingComponent RC ON RC.intReportingComponentId = TaxCrit.intReportingComponentId
where RC.intTaxAuthorityId = @TaxAuthorityId and TaxCat.intTaxAuthorityId = @TaxAuthorityId
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
SELECT intTaxCriteriaId = 24, strTaxCategory = 'NE Excise Tax Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 25, strTaxCategory = 'NE PRF Fee Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 26, strTaxCategory = 'NE PRF Fee Diesel Clear', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 27, strTaxCategory = 'NE Excise Tax Diesel Clear', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 28, strTaxCategory = 'NE Excise Tax Aviation Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 29, strTaxCategory = 'NE PRF Fee Aviation Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 30, strTaxCategory = 'NE Excise Tax Jet Fuel', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 31, strTaxCategory = 'NE PRF Fee Jet Fuel', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 32, strTaxCategory = 'NE Excise Tax Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 33, strTaxCategory = 'NE PRF Fee Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 34, strTaxCategory = 'NE PRF Fee Diesel Clear', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 35, strTaxCategory = 'NE Excise Tax Diesel Clear', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 36, strTaxCategory = 'NE Excise Tax Aviation Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 37, strTaxCategory = 'NE PRF Fee Aviation Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 38, strTaxCategory = 'NE Excise Tax Jet Fuel', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 39, strTaxCategory = 'NE PRF Fee Jet Fuel', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 40, strTaxCategory = 'NE Excise Tax Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 41, strTaxCategory = 'NE PRF Fee Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 42, strTaxCategory = 'NE PRF Fee Diesel Clear', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 43, strTaxCategory = 'NE Excise Tax Diesel Clear', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 44, strTaxCategory = 'NE Excise Tax Aviation Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 45, strTaxCategory = 'NE PRF Fee Aviation Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 46, strTaxCategory = 'NE Excise Tax Jet Fuel', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 47, strTaxCategory = 'NE PRF Fee Jet Fuel', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 48, strTaxCategory = 'NE Excise Tax Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 49, strTaxCategory = 'NE PRF Fee Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 50, strTaxCategory = 'NE PRF Fee Diesel Clear', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 51, strTaxCategory = 'NE Excise Tax Diesel Clear', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 52, strTaxCategory = 'NE Excise Tax Aviation Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 53, strTaxCategory = 'NE PRF Fee Aviation Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 54, strTaxCategory = 'NE Excise Tax Jet Fuel', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 55, strTaxCategory = 'NE PRF Fee Jet Fuel', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 56, strTaxCategory = 'NE Excise Tax Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 57, strTaxCategory = 'NE PRF Fee Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 58, strTaxCategory = 'NE PRF Fee Diesel Clear', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 59, strTaxCategory = 'NE Excise Tax Diesel Clear', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 60, strTaxCategory = 'NE Excise Tax Aviation Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 61, strTaxCategory = 'NE PRF Fee Aviation Gasoline', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 62, strTaxCategory = 'NE Excise Tax Jet Fuel', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 63, strTaxCategory = 'NE PRF Fee Jet Fuel', strState = 'NE', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 64, strTaxCategory = 'NE Excise Tax Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 65, strTaxCategory = 'NE PRF Fee Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 66, strTaxCategory = 'NE Excise Tax Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 67, strTaxCategory = 'NE PRF Fee Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 68, strTaxCategory = 'NE Excise Tax Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 69, strTaxCategory = 'NE PRF Fee Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 70, strTaxCategory = 'NE Excise Tax Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 71, strTaxCategory = 'NE PRF Fee Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 72, strTaxCategory = 'NE Excise Tax Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strCriteria = '= 0 '
UNION ALL SELECT intTaxCriteriaId = 73, strTaxCategory = 'NE PRF Fee Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strCriteria = '= 0 '
UNION ALL SELECT intTaxCriteriaId = 74, strTaxCategory = 'NE Excise Tax Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strCriteria = '= 0 '
UNION ALL SELECT intTaxCriteriaId = 75, strTaxCategory = 'NE PRF Fee Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strCriteria = '= 0 '
UNION ALL SELECT intTaxCriteriaId = 76, strTaxCategory = 'NE Excise Tax Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 77, strTaxCategory = 'NE PRF Fee Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 78, strTaxCategory = 'NE Excise Tax Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 79, strTaxCategory = 'NE PRF Fee Ethanol', strState = 'NE', strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strCriteria = '<> 0'

EXEC uspTFUpgradeTaxCriteria @TaxAuthorityCode = @TaxAuthorityCode, @TaxCriteria = @TaxCriteria


-- Reporting Component - Base
/* Generate script for Valid Product Codes. Specify Tax Authority Id to filter out specific Valid Product Codes only.
select 'UNION ALL SELECT intValidProductCodeId = ' + CAST(intReportingComponentProductCodeId AS NVARCHAR(10))
	+ CASE WHEN PC.strProductCode IS NULL THEN ', strProductCode = NULL' ELSE ', strProductCode = ''' + PC.strProductCode + ''''  END
	+ CASE WHEN RC.strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN RC.strType IS NULL THEN ', strType = ''''' ELSE ', strType = ''' + RC.strType + '''' END
from tblTFReportingComponentProductCode RCPC
left join tblTFProductCode PC ON PC.intProductCodeId= RCPC.intProductCodeId
left join tblTFReportingComponent RC ON RC.intReportingComponentId = RCPC.intReportingComponentId
where RC.intTaxAuthorityId = @TaxAuthorityId
*/
/* Generate script for Valid Origin States. Specify Tax Authority Id to filter out specific Valid Origin States only.
select 'UNION ALL SELECT intValidOriginStateId = ' + CAST(intReportingComponentOriginStateId AS NVARCHAR(10))
	+ CASE WHEN RC.strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + RC.strFormCode + ''''  END
	+ CASE WHEN RC.strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + RC.strScheduleCode + ''''  END
	+ CASE WHEN RC.strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + RC.strType + '''' END
	+ CASE WHEN ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS IS NULL THEN ', strState = NULL' ELSE ', strState = ''' + ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS + ''''  END
	+ CASE WHEN RCOS.strType IS NULL THEN ', strStatus = NULL' ELSE ', strStatus = ''' + RCOS.strType + ''''  END
from tblTFReportingComponentOriginState RCOS
left join tblTFOriginDestinationState ODS ON ODS.intOriginDestinationStateId= RCOS.intOriginDestinationStateId
left join tblTFReportingComponent RC ON RC.intReportingComponentId = RCOS.intReportingComponentId
where RC.intTaxAuthorityId = @TaxAuthorityId
*/
/* Generate script for Valid Destination States. Specify Tax Authority Id to filter out specific Valid Destination States only.
select 'UNION ALL SELECT intValidDestinationStateId = ' + CAST(intReportingComponentDestinationStateId AS NVARCHAR(10))
	+ CASE WHEN RC.strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + RC.strFormCode + ''''  END
	+ CASE WHEN RC.strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + RC.strScheduleCode + ''''  END
	+ CASE WHEN RC.strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + RC.strType + '''' END
	+ CASE WHEN ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS IS NULL THEN ', strState = NULL' ELSE ', strState = ''' + ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS + ''''  END
	+ CASE WHEN RCDS.strType IS NULL THEN ', strStatus = NULL' ELSE ', strStatus = ''' + RCDS.strType + ''''  END
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
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intValidProductCodeId = 1029, strProductCode = '061', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1030, strProductCode = '065', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1031, strProductCode = '123', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1032, strProductCode = '124', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1033, strProductCode = '160', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1034, strProductCode = '170', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1035, strProductCode = 'B00', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1036, strProductCode = '125', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline'
UNION ALL SELECT intValidProductCodeId = 1037, strProductCode = '130', strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel'
UNION ALL SELECT intValidProductCodeId = 1038, strProductCode = '061', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1039, strProductCode = '065', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1040, strProductCode = '123', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1041, strProductCode = '124', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1042, strProductCode = '160', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1043, strProductCode = '170', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1044, strProductCode = 'B00', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1045, strProductCode = '171', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1046, strProductCode = '228', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1047, strProductCode = 'D00', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1048, strProductCode = '125', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline'
UNION ALL SELECT intValidProductCodeId = 1049, strProductCode = '130', strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel'
UNION ALL SELECT intValidProductCodeId = 1050, strProductCode = '061', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1051, strProductCode = '065', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1052, strProductCode = '123', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1053, strProductCode = '124', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1054, strProductCode = '160', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1055, strProductCode = '170', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1056, strProductCode = 'B00', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1057, strProductCode = '171', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1058, strProductCode = '228', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1059, strProductCode = 'D00', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1060, strProductCode = '125', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline'
UNION ALL SELECT intValidProductCodeId = 1061, strProductCode = '130', strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel'
UNION ALL SELECT intValidProductCodeId = 1062, strProductCode = '061', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1063, strProductCode = '065', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1064, strProductCode = '123', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1065, strProductCode = '124', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1066, strProductCode = '160', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1067, strProductCode = '170', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1068, strProductCode = 'B00', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1069, strProductCode = '142', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed or Dyed Kerosene'
UNION ALL SELECT intValidProductCodeId = 1070, strProductCode = '125', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline'
UNION ALL SELECT intValidProductCodeId = 1071, strProductCode = '130', strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel'
UNION ALL SELECT intValidProductCodeId = 1072, strProductCode = '061', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1073, strProductCode = '065', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1074, strProductCode = '123', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1075, strProductCode = '124', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1076, strProductCode = '160', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1077, strProductCode = '170', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1078, strProductCode = 'B00', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1079, strProductCode = '171', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1080, strProductCode = '228', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1081, strProductCode = 'D00', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1082, strProductCode = '125', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline'
UNION ALL SELECT intValidProductCodeId = 1083, strProductCode = '130', strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel'
UNION ALL SELECT intValidProductCodeId = 1084, strProductCode = '061', strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1085, strProductCode = '065', strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1086, strProductCode = '123', strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1087, strProductCode = '124', strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1088, strProductCode = '160', strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1089, strProductCode = '170', strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1090, strProductCode = 'B00', strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1091, strProductCode = '171', strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1092, strProductCode = '228', strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1093, strProductCode = 'D00', strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1094, strProductCode = '125', strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline'
UNION ALL SELECT intValidProductCodeId = 1095, strProductCode = '130', strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel'
UNION ALL SELECT intValidProductCodeId = 1096, strProductCode = '061', strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1097, strProductCode = '065', strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1098, strProductCode = '123', strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1099, strProductCode = '124', strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1100, strProductCode = '160', strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1101, strProductCode = '170', strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1102, strProductCode = 'B00', strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1103, strProductCode = '171', strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1104, strProductCode = '228', strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1105, strProductCode = 'D00', strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1106, strProductCode = '125', strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Gasoline'
UNION ALL SELECT intValidProductCodeId = 1107, strProductCode = '130', strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Jet Fuel'
UNION ALL SELECT intValidProductCodeId = 1108, strProductCode = '061', strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1109, strProductCode = '065', strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1110, strProductCode = '123', strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1111, strProductCode = '124', strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1112, strProductCode = '160', strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1113, strProductCode = '170', strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1114, strProductCode = 'B00', strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1115, strProductCode = '125', strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Gasoline'
UNION ALL SELECT intValidProductCodeId = 1116, strProductCode = '130', strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Jet Fuel'
UNION ALL SELECT intValidProductCodeId = 1117, strProductCode = '061', strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1118, strProductCode = '065', strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1119, strProductCode = '123', strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1120, strProductCode = '124', strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1121, strProductCode = '160', strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1122, strProductCode = '170', strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1123, strProductCode = 'B00', strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1124, strProductCode = '061', strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1125, strProductCode = '065', strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1126, strProductCode = '123', strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1127, strProductCode = '124', strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol'
UNION ALL SELECT intValidProductCodeId = 1128, strProductCode = '160', strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1129, strProductCode = '170', strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1130, strProductCode = 'B00', strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1131, strProductCode = '061', strFormCode = 'Form 73', strScheduleCode = '', strType = ''
UNION ALL SELECT intValidProductCodeId = 1132, strProductCode = '123', strFormCode = 'Form 73', strScheduleCode = '', strType = ''
UNION ALL SELECT intValidProductCodeId = 1133, strProductCode = '061', strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol'
UNION ALL SELECT intValidProductCodeId = 1134, strProductCode = '123', strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol'
UNION ALL SELECT intValidProductCodeId = 1135, strProductCode = '170', strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1136, strProductCode = 'B00', strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1137, strProductCode = '061', strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol'
UNION ALL SELECT intValidProductCodeId = 1138, strProductCode = '123', strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol'
UNION ALL SELECT intValidProductCodeId = 1139, strProductCode = '170', strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1140, strProductCode = 'B00', strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1141, strProductCode = '061', strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol'
UNION ALL SELECT intValidProductCodeId = 1142, strProductCode = '123', strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol'
UNION ALL SELECT intValidProductCodeId = 1143, strProductCode = '170', strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1144, strProductCode = 'B00', strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1145, strProductCode = '061', strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol'
UNION ALL SELECT intValidProductCodeId = 1146, strProductCode = '123', strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol'
UNION ALL SELECT intValidProductCodeId = 1147, strProductCode = '170', strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1148, strProductCode = 'B00', strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1149, strProductCode = '061', strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Ethanol'
UNION ALL SELECT intValidProductCodeId = 1150, strProductCode = '123', strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Ethanol'
UNION ALL SELECT intValidProductCodeId = 1151, strProductCode = '170', strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1152, strProductCode = 'B00', strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1153, strProductCode = '061', strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol'
UNION ALL SELECT intValidProductCodeId = 1154, strProductCode = '123', strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol'
UNION ALL SELECT intValidProductCodeId = 1155, strProductCode = '170', strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1156, strProductCode = 'B00', strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1157, strProductCode = '061', strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Ethanol'
UNION ALL SELECT intValidProductCodeId = 1158, strProductCode = '123', strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Ethanol'
UNION ALL SELECT intValidProductCodeId = 1159, strProductCode = '170', strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1160, strProductCode = 'B00', strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1161, strProductCode = '061', strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Ethanol'
UNION ALL SELECT intValidProductCodeId = 1162, strProductCode = '123', strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Ethanol'
UNION ALL SELECT intValidProductCodeId = 1163, strProductCode = '170', strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Biodiesel'
UNION ALL SELECT intValidProductCodeId = 1164, strProductCode = 'B00', strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Biodiesel'

INSERT INTO @ValidOriginStates(
	intValidOriginStateId
	, strFormCode
	, strScheduleCode
	, strType
	, strState
	, strStatus
)
SELECT intValidOriginStateId = 188, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 189, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 190, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 191, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 192, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 193, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 194, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 195, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 196, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 197, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 198, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 199, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 200, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 201, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 202, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 203, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 204, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 205, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 206, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strState = 'NE', strStatus = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 207, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strState = 'NE', strStatus = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 208, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strState = 'NE', strStatus = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 209, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strState = 'NE', strStatus = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 210, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strState = 'NE', strStatus = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 211, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strState = 'NE', strStatus = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 212, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strState = 'NE', strStatus = 'Exclude'

INSERT INTO @ValidDestinationStates(
	intValidDestinationStateId
	, strFormCode
	, strScheduleCode
	, strType
	, strState
	, strStatus
)
SELECT intValidDestinationStateId = 190, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 191, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 192, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 193, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 194, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 195, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 196, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 197, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 198, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 199, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 200, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 201, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 202, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 203, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 204, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 205, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 206, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 207, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strState = 'NE', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 208, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strState = 'NE', strStatus = 'Exclude'
UNION ALL SELECT intValidDestinationStateId = 209, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strState = 'NE', strStatus = 'Exclude'
UNION ALL SELECT intValidDestinationStateId = 210, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strState = 'NE', strStatus = 'Exclude'
UNION ALL SELECT intValidDestinationStateId = 211, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', strState = 'NE', strStatus = 'Exclude'
UNION ALL SELECT intValidDestinationStateId = 212, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', strState = 'NE', strStatus = 'Exclude'
UNION ALL SELECT intValidDestinationStateId = 213, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strState = 'NE', strStatus = 'Exclude'
UNION ALL SELECT intValidDestinationStateId = 214, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strState = 'NE', strStatus = 'Exclude'

EXEC uspTFUpgradeValidProductCodes @TaxAuthorityCode = @TaxAuthorityCode, @ValidProductCodes = @ValidProductCodes
EXEC uspTFUpgradeValidOriginStates @TaxAuthorityCode = @TaxAuthorityCode, @ValidOriginStates = @ValidOriginStates
EXEC uspTFUpgradeValidDestinationStates @TaxAuthorityCode = @TaxAuthorityCode, @ValidDestinationStates = @ValidDestinationStates


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
	, ysnDynamicConfiguration
	, strLastIndexOf
	, strSegment
	, intSort
)
SELECT intReportTemplateId = 263, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Details-001', strReportSection = 'I. RECEIPTS (Gross Gallons)', intReportItemSequence = '1', intTemplateItemNumber = '1', strDescription = '1. Tax-paid gallons, total of MFR Schedule Code 1', strScheduleList = '1', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = '200'
UNION ALL SELECT intReportTemplateId = 264, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Details-002', strReportSection = 'I. RECEIPTS (Gross Gallons)', intReportItemSequence = '2', intTemplateItemNumber = '2', strDescription = '2. Tax-free gallons (without PRF), total of MFR Schedule Codes 2 and 3', strScheduleList = '2,3', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = '210'
UNION ALL SELECT intReportTemplateId = 265, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Details-003', strReportSection = 'II. DISBURSEMENTS (Gross Gallons)', intReportItemSequence = '3', intTemplateItemNumber = '3', strDescription = '3. Tax-paid gallons, total of MFD Schedule Code 5', strScheduleList = '5', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = '220'
UNION ALL SELECT intReportTemplateId = 266, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Details-004', strReportSection = 'II. DISBURSEMENTS (Gross Gallons)', intReportItemSequence = '4', intTemplateItemNumber = '4', strDescription = '4. Other gallons disbursed tax-paid, used in a taxable manner, or blended with undyed diesel', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = '230'
UNION ALL SELECT intReportTemplateId = 267, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Details-005', strReportSection = 'II. DISBURSEMENTS (Gross Gallons)', intReportItemSequence = '5', intTemplateItemNumber = '5', strDescription = '5. Gallons of biodiesel or kerosene blended with dyed diesel', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = '240'
UNION ALL SELECT intReportTemplateId = 268, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Details-006', strReportSection = 'II. DISBURSEMENTS (Gross Gallons)', intReportItemSequence = '6', intTemplateItemNumber = '6', strDescription = '6. Tax-free gallons (without PRF), total of MFD Schedule Codes 6, 7, 8 & 9', strScheduleList = '6,7,8', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = '250'
UNION ALL SELECT intReportTemplateId = 269, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Details-007', strReportSection = 'II. DISBURSEMENTS (Gross Gallons)', intReportItemSequence = '7', intTemplateItemNumber = '7', strDescription = '7. Tax-free gallons sold to Native Americans, total of MFD Schedule Code 10', strScheduleList = '10', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = '260'
UNION ALL SELECT intReportTemplateId = 270, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Details-008', strReportSection = 'II. DISBURSEMENTS (Gross Gallons)', intReportItemSequence = '8', intTemplateItemNumber = '8', strDescription = '8. Gallons disbursed tax-free pursuant to a Form 91EX', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = '270'
UNION ALL SELECT intReportTemplateId = 271, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Details-009', strReportSection = 'II. DISBURSEMENTS (Gross Gallons)', intReportItemSequence = '9', intTemplateItemNumber = '9', strDescription = '9. Credit gallons supported by MFD Schedule Codes 13C and 13J', strScheduleList = '13C,13J', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = '280'
UNION ALL SELECT intReportTemplateId = 272, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Details-010', strReportSection = 'III. TAX COMPUTATION', intReportItemSequence = '10', intTemplateItemNumber = '10', strDescription = '10. Gallons subject to tax: Columns A, B, G, & H (line 2 minus lines 5, 6, 7, 8, & 9) Column D (line 3 plus line 4) Columns E & F (from line 4)', strScheduleList = '5,6,7,8,9', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = '290'
UNION ALL SELECT intReportTemplateId = 273, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Details-011', strReportSection = 'III. TAX COMPUTATION', intReportItemSequence = '11', intTemplateItemNumber = '11', strDescription = '11. Tax rate', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = '300'
UNION ALL SELECT intReportTemplateId = 274, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Details-012', strReportSection = 'III. TAX COMPUTATION', intReportItemSequence = '12', intTemplateItemNumber = '12', strDescription = '12. Gross tax due by fuel type (line 10 multiplied by line 11)', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = '310'
UNION ALL SELECT intReportTemplateId = 275, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Details-013', strReportSection = 'III. TAX COMPUTATION', intReportItemSequence = '13', intTemplateItemNumber = '13', strDescription = '13. Gross tax due for motor vehicle fuels (line 12, column A); diesel fuel (line 12, total of columns B & D); compressed fuel (line 12, total of columns E & F); & aircraft fuels (line 12, total of columns G & H)', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = '320'
UNION ALL SELECT intReportTemplateId = 276, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Details-014', strReportSection = 'III. TAX COMPUTATION', intReportItemSequence = '14', intTemplateItemNumber = '14', strDescription = '14. Commissions allowed: Columns A & G (.0500 on first $5,000 plus .0250 on excess over $5,000) Columns B & E (.0200 on first $5,000 plus .0050 on excess over $5,000)', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = '330'
UNION ALL SELECT intReportTemplateId = 277, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Details-015', strReportSection = 'III. TAX COMPUTATION', intReportItemSequence = '15', intTemplateItemNumber = '15', strDescription = '15. Net tax due (line 13 minus line 14)', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = '340'
UNION ALL SELECT intReportTemplateId = 278, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Details-016', strReportSection = 'IV. PETROLEUM RELEASE REMEDIAL ACTION FEE', intReportItemSequence = '16', intTemplateItemNumber = '16', strDescription = '16. Gallons subject to fee: Columns A, B, D, G, & H (line 10 plus lines 5, 7, 8, & 9) Column C (line 2 minus line 6)', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = '350'
UNION ALL SELECT intReportTemplateId = 279, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Details-017', strReportSection = 'IV. PETROLEUM RELEASE REMEDIAL ACTION FEE', intReportItemSequence = '17', intTemplateItemNumber = '17', strDescription = '17. Fee rate', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = '360'
UNION ALL SELECT intReportTemplateId = 280, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Details-018', strReportSection = 'IV. PETROLEUM RELEASE REMEDIAL ACTION FEE', intReportItemSequence = '18', intTemplateItemNumber = '18', strDescription = '18. Total fee due (line 16 multiplied by line 17)', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = '370'
UNION ALL SELECT intReportTemplateId = 281, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Details-019', strReportSection = 'SUMMARY OF MOTOR FUEL TAXES AND FEES DUE', intReportItemSequence = '19', intTemplateItemNumber = '19', strDescription = '19. Net tax due – motor fuels, line 15, columns A and B', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = '380'
UNION ALL SELECT intReportTemplateId = 282, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Details-020', strReportSection = 'SUMMARY OF MOTOR FUEL TAXES AND FEES DUE', intReportItemSequence = '20', intTemplateItemNumber = '20', strDescription = '20. Net tax due - compressed fuels, line 15, column E', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = '390'
UNION ALL SELECT intReportTemplateId = 283, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Details-021', strReportSection = 'SUMMARY OF MOTOR FUEL TAXES AND FEES DUE', intReportItemSequence = '21', intTemplateItemNumber = '21', strDescription = '21. Net tax due – aircraft fuels, line 15, column G', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = '400'
UNION ALL SELECT intReportTemplateId = 284, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Details-022', strReportSection = 'SUMMARY OF MOTOR FUEL TAXES AND FEES DUE', intReportItemSequence = '22', intTemplateItemNumber = '22', strDescription = '22. Petroleum Release Remedial Action Fee, line 18, column A through column H', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = '410'
UNION ALL SELECT intReportTemplateId = 285, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Details-023', strReportSection = 'SUMMARY OF MOTOR FUEL TAXES AND FEES DUE', intReportItemSequence = '23', intTemplateItemNumber = '23', strDescription = '23. Total taxes and fees due (total of lines 19 through 22)', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = '420'
UNION ALL SELECT intReportTemplateId = 286, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Config-001', strReportSection = 'II. DISBURSEMENTS (Gross Gallons)', intReportItemSequence = '4', intTemplateItemNumber = '4', strDescription = '4. Other gallons disbursed tax-paid, used in a taxable manner, or blended with undyed diesel, for Form 73''s Column D Undyed or Dyned Kerosene', strScheduleList = 'D', strConfiguration = '1', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Configuration', intConfigurationSequence = '230'
UNION ALL SELECT intReportTemplateId = 287, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Config-002', strReportSection = 'II. DISBURSEMENTS (Gross Gallons)', intReportItemSequence = '4', intTemplateItemNumber = '4', strDescription = '4. Other gallons disbursed tax-paid, used in a taxable manner, or blended with undyed diesel, for Form 73''s Column E Propane (LPG)', strScheduleList = 'E', strConfiguration = '2', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Configuration', intConfigurationSequence = '230'
UNION ALL SELECT intReportTemplateId = 288, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Config-003', strReportSection = 'II. DISBURSEMENTS (Gross Gallons)', intReportItemSequence = '4', intTemplateItemNumber = '4', strDescription = '4. Other gallons disbursed tax-paid, used in a taxable manner, or blended with undyed diesel, for Form 73''s Column F Compressed Natural Gas (CNG)', strScheduleList = 'F', strConfiguration = '3', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Configuration', intConfigurationSequence = '230'
UNION ALL SELECT intReportTemplateId = 289, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Config-004', strReportSection = 'II. DISBURSEMENTS (Gross Gallons)', intReportItemSequence = '5', intTemplateItemNumber = '5', strDescription = '5. Gallons of biodiesel or kerosene blended with dyed diesel, for Form 73''s Column B Undyed Diesel / Biodiesel', strScheduleList = 'B', strConfiguration = '1', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Configuration', intConfigurationSequence = '240'
UNION ALL SELECT intReportTemplateId = 290, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Config-005', strReportSection = 'II. DISBURSEMENTS (Gross Gallons)', intReportItemSequence = '5', intTemplateItemNumber = '5', strDescription = '5. Gallons of biodiesel or kerosene blended with dyed diesel, for Form 73''s Column D Undyed or Dyed Kerosene', strScheduleList = 'D', strConfiguration = '2', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Configuration', intConfigurationSequence = '240'
UNION ALL SELECT intReportTemplateId = 291, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Config-006', strReportSection = 'II. DISBURSEMENTS (Gross Gallons)', intReportItemSequence = '8', intTemplateItemNumber = '8', strDescription = '8. Gallons disbursed tax-free pursuant to a Form 91EX, for Form 73''s Column B Undyed Diesel / Biodiesel', strScheduleList = 'B', strConfiguration = '1', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Configuration', intConfigurationSequence = '270'
UNION ALL SELECT intReportTemplateId = 292, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Config-007', strReportSection = 'III. TAX COMPUTATION', intReportItemSequence = '11', intTemplateItemNumber = '11', strDescription = '11. Tax rate, for Form 73''s Column A Gasoline / Gasohol / Ethanol', strScheduleList = 'A', strConfiguration = '0.264', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Configuration', intConfigurationSequence = '300'
UNION ALL SELECT intReportTemplateId = 293, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Config-008', strReportSection = 'III. TAX COMPUTATION', intReportItemSequence = '11', intTemplateItemNumber = '11', strDescription = '11. Tax rate, for Form 73''s Column B Undyed Diesel / Biodiesel', strScheduleList = 'B', strConfiguration = '0.264', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Configuration', intConfigurationSequence = '300'
UNION ALL SELECT intReportTemplateId = 294, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Config-009', strReportSection = 'III. TAX COMPUTATION', intReportItemSequence = '11', intTemplateItemNumber = '11', strDescription = '11. Tax rate, for Form 73''s Column D Undyed or Dyed Kerosene', strScheduleList = 'D', strConfiguration = '0.264', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Configuration', intConfigurationSequence = '300'
UNION ALL SELECT intReportTemplateId = 295, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Config-010', strReportSection = 'III. TAX COMPUTATION', intReportItemSequence = '11', intTemplateItemNumber = '11', strDescription = '11. Tax rate, for Form 73''s Column E Propane (LPG)', strScheduleList = 'E', strConfiguration = '0.264', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Configuration', intConfigurationSequence = '300'
UNION ALL SELECT intReportTemplateId = 296, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Config-011', strReportSection = 'III. TAX COMPUTATION', intReportItemSequence = '11', intTemplateItemNumber = '11', strDescription = '11. Tax rate, for Form 73''s Column F Compressed Natural Gas (CNG)', strScheduleList = 'F', strConfiguration = '0.264', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Configuration', intConfigurationSequence = '300'
UNION ALL SELECT intReportTemplateId = 297, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Config-012', strReportSection = 'III. TAX COMPUTATION', intReportItemSequence = '11', intTemplateItemNumber = '11', strDescription = '11. Tax rate, for Form 73''s Column G Aviation Gas', strScheduleList = 'G', strConfiguration = '0.050', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Configuration', intConfigurationSequence = '300'
UNION ALL SELECT intReportTemplateId = 298, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Config-013', strReportSection = 'III. TAX COMPUTATION', intReportItemSequence = '11', intTemplateItemNumber = '11', strDescription = '11. Tax rate, for Form 73''s Column H Aviation Jet Fuel', strScheduleList = 'H', strConfiguration = '0.030', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Configuration', intConfigurationSequence = '300'
UNION ALL SELECT intReportTemplateId = 299, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Config-014', strReportSection = 'IV. PETROLEUM RELEASE REMEDIAL ACTION FEE', intReportItemSequence = '17', intTemplateItemNumber = '17', strDescription = '17. Fee rate, for Form 73''s Column A Gasoline / Gasohol / Ethanol', strScheduleList = 'A', strConfiguration = '0.009', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Configuration', intConfigurationSequence = '360'
UNION ALL SELECT intReportTemplateId = 300, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Config-015', strReportSection = 'IV. PETROLEUM RELEASE REMEDIAL ACTION FEE', intReportItemSequence = '17', intTemplateItemNumber = '17', strDescription = '17. Fee rate, for Form 73''s Column B Undyed Diesel / Biodiesel', strScheduleList = 'B', strConfiguration = '0.003', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Configuration', intConfigurationSequence = '360'
UNION ALL SELECT intReportTemplateId = 301, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Config-016', strReportSection = 'IV. PETROLEUM RELEASE REMEDIAL ACTION FEE', intReportItemSequence = '17', intTemplateItemNumber = '17', strDescription = '17. Fee rate, for Form 73''s Column C Dyed Diesel / Biodiesel', strScheduleList = 'C', strConfiguration = '0.003', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Configuration', intConfigurationSequence = '360'
UNION ALL SELECT intReportTemplateId = 302, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Config-017', strReportSection = 'IV. PETROLEUM RELEASE REMEDIAL ACTION FEE', intReportItemSequence = '17', intTemplateItemNumber = '17', strDescription = '17. Fee rate, for Form 73''s Column D Undyed or Dyed Kerosene', strScheduleList = 'D', strConfiguration = '0.003', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Configuration', intConfigurationSequence = '360'
UNION ALL SELECT intReportTemplateId = 303, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Config-018', strReportSection = 'IV. PETROLEUM RELEASE REMEDIAL ACTION FEE', intReportItemSequence = '17', intTemplateItemNumber = '17', strDescription = '17. Fee rate, for Form 73''s Column G Aviation Gas', strScheduleList = 'G', strConfiguration = '0.009', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Configuration', intConfigurationSequence = '360'
UNION ALL SELECT intReportTemplateId = 304, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Config-019', strReportSection = 'IV. PETROLEUM RELEASE REMEDIAL ACTION FEE', intReportItemSequence = '17', intTemplateItemNumber = '17', strDescription = '17. Fee rate, for Form 73''s Column H Aviation Jet Fuel', strScheduleList = 'H', strConfiguration = '0.003', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Configuration', intConfigurationSequence = '360'
UNION ALL SELECT intReportTemplateId = 305, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Header-01', strReportSection = 'HEADER', intReportItemSequence = '0', intTemplateItemNumber = '0', strDescription = 'Name of License Holder', strScheduleList = NULL, strConfiguration = 'Name of License Holder test', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'HEADER', intConfigurationSequence = '190'
UNION ALL SELECT intReportTemplateId = 306, strFormCode = 'Form 73', strScheduleCode = '', strType = '', strTemplateItemId = 'Form-73-Header-NEIdNumber', strReportSection = 'HEADER', intReportItemSequence = '0', intTemplateItemNumber = '0', strDescription = 'NE ID Number', strScheduleList = NULL, strConfiguration = 'NE ID Number test', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'HEADER', intConfigurationSequence = '195'
UNION ALL SELECT intReportTemplateId = 336, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA01', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '0', strDescription = 'ISA01 - Authorization Information Qualifier', strScheduleList = NULL, strConfiguration = '03', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '42'
UNION ALL SELECT intReportTemplateId = 337, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA02', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '0', strDescription = 'ISA02 - Authorization Information', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '46'
UNION ALL SELECT intReportTemplateId = 338, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA03', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '0', strDescription = 'ISA03 - Security Information Qualifier', strScheduleList = NULL, strConfiguration = '01', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '48'
UNION ALL SELECT intReportTemplateId = 339, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA04', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '0', strDescription = 'ISA04 - Security Information', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '50'
UNION ALL SELECT intReportTemplateId = 340, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA05', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'ISA07 - Interchange ID Qualifier', strScheduleList = NULL, strConfiguration = '32', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '55'
UNION ALL SELECT intReportTemplateId = 341, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA06', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'ISA06 - Interchange Sender ID (including 6 trailing spaces)', strScheduleList = NULL, strConfiguration = '123456789      ', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '60'
UNION ALL SELECT intReportTemplateId = 342, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA07', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'ISA07 - Interchange ID Qualifier', strScheduleList = NULL, strConfiguration = '01', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '65'
UNION ALL SELECT intReportTemplateId = 343, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA08', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'ISA08 - Interchange Receiver ID (including 6 trailing spaces)', strScheduleList = NULL, strConfiguration = '824799308      ', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '70'
UNION ALL SELECT intReportTemplateId = 344, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA11', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'ISA11 - Repetition Separator', strScheduleList = NULL, strConfiguration = '|', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '75'
UNION ALL SELECT intReportTemplateId = 345, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA12', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'ISA12 - Interchange Control Version Number', strScheduleList = NULL, strConfiguration = '00403', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '80'
UNION ALL SELECT intReportTemplateId = 346, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA13', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'ISA13 - Interchange Control Number (for next transmission)', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '85'
UNION ALL SELECT intReportTemplateId = 347, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA14', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'ISA14 - Acknowledgement Requested', strScheduleList = NULL, strConfiguration = '0', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '90'
UNION ALL SELECT intReportTemplateId = 348, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA15', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'ISA15 - Usage Indicator', strScheduleList = NULL, strConfiguration = 'T', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '95'
UNION ALL SELECT intReportTemplateId = 349, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA16', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'ISA16 - Component Sub-element Separator', strScheduleList = NULL, strConfiguration = '^', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '100'
UNION ALL SELECT intReportTemplateId = 350, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-GS01', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'GS01 - Functional Identifier Code', strScheduleList = NULL, strConfiguration = 'TF', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '105'
UNION ALL SELECT intReportTemplateId = 351, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-GS02', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'GS02 - Application Sender''s Code (no trailing space)', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '110'
UNION ALL SELECT intReportTemplateId = 352, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-GS03', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'GS03 - Receiver''s Code', strScheduleList = NULL, strConfiguration = '824799308050', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '115'
UNION ALL SELECT intReportTemplateId = 353, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-GS06', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'GS06 - Group Control Number (for next transmission)', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '120'
UNION ALL SELECT intReportTemplateId = 354, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-GS07', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'GS07 - Responsible Agency Code', strScheduleList = NULL, strConfiguration = 'X', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '125'
UNION ALL SELECT intReportTemplateId = 355, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-GS08', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'GS08 - Version/Release/Industry ID Code', strScheduleList = NULL, strConfiguration = '004030', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '130'
UNION ALL SELECT intReportTemplateId = 356, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ST01', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'ST01 - Transaction Set Code', strScheduleList = NULL, strConfiguration = '813', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '135'
UNION ALL SELECT intReportTemplateId = 357, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ST02', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'ST02 - Transaction Set Control Number (for next transmission)', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '137'
UNION ALL SELECT intReportTemplateId = 358, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-BTI13', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'BTI13 - Transaction Set Purpose Code', strScheduleList = NULL, strConfiguration = '00', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '140'
UNION ALL SELECT intReportTemplateId = 359, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-BTI14', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'BTI14 - Transaction Type Code', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '145'
UNION ALL SELECT intReportTemplateId = 360, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-FilePath', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'EDI File Path', strScheduleList = NULL, strConfiguration = 'C:\dir', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '155'
UNION ALL SELECT intReportTemplateId = 361, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-FileName1st', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'EDI File Name - 1st part (TST or PRD)', strScheduleList = NULL, strConfiguration = 'T', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '160'
UNION ALL SELECT intReportTemplateId = 362, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-FileName2nd', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'EDI File Name - 2nd part (Tax Payer Code)', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '165'
UNION ALL SELECT intReportTemplateId = 363, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-FileName3rd', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'EDI File Name - 3rd part (Next Sequence Number)', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '170'

EXEC uspTFUpgradeReportingComponentConfigurations @TaxAuthorityCode = @TaxAuthorityCode, @ReportingComponentConfigurations = @ReportingComponentConfigurations

-- Reporting Component - Output Designer
/* Generate script for Reporting Component - Output Designer. Specify Tax Authority Id to filter out specific Reporting Component - Output Designer only.
select 'UNION ALL SELECT intScheduleColumnId = ' + CAST(intReportingComponentFieldId AS NVARCHAR(10))
	+ CASE WHEN strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END
	+ CASE WHEN strColumn IS NULL THEN ', strColumn = NULL' ELSE ', strColumn = ''' + strColumn + '''' END
	+ CASE WHEN strCaption IS NULL THEN ', strCaption = NULL' ELSE ', strCaption = ''' + strCaption + '''' END
	+ CASE WHEN strFormat IS NULL THEN ', strFormat = NULL' ELSE ', strFormat = ''' + strFormat + '''' END
	+ CASE WHEN strFooter IS NULL THEN ', strFooter = NULL' ELSE ', strFooter = ''' + strFooter + '''' END
	+ CASE WHEN intWidth IS NULL THEN ', intWidth = NULL' ELSE ', intWidth = ' + CAST(intWidth AS NVARCHAR(10)) END
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
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intScheduleColumnId = 1038, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1039, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1040, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1041, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1042, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1043, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1044, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1045, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1046, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1047, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1048, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1049, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1050, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1051, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1052, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1053, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1054, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1055, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1056, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1057, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1058, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1059, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1060, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1061, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1062, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1063, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1064, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1065, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1066, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1067, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1068, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1069, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1070, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1071, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1072, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1073, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1074, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1075, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1076, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1077, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1078, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1079, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1080, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1081, strFormCode = 'Form 73', strScheduleCode = '1', strType = 'Aviation Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1082, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1083, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1084, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1085, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1086, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1087, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1088, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1089, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1090, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1091, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1092, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1093, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1094, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1095, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1096, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1097, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1098, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1099, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1100, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1101, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1102, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1103, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1104, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1105, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1106, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1107, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1108, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1109, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1110, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1111, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1112, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1113, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1114, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1115, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1116, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1117, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1118, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1119, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1120, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1121, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1122, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1123, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1124, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1125, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1126, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1127, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1128, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1129, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1130, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1131, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1132, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1133, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1134, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1135, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1136, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Aviation Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1137, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1138, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1139, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1140, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1141, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1142, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1143, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1144, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1145, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1146, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1147, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1148, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1149, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1150, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1151, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1152, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1153, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1154, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1155, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1156, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1157, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1158, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1159, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1160, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1161, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1162, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1163, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1164, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1165, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1166, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1167, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1168, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1169, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Dyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1170, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1171, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1172, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1173, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1174, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1175, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1176, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1177, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1178, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1179, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1180, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1181, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1182, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1183, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1184, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1185, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1186, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1187, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1188, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1189, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1190, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1191, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1192, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1193, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1194, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1195, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1196, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1197, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1198, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1199, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1200, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1201, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1202, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1203, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1204, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1205, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1206, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1207, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1208, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1209, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1210, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1211, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1212, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1213, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1214, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed or Dyed Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1215, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed or Dyed Kerosene', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1216, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed or Dyed Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1217, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed or Dyed Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1218, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed or Dyed Kerosene', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1219, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed or Dyed Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1220, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed or Dyed Kerosene', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1221, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed or Dyed Kerosene', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1222, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed or Dyed Kerosene', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1223, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed or Dyed Kerosene', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1224, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Undyed or Dyed Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1225, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1226, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1227, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1228, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1229, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1230, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1231, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1232, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1233, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1234, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1235, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1236, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1237, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1238, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1239, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1240, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1241, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1242, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1243, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1244, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1245, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1246, strFormCode = 'Form 73', strScheduleCode = '5', strType = 'Aviation Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1247, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1248, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1249, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1250, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1251, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1252, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1253, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1254, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1255, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1256, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1257, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1258, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1259, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1260, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1261, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1262, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1263, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1264, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1265, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1266, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1267, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1268, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1269, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1270, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1271, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1272, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1273, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1274, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1275, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1276, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1277, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1278, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1279, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Dyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1280, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1281, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1282, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1283, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1284, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1285, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1286, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1287, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1288, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1289, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1290, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1291, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1292, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1293, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1294, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1295, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1296, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1297, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1298, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1299, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1300, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1301, strFormCode = 'Form 73', strScheduleCode = '6', strType = 'Aviation Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1302, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1303, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1304, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1305, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1306, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1307, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1308, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1309, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1310, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1311, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1312, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1313, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1314, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1315, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1316, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1317, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1318, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1319, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1320, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1321, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1322, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1323, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1324, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1325, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1326, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1327, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1328, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1329, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1330, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1331, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1332, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1333, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1334, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Dyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1335, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1336, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1337, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1338, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1339, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1340, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1341, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1342, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1343, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1344, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1345, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1346, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1347, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1348, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1349, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1350, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1351, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1352, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1353, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1354, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1355, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1356, strFormCode = 'Form 73', strScheduleCode = '7', strType = 'Aviation Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1357, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1358, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1359, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1360, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1361, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1362, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1363, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1364, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1365, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1366, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1367, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1368, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1369, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1370, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1371, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1372, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1373, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1374, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1375, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1376, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1377, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1378, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1379, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1380, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1381, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1382, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1383, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1384, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1385, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1386, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1387, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1388, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1389, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Dyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1390, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1391, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1392, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1393, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1394, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Gasoline', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1395, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1396, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Gasoline', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1397, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1398, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Gasoline', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1399, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Gasoline', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1400, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1401, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1402, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1403, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1404, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1405, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1406, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1407, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Jet Fuel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1408, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Jet Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1409, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Jet Fuel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1410, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Jet Fuel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1411, strFormCode = 'Form 73', strScheduleCode = '8', strType = 'Aviation Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1412, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1413, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1414, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1415, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1416, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1417, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1418, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1419, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1420, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1421, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1422, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1423, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1424, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1425, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1426, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1427, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1428, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1429, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1430, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1431, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1432, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1433, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1434, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1435, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Gasoline', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1436, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Gasoline', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1437, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1438, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Gasoline', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1439, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1440, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Gasoline', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1441, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1442, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Gasoline', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1443, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Gasoline', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1444, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Gasoline', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1445, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Jet Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1446, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1447, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Jet Fuel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1448, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Jet Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1449, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Jet Fuel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1450, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Jet Fuel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1451, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Jet Fuel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1452, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Jet Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1453, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Jet Fuel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1454, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Jet Fuel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1455, strFormCode = 'Form 73', strScheduleCode = '10', strType = 'Aviation Jet Fuel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1456, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1457, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1458, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1459, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1460, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1461, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1462, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1463, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1464, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1465, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1466, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1467, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1468, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1469, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1470, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1471, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1472, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1473, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1474, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1475, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1476, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1477, strFormCode = 'Form 73', strScheduleCode = '13C', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1478, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1479, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1480, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1481, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1482, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1483, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1484, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1485, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1486, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1487, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1488, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Gasoline / Gasohol / Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1489, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1490, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1491, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1492, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1493, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1494, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1495, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1496, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1497, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1498, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1499, strFormCode = 'Form 73', strScheduleCode = '13J', strType = 'Undyed Diesel / Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1500, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1501, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1502, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1503, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1504, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1505, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1506, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1507, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1508, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1509, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1510, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1511, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1512, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1513, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1514, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1515, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1516, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1517, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1518, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1519, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1520, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1521, strFormCode = 'Form 83', strScheduleCode = '2', strType = 'Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1522, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1523, strFormCode = 'Form 73', strScheduleCode = '2', strType = 'Dyed Diesel / Biodiesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1524, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1525, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1526, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1527, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1528, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1529, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1530, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1531, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1532, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1533, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1534, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1535, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1536, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1537, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1538, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1539, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1540, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1541, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1542, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1543, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1544, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1545, strFormCode = 'Form 83', strScheduleCode = '3', strType = 'Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1546, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1547, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1548, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1549, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1550, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1551, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1552, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1553, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1554, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1555, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1556, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1557, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1558, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1559, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1560, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1561, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1562, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1563, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1564, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1565, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1566, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1567, strFormCode = 'Form 83', strScheduleCode = '5', strType = 'Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1568, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1569, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1570, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1571, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1572, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1573, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1574, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1575, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1576, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1577, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1578, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1579, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1580, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1581, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1582, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1583, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1584, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1585, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1586, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1587, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1588, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1589, strFormCode = 'Form 83', strScheduleCode = '6', strType = 'Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1590, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1591, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1592, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1593, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1594, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1595, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1596, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Ethanol', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1597, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1598, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1599, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1600, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1601, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1602, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1603, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1604, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1605, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1606, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1607, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1608, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1609, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1610, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1611, strFormCode = 'Form 83', strScheduleCode = '6R', strType = 'Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1612, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1613, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1614, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1615, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1616, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1617, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1618, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1619, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1620, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1621, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1622, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1623, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1624, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1625, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1626, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1627, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1628, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1629, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1630, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1631, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1632, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1633, strFormCode = 'Form 83', strScheduleCode = '7', strType = 'Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1634, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1635, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1636, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1637, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1638, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1639, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1640, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1641, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1642, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1643, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1644, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1645, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1646, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1647, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1648, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1649, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1650, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1651, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1652, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1653, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1654, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1655, strFormCode = 'Form 83', strScheduleCode = '8', strType = 'Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1656, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Ethanol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1657, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Ethanol', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1658, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Ethanol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1659, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Ethanol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1660, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Ethanol', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1661, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Ethanol', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1662, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Ethanol', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1663, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Ethanol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1664, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Ethanol', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1665, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Ethanol', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1666, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Ethanol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1667, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Biodiesel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1668, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Biodiesel', strColumn = 'strTransporterName', strCaption = 'Carrier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1669, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Biodiesel', strColumn = 'strTransporterFederalTaxId', strCaption = 'Carrier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1670, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Biodiesel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1671, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Biodiesel', strColumn = 'strOriginState', strCaption = 'Origin', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1672, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Biodiesel', strColumn = 'strDestinationState', strCaption = 'Destination', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1673, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Biodiesel', strColumn = 'strCustomerName', strCaption = 'Purchaser Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1674, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Biodiesel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Purchaser FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1675, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Biodiesel', strColumn = 'dtmDate', strCaption = 'BoL Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1676, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Biodiesel', strColumn = 'strBillOfLading', strCaption = 'Bill of Lading', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1677, strFormCode = 'Form 83', strScheduleCode = '10', strType = 'Biodiesel', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0

EXEC uspTFUpgradeReportingComponentOutputDesigners @TaxAuthorityCode = @TaxAuthorityCode, @ReportingComponentOutputDesigners = @ReportingComponentOutputDesigners


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
UNION ALL SELECT intFilingPacketId = 1129, strFormCode = 'Form 73', strScheduleCode = '3', strType = 'Aviation Jet Fuel', ysnStatus = 1, intFrequency = 2
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