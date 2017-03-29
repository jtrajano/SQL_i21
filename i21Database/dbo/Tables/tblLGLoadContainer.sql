CREATE TABLE [dbo].[tblLGLoadContainer]
(
[intLoadContainerId] INT NOT NULL IDENTITY (1, 1),
[intConcurrencyId] INT NOT NULL, 
[intLoadId] INT NOT NULL,

[strContainerNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[dblQuantity] NUMERIC(18, 6) NULL,
[intUnitMeasureId] INT NULL,
[dblGrossWt] NUMERIC(18, 6) NULL,
[dblTareWt] NUMERIC(18, 6) NULL,
[dblNetWt] NUMERIC(18, 6) NULL,
[intWeightUnitMeasureId] INT NULL,
[strComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NULL,

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

[dblUnitCost] NUMERIC(18, 6) NULL,
[intCostUOMId] [int] NULL,
[intCurrencyId] [int] NULL,
[dblTotalCost] NUMERIC(18, 6) NULL,
[ysnNewContainer] BIT DEFAULT (1),

CONSTRAINT [PK_tblLGLoadContainer] PRIMARY KEY ([intLoadContainerId]), 
CONSTRAINT [FK_tblLGLoadContainer_tblLGLoad_intLoadId] FOREIGN KEY ([intLoadId]) REFERENCES [tblLGLoad]([intLoadId]) ON DELETE CASCADE,

CONSTRAINT [FK_tblLGLoadContainer_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
CONSTRAINT [FK_tblLGLoadContainer_tblICUnitMeasure_intWeightUnitMeasureId] FOREIGN KEY ([intWeightUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),

CONSTRAINT [FK_tblLGLoadContainer_tblICItemUOM_intCostUOMId] FOREIGN KEY ([intCostUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
CONSTRAINT [FK_tblLGLoadContainer_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID])
)
GO

CREATE STATISTICS [_dta_stat_1001926791_16_1] ON [dbo].[tblLGLoadContainer]([ysnRejected], [intLoadContainerId])
