CREATE TABLE [dbo].[tblLGContainerTypeCommodityQty]
(
	[intContainerTypeCommodityQtyId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
	[intContainerTypeId] INT NOT NULL, 
    [intCommodityId] INT NOT NULL, 
    [dblQuantity] NUMERIC(18, 6) NULL, 
    [intUnitMeasureId] INT NULL, 
    [dblConversionFactor] NUMERIC(18, 6) NULL, 
    [dblWeight] NUMERIC(18, 6) NULL, 
    [intWeightUnitMeasureId] INT NULL, 
    CONSTRAINT [PK_tblLGContainerTypeCommodityQty] PRIMARY KEY ([intContainerTypeCommodityQtyId]),
    CONSTRAINT [FK_tblLGContainerTypeCommodityQty_tblLGContainerType_intContainerTypeId] FOREIGN KEY ([intContainerTypeId]) REFERENCES [tblLGContainerType]([intContainerTypeId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblLGContainerTypeCommodityQty_tblICCommodity_intCommodityId] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]), 
    CONSTRAINT [FK_tblLGContainerTypeCommodityQty_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
    CONSTRAINT [FK_tblLGContainerTypeCommodityQty_tblICUnitMeasure_intWeightUnitMeasureId] FOREIGN KEY ([intWeightUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
    CONSTRAINT [UQ_tblLGContainerTypeCommodityQty_intContainerTypeId_intUnitMeasureId] UNIQUE ([intContainerTypeId], [intCommodityId], [intUnitMeasureId])
)
