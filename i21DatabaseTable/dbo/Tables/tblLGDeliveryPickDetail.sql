CREATE TABLE [dbo].[tblLGDeliveryPickDetail]
(
	[intDeliveryPickDetailId] INT NOT NULL IDENTITY(1, 1), 
    [intConcurrencyId] INT NOT NULL, 
	[intDeliveryDetailId] INT NOT NULL, 
	[intPickLotDetailId] INT NOT NULL, 
	[dblGrossWt] NUMERIC(18, 6) NOT NULL,
	[dblTareWt] NUMERIC(18, 6) NOT NULL,
	[dblNetWt] NUMERIC(18, 6) NOT NULL,
	[intWeightUnitMeasureId] INT NOT NULL,	
	
    CONSTRAINT [PK_tblLGDeliveryPickDetail] PRIMARY KEY ([intDeliveryPickDetailId]),
    CONSTRAINT [FK_tblLGDeliveryPickDetail_tblLGDeliveryDetail_intDeliveryDetailId] FOREIGN KEY ([intDeliveryDetailId]) REFERENCES [tblLGDeliveryDetail]([intDeliveryDetailId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblLGDeliveryPickDetail_tblLGPickLotDetail_intPickLotDetailId] FOREIGN KEY ([intPickLotDetailId]) REFERENCES [tblLGPickLotDetail]([intPickLotDetailId]),
	CONSTRAINT [FK_tblLGDeliveryPickDetail_tblICUnitMeasure_intWeightUnitMeasureId] FOREIGN KEY ([intWeightUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
	CONSTRAINT [UK_tblLGDeliveryPickDetail_tblLGDeliveryDetail_tblLGPickLotDetail_intDeliveryDetailId_intPickLotDetailId] UNIQUE ([intDeliveryDetailId], [intPickLotDetailId])
)
