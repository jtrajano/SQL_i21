﻿CREATE TABLE [dbo].[tblRKCompanyPreference]
(
	[intCompanyPreferenceId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL,
    [dblDecimals] NUMERIC(18, 6) DEFAULT ((2)) NULL, 
    [dblRefreshRate] NUMERIC(18, 6) NULL DEFAULT ((60)), 
    [ysnIncludeInTransitInCompanyTitled] BIT DEFAULT ((0)) NULL, 
    [ysnIncludeOffsiteInventoryInCompanyTitled] BIT  DEFAULT ((0)) NULL, 
    [ysnIncludeDPPurchasesInCompanyTitled] BIT DEFAULT ((0))  NULL, 
    [ysnIncludeOptionsInRiskInquiryOrCoverage] BIT  DEFAULT ((0)) NULL, 
    [ysnIncludeInventoryHedge] BIT DEFAULT ((0))  NULL, 
    [ysnIncludeExpiredMonths] BIT  DEFAULT ((0)) NULL, 
	[intRiskViewId] INT NULL,
    [strReportLevel] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strTimingField] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strReportTerms] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ysnIncludeInventoryBasis] BIT DEFAULT ((0)) NULL, 
    [strM2MReportLevel] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ysnIncludeInventoryM2M] BIT DEFAULT ((0)) NULL, 
    [ysnIncludeInTransitM2M] BIT DEFAULT ((0)) NULL,
	[ysnIncludeBasisDifferentialsInResults] BIT DEFAULT ((0)) NULL, 
    [ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell] BIT DEFAULT ((0)) NULL, 
    [ysnEnterForwardCurveForMarketBasisDifferential] BIT DEFAULT ((0)) NULL, 
    [ysnAllowPartialPricingOfAContractSequence] BIT DEFAULT ((0)) NULL, 
    [strPricingQty] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ysnEnablePolarizationAdjustments] BIT DEFAULT ((0)) NULL,
    [strPeriodType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[ysnValueBasisAndDPDeliveries] BIT DEFAULT ((0)) NULL, 
    [strEvaluationBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strEvaluationByZone] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intCurrencyId] INT NULL, 
	[strDateTimeFormat] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intInterfaceSystemId] INT NULL, 
    [ysnAutoExpire] BIT DEFAULT ((0)) NULL,
    [ysnIsAutoAssign] BIT DEFAULT ((0)) NULL, 
	[ysnCanadianCustomer] BIT DEFAULT ((0)) NULL, 
	[ysnPnLWithOutAllocation] BIT DEFAULT ((0)) NULL,
	[intUnrealizedGainOnBasisId] INT NULL,
	[intUnrealizedGainOnFuturesId] INT NULL,
	[intUnrealizedGainOnCashId] INT NULL,
	[intUnrealizedGainOnRatioId] INT NULL,
	[intUnrealizedLossOnBasisId] INT NULL,
	[intUnrealizedLossOnFuturesId] INT NULL,
	[intUnrealizedLossOnCashId] INT NULL,
	[intUnrealizedLossOnRatioId] INT NULL,
	[intUnrealizedGainOnInventoryBasisIOSId] INT NULL,
	[intUnrealizedGainOnInventoryFuturesIOSId] INT NULL,
	[intUnrealizedGainOnInventoryCashIOSId] INT NULL,
	[intUnrealizedGainOnInventoryRatioIOSId] INT NULL,
	[intUnrealizedLossOnInventoryBasisIOSId] INT NULL,
	[intUnrealizedLossOnInventoryFuturesIOSId] INT  NULL,
	[intUnrealizedLossOnInventoryCashIOSId] INT NULL,
	[intUnrealizedLossOnInventoryRatioIOSId] INT NULL,
	[intUnrealizedGainOnInventoryIntransitIOSId] INT NULL,
	[intUnrealizedLossOnInventoryIntransitIOSId] INT NULL,
	[intUnrealizedGainOnInventoryIOSId] INT NULL,
	[intUnrealizedLossOnInventoryIOSId] INT NULL,
	[intFuturesGainOrLossRealizedId] INT NULL,
	[intFuturesGainOrLossRealizedOffsetId] INT NULL,
	[ysnDisplayAllStorage] BIT DEFAULT ((0)) NULL,
	[strM2MView] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[ysnPreCrush] BIT DEFAULT ((0)) NULL,
	[ysnHideNetPayableAndReceivable] BIT DEFAULT ((0)) NULL,
	[intMarkExpiredMonthPositionId] INT NULL DEFAULT((1)),
	[ysnSubTotalByBook] BIT DEFAULT((0)) NULL,
	[intDefaultInstrumentId] INT NULL,
	[intDefaultInstrumentTypeId] INT NULL,
	[ysnDefaultTraderLoggedUser] BIT NULL DEFAULT((0)),
	[intPostToGLId] INT NULL DEFAULT ((1)),
	[ysnIncludeDerivatives] BIT NULL DEFAULT((1)),
	[ysnIncludeCrushDerivatives] BIT NULL DEFAULT((1)),
	[ysnUseBoardMonth] BIT NULL DEFAULT((0)),
	[ysnAllowEditAvgLongPrice] BIT NULL DEFAULT((0)),
	[ysnUseM2MDate] BIT NULL DEFAULT((0)),
	[ysnDisableHistoricalDerivative] BIT NULL DEFAULT((0)),
	[intTonnageUOMId] INT NULL,
	[ysnAllowRebuildSummaryLog] BIT NOT NULL DEFAULT((1)),
	[ysnEnableSliceDerivative] BIT NULL DEFAULT((0)),
    CONSTRAINT [PK_tblRKCompanyPreference_intCompanyPreferenceId] PRIMARY KEY ([intCompanyPreferenceId]), 
	CONSTRAINT [FK_tblRKCompanyPreference_tblSMCurrency_intCurrencyId] FOREIGN KEY([intCurrencyId])REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID]),
	CONSTRAINT [FK_tblRKCompanyPreference_tblRKInterfaceSystem_intCurrencyId] FOREIGN KEY([intInterfaceSystemId])REFERENCES [dbo].[tblRKInterfaceSystem] ([intInterfaceSystemId]),
	CONSTRAINT [FK_tblRKCompanyPreference_tblGLAccount_intUnrealizedGainOnBasisId] FOREIGN KEY(intUnrealizedGainOnBasisId)REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblRKCompanyPreference_tblGLAccount_intUnrealizedGainOnFuturesId] FOREIGN KEY(intUnrealizedGainOnFuturesId)REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblRKCompanyPreference_tblGLAccount_intUnrealizedGainOnCashId] FOREIGN KEY(intUnrealizedGainOnCashId)REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblRKCompanyPreference_tblGLAccount_intUnrealizedGainOnRatioId] FOREIGN KEY(intUnrealizedGainOnRatioId)REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblRKCompanyPreference_tblGLAccount_intUnrealizedLossOnBasisId] FOREIGN KEY(intUnrealizedLossOnBasisId)REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblRKCompanyPreference_tblGLAccount_intUnrealizedLossOnFuturesId] FOREIGN KEY(intUnrealizedLossOnFuturesId)REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblRKCompanyPreference_tblGLAccount_intUnrealizedLossOnCashId] FOREIGN KEY(intUnrealizedLossOnCashId)REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblRKCompanyPreference_tblGLAccount_intUnrealizedLossOnRatioId] FOREIGN KEY(intUnrealizedLossOnRatioId)REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    CONSTRAINT [FK_tblRKCompanyPreference_tblGLAccount_intUnrealizedGainOnInventoryBasisIOSId] FOREIGN KEY(intUnrealizedGainOnInventoryBasisIOSId)REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    CONSTRAINT [FK_tblRKCompanyPreference_tblGLAccount_intUnrealizedGainOnInventoryFuturesIOSId] FOREIGN KEY(intUnrealizedGainOnInventoryFuturesIOSId)REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblRKCompanyPreference_tblGLAccount_intUnrealizedGainOnInventoryCashIOSId] FOREIGN KEY(intUnrealizedGainOnInventoryCashIOSId)REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblRKCompanyPreference_tblGLAccount_intUnrealizedGainOnInventoryRatioIOSId] FOREIGN KEY(intUnrealizedGainOnInventoryRatioIOSId)REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblRKCompanyPreference_tblGLAccount_intUnrealizedLossOnInventoryBasisIOSId] FOREIGN KEY(intUnrealizedLossOnInventoryBasisIOSId)REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblRKCompanyPreference_tblGLAccount_intUnrealizedLossOnInventoryFuturesIOSId] FOREIGN KEY(intUnrealizedLossOnInventoryFuturesIOSId)REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblRKCompanyPreference_tblGLAccount_intUnrealizedLossOnInventoryCashIOSId] FOREIGN KEY(intUnrealizedLossOnInventoryCashIOSId)REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblRKCompanyPreference_tblGLAccount_intUnrealizedLossOnInventoryRatioIOSId] FOREIGN KEY(intUnrealizedLossOnInventoryRatioIOSId)REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblRKCompanyPreference_tblGLAccount_intUnrealizedGainOnInventoryIntransitIOSId] FOREIGN KEY(intUnrealizedGainOnInventoryIntransitIOSId)REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblRKCompanyPreference_tblGLAccount_intUnrealizedLossOnInventoryIntransitIOSId] FOREIGN KEY(intUnrealizedLossOnInventoryIntransitIOSId)REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblRKCompanyPreference_tblGLAccount_intUnrealizedGainOnInventoryIOSId] FOREIGN KEY(intUnrealizedGainOnInventoryIOSId)REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblRKCompanyPreference_tblGLAccount_intUnrealizedLossOnInventoryIOSId] FOREIGN KEY(intUnrealizedLossOnInventoryIOSId)REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblRKCompanyPreference_tblGLAccount_intFuturesGainOrLossRealizedId] FOREIGN KEY(intFuturesGainOrLossRealizedId)REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblRKCompanyPreference_tblGLAccount_intFuturesGainOrLossRealizedOffsetId] FOREIGN KEY(intFuturesGainOrLossRealizedOffsetId)REFERENCES [dbo].[tblGLAccount] ([intAccountId])
)
