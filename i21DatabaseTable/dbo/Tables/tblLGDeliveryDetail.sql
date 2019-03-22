CREATE TABLE [dbo].[tblLGDeliveryDetail]
(
	[intDeliveryDetailId] INT NOT NULL IDENTITY(1, 1), 
    [intConcurrencyId] INT NOT NULL, 
	[intDeliveryHeaderId] INT NOT NULL, 
	[intPickLotHeaderId] INT NOT NULL,
	
    CONSTRAINT [PK_tblLGDeliveryDetail] PRIMARY KEY ([intDeliveryDetailId]),	
    CONSTRAINT [FK_tblLGDeliveryDetail_tblLGDeliveryHeader_intDeliveryHeaderId] FOREIGN KEY ([intDeliveryHeaderId]) REFERENCES [tblLGDeliveryHeader]([intDeliveryHeaderId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblLGDeliveryDetail_tblLGPickLotHeader_intPickLotHeaderId] FOREIGN KEY ([intPickLotHeaderId]) REFERENCES [tblLGPickLotHeader]([intPickLotHeaderId]),
	CONSTRAINT [UK_tblLGDeliveryDetail_tblLGPickLotHeader_intPickLotHeaderId] UNIQUE ([intPickLotHeaderId])
)
