GO
PRINT 'START TF Reporting Component'
GO

DECLARE @intTaxAuthorityId INT
DECLARE @MasterPk	INT
DECLARE @ScheduleFieldTemplateMasterPk INT

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IN'
IF (@intTaxAuthorityId IS NOT NULL)


TRUNCATE TABLE tblTFScheduleFieldTemplate
TRUNCATE TABLE tblTFScheduleFields
TRUNCATE TABLE tblTFTaxReportTemplate
TRUNCATE TABLE tblTFTransactions
-- CONFIGS
TRUNCATE TABLE tblTFValidAccountStatusCode
TRUNCATE TABLE tblTFValidLocalTax
TRUNCATE TABLE tblTFValidOriginDestinationState
TRUNCATE TABLE tblTFValidProductCode
TRUNCATE TABLE tblTFValidVendor

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

ALTER TABLE tblTFValidOriginDestinationState
DROP CONSTRAINT FK_tblTFValidOriginDestinationState_tblTFReportingComponentDetail

ALTER TABLE tblTFValidProductCode
DROP CONSTRAINT FK_tblTFValidProductCode_tblTFReportingComponentDetail

ALTER TABLE tblTFValidVendor
DROP CONSTRAINT FK_tblTFValidVendor_tblTFReportingComponentDetail

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

ALTER TABLE tblTFValidOriginDestinationState ADD CONSTRAINT
FK_tblTFValidOriginDestinationState_tblTFReportingComponentDetail FOREIGN KEY
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




BEGIN
	IF NOT EXISTS(SELECT TOP 1 [intTaxAuthorityId] FROM [tblTFReportingComponent] WHERE [intTaxAuthorityId] = @intTaxAuthorityId)
	BEGIN
		
		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'1A'	,'Gallons Received Tax Paid (Gasoline Return Only)','', 10, 'Gasoline / Aviation Gasoline / Gasohol')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'1A'	,'Gallons Received Tax Paid (Gasoline Return Only)','', 20, 'K-1 / K-2 Kerosene')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'1A'	,'Gallons Received Tax Paid (Gasoline Return Only)','', 30, 'All Other Products')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'2'	,'Gallons Received from Licensed Distributor or Oil Inspection Distributor, Tax Unpaid (Gasoline Only)','', 40, 'Gasoline / Aviation Gasoline / Gasohol')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'2'	,'Gallons Received from Licensed Distributor or Oil Inspection Distributor, Tax Unpaid (Gasoline Only)','', 50, 'K-1 / K-2 Kerosene')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'2'	,'Gallons Received from Licensed Distributor or Oil Inspection Distributor, Tax Unpaid (Gasoline Only)','', 60, 'All Other Products')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'2K'	,'Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose','', 70, 'Gasoline / Aviation Gasoline / Gasohol')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'2K'	,'Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose','', 80, 'K-1 / K-2 Kerosene')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'2K'	,'Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose','', 90, 'All Other Products')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'2X','Gallons Received from Distributor on Exchange (Gasoline Only)','', 100, 'Gasoline / Aviation Gasoline / Gasohol')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'2X','Gallons Received from Distributor on Exchange (Gasoline Only)','', 110, 'K-1 / K-2 Kerosene')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'2X','Gallons Received from Distributor on Exchange (Gasoline Only)','', 120, 'All Other Products')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)


		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'3','Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid','', 130, 'Gasoline / Aviation Gasoline / Gasohol')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'Vendor FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Received', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strBillOfLading', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'3','Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid','', 140, 'K-1 / K-2 Kerosene')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'3','Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid','', 150, 'All Other Products')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'4','Gallons Imported into Own Storage  (Gasoline Only)','', 160, 'Gasoline / Aviation Gasoline / Gasohol')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'4','Gallons Imported into Own Storage  (Gasoline Only)','', 170, 'K-1 / K-2 Kerosene')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'4','Gallons Imported into Own Storage  (Gasoline Only)','', 180, 'All Other Products')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'5','Gallons Delivered, Tax Collected','', 190, 'Gasoline / Aviation Gasoline / Gasohol')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Terminal Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Buyer Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'Buyer FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Sent', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strInvoiceNumber', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		--NOT EXIST YET
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'5','Gallons Delivered, Tax Collected and Gallons Blended or Dyed Fuel Used','', 200, 'K-1 / K-2 Kerosene')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'5','Gallons Delivered, Tax Collected and Gallons Blended or Dyed Fuel Used','', 210, 'All Other Products')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'6D','Gallons Sold to Licensed Distributors, Tax Not Collected (Gasoline Only)','', 220, 'Gasoline / Aviation Gasoline / Gasohol')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Terminal Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Buyer Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'Buyer FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Sent', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strInvoiceNumber', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		--NOT EXIST YET
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'6D','Gallons Sold to Licensed Distributors, Tax Not Collected (Gasoline Only)','', 230, 'K-1 / K-2 Kerosene')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'6D','Gallons Sold to Licensed Distributors, Tax Not Collected (Gasoline Only)','', 240, 'All Other Products')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'6X','Gallons Disbursed on exchange','', 250, 'Gasoline / Aviation Gasoline / Gasohol')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'6X','Gallons Disbursed on exchange','', 260, 'K-1 / K-2 Kerosene')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'6X','Gallons Disbursed on exchange','', 270, 'All Other Products')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'7MI','Gallons Exported to State of MI','', 280, 'Gasoline / Aviation Gasoline / Gasohol')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Terminal Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Buyer Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'Buyer FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Sent', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strInvoiceNumber', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		--NOT EXIST YET
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'7MI','Gallons Exported to State of MI','', 290, 'K-1 / K-2 Kerosene')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'7MI','Gallons Exported to State of MI','', 300, 'All Other Products')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		
		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'8','Gallons of Undyed Special Fuel, Gasoline and Kerosene sold to the US Government Tax Exempt','', 370, 'Gasoline / Aviation Gasoline / Gasohol')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Terminal Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Buyer Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'Buyer FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Sent', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strInvoiceNumber', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		--NOT EXIST YET
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'8','Gallons of Undyed Special Fuel, Gasoline and Kerosene sold to the US Government Tax Exempt','', 380, 'K-1 / K-2 Kerosene')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'8','Gallons of Undyed Special Fuel, Gasoline and Kerosene sold to the US Government Tax Exempt','', 390, 'All Other Products')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'10A','Gallons Delivered to Marina Fuel Dealers','', 460, 'Gasoline / Aviation Gasoline / Gasohol')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'Transporter FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strTransportationMode', N'Mode', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Terminal Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Buyer Name', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerFederalTaxId', N'Buyer FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date Sent', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strInvoiceNumber', N'Document Number', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		--NOT EXIST YET
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'10A','Gallons Delivered to Marina Fuel Dealers','', 470, 'K-1 / K-2 Kerosene')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'10A','Gallons Delivered to Marina Fuel Dealers','', 480, 'All Other Products')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'10B','Gallons Delivered to Aviation Fuel Dealers','', 490, 'Gasoline / Aviation Gasoline / Gasohol')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'10B','Gallons Delivered to Aviation Fuel Dealers','', 500, 'K-1 / K-2 Kerosene')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'10B','Gallons Delivered to Aviation Fuel Dealers','', 510, 'All Other Products')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'MF-360',	'Consolidated Gasoline Monthly Tax Return',	'','Main Form','Form MF-360', 520, '')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'GT-103',	'Recap of Gasoline Use Tax by Distributors', '1R','Receipt Schedule','', 530, '')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'GT-103',	'Recap of Gasoline Use Tax by Distributors', '2D','Disbursement Schedule','', 540, '')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'GT-103',	'Recap of Gasoline Use Tax by Distributors', 'DR','Recap of Gasoline Use Tax by Distributors','', 550, '')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '1','Gallons Received Tax Paid (Special Fuel Returns Only)','', 560, '')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '2E','Gallons Received for Export (Special Fuel Exporters Only)','', 570, '')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '2K','Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose','', 580, '')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '3','Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid','', 590, '')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '5','Gallons Delivered, Tax Collected and Gallons Blended or Dyed Fuel Used','', 600, '')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '6','Gallons Delivered Via Rail, Pipeline or Vessel to Licensed Suppliers, Tax not Collected (Special Fuel)','', 610, '')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '6X','Gallons Disbursed on exchange','', 620, '')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '7','Gallons Exported to State of','', 630, '')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '8', 'Gallons of Undyed Special Fuel, Gasoline and Kerosene sold to the US Government Tax Exempt','', 660, '')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '10', 'Gallons Sold of Tax Exempt Dyed Fuel','', 670, '')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '11', 'Diversion Corrections','', 680, '')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-900',	'Consolidated Special Fuel Monthly Tax Return', '', '','', 690, '')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return', '1A', 'Exports','Dyed and Clear Diesel Fuel, Biodiesel and Blended Biodiesel', 700, 'Special Fuel')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return', '1A', 'Exports','Gasoline, Gasohol', 710, 'Gasoline')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
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

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return', '2A', 'Imports','Jet Fuel, Kerosene', 740, 'Special Fuel')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return', '2A', 'Imports','Gasoline, Gasohol', 750, 'Gasoline')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return', '2A', 'Imports','Jet Fuel, Kerosene', 760, 'Other Products')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return', '3A', 'In-State Transfers', 'Dyed and Clear Diesel Fuel, Biodiesel and Blended', 770, 'Special Fuel')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return', '3A' , 'In-State Transfers', 'Gasoline, Gasohol', 780, 'Gasoline')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'SF-401',	'Transporters Monthly Tax Return', '3A' , 'In-State Transfers', 'Jet Fuel, Kerosene', 790, 'Other Products')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		INSERT INTO [tblTFReportingComponent]([intTaxAuthorityId],[strFormCode],[strFormName],[strScheduleCode],[strScheduleName],[strNote],[intPositionId],[strType])
		VALUES(@intTaxAuthorityId, 'EDI',	'Electronic file', '', 'IN EDI file', '', 800, '')
		SELECT @MasterPk  = SCOPE_IDENTITY();
		INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
		VALUES(@intTaxAuthorityId, @MasterPk,1,2)
		INSERT INTO [tblTFReportingComponentDetail] ([intReportingComponentId])
		VALUES(@MasterPk)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strScheduleName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCodeDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strSupplierName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxCode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTaxClass')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strItemNo')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityVendorId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBillOfLading')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intItemId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intTaxCodeId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblTax')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShortName')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strType')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDescription')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblQtyShipped')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strPONumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strBOLNumber')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityCustomerId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToCity')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'intEntityShipViaId')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransporterLicense')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strTransportationMode')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerFederalTaxId')
		
		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strProductCode')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strProductCode', N'Product Code', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorName', N'Vendor', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorFederalTaxId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorFederalTaxId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strCustomerName')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strCustomerName', N'Customer', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipVia')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipVia', N'Transporter', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strFederalId')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strFederalId', N'FEIN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strShipToState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strShipToState', N'Destination State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dtmDate')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dtmDate', N'Date', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblNet')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblNet', N'Net', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblGross')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblGross', N'Gross', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblReceived')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblReceived', N'Billed', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strInvoiceNumber')

		--NOT EXIST YET
		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strVendorLicenseNumber', N'Vendor License', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strVendorLicenseNumber')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginTCN', N'Origin TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginCity', N'Origin City', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginCity')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strOriginState', N'Origin State', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strOriginState')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'strDestinationTCN', N'Destination TCN', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'strDestinationTCN')

		SELECT @ScheduleFieldTemplateMasterPk  = SCOPE_IDENTITY();
		INSERT [dbo].[tblTFScheduleFields] ([intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) 
		VALUES (@MasterPk, N'dblBillQty', N'Billed Gals', N'', N'No', 0, @ScheduleFieldTemplateMasterPk, 0)

		INSERT INTO [tblTFScheduleFieldTemplate] ([intReportingComponentDetailId],[strColumn])
		VALUES(@MasterPk, 'dblBillQty')
		--END

		--TEST DATA TRANSACTIONS
		SET IDENTITY_INSERT [dbo].[tblTFTransactions] ON 
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (1, NULL, 1, 21, N'TR-880', 66, N'Gasoline', 41, N'83817', 45, 1, CAST(9593.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9593.000000 AS Numeric(18, 6)), 5, CAST(38.372000 AS Numeric(18, 6)), N'', N'Inventory', N'Gasoline', N'Gasoline / Aviation ', N'SI-30813', CAST(9593.000000 AS Numeric(18, 6)), N'', N'83817', CAST(0x0000A56800000000 AS DateTime), 1116, N'Reedley             ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'1A', NULL, N'065', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Plains Marketing, L.P.', N'Alta Oil Propane Co. Inc.', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (2, NULL, 1, 21, N'TR-876', 66, N'Gasoline', 41, N'51782', 1043, 1, CAST(9203.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9203.000000 AS Numeric(18, 6)), 5, CAST(36.812000 AS Numeric(18, 6)), N'', N'Inventory', N'Gasoline', N'Gasoline / Aviation ', N'SI-30809', CAST(9203.000000 AS Numeric(18, 6)), N'', N'51782', CAST(0x0000A56A00000000 AS DateTime), 1186, N'Pomona              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'1A', NULL, N'065', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1043, N'', N'Truck', N'Transport Dynamics', N'20-1832037', N'Plains Marketing, L.P.', N'DLE61 POMONA', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (3, NULL, 1, 21, N'TR-875', 66, N'Gasoline', 1091, N'2491', 45, 1, CAST(8835.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8835.000000 AS Numeric(18, 6)), 5, CAST(35.340000 AS Numeric(18, 6)), N'', N'Inventory', N'Gasoline', N'Gasoline / Aviation ', N'SI-30808', CAST(8835.000000 AS Numeric(18, 6)), N'', N'2491', CAST(0x0000A56A00000000 AS DateTime), 1190, N'Sylmar              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'1A', NULL, N'065', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Targa Liquids Marketing and Trade LLC', N'DLE81 SYLMAR', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (4, NULL, 1, 21, N'TR-874', 66, N'Gasoline', 43, N'489565', 45, 1, CAST(8970.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8970.000000 AS Numeric(18, 6)), 5, CAST(35.880000 AS Numeric(18, 6)), N'', N'Inventory', N'Gasoline', N'Gasoline / Aviation ', N'SI-30807', CAST(8970.000000 AS Numeric(18, 6)), N'', N'489565', CAST(0x0000A56B00000000 AS DateTime), 1186, N'Pomona              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'1A', NULL, N'065', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE61 POMONA', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (5, NULL, 1, 21, N'TR-873', 66, N'Gasoline', 43, N'489494', 45, 1, CAST(8909.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8909.000000 AS Numeric(18, 6)), 5, CAST(35.636000 AS Numeric(18, 6)), N'', N'Inventory', N'Gasoline', N'Gasoline / Aviation ', N'SI-30806', CAST(8909.000000 AS Numeric(18, 6)), N'', N'489494', CAST(0x0000A56900000000 AS DateTime), 1186, N'Pomona              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'1A', NULL, N'065', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE61 POMONA', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (6, NULL, 1, 21, N'TR-864', 66, N'Gasoline', 43, N'489509', 45, 1, CAST(8907.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8907.000000 AS Numeric(18, 6)), 5, CAST(35.628000 AS Numeric(18, 6)), N'', N'Inventory', N'Gasoline', N'Gasoline / Aviation ', N'SI-30798', CAST(8907.000000 AS Numeric(18, 6)), N'', N'489509', CAST(0x0000A56A00000000 AS DateTime), 1178, N'Los Angeles         ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'1A', NULL, N'065', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE18 ARRO AUTOGAS', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (7, NULL, 1, 21, N'TR-863', 66, N'Gasoline', 23, N'77536', 45, 1, CAST(9539.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9539.000000 AS Numeric(18, 6)), 5, CAST(38.156000 AS Numeric(18, 6)), N'', N'Inventory', N'Gasoline', N'Gasoline / Aviation ', N'SI-30797', CAST(9539.000000 AS Numeric(18, 6)), N'', N'77536', CAST(0x0000A56B00000000 AS DateTime), 1172, N'Paso Robles         ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'1A', NULL, N'065', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Crestwood West Coast LLC', N'DLE11 PASO ROBLES', N'38-3875473', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (8, NULL, 1, 21, N'TR-862', 66, N'Gasoline', 43, N'467352', 45, 1, CAST(9536.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9536.000000 AS Numeric(18, 6)), 5, CAST(38.144000 AS Numeric(18, 6)), N'', N'Inventory', N'Gasoline', N'Gasoline / Aviation ', N'SI-30796', CAST(9536.000000 AS Numeric(18, 6)), N'', N'467352', CAST(0x0000A56B00000000 AS DateTime), 1172, N'Paso Robles         ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'1A', NULL, N'065', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE11 PASO ROBLES', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (9, NULL, 1, 21, N'TR-859', 66, N'Gasoline', 23, N'A68153', 45, 1, CAST(9381.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9381.000000 AS Numeric(18, 6)), 5, CAST(37.524000 AS Numeric(18, 6)), N'', N'Inventory', N'Gasoline', N'Gasoline / Aviation ', N'SI-30793', CAST(9381.000000 AS Numeric(18, 6)), N'', N'A68153', CAST(0x0000A56A00000000 AS DateTime), 2336, N'Visalia', N'CA', 11, 14, NULL, N'MF-360', NULL, N'1A', NULL, N'065', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Crestwood West Coast LLC', N'Calaveras Materials Inc Subsidiary of Lehigh Hanson', N'38-3875473', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (10, NULL, 1, 21, N'TR-859', 66, N'Gasoline', 23, N'A68153', 45, 1, CAST(9381.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9381.000000 AS Numeric(18, 6)), 5, CAST(37.524000 AS Numeric(18, 6)), N'', N'Inventory', N'Gasoline', N'Gasoline / Aviation ', N'SI-30793', CAST(9381.000000 AS Numeric(18, 6)), N'', N'A68153', CAST(0x0000A56A00000000 AS DateTime), 2336, N'Visalia', N'CA', 11, 14, NULL, N'MF-360', NULL, N'1A', NULL, N'065', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Crestwood West Coast LLC', N'Calaveras Materials Inc Subsidiary of Lehigh Hanson', N'38-3875473', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (11, NULL, 4, 21, N'TR-880', 65, N'Jet Fuel', 41, N'83817', 45, 1, CAST(9593.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9593.000000 AS Numeric(18, 6)), 5, CAST(38.372000 AS Numeric(18, 6)), N'', N'Inventory', N'Jet Fuel', N'Gasoline / Aviation ', N'SI-30813', CAST(9593.000000 AS Numeric(18, 6)), N'', N'83817', CAST(0x0000A56800000000 AS DateTime), 1116, N'Reedley             ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'2', NULL, N'130', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Plains Marketing, L.P.', N'Alta Oil Propane Co. Inc.', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (12, NULL, 4, 21, N'TR-876', 65, N'Jet Fuel', 41, N'51782', 1043, 1, CAST(9203.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9203.000000 AS Numeric(18, 6)), 5, CAST(36.812000 AS Numeric(18, 6)), N'', N'Inventory', N'Jet Fuel', N'Gasoline / Aviation ', N'SI-30809', CAST(9203.000000 AS Numeric(18, 6)), N'', N'51782', CAST(0x0000A56A00000000 AS DateTime), 1186, N'Pomona              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'2', NULL, N'130', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1043, N'', N'Truck', N'Transport Dynamics', N'20-1832037', N'Plains Marketing, L.P.', N'DLE61 POMONA', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (13, NULL, 4, 21, N'TR-875', 65, N'Jet Fuel', 1091, N'2491', 45, 1, CAST(8835.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8835.000000 AS Numeric(18, 6)), 5, CAST(35.340000 AS Numeric(18, 6)), N'', N'Inventory', N'Jet Fuel', N'Gasoline / Aviation ', N'SI-30808', CAST(8835.000000 AS Numeric(18, 6)), N'', N'2491', CAST(0x0000A56A00000000 AS DateTime), 1190, N'Sylmar              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'2', NULL, N'130', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Targa Liquids Marketing and Trade LLC', N'DLE81 SYLMAR', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (14, NULL, 4, 21, N'TR-874', 65, N'Jet Fuel', 43, N'489565', 45, 1, CAST(8970.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8970.000000 AS Numeric(18, 6)), 5, CAST(35.880000 AS Numeric(18, 6)), N'', N'Inventory', N'Jet Fuel', N'Gasoline / Aviation ', N'SI-30807', CAST(8970.000000 AS Numeric(18, 6)), N'', N'489565', CAST(0x0000A56B00000000 AS DateTime), 1186, N'Pomona              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'2', NULL, N'130', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE61 POMONA', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (15, NULL, 4, 21, N'TR-873', 65, N'Jet Fuel', 43, N'489494', 45, 1, CAST(8909.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8909.000000 AS Numeric(18, 6)), 5, CAST(35.636000 AS Numeric(18, 6)), N'', N'Inventory', N'Jet Fuel', N'Gasoline / Aviation ', N'SI-30806', CAST(8909.000000 AS Numeric(18, 6)), N'', N'489494', CAST(0x0000A56900000000 AS DateTime), 1186, N'Pomona              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'2', NULL, N'130', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE61 POMONA', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (16, NULL, 4, 21, N'TR-864', 65, N'Jet Fuel', 43, N'489509', 45, 1, CAST(8907.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8907.000000 AS Numeric(18, 6)), 5, CAST(35.628000 AS Numeric(18, 6)), N'', N'Inventory', N'Jet Fuel', N'Gasoline / Aviation ', N'SI-30798', CAST(8907.000000 AS Numeric(18, 6)), N'', N'489509', CAST(0x0000A56A00000000 AS DateTime), 1178, N'Los Angeles         ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'2', NULL, N'130', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE18 ARRO AUTOGAS', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (17, NULL, 4, 21, N'TR-863', 65, N'Jet Fuel', 23, N'77536', 45, 1, CAST(9539.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9539.000000 AS Numeric(18, 6)), 5, CAST(38.156000 AS Numeric(18, 6)), N'', N'Inventory', N'Jet Fuel', N'Gasoline / Aviation ', N'SI-30797', CAST(9539.000000 AS Numeric(18, 6)), N'', N'77536', CAST(0x0000A56B00000000 AS DateTime), 1172, N'Paso Robles         ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'2', NULL, N'130', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Crestwood West Coast LLC', N'DLE11 PASO ROBLES', N'38-3875473', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (18, NULL, 4, 21, N'TR-862', 65, N'Jet Fuel', 43, N'467352', 45, 1, CAST(9536.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9536.000000 AS Numeric(18, 6)), 5, CAST(38.144000 AS Numeric(18, 6)), N'', N'Inventory', N'Jet Fuel', N'Gasoline / Aviation ', N'SI-30796', CAST(9536.000000 AS Numeric(18, 6)), N'', N'467352', CAST(0x0000A56B00000000 AS DateTime), 1172, N'Paso Robles         ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'2', NULL, N'130', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE11 PASO ROBLES', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (19, NULL, 4, 21, N'TR-859', 65, N'Jet Fuel', 23, N'A68153', 45, 1, CAST(9381.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9381.000000 AS Numeric(18, 6)), 5, CAST(37.524000 AS Numeric(18, 6)), N'', N'Inventory', N'Jet Fuel', N'Gasoline / Aviation ', N'SI-30793', CAST(9381.000000 AS Numeric(18, 6)), N'', N'A68153', CAST(0x0000A56A00000000 AS DateTime), 2336, N'Visalia', N'CA', 11, 14, NULL, N'MF-360', NULL, N'2', NULL, N'130', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Crestwood West Coast LLC', N'Calaveras Materials Inc Subsidiary of Lehigh Hanson', N'38-3875473', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (20, NULL, 4, 21, N'TR-859', 65, N'Jet Fuel', 23, N'A68153', 45, 1, CAST(9381.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9381.000000 AS Numeric(18, 6)), 5, CAST(37.524000 AS Numeric(18, 6)), N'', N'Inventory', N'Jet Fuel', N'Gasoline / Aviation ', N'SI-30793', CAST(9381.000000 AS Numeric(18, 6)), N'', N'A68153', CAST(0x0000A56A00000000 AS DateTime), 2336, N'Visalia', N'CA', 11, 14, NULL, N'MF-360', NULL, N'2', NULL, N'130', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Crestwood West Coast LLC', N'Calaveras Materials Inc Subsidiary of Lehigh Hanson', N'38-3875473', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (21, NULL, 13, 21, N'TR-880', 64, N'Heating Oil', 41, N'83817', 45, 1, CAST(9593.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9593.000000 AS Numeric(18, 6)), 5, CAST(38.372000 AS Numeric(18, 6)), N'', N'Inventory', N'Heating Oil', N'Gasoline / Aviation ', N'SI-30813', CAST(9593.000000 AS Numeric(18, 6)), N'', N'83817', CAST(0x0000A56800000000 AS DateTime), 1116, N'Reedley             ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'3', NULL, N'152', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Plains Marketing, L.P.', N'Alta Oil Propane Co. Inc.', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (22, NULL, 13, 21, N'TR-876', 64, N'Heating Oil', 41, N'51782', 1043, 1, CAST(9203.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9203.000000 AS Numeric(18, 6)), 5, CAST(36.812000 AS Numeric(18, 6)), N'', N'Inventory', N'Heating Oil', N'Gasoline / Aviation ', N'SI-30809', CAST(9203.000000 AS Numeric(18, 6)), N'', N'51782', CAST(0x0000A56A00000000 AS DateTime), 1186, N'Pomona              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'3', NULL, N'152', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1043, N'', N'Truck', N'Transport Dynamics', N'20-1832037', N'Plains Marketing, L.P.', N'DLE61 POMONA', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (23, NULL, 13, 21, N'TR-875', 64, N'Heating Oil', 1091, N'2491', 45, 1, CAST(8835.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8835.000000 AS Numeric(18, 6)), 5, CAST(35.340000 AS Numeric(18, 6)), N'', N'Inventory', N'Heating Oil', N'Gasoline / Aviation ', N'SI-30808', CAST(8835.000000 AS Numeric(18, 6)), N'', N'2491', CAST(0x0000A56A00000000 AS DateTime), 1190, N'Sylmar              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'3', NULL, N'152', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Targa Liquids Marketing and Trade LLC', N'DLE81 SYLMAR', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (24, NULL, 13, 21, N'TR-874', 64, N'Heating Oil', 43, N'489565', 45, 1, CAST(8970.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8970.000000 AS Numeric(18, 6)), 5, CAST(35.880000 AS Numeric(18, 6)), N'', N'Inventory', N'Heating Oil', N'Gasoline / Aviation ', N'SI-30807', CAST(8970.000000 AS Numeric(18, 6)), N'', N'489565', CAST(0x0000A56B00000000 AS DateTime), 1186, N'Pomona              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'3', NULL, N'152', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE61 POMONA', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (25, NULL, 13, 21, N'TR-873', 64, N'Heating Oil', 43, N'489494', 45, 1, CAST(8909.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8909.000000 AS Numeric(18, 6)), 5, CAST(35.636000 AS Numeric(18, 6)), N'', N'Inventory', N'Heating Oil', N'Gasoline / Aviation ', N'SI-30806', CAST(8909.000000 AS Numeric(18, 6)), N'', N'489494', CAST(0x0000A56900000000 AS DateTime), 1186, N'Pomona              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'3', NULL, N'152', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE61 POMONA', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (26, NULL, 13, 21, N'TR-864', 64, N'Heating Oil', 43, N'489509', 45, 1, CAST(8907.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8907.000000 AS Numeric(18, 6)), 5, CAST(35.628000 AS Numeric(18, 6)), N'', N'Inventory', N'Heating Oil', N'Gasoline / Aviation ', N'SI-30798', CAST(8907.000000 AS Numeric(18, 6)), N'', N'489509', CAST(0x0000A56A00000000 AS DateTime), 1178, N'Los Angeles         ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'3', NULL, N'152', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE18 ARRO AUTOGAS', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (27, NULL, 13, 21, N'TR-863', 64, N'Heating Oil', 23, N'77536', 45, 1, CAST(9539.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9539.000000 AS Numeric(18, 6)), 5, CAST(38.156000 AS Numeric(18, 6)), N'', N'Inventory', N'Heating Oil', N'Gasoline / Aviation ', N'SI-30797', CAST(9539.000000 AS Numeric(18, 6)), N'', N'77536', CAST(0x0000A56B00000000 AS DateTime), 1172, N'Paso Robles         ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'3', NULL, N'152', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Crestwood West Coast LLC', N'DLE11 PASO ROBLES', N'38-3875473', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (28, NULL, 13, 21, N'TR-862', 64, N'Heating Oil', 43, N'467352', 45, 1, CAST(9536.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9536.000000 AS Numeric(18, 6)), 5, CAST(38.144000 AS Numeric(18, 6)), N'', N'Inventory', N'Heating Oil', N'Gasoline / Aviation ', N'SI-30796', CAST(9536.000000 AS Numeric(18, 6)), N'', N'467352', CAST(0x0000A56B00000000 AS DateTime), 1172, N'Paso Robles         ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'3', NULL, N'152', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE11 PASO ROBLES', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (29, NULL, 13, 21, N'TR-859', 64, N'Heating Oil', 23, N'A68153', 45, 1, CAST(9381.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9381.000000 AS Numeric(18, 6)), 5, CAST(37.524000 AS Numeric(18, 6)), N'', N'Inventory', N'Heating Oil', N'Gasoline / Aviation ', N'SI-30793', CAST(9381.000000 AS Numeric(18, 6)), N'', N'A68153', CAST(0x0000A56A00000000 AS DateTime), 2336, N'Visalia', N'CA', 11, 14, NULL, N'MF-360', NULL, N'3', NULL, N'152', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Crestwood West Coast LLC', N'Calaveras Materials Inc Subsidiary of Lehigh Hanson', N'38-3875473', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (30, NULL, 13, 21, N'TR-859', 64, N'Heating Oil', 23, N'A68153', 45, 1, CAST(9381.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9381.000000 AS Numeric(18, 6)), 5, CAST(37.524000 AS Numeric(18, 6)), N'', N'Inventory', N'Heating Oil', N'Gasoline / Aviation ', N'SI-30793', CAST(9381.000000 AS Numeric(18, 6)), N'', N'A68153', CAST(0x0000A56A00000000 AS DateTime), 2336, N'Visalia', N'CA', 11, 14, NULL, N'MF-360', NULL, N'3', NULL, N'152', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Crestwood West Coast LLC', N'Calaveras Materials Inc Subsidiary of Lehigh Hanson', N'38-3875473', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (31, NULL, 19, 21, N'TR-880', 30, N'Aviation Gasoline', 41, N'83817', 45, 1, CAST(9593.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9593.000000 AS Numeric(18, 6)), 5, CAST(38.372000 AS Numeric(18, 6)), N'', N'Inventory', N'Aviation Gasoline', N'Gasoline / Aviation ', N'SI-30813', CAST(9593.000000 AS Numeric(18, 6)), N'', N'83817', CAST(0x0000A56800000000 AS DateTime), 1116, N'Reedley             ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'5', NULL, N'125', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Plains Marketing, L.P.', N'Alta Oil Propane Co. Inc.', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (32, NULL, 19, 21, N'TR-876', 30, N'Aviation Gasoline', 41, N'51782', 1043, 1, CAST(9203.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9203.000000 AS Numeric(18, 6)), 5, CAST(36.812000 AS Numeric(18, 6)), N'', N'Inventory', N'Aviation Gasoline', N'Gasoline / Aviation ', N'SI-30809', CAST(9203.000000 AS Numeric(18, 6)), N'', N'51782', CAST(0x0000A56A00000000 AS DateTime), 1186, N'Pomona              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'5', NULL, N'125', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1043, N'', N'Truck', N'Transport Dynamics', N'20-1832037', N'Plains Marketing, L.P.', N'DLE61 POMONA', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (33, NULL, 19, 21, N'TR-875', 30, N'Aviation Gasoline', 1091, N'2491', 45, 1, CAST(8835.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8835.000000 AS Numeric(18, 6)), 5, CAST(35.340000 AS Numeric(18, 6)), N'', N'Inventory', N'Aviation Gasoline', N'Gasoline / Aviation ', N'SI-30808', CAST(8835.000000 AS Numeric(18, 6)), N'', N'2491', CAST(0x0000A56A00000000 AS DateTime), 1190, N'Sylmar              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'5', NULL, N'125', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Targa Liquids Marketing and Trade LLC', N'DLE81 SYLMAR', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (34, NULL, 19, 21, N'TR-874', 30, N'Aviation Gasoline', 43, N'489565', 45, 1, CAST(8970.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8970.000000 AS Numeric(18, 6)), 5, CAST(35.880000 AS Numeric(18, 6)), N'', N'Inventory', N'Aviation Gasoline', N'Gasoline / Aviation ', N'SI-30807', CAST(8970.000000 AS Numeric(18, 6)), N'', N'489565', CAST(0x0000A56B00000000 AS DateTime), 1186, N'Pomona              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'5', NULL, N'125', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE61 POMONA', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (35, NULL, 19, 21, N'TR-873', 30, N'Aviation Gasoline', 43, N'489494', 45, 1, CAST(8909.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8909.000000 AS Numeric(18, 6)), 5, CAST(35.636000 AS Numeric(18, 6)), N'', N'Inventory', N'Aviation Gasoline', N'Gasoline / Aviation ', N'SI-30806', CAST(8909.000000 AS Numeric(18, 6)), N'', N'489494', CAST(0x0000A56900000000 AS DateTime), 1186, N'Pomona              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'5', NULL, N'125', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE61 POMONA', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (36, NULL, 19, 21, N'TR-864', 30, N'Aviation Gasoline', 43, N'489509', 45, 1, CAST(8907.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8907.000000 AS Numeric(18, 6)), 5, CAST(35.628000 AS Numeric(18, 6)), N'', N'Inventory', N'Aviation Gasoline', N'Gasoline / Aviation ', N'SI-30798', CAST(8907.000000 AS Numeric(18, 6)), N'', N'489509', CAST(0x0000A56A00000000 AS DateTime), 1178, N'Los Angeles         ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'5', NULL, N'125', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE18 ARRO AUTOGAS', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (37, NULL, 19, 21, N'TR-863', 30, N'Aviation Gasoline', 23, N'77536', 45, 1, CAST(9539.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9539.000000 AS Numeric(18, 6)), 5, CAST(38.156000 AS Numeric(18, 6)), N'', N'Inventory', N'Aviation Gasoline', N'Gasoline / Aviation ', N'SI-30797', CAST(9539.000000 AS Numeric(18, 6)), N'', N'77536', CAST(0x0000A56B00000000 AS DateTime), 1172, N'Paso Robles         ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'5', NULL, N'125', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Crestwood West Coast LLC', N'DLE11 PASO ROBLES', N'38-3875473', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (38, NULL, 19, 21, N'TR-862', 30, N'Aviation Gasoline', 43, N'467352', 45, 1, CAST(9536.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9536.000000 AS Numeric(18, 6)), 5, CAST(38.144000 AS Numeric(18, 6)), N'', N'Inventory', N'Aviation Gasoline', N'Gasoline / Aviation ', N'SI-30796', CAST(9536.000000 AS Numeric(18, 6)), N'', N'467352', CAST(0x0000A56B00000000 AS DateTime), 1172, N'Paso Robles         ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'5', NULL, N'125', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE11 PASO ROBLES', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (39, NULL, 19, 21, N'TR-859', 30, N'Aviation Gasoline', 23, N'A68153', 45, 1, CAST(9381.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9381.000000 AS Numeric(18, 6)), 5, CAST(37.524000 AS Numeric(18, 6)), N'', N'Inventory', N'Aviation Gasoline', N'Gasoline / Aviation ', N'SI-30793', CAST(9381.000000 AS Numeric(18, 6)), N'', N'A68153', CAST(0x0000A56A00000000 AS DateTime), 2336, N'Visalia', N'CA', 11, 14, NULL, N'MF-360', NULL, N'5', NULL, N'125', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Crestwood West Coast LLC', N'Calaveras Materials Inc Subsidiary of Lehigh Hanson', N'38-3875473', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (40, NULL, 19, 21, N'TR-859', 30, N'Aviation Gasoline', 23, N'A68153', 45, 1, CAST(9381.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9381.000000 AS Numeric(18, 6)), 5, CAST(37.524000 AS Numeric(18, 6)), N'', N'Inventory', N'Aviation Gasoline', N'Gasoline / Aviation ', N'SI-30793', CAST(9381.000000 AS Numeric(18, 6)), N'', N'A68153', CAST(0x0000A56A00000000 AS DateTime), 2336, N'Visalia', N'CA', 11, 14, NULL, N'MF-360', NULL, N'5', NULL, N'125', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Crestwood West Coast LLC', N'Calaveras Materials Inc Subsidiary of Lehigh Hanson', N'38-3875473', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (41, NULL, 28, 21, N'TR-880', 29, N'Methanol (11%)', 41, N'83817', 45, 1, CAST(9593.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9593.000000 AS Numeric(18, 6)), 5, CAST(38.372000 AS Numeric(18, 6)), N'', N'Inventory', N'Methanol (11%)', N'Gasoline / Aviation ', N'SI-30813', CAST(9593.000000 AS Numeric(18, 6)), N'', N'83817', CAST(0x0000A56800000000 AS DateTime), 1116, N'Reedley             ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'7MI', NULL, N'M11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Plains Marketing, L.P.', N'Alta Oil Propane Co. Inc.', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (42, NULL, 28, 21, N'TR-876', 29, N'Methanol (11%)', 41, N'51782', 1043, 1, CAST(9203.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9203.000000 AS Numeric(18, 6)), 5, CAST(36.812000 AS Numeric(18, 6)), N'', N'Inventory', N'Methanol (11%)', N'Gasoline / Aviation ', N'SI-30809', CAST(9203.000000 AS Numeric(18, 6)), N'', N'51782', CAST(0x0000A56A00000000 AS DateTime), 1186, N'Pomona              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'7MI', NULL, N'M11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1043, N'', N'Truck', N'Transport Dynamics', N'20-1832037', N'Plains Marketing, L.P.', N'DLE61 POMONA', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (43, NULL, 28, 21, N'TR-875', 29, N'Methanol (11%)', 1091, N'2491', 45, 1, CAST(8835.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8835.000000 AS Numeric(18, 6)), 5, CAST(35.340000 AS Numeric(18, 6)), N'', N'Inventory', N'Methanol (11%)', N'Gasoline / Aviation ', N'SI-30808', CAST(8835.000000 AS Numeric(18, 6)), N'', N'2491', CAST(0x0000A56A00000000 AS DateTime), 1190, N'Sylmar              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'7MI', NULL, N'M11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Targa Liquids Marketing and Trade LLC', N'DLE81 SYLMAR', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (44, NULL, 28, 21, N'TR-874', 29, N'Methanol (11%)', 43, N'489565', 45, 1, CAST(8970.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8970.000000 AS Numeric(18, 6)), 5, CAST(35.880000 AS Numeric(18, 6)), N'', N'Inventory', N'Methanol (11%)', N'Gasoline / Aviation ', N'SI-30807', CAST(8970.000000 AS Numeric(18, 6)), N'', N'489565', CAST(0x0000A56B00000000 AS DateTime), 1186, N'Pomona              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'7MI', NULL, N'M11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE61 POMONA', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (45, NULL, 28, 21, N'TR-873', 29, N'Methanol (11%)', 43, N'489494', 45, 1, CAST(8909.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8909.000000 AS Numeric(18, 6)), 5, CAST(35.636000 AS Numeric(18, 6)), N'', N'Inventory', N'Methanol (11%)', N'Gasoline / Aviation ', N'SI-30806', CAST(8909.000000 AS Numeric(18, 6)), N'', N'489494', CAST(0x0000A56900000000 AS DateTime), 1186, N'Pomona              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'7MI', NULL, N'M11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE61 POMONA', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (46, NULL, 28, 21, N'TR-864', 29, N'Methanol (11%)', 43, N'489509', 45, 1, CAST(8907.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8907.000000 AS Numeric(18, 6)), 5, CAST(35.628000 AS Numeric(18, 6)), N'', N'Inventory', N'Methanol (11%)', N'Gasoline / Aviation ', N'SI-30798', CAST(8907.000000 AS Numeric(18, 6)), N'', N'489509', CAST(0x0000A56A00000000 AS DateTime), 1178, N'Los Angeles         ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'7MI', NULL, N'M11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE18 ARRO AUTOGAS', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (47, NULL, 28, 21, N'TR-863', 29, N'Methanol (11%)', 23, N'77536', 45, 1, CAST(9539.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9539.000000 AS Numeric(18, 6)), 5, CAST(38.156000 AS Numeric(18, 6)), N'', N'Inventory', N'Methanol (11%)', N'Gasoline / Aviation ', N'SI-30797', CAST(9539.000000 AS Numeric(18, 6)), N'', N'77536', CAST(0x0000A56B00000000 AS DateTime), 1172, N'Paso Robles         ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'7MI', NULL, N'M11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Crestwood West Coast LLC', N'DLE11 PASO ROBLES', N'38-3875473', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (48, NULL, 28, 21, N'TR-862', 29, N'Methanol (11%)', 43, N'467352', 45, 1, CAST(9536.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9536.000000 AS Numeric(18, 6)), 5, CAST(38.144000 AS Numeric(18, 6)), N'', N'Inventory', N'Methanol (11%)', N'Gasoline / Aviation ', N'SI-30796', CAST(9536.000000 AS Numeric(18, 6)), N'', N'467352', CAST(0x0000A56B00000000 AS DateTime), 1172, N'Paso Robles         ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'7MI', NULL, N'M11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE11 PASO ROBLES', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (49, NULL, 28, 21, N'TR-859', 29, N'Methanol (11%)', 23, N'A68153', 45, 1, CAST(9381.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9381.000000 AS Numeric(18, 6)), 5, CAST(37.524000 AS Numeric(18, 6)), N'', N'Inventory', N'Methanol (11%)', N'Gasoline / Aviation ', N'SI-30793', CAST(9381.000000 AS Numeric(18, 6)), N'', N'A68153', CAST(0x0000A56A00000000 AS DateTime), 2336, N'Visalia', N'CA', 11, 14, NULL, N'MF-360', NULL, N'7MI', NULL, N'M11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Crestwood West Coast LLC', N'Calaveras Materials Inc Subsidiary of Lehigh Hanson', N'38-3875473', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (50, NULL, 28, 21, N'TR-859', 28, N'Methanol (11%)', 23, N'A68153', 45, 1, CAST(9381.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9381.000000 AS Numeric(18, 6)), 5, CAST(37.524000 AS Numeric(18, 6)), N'', N'Inventory', N'Methanol (11%)', N'Gasoline / Aviation ', N'SI-30793', CAST(9381.000000 AS Numeric(18, 6)), N'', N'A68153', CAST(0x0000A56A00000000 AS DateTime), 2336, N'Visalia', N'CA', 11, 14, NULL, N'MF-360', NULL, N'7MI', NULL, N'M11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Crestwood West Coast LLC', N'Calaveras Materials Inc Subsidiary of Lehigh Hanson', N'38-3875473', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (51, NULL, 31, 21, N'TR-880', 28, N'Methanol (100%)', 41, N'83817', 45, 1, CAST(9593.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9593.000000 AS Numeric(18, 6)), 5, CAST(38.372000 AS Numeric(18, 6)), N'', N'Inventory', N'Methanol (100%)', N'Gasoline / Aviation ', N'SI-30813', CAST(9593.000000 AS Numeric(18, 6)), N'', N'83817', CAST(0x0000A56800000000 AS DateTime), 1116, N'Reedley             ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'8', NULL, N'M00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Plains Marketing, L.P.', N'Alta Oil Propane Co. Inc.', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (52, NULL, 31, 21, N'TR-876', 28, N'Methanol (100%)', 41, N'51782', 1043, 1, CAST(9203.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9203.000000 AS Numeric(18, 6)), 5, CAST(36.812000 AS Numeric(18, 6)), N'', N'Inventory', N'Methanol (100%)', N'Gasoline / Aviation ', N'SI-30809', CAST(9203.000000 AS Numeric(18, 6)), N'', N'51782', CAST(0x0000A56A00000000 AS DateTime), 1186, N'Pomona              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'8', NULL, N'M00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1043, N'', N'Truck', N'Transport Dynamics', N'20-1832037', N'Plains Marketing, L.P.', N'DLE61 POMONA', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (53, NULL, 31, 21, N'TR-875', 28, N'Methanol (100%)', 1091, N'2491', 45, 1, CAST(8835.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8835.000000 AS Numeric(18, 6)), 5, CAST(35.340000 AS Numeric(18, 6)), N'', N'Inventory', N'Methanol (100%)', N'Gasoline / Aviation ', N'SI-30808', CAST(8835.000000 AS Numeric(18, 6)), N'', N'2491', CAST(0x0000A56A00000000 AS DateTime), 1190, N'Sylmar              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'8', NULL, N'M00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Targa Liquids Marketing and Trade LLC', N'DLE81 SYLMAR', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (54, NULL, 31, 21, N'TR-874', 28, N'Methanol (100%)', 43, N'489565', 45, 1, CAST(8970.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8970.000000 AS Numeric(18, 6)), 5, CAST(35.880000 AS Numeric(18, 6)), N'', N'Inventory', N'Methanol (100%)', N'Gasoline / Aviation ', N'SI-30807', CAST(8970.000000 AS Numeric(18, 6)), N'', N'489565', CAST(0x0000A56B00000000 AS DateTime), 1186, N'Pomona              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'8', NULL, N'M00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE61 POMONA', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (55, NULL, 31, 21, N'TR-873', 28, N'Methanol (100%)', 43, N'489494', 45, 1, CAST(8909.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8909.000000 AS Numeric(18, 6)), 5, CAST(35.636000 AS Numeric(18, 6)), N'', N'Inventory', N'Methanol (100%)', N'Gasoline / Aviation ', N'SI-30806', CAST(8909.000000 AS Numeric(18, 6)), N'', N'489494', CAST(0x0000A56900000000 AS DateTime), 1186, N'Pomona              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'8', NULL, N'M00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE61 POMONA', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (56, NULL, 31, 21, N'TR-864', 28, N'Methanol (100%)', 43, N'489509', 45, 1, CAST(8907.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8907.000000 AS Numeric(18, 6)), 5, CAST(35.628000 AS Numeric(18, 6)), N'', N'Inventory', N'Methanol (100%)', N'Gasoline / Aviation ', N'SI-30798', CAST(8907.000000 AS Numeric(18, 6)), N'', N'489509', CAST(0x0000A56A00000000 AS DateTime), 1178, N'Los Angeles         ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'8', NULL, N'M00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE18 ARRO AUTOGAS', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (57, NULL, 31, 21, N'TR-863', 28, N'Methanol (100%)', 23, N'77536', 45, 1, CAST(9539.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9539.000000 AS Numeric(18, 6)), 5, CAST(38.156000 AS Numeric(18, 6)), N'', N'Inventory', N'Methanol (100%)', N'Gasoline / Aviation ', N'SI-30797', CAST(9539.000000 AS Numeric(18, 6)), N'', N'77536', CAST(0x0000A56B00000000 AS DateTime), 1172, N'Paso Robles         ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'8', NULL, N'M00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Crestwood West Coast LLC', N'DLE11 PASO ROBLES', N'38-3875473', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (58, NULL, 31, 21, N'TR-862', 28, N'Methanol (100%)', 43, N'467352', 45, 1, CAST(9536.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9536.000000 AS Numeric(18, 6)), 5, CAST(38.144000 AS Numeric(18, 6)), N'', N'Inventory', N'Methanol (100%)', N'Gasoline / Aviation ', N'SI-30796', CAST(9536.000000 AS Numeric(18, 6)), N'', N'467352', CAST(0x0000A56B00000000 AS DateTime), 1172, N'Paso Robles         ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'8', NULL, N'M00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE11 PASO ROBLES', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (59, NULL, 31, 21, N'TR-859', 28, N'Methanol (100%)', 23, N'A68153', 45, 1, CAST(9381.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9381.000000 AS Numeric(18, 6)), 5, CAST(37.524000 AS Numeric(18, 6)), N'', N'Inventory', N'Methanol (100%)', N'Gasoline / Aviation ', N'SI-30793', CAST(9381.000000 AS Numeric(18, 6)), N'', N'A68153', CAST(0x0000A56A00000000 AS DateTime), 2336, N'Visalia', N'CA', 11, 14, NULL, N'MF-360', NULL, N'8', NULL, N'M00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Crestwood West Coast LLC', N'Calaveras Materials Inc Subsidiary of Lehigh Hanson', N'38-3875473', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (60, NULL, 31, 21, N'TR-859', 28, N'Methanol (100%)', 23, N'A68153', 45, 1, CAST(9381.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9381.000000 AS Numeric(18, 6)), 5, CAST(37.524000 AS Numeric(18, 6)), N'', N'Inventory', N'Methanol (100%)', N'Gasoline / Aviation ', N'SI-30793', CAST(9381.000000 AS Numeric(18, 6)), N'', N'A68153', CAST(0x0000A56A00000000 AS DateTime), 2336, N'Visalia', N'CA', 11, 14, NULL, N'MF-360', NULL, N'8', NULL, N'M00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Crestwood West Coast LLC', N'Calaveras Materials Inc Subsidiary of Lehigh Hanson', N'38-3875473', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (61, NULL, 34, 21, N'TR-880', 66, N'Gasoline', 41, N'83817', 45, 1, CAST(9593.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9593.000000 AS Numeric(18, 6)), 5, CAST(38.372000 AS Numeric(18, 6)), N'', N'Inventory', N'Gasoline', N'Gasoline / Aviation ', N'SI-30813', CAST(9593.000000 AS Numeric(18, 6)), N'', N'83817', CAST(0x0000A56800000000 AS DateTime), 1116, N'Reedley             ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'10A', NULL, N'065', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Plains Marketing, L.P.', N'Alta Oil Propane Co. Inc.', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (62, NULL, 34, 21, N'TR-876', 66, N'Gasoline', 41, N'51782', 1043, 1, CAST(9203.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9203.000000 AS Numeric(18, 6)), 5, CAST(36.812000 AS Numeric(18, 6)), N'', N'Inventory', N'Gasoline', N'Gasoline / Aviation ', N'SI-30809', CAST(9203.000000 AS Numeric(18, 6)), N'', N'51782', CAST(0x0000A56A00000000 AS DateTime), 1186, N'Pomona              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'10A', NULL, N'065', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1043, N'', N'Truck', N'Transport Dynamics', N'20-1832037', N'Plains Marketing, L.P.', N'DLE61 POMONA', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (63, NULL, 34, 21, N'TR-875', 66, N'Gasoline', 1091, N'2491', 45, 1, CAST(8835.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8835.000000 AS Numeric(18, 6)), 5, CAST(35.340000 AS Numeric(18, 6)), N'', N'Inventory', N'Gasoline', N'Gasoline / Aviation ', N'SI-30808', CAST(8835.000000 AS Numeric(18, 6)), N'', N'2491', CAST(0x0000A56A00000000 AS DateTime), 1190, N'Sylmar              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'10A', NULL, N'065', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Targa Liquids Marketing and Trade LLC', N'DLE81 SYLMAR', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (64, NULL, 34, 21, N'TR-874', 66, N'Gasoline', 43, N'489565', 45, 1, CAST(8970.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8970.000000 AS Numeric(18, 6)), 5, CAST(35.880000 AS Numeric(18, 6)), N'', N'Inventory', N'Gasoline', N'Gasoline / Aviation ', N'SI-30807', CAST(8970.000000 AS Numeric(18, 6)), N'', N'489565', CAST(0x0000A56B00000000 AS DateTime), 1186, N'Pomona              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'10A', NULL, N'065', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE61 POMONA', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (65, NULL, 34, 21, N'TR-873', 66, N'Gasoline', 43, N'489494', 45, 1, CAST(8909.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8909.000000 AS Numeric(18, 6)), 5, CAST(35.636000 AS Numeric(18, 6)), N'', N'Inventory', N'Gasoline', N'Gasoline / Aviation ', N'SI-30806', CAST(8909.000000 AS Numeric(18, 6)), N'', N'489494', CAST(0x0000A56900000000 AS DateTime), 1186, N'Pomona              ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'10A', NULL, N'065', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE61 POMONA', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (66, NULL, 34, 21, N'TR-864', 66, N'Gasoline', 43, N'489509', 45, 1, CAST(8907.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(8907.000000 AS Numeric(18, 6)), 5, CAST(35.628000 AS Numeric(18, 6)), N'', N'Inventory', N'Gasoline', N'Gasoline / Aviation ', N'SI-30798', CAST(8907.000000 AS Numeric(18, 6)), N'', N'489509', CAST(0x0000A56A00000000 AS DateTime), 1178, N'Los Angeles         ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'10A', NULL, N'065', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE18 ARRO AUTOGAS', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (67, NULL, 34, 21, N'TR-863', 66, N'Gasoline', 23, N'77536', 45, 1, CAST(9539.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9539.000000 AS Numeric(18, 6)), 5, CAST(38.156000 AS Numeric(18, 6)), N'', N'Inventory', N'Gasoline', N'Gasoline / Aviation ', N'SI-30797', CAST(9539.000000 AS Numeric(18, 6)), N'', N'77536', CAST(0x0000A56B00000000 AS DateTime), 1172, N'Paso Robles         ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'10A', NULL, N'065', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Crestwood West Coast LLC', N'DLE11 PASO ROBLES', N'38-3875473', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (68, NULL, 34, 21, N'TR-862', 66, N'Gasoline', 43, N'467352', 45, 1, CAST(9536.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9536.000000 AS Numeric(18, 6)), 5, CAST(38.144000 AS Numeric(18, 6)), N'', N'Inventory', N'Gasoline', N'Gasoline / Aviation ', N'SI-30796', CAST(9536.000000 AS Numeric(18, 6)), N'', N'467352', CAST(0x0000A56B00000000 AS DateTime), 1172, N'Paso Robles         ', N'CA', 11, 14, NULL, N'MF-360', NULL, N'10A', NULL, N'065', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Enterprise Products Operating LLC', N'DLE11 PASO ROBLES', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (69, NULL, 34, 21, N'TR-859', 66, N'Gasoline', 23, N'A68153', 45, 1, CAST(9381.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9381.000000 AS Numeric(18, 6)), 5, CAST(37.524000 AS Numeric(18, 6)), N'', N'Inventory', N'Gasoline', N'Gasoline / Aviation ', N'SI-30793', CAST(9381.000000 AS Numeric(18, 6)), N'', N'A68153', CAST(0x0000A56A00000000 AS DateTime), 2336, N'Visalia', N'CA', 11, 14, NULL, N'MF-360', NULL, N'10A', NULL, N'065', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Crestwood West Coast LLC', N'Calaveras Materials Inc Subsidiary of Lehigh Hanson', N'38-3875473', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		INSERT [dbo].[tblTFTransactions] ([intTransactionId], [uniqTransactionGuid], [intReportingComponentDetailId], [intItemMotorFuelTaxId], [strActualCostId], [intProductCodeId], [strItemNo], [intEntityVendorId], [strBillOfLading], [intShipViaId], [intItemId], [dblReceived], [dblGross], [dblNet], [intTaxCodeId], [dblTax], [strShortName], [strType], [strDescription], [strFuelType], [strInvoiceNumber], [dblQtyShipped], [strPONumber], [strBOLNumber], [dtmDate], [intEntityCustomerId], [strShipToCity], [strShipToState], [intCompanyLocationId], [intTaxAuthorityId], [strTaxAuthority], [strFormCode], [strFormName], [strScheduleCode], [strScheduleName], [strProductCode], [strProductCodeDescription], [strTaxCode], [strTaxClass], [intSupplierId], [strSupplierName], [strItem], [dtmLastRun], [dtmReportingPeriodBegin], [dtmReportingPeriodEnd], [strTaxPayerName], [strLicenseNumber], [strEmail], [strFEINSSN], [strCity], [strState], [strZipCode], [strTelephoneNumber], [strContactName], [intEntityShipViaId], [strTransporterLicense], [strTransportationMode], [strShipVia], [strFederalId], [strVendorName], [strCustomerName], [strVendorFederalTaxId], [strCustomerFederalTaxId], [strVendorLicenseNumber], [strOriginTCN], [strOriginCity], [strOriginState], [strDestinationTCN], [dblBillQty], [leaf], [intConcurrencyId]) VALUES (70, NULL, 34, 21, N'TR-859', 66, N'Gasoline', 23, N'A68153', 45, 1, CAST(9381.000000 AS Numeric(18, 6)), CAST(9500.000000 AS Numeric(18, 6)), CAST(9381.000000 AS Numeric(18, 6)), 5, CAST(37.524000 AS Numeric(18, 6)), N'', N'Inventory', N'Gasoline', N'Gasoline / Aviation ', N'SI-30793', CAST(9381.000000 AS Numeric(18, 6)), N'', N'A68153', CAST(0x0000A56A00000000 AS DateTime), 2336, N'Visalia', N'CA', 11, 14, NULL, N'MF-360', NULL, N'10A', NULL, N'065', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 45, N'', N'', N'AePEX ENERGY Trucking', N'', N'Crestwood West Coast LLC', N'Calaveras Materials Inc Subsidiary of Lehigh Hanson', N'38-3875473', N'', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
		SET IDENTITY_INSERT [dbo].[tblTFTransactions] OFF

		--REPORT GENERATION TEMPLATE
		DECLARE @intReportingComponentId INT
		SELECT @intReportingComponentId = intReportingComponentId FROM tblTFReportingComponent WHERE strScheduleName = 'Main Form' AND strFormCode = 'MF-360'
		IF (@intReportingComponentId IS NOT NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', @intTaxAuthorityId, N'IN', N'1', 0, 0, N'Filing Type', N'', NULL, NULL, NULL, N'Filing Type', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-001', N'MF-360', @intTaxAuthorityId, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 1, 1, N'1. Total receipts (From Section A, Line 8, Column D on back of return)', N'1A,2,2K,2X,3,4', NULL, N'details', N'sum', N'Summary', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-002', N'MF-360', @intTaxAuthorityId, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 2, 2, N'2. Total non-taxable disbursements (From Section B, Line 10, Column D on back of return)', N'11,6D,6X,7,8,10A,10B', NULL, NULL, NULL, N'Summary', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-003', N'MF-360', @intTaxAuthorityId, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 3, 3, N'3. Gallons received, gasoline tax paid (From Section A, Line 1, Column A on back of return)', N'1A', NULL, NULL, NULL, N'Summary', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-004', N'MF-360', @intTaxAuthorityId, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 4, 4, N'4.  Billed taxable gallons (Line 1 minus Line 2 minus Line 3)', N'1,2,3', NULL, NULL, NULL, N'Summary', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (@intReportingComponentId, N'MF-360-Summary-005', N'MF-360', @intTaxAuthorityId, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 5, 5, N'5. Licensed gasoline distributor deduction (Multiply Line 4 by 0.016)', N'4', N'0.016', N'', N'', N'Summary', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-006', N'MF-360', @intTaxAuthorityId, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 6, 6, N'6. Billed taxable gallons (Line 4 minus Line 5)', N'4,5', NULL, NULL, NULL, N'Summary', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (@intReportingComponentId, N'MF-360-Summary-007', N'MF-360', @intTaxAuthorityId, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 7, 7, N'7 Gasoline tax due (Multiply Line 6 by $0.18)', N'6', N'0.18', N'', N'', N'Summary', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-008', N'MF-360', @intTaxAuthorityId, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 8, 8, N'8. Adjustments (Schedule E-1 must be attached and is subject to Department approval)', N'0', NULL, N'', N'', N'Summary', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-009', N'MF-360', @intTaxAuthorityId, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 9, 9, N'9. Total gasoline tax due (Line 7 plus or minus Line 8)', N'7,8', NULL, NULL, NULL, N'Summary', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-010', N'MF-360', @intTaxAuthorityId, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 1, 10, N'1. Total receipts (From Section A, Line 9, Coumn D on back of return)', N'1A,2,2K,2X,3,4', NULL, N'', N'', N'Summary', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-011', N'MF-360', @intTaxAuthorityId, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 2, 11, N'2. Total non-taxable disbursements (From Section B, Line 11, Column D on back of return)', N'11,6D,6X,7,8', NULL, N'', N'', N'Summary', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-012', N'MF-360', @intTaxAuthorityId, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 3, 12, N'3. Gallons received, oil inspection fee paid (From Section A, Line 1, Column D on back of return)', N'1A', NULL, NULL, NULL, N'Summary', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-013', N'MF-360', @intTaxAuthorityId, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 4, 13, N'4. Billed taxable gallons (Line 1 minus Line 2 minus Line 3)', N'10,11,12', NULL, NULL, NULL, N'Summary', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (@intReportingComponentId, N'MF-360-Summary-014', N'MF-360', @intTaxAuthorityId, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 5, 14, N'5. Oil inspection fees due (Multiply Line 4 by $0.01)', N'13', N'0.01', N'', N'', N'Summary', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-015', N'MF-360', @intTaxAuthorityId, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 6, 15, N'6. Adjustments (Schedule E-1 must be attached and is subject to Department approval)', N'15', NULL, NULL, NULL, N'Summary', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-016', N'MF-360', @intTaxAuthorityId, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 7, 16, N'7. Total oil inspection fees due (Line 5 plus or minus Line 6)', N'14,15', NULL, NULL, NULL, N'Summary', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-017', N'MF-360', @intTaxAuthorityId, N'IN', N'Section 4:    Calculation of Total Amount Due', 1, 17, N'1. Total amount due (Section 2, Line 9 plus Section 3, Line 7)', N'9,16', NULL, NULL, NULL, N'Summary', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-018', N'MF-360', @intTaxAuthorityId, N'IN', N'Section 4:    Calculation of Total Amount Due', 2, 18, N'2. Penalty (Penalty must be added if report is filed after the due date. 10% of tax due or $5.00, whichever is greater. Five dollars ($5.00) is due on a late report showing no tax due.)', N'18', NULL, NULL, NULL, N'Summary', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-019', N'MF-360', @intTaxAuthorityId, N'IN', N'Section 4:    Calculation of Total Amount Due', 3, 19, N'3. Interest (Interest must be added if report is filed after the due date. Contact the Department for daily interest rates.)', NULL, NULL, NULL, NULL, N'Summary', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-020', N'MF-360', @intTaxAuthorityId, N'IN', N'Section 4:    Calculation of Total Amount Due', 4, 20, N'4. Net tax due (Line 1 plus Line 2 plus Line 3)', N'17,18,19', NULL, NULL, NULL, N'Summary', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-021', N'MF-360', @intTaxAuthorityId, N'IN', N'Section 4:    Calculation of Total Amount Due', 5, 21, N'5. Payment(s)', NULL, NULL, NULL, NULL, N'Summary', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-022', N'MF-360', @intTaxAuthorityId, N'IN', N'Section 4:    Calculation of Total Amount Due', 6, 22, N'6. Balance due (Line 4 minus Line 5)', N'20,21', NULL, NULL, NULL, N'Summary', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, N'MF-360-Summary-023', N'MF-360', @intTaxAuthorityId, N'IN', N'Section 4:    Calculation of Total Amount Due', 7, 7, N'7. Gallons of gasoline sold to taxable marina', NULL, NULL, NULL, NULL, N'Summary', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', @intTaxAuthorityId, N'IN', N'Section A: Receipts', 1, 1, N'1. Gallons received, gasoline tax or inspection fee paid', N'1A', NULL, NULL, NULL, N'Details', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', @intTaxAuthorityId, N'IN', N'Section A: Receipts', 2, 2, N'2. Gallons received from licensed distributors or oil inspection distributors, tax unpaid', N'2', NULL, NULL, NULL, N'Details', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', @intTaxAuthorityId, N'IN', N'Section A: Receipts', 3, 3, N'3. Gallons of non-taxable fuel received and sold or used for a taxable purpose', N'2K', NULL, NULL, NULL, N'Details', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', @intTaxAuthorityId, N'IN', N'Section A: Receipts', 4, 4, N'4. Gallons received from licensed distributors on exchange agreements, tax unpaid', N'2X', NULL, NULL, NULL, N'Details', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', @intTaxAuthorityId, N'IN', N'Section A: Receipts', 5, 5, N'5. Gallons imported directly to customer', N'3', NULL, NULL, NULL, N'Details', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', @intTaxAuthorityId, N'IN', N'Section A: Receipts', 6, 6, N'6. Gallons imported directly to customer', N'4', NULL, NULL, NULL, N'Details', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', @intTaxAuthorityId, N'IN', N'Section A: Receipts', 7, 7, N'7. Diversions into Indiana', N'11', NULL, NULL, NULL, N'Details', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', @intTaxAuthorityId, N'IN', N'Section A: Receipts', 8, 8, N'8. Total receipts - add Lines 1-7, carry total(Column D) to Section 2, Line 1 on front', N'1A,2,2K,2X,3,4', NULL, NULL, NULL, N'Details', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', @intTaxAuthorityId, N'IN', N'Section A: Receipts', 9, 9, N'9. Total Receipts - add Lines 1-7, carry total (Column D) to Section 3, Line 1 on front', N'1A,2,2K,2X,3,4', NULL, NULL, NULL, N'Details', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', @intTaxAuthorityId, N'IN', N'Section B: Disbursement', 1, 10, N'1. Gallons delivered, tax collected', N'5', NULL, NULL, NULL, N'Details', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', @intTaxAuthorityId, N'IN', N'Section B: Disbursement', 2, 11, N'2. Diversion out of Indiana', N'11', NULL, NULL, NULL, N'Details', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', @intTaxAuthorityId, N'IN', N'Section B: Disbursement', 3, 12, N'3. Gallons sold to licensed distributors, tax not collected', N'6D', NULL, NULL, NULL, N'Details', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', @intTaxAuthorityId, N'IN', N'Section B: Disbursement', 4, 13, N'4. Gallons disbursed on exchange', N'6X', NULL, NULL, NULL, N'Details', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', @intTaxAuthorityId, N'IN', N'Section B: Disbursement', 5, 14, N'5. Gallons exported (must be filed in duplicate)', N'7', NULL, NULL, NULL, N'Details', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', @intTaxAuthorityId, N'IN', N'Section B: Disbursement', 6, 15, N'6. Gallons delivered to U.S. Government - tax exempt', N'8', NULL, NULL, NULL, N'Details', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', @intTaxAuthorityId, N'IN', N'Section B: Disbursement', 7, 16, N'7 Gallons delivered to licensed marina fuel dealers', N'10A', NULL, NULL, NULL, N'Details', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', @intTaxAuthorityId, N'IN', N'Section B: Disbursement', 8, 17, N'8. Gallons delivered to licensed aviation fuel dealers', N'10B', NULL, NULL, NULL, N'Details', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', @intTaxAuthorityId, N'IN', N'Section B: Disbursement', 9, 18, N'9. Miscelleaneous deduction - theft/loss', N'E-1', NULL, NULL, NULL, N'Details', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', @intTaxAuthorityId, N'IN', N'Section B: Disbursement', 10, 19, N'9a. Miscellaneous deduction - off road, other', N'E-1', NULL, NULL, NULL, N'Details', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', @intTaxAuthorityId, N'IN', N'Section B: Disbursement', 11, 20, N'10. Total non-taxable disbursements - add Lines 2-9a, carry total to Section 2, line 2 on front.', N'11,6D,6X,7,8,10A,10B', NULL, NULL, NULL, N'Details', 0)
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentDetailId], [intTaxReportSummaryItemId], [strSummaryFormCode], [intSummaryTaxAuthorityId], [strSummaryTaxAuthority], [strSummarySection], [intSummaryItemSequenceNumber], [intSummaryItemNumber], [strSummaryItemDescription], [strSummaryScheduleCode], [strConfiguration], [strSummaryPart], [strSummaryOperation], [strTaxType], [intConcurrencyId]) VALUES (NULL, NULL, N'MF-360', @intTaxAuthorityId, N'IN', N'Section B: Disbursement', 12, 21, N'11. Total non-taxable disbursements - add Lines 2-6, carry total to Section 3, line 2 on front', N'11,6D,6X,7,8', NULL, NULL, NULL, N'Details', 0)
		END
	END
END
GO
PRINT 'END TF Reporting Component'
GO
