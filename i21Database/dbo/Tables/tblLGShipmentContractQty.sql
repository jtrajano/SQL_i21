CREATE TABLE [dbo].[tblLGShipmentContractQty]
(
[intShipmentContractQtyId] INT NOT NULL IDENTITY (1, 1),
[intConcurrencyId] INT NOT NULL, 
[intShipmentId] INT NOT NULL,
[intContractDetailId] INT NOT NULL,
[intItemId] INT NOT NULL,
[dblQuantity] NUMERIC(18, 6) NOT NULL,
[intUnitMeasureId] INT NOT NULL,
[dblGrossWt] NUMERIC(18, 6) NOT NULL,
[dblTareWt] NUMERIC(18, 6) NOT NULL,
[dblNetWt] NUMERIC(18, 6) NOT NULL,
[intWeightUnitMeasureId] INT NOT NULL,
[dblReceivedQty] NUMERIC(18, 6) NULL,

CONSTRAINT [PK_tblLGShipmentContractQty] PRIMARY KEY ([intShipmentContractQtyId]), 
CONSTRAINT [FK_tblLGShipmentContractQty_tblLGShipment_intShipmentId] FOREIGN KEY ([intShipmentId]) REFERENCES [tblLGShipment]([intShipmentId]) ON DELETE CASCADE,
CONSTRAINT [UK_tblLGShipmentContractQty_intShipmentId_intContractDetailId] UNIQUE ([intShipmentId], [intContractDetailId]),

CONSTRAINT [FK_tblLGShipmentContractQty_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),
CONSTRAINT [FK_tblLGShipmentContractQty_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
CONSTRAINT [FK_tblLGShipmentContractQty_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
CONSTRAINT [FK_tblLGShipmentContractQty_tblICUnitMeasure_intWeightUnitMeasureId] FOREIGN KEY ([intWeightUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
)
