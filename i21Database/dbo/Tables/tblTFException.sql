﻿CREATE TABLE [dbo].[tblTFException]
(
	[intExceptionId] INT IDENTITY NOT NULL,
	[intReportingComponentId] INT NOT NULL,
	[strExceptionType] NVARCHAR(50) NOT NULL,
	[strTransactionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intTransactionNumberId] INT NULL,
	[dtmDate] DATETIME NULL,
	[intProductCodeId] INT NULL,
	[strProductCode] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strProductCodeDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strTaxCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intItemId] INT NULL,
	[strItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strBillOfLading] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dblReceived] NUMERIC(18, 6) DEFAULT((0)) NULL,
	[dblGross] NUMERIC(18, 6) DEFAULT((0)) NULL,
	[dblNet] NUMERIC(18, 6) DEFAULT((0)) NULL,
	[dblBillQty] NUMERIC(18, 6) DEFAULT((0)) NULL,
	[dblTax] NUMERIC(18, 6) DEFAULT((0)) NULL,
	[dblTaxExempt] NUMERIC(18, 6) DEFAULT((0)) NULL,
	[dblQtyShipped] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strInvoiceNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strPONumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strTerminalControlNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strShipToCity] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strShipToState] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strSupplierName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strLicenseNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strEmail] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strFEINSSN] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
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
	[strFuelType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerIdentificationNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerFEIN] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerDBA] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerAddress] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[dtmLastRun] DATETIME NULL,
	[ysnDeleted] BIT DEFAULT((0)) NULL,
	[intConcurrencyId] INT DEFAULT((1)) NULL,
    CONSTRAINT [PK_tblTFException] PRIMARY KEY ([intExceptionId]) 
)
