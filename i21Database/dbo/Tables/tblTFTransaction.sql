﻿CREATE TABLE [dbo].[tblTFTransaction](
	[intTransactionId] INT IDENTITY NOT NULL,
	[uniqTransactionGuid] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	[intReportingComponentId] INT NULL,
	[intTaxAuthorityId] INT NULL,
	[strTaxAuthority] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strFormCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strFormName] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strScheduleCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strScheduleName] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[intProductCodeId] INT NULL,
	[strProductCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strProductCodeDescription] NVARCHAR(max) COLLATE Latin1_General_CI_AS NULL,
	[strTaxCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strType] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] NVARCHAR(max) COLLATE Latin1_General_CI_AS NULL,
	[strItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strBillOfLading] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intItemId] INT NULL,
	[dblReceived] NUMERIC(18, 6) NULL,
	[dblGross] NUMERIC(18, 6) NULL,
	[dblNet] NUMERIC(18, 6) NULL,
	[dblBillQty] NUMERIC(18, 6) NULL,
	[dblTax] NUMERIC(18, 6) NULL,
	[dblTaxExempt] NUMERIC(18, 6) NULL,
	[strInvoiceNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dblQtyShipped] NUMERIC(18, 6) NULL,
	[strPONumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strBOLNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strTerminalControlNumber] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate] DATETIME NULL,
	[strShipToCity] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strShipToState] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strSupplierName] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strItem] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dtmLastRun] DATETIME NULL,
	[dtmReportingPeriodBegin] DATETIME NULL,
	[dtmReportingPeriodEnd] DATETIME NULL,
	[strLicenseNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strEmail] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strFEINSSN] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strCity] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strState] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strZipCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strTelephoneNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strContactName] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	[strShipVia] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strTransporterName] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strTransportationMode] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strTransporterFederalTaxId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strTransporterLicense] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strCustomerName] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strCustomerFederalTaxId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strVendorName] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strVendorFederalTaxId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strVendorLicenseNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strConsignorName] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strConsignorFederalTaxId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strDestinationState] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strDestinationCity] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strDestinationTCN] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strOriginState] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strOriginCity] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strOriginTCN] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strFuelType] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerName] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerIdentificationNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerFEIN] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerDBA] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerAddress] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[intIntegrationError] INT,
	[leaf] BIT NULL,
	[intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblTFTransaction] PRIMARY KEY ([intTransactionId]), 
    CONSTRAINT [FK_tblTFTransaction_tblTFReportingComponent] FOREIGN KEY ([intReportingComponentId]) REFERENCES [tblTFReportingComponent]([intReportingComponentId]), 
    CONSTRAINT [FK_tblTFTransaction_tblTFProductCode] FOREIGN KEY ([intProductCodeId]) REFERENCES [tblTFProductCode]([intProductCodeId])
)

GO