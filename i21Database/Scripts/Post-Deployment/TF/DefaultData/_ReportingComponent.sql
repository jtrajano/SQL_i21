
TRUNCATE TABLE tblTFTransactions
TRUNCATE TABLE tblTFTaxReportSummary

PRINT 'START TF Reporting Component'

DECLARE @intTaxAuthorityId INT
DECLARE @MasterPk	INT
DECLARE @ScheduleFieldTemplateMasterPk INT
DECLARE @ReportingComponentId NVARCHAR(10)

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IN'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN

UPDATE tblTFReportingComponent SET strType = 'Special Fuel' WHERE strFormCode = 'SF-401' AND strScheduleCode = '1A' AND strType = 'Special Fuel (Dyed and Clear Diesel Fuel, Biodiesel and Blended Biodiesel)'
UPDATE tblTFReportingComponent SET strType = 'Gasoline' WHERE strFormCode = 'SF-401' AND strScheduleCode = '1A' AND strType = 'Gasoline (Gasoline, Gasohol)'
UPDATE tblTFReportingComponent SET strType = 'Other Products' WHERE strFormCode = 'SF-401' AND strScheduleCode = '1A' AND strType = 'Other Products (Jet Fuel, Kerosene)'
UPDATE tblTFReportingComponent SET strType = 'Special Fuel' WHERE strFormCode = 'SF-401' AND strScheduleCode = '2A' AND strType = 'Special Fuel (Dyed and Clear Diesel Fuel, Biodiesel and Blended Biodiesel)'
UPDATE tblTFReportingComponent SET strType = 'Gasoline' WHERE strFormCode = 'SF-401' AND strScheduleCode = '2A' AND strType = 'Gasoline (Gasoline, Gasohol)'
UPDATE tblTFReportingComponent SET strType = 'Other Products' WHERE strFormCode = 'SF-401' AND strScheduleCode = '2A' AND strType = 'Other Products (Jet Fuel, Kerosene)'
UPDATE tblTFReportingComponent SET strType = 'Special Fuel' WHERE strFormCode = 'SF-401' AND strScheduleCode = '3A' AND strType = 'Special Fuel (Dyed and Clear Diesel Fuel, Biodiesel and Blended Biodiesel)'
UPDATE tblTFReportingComponent SET strType = 'Gasoline' WHERE strFormCode = 'SF-401' AND strScheduleCode = '3A' AND strType = 'Gasoline (Gasoline, Gasohol)'
UPDATE tblTFReportingComponent SET strType = 'Other Products' WHERE strFormCode = 'SF-401' AND strScheduleCode = '3A' AND strType = 'Other Products (Jet Fuel, Kerosene)'

DELETE FROM tblTFReportingComponent WHERE strFormCode = 'SF-900' AND strScheduleCode IN ('7','7A','7B')
UPDATE tblTFReportingComponent SET strScheduleCode = ISNULL(strScheduleCode, ''), strType = ISNULL(strType, ''), strNote = ISNULL(strNote, ''), strTransactionType = ISNULL(strTransactionType, ''), strSPInventory = ISNULL(strSPInventory, ''), strSPInvoice = ISNULL(strSPInvoice, ''), strSPRunReport = ISNULL(strSPRunReport, '')

IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '1A' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '1A', 'Gallons Received Tax Paid (Gasoline Return Only)', 'Gasoline / Aviation Gasoline / Gasohol', '', 'Inventory', '10', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '1A' AND strType = 'K-1 / K-2 Kerosene')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '1A', 'Gallons Received Tax Paid (Gasoline Return Only)', 'K-1 / K-2 Kerosene', '', 'Inventory', '20', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '1A' AND strType = 'All Other Products')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '1A', 'Gallons Received Tax Paid (Gasoline Return Only)', 'All Other Products', '', 'Inventory', '30', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '2' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '2', 'Gallons Received from Licensed Distributor or Oil Inspection Distributor, Tax Unpaid (Gasoline Only)', 'Gasoline / Aviation Gasoline / Gasohol', '', 'Inventory', '40', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '2' AND strType = 'K-1 / K-2 Kerosene')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '2', 'Gallons Received from Licensed Distributor or Oil Inspection Distributor, Tax Unpaid (Gasoline Only)', 'K-1 / K-2 Kerosene', '', 'Inventory', '50', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '2' AND strType = 'All Other Products')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '2', 'Gallons Received from Licensed Distributor or Oil Inspection Distributor, Tax Unpaid (Gasoline Only)', 'All Other Products', '', 'Inventory', '60', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '2K' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '2K', 'Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose', 'Gasoline / Aviation Gasoline / Gasohol', '', 'Inventory', '70', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '2K' AND strType = 'K-1 / K-2 Kerosene')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '2K', 'Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose', 'K-1 / K-2 Kerosene', '', 'Inventory', '80', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '2K' AND strType = 'All Other Products')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '2K', 'Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose', 'All Other Products', '', 'Inventory', '90', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '2X' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '2X', 'Gallons Received from Distributor on Exchange (Gasoline Only)', 'Gasoline / Aviation Gasoline / Gasohol', '', 'Inventory', '100', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '2X' AND strType = 'K-1 / K-2 Kerosene')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '2X', 'Gallons Received from Distributor on Exchange (Gasoline Only)', 'K-1 / K-2 Kerosene', '', 'Inventory', '110', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '2X' AND strType = 'All Other Products')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '2X', 'Gallons Received from Distributor on Exchange (Gasoline Only)', 'All Other Products', '', 'Inventory', '120', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '3' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '3', 'Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid', 'Gasoline / Aviation Gasoline / Gasohol', '', 'Inventory', '130', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '3' AND strType = 'K-1 / K-2 Kerosene')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '3', 'Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid', 'K-1 / K-2 Kerosene', '', 'Inventory', '140', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '3' AND strType = 'All Other Products')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '3', 'Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid', 'All Other Products', '', 'Inventory', '150', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '4' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '4', 'Gallons Imported into Own Storage  (Gasoline Only)', 'Gasoline / Aviation Gasoline / Gasohol', '', 'Inventory', '160', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '4' AND strType = 'K-1 / K-2 Kerosene')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '4', 'Gallons Imported into Own Storage  (Gasoline Only)', 'K-1 / K-2 Kerosene', '', 'Inventory', '170', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '4' AND strType = 'All Other Products')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '4', 'Gallons Imported into Own Storage  (Gasoline Only)', 'All Other Products', '', 'Inventory', '180', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '5' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '5', 'Gallons Delivered, Tax Collected and Gallons Blended or Dyed Fuel Used', 'Gasoline / Aviation Gasoline / Gasohol', '', 'Invoice', '190', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '5' AND strType = 'K-1 / K-2 Kerosene')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '5', 'Gallons Delivered, Tax Collected and Gallons Blended or Dyed Fuel Used', 'K-1 / K-2 Kerosene', '', 'Invoice', '200', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '5' AND strType = 'All Other Products')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '5', 'Gallons Delivered, Tax Collected and Gallons Blended or Dyed Fuel Used', 'All Other Products', '', 'Invoice', '210', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '6D' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '6D', 'Gallons Sold to Licensed Distributors, Tax Not Collected (Gasoline Only)', 'Gasoline / Aviation Gasoline / Gasohol', '', 'Invoice', '220', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '6D' AND strType = 'K-1 / K-2 Kerosene')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '6D', 'Gallons Sold to Licensed Distributors, Tax Not Collected (Gasoline Only)', 'K-1 / K-2 Kerosene', '', 'Invoice', '230', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '6D' AND strType = 'All Other Products')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '6D', 'Gallons Sold to Licensed Distributors, Tax Not Collected (Gasoline Only)', 'All Other Products', '', 'Invoice', '240', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '6X' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '6X', 'Gallons Disbursed on Exchange', 'Gasoline / Aviation Gasoline / Gasohol', '', 'Invoice', '250', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '6X' AND strType = 'K-1 / K-2 Kerosene')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '6X', 'Gallons Disbursed on Exchange', 'K-1 / K-2 Kerosene', '', 'Invoice', '260', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '6X' AND strType = 'All Other Products')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '6X', 'Gallons Disbursed on Exchange', 'All Other Products', '', 'Invoice', '270', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '7MI' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '7MI', 'Gallons Exported to State of MI', 'Gasoline / Aviation Gasoline / Gasohol', '', 'Invoice', '280', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '7MI' AND strType = 'K-1 / K-2 Kerosene')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '7MI', 'Gallons Exported to State of MI', 'K-1 / K-2 Kerosene', '', 'Invoice', '290', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '7MI' AND strType = 'All Other Products')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '7MI', 'Gallons Exported to State of MI', 'All Other Products', '', 'Invoice', '300', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '8' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '8', 'Gallons of Undyed Special Fuel, Gasoline and Kerosene sold to the US Government Tax Exempt', 'Gasoline / Aviation Gasoline / Gasohol', '', 'Invoice', '370', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '8' AND strType = 'K-1 / K-2 Kerosene')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '8', 'Gallons of Undyed Special Fuel, Gasoline and Kerosene sold to the US Government Tax Exempt', 'K-1 / K-2 Kerosene', '', 'Invoice', '380', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '8' AND strType = 'All Other Products')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '8', 'Gallons of Undyed Special Fuel, Gasoline and Kerosene sold to the US Government Tax Exempt', 'All Other Products', '', 'Invoice', '390', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '10A' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '10A', 'Gallons Delivered to Marina Fuel Dealers', 'Gasoline / Aviation Gasoline / Gasohol', '', 'Invoice', '460', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '10B' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '10B', 'Gallons Delivered to Aviation Fuel Dealers', 'Gasoline / Aviation Gasoline / Gasohol', '', 'Invoice', '490', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '' AND strType = '')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '', 'Main Form', '', 'Form MF-360', '', '520', '', '', '') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'GT-103'  AND strScheduleCode = '1R' AND strType = 'Gasoline')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'GT-103', 'Recap of Gasoline Use Tax by Distributors', '1R', 'Receipt Schedule', 'Gasoline', '', 'Inventory', '530', 'uspTFGT103InventoryTax', 'uspTFGT103InvoiceTax', 'uspTFGenerateGT103') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'GT-103'  AND strScheduleCode = '1R' AND strType = 'Gasohol')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'GT-103', 'Recap of Gasoline Use Tax by Distributors', '1R', 'Receipt Schedule', 'Gasohol', '', 'Inventory', '540', 'uspTFGT103InventoryTax', 'uspTFGT103InvoiceTax', 'uspTFGenerateGT103') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'GT-103'  AND strScheduleCode = '2D' AND strType = 'Gasoline')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'GT-103', 'Recap of Gasoline Use Tax by Distributors', '2D', 'Disbursement Schedule', 'Gasoline', '', 'Invoice', '541', 'uspTFGT103InventoryTax', 'uspTFGT103InvoiceTax', 'uspTFGenerateGT103') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'GT-103'  AND strScheduleCode = '2D' AND strType = 'Gasohol')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'GT-103', 'Recap of Gasoline Use Tax by Distributors', '2D', 'Disbursement Schedule', 'Gasohol', '', 'Invoice', '542', 'uspTFGT103InventoryTax', 'uspTFGT103InvoiceTax', 'uspTFGenerateGT103') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'GT-103'  AND strScheduleCode = '' AND strType = '')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'GT-103', 'Recap of Gasoline Use Tax by Distributors', '', 'Main Form', '', 'Form GT-103', '', '550', '', '', '') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-900'  AND strScheduleCode = '1' AND strType = '')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '1', 'Gallons Received Tax Paid (Special Fuel Returns Only)', '', '', 'Inventory', '560', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-900'  AND strScheduleCode = '2E' AND strType = '')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '2E', 'Gallons Received for Export (Special Fuel Exporters Only)', '', '', 'Inventory', '570', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-900'  AND strScheduleCode = '2K' AND strType = '')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '2K', 'Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose', '', '', 'Inventory', '580', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-900'  AND strScheduleCode = '3' AND strType = '')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '3', 'Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid', '', '', 'Inventory', '590', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-900'  AND strScheduleCode = '5' AND strType = '')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '5', 'Gallons Delivered, Tax Collected and Gallons Blended or Dyed Fuel Used', '', '', 'Invoice', '600', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-900'  AND strScheduleCode = '6' AND strType = '')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '6', 'Gallons Delivered Via Rail, Pipeline or Vessel to Licensed Suppliers, Tax Not Collected (Special Fuel)', '', '', 'Invoice', '610', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-900'  AND strScheduleCode = '6X' AND strType = '')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '6X', 'Gallons Disbursed on Exchange', '', '', 'Invoice', '620', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-900'  AND strScheduleCode = '7IL' AND strType = '')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '7IL', 'Gallons Exported to State of IL', '', '', 'Invoice', '630', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-900'  AND strScheduleCode = '7AIL' AND strType = '')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '7AIL', 'Special Fuel Sold to Unlicensed Exporters for Export to State of IL (IL Tax Collected)', '', '', 'Invoice', '634', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-900'  AND strScheduleCode = '7BIL' AND strType = '')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '7BIL', 'Special Fuel Sold to Licensed Exporters for Export to State of IL', '', '', 'Invoice', '638', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-900'  AND strScheduleCode = '8' AND strType = '')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '8', 'Gallons of Undyed Special Fuel, Gasoline and Kerosene Sold to the US Government Tax Exempt', '', '', 'Invoice', '660', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-900'  AND strScheduleCode = '10' AND strType = '')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '10', 'Gallons Sold of Tax Exempt Dyed Fuel', '', '', 'Invoice', '670', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-900'  AND strScheduleCode = '11' AND strType = '')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '11', 'Diversion Corrections', '', '', 'Invoice', '680', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-900'  AND strScheduleCode = '' AND strType = '')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '', 'Main Form', '', 'Form SF-900', '', '690', '', '', '') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-401'  AND strScheduleCode = '1A' AND strType = 'Special Fuel')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-401', 'Transporters Monthly Tax Return', '1A', 'Exports', 'Special Fuel', 'Dyed and Clear Diesel Fuel, Biodiesel and Blended Biodiesel', 'Invoice', '700', 'uspTFGetInventoryTax', 'uspTFSF401InvoiceTax', 'uspTFGenerateSF401') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-401'  AND strScheduleCode = '1A' AND strType = 'Gasoline')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-401', 'Transporters Monthly Tax Return', '1A', 'Exports', 'Gasoline', 'Gasoline, Gasohol', 'Invoice', '710', 'uspTFGetInventoryTax', 'uspTFSF401InvoiceTax', 'uspTFGenerateSF401') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-401'  AND strScheduleCode = '1A' AND strType = 'Other Products')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-401', 'Transporters Monthly Tax Return', '1A', 'Exports', 'Other Products', 'Jet Fuel, Jerosene', 'Invoice', '720', 'uspTFGetInventoryTax', 'uspTFSF401InvoiceTax', 'uspTFGenerateSF401') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-401'  AND strScheduleCode = '2A' AND strType = 'Special Fuel')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-401', 'Transporters Monthly Tax Return', '2A', 'Imports', 'Special Fuel', 'Dyed and Clear Diesel Fuel, Biodiesel and Blended Biodiesel', 'Invoice', '730', 'uspTFGetInventoryTax', 'uspTFSF401InvoiceTax', 'uspTFGenerateSF401') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-401'  AND strScheduleCode = '2A' AND strType = 'Gasoline')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-401', 'Transporters Monthly Tax Return', '2A', 'Imports', 'Gasoline', 'Gasoline, Gasohol', 'Invoice', '750', 'uspTFGetInventoryTax', 'uspTFSF401InvoiceTax', 'uspTFGenerateSF401') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-401'  AND strScheduleCode = '2A' AND strType = 'Other Products')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-401', 'Transporters Monthly Tax Return', '2A', 'Imports', 'Other Products', 'Jet Fuel, Jerosene', 'Invoice', '760', 'uspTFGetInventoryTax', 'uspTFSF401InvoiceTax', 'uspTFGenerateSF401') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-401'  AND strScheduleCode = '3A' AND strType = 'Special Fuel')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-401', 'Transporters Monthly Tax Return', '3A', 'In-State Transfers', 'Special Fuel', 'Dyed and Clear Diesel Fuel, Biodiesel and Blended Biodiesel', 'Invoice', '770', 'uspTFGetInventoryTax', 'uspTFSF401InvoiceTax', 'uspTFGenerateSF401') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-401'  AND strScheduleCode = '3A' AND strType = 'Gasoline')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-401', 'Transporters Monthly Tax Return', '3A', 'In-State Transfers', 'Gasoline', 'Gasoline, Gasohol', 'Invoice', '780', 'uspTFGetInventoryTax', 'uspTFSF401InvoiceTax', 'uspTFGenerateSF401') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-401'  AND strScheduleCode = '3A' AND strType = 'Other Products')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-401', 'Transporters Monthly Tax Return', '3A', 'In-State Transfers', 'Other Products', 'Jet Fuel, Jerosene', 'Invoice', '790', 'uspTFGetInventoryTax', 'uspTFSF401InvoiceTax', 'uspTFGenerateSF401') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-401'  AND strScheduleCode = '' AND strType = '')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-401', 'Transporters Monthly Tax Return', '', 'Main Form', '', 'Form SF-401', '', '795', '', '', '') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'EDI'  AND strScheduleCode = '' AND strType = 'EDI')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'EDI', 'Electronic file', '', 'IN EDI file', 'EDI', '', '', '800', '', '', '') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '7KY' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '7KY', 'Gallons Exported to State of KY', 'Gasoline / Aviation Gasoline / Gasohol', '', 'Invoice', '310', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '7KY' AND strType = 'K-1 / K-2 Kerosene')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '7KY', 'Gallons Exported to State of KY', 'K-1 / K-2 Kerosene', '', 'Invoice', '320', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '7KY' AND strType = 'All Other Products')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '7KY', 'Gallons Exported to State of KY', 'All Other Products', '', 'Invoice', '330', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '7IL' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '7IL', 'Gallons Exported to State of IL', 'Gasoline / Aviation Gasoline / Gasohol', '', 'Invoice', '340', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '7IL' AND strType = 'K-1 / K-2 Kerosene')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '7IL', 'Gallons Exported to State of IL', 'K-1 / K-2 Kerosene', '', 'Invoice', '350', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '7IL' AND strType = 'All Other Products')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '7IL', 'Gallons Exported to State of IL', 'All Other Products', '', 'Invoice', '360', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '7OH' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '7OH', 'Gallons Exported to State of OH', 'Gasoline / Aviation Gasoline / Gasohol', '', 'Invoice', '365', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '7OH' AND strType = 'K-1 / K-2 Kerosene')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '7OH', 'Gallons Exported to State of OH', 'K-1 / K-2 Kerosene', '', 'Invoice', '366', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'MF-360'  AND strScheduleCode = '7OH' AND strType = 'All Other Products')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '7OH', 'Gallons Exported to State of OH', 'All Other Products', '', 'Invoice', '367', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-900'  AND strScheduleCode = '7KY' AND strType = '')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '7KY', 'Gallons Exported to State of KY', '', '', 'Invoice', '631', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-900'  AND strScheduleCode = '7MI' AND strType = '')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '7MI', 'Gallons Exported to State of MI', '', '', 'Invoice', '632', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-900'  AND strScheduleCode = '7OH' AND strType = '')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '7OH', 'Gallons Exported to State of OH', '', '', 'Invoice', '633', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-900'  AND strScheduleCode = '7AKY' AND strType = '')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '7AKY', 'Special Fuel Sold to Unlicensed Exporters for Export to State of KY (KY Tax Collected)', '', '', 'Invoice', '635', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-900'  AND strScheduleCode = '7AMI' AND strType = '')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '7AMI', 'Special Fuel Sold to Unlicensed Exporters for Export to State of MI (MI Tax Collected)', '', '', 'Invoice', '636', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-900'  AND strScheduleCode = '7AOH' AND strType = '')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '7AOH', 'Special Fuel Sold to Unlicensed Exporters for Export to State of OH (OH Tax Collected)', '', '', 'Invoice', '637', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-900'  AND strScheduleCode = '7BKY' AND strType = '')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '7BKY', 'Special Fuel Sold to Licensed Exporters for Export to State of KY', '', '', 'Invoice', '639', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-900'  AND strScheduleCode = '7BMI' AND strType = '')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '7BMI', 'Special Fuel Sold to Licensed Exporters for Export to State of MI', '', '', 'Invoice', '640', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900') END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent 
WHERE strFormCode = 'SF-900'  AND strScheduleCode = '7BOH' AND strType = '')
BEGIN
INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '7BOH', 'Special Fuel Sold to Licensed Exporters for Export to State of OH', '', '', 'Invoice', '641', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900') END
END

PRINT 'END TF Reporting Component'
