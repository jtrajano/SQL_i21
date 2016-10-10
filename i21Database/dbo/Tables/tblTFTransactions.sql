﻿CREATE TABLE [dbo].[tblTFTransactions](
	[intTransactionId] [int] IDENTITY(1,1) NOT NULL,
	[uniqTransactionGuid] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL,
	[intReportingComponentId] [int] NULL,
	[intTaxAuthorityId] [int] NULL,
	[strTaxAuthority] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strFormCode] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strFormName] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strScheduleCode] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strScheduleName] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[intProductCodeId] [int] NULL,
	[strProductCode] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strProductCodeDescription] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strTaxCode] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strType] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strItemNo] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strBillOfLading] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intItemId] [int] NULL,
	[dblReceived] [numeric](18, 6) NULL,
	[dblGross] [numeric](18, 6) NULL,
	[dblNet] [numeric](18, 6) NULL,
	[dblBillQty] [numeric](18, 6) NULL,
	[dblTax] [numeric](18, 6) NULL,
	[dblTaxExempt] [numeric](18, 6) NULL,
	[strInvoiceNumber] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[dblQtyShipped] [numeric](18, 6) NULL,
	[strPONumber] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strBOLNumber] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strTerminalControlNumber] [nvarchar](30) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate] [datetime] NULL,
	[strShipToCity] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strShipToState] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strSupplierName] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[strItem] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[dtmLastRun] [datetime] NULL,
	[dtmReportingPeriodBegin] [datetime] NULL,
	[dtmReportingPeriodEnd] [datetime] NULL,
	[strLicenseNumber] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strEmail] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[strFEINSSN] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strCity] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strState] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strZipCode] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strTelephoneNumber] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strContactName] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL,
	[strShipVia] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[strTransporterName] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[strTransportationMode] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strTransporterFederalTaxId] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strTransporterLicense] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strCustomerName] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[strCustomerFederalTaxId] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strVendorName] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[strVendorFederalTaxId] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strVendorLicenseNumber] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strConsignorName] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[strConsignorFederalTaxId] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strDestinationState] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strDestinationCity] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strDestinationTCN] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strOriginState] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strOriginCity] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strOriginTCN] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strFuelType] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerName] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerIdentificationNumber] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerFEIN] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerDBA] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerAddress] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[leaf] [bit] NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblDummyTransaction] PRIMARY KEY CLUSTERED 
(
	[intTransactionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblTFTransactions] ADD  CONSTRAINT [DF_tblTFTransactions_intConcurrencyId]  DEFAULT ((1)) FOR [intConcurrencyId]
GO