CREATE TABLE [dbo].[tblLGWarehouseRateMatrixDetail]
(
	[intWarehouseRateMatrixDetailId] INT NOT NULL IDENTITY(1, 1), 
    [intConcurrencyId] INT NOT NULL, 
	[intWarehouseRateMatrixHeaderId] INT NOT NULL, 
	[strCategory] NVARCHAR(300) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strActivity] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intType] INT NOT NULL, 
	[intSort] INT NOT NULL, 
	[dblUnitRate] NUMERIC(18, 6) NOT NULL,
	[intItemUOMId] INT NOT NULL,
	[ysnPrint] [bit] NOT NULL,
    [strComments] NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL, 
	[intItemId] [int] NULL,
	[intCalculateQty] [int] NULL,
	
    CONSTRAINT [PK_tblLGWarehouseRateMatrixDetail] PRIMARY KEY ([intWarehouseRateMatrixDetailId]),
    CONSTRAINT [FK_tblLGWarehouseRateMatrixDetail_tblLGWarehouseRateMatrixHeader_intWarehouseRateMatrixHeaderId] FOREIGN KEY ([intWarehouseRateMatrixHeaderId]) REFERENCES [tblLGWarehouseRateMatrixHeader]([intWarehouseRateMatrixHeaderId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblLGWarehouseRateMatrixDetail_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblLGWarehouseRateMatrixDetail_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
)
