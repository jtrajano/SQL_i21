﻿CREATE TABLE [dbo].[tblTRSupplyPoint]
(
	[intSupplyPointId] INT NOT NULL IDENTITY,
	[intEntityVendorId] INT NOT NULL,		
	[intEntityLocationId] INT NOT NULL,	
	[intTerminalControlNumberId] INT NULL,
	[strGrossOrNet] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strFuelDealerId1] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strFuelDealerId2] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strDefaultOrigin] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[ysnMultipleDueDates]  BIT  DEFAULT ((0)) NOT NULL,
    [ysnMultipleBolInvoiced]  BIT  DEFAULT ((0)) NOT NULL,
	[intRackPriceSupplyPointId] INT NULL,
	[guiApiUniqueId] UNIQUEIDENTIFIER NULL,
	[intConcurrencyId] [int] NOT NULL,
	[strFreightSalesUnit] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	CONSTRAINT [PK_tblTRSupplyPoint] PRIMARY KEY ([intSupplyPointId]),
	CONSTRAINT [AK_tblTRSupplyPoint_intEntityVendorId_intEntityLocationId] UNIQUE ([intEntityVendorId],[intEntityLocationId]),
	CONSTRAINT [FK_tblTRSupplyPoint_tblAPVendor_intEntityVendorId] FOREIGN KEY (intEntityVendorId) REFERENCES [dbo].[tblAPVendor] (intEntityId),
	CONSTRAINT [FK_tblTRSupplyPoint_tblEMEntityLocation_intEntityLocationId] FOREIGN KEY ([intEntityLocationId]) REFERENCES [dbo].[tblEMEntityLocation] ([intEntityLocationId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblTRSupplyPoint_tblTFTerminalControlNumber_intTerminalControlNumberId] FOREIGN KEY (intTerminalControlNumberId) REFERENCES [dbo].[tblTFTerminalControlNumber] (intTerminalControlNumberId)
)
