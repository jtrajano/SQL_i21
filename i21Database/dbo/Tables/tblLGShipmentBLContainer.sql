CREATE TABLE [dbo].[tblLGShipmentBLContainer]
(
[intShipmentBLContainerId] INT NOT NULL IDENTITY (1, 1),
[intConcurrencyId] INT NOT NULL, 
[intShipmentBLId] INT NOT NULL,

[strContainerNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[dblQuantity] NUMERIC(18, 6) NULL,
[intUnitMeasureId] INT NULL,
[dblGrossWt] NUMERIC(18, 6) NULL,
[dblTareWt] NUMERIC(18, 6) NULL,
[dblNetWt] NUMERIC(18, 6) NULL,
[intWeightUnitMeasureId] INT NULL,
[strComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NULL,

[intContainerTypeId] INT NULL,
[strSealNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[strLotNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[strMarks] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[strOtherMarks] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[ysnRejected] [bit] NULL,

[dtmCustoms] DATETIME NULL,
[ysnCustomsHold] [bit] NULL,
[strCustomsComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NULL,

[dtmFDA] DATETIME NULL,
[ysnFDAHold] [bit] NULL,
[strFDAComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NULL,

[dtmFreight] DATETIME NULL,
[ysnDutyPaid] [bit] NULL,
[strFreightComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NULL,

[dtmUSDA] DATETIME NULL,
[ysnUSDAHold] [bit] NULL,
[strUSDAComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NULL,

CONSTRAINT [PK_tblLGShipmentBLContainer] PRIMARY KEY ([intShipmentBLContainerId]), 
CONSTRAINT [UK_tblLGShipmentBLContainer_intShipmentBLId_strContainerNumber_intUnitMeasureId_strLotNumber] UNIQUE ([intShipmentBLId], [strContainerNumber], [intUnitMeasureId], [strLotNumber]),
CONSTRAINT [FK_tblLGShipmentBLContainer_tblLGShipmentBL_intShipmentBLId] FOREIGN KEY ([intShipmentBLId]) REFERENCES [tblLGShipmentBL]([intShipmentBLId]) ON DELETE CASCADE,

CONSTRAINT [FK_tblLGShipmentBLContainer_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
CONSTRAINT [FK_tblLGShipmentBLContainer_tblICUnitMeasure_intWeightUnitMeasureId] FOREIGN KEY ([intWeightUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),

CONSTRAINT [FK_tblLGShipmentBLContainer_tblLGContainerType_intContainerTypeId] FOREIGN KEY ([intContainerTypeId]) REFERENCES [tblLGContainerType]([intContainerTypeId])
)
