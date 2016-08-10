
PRINT 'START TF CLEAR TEST DATA'

TRUNCATE TABLE tblTFScheduleFieldTemplate
TRUNCATE TABLE tblTFScheduleFields
TRUNCATE TABLE tblTFTaxReportTemplate
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

-- DROP CONSTRAINTS TO TRUNCATE tblTFReportingComponent
ALTER TABLE tblTFFilingPacket
DROP CONSTRAINT FK_tblTFFilingPacket_tblTFReportingComponent

TRUNCATE TABLE tblTFFilingPacket
TRUNCATE TABLE tblTFReportingComponent

--ADD FOREIGN KEY BACK
ALTER TABLE tblTFFilingPacket ADD CONSTRAINT
FK_tblTFFilingPacket_tblTFReportingComponent FOREIGN KEY
( intReportingComponentId )
REFERENCES tblTFReportingComponent
( intReportingComponentId )

--- DROP CONSTRAINTS TO TRUNCATE tblTFReportingComponentDetail

ALTER TABLE tblTFValidAccountStatusCode
DROP CONSTRAINT FK_tblTFValidAccountStatusCode_tblTFReportingComponentDetail

ALTER TABLE tblTFValidLocalTax
DROP CONSTRAINT FK_tblTFValidLocalTax_tblTFReportingComponentDetail

ALTER TABLE tblTFValidOriginState
DROP CONSTRAINT FK_tblTFValidOriginState_tblTFReportingComponentDetail

ALTER TABLE tblTFValidProductCode
DROP CONSTRAINT FK_tblTFValidProductCode_tblTFReportingComponentDetail

ALTER TABLE tblTFValidVendor
DROP CONSTRAINT FK_tblTFValidVendor_tblTFReportingComponentDetail

ALTER TABLE tblTFValidDestinationState
DROP CONSTRAINT FK_tblTFValidDestinationState_tblTFReportingComponentDetail

ALTER TABLE tblTFTaxCriteria
DROP CONSTRAINT FK_tblTFTaxCriteria_tblTFReportingComponentDetail

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


TRUNCATE TABLE tblTFReportingComponentDetail

--ADD FOREIGN KEY BACK
ALTER TABLE tblTFValidAccountStatusCode ADD CONSTRAINT
FK_tblTFValidAccountStatusCode_tblTFReportingComponentDetail FOREIGN KEY
( intReportingComponentDetailId )
REFERENCES tblTFReportingComponentDetail
( intReportingComponentDetailId )

ALTER TABLE tblTFValidLocalTax ADD CONSTRAINT
FK_tblTFValidLocalTax_tblTFReportingComponentDetail FOREIGN KEY
( intReportingComponentDetailId )
REFERENCES tblTFReportingComponentDetail
( intReportingComponentDetailId )

ALTER TABLE tblTFValidOriginState ADD CONSTRAINT
FK_tblTFValidOriginState_tblTFReportingComponentDetail FOREIGN KEY
( intReportingComponentDetailId )
REFERENCES tblTFReportingComponentDetail
( intReportingComponentDetailId )

ALTER TABLE tblTFValidProductCode ADD CONSTRAINT
FK_tblTFValidProductCode_tblTFReportingComponentDetail FOREIGN KEY
( intReportingComponentDetailId )
REFERENCES tblTFReportingComponentDetail
( intReportingComponentDetailId )

ALTER TABLE tblTFValidVendor ADD CONSTRAINT
FK_tblTFValidVendor_tblTFReportingComponentDetail FOREIGN KEY
( intReportingComponentDetailId )
REFERENCES tblTFReportingComponentDetail
( intReportingComponentDetailId )

ALTER TABLE tblTFValidDestinationState ADD CONSTRAINT
FK_tblTFValidDestinationState_tblTFReportingComponentDetail FOREIGN KEY
( intReportingComponentDetailId )
REFERENCES tblTFReportingComponentDetail
( intReportingComponentDetailId )

ALTER TABLE tblTFTaxCriteria ADD CONSTRAINT
FK_tblTFTaxCriteria_tblTFReportingComponentDetail FOREIGN KEY
( intReportingComponentDetailId )
REFERENCES tblTFReportingComponentDetail
( intReportingComponentDetailId )

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
					PRINT 'SUCCESSFULLY TRUNCATED tblTFReportingComponentDetail'
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

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IN'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM [tblTFReportingComponent])
	BEGIN
		
		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'1A'	,'Gallons Received Tax Paid (Gasoline Return Only)','', 10, 'Gasoline / Aviation Gasoline / Gasohol','Inventory', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId], [ysnIncludeSalesFreightOnly], [strIncludeTransactionsWithSET], [intCustomerTax], [intNumberOfCopies])
		VALUES(@MasterPk, 0, '<> 0', 0, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'1A'	,'Gallons Received Tax Paid (Gasoline Return Only)','', 20, 'K-1 / K-2 Kerosene','Inventory', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'1A'	,'Gallons Received Tax Paid (Gasoline Return Only)','', 30, 'All Other Products','Inventory', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'2'	,'Gallons Received from Licensed Distributor or Oil Inspection Distributor, Tax Unpaid (Gasoline Only)','', 40, 'Gasoline / Aviation Gasoline / Gasohol','Inventory', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId], [ysnIncludeSalesFreightOnly], [strIncludeTransactionsWithSET], [intCustomerTax], [intNumberOfCopies])
		VALUES(@MasterPk, 0, '= 0', 0, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'2'	,'Gallons Received from Licensed Distributor or Oil Inspection Distributor, Tax Unpaid (Gasoline Only)','', 50, 'K-1 / K-2 Kerosene','Inventory', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'2'	,'Gallons Received from Licensed Distributor or Oil Inspection Distributor, Tax Unpaid (Gasoline Only)','', 60, 'All Other Products','Inventory', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'2K'	,'Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose','', 70, 'Gasoline / Aviation Gasoline / Gasohol','Inventory', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'2K'	,'Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose','', 80, 'K-1 / K-2 Kerosene','Inventory', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'2K'	,'Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose','', 90, 'All Other Products','Inventory', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'2X','Gallons Received from Distributor on Exchange (Gasoline Only)','', 100, 'Gasoline / Aviation Gasoline / Gasohol','Inventory', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'2X','Gallons Received from Distributor on Exchange (Gasoline Only)','', 110, 'K-1 / K-2 Kerosene','Inventory', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'2X','Gallons Received from Distributor on Exchange (Gasoline Only)','', 120, 'All Other Products','Inventory', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)


		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'3','Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid','', 130, 'Gasoline / Aviation Gasoline / Gasohol','Inventory', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId], [ysnIncludeSalesFreightOnly], [strIncludeTransactionsWithSET], [intCustomerTax], [intNumberOfCopies])
		VALUES(@MasterPk, 0, '<> 0', 0, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'3','Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid','', 140, 'K-1 / K-2 Kerosene','Inventory', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'3','Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid','', 150, 'All Other Products','Inventory', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'4','Gallons Imported into Own Storage  (Gasoline Only)','', 160, 'Gasoline / Aviation Gasoline / Gasohol','Inventory', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'4','Gallons Imported into Own Storage  (Gasoline Only)','', 170, 'K-1 / K-2 Kerosene','Inventory', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'4','Gallons Imported into Own Storage  (Gasoline Only)','', 180, 'All Other Products','Inventory', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		--DISBURSEMENT

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'5','Gallons Delivered, Tax Collected','', 190, 'Gasoline / Aviation Gasoline / Gasohol','Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId], [ysnIncludeSalesFreightOnly], [strIncludeTransactionsWithSET], [intCustomerTax], [intNumberOfCopies])
		VALUES(@MasterPk, 0, '<> 0', 0, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'5','Gallons Delivered, Tax Collected and Gallons Blended or Dyed Fuel Used','', 200, 'K-1 / K-2 Kerosene','Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'5','Gallons Delivered, Tax Collected and Gallons Blended or Dyed Fuel Used','', 210, 'All Other Products','Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'6D','Gallons Sold to Licensed Distributors, Tax Not Collected (Gasoline Only)','', 220, 'Gasoline / Aviation Gasoline / Gasohol','Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'6D','Gallons Sold to Licensed Distributors, Tax Not Collected (Gasoline Only)','', 230, 'K-1 / K-2 Kerosene','Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'6D','Gallons Sold to Licensed Distributors, Tax Not Collected (Gasoline Only)','', 240, 'All Other Products','Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'6X','Gallons Disbursed on exchange','', 250, 'Gasoline / Aviation Gasoline / Gasohol','Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'6X','Gallons Disbursed on exchange','', 260, 'K-1 / K-2 Kerosene','Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'6X','Gallons Disbursed on exchange','', 270, 'All Other Products','Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'7MI','Gallons Exported to State of MI','', 280, 'Gasoline / Aviation Gasoline / Gasohol','Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId], [ysnIncludeSalesFreightOnly], [strIncludeTransactionsWithSET], [intCustomerTax], [intNumberOfCopies])
		VALUES(@MasterPk, 0, '<> 0', 0, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'7MI','Gallons Exported to State of MI','', 290, 'K-1 / K-2 Kerosene','Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'7MI','Gallons Exported to State of MI','', 300, 'All Other Products','Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		
		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'8','Gallons of Undyed Special Fuel, Gasoline and Kerosene sold to the US Government Tax Exempt','', 370, 'Gasoline / Aviation Gasoline / Gasohol','Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId], [ysnIncludeSalesFreightOnly], [strIncludeTransactionsWithSET], [intCustomerTax], [intNumberOfCopies])
		VALUES(@MasterPk, 0, '= 0', 0, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'8','Gallons of Undyed Special Fuel, Gasoline and Kerosene sold to the US Government Tax Exempt','', 380, 'K-1 / K-2 Kerosene','Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'8','Gallons of Undyed Special Fuel, Gasoline and Kerosene sold to the US Government Tax Exempt','', 390, 'All Other Products','Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'10A','Gallons Delivered to Marina Fuel Dealers','', 460, 'Gasoline / Aviation Gasoline / Gasohol','Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'10A','Gallons Delivered to Marina Fuel Dealers','', 470, 'K-1 / K-2 Kerosene','Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'10A','Gallons Delivered to Marina Fuel Dealers','', 480, 'All Other Products','Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'10B','Gallons Delivered to Aviation Fuel Dealers','', 490, 'Gasoline / Aviation Gasoline / Gasohol','Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'10B','Gallons Delivered to Aviation Fuel Dealers','', 500, 'K-1 / K-2 Kerosene','Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'10B','Gallons Delivered to Aviation Fuel Dealers','', 510, 'All Other Products','Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterName', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransporterFederalTaxId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Sold To', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'','Main Form','Form MF-360', 520, '','Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'GT-103',	'Recap of Gasoline Use Tax by Distributors', '1R','Receipt Schedule','', 530, 'Gasoline', 'Inventory', 'uspTFGT103InventoryTax', 'uspTFGT103InvoiceTax', 'uspTFGT103RunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Supplier Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Supplier FID', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Indiana FID', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)


		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Total Gallons Purchased', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'GT-103',	'Recap of Gasoline Use Tax by Distributors', '1R','Receipt Schedule','', 540,'Gasohol', 'Inventory', 'uspTFGT103InventoryTax', 'uspTFGT103InvoiceTax', 'uspTFGT103RunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Supplier Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Supplier FID', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Indiana FID', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)


		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Total Gallons Purchased', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'GT-103',	'Recap of Gasoline Use Tax by Distributors', '2D','Disbursement Schedule','', 541,'Gasoline', 'Invoice', 'uspTFGT103InventoryTax', 'uspTFGT103InvoiceTax', 'uspTFGT103RunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'Customer FID', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Indiana FID', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)


		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblQtyShipped', N'Total Gallons Sold', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblTaxExempt', N'Exempt Gallons Sold', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblTax', N'Gasoline Used Tax Collected', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'GT-103',	'Recap of Gasoline Use Tax by Distributors', '2D','Disbursement Schedule','', 542,'Gasohol', 'Invoice', 'uspTFGT103InventoryTax', 'uspTFGT103InvoiceTax', 'uspTFGT103RunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'Customer FID', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Indiana FID', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)


		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblQtyShipped', N'Total Gallons Sold', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblTaxExempt', N'Exempt Gallons Sold', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblTax', N'Gasoline Used Tax Collected', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		--GT-103 MAIN FORM
		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'GT-103',	'Recap of Gasoline Use Tax by Distributors', '','Main Form','Form GT-103', 550, '', 'uspTFGT103InventoryTax', 'uspTFGT103InvoiceTax', 'uspTFGT103RunTax')

		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '1','Gallons Received Tax Paid (Special Fuel Returns Only)','', 560, '', 'Inventory','uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '2E','Gallons Received for Export (Special Fuel Exporters Only)','', 570, '', 'Inventory', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)


		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '2K','Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose','', 580, '', 'Inventory', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '3','Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid','', 590, '', 'Inventory', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)


		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '5','Gallons Delivered, Tax Collected and Gallons Blended or Dyed Fuel Used','', 600, '', 'Inventory', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)


		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '6','Gallons Delivered Via Rail, Pipeline or Vessel to Licensed Suppliers, Tax not Collected (Special Fuel)','', 610, '', 'Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '6X','Gallons Disbursed on exchange','', 620, '', 'Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '7','Gallons Exported to State of','', 630, '', 'Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '7A','Gallons Exported to State of','', 632, '', 'Invoice','uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '7B','Gallons Exported to State of','', 634, '', 'Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '8', 'Gallons of Undyed Special Fuel, Gasoline and Kerosene sold to the US Government Tax Exempt','', 660, '', 'Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '10', 'Gallons Sold of Tax Exempt Dyed Fuel','', 670, '', 'Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)


		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '11', 'Diversion Corrections','', 680, '', 'Invoice', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '', 'Main Form','Form SF-900', 690, '', 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFGenerateSF900')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return', '1A', 'Exports','Dyed and Clear Diesel Fuel, Biodiesel and Blended Biodiesel', 700, 'Special Fuel')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return', '1A', 'Exports','Gasoline, Gasohol', 710, 'Gasoline')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return', '1A', 'Exports','Jet Fuel, Kerosene', 720, 'Other Products')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return', '2A', 'Imports','Jet Fuel, Kerosene', 730, 'Special Fuel')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return', '2A', 'Imports','Jet Fuel, Kerosene', 740, 'Special Fuel')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return', '2A', 'Imports','Gasoline, Gasohol', 750, 'Gasoline')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return', '2A', 'Imports','Jet Fuel, Kerosene', 760, 'Other Products')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return', '3A', 'In-State Transfers', 'Dyed and Clear Diesel Fuel, Biodiesel and Blended', 770, 'Special Fuel')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return', '3A' , 'In-State Transfers', 'Gasoline, Gasohol', 780, 'Gasoline')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return', '3A' , 'In-State Transfers', 'Jet Fuel, Kerosene', 790, 'Other Products')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType],[strTransactionType],[strSPInventory],[strSPInvoice],[strSPRunReport])
		VALUES(@intTaxAuthorityId, 'EDI',	'Electronic file', '', 'IN EDI file', NULL, 800, 'EDI',NULL, 'uspTFGetInventoryTax', 'uspTFGetInvoiceTax', 'uspTFRunTax')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		--END

		--REPORT GENERATION TEMPLATE
		DECLARE @intReportingComponentId INT
		SELECT @intReportingComponentId = intReportingComponentId FROM tblTFReportingComponent WHERE strScheduleName = 'Main Form' AND strFormCode = 'MF-360'
		IF (@intReportingComponentId IS NOT NULL)
			BEGIN
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'1', 0, 0, N'Filing Type', N'', NULL, NULL, NULL, N'Filing Type', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-001', N'MF-360', 14, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 1, 1, N'1. Total receipts (From Section A, Line 8, Column D on back of return)', N'1A,2,2K,2X,3,4', NULL, N'details', N'sum', N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-002', N'MF-360', 14, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 2, 2, N'2. Total non-taxable disbursements (From Section B, Line 10, Column D on back of return)', N'5,11,6D,6X,7,8,10A,10B', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-003', N'MF-360', 14, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 3, 3, N'3. Gallons received, gasoline tax paid (From Section A, Line 1, Column A on back of return)', N'1A', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-004', N'MF-360', 14, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 4, 4, N'4.  Billed taxable gallons (Line 1 minus Line 2 minus Line 3)', N'1,2,3', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (40, N'MF-360-Summary-005', N'MF-360', 14, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 5, 5, N'5. Licensed gasoline distributor deduction (Multiply Line 4 by 1.034)', N'4', N'1.034', N'', N'', N'Summary', 10, 6)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-006', N'MF-360', 14, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 6, 6, N'6. Billed taxable gallons (Line 4 minus Line 5)', N'4,5', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (40, N'MF-360-Summary-007', N'MF-360', 14, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 7, 7, N'7. Gasoline tax due (Multiply Line 6 by $16)', N'6', N'16', N'', N'', N'Summary', 20, 7)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (40, N'MF-360-Summary-008', N'MF-360', 14, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 8, 8, N'8. Adjustments (Schedule E-1 must be attached and is subject to Department approval)', N'0', N'3333', N'', N'', N'Summary', 25, 1)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-009', N'MF-360', 14, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 9, 9, N'9. Total gasoline tax due (Line 7 plus or minus Line 8)', N'7,8', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-010', N'MF-360', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 1, 10, N'1. Total receipts (From Section A, Line 9, Coumn D on back of return)', N'1A,2,2K,2X,3,4', NULL, N'', N'', N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-011', N'MF-360', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 2, 11, N'2. Total non-taxable disbursements (From Section B, Line 11, Column D on back of return)', N'11,6D,6X,7,8', NULL, N'', N'', N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-012', N'MF-360', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 3, 12, N'3. Gallons received, oil inspection fee paid (From Section A, Line 1, Column D on back of return)', N'1A', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-013', N'MF-360', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 4, 13, N'4. Billed taxable gallons (Line 1 minus Line 2 minus Line 3)', N'10,11,12', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (40, N'MF-360-Summary-014', N'MF-360', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 5, 14, N'5. Oil inspection fees due (Multiply Line 4 by $0.14)', N'13', N'0.14', N'', N'', N'Summary', 30, 5)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (40, N'MF-360-Summary-015', N'MF-360', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 6, 15, N'6. Adjustments (Schedule E-1 must be attached and is subject to Department approval)', N'15', N'123', NULL, NULL, N'Summary', 32, 2)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-016', N'MF-360', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 7, 16, N'7. Total oil inspection fees due (Line 5 plus or minus Line 6)', N'14,15', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-017', N'MF-360', 14, N'IN', N'Section 4:    Calculation of Total Amount Due', 1, 17, N'1. Total amount due (Section 2, Line 9 plus Section 3, Line 7)', N'9,16', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (40, N'MF-360-Summary-018', N'MF-360', 14, N'IN', N'Section 4:    Calculation of Total Amount Due', 2, 18, N'2. Penalty (Penalty must be added if report is filed after the due date. 10% of tax due or $5.00, whichever is greater. Five dollars ($5.00) is due on a late report showing no tax due.)', N'18', N'321', NULL, NULL, N'Summary', 33, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (40, N'MF-360-Summary-019', N'MF-360', 14, N'IN', N'Section 4:    Calculation of Total Amount Due', 3, 19, N'3. Interest (Interest must be added if report is filed after the due date. Contact the Department for daily interest rates.)', N'19', N'11', NULL, NULL, N'Summary', 34, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-020', N'MF-360', 14, N'IN', N'Section 4:    Calculation of Total Amount Due', 4, 20, N'4. Net tax due (Line 1 plus Line 2 plus Line 3)', N'17,18,19', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (40, N'MF-360-Summary-021', N'MF-360', 14, N'IN', N'Section 4:    Calculation of Total Amount Due', 5, 21, N'5. Payment(s)', N'0', N'44', NULL, NULL, N'Summary', 35, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-022', N'MF-360', 14, N'IN', N'Section 4:    Calculation of Total Amount Due', 6, 22, N'6. Balance due (Line 4 minus Line 5)', N'20,21', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (40, N'MF-360-Summary-023', N'MF-360', 14, N'IN', N'Section 4:    Calculation of Total Amount Due', 7, 23, N'7. Gallons of gasoline sold to taxable marina', N'0', N'55', NULL, NULL, N'Summary', 36, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section A: Receipts', 1, 1, N'1. Gallons received, gasoline tax or inspection fee paid', N'1A', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section A: Receipts', 2, 2, N'2. Gallons received from licensed distributors or oil inspection distributors, tax unpaid', N'2', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section A: Receipts', 3, 3, N'3. Gallons of non-taxable fuel received and sold or used for a taxable purpose', N'2K', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section A: Receipts', 4, 4, N'4. Gallons received from licensed distributors on exchange agreements, tax unpaid', N'2X', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section A: Receipts', 5, 5, N'5. Gallons imported directly to customer', N'3', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section A: Receipts', 6, 6, N'6. Gallons imported into own storage', N'4', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section A: Receipts', 7, 7, N'7. Diversions into Indiana', N'11', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section A: Receipts', 8, 8, N'8. Total receipts - add Lines 1-7, carry total (Column D) to Section 2, Line 1 on front', N'1A,2,2K,2X,3,4', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section A: Receipts', 9, 9, N'9. Total Receipts - add Lines 1-7, carry total (Column D) to Section 3, Line 1 on front', N'1A,2,2K,2X,3,4', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section B: Disbursement', 1, 10, N'1. Gallons delivered, tax collected', N'5', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section B: Disbursement', 2, 11, N'2. Diversion out of Indiana', N'11', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section B: Disbursement', 3, 12, N'3. Gallons sold to licensed distributors, tax not collected', N'6D', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section B: Disbursement', 4, 13, N'4. Gallons disbursed on exchange', N'6X', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section B: Disbursement', 5, 14, N'5. Gallons exported (must be filed in duplicate)', N'7', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section B: Disbursement', 6, 15, N'6. Gallons delivered to U.S. Government - tax exempt', N'8', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section B: Disbursement', 7, 16, N'7 Gallons delivered to licensed marina fuel dealers', N'10A', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section B: Disbursement', 8, 17, N'8. Gallons delivered to licensed aviation fuel dealers', N'10B', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (40, N'MF-360-Summary-024', N'MF-360', 14, N'IN', N'Section B: Disbursement', 9, 18, N'9. Miscelleaneous deduction - theft/loss', N'E-1', N'143', NULL, NULL, N'Details', 39, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (40, N'MF-360-Summary-025', N'MF-360', 14, N'IN', N'Section B: Disbursement', 10, 19, N'9a. Miscellaneous deduction - off road, other', N'E-1', N'2', NULL, NULL, N'Details', 40, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section B: Disbursement', 11, 20, N'10. Total non-taxable disbursements - add Lines 2-9a, carry total to Section 2, line 2 on front.', N'5,11,6D,6X,7,8,10A,10B', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section B: Disbursement', 12, 21, N'11. Total non-taxable disbursements - add Lines 2-6, carry total to Section 3, line 2 on front', N'5,11,6D,6X,7,8', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'GT-103-Summary-001', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 1, 1, N'1. Total Gallons Sold for Period', N'2D,1R', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'GT-103-Summary-002', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 2, 2, N'2. Total Exempt Gallons Sold for Period', N'2D', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'GT-103-Summary-003', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 3, 3, N'3. Total Taxable Gallons Sold (Line 1 minus Line 2)', N'1,2', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (45, N'GT-103-Summary-004', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 4, 4, N'4. Gasoline Use Tax Due. (Line 3 multiplied by the current rate. See Departmental Notice #2', N'3', N'0.10', NULL, NULL, N'Summary', 9, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (45, N'GT-103-Summary-005', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 5, 5, N'5. Collection Allowance. Do not calculate this allowance if your return and payment are late. Collection allowance rate is 1%', N'0', N'1', NULL, NULL, N'Summary', 10, 9)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'GT-103-Summary-006', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 6, 6, N'6. Net Gasoline Use Tax Due. Subtotal of use tax and collection allowance. (Line 4 minus Line 5)', N'4,5', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (45, N'GT-103-Summary-007', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 7, 7, N'7. Penalty Due. If late, the penalty is 10% of the tax due on Line 6 or $5, whichever is greater.', N'6', N'5', N'', N'', N'Summary', 20, 7)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (45, N'GT-103-Summary-008', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 8, 8, N'8. Interest Due. If late, multiply Line 6 by the interest rate (see Departmental Notice #)', N'6', N'4', N'', N'', N'Summary', 30, 3)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (45, N'GT-103-Summary-009', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 9, 9, N'9. Electronic Funds Transfer Credit', N'0', N'3', NULL, NULL, N'Summary', 40, 2)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (45, N'GT-103-Summary-010', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 10, 10, N'10. Adjustments. If negative entry, use a negative sign. (You must provide an explanation and supporting documentation to the Fuel Tax section.)', N'0', N'01', NULL, NULL, N'Summary', 50, 4)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'GT-103-Summary-011', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 11, 11, N'11. Total Amount Due. (Add Lines 6 through 8, subtract Line 9, add Line 10).', N'6,7,8', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'GT-103', 14, N'IN', N'Receipts - Schedule 1', 1, 1, N'Gasoline', N'1R', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'GT-103', 14, N'IN', N'Receipts - Schedule 1', 2, 2, N'Gasohol', N'1R', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'GT-103', 14, N'IN', N'Receipts - Schedule 1', 3, 3, N'Total Gallons of Fuel Purchased', N'1R', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'GT-103', 14, N'IN', N'Disbursements - Schedule 2', 1, 4, N'Gasoline', N'2D', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'GT-103', 14, N'IN', N'Disbursements - Schedule 2', 2, 5, N'Gasohol', N'2D', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'GT-103', 14, N'IN', N'Disbursements - Schedule 2', 3, 6, N'Total Gallons of Fuel Sold', N'2D', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (45, N'TID', N'GT-103', 14, N'IN', N'HEADER', 0, 0, N'Taxpayer Identification Number', NULL, N'12', NULL, NULL, N'HEADER', 5, 4)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (40, N'License Number', N'MF-360', 14, N'IN', N'HEADER', 0, 0, N'License Number', NULL, N'121258.00', NULL, NULL, N'HEADER', 5, 11)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (40, N'Filing Type', N'MF-360', 14, N'IN', N'HEADER', 0, 0, N'FilingType - Gasoline', NULL, N'1', NULL, NULL, N'HEADER', 6, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (40, N'Filing Type', N'MF-360', 14, N'IN', N'HEADER', 0, 0, N'FilingType - Oil Inspection', NULL, N'1', NULL, NULL, N'HEADER', 7, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (40, N'Filing Type', N'MF-360', 14, N'IN', N'HEADER', 0, 0, N'FilingType - Gasohol Blender', NULL, N'0', NULL, NULL, N'HEADER', 8, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (40, N'License Holder Name', N'MF-360', 14, N'IN', N'HEADER', 0, 0, N'Name of License Holder', NULL, N'TP Name', NULL, NULL, N'HEADER', 1, 2)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (45, N'TaxPayerName', N'GT-103', 14, N'IN', N'HEADER', 0, 0, N'Tax Payer Name', NULL, N'TPayer Name', NULL, NULL, N'HEADER', 1, 4)
				--SF900
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'SF-900', 14, N'IN', N'1', 0, 0, N'Filing Type', N'', NULL, NULL, NULL, N'Filing Type', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-001', N'SF-900', 14, N'IN', N'Section 2: Computation of Tax', 1, 1, N'1. Total Receipts (From Section A, Line 5 on back of return)', N'1,2E,2K,3', NULL, N'details', N'sum', N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-002', N'SF-900', 14, N'IN', N'Section 2: Computation of Tax', 2, 2, N'2. Total Non-Taxable Disbursements (From Section B, Line 11 on back of return)', N'6,6X,7,7A,7B,8,10', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-003', N'SF-900', 14, N'IN', N'Section 2: Computation of Tax', 3, 3, N'3. Taxable Gallons Sold or Used (From Section B, Line 3, on back of return)', N'8,9', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-004', N'SF-900', 14, N'IN', N'Section 2: Computation of Tax', 4, 4, N'4.  Gallons Received Tax Paid (From Section A, Line 1, on back of return)', N'1', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-005', N'SF-900', 14, N'IN', N'Section 2: Computation of Tax', 5, 5, N'5. Billed Taxable Gallons (Line 3 minus Line 4)', N'3,4', NULL, N'', N'', N'Summary', NULL, 6)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (59, N'SF-900-Summary-006', N'SF-900', 14, N'IN', N'Section 2: Computation of Tax', 6, 6, N'6. Tax Due (Multiply Line 5 by $0.16)', N'5', N'0.16', NULL, NULL, N'Summary', 50, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (59, N'SF-900-Summary-007', N'SF-900', 14, N'IN', N'Section 2: Computation of Tax', 7, 7, N'7. Amount of Tax Uncollectible from Eligible Purchasers - Complete Schedule 10E', N'0', N'1', N'', N'', N'Summary', 60, 7)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-008', N'SF-900', 14, N'IN', N'Section 2: Computation of Tax', 8, 8, N'8. Adjusted Tax Due (Line 6 minus Line 7)', N'6,7', NULL, N'', N'', N'Summary', NULL, 1)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (59, N'SF-900-Summary-009', N'SF-900', 14, N'IN', N'Section 2: Computation of Tax', 9, 9, N'9. Collection Allowance (Multiply Line 8 by .016). If return filed or tax paid after due date enter zero (0)', N'8', N'0.016', NULL, NULL, N'Summary', 70, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (59, N'SF-900-Summary-010', N'SF-900', 14, N'IN', N'Section 2: Computation of Tax', 10, 10, N'10. Adjustment - Complete Schedule E-1 (Dollar amount only)', N'0', N'3', N'', N'', N'Summary', 80, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-011', N'SF-900', 14, N'IN', N'Section 2: Computation of Tax', 11, 11, N'11. Total special fuel tax due (Line 8 minus Line 9 plus or minus Line 10)', N'8,9,10', NULL, N'', N'', N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-012', N'SF-900', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 1, 12, N'1. Total billed gallons (From Section 2, Line 5)', N'3,4', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (59, N'SF-900-Summary-013', N'SF-900', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 2, 13, N'2. Oil inspection fees due (Multiply Line 1 by $0.01)', N'12', N'0.01', NULL, NULL, N'Summary', 90, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (59, N'SF-900-Summary-014', N'SF-900', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 3, 14, N'3. Adjustments (Schedule E-1 must be attached and is subject to Department approval)', N'0', N'4', N'', N'', N'Summary', 100, 5)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-015', N'SF-900', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 4, 15, N'4. Total oil inspection fees due (Line 2 plus or minus Line 3)', N'13,14', NULL, NULL, NULL, N'Summary', NULL, 2)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-016', N'SF-900', 14, N'IN', N'Section 4: Calculation of Total Amount Due', 1, 16, N'1. Total amount due (Section 2, Line 11 plus Section 3, Line 4)', N'11,15', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (59, N'SF-900-Summary-017', N'SF-900', 14, N'IN', N'Section 4: Calculation of Total Amount Due', 2, 17, N'2. Penalty (Penalty must be added if report is filed after the due date. 10% of tax due or $5.00, whichever is greater. Five dollars ($5.00) is due on a late report showing no tax due.)', N'0', N'5', NULL, NULL, N'Summary', 110, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (59, N'SF-900-Summary-018', N'SF-900', 14, N'IN', N'Section 4: Calculation of Total Amount Due', 3, 18, N'3. (Interest must be added if report is filed after the due date. Contact the Department for daily interest rates.)', N'0', N'6', NULL, NULL, N'Summary', 120, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-019', N'SF-900', 14, N'IN', N'Section 4: Calculation of Total Amount Due', 4, 19, N'4. Net tax due (Line 1 plus Line 2 plus Line 3)', N'16,17,18', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (59, N'SF-900-Summary-020', N'SF-900', 14, N'IN', N'Section 4: Calculation of Total Amount Due', 5, 20, N'5. Payment(s)', N'0', N'7', NULL, NULL, N'Summary', 130, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-021', N'SF-900', 14, N'IN', N'Section 4: Calculation of Total Amount Due', 6, 21, N'6. Balance due (Line 4 minus Line 5)', N'19,20', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'SF-900', 14, N'IN', N'Section A: Receipts', 1, 1, N'Section A:    Receipts', N'0', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-023', N'SF-900', 14, N'IN', N'Section A: Receipts', 2, 2, N'1. Gallons Received Tax Paid (Carry forward to Section 2, Line 4 on front of return)', N'1', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-024', N'SF-900', 14, N'IN', N'Section A: Receipts', 3, 3, N'2. Gallons Received for Export (To be completed only by licensed exporters)', N'2E', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-025', N'SF-900', 14, N'IN', N'Section A: Receipts', 4, 4, N'3. Gallons of Nontaxable Fuel Received and Sold or Used For a Taxable Purpose', N'2K', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-026', N'SF-900', 14, N'IN', N'Section A: Receipts', 5, 5, N'4. Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid', N'3', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-027', N'SF-900', 14, N'IN', N'Section A: Receipts', 6, 6, N'5. Total Receipts (Add Lines 1 through 4, carry forward to Section 2, Line 1 on', N'1,2E,2K,3', NULL, NULL, NULL, N'Details', NULL, NULL)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'SF-900', 14, N'IN', N'Section B: Disbursement', 1, 7, N'Section B:    Disbursements', N'0', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-029', N'SF-900', 14, N'IN', N'Section B: Disbursement', 2, 8, N'1. Gallons Delivered Tax Collected and Gallons Blended or Dyed Fuel Used', N'5', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-030', N'SF-900', 14, N'IN', N'Section B: Disbursement', 3, 9, N'2. Diversions (Special fuel only)', N'11', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-031', N'SF-900', 14, N'IN', N'Section B: Disbursement', 4, 10, N'3. Taxable Gallons Sold or Used (Carry forward to Section 2, Line 3 on front', N'8,9', NULL, NULL, NULL, N'Details', NULL, NULL)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-032', N'SF-900', 14, N'IN', N'Section B: Disbursement', 5, 11, N'4. Gallons Delivered Via Rail, Pipeline, or Vessel to Licensed Suppliers, Tax', N'6', NULL, NULL, NULL, N'Details', NULL, NULL)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-033', N'SF-900', 14, N'IN', N'Section B: Disbursement', 6, 12, N'5. Gallons Disbursed on Exchange for Other Suppliers or Permissive Suppliers', N'6X', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-034', N'SF-900', 14, N'IN', N'Section B: Disbursement', 7, 13, N'6. Gallons Exported by License Holder', N'7', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-035', N'SF-900', 14, N'IN', N'Section B: Disbursement', 8, 14, N'7. Gallons Sold to Unlicensed Exporters for Export', N'7A', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-036', N'SF-900', 14, N'IN', N'Section B: Disbursement', 9, 15, N'8. Gallons Sold to Licensed Exporters for Export', N'7B', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-037', N'SF-900', 14, N'IN', N'Section B: Disbursement', 10, 16, N'9. Gallons of Undyed Fuel Sold to the U.S. Government - Tax Exempt', N'8', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-038', N'SF-900', 14, N'IN', N'Section B: Disbursement', 11, 17, N'10. Gallons Sold of Tax Exempt Dyed Fuel', N'10', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'SF-900-Summary-039', N'SF-900', 14, N'IN', N'Section B: Disbursement', 12, 18, N'11. Total Non-Taxable Disbursements (Add Lines 4 through 10; carry forward to', N'6,6X,7,7A,7B,8,10', NULL, NULL, NULL, N'Details', NULL, NULL)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (59, N'License Number', N'SF-900', 14, N'IN', N'HEADER', 0, 0, N'License Number', NULL, N'001', NULL, NULL, N'HEADER', 2, 11)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (59, N'Filing Type', N'SF-900', 14, N'IN', N'HEADER', 0, 0, N'FilingType - Supplier', NULL, N'1', NULL, NULL, N'HEADER', 3, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (59, N'Filing Type', N'SF-900', 14, N'IN', N'HEADER', 0, 0, N'FilingType - Permissive Supplier', NULL, N'1', NULL, NULL, N'HEADER', 4, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (59, N'Filing Type', N'SF-900', 14, N'IN', N'HEADER', 0, 0, N'FilingType - Importer', NULL, N'1', NULL, NULL, N'HEADER', 5, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (59, N'Filing Type', N'SF-900', 14, N'IN', N'HEADER', 0, 0, N'FilingType - Exporter', NULL, N'1', NULL, NULL, N'HEADER', 6, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (59, N'Filing Type', N'SF-900', 14, N'IN', N'HEADER', 0, 0, N'FilingType - Blender', NULL, N'1', NULL, NULL, N'HEADER', 7, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (59, N'Filing Type', N'SF-900', 14, N'IN', N'HEADER', 0, 0, N'FilingType - Dyed Fuel User', NULL, N'1', NULL, NULL, N'HEADER', 8, 0)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (59, N'LicenseHolderName', N'SF-900', 14, N'IN', N'HEADER', 0, 0, N'Name of License Holder', NULL, N'Company 01', NULL, NULL, N'HEADER', 1, 0)
				--EDI
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-ISA01', N'EDI', 14, N'IN', N'EDI', NULL, 0, N'ISA01 - Authorization Information Qualifier', NULL, N'03', NULL, NULL, N'Summary', 42, 4)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-ISA02', N'EDI', 14, N'IN', N'EDI', NULL, 0, N'ISA02 - Authorization Information', NULL, N'1234567899', NULL, NULL, N'Summary', 46, 4)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-ISA03', N'EDI', 14, N'IN', N'EDI', NULL, 0, N'ISA03 - Security Information Qualifier', NULL, N'01', NULL, NULL, N'Summary', 48, 5)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-ISA04', N'EDI', 14, N'IN', N'EDI', NULL, 0, N'ISA04 - Security Information', NULL, N'9987654321', NULL, NULL, N'Summary', 50, 4)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-ISA05', N'EDI', 14, N'IN', N'EDI', 7, 23, N'ISA05 - Interchange ID Qualifier', NULL, N'32', NULL, NULL, N'Summary', 55, 4)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-ISA06', N'EDI', 14, N'IN', N'EDI', 7, 23, N'ISA06 - Interchange Sender ID', NULL, N'777776666', NULL, NULL, N'Summary', 60, 7)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-ISA07', N'EDI', 14, N'IN', N'EDI', 7, 23, N'ISA07 - Interchange ID Qualifier', NULL, N'01', NULL, NULL, N'Summary', 65, 3)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-ISA08', N'EDI', 14, N'IN', N'EDI', 7, 23, N'ISA08 - Interchange Receiver ID', NULL, N'824799308', NULL, NULL, N'Summary', 70, 3)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-ISA11', N'EDI', 14, N'IN', N'EDI', 7, 23, N'ISA11 - Repetition Separator', NULL, N'|', NULL, NULL, N'Summary', 75, 4)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-ISA12', N'EDI', 14, N'IN', N'EDI', 7, 23, N'ISA12 - Interchange Control Version Number', NULL, N'00403', NULL, NULL, N'Summary', 80, 2)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-ISA13', N'EDI', 14, N'IN', N'EDI', 7, 23, N'ISA13 - Interchange Control Number (for next transmission)', NULL, N'1187', NULL, NULL, N'Summary', 85, 2)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-ISA14', N'EDI', 14, N'IN', N'EDI', 7, 23, N'ISA14 - Acknowledgement Requested', NULL, N'00403', NULL, NULL, N'Summary', 90, 3)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-ISA15', N'EDI', 14, N'IN', N'EDI', 7, 23, N'ISA15 - Usage Indicator (P = Production; T = Test)', NULL, N'T', NULL, NULL, N'Summary', 95, 2)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-ISA16', N'EDI', 14, N'IN', N'EDI', 7, 23, N'ISA16 - Component Sub-element Separator', NULL, N'^', NULL, NULL, N'Summary', 100, 4)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-GS01', N'EDI', 14, N'IN', N'EDI', 7, 23, N'GS01 - Functional Identifier Code', NULL, N'TF', NULL, NULL, N'Summary', 105, 2)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-GS02', N'EDI', 14, N'IN', N'EDI', 7, 23, N'GS02 - Application Sender''s Code', NULL, NULL, NULL, NULL, N'Summary', 110, 2)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-GS03', N'EDI', 14, N'IN', N'EDI', 7, 23, N'GS03 - Receiver''s Code', NULL, N'824799308050', NULL, NULL, N'Summary', 115, 2)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-GS06', N'EDI', 14, N'IN', N'EDI', 7, 23, N'GS06 - Group Control Number (for next transmission)', NULL, N'1202', NULL, NULL, N'Summary', 120, 3)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-GS07', N'EDI', 14, N'IN', N'EDI', 7, 23, N'GS07 - Responsible Agency Code', NULL, N'X', NULL, NULL, N'Summary', 125, 2)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-GS08', N'EDI', 14, N'IN', N'EDI', 7, 23, N'GS08 - Version/Release/Industry ID Code', NULL, N'004030', NULL, NULL, N'Summary', 130, 2)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-ST01', N'EDI', 14, N'IN', N'EDI', 7, 23, N'ST01 - Transaction Set Code', NULL, N'8132', NULL, NULL, N'Summary', 135, 2)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-ST02', N'EDI', 14, N'IN', N'EDI', 7, 23, N'ST02 - Transaction Set Control Number (for next transmission)', NULL, N'321', NULL, NULL, N'Summary', 137, 2)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-BTI13', N'EDI', 14, N'IN', N'EDI', 7, 23, N'BTI13 - Transaction Set Purpose Code', NULL, NULL, NULL, NULL, N'Summary', 140, 2)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-BTI14', N'EDI', 14, N'IN', N'EDI', 7, 23, N'BTI14 - Transaction Type Code', NULL, NULL, NULL, NULL, N'Summary', 145, 2)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-FilePath', N'EDI', 14, N'IN', N'EDI', 7, 23, N'EDI File Path', NULL, N'C:\dir', NULL, NULL, N'Summary', 155, 2)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-FileName1st', N'EDI', 14, N'IN', N'EDI', 7, 23, N'EDI File Name - 1st part (TST or PRD)', NULL, N'fname1', NULL, NULL, N'Summary', 160, 2)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-FileName2nd', N'EDI', 14, N'IN', N'EDI', 7, 23, N'EDI File Name - 2nd part (Tax Payer Code)', NULL, N'fname2', NULL, NULL, N'Summary', 165, 2)
				INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (70, N'MF-360-FileName3rd', N'EDI', 14, N'IN', N'EDI', 7, 23, N'EDI File Name - 3rd part (Next Sequence Number)', NULL, N'fname3', NULL, NULL, N'Summary', 170, 2)
		END
	END
END

PRINT 'END TF Reporting Component - IN'