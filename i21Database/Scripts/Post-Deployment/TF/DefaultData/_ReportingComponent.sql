
PRINT 'START TF CLEAR TEST DATA'

TRUNCATE TABLE tblTFScheduleFieldTemplate
TRUNCATE TABLE tblTFScheduleFields
--TRUNCATE TABLE tblTFTaxReportTemplate
TRUNCATE TABLE tblTFTransactions
-- CONFIGS
TRUNCATE TABLE tblTFValidAccountStatusCode
TRUNCATE TABLE tblTFValidLocalTax
TRUNCATE TABLE tblTFValidOriginState
TRUNCATE TABLE tblTFValidDestinationState
TRUNCATE TABLE tblTFValidProductCode
TRUNCATE TABLE tblTFValidVendor
TRUNCATE TABLE tblTFTaxReportSummary
TRUNCATE TABLE tblTFTaxCriteria

TRUNCATE TABLE tblTFOriginDestinationState
TRUNCATE TABLE tblTFFilingPacket


--- DROP CONSTRAINTS TO TRUNCATE tblTFReportingComponentDetail

ALTER TABLE tblTFValidAccountStatusCode
DROP CONSTRAINT FK_tblTFValidAccountStatusCode_tblTFReportingComponent

ALTER TABLE tblTFValidLocalTax
DROP CONSTRAINT FK_tblTFValidLocalTax_tblTFReportingComponent

ALTER TABLE tblTFValidOriginState
DROP CONSTRAINT FK_tblTFValidOriginState_tblTFReportingComponent

ALTER TABLE tblTFValidProductCode
DROP CONSTRAINT FK_tblTFValidProductCode_tblTFReportingComponent

ALTER TABLE tblTFValidVendor
DROP CONSTRAINT FK_tblTFValidVendor_tblTFReportingComponent

ALTER TABLE tblTFValidDestinationState
DROP CONSTRAINT FK_tblTFValidDestinationState_tblTFReportingComponent

ALTER TABLE tblTFTaxCriteria
DROP CONSTRAINT FK_tblTFTaxCriteria_tblTFReportingComponent

ALTER TABLE tblTFFilingPacket
DROP CONSTRAINT FK_tblTFFilingPacket_tblTFReportingComponent

ALTER TABLE tblTFScheduleFields
DROP CONSTRAINT FK_tblTFScheduleFields_tblTFReportingComponent

GO
PRINT 'START MFT CHECK TABLE EXISTENCE - tblTFValidOriginDestinationState'
GO
	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblTFValidOriginDestinationState')
		BEGIN
			IF EXISTS(SELECT 1 FROM sys.foreign_keys WHERE parent_object_id = OBJECT_ID(N'dbo.tblTFValidOriginDestinationState'))
			 BEGIN 
					ALTER TABLE tblTFValidOriginDestinationState
					DROP CONSTRAINT FK_tblTFValidOriginDestinationState_tblTFReportingComponentDetail
			END 
		END
	ELSE
		BEGIN
			PRINT 'TABLE NOT EXIST!'
		END

TRUNCATE TABLE tblTFReportingComponent
--TRUNCATE TABLE tblTFReportingComponentDetail

--ADD FOREIGN KEY BACK
ALTER TABLE tblTFValidAccountStatusCode ADD CONSTRAINT
FK_tblTFValidAccountStatusCode_tblTFReportingComponent FOREIGN KEY
( intReportingComponentId )
REFERENCES tblTFReportingComponent
( intReportingComponentId )

ALTER TABLE tblTFValidLocalTax ADD CONSTRAINT
FK_tblTFValidLocalTax_tblTFReportingComponent FOREIGN KEY
( intReportingComponentId )
REFERENCES tblTFReportingComponent
( intReportingComponentId )

ALTER TABLE tblTFValidOriginState ADD CONSTRAINT
FK_tblTFValidOriginState_tblTFReportingComponent FOREIGN KEY
( intReportingComponentId )
REFERENCES tblTFReportingComponent
( intReportingComponentId )

ALTER TABLE tblTFValidProductCode ADD CONSTRAINT
FK_tblTFValidProductCode_tblTFReportingComponent FOREIGN KEY
( intReportingComponentId )
REFERENCES tblTFReportingComponent
( intReportingComponentId )

ALTER TABLE tblTFValidVendor ADD CONSTRAINT
FK_tblTFValidVendor_tblTFReportingComponent FOREIGN KEY
( intReportingComponentId )
REFERENCES tblTFReportingComponent
( intReportingComponentId )

ALTER TABLE tblTFValidDestinationState ADD CONSTRAINT
FK_tblTFValidDestinationState_tblTFReportingComponent FOREIGN KEY
( intReportingComponentId )
REFERENCES tblTFReportingComponent
( intReportingComponentId )

ALTER TABLE tblTFTaxCriteria ADD CONSTRAINT
FK_tblTFTaxCriteria_tblTFReportingComponent FOREIGN KEY
( intReportingComponentId )
REFERENCES tblTFReportingComponent
( intReportingComponentId )

ALTER TABLE tblTFFilingPacket ADD CONSTRAINT
FK_tblTFFilingPacket_tblTFReportingComponent FOREIGN KEY
( intReportingComponentId )
REFERENCES tblTFReportingComponent
( intReportingComponentId )

ALTER TABLE tblTFScheduleFields ADD CONSTRAINT
FK_tblTFScheduleFields_tblTFReportingComponent FOREIGN KEY
( intReportingComponentId )
REFERENCES tblTFReportingComponent
( intReportingComponentId )


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblTFValidOriginDestinationState')
		BEGIN
			IF EXISTS(SELECT 1 FROM sys.foreign_keys WHERE parent_object_id = OBJECT_ID(N'dbo.tblTFValidOriginDestinationState'))
			 BEGIN
			--IF EXISTS(SELECT 1 FROM sys.foreign_keys WHERE parent_object_id = OBJECT_ID(N'dbo.tblTFValidOriginDestinationState'))
			-- BEGIN 
					 ALTER TABLE tblTFValidOriginDestinationState ADD CONSTRAINT
					FK_tblTFValidOriginDestinationState_tblTFReportingComponentDetail FOREIGN KEY
					( intReportingComponentDetailId )
					REFERENCES tblTFReportingComponentDetail
					( intReportingComponentDetailId )
					PRINT 'SUCCESSFULLY TRUNCATED tblTFReportingComponent'
			--END 
		END
		END
	ELSE
		BEGIN
			PRINT 'TABLE NOT EXIST!'
		END
GO
PRINT 'END MFT CHECK TABLE EXISTENCE - tblTFValidOriginDestinationState'
GO

PRINT 'END TF CLEAR TEST DATA'

PRINT 'START TF Reporting Component'

DECLARE @intTaxAuthorityId INT
DECLARE @MasterPk	INT
DECLARE @ScheduleFieldTemplateMasterPk INT
DECLARE @ReportingComponentId NVARCHAR(10)

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IN'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM [tblTFReportingComponent])
	BEGIN
		
		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'1A'	,'Gallons Received Tax Paid (Gasoline Return Only)','', 10, 'Gasoline / Aviation Gasoline / Gasohol','Inventory','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId], [ysnIncludeSalesFreightOnly], [strIncludeTransactionsWithSET], [intCustomerTax], [intNumberOfCopies])
		VALUES(@MasterPk, 0, '<> 0', 0, 0)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'1A'	,'Gallons Received Tax Paid (Gasoline Return Only)','', 20, 'K-1 / K-2 Kerosene','Inventory','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'1A'	,'Gallons Received Tax Paid (Gasoline Return Only)','', 30, 'All Other Products','Inventory','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'2'	,'Gallons Received from Licensed Distributor or Oil Inspection Distributor, Tax Unpaid (Gasoline Only)','', 40, 'Gasoline / Aviation Gasoline / Gasohol','Inventory','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId], [ysnIncludeSalesFreightOnly], [strIncludeTransactionsWithSET], [intCustomerTax], [intNumberOfCopies])
		VALUES(@MasterPk, 0, '= 0', 0, 0)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'2'	,'Gallons Received from Licensed Distributor or Oil Inspection Distributor, Tax Unpaid (Gasoline Only)','', 50, 'K-1 / K-2 Kerosene','Inventory','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'2'	,'Gallons Received from Licensed Distributor or Oil Inspection Distributor, Tax Unpaid (Gasoline Only)','', 60, 'All Other Products','Inventory','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'2K'	,'Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose','', 70, 'Gasoline / Aviation Gasoline / Gasohol','Inventory','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'2K'	,'Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose','', 80, 'K-1 / K-2 Kerosene','Inventory','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'2K'	,'Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose','', 90, 'All Other Products','Inventory','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'2X','Gallons Received from Distributor on Exchange (Gasoline Only)','', 100, 'Gasoline / Aviation Gasoline / Gasohol','Inventory','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'2X','Gallons Received from Distributor on Exchange (Gasoline Only)','', 110, 'K-1 / K-2 Kerosene','Inventory','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'2X','Gallons Received from Distributor on Exchange (Gasoline Only)','', 120, 'All Other Products','Inventory','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'3','Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid','', 130, 'Gasoline / Aviation Gasoline / Gasohol','Inventory','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId], [ysnIncludeSalesFreightOnly], [strIncludeTransactionsWithSET], [intCustomerTax], [intNumberOfCopies])
		VALUES(@MasterPk, 0, '<> 0', 0, 0)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'3','Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid','', 140, 'K-1 / K-2 Kerosene','Inventory','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'3','Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid','', 150, 'All Other Products','Inventory','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'4','Gallons Imported into Own Storage  (Gasoline Only)','', 160, 'Gasoline / Aviation Gasoline / Gasohol','Inventory','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'4','Gallons Imported into Own Storage  (Gasoline Only)','', 170, 'K-1 / K-2 Kerosene','Inventory','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'4','Gallons Imported into Own Storage  (Gasoline Only)','', 180, 'All Other Products','Inventory','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		--DISBURSEMENT

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'5','Gallons Delivered, Tax Collected','', 190, 'Gasoline / Aviation Gasoline / Gasohol','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId], [ysnIncludeSalesFreightOnly], [strIncludeTransactionsWithSET], [intCustomerTax], [intNumberOfCopies])
		VALUES(@MasterPk, 0, '<> 0', 0, 0)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'5','Gallons Delivered, Tax Collected and Gallons Blended or Dyed Fuel Used','', 200, 'K-1 / K-2 Kerosene','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'5','Gallons Delivered, Tax Collected and Gallons Blended or Dyed Fuel Used','', 210, 'All Other Products','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
	
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'6D','Gallons Sold to Licensed Distributors, Tax Not Collected (Gasoline Only)','', 220, 'Gasoline / Aviation Gasoline / Gasohol','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();

		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'6D','Gallons Sold to Licensed Distributors, Tax Not Collected (Gasoline Only)','', 230, 'K-1 / K-2 Kerosene','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
	
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'6D','Gallons Sold to Licensed Distributors, Tax Not Collected (Gasoline Only)','', 240, 'All Other Products','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();

		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'6X','Gallons Disbursed on exchange','', 250, 'Gasoline / Aviation Gasoline / Gasohol','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
	
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'6X','Gallons Disbursed on exchange','', 260, 'K-1 / K-2 Kerosene','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();

		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'6X','Gallons Disbursed on exchange','', 270, 'All Other Products','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'7MI','Gallons Exported to State of MI','', 280, 'Gasoline / Aviation Gasoline / Gasohol','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
	
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId], [ysnIncludeSalesFreightOnly], [strIncludeTransactionsWithSET], [intCustomerTax], [intNumberOfCopies])
		VALUES(@MasterPk, 0, '<> 0', 0, 0)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'7MI','Gallons Exported to State of MI','', 290, 'K-1 / K-2 Kerosene','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();

		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'7MI','Gallons Exported to State of MI','', 300, 'All Other Products','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();

		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'8','Gallons of Undyed Special Fuel, Gasoline and Kerosene sold to the US Government Tax Exempt','', 370, 'Gasoline / Aviation Gasoline / Gasohol','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId], [ysnIncludeSalesFreightOnly], [strIncludeTransactionsWithSET], [intCustomerTax], [intNumberOfCopies])
		VALUES(@MasterPk, 0, '= 0', 0, 0)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'8','Gallons of Undyed Special Fuel, Gasoline and Kerosene sold to the US Government Tax Exempt','', 380, 'K-1 / K-2 Kerosene','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();

		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'8','Gallons of Undyed Special Fuel, Gasoline and Kerosene sold to the US Government Tax Exempt','', 390, 'All Other Products','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();

		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'10A','Gallons Delivered to Marina Fuel Dealers','', 460, 'Gasoline / Aviation Gasoline / Gasohol','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'10A','Gallons Delivered to Marina Fuel Dealers','', 470, 'K-1 / K-2 Kerosene','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();

		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'10A','Gallons Delivered to Marina Fuel Dealers','', 480, 'All Other Products','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();

		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'10B','Gallons Delivered to Aviation Fuel Dealers','', 490, 'Gasoline / Aviation Gasoline / Gasohol','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
	
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'10B','Gallons Delivered to Aviation Fuel Dealers','', 500, 'K-1 / K-2 Kerosene','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();

		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'10B','Gallons Delivered to Aviation Fuel Dealers','', 510, 'All Other Products','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'','Main Form','Form MF-360', 650, '')
		SELECT @MasterPk  = SCOPE_IDENTITY();
	
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'GT-103',	'Recap of Gasoline Use Tax by Distributors', '1R','Receipt Schedule','', 530, 'Gasoline', 'Inventory','uspTFGT103InventoryTax','uspTFGT103InvoiceTax','uspTFGenerateGT103')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'GT-103',	'Recap of Gasoline Use Tax by Distributors', '1R','Receipt Schedule','', 540,'Gasohol', 'Inventory','uspTFGT103InventoryTax','uspTFGT103InvoiceTax','uspTFGenerateGT103')
		SELECT @MasterPk  = SCOPE_IDENTITY();
	
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'GT-103',	'Recap of Gasoline Use Tax by Distributors', '2D','Disbursement Schedule','', 541,'Gasoline', 'Invoice','uspTFGT103InventoryTax','uspTFGT103InvoiceTax','uspTFGenerateGT103')
		SELECT @MasterPk  = SCOPE_IDENTITY();
	
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'GT-103',	'Recap of Gasoline Use Tax by Distributors', '2D','Disbursement Schedule','', 542,'Gasohol', 'Invoice','uspTFGT103InventoryTax','uspTFGT103InvoiceTax','uspTFGenerateGT103')
		SELECT @MasterPk  = SCOPE_IDENTITY();
	
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		--GT-103 MAIN FORM
		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'GT-103',	'Recap of Gasoline Use Tax by Distributors', '','Main Form','Form GT-103', 550, '')

		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '1','Gallons Received Tax Paid (Special Fuel Returns Only)','', 560, '', 'Inventory','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateSF900')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '2E','Gallons Received for Export (Special Fuel Exporters Only)','', 570, '', 'Inventory','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateSF900')
		SELECT @MasterPk  = SCOPE_IDENTITY();
	
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '2K','Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose','', 580, '', 'Inventory','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateSF900')
		SELECT @MasterPk  = SCOPE_IDENTITY();

		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '3','Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid','', 590, '', 'Inventory','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateSF900')
		SELECT @MasterPk  = SCOPE_IDENTITY();
	
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '5','Gallons Delivered, Tax Collected and Gallons Blended or Dyed Fuel Used','', 600, '', 'Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateSF900')
		SELECT @MasterPk  = SCOPE_IDENTITY();
	
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '6','Gallons Delivered Via Rail, Pipeline or Vessel to Licensed Suppliers, Tax not Collected (Special Fuel)','', 610, '', 'Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateSF900')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '6X','Gallons Disbursed on exchange','', 620, '', 'Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateSF900')
		SELECT @MasterPk  = SCOPE_IDENTITY();
	
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '7','Gallons Exported to State of','', 630, '', 'Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateSF900')
		SELECT @MasterPk  = SCOPE_IDENTITY();
	
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '7A','Gallons Exported to State of','', 632, '', 'Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateSF900')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '7B','Gallons Exported to State of','', 634, '', 'Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateSF900')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '8', 'Gallons of Undyed Special Fuel, Gasoline and Kerosene sold to the US Government Tax Exempt','', 660, '', 'Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateSF900')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '10', 'Gallons Sold of Tax Exempt Dyed Fuel','', 670, '', 'Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateSF900')
		SELECT @MasterPk  = SCOPE_IDENTITY();
	
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '11', 'Diversion Corrections','', 680, '', 'Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateSF900')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '', 'Main Form','Form SF-900', 690, '')
		SELECT @MasterPk  = SCOPE_IDENTITY();
	
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return', '1A', 'Exports','', 700, 'Special Fuel (Dyed and Clear Diesel Fuel, Biodiesel and Blended Biodiesel)', 'Invoice','uspTFGetInventoryTax','uspTFSF401InvoiceTax','uspTFGenerateSF401')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return', '1A', 'Exports','', 710, 'Gasoline (Gasoline, Gasohol)', 'Invoice','uspTFGetInventoryTax','uspTFSF401InvoiceTax','uspTFGenerateSF401')
		SELECT @MasterPk  = SCOPE_IDENTITY();
	
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return', '1A', 'Exports','', 720, 'Other Products (Jet Fuel, Kerosene)', 'Invoice','uspTFGetInventoryTax','uspTFSF401InvoiceTax','uspTFGenerateSF401')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return', '2A', 'Imports','', 730, 'Special Fuel (Dyed and Clear Diesel Fuel, Biodiesel and Blended Biodiesel)', 'Invoice','uspTFGetInventoryTax','uspTFSF401InvoiceTax','uspTFGenerateSF401')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return', '2A', 'Imports','', 750, 'Gasoline (Gasoline, Gasohol)', 'Invoice','uspTFGetInventoryTax','uspTFSF401InvoiceTax','uspTFGenerateSF401')
		SELECT @MasterPk  = SCOPE_IDENTITY();

		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return', '2A', 'Imports','', 760, 'Other Products (Jet Fuel, Kerosene)', 'Invoice','uspTFGetInventoryTax','uspTFSF401InvoiceTax','uspTFGenerateSF401')
		SELECT @MasterPk  = SCOPE_IDENTITY();

		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return', '3A', 'In-State Transfers', '', 770, 'Special Fuel (Dyed and Clear Diesel Fuel, Biodiesel and Blended Biodiesel)', 'Invoice','uspTFGetInventoryTax','uspTFSF401InvoiceTax','uspTFGenerateSF401')
		SELECT @MasterPk  = SCOPE_IDENTITY();
	
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return', '3A' , 'In-State Transfers', '', 780, 'Gasoline (Gasoline, Gasohol)', 'Invoice','uspTFGetInventoryTax','uspTFSF401InvoiceTax','uspTFGenerateSF401')
		SELECT @MasterPk  = SCOPE_IDENTITY();
	
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return', '3A' , 'In-State Transfers', '', 790, 'Other Products (Jet Fuel, Kerosene)', 'Invoice','uspTFGetInventoryTax','uspTFSF401InvoiceTax','uspTFGenerateSF401')
		SELECT @MasterPk  = SCOPE_IDENTITY();
	
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return',	'','Main Form','Form SF-401', 795, '')
		SELECT @MasterPk  = SCOPE_IDENTITY();
	
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType])
		VALUES(@intTaxAuthorityId, 'EDI',	'Electronic file', '', 'IN EDI file', NULL, 800, 'EDI',NULL)
		SELECT @MasterPk  = SCOPE_IDENTITY();
	
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		--========
		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'7KY'	,'Gallons Exported to State of KY','', 310, 'Gasoline / Aviation Gasoline / Gasohol','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'7KY'	,'Gallons Exported to State of KY','', 320, 'K-1 / K-2 Kerosene','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'7KY'	,'Gallons Exported to State of KY','', 330, 'All Other Products','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'7IL'	,'Gallons Exported to State of IL','', 340, 'Gasoline / Aviation Gasoline / Gasohol','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'7IL'	,'Gallons Exported to State of IL','', 350, 'K-1 / K-2 Kerosene','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'7IL'	,'Gallons Exported to State of IL','', 360, 'All Other Products','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END
			
		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'7OH'	,'Gallons Exported to State of OH','', 365, 'Gasoline / Aviation Gasoline / Gasohol','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'7OH'	,'Gallons Exported to State of OH','', 366, 'K-1 / K-2 Kerosene','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'7OH'	,'Gallons Exported to State of OH','', 367, 'All Other Products','Invoice','uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Special Fuel Monthly Tax Return',	'7KY'	,'Gallons Exported to State of KY','', 631, NULL, 'Invoice', 'uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Special Fuel Monthly Tax Return',	'7MI'	,'Gallons Exported to State of MI','', 632, NULL, 'Invoice', 'uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Special Fuel Monthly Tax Return',	'7OH'	,'Gallons Exported to State of OH','', 633, NULL, 'Invoice' ,'uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Special Fuel Monthly Tax Return',	'7AKY'	,'Special Fuel Sold to Unlicensed Exporters for Export to State of KY (KY Tax Collected)','', 635, NULL, 'Invoice' ,'uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Special Fuel Monthly Tax Return',	'7AMI'	,'Special Fuel Sold to Unlicensed Exporters for Export to State of MI (MI Tax Collected)','', 636, NULL, 'Invoice' ,'uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Special Fuel Monthly Tax Return',	'7AOH'	,'Special Fuel Sold to Unlicensed Exporters for Export to State of OH (OH Tax Collected)','', 637, NULL, 'Invoice' ,'uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Special Fuel Monthly Tax Return',	'7BKY'	,'Special Fuel Sold to Licensed Exporters for Export to State of KY','', 639, NULL, 'Invoice' ,'uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Special Fuel Monthly Tax Return',	'7BMI'	,'Special Fuel Sold to Licensed Exporters for Export to State of MI','', 640, NULL, 'Invoice' ,'uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Special Fuel Monthly Tax Return',	'7BOH'	,'Special Fuel Sold to Licensed Exporters for Export to State of OH','', 641, NULL, 'Invoice' ,'uspTFGetInventoryTax','uspTFGetInvoiceTax','uspTFGenerateMF360')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		
		SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = @MasterPk)
		IF @ReportingComponentId IS NULL
			BEGIN
				INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
				VALUES(@intTaxAuthorityId, @MasterPk,1,2)
			END
	END
END

PRINT 'END TF Reporting Component'

PRINT 'START TF Schedule Fields'

INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(1, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(1, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(1, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '2')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(1, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1167')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(1, 'strOriginState', 'Origin State', NULL, 'No', '0', '4')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(1, 'strDestinationState', 'Destination State', NULL, 'No', '0', '5')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(1, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '6')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(1, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '7')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(1, 'dtmDate', 'Date Received', NULL, 'No', '0', '8')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(1, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '9')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(1, 'dblNet', 'Net Gals', NULL, 'No', '0', '10')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(1, 'dblGross', 'Gross Gals', NULL, 'No', '0', '11')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(1, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '12')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(2, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(2, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(2, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(2, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(2, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(2, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(2, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(2, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(2, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(2, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(2, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(2, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(2, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(3, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(3, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(3, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(3, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(3, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(3, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(3, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(3, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(3, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(3, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(3, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(3, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(3, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(4, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(4, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(4, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(4, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(4, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(4, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(4, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(4, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(4, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(4, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(4, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(4, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(4, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(5, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(5, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(5, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(5, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(5, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(5, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(5, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(5, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(5, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(5, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(5, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(5, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(5, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(6, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(6, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(6, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(6, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(6, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(6, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(6, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(6, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(6, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(6, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(6, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(6, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(6, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(7, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(7, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(7, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(7, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(7, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(7, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(7, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(7, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(7, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(7, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(7, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(7, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(7, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(8, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(8, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(8, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(8, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(8, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(8, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(8, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(8, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(8, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(8, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(8, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(8, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(8, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(9, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(9, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(9, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(9, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(9, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(9, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(9, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(9, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(9, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(9, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(9, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(9, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(9, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(10, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(10, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(10, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(10, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(10, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(10, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(10, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(10, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(10, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(10, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(10, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(10, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(10, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(11, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(11, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(11, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(11, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(11, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(11, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(11, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(11, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(11, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(11, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(11, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(11, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(11, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(12, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(12, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(12, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(12, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(12, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(12, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(12, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(12, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(12, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(12, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(12, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(12, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(12, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(13, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(13, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(13, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(13, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(13, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(13, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(13, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(13, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(13, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(13, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(13, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(13, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(13, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(14, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(14, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(14, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(14, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(14, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(14, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(14, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(14, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(14, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(14, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(14, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(14, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(14, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(15, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(15, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(15, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(15, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(15, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(15, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(15, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(15, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(15, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(15, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(15, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(15, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(15, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(16, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(16, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(16, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(16, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(16, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(16, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(16, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(16, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(16, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(16, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(16, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(16, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(16, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(17, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(17, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(17, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(17, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(17, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(17, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(17, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(17, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(17, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(17, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(17, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(17, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(17, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(18, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(18, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(18, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(18, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(18, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(18, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(18, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(18, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(18, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(18, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(18, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(18, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(18, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(46, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(46, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(46, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(46, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(46, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(46, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(46, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(46, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(46, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(46, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(46, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(46, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(46, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(47, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(47, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(47, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(47, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(47, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(47, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(47, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(47, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(47, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(47, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(47, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(47, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(47, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(48, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(48, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(48, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(48, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(48, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(48, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(48, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(48, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(48, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(48, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(48, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(48, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(48, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(49, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(49, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(49, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(49, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(49, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(49, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(49, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(49, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(49, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(49, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(49, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(49, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(49, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(19, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(19, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(19, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(19, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(19, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(19, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(19, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(19, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(19, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(19, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(19, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(19, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(19, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(19, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(20, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(20, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(20, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(20, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(20, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(20, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(20, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(20, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(20, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(20, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(20, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(20, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(20, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(20, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(21, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(21, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(21, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(21, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(21, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(21, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(21, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(21, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(21, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(21, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(21, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(21, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(21, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(21, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(22, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(22, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(22, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(22, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(22, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(22, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(22, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(22, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(22, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(22, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(22, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(22, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(22, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(22, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(23, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(23, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(23, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(23, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(23, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(23, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(23, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(23, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(23, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(23, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(23, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(23, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(23, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(23, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(24, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(24, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(24, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(24, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(24, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(24, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(24, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(24, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(24, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(24, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(24, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(24, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(24, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(24, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(25, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(25, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(25, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(25, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(25, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(25, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(25, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(25, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(25, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(25, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(25, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(25, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(25, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(25, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(26, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(26, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(26, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(26, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(26, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(26, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(26, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(26, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(26, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(26, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(26, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(26, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(26, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(26, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(27, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(27, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(27, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(27, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(27, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(27, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(27, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(27, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(27, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(27, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(27, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(27, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(27, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(27, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(28, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(28, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(28, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(28, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(28, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(28, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(28, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(28, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(28, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(28, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(28, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(28, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(28, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(28, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(29, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(29, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(29, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(29, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(29, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(29, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(29, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(29, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(29, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(29, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(29, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(29, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(29, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(29, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(30, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(30, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(30, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(30, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(30, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(30, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(30, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(30, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(30, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(30, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(30, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(30, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(30, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(30, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(31, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(31, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(31, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(31, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(31, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(31, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(31, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(31, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(31, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(31, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(31, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(31, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(31, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(31, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(32, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(32, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(32, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(32, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(32, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(32, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(32, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(32, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(32, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(32, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(32, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(32, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(32, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(32, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(33, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(33, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(33, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(33, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(33, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(33, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(33, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(33, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(33, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(33, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(33, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(33, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(33, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(33, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(34, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(34, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(34, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(34, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(34, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(34, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(34, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(34, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(34, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(34, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(34, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(34, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(34, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(34, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(37, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(37, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(37, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(37, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(37, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(37, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(37, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(37, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(37, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(37, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(37, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(37, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(37, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(37, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(50, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(50, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(50, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(50, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(50, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(50, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(50, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(50, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(50, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(50, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(50, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(50, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(50, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(50, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(51, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(51, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(51, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(51, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(51, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(51, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(51, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(51, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(51, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(51, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(51, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(51, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(51, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(51, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(52, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(52, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(52, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(52, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(52, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(52, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(52, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(52, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(52, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(52, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(52, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(52, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(52, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(52, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(53, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(53, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(53, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(53, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(53, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(53, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(53, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(53, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(53, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(53, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(53, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(53, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(53, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(53, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(54, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(54, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(54, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(54, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(54, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(54, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(54, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(54, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(54, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(54, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(54, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(54, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(54, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(54, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(55, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(55, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(55, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(55, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(55, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(55, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(55, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(55, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(55, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(55, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(55, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(55, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(55, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(55, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(56, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(56, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(56, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(56, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(56, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(56, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(56, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(56, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(56, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(56, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(56, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(56, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(56, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(56, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(57, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(57, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(57, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(57, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(57, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(57, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(57, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(57, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(57, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(57, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(57, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(57, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(57, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(57, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(71, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(71, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(71, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(71, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(71, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(71, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(71, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(71, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(71, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(71, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(71, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(71, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(71, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(71, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(72, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(72, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(72, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(72, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(72, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(72, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(72, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(72, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(72, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(72, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(72, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(72, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(72, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(72, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(73, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(73, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(73, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(73, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(73, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(73, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(73, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(73, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(73, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(73, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(73, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(73, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(73, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(73, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(74, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(74, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(74, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(74, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(74, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(74, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(74, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(74, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(74, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(74, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(74, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(74, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(74, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(74, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(75, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(75, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(75, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(75, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(75, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(75, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(75, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(75, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(75, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(75, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(75, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(75, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(75, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(75, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(76, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(76, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(76, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(76, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(76, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(76, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(76, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(76, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(76, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(76, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(76, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(76, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(76, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(76, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(77, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(77, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(77, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(77, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(77, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(77, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(77, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(77, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(77, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(77, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(77, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(77, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(77, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(77, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(78, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(78, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(78, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(78, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(78, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(78, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(78, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(78, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(78, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(78, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(78, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(78, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(78, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(78, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(79, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(79, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(79, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(79, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(79, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(79, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(79, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(79, 'strCustomerName', 'Sold To', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(79, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(79, 'dtmDate', 'Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(79, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(79, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(79, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(79, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(80, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(80, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(80, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(80, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(80, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(80, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(80, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(80, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(80, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(80, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(80, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(80, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(80, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(81, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(81, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(81, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(81, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(81, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(81, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(81, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(81, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(81, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(81, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(81, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(81, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(81, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(82, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(82, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(82, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(82, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(82, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(82, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(82, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(82, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(82, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(82, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(82, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(82, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(82, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(83, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(83, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(83, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(83, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(83, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(83, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(83, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(83, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(83, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(83, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(83, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(83, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(83, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(84, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(84, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(84, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(84, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(84, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(84, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(84, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(84, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(84, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(84, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(84, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(84, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(84, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(85, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(85, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(85, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(85, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(85, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(85, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(85, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(85, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(85, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(85, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(85, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(85, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(85, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(86, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(86, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(86, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(86, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(86, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(86, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(86, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(86, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(86, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(86, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(86, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(86, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(86, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(87, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(87, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(87, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(87, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(87, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(87, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(87, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(87, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(87, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(87, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(87, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(87, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(87, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(88, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(88, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(88, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(88, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(88, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(88, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(88, 'strVendorName', 'Vendor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(88, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(88, 'dtmDate', 'Date Received', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(88, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(88, 'dblNet', 'Net Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(88, 'dblGross', 'Gross Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(88, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(60, 'strProductCode', 'Product Code', NULL, 'No', '0', '19495')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(60, 'strConsignorName', 'Consignor Name', NULL, 'No', '0', '19543')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(60, 'strConsignorFederalTaxId', 'Consigner FEIN', NULL, 'No', '0', '19588')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(60, 'strVendorName', 'Seller Name', NULL, 'No', '0', '19633')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(60, 'strVendorFederalTaxId', 'Seller FEIN', NULL, 'No', '0', '19636')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(60, 'strTransportationMode', 'Mode', NULL, 'No', '0', '19651')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(60, 'strOriginState', 'Origin State', NULL, 'No', '0', '19697')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(60, 'strCustomerName', 'Customer Name', NULL, 'No', '0', '19702')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(60, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '19744')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(60, 'strDestinationState', 'Destination State', NULL, 'No', '0', '19789')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(60, 'dtmDate', 'Document Date', NULL, 'No', '0', '19843')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(60, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '19886')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(60, 'dblGross', 'Gross', NULL, 'No', '0', '19889')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(60, 'dblNet', 'Net', NULL, 'No', '0', '19915')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(61, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(61, 'strConsignorName', 'Consignor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(61, 'strConsignorFederalTaxId', 'Consigner FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(61, 'strVendorName', 'Seller Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(61, 'strVendorFederalTaxId', 'Seller FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(61, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(61, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(61, 'strCustomerName', 'Customer Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(61, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(61, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(61, 'dtmDate', 'Document Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(61, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(61, 'dblGross', 'Gross', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(61, 'dblNet', 'Net', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(62, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(62, 'strConsignorName', 'Consignor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(62, 'strConsignorFederalTaxId', 'Consigner FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(62, 'strVendorName', 'Seller Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(62, 'strVendorFederalTaxId', 'Seller FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(62, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(62, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(62, 'strCustomerName', 'Customer Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(62, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(62, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(62, 'dtmDate', 'Document Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(62, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(62, 'dblGross', 'Gross', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(62, 'dblNet', 'Net', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(63, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(63, 'strConsignorName', 'Consignor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(63, 'strConsignorFederalTaxId', 'Consigner FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(63, 'strVendorName', 'Seller Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(63, 'strVendorFederalTaxId', 'Seller FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(63, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(63, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(63, 'strCustomerName', 'Customer Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(63, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(63, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(63, 'dtmDate', 'Document Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(63, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(63, 'dblGross', 'Gross', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(63, 'dblNet', 'Net', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(64, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(64, 'strConsignorName', 'Consignor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(64, 'strConsignorFederalTaxId', 'Consigner FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(64, 'strVendorName', 'Seller Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(64, 'strVendorFederalTaxId', 'Seller FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(64, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(64, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(64, 'strCustomerName', 'Customer Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(64, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(64, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(64, 'dtmDate', 'Document Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(64, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(64, 'dblGross', 'Gross', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(64, 'dblNet', 'Net', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(65, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(65, 'strConsignorName', 'Consignor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(65, 'strConsignorFederalTaxId', 'Consigner FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(65, 'strVendorName', 'Seller Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(65, 'strVendorFederalTaxId', 'Seller FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(65, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(65, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(65, 'strCustomerName', 'Customer Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(65, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(65, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(65, 'dtmDate', 'Document Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(65, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(65, 'dblGross', 'Gross', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(65, 'dblNet', 'Net', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(66, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(66, 'strConsignorName', 'Consignor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(66, 'strConsignorFederalTaxId', 'Consigner FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(66, 'strVendorName', 'Seller Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(66, 'strVendorFederalTaxId', 'Seller FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(66, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(66, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(66, 'strCustomerName', 'Customer Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(66, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(66, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(66, 'dtmDate', 'Document Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(66, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(66, 'dblGross', 'Gross', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(66, 'dblNet', 'Net', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(67, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(67, 'strConsignorName', 'Consignor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(67, 'strConsignorFederalTaxId', 'Consigner FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(67, 'strVendorName', 'Seller Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(67, 'strVendorFederalTaxId', 'Seller FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(67, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(67, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(67, 'strCustomerName', 'Customer Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(67, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(67, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(67, 'dtmDate', 'Document Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(67, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(67, 'dblGross', 'Gross', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(67, 'dblNet', 'Net', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(68, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(68, 'strConsignorName', 'Consignor Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(68, 'strConsignorFederalTaxId', 'Consigner FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(68, 'strVendorName', 'Seller Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(68, 'strVendorFederalTaxId', 'Seller FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(68, 'strTransportationMode', 'Mode', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(68, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(68, 'strCustomerName', 'Customer Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(68, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(68, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(68, 'dtmDate', 'Document Date', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(68, 'strBillOfLading', 'Document Number', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(68, 'dblGross', 'Gross', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(68, 'dblNet', 'Net', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(41, 'strProductCode', 'Product Code', NULL, 'No', '0', '20642')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(41, 'strVendorName', 'Supplier Name', NULL, 'No', '0', '20648')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(41, 'strOriginState', 'Origin State', NULL, 'No', '0', '20652')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(41, 'strDestinationState', 'Destination State', NULL, 'No', '0', '20658')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(41, 'strVendorFederalTaxId', 'Supplier FEIN', NULL, 'No', '0', '20701')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(41, 'strVendorLicenseNumber', 'Indiana TID', NULL, 'No', '0', '20746')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(41, 'dblGross', 'Total Gals Purchased', NULL, 'No', '0', '20794')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(41, 'dblTax', 'GUT Paid to Supplier', NULL, 'No', '0', '20814')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(42, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(42, 'strVendorName', 'Supplier Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(42, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(42, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(42, 'strVendorFederalTaxId', 'Supplier FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(42, 'strVendorLicenseNumber', 'Indiana TID', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(42, 'dblGross', 'Total Gals Purchased', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(42, 'dblTax', 'GUT Paid to Supplier', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(43, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(43, 'strVendorName', 'Supplier Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(43, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(43, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(43, 'strVendorFederalTaxId', 'Supplier FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(43, 'strVendorLicenseNumber', 'Indiana TID', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(43, 'dblGross', 'Total Gals Purchased', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(43, 'dblTax', 'GUT Paid to Supplier', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(44, 'strProductCode', 'Product Code', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(44, 'strVendorName', 'Supplier Name', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(44, 'strOriginState', 'Origin State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(44, 'strDestinationState', 'Destination State', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(44, 'strVendorFederalTaxId', 'Supplier FEIN', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(44, 'strVendorLicenseNumber', 'Indiana TID', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(44, 'dblGross', 'Total Gals Purchased', NULL, 'No', '0', '1')
INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId])VALUES(44, 'dblTax', 'GUT Paid to Supplier', NULL, 'No', '0', '1')

PRINT 'END TF Schedule Fields'

GO
PRINT 'START TF tblTFTaxCriteria'
GO
DECLARE @intTaxAuthorityId INT
		SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IN'
		IF (@intTaxAuthorityId IS NOT NULL)
			BEGIN
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 1 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 1, 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 2 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 2, 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 3 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 3, 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 4 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 4, 'IN', 'IN Excise Tax Gasoline', '= 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 5 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 5, 'IN', 'IN Excise Tax Gasoline', '= 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 6 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 6, 'IN', 'IN Excise Tax Gasoline', '= 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 7 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 7, 'IN', 'IN Excise Tax Gasoline', '= 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 8 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 8, 'IN', 'IN Excise Tax Gasoline', '= 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 9 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 9, 'IN', 'IN Excise Tax Gasoline', '= 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 13 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 13, 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 14 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 14, 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 15 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 15, 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 19 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 19, 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 20 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 20, 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 21 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 21, 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 22 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 22, 'IN', 'IN Excise Tax Gasoline', '= 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 23 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 23, 'IN', 'IN Excise Tax Gasoline', '= 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 24 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 24, 'IN', 'IN Excise Tax Gasoline', '= 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 54 AND strTaxCategory = 'IL Excise Tax Diesel Clear') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(6, 54, 'IL', 'IL Excise Tax Diesel Clear', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 83 AND strTaxCategory = 'KY Excise Tax Diesel Clear') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(16, 83, 'KY', 'KY Excise Tax Diesel Clear', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 84 AND strTaxCategory = 'MI Excise Tax Diesel Clear') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(10, 84, 'MI', 'MI Excise Tax Diesel Clear', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 85 AND strTaxCategory = 'KY Excise Tax Diesel Clear') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(16, 85, 'KY', 'KY Excise Tax Diesel Clear', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 46 AND strTaxCategory = 'IN Excise Tax Diesel Clear') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(2, 46, 'IN', 'IN Excise Tax Diesel Clear', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 49 AND strTaxCategory = 'IN Excise Tax Diesel Clear') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(2, 49, 'IN', 'IN Excise Tax Diesel Clear', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 50 AND strTaxCategory = 'IN Excise Tax Diesel Clear') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(2, 50, 'IN', 'IN Excise Tax Diesel Clear', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 51 AND strTaxCategory = 'IN Excise Tax Diesel Clear') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(2, 51, 'IN', 'IN Excise Tax Diesel Clear', '= 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 56 AND strTaxCategory = 'IN Excise Tax Diesel Clear') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(2, 56, 'IN', 'IN Excise Tax Diesel Clear', '= 0')
				END
			END

GO
PRINT 'END TF tblTFTaxCriteria'
GO

GO
PRINT 'START TF Tax Criteria Deployment Note'
GO
DECLARE @tblTempSource TABLE (intReportingComponentId INT, strTaxCategory NVARCHAR(50)  COLLATE Latin1_General_CI_AS)
--IN
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (1, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (2, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (3, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (4, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (5, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (6, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (7, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (8, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (9, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (10, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (11, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (12, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (13, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (14, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (15, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (16, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (17, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (18, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (19, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (20, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (21, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (22, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (23, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (24, 'IN Excise Tax Gasoline')
--IL
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (54, 'IL Excise Tax Diesel Clear')
--KY
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (83, 'KY Excise Tax Diesel Clear')
--MI
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (84, 'MI Excise Tax Diesel Clear')
--KY
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (85, 'KY Excise Tax Diesel Clear')
--IN
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (46, 'IN Excise Tax Diesel Clear')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (49, 'IN Excise Tax Diesel Clear')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (50, 'IN Excise Tax Diesel Clear')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (51, 'IN Excise Tax Diesel Clear')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (56, 'IN Excise Tax Diesel Clear')

INSERT INTO tblTFDeploymentNote ([strMessage],[strSourceTable],[intRecordId],[strKeyId],[intTaxAuthorityId],[strReleaseNumber],[dtmDateReleaseInstalled])
SELECT 'An obsolete record is detected in Customer database', 'tblTFTaxCriteria', intTaxCriteriaId, 'RC, ' + CONVERT(NVARCHAR(10), intReportingComponentId) + ', ' + strTaxCategory + ' ' + strCriteria, NULL, '', GETDATE() 
FROM tblTFTaxCriteria A WHERE NOT EXISTS (SELECT strTaxCategory FROM @tblTempSource B WHERE A.intReportingComponentId = B.intReportingComponentId AND A.strTaxCategory = B.strTaxCategory)
GO
PRINT 'END TF Tax Criteria Deployment Note'
GO

GO
PRINT 'START TF tblTFValidOriginState'
GO

DECLARE @tblTempSource TABLE (intReportingComponentId INT)

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 10) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(4, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('4')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 15) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(5, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('5')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 16) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(6, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('6')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 10) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(10, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('10')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 15) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(15, '14', 'IN', 'Exclude') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('15')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 16) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(16, '14', 'IN', 'Exclude') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('16')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 18) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(18, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('18')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 19) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(19, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('19')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 23) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(23, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('23')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 25) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(25, '14', 'IN', 'Exclude') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('25')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 26) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(26, '14', 'IN', 'Exclude') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('26')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 27) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(27, '14', 'IN', 'Exclude') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('27')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 28) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(28, '14', 'IN', 'Exclude') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('28')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 29) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(29, '14', 'IN', 'Exclude') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('29')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 30) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(30, '14', 'IN', 'Exclude') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('30')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 31) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(31, '14', 'IN', 'Exclude') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('31')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 32) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(32, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('32')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 33) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(33, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('33')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 34) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(34, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('34')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 35) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(35, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('35')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 36) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(36, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('36')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 37) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(37, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('37')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 38) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(38, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('38')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 39) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(39, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('39')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 40) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(40, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('40')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 41) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(41, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('41')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 42) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(42, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('42')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 43) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(43, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('43')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 44) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(44, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('44')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 45) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(45, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('45')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 46) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(46, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('46')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 47) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(47, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('47')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 48) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(48, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('48')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 49) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(49, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('49')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 50) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(50, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('50')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 51) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(51, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('51')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 52) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(52, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('52')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 53) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(53, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('53')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 54) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(54, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('54')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 55) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(55, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('55')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 56) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(56, '14', 'IN', 'Exclude') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('56')

INSERT INTO tblTFDeploymentNote ([strMessage],[strSourceTable],[intRecordId],[strKeyId],[intTaxAuthorityId],[strReleaseNumber],[dtmDateReleaseInstalled])
SELECT 'An obsolete record is detected in Customer database', 'tblTFValidOriginState', intValidOriginStateId, intReportingComponentId, NULL, '', GETDATE() 
FROM tblTFValidOriginState A WHERE NOT EXISTS (SELECT intReportingComponentId FROM @tblTempSource B WHERE A.intReportingComponentId = B.intReportingComponentId)

GO
PRINT 'END TF tblTFValidOriginState'
GO

GO
PRINT 'START TF tblTFValidDestinationState'
GO
DECLARE @tblTempSource TABLE (intReportingComponentId INT)

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 61) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(61, '14', 'IN', 'Exclude') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('61')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 62) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(62, '14', 'IN', 'Exclude') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('62')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 60) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(60, '14', 'IN', 'Exclude') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('60')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 63) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(63, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('63')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 64) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(64, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('64')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 65) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(65, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('65')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 67) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(67, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('67')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 68) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(68, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('68')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 66) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(66, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('66')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 13) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(13, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('13')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 14) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(14, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('14')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 15) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(15, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('15')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 16) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(16, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('16')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 17) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(17, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('17')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 18) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(18, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('18')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 28) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(28, '22', 'MI', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('28')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 29) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(29, '22', 'MI', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('29')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 30) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(30, '22', 'MI', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('30')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 71) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(71, '17', 'KY', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('71')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 72) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(72, '17', 'KY', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('72')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 73) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(73, '17', 'KY', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('73')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 74) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(74, '13', 'IL', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('74')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 75) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(75, '13', 'IL', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('75')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 76) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(76, '13', 'IL', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('76')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 77) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(77, '35', 'OH', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('77')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 78) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(78, '35', 'OH', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('78')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 79) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(79, '35', 'OH', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('79')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 53) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(53, '13', 'IL', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('53')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 80) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(80, '17', 'KY', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('80')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 81) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(81, '22', 'MI', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('81')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 82) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(82, '35', 'OH', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('82')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 54) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(54, '13', 'IL', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('54')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 83) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(83, '17', 'KY', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('83')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 84) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(84, '22', 'MI', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('84')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 85) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(85, '35', 'OH', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('85')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 55) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(55, '13', 'IL', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('55')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 86) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(86, '17', 'KY', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('86')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 87) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(87, '22', 'MI', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('87')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 88) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(88, '35', 'OH', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('88')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 49) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(49, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('49')

INSERT INTO tblTFDeploymentNote ([strMessage],[strSourceTable],[intRecordId],[strKeyId],[intTaxAuthorityId],[strReleaseNumber],[dtmDateReleaseInstalled])
SELECT 'An obsolete record is detected in Customer database', 'tblTFValidDestinationState', intValidDestinationStateId, intReportingComponentId, NULL, '', GETDATE() 
FROM tblTFValidDestinationState A WHERE NOT EXISTS (SELECT intReportingComponentId FROM @tblTempSource B WHERE A.intReportingComponentId = B.intReportingComponentId)

GO
PRINT 'END TF tblTFValidDestinationState'
GO


GO
PRINT 'START TF tblTFValidProductCode'
GO

DECLARE @tblTempSource TABLE (intReportingComponentId INT, strProductCode NVARCHAR(5) COLLATE Latin1_General_CI_AS)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, '282', 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, '283', 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, '284', 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, '285', 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, '286', '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, '287', '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, '288', '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, '289', '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, '290', '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, '291', '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, '292', '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, '294', '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, '295', '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, '296', '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, '297', '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, '298', '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, '309', '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, '282', 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, '283', 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, '284', 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, '285', 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, '286', '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, '287', '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, '288', '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, '289', '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, '290', '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, '291', '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, '292', '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, '294', '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, '295', '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, '296', '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, '297', '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, '298', '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, '309', '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, '282', 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, '283', 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, '284', 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, '285', 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, '286', '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, '287', '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, '288', '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, '289', '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, '290', '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, '291', '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, '292', '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, '294', '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, '295', '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, '296', '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, '297', '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, '298', '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, '309', '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 61 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(61, '314', 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('61', 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 61 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(61, '315', 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('61', 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 61 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(61, '263', 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('61', 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 61 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(61, '264', 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('61', 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 61 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(61, '265', '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('61', '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 61 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(61, '301', '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('61', '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 61 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(61, '308', '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('61', '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '266', '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '267', '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '268', '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '269', '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '270', '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '271', '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '272', '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '273', '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '274', '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '275', '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '276', '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '277', '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '278', '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '279', '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '280', '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '281', '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '293', '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '300', '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '302', '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '303', '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '304', '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '305', '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '307', '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '306', '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '100')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '310', '100') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '100')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '311', '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '092')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '312', '092') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '092')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, '313', '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 64 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(64, '314', 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('64', 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 64 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(64, '315', 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('64', 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 64 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(64, '263', 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('64', 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 64 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(64, '264', 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('64', 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 64 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(64, '265', '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('64', '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 64 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(64, '301', '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('64', '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 64 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(64, '308', '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('64', '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 67 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(67, '314', 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('67', 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 67 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(67, '315', 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('67', 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 67 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(67, '263', 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('67', 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 67 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(67, '264', 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('67', 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 67 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(67, '265', '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('67', '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 67 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(67, '301', '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('67', '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 67 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(67, '308', '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('67', '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '266', '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '267', '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '268', '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '269', '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '270', '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '271', '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '272', '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '273', '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '274', '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '275', '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '276', '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '277', '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '278', '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '279', '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '280', '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '281', '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '293', '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '300', '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '302', '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '303', '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '304', '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '305', '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '307', '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '306', '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '100')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '310', '100') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '100')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '311', '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '092')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '312', '092') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '092')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, '313', '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '266', '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '267', '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '268', '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '269', '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '270', '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '271', '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '272', '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '273', '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '274', '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '275', '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '276', '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '277', '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '278', '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '279', '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '280', '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '281', '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '293', '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '300', '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '302', '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '303', '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '304', '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '305', '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '307', '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '306', '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '100')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '310', '100') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '100')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '311', '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '092')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '312', '092') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '092')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, '313', '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 1 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(1, '314', 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('1', 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 1 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(1, '315', 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('1', 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 1 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(1, '263', 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('1', 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 1 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(1, '264', 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('1', 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 1 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(1, '265', '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('1', '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 1 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(1, '301', '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('1', '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 1 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(1, '308', '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('1', '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 4 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(4, '314', 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('4', 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 4 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(4, '315', 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('4', 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 4 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(4, '263', 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('4', 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 4 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(4, '264', 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('4', 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 4 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(4, '265', '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('4', '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 4 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(4, '301', '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('4', '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 4 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(4, '308', '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('4', '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 7 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(7, '314', 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('7', 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 7 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(7, '315', 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('7', 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 7 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(7, '263', 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('7', 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 7 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(7, '264', 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('7', 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 7 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(7, '265', '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('7', '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 7 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(7, '301', '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('7', '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 7 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(7, '308', '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('7', '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 10 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(10, '314', 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('10', 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 10 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(10, '315', 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('10', 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 10 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(10, '263', 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('10', 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 10 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(10, '264', 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('10', 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 10 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(10, '265', '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('10', '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 10 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(10, '301', '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('10', '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 10 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(10, '308', '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('10', '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 13 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(13, '314', 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('13', 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 13 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(13, '315', 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('13', 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 13 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(13, '263', 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('13', 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 13 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(13, '264', 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('13', 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 13 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(13, '265', '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('13', '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 13 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(13, '301', '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('13', '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 13 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(13, '308', '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('13', '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 16 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(16, '314', 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('16', 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 16 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(16, '315', 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('16', 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 16 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(16, '263', 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('16', 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 16 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(16, '264', 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('16', 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 16 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(16, '265', '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('16', '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 16 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(16, '301', '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('16', '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 16 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(16, '308', '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('16', '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 19 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(19, '314', 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('19', 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 19 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(19, '315', 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('19', 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 19 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(19, '263', 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('19', 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 19 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(19, '264', 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('19', 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 19 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(19, '265', '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('19', '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 19 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(19, '301', '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('19', '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 19 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(19, '308', '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('19', '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 22 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(22, '314', 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('22', 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 22 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(22, '315', 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('22', 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 22 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(22, '263', 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('22', 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 22 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(22, '264', 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('22', 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 22 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(22, '265', '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('22', '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 22 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(22, '301', '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('22', '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 22 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(22, '308', '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('22', '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 25 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(25, '314', 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('25', 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 25 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(25, '315', 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('25', 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 25 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(25, '263', 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('25', 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 25 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(25, '264', 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('25', 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 25 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(25, '265', '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('25', '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 25 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(25, '301', '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('25', '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 25 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(25, '308', '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('25', '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 28 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(28, '314', 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('28', 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 28 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(28, '315', 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('28', 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 28 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(28, '263', 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('28', 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 28 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(28, '264', 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('28', 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 28 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(28, '265', '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('28', '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 28 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(28, '301', '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('28', '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 28 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(28, '308', '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('28', '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 31 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(31, '314', 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('31', 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 31 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(31, '315', 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('31', 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 31 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(31, '263', 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('31', 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 31 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(31, '264', 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('31', 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 31 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(31, '265', '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('31', '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 31 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(31, '301', '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('31', '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 31 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(31, '308', '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('31', '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 34 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(34, '314', 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('34', 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 34 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(34, '315', 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('34', 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 34 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(34, '263', 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('34', 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 34 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(34, '264', 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('34', 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 34 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(34, '265', '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('34', '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 34 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(34, '301', '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('34', '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 34 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(34, '308', '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('34', '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 37 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(37, '314', 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('37', 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 37 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(37, '315', 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('37', 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 37 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(37, '263', 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('37', 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 37 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(37, '264', 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('37', 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 37 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(37, '265', '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('37', '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 37 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(37, '301', '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('37', '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 37 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(37, '308', '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('37', '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 2 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(2, '302', '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('2', '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 2 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(2, '304', '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('2', '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 2 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(2, '306', '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('2', '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 2 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(2, '307', '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('2', '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 5 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(5, '302', '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('5', '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 5 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(5, '304', '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('5', '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 5 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(5, '306', '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('5', '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 5 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(5, '307', '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('5', '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 8 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(8, '302', '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('8', '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 8 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(8, '304', '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('8', '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 8 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(8, '306', '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('8', '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 8 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(8, '307', '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('8', '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 11 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(11, '302', '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('11', '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 11 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(11, '304', '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('11', '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 11 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(11, '306', '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('11', '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 11 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(11, '307', '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('11', '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 14 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(14, '302', '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('14', '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 14 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(14, '304', '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('14', '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 14 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(14, '306', '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('14', '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 14 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(14, '307', '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('14', '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 17 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(17, '302', '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('17', '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 17 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(17, '304', '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('17', '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 17 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(17, '306', '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('17', '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 17 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(17, '307', '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('17', '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 20 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(20, '302', '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('20', '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 20 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(20, '304', '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('20', '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 20 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(20, '306', '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('20', '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 20 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(20, '307', '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('20', '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 23 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(23, '302', '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('23', '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 23 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(23, '304', '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('23', '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 23 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(23, '306', '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('23', '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 23 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(23, '307', '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('23', '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 26 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(26, '302', '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('26', '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 26 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(26, '304', '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('26', '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 26 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(26, '306', '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('26', '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 26 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(26, '307', '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('26', '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 29 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(29, '302', '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('29', '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 29 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(29, '304', '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('29', '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 29 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(29, '306', '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('29', '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 29 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(29, '307', '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('29', '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 32 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(32, '302', '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('32', '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 32 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(32, '304', '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('32', '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 32 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(32, '306', '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('32', '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 32 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(32, '307', '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('32', '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, '266', '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, '267', '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, '268', '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, '269', '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, '270', '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, '271', '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, '272', '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, '273', '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, '274', '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, '275', '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, '276', '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, '277', '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, '278', '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, '279', '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, '280', '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, '281', '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, '288', '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, '293', '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, '295', '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, '299', '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, '300', '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, '266', '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, '267', '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, '268', '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, '269', '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, '270', '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, '271', '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, '272', '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, '273', '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, '274', '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, '275', '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, '276', '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, '277', '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, '278', '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, '279', '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, '280', '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, '281', '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, '288', '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, '293', '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, '295', '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, '299', '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, '300', '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, '266', '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, '267', '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, '268', '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, '269', '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, '270', '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, '271', '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, '272', '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, '273', '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, '274', '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, '275', '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, '276', '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, '277', '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, '278', '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, '279', '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, '280', '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, '281', '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, '288', '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, '293', '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, '295', '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, '299', '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, '300', '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, '266', '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, '267', '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, '268', '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, '269', '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, '270', '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, '271', '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, '272', '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, '273', '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, '274', '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, '275', '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, '276', '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, '277', '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, '278', '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, '279', '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, '280', '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, '281', '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, '288', '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, '293', '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, '295', '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, '299', '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, '300', '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, '266', '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, '267', '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, '268', '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, '269', '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, '270', '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, '271', '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, '272', '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, '273', '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, '274', '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, '275', '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, '276', '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, '277', '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, '278', '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, '279', '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, '280', '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, '281', '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, '288', '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, '293', '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, '295', '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, '299', '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, '300', '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, '266', '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, '267', '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, '268', '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, '269', '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, '270', '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, '271', '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, '272', '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, '273', '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, '274', '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, '275', '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, '276', '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, '277', '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, '278', '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, '279', '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, '280', '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, '281', '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, '288', '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, '293', '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, '295', '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, '299', '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, '300', '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, '266', '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, '267', '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, '268', '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, '269', '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, '270', '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, '271', '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, '272', '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, '273', '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, '274', '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, '275', '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, '276', '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, '277', '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, '278', '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, '279', '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, '280', '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, '281', '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, '288', '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, '293', '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, '295', '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, '299', '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, '300', '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, '266', '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, '267', '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, '268', '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, '269', '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, '270', '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, '271', '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, '272', '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, '273', '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, '274', '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, '275', '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, '276', '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, '277', '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, '278', '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, '279', '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, '280', '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, '281', '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, '288', '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, '293', '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, '295', '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, '299', '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, '300', '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, '266', '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, '267', '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, '268', '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, '269', '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, '270', '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, '271', '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, '272', '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, '273', '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, '274', '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, '275', '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, '276', '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, '277', '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, '278', '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, '279', '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, '280', '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, '281', '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, '288', '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, '293', '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, '295', '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, '299', '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, '300', '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, '266', '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, '267', '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, '268', '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, '269', '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, '270', '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, '271', '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, '272', '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, '273', '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, '274', '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, '275', '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, '276', '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, '277', '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, '278', '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, '279', '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, '280', '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, '281', '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, '288', '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, '293', '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, '295', '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, '299', '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, '300', '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, '266', '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, '267', '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, '268', '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, '269', '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, '270', '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, '271', '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, '272', '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, '273', '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, '274', '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, '275', '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, '276', '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, '277', '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, '278', '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, '279', '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, '280', '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, '281', '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, '288', '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, '293', '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, '295', '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, '299', '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, '300', '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 71 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(71, '314', 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('71', 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 71 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(71, '315', 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('71', 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 71 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(71, '263', 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('71', 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 71 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(71, '264', 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('71', 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 71 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(71, '265', '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('71', '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 71 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(71, '301', '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('71', '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 71 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(71, '308', '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('71', '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 74 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(74, '314', 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('74', 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 74 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(74, '315', 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('74', 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 74 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(74, '263', 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('74', 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 74 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(74, '264', 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('74', 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 74 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(74, '265', '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('74', '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 74 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(74, '301', '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('74', '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 74 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(74, '308', '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('74', '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 77 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(77, '314', 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('77', 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 77 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(77, '315', 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('77', 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 77 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(77, '263', 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('77', 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 77 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(77, '264', 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('77', 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 77 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(77, '265', '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('77', '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 77 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(77, '301', '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('77', '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 77 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(77, '308', '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('77', '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 72 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(72, '302', '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('72', '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 72 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(72, '304', '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('72', '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 72 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(72, '306', '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('72', '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 72 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(72, '307', '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('72', '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 75 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(75, '302', '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('75', '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 75 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(75, '304', '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('75', '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 75 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(75, '306', '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('75', '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 75 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(75, '307', '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('75', '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 78 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(78, '302', '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('78', '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 78 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(78, '304', '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('78', '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 78 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(78, '306', '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('78', '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 78 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(78, '307', '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('78', '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, '266', '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, '267', '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, '268', '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, '269', '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, '270', '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, '271', '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, '272', '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, '273', '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, '274', '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, '275', '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, '276', '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, '277', '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, '278', '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, '279', '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, '280', '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, '281', '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, '288', '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, '293', '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, '295', '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, '299', '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, '300', '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, '266', '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, '267', '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, '268', '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, '269', '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, '270', '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, '271', '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, '272', '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, '273', '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, '274', '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, '275', '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, '276', '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, '277', '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, '278', '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, '279', '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, '280', '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, '281', '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, '288', '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, '293', '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, '295', '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, '299', '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, '300', '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, '266', '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, '267', '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, '268', '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, '269', '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, '270', '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, '271', '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, '272', '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, '273', '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, '274', '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, '275', '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, '276', '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, '277', '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, '278', '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, '279', '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, '280', '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, '281', '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, '288', '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, '293', '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, '295', '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, '299', '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, '300', '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, '282', 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, '283', 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, '284', 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, '285', 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, '286', '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, '287', '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, '289', '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, '290', '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, '291', '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, '292', '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, '294', '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, '296', '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, '297', '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, '298', '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, '303', '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, '305', '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, '309', '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, '311', '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, '313', '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, '282', 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, '283', 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, '284', 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, '285', 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, '286', '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, '287', '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, '289', '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, '290', '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, '291', '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, '292', '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, '294', '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, '296', '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, '297', '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, '298', '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, '303', '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, '305', '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, '309', '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, '311', '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, '313', '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, '282', 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, '283', 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, '284', 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, '285', 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, '286', '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, '287', '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, '289', '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, '290', '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, '291', '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, '292', '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, '294', '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, '296', '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, '297', '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, '298', '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, '303', '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, '305', '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, '309', '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, '311', '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, '313', '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, '282', 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, '283', 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, '284', 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, '285', 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, '286', '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, '287', '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, '289', '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, '290', '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, '291', '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, '292', '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, '294', '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, '296', '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, '297', '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, '298', '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, '303', '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, '305', '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, '309', '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, '311', '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, '313', '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, '282', 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, '283', 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, '284', 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, '285', 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, '286', '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, '287', '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, '289', '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, '290', '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, '291', '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, '292', '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, '294', '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, '296', '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, '297', '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, '298', '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, '303', '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, '305', '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, '309', '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, '311', '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, '313', '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, '282', 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, '283', 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, '284', 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, '285', 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, '286', '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, '287', '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, '289', '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, '290', '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, '291', '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, '292', '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, '294', '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, '296', '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, '297', '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, '298', '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, '303', '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, '305', '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, '309', '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, '311', '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, '313', '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, '282', 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, '283', 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, '284', 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, '285', 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, '286', '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, '287', '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, '289', '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, '290', '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, '291', '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, '292', '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, '294', '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, '296', '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, '297', '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, '298', '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, '303', '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, '305', '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, '309', '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, '311', '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, '313', '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, '282', 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, '283', 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, '284', 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, '285', 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, '286', '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, '287', '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, '289', '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, '290', '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, '291', '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, '292', '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, '294', '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, '296', '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, '297', '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, '298', '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, '303', '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, '305', '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, '309', '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, '311', '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, '313', '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, '282', 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, '283', 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, '284', 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, '285', 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, '286', '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, '287', '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, '289', '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, '290', '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, '291', '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, '292', '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, '294', '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, '296', '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, '297', '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, '298', '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, '303', '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, '305', '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, '309', '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, '311', '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, '313', '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, '282', 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, '283', 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, '284', 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, '285', 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, '286', '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, '287', '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, '289', '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, '290', '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, '291', '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, '292', '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, '294', '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, '296', '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, '297', '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, '298', '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, '303', '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, '305', '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, '309', '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, '311', '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, '313', '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 56 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(56, '282', 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('56', 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 56 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(56, '283', 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('56', 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 56 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(56, '291', '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('56', '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 56 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(56, '292', '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('56', '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 56 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(56, '294', '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('56', '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 56 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(56, '296', '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('56', '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 56 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(56, '303', '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('56', '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 56 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(56, '305', '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('56', '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 56 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(56, '309', '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('56', '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 56 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(56, '311', '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('56', '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 56 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(56, '313', '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('56', '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 57 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(57, '284', 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('57', 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 57 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(57, '285', 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('57', 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 57 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(57, '286', '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('57', '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 57 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(57, '287', '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('57', '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 57 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(57, '289', '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('57', '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 57 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(57, '290', '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('57', '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 57 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(57, '313', '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('57', '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, '282', 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, '283', 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, '284', 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, '285', 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, '286', '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, '287', '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, '289', '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, '290', '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, '291', '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, '292', '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, '294', '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, '296', '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, '297', '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, '298', '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, '303', '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, '305', '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, '309', '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, '311', '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, '313', '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, '282', 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, '283', 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, '284', 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, '285', 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, '286', '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, '287', '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, '289', '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, '290', '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, '291', '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, '292', '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, '294', '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, '296', '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, '297', '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, '298', '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, '303', '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, '305', '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, '309', '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, '311', '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, '313', '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, '282', 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, '283', 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, '284', 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, '285', 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, '286', '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, '287', '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, '289', '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, '290', '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, '291', '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, '292', '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, '294', '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, '296', '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, '297', '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, '298', '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, '303', '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, '305', '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, '309', '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, '311', '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, '313', '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, '282', 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, '283', 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, '284', 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, '285', 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, '286', '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, '287', '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, '289', '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, '290', '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, '291', '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, '292', '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, '294', '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, '296', '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, '297', '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, '298', '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, '303', '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, '305', '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, '309', '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, '311', '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, '313', '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, '282', 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, '283', 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, '284', 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, '285', 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, '286', '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, '287', '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, '289', '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, '290', '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, '291', '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, '292', '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, '294', '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, '296', '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, '297', '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, '298', '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, '303', '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, '305', '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, '309', '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, '311', '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, '313', '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, '282', 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, '283', 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, '284', 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, '285', 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, '286', '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, '287', '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, '289', '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, '290', '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, '291', '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, '292', '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, '294', '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, '296', '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, '297', '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, '298', '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, '303', '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, '305', '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, '309', '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, '311', '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, '313', '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, '282', 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, '283', 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, '284', 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, '285', 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, '286', '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, '287', '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, '289', '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, '290', '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, '291', '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, '292', '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, '294', '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, '296', '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, '297', '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, '298', '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, '303', '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, '305', '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, '309', '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, '311', '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, '313', '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, '282', 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, '283', 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, '284', 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, '285', 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, '286', '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, '287', '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, '289', '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, '290', '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, '291', '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, '292', '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, '294', '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, '296', '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, '297', '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, '298', '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, '303', '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, '305', '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, '309', '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, '311', '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, '313', '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, '282', 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, '283', 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, '284', 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, '285', 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, '286', '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, '287', '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, '289', '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, '290', '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, '291', '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, '292', '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, '294', '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, '296', '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, '297', '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, '298', '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, '303', '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, '305', '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, '309', '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, '311', '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, '313', '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, '282', 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, '283', 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, '284', 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, '285', 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, '286', '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, '287', '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, '289', '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, '290', '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, '291', '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, '292', '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, '294', '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, '296', '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, '297', '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, '298', '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, '303', '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, '305', '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, '309', '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, '311', '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, '313', '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 41 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(41, '308', '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('41', '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 41 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(41, '301', '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('41', '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 42 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(42, '314', 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('42', 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 42 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(42, '315', 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('42', 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 42 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(42, '263', 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('42', 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 42 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(42, '264', 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('42', 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 43 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(43, '308', '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('43', '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 43 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(43, '301', '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('43', '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 44 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(44, '314', 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('44', 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 44 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(44, '315', 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('44', 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 44 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(44, '263', 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('44', 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 44 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(44, '264', 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('44', 'M11')

INSERT INTO tblTFDeploymentNote ([strMessage],[strSourceTable],[intRecordId],[strKeyId],[intTaxAuthorityId],[strReleaseNumber],[dtmDateReleaseInstalled])
SELECT 'An obsolete record is detected in Customer database', 'tblTFValidProductCode', intValidProductCodeId, strProductCode, NULL, '', GETDATE() 
FROM tblTFValidProductCode A WHERE NOT EXISTS (SELECT intReportingComponentId, strProductCode FROM @tblTempSource B WHERE A.strProductCode = B.strProductCode AND A.intReportingComponentId = B.intReportingComponentId)

GO
PRINT 'END TF tblTFValidProductCode'
GO