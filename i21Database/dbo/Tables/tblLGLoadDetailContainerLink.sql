CREATE TABLE [dbo].[tblLGLoadDetailContainerLink]
(
[intLoadDetailContainerLinkId] INT NOT NULL IDENTITY (1, 1),
[intConcurrencyId] INT NOT NULL, 
[intLoadId] INT NOT NULL,
[intLoadContainerId] INT NULL,
[intLoadDetailId] INT NULL,
[dblQuantity] NUMERIC(18, 6) NOT NULL,
[intItemUOMId] INT NOT NULL,
[dblReceivedQty] NUMERIC(18, 6) NULL,

[dblUnitCost] NUMERIC(18, 6) NULL,
[intCostUOMId] [int] NULL,
[intCurrencyId] [int] NULL,
[dblTotalCost] NUMERIC(18, 6) NULL,
[strIntegrationNumber] NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL,
[dtmIntegrationRequested] DATETIME NULL,
[strIntegrationOrderNumber] NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL,
[dblIntegrationOrderPrice] NUMERIC(18, 6) NULL,
[strExternalContainerId] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[ysnExported] [bit] NULL,
[dtmExportedDate] DATETIME NULL,
[dtmIntegrationOrderDate] DATETIME NULL,

CONSTRAINT [PK_tblLGLoadDetailContainerLink_intLoadDetailContainerLinkId] PRIMARY KEY ([intLoadDetailContainerLinkId]), 
CONSTRAINT [FK_tblLGLoadDetailContainerLink_tblLGLoad_intLoadId] FOREIGN KEY ([intLoadId]) REFERENCES [tblLGLoad]([intLoadId]) ON DELETE CASCADE,

CONSTRAINT [FK_tblLGLoadDetailContainerLink_tblLGLoadContainer_intLoadContainerId] FOREIGN KEY ([intLoadContainerId]) REFERENCES [tblLGLoadContainer]([intLoadContainerId]) ,
CONSTRAINT [FK_tblLGLoadDetailContainerLink_tblLGLoadDetail_intLoadDetailId] FOREIGN KEY ([intLoadDetailId]) REFERENCES [tblLGLoadDetail]([intLoadDetailId]),

CONSTRAINT [FK_tblLGLoadDetailContainerLink_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
CONSTRAINT [FK_tblLGLoadDetailContainerLink_tblICItemUOM_intCostUOMId] FOREIGN KEY ([intCostUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
CONSTRAINT [FK_tblLGLoadDetailContainerLink_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID])
)
GO

CREATE STATISTICS [_dta_stat_1097927133_4_5] ON [dbo].[tblLGLoadDetailContainerLink]([intLoadContainerId], [intLoadDetailId])
