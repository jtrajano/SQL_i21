CREATE TABLE [dbo].[tblLGShipmentBL]
(
[intShipmentBLId] INT NOT NULL IDENTITY (1, 1),
[intConcurrencyId] INT NOT NULL, 
[intShipmentId] INT NOT NULL,
[strBLNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[dtmBLDate] DATETIME NULL,
[dblQuantity] NUMERIC(18, 6) NULL,
[intUnitMeasureId] INT NULL,
[dblGrossWt] NUMERIC(18, 6) NULL,
[dblTareWt] NUMERIC(18, 6) NULL,
[dblNetWt] NUMERIC(18, 6) NULL,
[intWeightUnitMeasureId] INT NULL,
[strComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NULL,

CONSTRAINT [PK_tblLGShipmentBL] PRIMARY KEY ([intShipmentBLId]), 
CONSTRAINT [UK_tblLGShipmentBL_intShipmentId_strBLNumber_intUnitMeasureId] UNIQUE ([intShipmentId], [strBLNumber], [intUnitMeasureId]),

CONSTRAINT [FK_tblLGShipmentBL_tblLGShipment_intShipmentId] FOREIGN KEY ([intShipmentId]) REFERENCES [tblLGShipment]([intShipmentId]) ON DELETE CASCADE,
CONSTRAINT [FK_tblLGShipmentBL_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
CONSTRAINT [FK_tblLGShipmentBL_tblICUnitMeasure_intWeightUnitMeasureId] FOREIGN KEY ([intWeightUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
)
