CREATE TABLE [dbo].[tblLGWarehouseInstructionCost]
(
	[intWarehouseInstructionCostId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intWarehouseInstructionHeaderId] [int] NOT NULL,
	[intItemId] [int] NOT NULL,
	[intVendorId] [int] NULL,
	[strCostMethod] [nvarchar](30) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblRate] [numeric](10, 4) NOT NULL,
	[intItemUOMId] [int] NULL,
	[ysnAccrue] [bit] NULL,
	[ysnMTM] [bit] NULL,
	[ysnPrice] [bit] NULL,

	CONSTRAINT [PK_tblLGWarehouseInstructionCost] PRIMARY KEY ([intWarehouseInstructionCostId]), 
    CONSTRAINT [FK_tblLGWarehouseInstructionCost_tblLGWarehouseInstructionHeader_intWarehouseInstructionHeaderId] FOREIGN KEY ([intWarehouseInstructionHeaderId]) REFERENCES [tblLGWarehouseInstructionHeader]([intWarehouseInstructionHeaderId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblLGWarehouseInstructionCost_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblLGWarehouseInstructionCost_tblAPVendor_intVendorId] FOREIGN KEY ([intVendorId]) REFERENCES [tblAPVendor]([intEntityId]),
	CONSTRAINT [FK_tblLGWarehouseInstructionCost_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId])
)