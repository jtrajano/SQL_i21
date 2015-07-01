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
	[intCommodityUnitMeasureId] INT NOT NULL,
	[ysnPrint] [bit] NOT NULL,
    [strComments] NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL, 
	
    CONSTRAINT [PK_tblLGWarehouseRateMatrixDetail] PRIMARY KEY ([intWarehouseRateMatrixDetailId]),
    CONSTRAINT [FK_tblLGWarehouseRateMatrixDetail_tblLGWarehouseRateMatrixHeader_intWarehouseRateMatrixHeaderId] FOREIGN KEY ([intWarehouseRateMatrixHeaderId]) REFERENCES [tblLGWarehouseRateMatrixHeader]([intWarehouseRateMatrixHeaderId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblLGWarehouseRateMatrixDetail_tblICCommodityUnitMeasure_intCommodityUnitMeasureId] FOREIGN KEY ([intCommodityUnitMeasureId]) REFERENCES [tblICCommodityUnitMeasure]([intCommodityUnitMeasureId])
)
