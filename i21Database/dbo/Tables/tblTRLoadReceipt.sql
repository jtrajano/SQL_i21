﻿CREATE TABLE [dbo].[tblTRLoadReceipt]
(
	[intLoadReceiptId] INT NOT NULL IDENTITY,
	[intLoadHeaderId] INT NOT NULL,
	[strOrigin] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intTerminalId] INT NULL,
	[intSupplyPointId] INT NULL,
    [intCompanyLocationId] INT NOT NULL,
	[strBillOfLading] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intItemId] INT NOT NULL,	
	[intContractDetailId] INT NULL,
	[dblGross] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblNet] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblUnitCost] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblFreightRate] DECIMAL(18, 6) NULL DEFAULT 0,
	[dblPurSurcharge] DECIMAL(18, 6) NULL DEFAULT 0, 
	[intInventoryReceiptId] int NULL,
	[ysnFreightInPrice] BIT  DEFAULT ((0)) NOT NULL,
	[intTaxGroupId] int NULL,
	[intInventoryTransferId] int NULL,
	[strReceiptLine] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intLoadDetailId] [int] NULL,
	CONSTRAINT [PK_tblTRLoadReceipt] PRIMARY KEY ([intLoadReceiptId]),
	CONSTRAINT [FK_tblTRLoadReceipt_tblTRLoadHeader_intLoadHeaderId] FOREIGN KEY ([intLoadHeaderId]) REFERENCES [dbo].[tblTRLoadHeader] ([intLoadHeaderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblTRLoadReceipt_tblAPVendor_intTermianlId] FOREIGN KEY ([intTerminalId]) REFERENCES [dbo].[tblAPVendor] (intEntityId),
	CONSTRAINT [FK_tblTRLoadReceipt_tblTRSupplyPoint_intSupplyPointId] FOREIGN KEY ([intSupplyPointId]) REFERENCES [dbo].[tblTRSupplyPoint] ([intSupplyPointId]),
	CONSTRAINT [FK_tblTRLoadReceipt_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]),
	CONSTRAINT [FK_tblTRLoadReceipt_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [dbo].[tblICItem] ([intItemId]),
	CONSTRAINT [FK_tblTRLoadReceipt_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),
	CONSTRAINT [FK_tblTRLoadReceipt_tblICInventoryReceipt_intInventoryReceiptId] FOREIGN KEY ([intInventoryReceiptId]) REFERENCES [tblICInventoryReceipt]([intInventoryReceiptId]),
	CONSTRAINT [FK_tblTRLoadReceipt_tblSMTaxGroup_intTaxGroupId] FOREIGN KEY ([intTaxGroupId]) REFERENCES [dbo].[tblSMTaxGroup] ([intTaxGroupId]),
	CONSTRAINT [FK_tblTRLoadReceipt_tblICInventoryTransfer_intInventoryTransferId] FOREIGN KEY ([intInventoryTransferId]) REFERENCES [tblICInventoryTransfer]([intInventoryTransferId]),
	CONSTRAINT [FK_tblTRLoadReceipt_tblLGLoadDetail_intLoadDetailId] FOREIGN KEY ([intLoadDetailId]) REFERENCES [tblLGLoadDetail]([intLoadDetailId])				
)
GO

CREATE NONCLUSTERED INDEX [IX_tblTRLoadReceipt_intLoadHeaderId] ON [dbo].[tblTRLoadReceipt]
(
	[intLoadHeaderId] ASC
)
INCLUDE ( 	
	intLoadReceiptId
) 
GO 
