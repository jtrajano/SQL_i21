CREATE TABLE [dbo].[tblLGShipmentBLContainerContract]
(
[intShipmentBLContainerContractId] INT NOT NULL IDENTITY (1, 1),
[intConcurrencyId] INT NOT NULL, 
[intShipmentId] INT NOT NULL,
[intShipmentBLId] INT NOT NULL,
[intShipmentBLContainerId] INT NULL,
[intShipmentContractQtyId] INT NOT NULL,
[dblQuantity] NUMERIC(18, 6) NOT NULL,
[intUnitMeasureId] INT NOT NULL,
[dblReceivedQty] NUMERIC(18, 6) NULL,

CONSTRAINT [PK_tblLGShipmentBLContainerContract_intShipmentBLContainerContractId] PRIMARY KEY ([intShipmentBLContainerContractId]), 
CONSTRAINT [FK_tblLGShipmentBLContainerContract_tblLGShipment_intShipmentId] FOREIGN KEY ([intShipmentId]) REFERENCES [tblLGShipment]([intShipmentId]) ON DELETE CASCADE,

CONSTRAINT [FK_tblLGShipmentBLContainerContract_tblLGShipmentBL_intShipmentBLId] FOREIGN KEY ([intShipmentBLId]) REFERENCES [tblLGShipmentBL]([intShipmentBLId]),
CONSTRAINT [FK_tblLGShipmentBLContainerContract_tblLGShipmentBLContainer_intShipmentBLContainerId] FOREIGN KEY ([intShipmentBLContainerId]) REFERENCES [tblLGShipmentBLContainer]([intShipmentBLContainerId]),
CONSTRAINT [FK_tblLGShipmentBLContainerContract_tblLGShipmentContractQty_intShipmentContractQtyId] FOREIGN KEY ([intShipmentContractQtyId]) REFERENCES [tblLGShipmentContractQty]([intShipmentContractQtyId]),

CONSTRAINT [FK_tblLGShipmentBLContainerContract_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
)
