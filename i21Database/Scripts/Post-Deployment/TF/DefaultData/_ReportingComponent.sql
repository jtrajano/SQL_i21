﻿
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

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '1','Gallons Received Tax Paid (Special Fuel Returns Only)','', 560, '')
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
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '2E','Gallons Received for Export (Special Fuel Exporters Only)','', 570, '')
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
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '2K','Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose','', 580, '')
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
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '3','Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid','', 590, '')
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
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '5','Gallons Delivered, Tax Collected and Gallons Blended or Dyed Fuel Used','', 600, '')
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
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '6','Gallons Delivered Via Rail, Pipeline or Vessel to Licensed Suppliers, Tax not Collected (Special Fuel)','', 610, '')
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
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '6X','Gallons Disbursed on exchange','', 620, '')
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
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '7','Gallons Exported to State of','', 630, '')
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
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '8', 'Gallons of Undyed Special Fuel, Gasoline and Kerosene sold to the US Government Tax Exempt','', 660, '')
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
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '10', 'Gallons Sold of Tax Exempt Dyed Fuel','', 670, '')
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
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '11', 'Diversion Corrections','', 680, '')
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
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '', '','', 690, '')
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

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'EDI',	'Electronic file', '', 'IN EDI file', '', 800, '')
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
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'1', 0, 0, N'Filing Type', N'', NULL, NULL, NULL, N'Filing Type', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-001', N'MF-360', 14, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 1, 1, N'1. Total receipts (From Section A, Line 8, Column D on back of return)', N'1A,2,2K,2X,3,4', NULL, N'details', N'sum', N'Summary', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-002', N'MF-360', 14, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 2, 2, N'2. Total non-taxable disbursements (From Section B, Line 10, Column D on back of return)', N'11,6D,6X,7,8,10A,10B', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-003', N'MF-360', 14, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 3, 3, N'3. Gallons received, gasoline tax paid (From Section A, Line 1, Column A on back of return)', N'1A', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-004', N'MF-360', 14, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 4, 4, N'4.  Billed taxable gallons (Line 1 minus Line 2 minus Line 3)', N'1,2,3', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (40, N'MF-360-Summary-005', N'MF-360', 14, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 5, 5, N'5. Licensed gasoline distributor deduction (Multiply Line 4 by 0.1212)', N'4', N'0.12', N'', N'', N'Summary', 10, 4)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-006', N'MF-360', 14, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 6, 6, N'6. Billed taxable gallons (Line 4 minus Line 5)', N'4,5', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (40, N'MF-360-Summary-007', N'MF-360', 14, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 7, 7, N'7 Gasoline tax due (Multiply Line 6 by $0.15157)', N'6', N'0.15', N'', N'', N'Summary', 20, 3)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-008', N'MF-360', 14, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 8, 8, N'8. Adjustments (Schedule E-1 must be attached and is subject to Department approval)', N'0', NULL, N'', N'', N'Summary', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-009', N'MF-360', 14, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 9, 9, N'9. Total gasoline tax due (Line 7 plus or minus Line 8)', N'7,8', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-010', N'MF-360', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 1, 10, N'1. Total receipts (From Section A, Line 9, Coumn D on back of return)', N'1A,2,2K,2X,3,4', NULL, N'', N'', N'Summary', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-011', N'MF-360', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 2, 11, N'2. Total non-taxable disbursements (From Section B, Line 11, Column D on back of return)', N'11,6D,6X,7,8', NULL, N'', N'', N'Summary', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-012', N'MF-360', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 3, 12, N'3. Gallons received, oil inspection fee paid (From Section A, Line 1, Column D on back of return)', N'1A', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-013', N'MF-360', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 4, 13, N'4. Billed taxable gallons (Line 1 minus Line 2 minus Line 3)', N'10,11,12', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (40, N'MF-360-Summary-014', N'MF-360', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 5, 14, N'5. Oil inspection fees due (Multiply Line 4 by $0.144)', N'13', N'0.14', N'', N'', N'Summary', 30, 4)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-015', N'MF-360', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 6, 15, N'6. Adjustments (Schedule E-1 must be attached and is subject to Department approval)', N'15', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-016', N'MF-360', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 7, 16, N'7. Total oil inspection fees due (Line 5 plus or minus Line 6)', N'14,15', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-017', N'MF-360', 14, N'IN', N'Section 4:    Calculation of Total Amount Due', 1, 17, N'1. Total amount due (Section 2, Line 9 plus Section 3, Line 7)', N'9,16', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-018', N'MF-360', 14, N'IN', N'Section 4:    Calculation of Total Amount Due', 2, 18, N'2. Penalty (Penalty must be added if report is filed after the due date. 10% of tax due or $5.00, whichever is greater. Five dollars ($5.00) is due on a late report showing no tax due.)', N'18', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-019', N'MF-360', 14, N'IN', N'Section 4:    Calculation of Total Amount Due', 3, 19, N'3. Interest (Interest must be added if report is filed after the due date. Contact the Department for daily interest rates.)', NULL, NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-020', N'MF-360', 14, N'IN', N'Section 4:    Calculation of Total Amount Due', 4, 20, N'4. Net tax due (Line 1 plus Line 2 plus Line 3)', N'17,18,19', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-021', N'MF-360', 14, N'IN', N'Section 4:    Calculation of Total Amount Due', 5, 21, N'5. Payment(s)', NULL, NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-022', N'MF-360', 14, N'IN', N'Section 4:    Calculation of Total Amount Due', 6, 22, N'6. Balance due (Line 4 minus Line 5)', N'20,21', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-023', N'MF-360', 14, N'IN', N'Section 4:    Calculation of Total Amount Due', 7, 7, N'7. Gallons of gasoline sold to taxable marina', NULL, NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section A: Receipts', 1, 1, N'1. Gallons received, gasoline tax or inspection fee paid', N'1A', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section A: Receipts', 2, 2, N'2. Gallons received from licensed distributors or oil inspection distributors, tax unpaid', N'2', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section A: Receipts', 3, 3, N'3. Gallons of non-taxable fuel received and sold or used for a taxable purpose', N'2K', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section A: Receipts', 4, 4, N'4. Gallons received from licensed distributors on exchange agreements, tax unpaid', N'2X', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section A: Receipts', 5, 5, N'5. Gallons imported directly to customer', N'3', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section A: Receipts', 6, 6, N'6. Gallons imported directly to customer', N'4', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section A: Receipts', 7, 7, N'7. Diversions into Indiana', N'11', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section A: Receipts', 8, 8, N'8. Total receipts - add Lines 1-7, carry total(Column D) to Section 2, Line 1 on front', N'1A,2,2K,2X,3,4', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section A: Receipts', 9, 9, N'9. Total Receipts - add Lines 1-7, carry total (Column D) to Section 3, Line 1 on front', N'1A,2,2K,2X,3,4', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section B: Disbursement', 1, 10, N'1. Gallons delivered, tax collected', N'5', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section B: Disbursement', 2, 11, N'2. Diversion out of Indiana', N'11', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section B: Disbursement', 3, 12, N'3. Gallons sold to licensed distributors, tax not collected', N'6D', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section B: Disbursement', 4, 13, N'4. Gallons disbursed on exchange', N'6X', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section B: Disbursement', 5, 14, N'5. Gallons exported (must be filed in duplicate)', N'7', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section B: Disbursement', 6, 15, N'6. Gallons delivered to U.S. Government - tax exempt', N'8', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section B: Disbursement', 7, 16, N'7 Gallons delivered to licensed marina fuel dealers', N'10A', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section B: Disbursement', 8, 17, N'8. Gallons delivered to licensed aviation fuel dealers', N'10B', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section B: Disbursement', 9, 18, N'9. Miscelleaneous deduction - theft/loss', N'E-1', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section B: Disbursement', 10, 19, N'9a. Miscellaneous deduction - off road, other', N'E-1', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section B: Disbursement', 11, 20, N'10. Total non-taxable disbursements - add Lines 2-9a, carry total to Section 2, line 2 on front.', N'11,6D,6X,7,8,10A,10B', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', 14, N'IN', N'Section B: Disbursement', 12, 21, N'11. Total non-taxable disbursements - add Lines 2-6, carry total to Section 3, line 2 on front', N'11,6D,6X,7,8', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'GT-103-Summary-001', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 1, 1, N'1. Total Gallons Sold for Period', N'2D,1R', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'GT-103-Summary-002', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 2, 2, N'2. Total Exempt Gallons Sold for Period', N'2D', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'GT-103-Summary-003', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 3, 3, N'3. Total Taxable Gallons Sold (Line 1 minus Line 2)', N'1,2', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'GT-103-Summary-004', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 4, 4, N'4. Gasoline Use Tax Due. (Line 3 multiplied by the current rate. See Departmental Notice #2', N'3', N'0.10', NULL, NULL, N'Summary', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (45, N'GT-103-Summary-005', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 5, 5, N'5. Collection Allowance. Do not calculate this allowance if your return and payment are late. Collection allowance rate is 1%', N'0', N'1', NULL, NULL, N'Summary', 10, 9)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'GT-103-Summary-006', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 6, 6, N'6. Net Gasoline Use Tax Due. Subtotal of use tax and collection allowance. (Line 4 minus Line 5)', N'4,5', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (45, N'GT-103-Summary-007', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 7, 7, N'7. Penalty Due. If late, the penalty is 10% of the tax due on Line 6 or $5, whichever is greater.', N'6', N'5', N'', N'', N'Summary', 20, 7)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (45, N'GT-103-Summary-008', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 8, 8, N'8. Interest Due. If late, multiply Line 6 by the interest rate (see Departmental Notice #)', N'6', N'4', N'', N'', N'Summary', 30, 3)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (45, N'GT-103-Summary-009', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 9, 9, N'9. Electronic Funds Transfer Credit', N'0', N'3', NULL, NULL, N'Summary', 40, 2)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (45, N'GT-103-Summary-010', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 10, 10, N'14. Adjustments. If negative entry, use a negative sign. (You must provide an explanation and', N'0', N'01', NULL, NULL, N'Summary', 50, 4)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, N'GT-103-Summary-011', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 11, 11, N'11. Total Amount Due. (Add Lines 6 through 8, subtract Line 9, add Line 10).', N'6,7,8', NULL, NULL, NULL, N'Summary', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'GT-103', 14, N'IN', N'Receipts - Schedule 1', 1, 1, N'Total Gallons of Fuel Purchased', N'1R', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES ( NULL, NULL, N'GT-103', 14, N'IN', N'Receipts - Schedule 1', 2, 2, N'Gasoline', N'1R', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'GT-103', 14, N'IN', N'Receipts - Schedule 1', 3, 3, N'Gasohol', N'1R', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'GT-103', 14, N'IN', N'Disbursements - Schedule 2', 1, 4, N'Gasoline', N'2D', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'GT-103', 14, N'IN', N'Disbursements - Schedule 2', 2, 5, N'Gasohol', N'2D', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (NULL, NULL, N'GT-103', 14, N'IN', N'Disbursements - Schedule 2', 3, 6, N'Total Gallons of Fuel Sold', N'2D', NULL, NULL, NULL, N'Details', NULL, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (45, N'TID', N'GT-103', 14, N'IN', N'HEADER', 0, 0, N'Taxpayer Identification Number', NULL, N'123', NULL, NULL, N'HEADER', 5, 3)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (40, N'License Number', N'MF-360', 14, N'IN', N'HEADER', 0, 0, N'License Number', NULL, N'121258.00', NULL, NULL, N'HEADER', 5, 11)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (40, N'Filing Type', N'MF-360', 14, N'IN', N'HEADER', 0, 0, N'FilingType - Gasoline', NULL, N'1', NULL, NULL, N'HEADER', 6, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (40, N'Filing Type', N'MF-360', 14, N'IN', N'HEADER', 0, 0, N'FilingType - Oil Inspection', NULL, N'1', NULL, NULL, N'HEADER', 7, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (40, N'Filing Type', N'MF-360', 14, N'IN', N'HEADER', 0, 0, N'FilingType - Gasohol Blender', NULL, N'0', NULL, NULL, N'HEADER', 8, 0)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (40, N'License Holder Name', N'MF-360', 14, N'IN', N'HEADER', 0, 0, N'Name of License Holder', NULL, N'TP Holder Name', NULL, NULL, N'HEADER', 1, 1)
				INSERT [tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConfigurationSequence], [intConcurrencyId]) VALUES (45, N'TaxPayerName', N'GT-103', 14, N'IN', N'HEADER', 0, 0, N'Tax Payer Name', NULL, N'TP Name', NULL, NULL, N'HEADER', 1, 3)
			END
	END
END

PRINT 'END TF Reporting Component - IN'