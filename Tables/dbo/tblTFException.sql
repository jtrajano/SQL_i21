CREATE TABLE [dbo].[tblTFException]
(
	[intExceptionId] INT IDENTITY NOT NULL,
	[intReportingComponentId] INT NOT NULL,
	[intTaxAuthorityId] INT NULL,
	[strExceptionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strTransactionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intTransactionNumberId] INT NULL,
	[strReason] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate] DATETIME NULL,
	[intProductCodeId] INT NULL,
	[strProductCode] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strProductCodeDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strTaxCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intItemId] INT NULL,
	[strBillOfLading] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dblReceived] NUMERIC(18, 6) DEFAULT((0)) NULL,
	[dblGross] NUMERIC(18, 6) DEFAULT((0)) NULL,
	[dblNet] NUMERIC(18, 6) DEFAULT((0)) NULL,
	[dblBillQty] NUMERIC(18, 6) DEFAULT((0)) NULL,
	[dblTax] NUMERIC(18, 6) DEFAULT((0)) NULL,
	[dblTaxExempt] NUMERIC(18, 6) DEFAULT((0)) NULL,
	[dblQtyShipped] NUMERIC(18, 6) DEFAULT((0)) NULL,
	[strInvoiceNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strPONumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strTerminalControlNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strCity] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strState] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strZipCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strTelephoneNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strContactName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strShipVia] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strTransporterName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strTransportationMode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strTransporterFederalTaxId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strTransporterLicense] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strCustomerName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strCustomerFederalTaxId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strVendorName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strVendorFederalTaxId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strVendorLicenseNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strConsignorName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strConsignorFederalTaxId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strDestinationState] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strDestinationCity] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strDestinationCounty] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strDestinationTCN] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strOriginState] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strOriginCity] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strOriginCounty] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strOriginTCN] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerIdentificationNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerFEIN] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerDBA] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerAddress] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[dtmLastRun] DATETIME NULL,
	[ysnDeleted] BIT DEFAULT((0)) NULL,
	[intConcurrencyId] INT DEFAULT((1)) NULL,
	[intUserEntityId] INT NULL,
	[dtmCreatedDate] DATETIME NULL,
    [intVendorId] INT NULL, 
    [intCustomerId] INT NULL, 
    [intTransporterId] INT NULL,
	[strTransactionSource] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,	
	[strTransportNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblTFException] PRIMARY KEY ([intExceptionId]),
	CONSTRAINT [FK_tblTFException_tblEMEntity] FOREIGN KEY ([intUserEntityId]) REFERENCES [tblEMEntity]([intEntityId])
)
GO

CREATE INDEX [IX_tblTFException_intUserEntityId] ON [dbo].[tblTFException] ([intUserEntityId])
GO

CREATE INDEX [IX_tblTFException_intReportingComponentId] ON [dbo].[tblTFException] ([intReportingComponentId])
GO

CREATE INDEX [IX_tblTFException_intTaxAuthorityId] ON [dbo].[tblTFException] ([intTaxAuthorityId])
GO

CREATE INDEX [IX_tblTFException_intTransactionNumberId] ON [dbo].[tblTFException] ([intTransactionNumberId])
GO

CREATE INDEX [IX_tblTFException_intProductCodeId] ON [dbo].[tblTFException] ([intProductCodeId])
GO

CREATE INDEX [IX_tblTFException_intItemId] ON [dbo].[tblTFException] ([intItemId])
GO

CREATE INDEX [IX_tblTFException_intVendorId] ON [dbo].[tblTFException] ([intVendorId])
GO

CREATE INDEX [IX_tblTFException_intCustomerId] ON [dbo].[tblTFException] ([intCustomerId])
GO

CREATE INDEX [IX_tblTFException_intTransporterId] ON [dbo].[tblTFException] ([intTransporterId])
GO




