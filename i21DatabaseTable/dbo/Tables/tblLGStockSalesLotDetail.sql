CREATE TABLE [dbo].[tblLGStockSalesLotDetail]
(
	[intStockSalesLotDetailId] INT NOT NULL IDENTITY(1, 1), 
    [intConcurrencyId] INT NOT NULL, 
	[intStockSalesHeaderId] INT NOT NULL, 
	[intPickLotDetailId] INT NOT NULL,
	
    CONSTRAINT [PK_tblLGStockSalesLotDetail] PRIMARY KEY ([intStockSalesLotDetailId]),
    CONSTRAINT [FK_tblLGStockSalesLotDetail_tblLGStockSalesHeader_intStockSalesHeaderId] FOREIGN KEY ([intStockSalesHeaderId]) REFERENCES [tblLGStockSalesHeader]([intStockSalesHeaderId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblLGStockSalesLotDetail_tblLGPickLotDetail_intPickLotDetailId] FOREIGN KEY ([intPickLotDetailId]) REFERENCES [tblLGPickLotDetail]([intPickLotDetailId])
)
