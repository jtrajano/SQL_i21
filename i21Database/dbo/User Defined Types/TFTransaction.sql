﻿CREATE TYPE [dbo].[TFTransaction] AS TABLE(
	[intId] [int] IDENTITY(1,1) NOT NULL,
	[intInventoryReceiptItemId] [int] NULL,
	[intTaxAuthorityId] [int] NULL,
	[strFormCode] [nvarchar](20) NULL,
	[intReportingComponentId] [int] NULL,
	[strScheduleCode] [nvarchar](20) NULL,
	[strType] [nvarchar](150) NULL,
	[strProductCode] [nvarchar](20) NULL,
	[strBillOfLading] [nvarchar](100) NULL,
	[dblReceived] [numeric](18, 2) NULL,
	[dblGross] [numeric](18, 2) NULL,
	[dblNet] [numeric](18, 2) NULL,
	[dblBillQty] [numeric](18, 2) NULL,
	[dtmReceiptDate] [datetime] NULL,
	[strShipVia] [nvarchar](100) NULL,
	[strTransporterLicense] [nvarchar](50) NULL,
	[strTransportationMode] [nvarchar](200) NULL,
	[strVendorName] [nvarchar](250) NULL,
	[strTransporterName] [nvarchar](250) NULL,
	[strVendorFEIN] [nvarchar](50) NULL,
	[strTransporterFEIN] [nvarchar](50) NULL,
	[strHeaderCompanyName] [nvarchar](250) NULL,
	[strHeaderAddress] [nvarchar](max) NULL,
	[strHeaderCity] [nvarchar](50) NULL,
	[strHeaderState] [nvarchar](50) NULL,
	[strHeaderZip] [nvarchar](10) NULL,
	[strHeaderPhone] [nvarchar](50) NULL,
	[strHeaderStateTaxID] [nvarchar](50) NULL,
	[strHeaderFederalTaxID] [nvarchar](50) NULL,
	[strOriginState] [nvarchar](250) NULL,
	[strDestinationState] [nvarchar](250) NULL,
	[strTerminalControlNumber] [nvarchar](30) NULL
)