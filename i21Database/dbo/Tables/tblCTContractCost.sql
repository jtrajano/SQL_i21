CREATE TABLE [dbo].[tblCTContractCost](
	[intContractCostId]			INT IDENTITY(1,1) NOT NULL,
	[intConcurrencyId]			INT NOT NULL,
	[intPrevConcurrencyId]		INT NOT NULL DEFAULT ((0)),
	[intContractDetailId]		INT NOT NULL,
	[intItemId]					INT NULL,
	[intVendorId]				INT NULL,
	[strCostMethod]				NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL,
	[intCurrencyId]				INT,
	[dblRate]					NUMERIC(18, 6) NOT NULL,
	[intItemUOMId]				INT NULL,
	[intRateTypeId]				INT NULL,
	[dblFX]						NUMERIC(18,6),
	[ysnAccrue]					BIT NOT NULL CONSTRAINT [DF_tblCTContractCost_ysnAccrue]  DEFAULT ((1)),
	[ysnMTM]					BIT NULL,
	[ysnPrice]					BIT NULL,
	[ysnAdditionalCost]			BIT NULL,
	[ysnBasis]					BIT NULL,
	[ysnReceivable]				BIT,
	[strParty]					NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[strPaidBy]					NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[dtmDueDate]				DATETIME,
	[strReference]				NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[ysn15DaysFromShipment]		BIT NOT NULL DEFAULT ((0)),
	[strRemarks]				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	strStatus					NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
	strCostStatus				NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
    dblReqstdAmount				NUMERIC(18,6),
	dblRcvdPaidAmount			NUMERIC(18,6),
	dblActualAmount				NUMERIC(18,6),
	dblAccruedAmount			NUMERIC(18,6),
	dblRemainingPercent			NUMERIC(18,6),
	[dtmAccrualDate]			DATETIME,
	[strAPAR]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strPayToReceiveFrom]		NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strReferenceNo]			NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[intContractCostRefId]		INT,
	[ysnFromBasisComponent]					BIT NULL,
	CONSTRAINT [PK_tblCTContractCost_intContractCostId] PRIMARY KEY CLUSTERED ([intContractCostId] ASC),
	--CONSTRAINT [FK_tblCTContractCost_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCTContractCost_tblEMEntity_intVendorId_intEntityId] FOREIGN KEY ([intVendorId]) REFERENCES [tblEMEntity](intEntityId),
	CONSTRAINT [FK_tblCTContractCost_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblCTContractCost_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblCTContractCost_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblCTContractCost_tblSMCurrencyExchangeRateType_intRateTypeId_intCurrencyExchangeRateId] FOREIGN KEY (intRateTypeId) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId])
)

GO

CREATE NONCLUSTERED INDEX [NonClusteredIndex_tblCTContractCost_001] ON [dbo].tblCTContractCost
(
	[intContractDetailId] ASC,
	intItemId ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

GO

CREATE NONCLUSTERED INDEX [NonClusteredIndex_tblCTContractCost_002] ON [dbo].tblCTContractCost
(
	[intContractDetailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

GO
