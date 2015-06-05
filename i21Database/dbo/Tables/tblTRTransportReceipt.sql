﻿CREATE TABLE [dbo].[tblTRTransportReceipt]
(
	[intTransportReceiptId] INT NOT NULL IDENTITY,
	[intTransportLoadId] INT NOT NULL,
	[strOrigin] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intTerminalId] INT NULL,
	[intSupplyPointId] INT NULL,
    [intCompanyLocationId] INT NULL,
	[strBillOfLadding] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intItemId] INT NOT NULL,	
	[dblGross] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblNet] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblUnitCost] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblFreightRate] DECIMAL(18, 6) NULL DEFAULT 0, 
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblTRTransportReceipt] PRIMARY KEY ([intTransportReceiptId]),
	CONSTRAINT [FK_tblTRTransportReceipt_tblTRTranportLoad_intTransportLoadId] FOREIGN KEY ([intTransportLoadId]) REFERENCES [dbo].[tblTRTransportLoad] ([intTransportLoadId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblTRTransportReceipt_tblAPVendor_intTermianlId] FOREIGN KEY ([intTerminalId]) REFERENCES [dbo].[tblAPVendor] ([intEntityVendorId]),
	CONSTRAINT [FK_tblTRTransportReceipt_tblTRSupplyPoint_intSupplyPointId] FOREIGN KEY ([intSupplyPointId]) REFERENCES [dbo].[tblTRSupplyPoint] ([intSupplyPointId]),
	CONSTRAINT [FK_tblTRTransportReceipt_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]),
	CONSTRAINT [FK_tblTRTransportReceipt_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [dbo].[tblICItem] ([intItemId])	
)
