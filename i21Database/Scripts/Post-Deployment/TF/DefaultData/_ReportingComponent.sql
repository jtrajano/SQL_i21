
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

PRINT 'START TF Reporting Component - IN'

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'strTransportationMode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		
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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'','Main Form','Form MF-360', 520, '')
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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Supplier Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Supplier FID', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Indiana FID', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)


		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Total Gallons Purchased', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Supplier Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Supplier FID', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Indiana FID', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)


		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Total Gallons Purchased', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'Customer FID', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Indiana FID', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)


		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblQtyShipped', N'Total Gallons Sold', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblTaxExempt', N'Exempt Gallons Sold', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblTax', N'Gasoline Used Tax Collected', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'Customer FID', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Indiana FID', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)


		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblQtyShipped', N'Total Gallons Sold', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblTaxExempt', N'Exempt Gallons Sold', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblTax', N'Gasoline Used Tax Collected', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)


		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)


		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)


		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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


		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strConsignorName', N'Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strConsignorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Supplier Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Supplier FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'State of Origin', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'Customer FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Document Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gallons', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Billed or Net Gallons', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'', N'Import Verification Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strConsignorName', N'Consignor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strConsignorFederalTaxId', N'Consignor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Supplier Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Supplier FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'State of Origin', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'Customer FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Document Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gallons', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Billed or Net Gallons', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'', N'Import Verification Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--END

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

			SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strConsignorName', N'Consignor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strConsignorFederalTaxId', N'Consignor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Supplier Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Supplier FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'State of Origin', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'Customer FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Document Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gallons', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Billed or Net Gallons', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'', N'Import Verification Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strConsignorName', N'Consignor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strConsignorFederalTaxId', N'Consignor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Supplier Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Supplier FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'State of Origin', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'Customer FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Document Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gallons', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Billed or Net Gallons', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'', N'Import Verification Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strConsignorName', N'Consignor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strConsignorFederalTaxId', N'Consignor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Supplier Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Supplier FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'State of Origin', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'Customer FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Document Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gallons', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Billed or Net Gallons', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'', N'Import Verification Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strConsignorName', N'Consignor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strConsignorFederalTaxId', N'Consignor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Supplier Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Supplier FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'State of Origin', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'Customer FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Document Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gallons', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Billed or Net Gallons', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'', N'Import Verification Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strConsignorName', N'Consignor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strConsignorFederalTaxId', N'Consignor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Supplier Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Supplier FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'State of Origin', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'Customer FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Document Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gallons', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Billed or Net Gallons', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'', N'Import Verification Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strConsignorName', N'Consignor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strConsignorFederalTaxId', N'Consignor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Supplier Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Supplier FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'State of Origin', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'Customer FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Document Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gallons', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Billed or Net Gallons', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'', N'Import Verification Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--END

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

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strConsignorName', N'Consignor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strConsignorFederalTaxId', N'Consignor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Supplier Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Supplier FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'State of Origin', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'Customer FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Document Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gallons', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Billed or Net Gallons', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'', N'Import Verification Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--END

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
	END
END

PRINT 'END TF Reporting Component - IN'