
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

--============================
SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IN'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN

SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '1')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '1', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '2')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '2', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '3')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '3', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '4')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '4', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '5')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '5', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '6')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '6', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '7')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '7', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '8')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '8', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '9')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '9', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '10')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '10', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '11')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '11', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '12')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '12', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '13')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '13', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '14')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '14', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '15')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '15', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '16')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '16', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '17')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '17', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '18')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '18', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '19')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '19', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '20')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '20', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '21')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '21', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '22')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '22', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '23')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '23', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '24')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '24', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '25')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '25', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '26')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '26', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '27')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '27', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '28')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '28', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '29')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '29', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '30')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '30', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '31')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '31', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '32')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '32', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '33')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '33', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '34')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '34', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '37')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '37', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '40')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '40', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '41')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '41', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '42')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '42', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '43')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '43', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '44')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '44', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '45')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '45', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '46')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '46', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '47')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '47', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '48')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '48', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '49')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '49', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '50')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '50', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '51')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '51', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '52')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '52', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '56')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '56', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '57')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '57', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '58')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '58', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '59')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '59', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '60')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '60', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '61')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '61', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '62')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '62', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '63')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '63', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '64')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '64', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '65')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '65', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '66')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '66', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '67')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '67', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '68')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '68', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '69')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '69', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '70')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '70', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '71')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '71', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '72')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '72', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '73')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '73', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '74')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '74', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '75')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '75', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '76')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '76', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '77')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '77', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '78')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '78', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '79')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '79', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '80')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '80', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '81')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '81', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '82')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '82', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '83')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '83', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '84')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '84', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '85')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '85', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '86')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '86', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '87')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '87', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '88')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '88', '1', '2')
END

END
--============================

PRINT 'START MFT Valid Product Code'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11'), 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00'), 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11'), 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226'), '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227'), '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231'), '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232'), '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153'), '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161'), '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167'), '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154'), '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282'), '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283'), '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224'), '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225'), '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285'), '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00'), 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11'), 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00'), 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11'), 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226'), '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227'), '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231'), '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232'), '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153'), '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161'), '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167'), '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154'), '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282'), '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283'), '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224'), '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225'), '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285'), '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00'), 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11'), 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00'), 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11'), 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226'), '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227'), '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231'), '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232'), '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153'), '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161'), '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167'), '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154'), '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282'), '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283'), '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224'), '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225'), '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285'), '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '61' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('61', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00'), 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '61' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('61', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11'), 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '61' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('61', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00'), 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '61' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('61', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11'), 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '61' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('61', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125'), '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '61' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('61', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065'), '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '61' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('61', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061'), '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090'), '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248'), '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198'), '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249'), '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052'), '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196'), '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058'), '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265'), '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126'), '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059'), '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075'), '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223'), '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121'), '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199'), '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091'), '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076'), '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150'), '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130'), '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145'), '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146'), '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147'), '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148'), '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074'), '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073'), '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '100')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '100'), '100')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101'), '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '092')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '092'), '092')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093'), '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '64' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('64', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00'), 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '64' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('64', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11'), 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '64' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('64', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00'), 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '64' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('64', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11'), 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '64' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('64', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125'), '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '64' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('64', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065'), '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '64' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('64', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061'), '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '67' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('67', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00'), 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '67' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('67', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11'), 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '67' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('67', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00'), 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '67' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('67', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11'), 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '67' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('67', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125'), '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '67' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('67', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065'), '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '67' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('67', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061'), '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090'), '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248'), '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198'), '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249'), '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052'), '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196'), '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058'), '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265'), '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126'), '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059'), '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075'), '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223'), '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121'), '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199'), '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091'), '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076'), '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150'), '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130'), '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145'), '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146'), '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147'), '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148'), '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074'), '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073'), '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '100')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '100'), '100')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101'), '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '092')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '092'), '092')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093'), '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090'), '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248'), '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198'), '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249'), '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052'), '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196'), '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058'), '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265'), '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126'), '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059'), '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075'), '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223'), '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121'), '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199'), '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091'), '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076'), '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150'), '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130'), '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145'), '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146'), '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147'), '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148'), '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074'), '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073'), '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '100')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '100'), '100')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101'), '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '092')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '092'), '092')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093'), '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '1' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('1', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00'), 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '1' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('1', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11'), 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '1' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('1', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00'), 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '1' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('1', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11'), 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '1' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('1', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125'), '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '1' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('1', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065'), '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '1' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('1', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061'), '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '4' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('4', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00'), 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '4' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('4', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11'), 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '4' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('4', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00'), 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '4' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('4', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11'), 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '4' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('4', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125'), '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '4' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('4', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065'), '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '4' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('4', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061'), '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '7' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('7', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00'), 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '7' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('7', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11'), 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '7' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('7', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00'), 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '7' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('7', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11'), 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '7' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('7', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125'), '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '7' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('7', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065'), '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '7' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('7', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061'), '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '10' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('10', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00'), 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '10' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('10', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11'), 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '10' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('10', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00'), 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '10' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('10', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11'), 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '10' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('10', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125'), '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '10' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('10', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065'), '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '10' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('10', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061'), '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '13' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('13', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00'), 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '13' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('13', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11'), 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '13' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('13', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00'), 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '13' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('13', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11'), 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '13' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('13', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125'), '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '13' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('13', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065'), '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '13' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('13', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061'), '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '16' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('16', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00'), 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '16' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('16', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11'), 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '16' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('16', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00'), 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '16' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('16', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11'), 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '16' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('16', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125'), '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '16' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('16', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065'), '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '16' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('16', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061'), '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '19' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('19', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00'), 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '19' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('19', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11'), 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '19' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('19', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00'), 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '19' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('19', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11'), 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '19' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('19', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125'), '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '19' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('19', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065'), '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '19' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('19', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061'), '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '22' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('22', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00'), 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '22' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('22', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11'), 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '22' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('22', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00'), 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '22' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('22', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11'), 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '22' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('22', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125'), '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '22' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('22', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065'), '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '22' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('22', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061'), '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '25' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('25', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00'), 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '25' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('25', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11'), 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '25' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('25', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00'), 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '25' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('25', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11'), 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '25' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('25', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125'), '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '25' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('25', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065'), '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '25' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('25', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061'), '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '28' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('28', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00'), 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '28' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('28', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11'), 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '28' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('28', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00'), 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '28' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('28', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11'), 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '28' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('28', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125'), '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '28' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('28', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065'), '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '28' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('28', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061'), '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '31' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('31', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00'), 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '31' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('31', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11'), 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '31' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('31', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00'), 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '31' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('31', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11'), 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '31' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('31', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125'), '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '31' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('31', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065'), '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '31' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('31', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061'), '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '34' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('34', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00'), 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '34' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('34', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11'), 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '34' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('34', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00'), 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '34' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('34', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11'), 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '34' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('34', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125'), '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '34' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('34', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065'), '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '34' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('34', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061'), '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '37' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('37', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00'), 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '37' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('37', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11'), 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '37' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('37', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00'), 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '37' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('37', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11'), 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '37' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('37', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125'), '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '37' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('37', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065'), '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '37' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('37', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061'), '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '2' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('2', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145'), '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '2' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('2', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147'), '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '2' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('2', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073'), '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '2' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('2', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074'), '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '5' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('5', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145'), '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '5' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('5', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147'), '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '5' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('5', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073'), '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '5' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('5', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074'), '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '8' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('8', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145'), '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '8' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('8', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147'), '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '8' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('8', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073'), '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '8' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('8', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074'), '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '11' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('11', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145'), '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '11' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('11', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147'), '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '11' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('11', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073'), '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '11' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('11', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074'), '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '14' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('14', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145'), '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '14' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('14', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147'), '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '14' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('14', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073'), '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '14' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('14', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074'), '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '17' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('17', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145'), '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '17' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('17', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147'), '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '17' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('17', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073'), '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '17' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('17', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074'), '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '20' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('20', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145'), '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '20' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('20', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147'), '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '20' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('20', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073'), '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '20' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('20', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074'), '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '23' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('23', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145'), '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '23' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('23', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147'), '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '23' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('23', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073'), '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '23' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('23', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074'), '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '26' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('26', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145'), '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '26' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('26', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147'), '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '26' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('26', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073'), '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '26' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('26', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074'), '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '29' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('29', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145'), '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '29' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('29', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147'), '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '29' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('29', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073'), '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '29' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('29', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074'), '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '32' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('32', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145'), '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '32' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('32', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147'), '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '32' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('32', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073'), '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '32' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('32', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074'), '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090'), '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248'), '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198'), '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249'), '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052'), '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196'), '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058'), '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265'), '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126'), '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059'), '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075'), '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223'), '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121'), '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199'), '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091'), '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076'), '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231'), '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150'), '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282'), '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152'), '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130'), '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090'), '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248'), '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198'), '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249'), '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052'), '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196'), '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058'), '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265'), '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126'), '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059'), '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075'), '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223'), '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121'), '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199'), '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091'), '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076'), '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231'), '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150'), '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282'), '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152'), '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130'), '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090'), '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248'), '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198'), '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249'), '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052'), '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196'), '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058'), '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265'), '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126'), '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059'), '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075'), '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223'), '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121'), '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199'), '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091'), '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076'), '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231'), '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150'), '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282'), '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152'), '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130'), '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090'), '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248'), '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198'), '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249'), '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052'), '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196'), '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058'), '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265'), '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126'), '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059'), '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075'), '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223'), '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121'), '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199'), '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091'), '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076'), '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231'), '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150'), '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282'), '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152'), '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130'), '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090'), '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248'), '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198'), '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249'), '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052'), '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196'), '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058'), '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265'), '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126'), '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059'), '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075'), '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223'), '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121'), '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199'), '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091'), '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076'), '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231'), '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150'), '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282'), '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152'), '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130'), '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090'), '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248'), '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198'), '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249'), '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052'), '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196'), '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058'), '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265'), '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126'), '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059'), '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075'), '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223'), '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121'), '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199'), '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091'), '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076'), '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231'), '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150'), '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282'), '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152'), '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130'), '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090'), '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248'), '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198'), '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249'), '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052'), '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196'), '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058'), '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265'), '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126'), '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059'), '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075'), '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223'), '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121'), '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199'), '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091'), '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076'), '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231'), '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150'), '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282'), '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152'), '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130'), '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090'), '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248'), '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198'), '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249'), '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052'), '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196'), '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058'), '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265'), '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126'), '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059'), '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075'), '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223'), '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121'), '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199'), '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091'), '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076'), '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231'), '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150'), '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282'), '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152'), '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130'), '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090'), '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248'), '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198'), '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249'), '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052'), '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196'), '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058'), '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265'), '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126'), '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059'), '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075'), '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223'), '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121'), '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199'), '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091'), '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076'), '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231'), '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150'), '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282'), '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152'), '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130'), '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090'), '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248'), '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198'), '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249'), '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052'), '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196'), '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058'), '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265'), '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126'), '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059'), '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075'), '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223'), '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121'), '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199'), '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091'), '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076'), '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231'), '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150'), '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282'), '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152'), '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130'), '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090'), '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248'), '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198'), '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249'), '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052'), '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196'), '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058'), '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265'), '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126'), '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059'), '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075'), '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223'), '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121'), '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199'), '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091'), '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076'), '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231'), '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150'), '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282'), '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152'), '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130'), '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '71' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('71', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00'), 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '71' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('71', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11'), 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '71' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('71', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00'), 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '71' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('71', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11'), 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '71' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('71', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125'), '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '71' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('71', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065'), '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '71' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('71', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061'), '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '74' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('74', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00'), 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '74' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('74', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11'), 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '74' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('74', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00'), 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '74' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('74', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11'), 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '74' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('74', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125'), '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '74' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('74', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065'), '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '74' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('74', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061'), '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '77' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('77', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00'), 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '77' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('77', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11'), 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '77' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('77', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00'), 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '77' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('77', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11'), 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '77' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('77', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125'), '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '77' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('77', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065'), '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '77' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('77', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061'), '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '72' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('72', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145'), '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '72' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('72', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147'), '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '72' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('72', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073'), '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '72' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('72', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074'), '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '75' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('75', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145'), '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '75' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('75', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147'), '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '75' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('75', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073'), '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '75' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('75', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074'), '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '78' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('78', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145'), '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '78' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('78', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147'), '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '78' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('78', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073'), '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '78' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('78', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074'), '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090'), '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248'), '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198'), '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249'), '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052'), '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196'), '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058'), '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265'), '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126'), '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059'), '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075'), '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223'), '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121'), '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199'), '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091'), '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076'), '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231'), '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150'), '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282'), '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152'), '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130'), '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090'), '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248'), '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198'), '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249'), '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052'), '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196'), '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058'), '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265'), '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126'), '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059'), '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075'), '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223'), '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121'), '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199'), '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091'), '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076'), '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231'), '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150'), '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282'), '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152'), '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130'), '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090'), '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248'), '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198'), '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249'), '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052'), '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196'), '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058'), '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265'), '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126'), '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059'), '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075'), '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223'), '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121'), '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199'), '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091'), '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076'), '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231'), '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150'), '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282'), '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152'), '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130'), '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00'), 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11'), 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00'), 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11'), 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226'), '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227'), '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232'), '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153'), '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161'), '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167'), '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154'), '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283'), '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224'), '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225'), '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146'), '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148'), '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285'), '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101'), '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093'), '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00'), 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11'), 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00'), 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11'), 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226'), '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227'), '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232'), '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153'), '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161'), '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167'), '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154'), '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283'), '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224'), '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225'), '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146'), '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148'), '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285'), '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101'), '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093'), '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00'), 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11'), 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00'), 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11'), 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226'), '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227'), '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232'), '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153'), '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161'), '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167'), '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154'), '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283'), '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224'), '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225'), '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146'), '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148'), '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285'), '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101'), '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093'), '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00'), 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11'), 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00'), 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11'), 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226'), '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227'), '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232'), '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153'), '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161'), '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167'), '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154'), '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283'), '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224'), '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225'), '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146'), '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148'), '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285'), '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101'), '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093'), '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00'), 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11'), 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00'), 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11'), 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226'), '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227'), '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232'), '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153'), '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161'), '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167'), '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154'), '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283'), '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224'), '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225'), '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146'), '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148'), '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285'), '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101'), '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093'), '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00'), 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11'), 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00'), 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11'), 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226'), '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227'), '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232'), '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153'), '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161'), '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167'), '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154'), '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283'), '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224'), '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225'), '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146'), '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148'), '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285'), '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101'), '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093'), '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00'), 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11'), 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00'), 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11'), 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226'), '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227'), '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232'), '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153'), '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161'), '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167'), '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154'), '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283'), '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224'), '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225'), '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146'), '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148'), '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285'), '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101'), '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093'), '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '56' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('56', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00'), 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '56' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('56', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11'), 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '56' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('56', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161'), '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '56' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('56', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167'), '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '56' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('56', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154'), '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '56' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('56', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283'), '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '56' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('56', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146'), '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '56' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('56', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148'), '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '56' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('56', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285'), '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '56' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('56', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101'), '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '56' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('56', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093'), '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '57' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('57', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00'), 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '57' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('57', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11'), 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '57' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('57', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226'), '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '57' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('57', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227'), '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '57' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('57', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232'), '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '57' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('57', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153'), '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '57' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('57', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093'), '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00'), 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11'), 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00'), 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11'), 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226'), '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227'), '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232'), '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153'), '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161'), '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167'), '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154'), '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283'), '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224'), '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225'), '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146'), '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148'), '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285'), '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101'), '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093'), '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00'), 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11'), 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00'), 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11'), 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226'), '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227'), '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232'), '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153'), '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161'), '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167'), '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154'), '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283'), '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224'), '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225'), '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146'), '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148'), '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285'), '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101'), '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093'), '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00'), 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11'), 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00'), 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11'), 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226'), '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227'), '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232'), '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153'), '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161'), '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167'), '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154'), '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283'), '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224'), '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225'), '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146'), '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148'), '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285'), '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101'), '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093'), '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00'), 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11'), 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00'), 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11'), 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226'), '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227'), '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232'), '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153'), '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161'), '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167'), '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154'), '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283'), '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224'), '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225'), '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146'), '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148'), '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285'), '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101'), '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093'), '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00'), 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11'), 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00'), 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11'), 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226'), '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227'), '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232'), '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153'), '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161'), '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167'), '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154'), '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283'), '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224'), '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225'), '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146'), '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148'), '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285'), '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101'), '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093'), '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00'), 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11'), 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00'), 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11'), 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226'), '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227'), '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232'), '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153'), '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161'), '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167'), '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154'), '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283'), '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224'), '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225'), '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146'), '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148'), '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285'), '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101'), '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093'), '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00'), 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11'), 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00'), 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11'), 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226'), '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227'), '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232'), '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153'), '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161'), '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167'), '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154'), '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283'), '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224'), '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225'), '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146'), '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148'), '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285'), '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101'), '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093'), '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00'), 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11'), 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00'), 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11'), 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226'), '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227'), '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232'), '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153'), '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161'), '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167'), '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154'), '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283'), '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224'), '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225'), '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146'), '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148'), '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285'), '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101'), '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093'), '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00'), 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11'), 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00'), 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11'), 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226'), '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227'), '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232'), '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153'), '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161'), '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167'), '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154'), '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283'), '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224'), '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225'), '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146'), '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148'), '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285'), '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101'), '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093'), '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00'), 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11'), 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00'), 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11'), 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226'), '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227'), '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232'), '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153'), '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161'), '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167'), '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154'), '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283'), '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224'), '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225'), '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146'), '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148'), '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285'), '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101'), '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093'), '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '41' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('41', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061'), '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '41' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('41', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065'), '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '42' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('42', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00'), 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '42' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('42', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11'), 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '42' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('42', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00'), 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '42' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('42', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11'), 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '43' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('43', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061'), '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '43' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('43', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065'), '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '44' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('44', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00'), 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '44' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('44', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11'), 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '44' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('44', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00'), 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '44' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('44', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11'), 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00'), 'B00')
END

PRINT 'START MFT Valid Product Code'

GO
PRINT 'END TF tblTFScheduleFields'
GO

UPDATE tblTFScheduleFields set strCaption = ISNULL(strCaption, ''), strFormat = ISNULL(strFormat, '')

IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '1' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('1', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '1' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('1', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '1' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('1', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '2')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '1' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('1', 'strTransportationMode', 'Mode', '', 'No', '0', '1167')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '1' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('1', 'strOriginState', 'Origin State', '', 'No', '0', '4')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '1' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('1', 'strDestinationState', 'Destination State', '', 'No', '0', '5')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '1' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('1', 'strVendorName', 'Vendor Name', '', 'No', '0', '6')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '1' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('1', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '7')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '1' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('1', 'dtmDate', 'Date Received', '', 'No', '0', '8')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '1' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('1', 'strBillOfLading', 'Document Number', '', 'No', '0', '9')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '1' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('1', 'dblNet', 'Net Gals', '', 'No', '0', '10')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '1' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('1', 'dblGross', 'Gross Gals', '', 'No', '0', '11')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '1' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('1', 'dblBillQty', 'Billed Gals', '', 'No', '0', '12')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '2' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('2', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '2' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('2', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '2' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('2', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '2' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('2', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '2' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('2', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '2' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('2', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '2' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('2', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '2' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('2', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '2' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('2', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '2' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('2', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '2' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('2', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '2' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('2', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '2' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('2', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '3' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('3', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '3' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('3', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '3' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('3', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '3' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('3', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '3' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('3', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '3' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('3', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '3' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('3', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '3' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('3', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '3' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('3', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '3' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('3', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '3' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('3', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '3' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('3', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '3' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('3', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '4' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('4', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '4' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('4', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '4' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('4', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '4' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('4', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '4' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('4', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '4' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('4', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '4' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('4', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '4' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('4', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '4' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('4', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '4' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('4', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '4' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('4', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '4' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('4', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '4' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('4', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '5' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('5', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '5' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('5', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '5' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('5', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '5' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('5', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '5' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('5', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '5' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('5', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '5' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('5', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '5' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('5', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '5' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('5', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '5' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('5', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '5' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('5', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '5' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('5', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '5' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('5', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '6' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('6', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '6' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('6', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '6' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('6', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '6' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('6', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '6' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('6', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '6' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('6', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '6' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('6', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '6' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('6', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '6' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('6', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '6' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('6', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '6' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('6', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '6' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('6', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '6' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('6', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '7' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('7', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '7' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('7', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '7' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('7', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '7' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('7', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '7' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('7', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '7' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('7', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '7' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('7', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '7' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('7', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '7' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('7', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '7' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('7', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '7' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('7', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '7' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('7', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '7' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('7', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '8' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('8', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '8' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('8', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '8' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('8', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '8' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('8', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '8' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('8', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '8' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('8', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '8' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('8', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '8' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('8', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '8' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('8', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '8' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('8', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '8' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('8', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '8' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('8', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '8' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('8', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '9' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('9', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '9' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('9', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '9' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('9', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '9' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('9', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '9' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('9', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '9' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('9', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '9' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('9', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '9' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('9', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '9' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('9', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '9' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('9', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '9' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('9', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '9' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('9', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '9' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('9', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '10' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('10', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '10' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('10', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '10' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('10', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '10' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('10', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '10' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('10', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '10' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('10', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '10' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('10', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '10' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('10', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '10' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('10', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '10' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('10', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '10' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('10', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '10' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('10', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '10' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('10', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '11' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('11', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '11' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('11', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '11' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('11', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '11' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('11', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '11' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('11', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '11' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('11', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '11' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('11', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '11' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('11', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '11' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('11', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '11' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('11', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '11' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('11', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '11' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('11', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '11' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('11', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '12' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('12', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '12' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('12', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '12' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('12', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '12' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('12', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '12' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('12', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '12' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('12', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '12' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('12', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '12' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('12', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '12' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('12', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '12' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('12', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '12' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('12', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '12' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('12', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '12' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('12', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '13' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('13', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '13' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('13', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '13' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('13', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '13' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('13', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '13' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('13', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '13' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('13', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '13' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('13', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '13' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('13', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '13' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('13', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '13' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('13', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '13' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('13', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '13' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('13', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '13' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('13', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '14' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('14', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '14' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('14', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '14' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('14', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '14' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('14', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '14' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('14', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '14' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('14', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '14' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('14', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '14' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('14', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '14' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('14', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '14' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('14', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '14' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('14', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '14' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('14', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '14' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('14', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '15' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('15', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '15' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('15', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '15' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('15', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '15' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('15', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '15' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('15', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '15' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('15', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '15' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('15', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '15' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('15', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '15' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('15', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '15' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('15', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '15' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('15', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '15' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('15', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '15' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('15', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '16' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('16', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '16' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('16', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '16' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('16', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '16' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('16', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '16' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('16', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '16' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('16', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '16' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('16', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '16' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('16', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '16' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('16', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '16' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('16', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '16' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('16', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '16' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('16', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '16' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('16', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '17' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('17', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '17' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('17', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '17' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('17', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '17' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('17', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '17' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('17', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '17' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('17', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '17' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('17', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '17' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('17', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '17' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('17', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '17' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('17', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '17' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('17', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '17' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('17', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '17' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('17', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '18' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('18', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '18' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('18', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '18' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('18', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '18' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('18', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '18' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('18', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '18' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('18', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '18' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('18', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '18' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('18', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '18' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('18', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '18' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('18', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '18' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('18', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '18' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('18', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '18' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('18', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '46' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('46', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '46' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('46', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '46' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('46', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '46' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('46', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '46' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('46', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '46' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('46', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '46' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('46', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '46' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('46', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '46' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('46', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '46' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('46', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '46' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('46', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '46' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('46', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '46' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('46', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '47' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('47', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '47' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('47', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '47' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('47', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '47' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('47', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '47' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('47', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '47' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('47', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '47' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('47', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '47' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('47', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '47' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('47', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '47' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('47', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '47' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('47', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '47' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('47', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '47' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('47', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '48' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('48', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '48' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('48', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '48' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('48', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '48' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('48', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '48' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('48', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '48' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('48', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '48' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('48', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '48' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('48', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '48' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('48', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '48' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('48', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '48' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('48', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '48' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('48', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '48' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('48', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '49' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('49', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '49' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('49', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '49' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('49', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '49' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('49', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '49' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('49', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '49' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('49', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '49' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('49', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '49' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('49', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '49' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('49', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '49' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('49', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '49' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('49', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '49' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('49', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '49' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('49', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '19' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('19', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '19' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('19', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '19' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('19', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '19' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('19', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '19' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('19', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '19' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('19', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '19' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('19', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '19' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('19', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '19' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('19', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '19' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('19', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '19' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('19', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '19' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('19', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '19' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('19', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '19' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('19', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '20' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('20', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '20' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('20', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '20' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('20', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '20' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('20', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '20' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('20', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '20' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('20', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '20' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('20', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '20' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('20', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '20' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('20', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '20' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('20', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '20' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('20', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '20' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('20', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '20' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('20', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '20' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('20', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '21' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('21', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '21' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('21', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '21' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('21', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '21' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('21', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '21' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('21', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '21' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('21', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '21' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('21', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '21' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('21', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '21' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('21', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '21' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('21', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '21' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('21', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '21' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('21', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '21' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('21', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '21' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('21', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '22' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('22', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '22' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('22', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '22' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('22', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '22' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('22', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '22' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('22', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '22' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('22', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '22' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('22', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '22' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('22', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '22' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('22', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '22' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('22', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '22' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('22', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '22' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('22', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '22' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('22', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '22' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('22', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '23' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('23', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '23' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('23', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '23' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('23', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '23' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('23', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '23' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('23', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '23' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('23', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '23' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('23', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '23' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('23', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '23' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('23', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '23' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('23', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '23' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('23', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '23' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('23', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '23' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('23', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '23' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('23', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '24' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('24', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '24' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('24', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '24' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('24', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '24' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('24', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '24' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('24', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '24' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('24', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '24' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('24', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '24' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('24', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '24' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('24', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '24' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('24', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '24' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('24', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '24' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('24', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '24' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('24', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '24' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('24', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '25' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('25', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '25' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('25', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '25' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('25', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '25' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('25', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '25' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('25', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '25' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('25', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '25' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('25', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '25' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('25', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '25' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('25', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '25' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('25', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '25' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('25', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '25' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('25', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '25' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('25', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '25' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('25', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '26' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('26', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '26' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('26', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '26' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('26', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '26' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('26', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '26' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('26', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '26' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('26', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '26' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('26', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '26' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('26', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '26' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('26', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '26' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('26', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '26' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('26', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '26' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('26', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '26' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('26', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '26' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('26', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '27' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('27', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '27' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('27', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '27' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('27', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '27' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('27', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '27' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('27', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '27' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('27', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '27' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('27', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '27' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('27', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '27' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('27', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '27' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('27', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '27' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('27', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '27' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('27', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '27' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('27', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '27' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('27', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '28' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('28', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '28' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('28', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '28' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('28', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '28' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('28', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '28' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('28', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '28' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('28', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '28' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('28', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '28' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('28', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '28' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('28', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '28' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('28', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '28' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('28', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '28' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('28', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '28' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('28', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '28' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('28', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '29' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('29', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '29' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('29', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '29' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('29', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '29' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('29', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '29' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('29', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '29' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('29', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '29' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('29', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '29' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('29', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '29' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('29', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '29' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('29', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '29' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('29', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '29' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('29', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '29' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('29', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '29' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('29', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '30' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('30', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '30' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('30', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '30' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('30', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '30' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('30', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '30' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('30', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '30' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('30', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '30' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('30', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '30' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('30', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '30' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('30', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '30' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('30', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '30' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('30', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '30' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('30', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '30' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('30', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '30' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('30', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '31' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('31', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '31' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('31', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '31' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('31', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '31' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('31', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '31' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('31', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '31' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('31', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '31' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('31', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '31' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('31', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '31' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('31', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '31' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('31', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '31' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('31', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '31' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('31', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '31' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('31', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '31' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('31', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '32' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('32', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '32' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('32', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '32' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('32', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '32' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('32', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '32' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('32', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '32' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('32', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '32' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('32', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '32' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('32', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '32' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('32', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '32' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('32', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '32' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('32', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '32' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('32', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '32' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('32', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '32' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('32', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '33' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('33', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '33' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('33', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '33' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('33', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '33' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('33', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '33' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('33', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '33' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('33', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '33' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('33', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '33' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('33', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '33' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('33', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '33' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('33', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '33' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('33', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '33' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('33', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '33' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('33', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '33' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('33', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '34' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('34', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '34' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('34', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '34' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('34', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '34' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('34', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '34' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('34', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '34' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('34', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '34' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('34', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '34' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('34', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '34' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('34', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '34' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('34', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '34' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('34', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '34' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('34', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '34' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('34', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '34' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('34', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '37' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('37', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '37' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('37', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '37' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('37', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '37' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('37', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '37' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('37', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '37' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('37', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '37' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('37', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '37' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('37', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '37' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('37', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '37' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('37', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '37' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('37', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '37' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('37', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '37' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('37', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '37' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('37', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '50' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('50', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '50' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('50', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '50' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('50', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '50' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('50', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '50' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('50', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '50' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('50', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '50' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('50', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '50' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('50', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '50' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('50', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '50' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('50', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '50' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('50', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '50' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('50', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '50' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('50', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '50' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('50', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '51' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('51', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '51' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('51', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '51' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('51', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '51' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('51', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '51' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('51', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '51' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('51', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '51' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('51', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '51' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('51', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '51' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('51', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '51' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('51', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '51' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('51', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '51' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('51', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '51' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('51', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '51' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('51', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '52' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('52', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '52' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('52', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '52' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('52', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '52' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('52', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '52' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('52', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '52' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('52', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '52' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('52', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '52' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('52', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '52' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('52', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '52' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('52', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '52' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('52', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '52' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('52', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '52' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('52', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '52' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('52', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '56' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('56', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '56' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('56', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '56' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('56', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '56' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('56', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '56' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('56', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '56' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('56', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '56' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('56', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '56' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('56', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '56' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('56', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '56' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('56', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '56' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('56', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '56' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('56', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '56' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('56', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '56' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('56', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '57' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('57', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '57' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('57', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '57' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('57', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '57' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('57', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '57' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('57', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '57' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('57', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '57' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('57', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '57' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('57', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '57' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('57', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '57' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('57', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '57' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('57', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '57' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('57', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '57' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('57', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '57' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('57', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '71' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('71', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '71' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('71', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '71' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('71', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '71' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('71', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '71' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('71', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '71' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('71', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '71' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('71', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '71' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('71', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '71' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('71', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '71' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('71', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '71' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('71', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '71' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('71', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '71' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('71', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '71' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('71', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '72' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('72', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '72' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('72', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '72' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('72', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '72' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('72', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '72' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('72', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '72' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('72', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '72' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('72', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '72' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('72', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '72' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('72', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '72' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('72', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '72' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('72', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '72' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('72', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '72' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('72', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '72' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('72', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '73' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('73', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '73' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('73', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '73' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('73', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '73' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('73', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '73' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('73', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '73' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('73', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '73' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('73', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '73' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('73', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '73' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('73', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '73' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('73', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '73' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('73', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '73' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('73', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '73' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('73', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '73' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('73', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '74' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('74', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '74' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('74', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '74' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('74', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '74' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('74', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '74' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('74', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '74' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('74', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '74' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('74', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '74' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('74', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '74' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('74', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '74' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('74', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '74' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('74', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '74' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('74', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '74' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('74', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '74' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('74', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '75' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('75', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '75' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('75', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '75' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('75', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '75' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('75', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '75' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('75', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '75' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('75', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '75' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('75', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '75' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('75', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '75' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('75', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '75' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('75', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '75' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('75', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '75' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('75', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '75' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('75', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '75' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('75', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '76' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('76', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '76' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('76', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '76' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('76', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '76' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('76', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '76' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('76', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '76' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('76', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '76' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('76', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '76' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('76', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '76' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('76', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '76' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('76', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '76' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('76', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '76' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('76', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '76' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('76', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '76' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('76', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '77' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('77', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '77' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('77', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '77' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('77', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '77' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('77', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '77' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('77', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '77' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('77', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '77' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('77', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '77' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('77', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '77' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('77', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '77' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('77', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '77' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('77', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '77' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('77', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '77' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('77', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '77' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('77', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '78' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('78', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '78' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('78', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '78' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('78', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '78' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('78', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '78' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('78', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '78' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('78', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '78' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('78', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '78' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('78', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '78' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('78', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '78' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('78', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '78' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('78', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '78' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('78', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '78' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('78', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '78' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('78', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '79' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('79', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '79' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('79', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '79' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('79', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '79' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('79', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '79' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('79', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '79' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('79', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '79' AND strColumn = 'strTerminalControlNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('79', 'strTerminalControlNumber', 'Terminal', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '79' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('79', 'strCustomerName', 'Sold To', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '79' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('79', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '79' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('79', 'dtmDate', 'Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '79' AND strColumn = 'strInvoiceNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('79', 'strInvoiceNumber', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '79' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('79', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '79' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('79', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '79' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('79', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '80' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('80', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '80' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('80', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '80' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('80', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '80' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('80', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '80' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('80', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '80' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('80', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '80' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('80', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '80' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('80', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '80' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('80', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '80' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('80', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '80' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('80', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '80' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('80', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '80' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('80', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '81' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('81', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '81' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('81', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '81' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('81', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '81' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('81', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '81' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('81', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '81' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('81', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '81' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('81', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '81' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('81', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '81' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('81', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '81' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('81', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '81' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('81', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '81' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('81', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '81' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('81', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '82' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('82', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '82' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('82', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '82' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('82', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '82' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('82', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '82' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('82', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '82' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('82', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '82' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('82', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '82' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('82', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '82' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('82', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '82' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('82', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '82' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('82', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '82' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('82', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '82' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('82', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '83' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('83', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '83' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('83', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '83' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('83', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '83' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('83', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '83' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('83', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '83' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('83', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '83' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('83', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '83' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('83', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '83' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('83', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '83' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('83', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '83' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('83', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '83' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('83', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '83' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('83', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '84' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('84', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '84' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('84', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '84' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('84', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '84' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('84', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '84' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('84', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '84' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('84', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '84' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('84', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '84' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('84', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '84' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('84', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '84' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('84', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '84' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('84', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '84' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('84', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '84' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('84', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '85' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('85', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '85' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('85', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '85' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('85', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '85' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('85', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '85' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('85', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '85' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('85', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '85' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('85', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '85' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('85', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '85' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('85', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '85' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('85', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '85' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('85', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '85' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('85', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '85' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('85', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '86' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('86', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '86' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('86', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '86' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('86', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '86' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('86', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '86' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('86', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '86' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('86', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '86' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('86', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '86' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('86', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '86' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('86', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '86' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('86', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '86' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('86', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '86' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('86', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '86' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('86', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '87' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('87', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '87' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('87', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '87' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('87', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '87' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('87', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '87' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('87', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '87' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('87', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '87' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('87', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '87' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('87', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '87' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('87', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '87' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('87', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '87' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('87', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '87' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('87', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '87' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('87', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '88' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('88', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '88' AND strColumn = 'strTransporterName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('88', 'strTransporterName', 'Transporter Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '88' AND strColumn = 'strTransporterFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('88', 'strTransporterFederalTaxId', 'Transporter FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '88' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('88', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '88' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('88', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '88' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('88', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '88' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('88', 'strVendorName', 'Vendor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '88' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('88', 'strVendorFederalTaxId', 'Vendor FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '88' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('88', 'dtmDate', 'Date Received', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '88' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('88', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '88' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('88', 'dblNet', 'Net Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '88' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('88', 'dblGross', 'Gross Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '88' AND strColumn = 'dblBillQty')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('88', 'dblBillQty', 'Billed Gals', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '60' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('60', 'strProductCode', 'Product Code', '', 'No', '0', '19495')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '60' AND strColumn = 'strConsignorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('60', 'strConsignorName', 'Consignor Name', '', 'No', '0', '19543')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '60' AND strColumn = 'strConsignorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('60', 'strConsignorFederalTaxId', 'Consigner FEIN', '', 'No', '0', '19588')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '60' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('60', 'strVendorName', 'Seller Name', '', 'No', '0', '19633')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '60' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('60', 'strVendorFederalTaxId', 'Seller FEIN', '', 'No', '0', '19636')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '60' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('60', 'strTransportationMode', 'Mode', '', 'No', '0', '19651')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '60' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('60', 'strOriginState', 'Origin State', '', 'No', '0', '19697')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '60' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('60', 'strCustomerName', 'Customer Name', '', 'No', '0', '19702')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '60' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('60', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '19744')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '60' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('60', 'strDestinationState', 'Destination State', '', 'No', '0', '19789')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '60' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('60', 'dtmDate', 'Document Date', '', 'No', '0', '19843')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '60' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('60', 'strBillOfLading', 'Document Number', '', 'No', '0', '19886')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '60' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('60', 'dblGross', 'Gross', '', 'No', '0', '19889')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '60' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('60', 'dblNet', 'Net', '', 'No', '0', '19915')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '61' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('61', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '61' AND strColumn = 'strConsignorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('61', 'strConsignorName', 'Consignor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '61' AND strColumn = 'strConsignorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('61', 'strConsignorFederalTaxId', 'Consigner FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '61' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('61', 'strVendorName', 'Seller Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '61' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('61', 'strVendorFederalTaxId', 'Seller FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '61' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('61', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '61' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('61', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '61' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('61', 'strCustomerName', 'Customer Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '61' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('61', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '61' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('61', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '61' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('61', 'dtmDate', 'Document Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '61' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('61', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '61' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('61', 'dblGross', 'Gross', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '61' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('61', 'dblNet', 'Net', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '62' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('62', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '62' AND strColumn = 'strConsignorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('62', 'strConsignorName', 'Consignor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '62' AND strColumn = 'strConsignorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('62', 'strConsignorFederalTaxId', 'Consigner FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '62' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('62', 'strVendorName', 'Seller Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '62' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('62', 'strVendorFederalTaxId', 'Seller FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '62' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('62', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '62' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('62', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '62' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('62', 'strCustomerName', 'Customer Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '62' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('62', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '62' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('62', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '62' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('62', 'dtmDate', 'Document Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '62' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('62', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '62' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('62', 'dblGross', 'Gross', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '62' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('62', 'dblNet', 'Net', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '63' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('63', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '63' AND strColumn = 'strConsignorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('63', 'strConsignorName', 'Consignor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '63' AND strColumn = 'strConsignorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('63', 'strConsignorFederalTaxId', 'Consigner FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '63' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('63', 'strVendorName', 'Seller Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '63' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('63', 'strVendorFederalTaxId', 'Seller FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '63' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('63', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '63' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('63', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '63' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('63', 'strCustomerName', 'Customer Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '63' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('63', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '63' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('63', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '63' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('63', 'dtmDate', 'Document Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '63' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('63', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '63' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('63', 'dblGross', 'Gross', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '63' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('63', 'dblNet', 'Net', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '64' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('64', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '64' AND strColumn = 'strConsignorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('64', 'strConsignorName', 'Consignor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '64' AND strColumn = 'strConsignorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('64', 'strConsignorFederalTaxId', 'Consigner FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '64' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('64', 'strVendorName', 'Seller Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '64' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('64', 'strVendorFederalTaxId', 'Seller FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '64' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('64', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '64' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('64', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '64' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('64', 'strCustomerName', 'Customer Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '64' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('64', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '64' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('64', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '64' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('64', 'dtmDate', 'Document Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '64' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('64', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '64' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('64', 'dblGross', 'Gross', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '64' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('64', 'dblNet', 'Net', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '65' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('65', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '65' AND strColumn = 'strConsignorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('65', 'strConsignorName', 'Consignor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '65' AND strColumn = 'strConsignorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('65', 'strConsignorFederalTaxId', 'Consigner FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '65' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('65', 'strVendorName', 'Seller Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '65' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('65', 'strVendorFederalTaxId', 'Seller FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '65' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('65', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '65' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('65', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '65' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('65', 'strCustomerName', 'Customer Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '65' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('65', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '65' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('65', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '65' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('65', 'dtmDate', 'Document Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '65' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('65', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '65' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('65', 'dblGross', 'Gross', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '65' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('65', 'dblNet', 'Net', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '66' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('66', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '66' AND strColumn = 'strConsignorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('66', 'strConsignorName', 'Consignor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '66' AND strColumn = 'strConsignorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('66', 'strConsignorFederalTaxId', 'Consigner FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '66' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('66', 'strVendorName', 'Seller Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '66' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('66', 'strVendorFederalTaxId', 'Seller FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '66' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('66', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '66' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('66', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '66' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('66', 'strCustomerName', 'Customer Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '66' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('66', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '66' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('66', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '66' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('66', 'dtmDate', 'Document Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '66' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('66', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '66' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('66', 'dblGross', 'Gross', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '66' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('66', 'dblNet', 'Net', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '67' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('67', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '67' AND strColumn = 'strConsignorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('67', 'strConsignorName', 'Consignor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '67' AND strColumn = 'strConsignorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('67', 'strConsignorFederalTaxId', 'Consigner FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '67' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('67', 'strVendorName', 'Seller Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '67' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('67', 'strVendorFederalTaxId', 'Seller FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '67' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('67', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '67' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('67', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '67' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('67', 'strCustomerName', 'Customer Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '67' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('67', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '67' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('67', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '67' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('67', 'dtmDate', 'Document Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '67' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('67', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '67' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('67', 'dblGross', 'Gross', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '67' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('67', 'dblNet', 'Net', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '68' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('68', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '68' AND strColumn = 'strConsignorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('68', 'strConsignorName', 'Consignor Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '68' AND strColumn = 'strConsignorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('68', 'strConsignorFederalTaxId', 'Consigner FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '68' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('68', 'strVendorName', 'Seller Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '68' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('68', 'strVendorFederalTaxId', 'Seller FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '68' AND strColumn = 'strTransportationMode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('68', 'strTransportationMode', 'Mode', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '68' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('68', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '68' AND strColumn = 'strCustomerName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('68', 'strCustomerName', 'Customer Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '68' AND strColumn = 'strCustomerFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('68', 'strCustomerFederalTaxId', 'Customer FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '68' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('68', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '68' AND strColumn = 'dtmDate')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('68', 'dtmDate', 'Document Date', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '68' AND strColumn = 'strBillOfLading')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('68', 'strBillOfLading', 'Document Number', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '68' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('68', 'dblGross', 'Gross', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '68' AND strColumn = 'dblNet')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('68', 'dblNet', 'Net', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '41' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('41', 'strProductCode', 'Product Code', '', 'No', '0', '20642')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '41' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('41', 'strVendorName', 'Supplier Name', '', 'No', '0', '20648')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '41' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('41', 'strOriginState', 'Origin State', '', 'No', '0', '20652')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '41' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('41', 'strDestinationState', 'Destination State', '', 'No', '0', '20658')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '41' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('41', 'strVendorFederalTaxId', 'Supplier FEIN', '', 'No', '0', '20701')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '41' AND strColumn = 'strVendorLicenseNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('41', 'strVendorLicenseNumber', 'Indiana TID', '', 'No', '0', '20746')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '41' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('41', 'dblGross', 'Total Gals Purchased', '', 'No', '0', '20794')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '41' AND strColumn = 'dblTax')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('41', 'dblTax', 'GUT Paid to Supplier', '', 'No', '0', '20814')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '42' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('42', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '42' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('42', 'strVendorName', 'Supplier Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '42' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('42', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '42' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('42', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '42' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('42', 'strVendorFederalTaxId', 'Supplier FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '42' AND strColumn = 'strVendorLicenseNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('42', 'strVendorLicenseNumber', 'Indiana TID', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '42' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('42', 'dblGross', 'Total Gals Purchased', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '42' AND strColumn = 'dblTax')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('42', 'dblTax', 'GUT Paid to Supplier', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '43' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('43', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '43' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('43', 'strVendorName', 'Supplier Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '43' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('43', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '43' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('43', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '43' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('43', 'strVendorFederalTaxId', 'Supplier FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '43' AND strColumn = 'strVendorLicenseNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('43', 'strVendorLicenseNumber', 'Indiana TID', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '43' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('43', 'dblGross', 'Total Gals Purchased', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '43' AND strColumn = 'dblTax')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('43', 'dblTax', 'GUT Paid to Supplier', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '44' AND strColumn = 'strProductCode')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('44', 'strProductCode', 'Product Code', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '44' AND strColumn = 'strVendorName')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('44', 'strVendorName', 'Supplier Name', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '44' AND strColumn = 'strOriginState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('44', 'strOriginState', 'Origin State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '44' AND strColumn = 'strDestinationState')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('44', 'strDestinationState', 'Destination State', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '44' AND strColumn = 'strVendorFederalTaxId')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('44', 'strVendorFederalTaxId', 'Supplier FEIN', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '44' AND strColumn = 'strVendorLicenseNumber')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('44', 'strVendorLicenseNumber', 'Indiana TID', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '44' AND strColumn = 'dblGross')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('44', 'dblGross', 'Total Gals Purchased', '', 'No', '0', '1')
END
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = '44' AND strColumn = 'dblTax')BEGIN
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])
VALUES('44', 'dblTax', 'GUT Paid to Supplier', '', 'No', '0', '1')
END

GO
PRINT 'END TF tblTFScheduleFields'
GO

--=======================================================
GO
PRINT 'START TF tblTFValidOriginState'
GO

UPDATE tblTFValidOriginState SET strFilter = ISNULL(strFilter, '')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '61')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('61', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '62')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('62', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '64')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('64', '14', 'IN', '')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '60')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('60', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '64')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('64', '14', 'IN', 'Exclude')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '65')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('65', '14', 'IN', 'Exclude')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '67')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('67', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '68')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('68', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '66')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('66', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '63')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('63', '14', 'IN', 'Exclude')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '13')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('13', '14', 'IN', 'Exclude')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '14')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('14', '14', 'IN', 'Exclude')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '15')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('15', '14', 'IN', 'Exclude')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '16')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('16', '14', 'IN', 'Exclude')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '17')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('17', '14', 'IN', 'Exclude')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '18')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('18', '14', 'IN', 'Exclude')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '28')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('28', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '29')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('29', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '30')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('30', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '71')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('71', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '72')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('72', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '73')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('73', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '74')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('74', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '75')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('75', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '76')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('76', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '77')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('77', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '78')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('78', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '79')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('79', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '80')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('80', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '81')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('81', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '82')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('82', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '83')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('83', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '84')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('84', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '85')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('85', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '86')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('86', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '87')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('87', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '88')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('88', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '49')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('49', '14', 'IN', 'Exclude')
END

GO
PRINT 'END TF tblTFValidOriginState'
GO


GO
PRINT 'START TF tblTFValidDestinationState'
GO

UPDATE tblTFValidDestinationState set strStatus = ISNULL(strStatus, '')

IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '61')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('61', '14', 'IN', 'Exclude')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '62')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('62', '14', 'IN', 'Exclude')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '60')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('60', '14', 'IN', 'Exclude')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '63')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('63', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '64')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('64', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '65')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('65', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '67')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('67', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '68')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('68', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '66')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('66', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '13')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('13', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '14')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('14', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '15')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('15', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '16')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('16', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '17')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('17', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '18')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('18', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '28')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('28', '22', 'MI', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '29')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('29', '22', 'MI', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '30')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('30', '22', 'MI', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '71')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('71', '17', 'KY', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '72')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('72', '17', 'KY', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '73')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('73', '17', 'KY', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '74')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('74', '13', 'IL', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '75')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('75', '13', 'IL', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '76')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('76', '13', 'IL', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '77')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('77', '35', 'OH', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '78')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('78', '35', 'OH', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '79')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('79', '35', 'OH', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '80')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('80', '17', 'KY', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '81')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('81', '22', 'MI', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '82')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('82', '35', 'OH', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '83')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('83', '17', 'KY', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '84')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('84', '22', 'MI', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '85')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('85', '35', 'OH', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '86')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('86', '17', 'KY', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '87')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('87', '22', 'MI', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '88')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('88', '35', 'OH', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '49')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('49', '14', 'IN', 'Include')
END

GO
PRINT 'END TF tblTFValidDestinationState'
GO


GO
PRINT 'START TF tblTFTaxCriteria'
GO
DECLARE @intTaxAuthorityId INT
		SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IN'
		IF (@intTaxAuthorityId IS NOT NULL)
			BEGIN
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '1' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '1', 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '2' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '2', 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '3' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '3', 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '4' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '4', 'IN', 'IN Excise Tax Gasoline', '= 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '5' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '5', 'IN', 'IN Excise Tax Gasoline', '= 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '6' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '6', 'IN', 'IN Excise Tax Gasoline', '= 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '7' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '7', 'IN', 'IN Excise Tax Gasoline', '= 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '8' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '8', 'IN', 'IN Excise Tax Gasoline', '= 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '9' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '9', 'IN', 'IN Excise Tax Gasoline', '= 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '13' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '13', 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '14' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '14', 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '15' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '15', 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '19' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '19', 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '20' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '20', 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '21' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '21', 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '22' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '22', 'IN', 'IN Excise Tax Gasoline', '= 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '23' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '23', 'IN', 'IN Excise Tax Gasoline', '= 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '24' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '24', 'IN', 'IN Excise Tax Gasoline', '= 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '83' AND strTaxCategory = 'KY Excise Tax Diesel Clear')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('16', '83', 'KY', 'KY Excise Tax Diesel Clear', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '84' AND strTaxCategory = 'MI Excise Tax Diesel Clear')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('10', '84', 'MI', 'MI Excise Tax Diesel Clear', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '85' AND strTaxCategory = 'KY Excise Tax Diesel Clear')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('16', '85', 'KY', 'KY Excise Tax Diesel Clear', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '46' AND strTaxCategory = 'IN Excise Tax Diesel Clear')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('2', '46', 'IN', 'IN Excise Tax Diesel Clear', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '49' AND strTaxCategory = 'IN Excise Tax Diesel Clear')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('2', '49', 'IN', 'IN Excise Tax Diesel Clear', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '50' AND strTaxCategory = 'IN Excise Tax Diesel Clear')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('2', '50', 'IN', 'IN Excise Tax Diesel Clear', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '51' AND strTaxCategory = 'IN Excise Tax Diesel Clear')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('2', '51', 'IN', 'IN Excise Tax Diesel Clear', '= 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '56' AND strTaxCategory = 'IN Excise Tax Diesel Clear')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('2', '56', 'IN', 'IN Excise Tax Diesel Clear', '= 0')
				END
			END

GO
PRINT 'END TF tblTFTaxCriteria'
GO
