CREATE TABLE [dbo].[tblLGLoadContainer]
(
[intLoadContainerId] INT NOT NULL IDENTITY (1, 1),
[intConcurrencyId] INT NOT NULL, 
[intLoadId] INT NOT NULL,
[strContainerId] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
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
[dtmUnloading] DATETIME NULL,

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

[dblCustomsClearedQty] NUMERIC(18, 6) NULL,
[dblIntransitQty] NUMERIC(18, 6) NULL,
[strDocumentNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[dtmClearanceDate] DATETIME, 
[strClearanceMonth] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[dblDeclaredWeight] NUMERIC(18, 6) NULL,
[dblStaticValue] NUMERIC(18, 6) NULL,
[intStaticValueCurrencyId] INT,
[dblAmount] NUMERIC(18, 6) NULL,
[intAmountCurrencyId] INT,
[strRemarks] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NULL,
[intLoadContainerRefId] INT NULL,
[intSort] INT NULL,

CONSTRAINT [PK_tblLGLoadContainer] PRIMARY KEY ([intLoadContainerId]), 
CONSTRAINT [FK_tblLGLoadContainer_tblLGLoad_intLoadId] FOREIGN KEY ([intLoadId]) REFERENCES [tblLGLoad]([intLoadId]) ON DELETE CASCADE,

CONSTRAINT [FK_tblLGLoadContainer_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
CONSTRAINT [FK_tblLGLoadContainer_tblICUnitMeasure_intWeightUnitMeasureId] FOREIGN KEY ([intWeightUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),

CONSTRAINT [FK_tblLGLoadContainer_tblICItemUOM_intCostUOMId] FOREIGN KEY ([intCostUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
CONSTRAINT [FK_tblLGLoadContainer_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID])
)
GO

CREATE STATISTICS [_dta_stat_1001926791_16_1] ON [dbo].[tblLGLoadContainer]([ysnRejected], [intLoadContainerId])

go

--CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoadContainer_207_1851869664__K3_4] ON [dbo].[tblLGLoadContainer]
--(
--	[intLoadId] ASC
--)
--INCLUDE ( 	[strContainerNumber]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
--go

CREATE NONCLUSTERED INDEX [IX_tblLGLoadContainer_intLoadId] ON [dbo].[tblLGLoadContainer]
(
	[intLoadId] ASC
)
INCLUDE ( 	
	[strContainerNumber]
	,[dblQuantity]
	,[intLoadContainerId]
) 
GO 
