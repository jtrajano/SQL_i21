CREATE TABLE [dbo].[tblLGShipmentPurchaseSalesContract]
(
[intShipmentPurchaseSalesContractId] INT NOT NULL IDENTITY (1, 1),
[intConcurrencyId] INT NOT NULL, 
[intShipmentId] INT NOT NULL,
[intShipmentContractQtyId] INT NOT NULL,
[intAllocationDetailId] INT NOT NULL,
[dblPAllocatedQty] NUMERIC(18, 6) NOT NULL,
[intPUnitMeasureId] INT NOT NULL,
[dblSAllocatedQty] NUMERIC(18, 6) NOT NULL,
[intSUnitMeasureId] INT NOT NULL,

CONSTRAINT [PK_tblLGShipmentPurchaseSalesContract_intShipmentPurchaseSalesContractId] PRIMARY KEY ([intShipmentPurchaseSalesContractId]), 
CONSTRAINT [FK_tblLGShipmentPurchaseSalesContract_tblLGShipment_intShipmentId] FOREIGN KEY ([intShipmentId]) REFERENCES [tblLGShipment]([intShipmentId]) ON DELETE CASCADE,
CONSTRAINT [FK_tblLGShipmentPurchaseSalesContract_tblLGShipmentContractQty_intShipmentContractQtyId] FOREIGN KEY ([intShipmentContractQtyId]) REFERENCES [tblLGShipmentContractQty]([intShipmentContractQtyId]),
CONSTRAINT [FK_tblLGShipmentPurchaseSalesContract_tblLGAllocationDetail_intAllocationDetailId] FOREIGN KEY ([intAllocationDetailId]) REFERENCES [tblLGAllocationDetail]([intAllocationDetailId]), 
CONSTRAINT [FK_tblLGShipmentPurchaseSalesContract_tblICUnitMeasure_intPUnitMeasureId] FOREIGN KEY ([intPUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
CONSTRAINT [FK_tblLGShipmentPurchaseSalesContract_tblICUnitMeasure_intSUnitMeasureId] FOREIGN KEY ([intSUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
)
