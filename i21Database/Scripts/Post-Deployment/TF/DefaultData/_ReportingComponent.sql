
TRUNCATE TABLE tblTFTransactions
TRUNCATE TABLE tblTFTaxReportSummary

PRINT 'START TF Reporting Component'

DECLARE @intTaxAuthorityId INT = 14
DECLARE @MasterPk	INT
DECLARE @ScheduleFieldTemplateMasterPk INT
DECLARE @ReportingComponentId NVARCHAR(10)


	IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '1A' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '1A', 'Gallons Received Tax Paid (Gasoline Return Only)', 'Gasoline / Aviation Gasoline / Gasohol', NULL, 'Inventory', '10', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '1A', strScheduleName = 'Gallons Received Tax Paid (Gasoline Return Only)', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = NULL, strTransactionType = 'Inventory', intPositionId = '10', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '1A' AND strType = 'Gasoline / Aviation Gasoline / Gasohol'
			END
			

			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '1A' AND strType = 'K-1 / K-2 Kerosene')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '1A', 'Gallons Received Tax Paid (Gasoline Return Only)', 'K-1 / K-2 Kerosene', NULL, 'Inventory', '20', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '1A', strScheduleName = 'Gallons Received Tax Paid (Gasoline Return Only)', strType = 'K-1 / K-2 Kerosene', strNote = NULL, strTransactionType = 'Inventory', intPositionId = '20', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '1A' AND strType = 'K-1 / K-2 Kerosene'
			END


			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '1A' AND strType = 'All Other Products')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '1A', 'Gallons Received Tax Paid (Gasoline Return Only)', 'All Other Products', NULL, 'Inventory', '30', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '1A', strScheduleName = 'Gallons Received Tax Paid (Gasoline Return Only)', strType = 'All Other Products', strNote = NULL, strTransactionType = 'Inventory', intPositionId = '30', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '1A' AND strType = 'All Other Products'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '2' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '2', 'Gallons Received from Licensed Distributor or Oil Inspection Distributor, Tax Unpaid (Gasoline Only)', 'Gasoline / Aviation Gasoline / Gasohol', NULL, 'Inventory', '40', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '2', strScheduleName = 'Gallons Received from Licensed Distributor or Oil Inspection Distributor, Tax Unpaid (Gasoline Only)', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = NULL, strTransactionType = 'Inventory', intPositionId = '40', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '2' AND strType = 'Gasoline / Aviation Gasoline / Gasohol'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '2' AND strType = 'K-1 / K-2 Kerosene')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '2', 'Gallons Received from Licensed Distributor or Oil Inspection Distributor, Tax Unpaid (Gasoline Only)', 'K-1 / K-2 Kerosene', NULL, 'Inventory', '50', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '2', strScheduleName = 'Gallons Received from Licensed Distributor or Oil Inspection Distributor, Tax Unpaid (Gasoline Only)', strType = 'K-1 / K-2 Kerosene', strNote = NULL, strTransactionType = 'Inventory', intPositionId = '50', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '2' AND strType = 'K-1 / K-2 Kerosene'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '2' AND strType = 'All Other Products')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '2', 'Gallons Received from Licensed Distributor or Oil Inspection Distributor, Tax Unpaid (Gasoline Only)', 'All Other Products', NULL, 'Inventory', '60', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '2', strScheduleName = 'Gallons Received from Licensed Distributor or Oil Inspection Distributor, Tax Unpaid (Gasoline Only)', strType = 'All Other Products', strNote = NULL, strTransactionType = 'Inventory', intPositionId = '60', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '2' AND strType = 'All Other Products'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '2K' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '2K', 'Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose', 'Gasoline / Aviation Gasoline / Gasohol', NULL, 'Inventory', '70', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '2K', strScheduleName = 'Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = NULL, strTransactionType = 'Inventory', intPositionId = '70', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '2K' AND strType = 'Gasoline / Aviation Gasoline / Gasohol'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '2K' AND strType = 'K-1 / K-2 Kerosene')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '2K', 'Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose', 'K-1 / K-2 Kerosene', NULL, 'Inventory', '80', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '2K', strScheduleName = 'Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose', strType = 'K-1 / K-2 Kerosene', strNote = NULL, strTransactionType = 'Inventory', intPositionId = '80', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '2K' AND strType = 'K-1 / K-2 Kerosene'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '2K' AND strType = 'All Other Products')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '2K', 'Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose', 'All Other Products', NULL, 'Inventory', '90', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '2K', strScheduleName = 'Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose', strType = 'All Other Products', strNote = NULL, strTransactionType = 'Inventory', intPositionId = '90', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '2K' AND strType = 'All Other Products'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '2X' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '2X', 'Gallons Received from Distributor on Exchange (Gasoline Only)', 'Gasoline / Aviation Gasoline / Gasohol', NULL, 'Inventory', '100', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '2X', strScheduleName = 'Gallons Received from Distributor on Exchange (Gasoline Only)', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = NULL, strTransactionType = 'Inventory', intPositionId = '100', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '2X' AND strType = 'Gasoline / Aviation Gasoline / Gasohol'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '2X' AND strType = 'K-1 / K-2 Kerosene')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '2X', 'Gallons Received from Distributor on Exchange (Gasoline Only)', 'K-1 / K-2 Kerosene', NULL, 'Inventory', '110', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '2X', strScheduleName = 'Gallons Received from Distributor on Exchange (Gasoline Only)', strType = 'K-1 / K-2 Kerosene', strNote = NULL, strTransactionType = 'Inventory', intPositionId = '110', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '2X' AND strType = 'K-1 / K-2 Kerosene'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '2X' AND strType = 'All Other Products')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '2X', 'Gallons Received from Distributor on Exchange (Gasoline Only)', 'All Other Products', NULL, 'Inventory', '120', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '2X', strScheduleName = 'Gallons Received from Distributor on Exchange (Gasoline Only)', strType = 'All Other Products', strNote = NULL, strTransactionType = 'Inventory', intPositionId = '120', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '2X' AND strType = 'All Other Products'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '3' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '3', 'Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid', 'Gasoline / Aviation Gasoline / Gasohol', NULL, 'Inventory', '130', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '3', strScheduleName = 'Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = NULL, strTransactionType = 'Inventory', intPositionId = '130', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '3' AND strType = 'Gasoline / Aviation Gasoline / Gasohol'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '3' AND strType = 'K-1 / K-2 Kerosene')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '3', 'Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid', 'K-1 / K-2 Kerosene', NULL, 'Inventory', '140', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '3', strScheduleName = 'Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid', strType = 'K-1 / K-2 Kerosene', strNote = NULL, strTransactionType = 'Inventory', intPositionId = '140', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '3' AND strType = 'K-1 / K-2 Kerosene'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '3' AND strType = 'All Other Products')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '3', 'Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid', 'All Other Products', NULL, 'Inventory', '150', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '3', strScheduleName = 'Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid', strType = 'All Other Products', strNote = NULL, strTransactionType = 'Inventory', intPositionId = '150', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '3' AND strType = 'All Other Products'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '4' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '4', 'Gallons Imported into Own Storage  (Gasoline Only)', 'Gasoline / Aviation Gasoline / Gasohol', NULL, 'Inventory', '160', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '4', strScheduleName = 'Gallons Imported into Own Storage  (Gasoline Only)', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = NULL, strTransactionType = 'Inventory', intPositionId = '160', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '4' AND strType = 'Gasoline / Aviation Gasoline / Gasohol'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '4' AND strType = 'K-1 / K-2 Kerosene')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '4', 'Gallons Imported into Own Storage  (Gasoline Only)', 'K-1 / K-2 Kerosene', NULL, 'Inventory', '170', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '4', strScheduleName = 'Gallons Imported into Own Storage  (Gasoline Only)', strType = 'K-1 / K-2 Kerosene', strNote = NULL, strTransactionType = 'Inventory', intPositionId = '170', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '4' AND strType = 'K-1 / K-2 Kerosene'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '4' AND strType = 'All Other Products')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '4', 'Gallons Imported into Own Storage  (Gasoline Only)', 'All Other Products', NULL, 'Inventory', '180', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '4', strScheduleName = 'Gallons Imported into Own Storage  (Gasoline Only)', strType = 'All Other Products', strNote = NULL, strTransactionType = 'Inventory', intPositionId = '180', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '4' AND strType = 'All Other Products'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '5' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '5', 'Gallons Delivered, Tax Collected', 'Gasoline / Aviation Gasoline / Gasohol', NULL, 'Invoice', '190', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '5', strScheduleName = 'Gallons Delivered, Tax Collected', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '190', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '5' AND strType = 'Gasoline / Aviation Gasoline / Gasohol'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '5' AND strType = 'K-1 / K-2 Kerosene')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '5', 'Gallons Delivered, Tax Collected and Gallons Blended or Dyed Fuel Used', 'K-1 / K-2 Kerosene', NULL, 'Invoice', '200', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '5', strScheduleName = 'Gallons Delivered, Tax Collected and Gallons Blended or Dyed Fuel Used', strType = 'K-1 / K-2 Kerosene', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '200', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '5' AND strType = 'K-1 / K-2 Kerosene'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '5' AND strType = 'All Other Products')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '5', 'Gallons Delivered, Tax Collected and Gallons Blended or Dyed Fuel Used', 'All Other Products', NULL, 'Invoice', '210', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '5', strScheduleName = 'Gallons Delivered, Tax Collected and Gallons Blended or Dyed Fuel Used', strType = 'All Other Products', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '210', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '5' AND strType = 'All Other Products'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '6D' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '6D', 'Gallons Sold to Licensed Distributors, Tax Not Collected (Gasoline Only)', 'Gasoline / Aviation Gasoline / Gasohol', NULL, 'Invoice', '220', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '6D', strScheduleName = 'Gallons Sold to Licensed Distributors, Tax Not Collected (Gasoline Only)', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '220', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '6D' AND strType = 'Gasoline / Aviation Gasoline / Gasohol'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '6D' AND strType = 'K-1 / K-2 Kerosene')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '6D', 'Gallons Sold to Licensed Distributors, Tax Not Collected (Gasoline Only)', 'K-1 / K-2 Kerosene', NULL, 'Invoice', '230', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '6D', strScheduleName = 'Gallons Sold to Licensed Distributors, Tax Not Collected (Gasoline Only)', strType = 'K-1 / K-2 Kerosene', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '230', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '6D' AND strType = 'K-1 / K-2 Kerosene'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '6D' AND strType = 'All Other Products')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '6D', 'Gallons Sold to Licensed Distributors, Tax Not Collected (Gasoline Only)', 'All Other Products', NULL, 'Invoice', '240', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '6D', strScheduleName = 'Gallons Sold to Licensed Distributors, Tax Not Collected (Gasoline Only)', strType = 'All Other Products', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '240', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '6D' AND strType = 'All Other Products'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '6X' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '6X', 'Gallons Disbursed on exchange', 'Gasoline / Aviation Gasoline / Gasohol', NULL, 'Invoice', '250', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '6X', strScheduleName = 'Gallons Disbursed on exchange', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '250', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '6X' AND strType = 'Gasoline / Aviation Gasoline / Gasohol'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '6X' AND strType = 'K-1 / K-2 Kerosene')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '6X', 'Gallons Disbursed on exchange', 'K-1 / K-2 Kerosene', NULL, 'Invoice', '260', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '6X', strScheduleName = 'Gallons Disbursed on exchange', strType = 'K-1 / K-2 Kerosene', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '260', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '6X' AND strType = 'K-1 / K-2 Kerosene'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '6X' AND strType = 'All Other Products')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '6X', 'Gallons Disbursed on exchange', 'All Other Products', NULL, 'Invoice', '270', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '6X', strScheduleName = 'Gallons Disbursed on exchange', strType = 'All Other Products', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '270', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '6X' AND strType = 'All Other Products'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '7MI' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '7MI', 'Gallons Exported to State of MI', 'Gasoline / Aviation Gasoline / Gasohol', NULL, 'Invoice', '280', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '7MI', strScheduleName = 'Gallons Exported to State of MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '280', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '7MI' AND strType = 'Gasoline / Aviation Gasoline / Gasohol'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '7MI' AND strType = 'K-1 / K-2 Kerosene')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '7MI', 'Gallons Exported to State of MI', 'K-1 / K-2 Kerosene', NULL, 'Invoice', '290', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '7MI', strScheduleName = 'Gallons Exported to State of MI', strType = 'K-1 / K-2 Kerosene', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '290', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '7MI' AND strType = 'K-1 / K-2 Kerosene'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '7MI' AND strType = 'All Other Products')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '7MI', 'Gallons Exported to State of MI', 'All Other Products', NULL, 'Invoice', '300', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '7MI', strScheduleName = 'Gallons Exported to State of MI', strType = 'All Other Products', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '300', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '7MI' AND strType = 'All Other Products'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '8' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '8', 'Gallons of Undyed Special Fuel, Gasoline and Kerosene sold to the US Government Tax Exempt', 'Gasoline / Aviation Gasoline / Gasohol', NULL, 'Invoice', '370', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '8', strScheduleName = 'Gallons of Undyed Special Fuel, Gasoline and Kerosene sold to the US Government Tax Exempt', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '370', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '8' AND strType = 'Gasoline / Aviation Gasoline / Gasohol'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '8' AND strType = 'K-1 / K-2 Kerosene')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '8', 'Gallons of Undyed Special Fuel, Gasoline and Kerosene sold to the US Government Tax Exempt', 'K-1 / K-2 Kerosene', NULL, 'Invoice', '380', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '8', strScheduleName = 'Gallons of Undyed Special Fuel, Gasoline and Kerosene sold to the US Government Tax Exempt', strType = 'K-1 / K-2 Kerosene', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '380', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '8' AND strType = 'K-1 / K-2 Kerosene'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '8' AND strType = 'All Other Products')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '8', 'Gallons of Undyed Special Fuel, Gasoline and Kerosene sold to the US Government Tax Exempt', 'All Other Products', NULL, 'Invoice', '390', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '8', strScheduleName = 'Gallons of Undyed Special Fuel, Gasoline and Kerosene sold to the US Government Tax Exempt', strType = 'All Other Products', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '390', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '8' AND strType = 'All Other Products'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '10A' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '10A', 'Gallons Delivered to Marina Fuel Dealers', 'Gasoline / Aviation Gasoline / Gasohol', NULL, 'Invoice', '460', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '10A', strScheduleName = 'Gallons Delivered to Marina Fuel Dealers', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '460', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '10A' AND strType = 'Gasoline / Aviation Gasoline / Gasohol'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '10A' AND strType = 'K-1 / K-2 Kerosene')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '10A', 'Gallons Delivered to Marina Fuel Dealers', 'K-1 / K-2 Kerosene', NULL, 'Invoice', '470', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '10A', strScheduleName = 'Gallons Delivered to Marina Fuel Dealers', strType = 'K-1 / K-2 Kerosene', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '470', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '10A' AND strType = 'K-1 / K-2 Kerosene'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '10A' AND strType = 'All Other Products')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '10A', 'Gallons Delivered to Marina Fuel Dealers', 'All Other Products', NULL, 'Invoice', '480', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '10A', strScheduleName = 'Gallons Delivered to Marina Fuel Dealers', strType = 'All Other Products', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '480', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '10A' AND strType = 'All Other Products'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '10B' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '10B', 'Gallons Delivered to Aviation Fuel Dealers', 'Gasoline / Aviation Gasoline / Gasohol', NULL, 'Invoice', '490', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '10B', strScheduleName = 'Gallons Delivered to Aviation Fuel Dealers', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '490', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '10B' AND strType = 'Gasoline / Aviation Gasoline / Gasohol'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '10B' AND strType = 'K-1 / K-2 Kerosene')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '10B', 'Gallons Delivered to Aviation Fuel Dealers', 'K-1 / K-2 Kerosene', NULL, 'Invoice', '500', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '10B', strScheduleName = 'Gallons Delivered to Aviation Fuel Dealers', strType = 'K-1 / K-2 Kerosene', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '500', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '10B' AND strType = 'K-1 / K-2 Kerosene'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '10B' AND strType = 'All Other Products')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '10B', 'Gallons Delivered to Aviation Fuel Dealers', 'All Other Products', NULL, 'Invoice', '510', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '10B', strScheduleName = 'Gallons Delivered to Aviation Fuel Dealers', strType = 'All Other Products', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '510', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '10B' AND strType = 'All Other Products'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode IS NULL AND strType IS NULL)
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', NULL, 'Main Form', NULL, 'Form MF-360', NULL, '650', NULL, NULL, NULL)
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = NULL, strScheduleName = 'Main Form', strType = NULL, strNote = 'Form MF-360', strTransactionType = NULL, intPositionId = '650', strSPInventory = NULL, strSPInvoice = NULL, strSPRunReport = NULL WHERE strFormCode = 'MF-360' AND strScheduleCode IS NULL AND strType IS NULL
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'GT-103' AND strScheduleCode = '1R' AND strType = 'Gasoline')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'GT-103', 'Recap of Gasoline Use Tax by Distributors', '1R', 'Receipt Schedule', 'Gasoline', NULL, 'Inventory', '530', 'uspTFGT103InventoryTax', 'uspTFGT103InvoiceTax', 'uspTFGenerateGT103')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'GT-103', strFormName = 'Recap of Gasoline Use Tax by Distributors', strScheduleCode = '1R', strScheduleName = 'Receipt Schedule', strType = 'Gasoline', strNote = NULL, strTransactionType = 'Inventory', intPositionId = '530', strSPInventory = 'uspTFGT103InventoryTax', strSPInvoice = 'uspTFGT103InvoiceTax', strSPRunReport = 'uspTFGenerateGT103' WHERE strFormCode = 'GT-103' AND strScheduleCode = '1R' AND strType = 'Gasoline'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'GT-103' AND strScheduleCode = '1R' AND strType = 'Gasohol')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'GT-103', 'Recap of Gasoline Use Tax by Distributors', '1R', 'Receipt Schedule', 'Gasohol', NULL, 'Inventory', '540', 'uspTFGT103InventoryTax', 'uspTFGT103InvoiceTax', 'uspTFGenerateGT103')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'GT-103', strFormName = 'Recap of Gasoline Use Tax by Distributors', strScheduleCode = '1R', strScheduleName = 'Receipt Schedule', strType = 'Gasohol', strNote = NULL, strTransactionType = 'Inventory', intPositionId = '540', strSPInventory = 'uspTFGT103InventoryTax', strSPInvoice = 'uspTFGT103InvoiceTax', strSPRunReport = 'uspTFGenerateGT103' WHERE strFormCode = 'GT-103' AND strScheduleCode = '1R' AND strType = 'Gasohol'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'GT-103' AND strScheduleCode = '2D' AND strType = 'Gasoline')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'GT-103', 'Recap of Gasoline Use Tax by Distributors', '2D', 'Disbursement Schedule', 'Gasoline', NULL, 'Invoice', '541', 'uspTFGT103InventoryTax', 'uspTFGT103InvoiceTax', 'uspTFGenerateGT103')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'GT-103', strFormName = 'Recap of Gasoline Use Tax by Distributors', strScheduleCode = '2D', strScheduleName = 'Disbursement Schedule', strType = 'Gasoline', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '541', strSPInventory = 'uspTFGT103InventoryTax', strSPInvoice = 'uspTFGT103InvoiceTax', strSPRunReport = 'uspTFGenerateGT103' WHERE strFormCode = 'GT-103' AND strScheduleCode = '2D' AND strType = 'Gasoline'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'GT-103' AND strScheduleCode = '2D' AND strType = 'Gasohol')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'GT-103', 'Recap of Gasoline Use Tax by Distributors', '2D', 'Disbursement Schedule', 'Gasohol', NULL, 'Invoice', '542', 'uspTFGT103InventoryTax', 'uspTFGT103InvoiceTax', 'uspTFGenerateGT103')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'GT-103', strFormName = 'Recap of Gasoline Use Tax by Distributors', strScheduleCode = '2D', strScheduleName = 'Disbursement Schedule', strType = 'Gasohol', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '542', strSPInventory = 'uspTFGT103InventoryTax', strSPInvoice = 'uspTFGT103InvoiceTax', strSPRunReport = 'uspTFGenerateGT103' WHERE strFormCode = 'GT-103' AND strScheduleCode = '2D' AND strType = 'Gasohol'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'GT-103' AND strScheduleCode IS NULL AND strType IS NULL)
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'GT-103', 'Recap of Gasoline Use Tax by Distributors', NULL, 'Main Form', NULL, 'Form GT-103', NULL, '550', NULL, NULL, NULL)
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'GT-103', strFormName = 'Recap of Gasoline Use Tax by Distributors', strScheduleCode = NULL, strScheduleName = 'Main Form', strType = NULL, strNote = 'Form GT-103', strTransactionType = NULL, intPositionId = '550', strSPInventory = NULL, strSPInvoice = NULL, strSPRunReport = NULL WHERE strFormCode = 'GT-103' AND strScheduleCode IS NULL AND strType IS NULL
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-900' AND strScheduleCode = '1' AND strType IS NULL)
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '1', 'Gallons Received Tax Paid (Special Fuel Returns Only)', NULL, NULL, 'Inventory', '560', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '1', strScheduleName = 'Gallons Received Tax Paid (Special Fuel Returns Only)', strType = NULL, strNote = NULL, strTransactionType = 'Inventory', intPositionId = '560', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900' WHERE strFormCode = 'SF-900' AND strScheduleCode = '1' AND strType IS NULL
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-900' AND strScheduleCode = '2E' AND strType IS NULL)
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '2E', 'Gallons Received for Export (Special Fuel Exporters Only)', NULL, NULL, 'Inventory', '570', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '2E', strScheduleName = 'Gallons Received for Export (Special Fuel Exporters Only)', strType = NULL, strNote = NULL, strTransactionType = 'Inventory', intPositionId = '570', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900' WHERE strFormCode = 'SF-900' AND strScheduleCode = '2E' AND strType IS NULL
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-900' AND strScheduleCode = '2K' AND strType IS NULL)
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '2K', 'Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose', NULL, NULL, 'Inventory', '580', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '2K', strScheduleName = 'Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose', strType = NULL, strNote = NULL, strTransactionType = 'Inventory', intPositionId = '580', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900' WHERE strFormCode = 'SF-900' AND strScheduleCode = '2K' AND strType IS NULL
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-900' AND strScheduleCode = '3' AND strType IS NULL)
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '3', 'Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid', NULL, NULL, 'Inventory', '590', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '3', strScheduleName = 'Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid', strType = NULL, strNote = NULL, strTransactionType = 'Inventory', intPositionId = '590', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900' WHERE strFormCode = 'SF-900' AND strScheduleCode = '3' AND strType IS NULL
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-900' AND strScheduleCode = '5' AND strType IS NULL)
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '5', 'Gallons Delivered, Tax Collected and Gallons Blended or Dyed Fuel Used', NULL, NULL, 'Invoice', '600', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '5', strScheduleName = 'Gallons Delivered, Tax Collected and Gallons Blended or Dyed Fuel Used', strType = NULL, strNote = NULL, strTransactionType = 'Invoice', intPositionId = '600', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900' WHERE strFormCode = 'SF-900' AND strScheduleCode = '5' AND strType IS NULL
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-900' AND strScheduleCode = '6' AND strType IS NULL)
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '6', 'Gallons Delivered Via Rail, Pipeline or Vessel to Licensed Suppliers, Tax not Collected (Special Fuel)', NULL, NULL, 'Invoice', '610', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '6', strScheduleName = 'Gallons Delivered Via Rail, Pipeline or Vessel to Licensed Suppliers, Tax not Collected (Special Fuel)', strType = NULL, strNote = NULL, strTransactionType = 'Invoice', intPositionId = '610', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900' WHERE strFormCode = 'SF-900' AND strScheduleCode = '6' AND strType IS NULL
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-900' AND strScheduleCode = '6X' AND strType IS NULL)
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '6X', 'Gallons Disbursed on exchange', NULL, NULL, 'Invoice', '620', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '6X', strScheduleName = 'Gallons Disbursed on exchange', strType = NULL, strNote = NULL, strTransactionType = 'Invoice', intPositionId = '620', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900' WHERE strFormCode = 'SF-900' AND strScheduleCode = '6X' AND strType IS NULL
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-900' AND strScheduleCode = '7IL' AND strType IS NULL)
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '7IL', 'Gallons Exported to State of IL', NULL, NULL, 'Invoice', '630', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '7IL', strScheduleName = 'Gallons Exported to State of IL', strType = NULL, strNote = NULL, strTransactionType = 'Invoice', intPositionId = '630', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900' WHERE strFormCode = 'SF-900' AND strScheduleCode = '7IL' AND strType IS NULL
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-900' AND strScheduleCode = '7AIL' AND strType IS NULL)
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '7AIL', 'Special Fuel Sold to Unlicensed Exporters for Export to State of IL (IL Tax Collected)', NULL, NULL, 'Invoice', '632', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '7AIL', strScheduleName = 'Special Fuel Sold to Unlicensed Exporters for Export to State of IL (IL Tax Collected)', strType = NULL, strNote = NULL, strTransactionType = 'Invoice', intPositionId = '632', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900' WHERE strFormCode = 'SF-900' AND strScheduleCode = '7AIL' AND strType IS NULL
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-900' AND strScheduleCode = '7BIL' AND strType IS NULL)
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '7BIL', 'Special Fuel Sold to Licensed Exporters for Export to State of IL', NULL, NULL, 'Invoice', '634', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '7BIL', strScheduleName = 'Special Fuel Sold to Licensed Exporters for Export to State of IL', strType = NULL, strNote = NULL, strTransactionType = 'Invoice', intPositionId = '634', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900' WHERE strFormCode = 'SF-900' AND strScheduleCode = '7BIL' AND strType IS NULL
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-900' AND strScheduleCode = '8' AND strType IS NULL)
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '8', 'Gallons of Undyed Special Fuel, Gasoline and Kerosene sold to the US Government Tax Exempt', NULL, NULL, 'Invoice', '660', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '8', strScheduleName = 'Gallons of Undyed Special Fuel, Gasoline and Kerosene sold to the US Government Tax Exempt', strType = NULL, strNote = NULL, strTransactionType = 'Invoice', intPositionId = '660', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900' WHERE strFormCode = 'SF-900' AND strScheduleCode = '8' AND strType IS NULL
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-900' AND strScheduleCode = '10' AND strType IS NULL)
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '10', 'Gallons Sold of Tax Exempt Dyed Fuel', NULL, NULL, 'Invoice', '670', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '10', strScheduleName = 'Gallons Sold of Tax Exempt Dyed Fuel', strType = NULL, strNote = NULL, strTransactionType = 'Invoice', intPositionId = '670', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900' WHERE strFormCode = 'SF-900' AND strScheduleCode = '10' AND strType IS NULL
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-900' AND strScheduleCode = '11' AND strType IS NULL)
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '11', 'Diversion Corrections', NULL, NULL, 'Invoice', '680', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '11', strScheduleName = 'Diversion Corrections', strType = NULL, strNote = NULL, strTransactionType = 'Invoice', intPositionId = '680', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900' WHERE strFormCode = 'SF-900' AND strScheduleCode = '11' AND strType IS NULL
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-900' AND strScheduleCode = '7KY' AND strType IS NULL)
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '7KY', 'Gallons Exported to State of KY', NULL, NULL, 'Invoice', '681', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '7KY', strScheduleName = 'Gallons Exported to State of KY', strType = NULL, strNote = NULL, strTransactionType = 'Invoice', intPositionId = '681', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'SF-900' AND strScheduleCode = '7KY' AND strType IS NULL
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-900' AND strScheduleCode = '7MI' AND strType IS NULL)
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '7MI', 'Gallons Exported to State of MI', NULL, NULL, 'Invoice', '682', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '7MI', strScheduleName = 'Gallons Exported to State of MI', strType = NULL, strNote = NULL, strTransactionType = 'Invoice', intPositionId = '682', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'SF-900' AND strScheduleCode = '7MI' AND strType IS NULL
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-900' AND strScheduleCode = '7OH' AND strType IS NULL)
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '7OH', 'Gallons Exported to State of OH', NULL, NULL, 'Invoice', '683', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '7OH', strScheduleName = 'Gallons Exported to State of OH', strType = NULL, strNote = NULL, strTransactionType = 'Invoice', intPositionId = '683', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'SF-900' AND strScheduleCode = '7OH' AND strType IS NULL
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-900' AND strScheduleCode = '7AKY' AND strType IS NULL)
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '7AKY', 'Special Fuel Sold to Unlicensed Exporters for Export to State of KY (KY Tax Collected)', NULL, NULL, 'Invoice', '684', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '7AKY', strScheduleName = 'Special Fuel Sold to Unlicensed Exporters for Export to State of KY (KY Tax Collected)', strType = NULL, strNote = NULL, strTransactionType = 'Invoice', intPositionId = '684', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'SF-900' AND strScheduleCode = '7AKY' AND strType IS NULL
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-900' AND strScheduleCode = '7AMI' AND strType IS NULL)
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '7AMI', 'Special Fuel Sold to Unlicensed Exporters for Export to State of MI (MI Tax Collected)', NULL, NULL, 'Invoice', '685', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '7AMI', strScheduleName = 'Special Fuel Sold to Unlicensed Exporters for Export to State of MI (MI Tax Collected)', strType = NULL, strNote = NULL, strTransactionType = 'Invoice', intPositionId = '685', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'SF-900' AND strScheduleCode = '7AMI' AND strType IS NULL
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-900' AND strScheduleCode = '7AOH' AND strType IS NULL)
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '7AOH', 'Special Fuel Sold to Unlicensed Exporters for Export to State of OH (OH Tax Collected)', NULL, NULL, 'Invoice', '686', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '7AOH', strScheduleName = 'Special Fuel Sold to Unlicensed Exporters for Export to State of OH (OH Tax Collected)', strType = NULL, strNote = NULL, strTransactionType = 'Invoice', intPositionId = '686', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'SF-900' AND strScheduleCode = '7AOH' AND strType IS NULL
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-900' AND strScheduleCode = '7BKY' AND strType IS NULL)
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '7BKY', 'Special Fuel Sold to Licensed Exporters for Export to State of KY', NULL, NULL, 'Invoice', '687', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '7BKY', strScheduleName = 'Special Fuel Sold to Licensed Exporters for Export to State of KY', strType = NULL, strNote = NULL, strTransactionType = 'Invoice', intPositionId = '687', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'SF-900' AND strScheduleCode = '7BKY' AND strType IS NULL
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-900' AND strScheduleCode = '7BMI' AND strType IS NULL)
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '7BMI', 'Special Fuel Sold to Licensed Exporters for Export to State of MI', NULL, NULL, 'Invoice', '688', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '7BMI', strScheduleName = 'Special Fuel Sold to Licensed Exporters for Export to State of MI', strType = NULL, strNote = NULL, strTransactionType = 'Invoice', intPositionId = '688', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'SF-900' AND strScheduleCode = '7BMI' AND strType IS NULL
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-900' AND strScheduleCode = '7BOH' AND strType IS NULL)
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', '7BOH', 'Special Fuel Sold to Licensed Exporters for Export to State of OH', NULL, NULL, 'Invoice', '689', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '7BOH', strScheduleName = 'Special Fuel Sold to Licensed Exporters for Export to State of OH', strType = NULL, strNote = NULL, strTransactionType = 'Invoice', intPositionId = '689', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'SF-900' AND strScheduleCode = '7BOH' AND strType IS NULL
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-900' AND strScheduleCode IS NULL AND strType IS NULL)
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-900', 'Consolidated Special Fuel Monthly Tax Return', NULL, 'Main Form', NULL, 'Form SF-900', NULL, '690', NULL, NULL, NULL)
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = NULL, strScheduleName = 'Main Form', strType = NULL, strNote = 'Form SF-900', strTransactionType = NULL, intPositionId = '690', strSPInventory = NULL, strSPInvoice = NULL, strSPRunReport = NULL WHERE strFormCode = 'SF-900' AND strScheduleCode IS NULL AND strType IS NULL
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-401' AND strScheduleCode = '1A' AND strType = 'Special Fuel')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-401', 'Transporters Monthly Tax Return', '1A', 'Exports', 'Special Fuel', 'Dyed and Clear Diesel Fuel, Biodiesel and Blended Biodiesel', 'Invoice', '700', 'uspTFGetInventoryTax', 'uspTFSF401InvoiceTax', 'uspTFGenerateSF401')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-401', strFormName = 'Transporters Monthly Tax Return', strScheduleCode = '1A', strScheduleName = 'Exports', strType = 'Special Fuel', strNote = 'Dyed and Clear Diesel Fuel, Biodiesel and Blended Biodiesel', strTransactionType = 'Invoice', intPositionId = '700', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFSF401InvoiceTax', strSPRunReport = 'uspTFGenerateSF401' WHERE strFormCode = 'SF-401' AND strScheduleCode = '1A' AND strType = 'Special Fuel'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-401' AND strScheduleCode = '1A' AND strType = 'Gasoline')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-401', 'Transporters Monthly Tax Return', '1A', 'Exports', 'Gasoline', 'Gasoline, Gasohol', 'Invoice', '710', 'uspTFGetInventoryTax', 'uspTFSF401InvoiceTax', 'uspTFGenerateSF401')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-401', strFormName = 'Transporters Monthly Tax Return', strScheduleCode = '1A', strScheduleName = 'Exports', strType = 'Gasoline', strNote = 'Gasoline, Gasohol', strTransactionType = 'Invoice', intPositionId = '710', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFSF401InvoiceTax', strSPRunReport = 'uspTFGenerateSF401' WHERE strFormCode = 'SF-401' AND strScheduleCode = '1A' AND strType = 'Gasoline'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-401' AND strScheduleCode = '1A' AND strType = 'Other Products')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-401', 'Transporters Monthly Tax Return', '1A', 'Exports', 'Other Products', 'Jet Fuel, Jerosene', 'Invoice', '720', 'uspTFGetInventoryTax', 'uspTFSF401InvoiceTax', 'uspTFGenerateSF401')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-401', strFormName = 'Transporters Monthly Tax Return', strScheduleCode = '1A', strScheduleName = 'Exports', strType = 'Other Products', strNote = 'Jet Fuel, Jerosene', strTransactionType = 'Invoice', intPositionId = '720', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFSF401InvoiceTax', strSPRunReport = 'uspTFGenerateSF401' WHERE strFormCode = 'SF-401' AND strScheduleCode = '1A' AND strType = 'Other Products'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-401' AND strScheduleCode = '2A' AND strType = 'Special Fuel')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-401', 'Transporters Monthly Tax Return', '2A', 'Imports', 'Special Fuel', 'Dyed and Clear Diesel Fuel, Biodiesel and Blended Biodiesel', 'Invoice', '730', 'uspTFGetInventoryTax', 'uspTFSF401InvoiceTax', 'uspTFGenerateSF401')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-401', strFormName = 'Transporters Monthly Tax Return', strScheduleCode = '2A', strScheduleName = 'Imports', strType = 'Special Fuel', strNote = 'Dyed and Clear Diesel Fuel, Biodiesel and Blended Biodiesel', strTransactionType = 'Invoice', intPositionId = '730', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFSF401InvoiceTax', strSPRunReport = 'uspTFGenerateSF401' WHERE strFormCode = 'SF-401' AND strScheduleCode = '2A' AND strType = 'Special Fuel'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-401' AND strScheduleCode = '2A' AND strType = 'Gasoline')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-401', 'Transporters Monthly Tax Return', '2A', 'Imports', 'Gasoline', 'Gasoline, Gasohol', 'Invoice', '750', 'uspTFGetInventoryTax', 'uspTFSF401InvoiceTax', 'uspTFGenerateSF401')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-401', strFormName = 'Transporters Monthly Tax Return', strScheduleCode = '2A', strScheduleName = 'Imports', strType = 'Gasoline', strNote = 'Gasoline, Gasohol', strTransactionType = 'Invoice', intPositionId = '750', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFSF401InvoiceTax', strSPRunReport = 'uspTFGenerateSF401' WHERE strFormCode = 'SF-401' AND strScheduleCode = '2A' AND strType = 'Gasoline'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-401' AND strScheduleCode = '2A' AND strType = 'Other Products')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-401', 'Transporters Monthly Tax Return', '2A', 'Imports', 'Other Products', 'Jet Fuel, Kerosene', 'Invoice', '760', 'uspTFGetInventoryTax', 'uspTFSF401InvoiceTax', 'uspTFGenerateSF401')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-401', strFormName = 'Transporters Monthly Tax Return', strScheduleCode = '2A', strScheduleName = 'Imports', strType = 'Other Products', strNote = 'Jet Fuel, Kerosene', strTransactionType = 'Invoice', intPositionId = '760', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFSF401InvoiceTax', strSPRunReport = 'uspTFGenerateSF401' WHERE strFormCode = 'SF-401' AND strScheduleCode = '2A' AND strType = 'Other Products'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-401' AND strScheduleCode = '3A' AND strType = 'Special Fuel')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-401', 'Transporters Monthly Tax Return', '3A', 'In-State Transfers', 'Special Fuel', 'Dyed and Clear Diesel Fuel, Biodiesel and Blended Biodiesel', 'Invoice', '770', 'uspTFGetInventoryTax', 'uspTFSF401InvoiceTax', 'uspTFGenerateSF401')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-401', strFormName = 'Transporters Monthly Tax Return', strScheduleCode = '3A', strScheduleName = 'In-State Transfers', strType = 'Special Fuel', strNote = 'Dyed and Clear Diesel Fuel, Biodiesel and Blended Biodiesel', strTransactionType = 'Invoice', intPositionId = '770', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFSF401InvoiceTax', strSPRunReport = 'uspTFGenerateSF401' WHERE strFormCode = 'SF-401' AND strScheduleCode = '3A' AND strType = 'Special Fuel'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-401' AND strScheduleCode = '3A' AND strType = 'Gasoline')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-401', 'Transporters Monthly Tax Return', '3A', 'In-State Transfers', 'Gasoline', 'Gasoline, Gasohol', 'Invoice', '780', 'uspTFGetInventoryTax', 'uspTFSF401InvoiceTax', 'uspTFGenerateSF401')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-401', strFormName = 'Transporters Monthly Tax Return', strScheduleCode = '3A', strScheduleName = 'In-State Transfers', strType = 'Gasoline', strNote = 'Gasoline, Gasohol', strTransactionType = 'Invoice', intPositionId = '780', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFSF401InvoiceTax', strSPRunReport = 'uspTFGenerateSF401' WHERE strFormCode = 'SF-401' AND strScheduleCode = '3A' AND strType = 'Gasoline'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-401' AND strScheduleCode = '3A' AND strType = 'Other Products')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-401', 'Transporters Monthly Tax Return', '3A', 'In-State Transfers', 'Other Products', 'Jet Fuel, Kerosene', 'Invoice', '790', 'uspTFGetInventoryTax', 'uspTFSF401InvoiceTax', 'uspTFGenerateSF401')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-401', strFormName = 'Transporters Monthly Tax Return', strScheduleCode = '3A', strScheduleName = 'In-State Transfers', strType = 'Other Products', strNote = 'Jet Fuel, Kerosene', strTransactionType = 'Invoice', intPositionId = '790', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFSF401InvoiceTax', strSPRunReport = 'uspTFGenerateSF401' WHERE strFormCode = 'SF-401' AND strScheduleCode = '3A' AND strType = 'Other Products'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'SF-401' AND strScheduleCode IS NULL AND strType IS NULL)
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'SF-401', 'Transporters Monthly Tax Return', NULL, 'Main Form', NULL, 'Form SF-401', NULL, '795', NULL, NULL, NULL)
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'SF-401', strFormName = 'Transporters Monthly Tax Return', strScheduleCode = NULL, strScheduleName = 'Main Form', strType = NULL, strNote = 'Form SF-401', strTransactionType = NULL, intPositionId = '795', strSPInventory = NULL, strSPInvoice = NULL, strSPRunReport = NULL WHERE strFormCode = 'SF-401' AND strScheduleCode IS NULL AND strType IS NULL
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'EDI' AND strScheduleCode IS NULL AND strType = 'EDI')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'EDI', 'Electronic file', NULL, 'IN EDI file', 'EDI', NULL, NULL, '800', NULL, NULL, NULL)
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'EDI', strFormName = 'Electronic file', strScheduleCode = NULL, strScheduleName = 'IN EDI file', strType = 'EDI', strNote = NULL, strTransactionType = NULL, intPositionId = '800', strSPInventory = NULL, strSPInvoice = NULL, strSPRunReport = NULL WHERE strFormCode = 'EDI' AND strScheduleCode IS NULL AND strType = 'EDI'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '7KY' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '7KY', 'Gallons Exported to State of KY', 'Gasoline / Aviation Gasoline / Gasohol', NULL, 'Invoice', '310', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '7KY', strScheduleName = 'Gallons Exported to State of KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '310', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '7KY' AND strType = 'Gasoline / Aviation Gasoline / Gasohol'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '7KY' AND strType = 'K-1 / K-2 Kerosene')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '7KY', 'Gallons Exported to State of KY', 'K-1 / K-2 Kerosene', NULL, 'Invoice', '320', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '7KY', strScheduleName = 'Gallons Exported to State of KY', strType = 'K-1 / K-2 Kerosene', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '320', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '7KY' AND strType = 'K-1 / K-2 Kerosene'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '7KY' AND strType = 'All Other Products')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '7KY', 'Gallons Exported to State of KY', 'All Other Products', NULL, 'Invoice', '330', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '7KY', strScheduleName = 'Gallons Exported to State of KY', strType = 'All Other Products', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '330', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '7KY' AND strType = 'All Other Products'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '7IL' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '7IL', 'Gallons Exported to State of IL', 'Gasoline / Aviation Gasoline / Gasohol', NULL, 'Invoice', '340', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '7IL', strScheduleName = 'Gallons Exported to State of IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '340', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '7IL' AND strType = 'Gasoline / Aviation Gasoline / Gasohol'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '7IL' AND strType = 'K-1 / K-2 Kerosene')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '7IL', 'Gallons Exported to State of IL', 'K-1 / K-2 Kerosene', NULL, 'Invoice', '350', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '7IL', strScheduleName = 'Gallons Exported to State of IL', strType = 'K-1 / K-2 Kerosene', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '350', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '7IL' AND strType = 'K-1 / K-2 Kerosene'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '7IL' AND strType = 'All Other Products')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '7IL', 'Gallons Exported to State of IL', 'All Other Products', NULL, 'Invoice', '360', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '7IL', strScheduleName = 'Gallons Exported to State of IL', strType = 'All Other Products', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '360', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '7IL' AND strType = 'All Other Products'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '7OH' AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '7OH', 'Gallons Exported to State of OH', 'Gasoline / Aviation Gasoline / Gasohol', NULL, 'Invoice', '365', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '7OH', strScheduleName = 'Gallons Exported to State of OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '365', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '7OH' AND strType = 'Gasoline / Aviation Gasoline / Gasohol'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '7OH' AND strType = 'K-1 / K-2 Kerosene')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '7OH', 'Gallons Exported to State of OH', 'K-1 / K-2 Kerosene', NULL, 'Invoice', '366', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '7OH', strScheduleName = 'Gallons Exported to State of OH', strType = 'K-1 / K-2 Kerosene', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '366', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '7OH' AND strType = 'K-1 / K-2 Kerosene'
			END
			IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFReportingComponent WHERE strFormCode = 'MF-360' AND strScheduleCode = '7OH' AND strType = 'All Other Products')
			BEGIN 
			INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strType],[strNote],[strTransactionType],[intPositionId],[strSPInventory],[strSPInvoice],[strSPRunReport])
			VALUES(@intTaxAuthorityId, 'MF-360', 'Consolidated Gasoline Monthly Tax Return', '7OH', 'Gallons Exported to State of OH', 'All Other Products', NULL, 'Invoice', '367', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateMF360')
			SELECT @MasterPk  = SCOPE_IDENTITY();
				SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
				IF @ReportingComponentId IS NULL
				BEGIN
					INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
					VALUES(@intTaxAuthorityId, @MasterPk,1,2)
				END
			END
			ELSE
			BEGIN 
			UPDATE tblTFReportingComponent SET intTaxAuthorityId = @intTaxAuthorityId, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '7OH', strScheduleName = 'Gallons Exported to State of OH', strType = 'All Other Products', strNote = NULL, strTransactionType = 'Invoice', intPositionId = '367', strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360' WHERE strFormCode = 'MF-360' AND strScheduleCode = '7OH' AND strType = 'All Other Products'
			END

PRINT 'END TF Reporting Component'
