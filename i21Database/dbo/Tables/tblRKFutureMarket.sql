CREATE TABLE [dbo].[tblRKFutureMarket](
	[intFutureMarketId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[strFutMarketName] [nvarchar](30) COLLATE Latin1_General_CI_AS NOT NULL,
	[strFutSymbol] [nvarchar](10) COLLATE Latin1_General_CI_AS NULL,
	[intFutMonthsToOpen] [int] NULL,
	[intForecastWeeklyConsumption] INT NULL, 
	[intForecastWeeklyConsumptionUOMId] INT NULL, 
	[ysnOptions] [bit] NULL,
	[ysnActive] [bit] NULL,
	[dblContractSize] [numeric](18, 6) NULL,
	[intUnitMeasureId] [int] NULL,
	[intCurrencyId] [int] NULL,
	[ysnFutJan] [bit] NULL,
	[ysnFutFeb] [bit] NULL,
	[ysnFutMar] [bit] NULL,
	[ysnFutApr] [bit] NULL,
	[ysnFutMay] [bit] NULL,
	[ysnFutJun] [bit] NULL,
	[ysnFutJul] [bit] NULL,
	[ysnFutAug] [bit] NULL,
	[ysnFutSep] [bit] NULL,
	[ysnFutOct] [bit] NULL,
	[ysnFutNov] [bit] NULL,
	[ysnFutDec] [bit] NULL,
	[strOptMarketName] [nvarchar](30)COLLATE Latin1_General_CI_AS  NULL,
	[intOptMonthsToOpen] [int] NULL,
	[strOptSymbol] [nvarchar](5) COLLATE Latin1_General_CI_AS NULL,
	[ysnOptJan] [bit] NULL,
	[ysnOptFeb] [bit] NULL,
	[ysnOptMar] [bit] NULL,
	[ysnOptApr] [bit] NULL,
	[ysnOptMay] [bit] NULL,
	[ysnOptJun] [bit] NULL,
	[ysnOptJul] [bit] NULL,
	[ysnOptAug] [bit] NULL,
	[ysnOptSep] [bit] NULL,
	[ysnOptOct] [bit] NULL,
	[ysnOptNov] [bit] NULL,
	[ysnOptDec] [bit] NULL,
    [intNoOfDecimal] INT NULL , 
    [intMarketExchangeId] INT NULL, 
    [strSymbolPrefix] NVARCHAR(5) COLLATE Latin1_General_CI_AS NULL, 
    [dblConversionRate] NUMERIC(18, 6) NULL DEFAULT 1, 
    [intReturnCurrency] INT NULL, 
    [intDisplayCurrency] INT NULL, 
    [strMarketSymbolCode] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
	[strOptionSymbolPrefix] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[intCompanyId] INT NULL,
    CONSTRAINT [PK_tblRKFutureMarket_intFutureMarketId] PRIMARY KEY CLUSTERED ([intFutureMarketId] ASC),
	CONSTRAINT [FK_tblRKFutureMarket_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY([intUnitMeasureId]) REFERENCES [dbo].[tblICUnitMeasure] ([intUnitMeasureId]),
	CONSTRAINT [FK_tblRKFutureMarket_tblSMCurrency_intCurrencyId] FOREIGN KEY([intCurrencyId])REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID]),
	CONSTRAINT [FK_tblRKFutureMarket_tblICUnitMeasure_intForecastWeeklyConsumptionUOMId] FOREIGN KEY([intForecastWeeklyConsumptionUOMId]) REFERENCES [dbo].[tblICUnitMeasure] ([intUnitMeasureId]),
	CONSTRAINT [UQ_tblRKFutureMarket_strFutMarketName] UNIQUE NONCLUSTERED ([strFutMarketName] ASC)
)
GO

ALTER TABLE [dbo].[tblRKFutureMarket] CHECK CONSTRAINT [FK_tblRKFutureMarket_tblSMCurrency_intCurrencyId]
GO

ALTER TABLE [dbo].[tblRKFutureMarket] ADD  CONSTRAINT [DF_tblRKFutureMarket_ysnOptions]  DEFAULT ((1)) FOR [ysnOptions]
GO

ALTER TABLE [dbo].[tblRKFutureMarket] ADD  CONSTRAINT [DF_tblRKFutureMarket_ysnFutJan]  DEFAULT ((0)) FOR [ysnFutJan]
GO

ALTER TABLE [dbo].[tblRKFutureMarket] ADD  CONSTRAINT [DF_tblRKFutureMarket_ysnFutFeb]  DEFAULT ((0)) FOR [ysnFutFeb]
GO

ALTER TABLE [dbo].[tblRKFutureMarket] ADD  CONSTRAINT [DF_tblRKFutureMarket_ysnFutMar]  DEFAULT ((0)) FOR [ysnFutMar]
GO

ALTER TABLE [dbo].[tblRKFutureMarket] ADD  CONSTRAINT [DF_tblRKFutureMarket_ysnFutApr]  DEFAULT ((0)) FOR [ysnFutApr]
GO

ALTER TABLE [dbo].[tblRKFutureMarket] ADD  CONSTRAINT [DF_tblRKFutureMarket_ysnFutMay]  DEFAULT ((0)) FOR [ysnFutMay]
GO

ALTER TABLE [dbo].[tblRKFutureMarket] ADD  CONSTRAINT [DF_tblRKFutureMarket_ysnFutJun]  DEFAULT ((0)) FOR [ysnFutJun]
GO

ALTER TABLE [dbo].[tblRKFutureMarket] ADD  CONSTRAINT [DF_tblRKFutureMarket_ysnFutJul]  DEFAULT ((0)) FOR [ysnFutJul]
GO

ALTER TABLE [dbo].[tblRKFutureMarket] ADD  CONSTRAINT [DF_tblRKFutureMarket_ysnFutAug]  DEFAULT ((0)) FOR [ysnFutAug]
GO

ALTER TABLE [dbo].[tblRKFutureMarket] ADD  CONSTRAINT [DF_tblRKFutureMarket_ysnFutSep]  DEFAULT ((0)) FOR [ysnFutSep]
GO

ALTER TABLE [dbo].[tblRKFutureMarket] ADD  CONSTRAINT [DF_tblRKFutureMarket_ysnFutOct]  DEFAULT ((0)) FOR [ysnFutOct]
GO

ALTER TABLE [dbo].[tblRKFutureMarket] ADD  CONSTRAINT [DF_tblRKFutureMarket_ysnFutNov]  DEFAULT ((0)) FOR [ysnFutNov]
GO

ALTER TABLE [dbo].[tblRKFutureMarket] ADD  CONSTRAINT [DF_tblRKFutureMarket_ysnFutDec]  DEFAULT ((0)) FOR [ysnFutDec]
GO

ALTER TABLE [dbo].[tblRKFutureMarket] ADD  CONSTRAINT [DF_tblRKFutureMarket_ysnOptJan]  DEFAULT ((0)) FOR [ysnOptJan]
GO

ALTER TABLE [dbo].[tblRKFutureMarket] ADD  CONSTRAINT [DF_tblRKFutureMarket_ysnOptFeb]  DEFAULT ((0)) FOR [ysnOptFeb]
GO

ALTER TABLE [dbo].[tblRKFutureMarket] ADD  CONSTRAINT [DF_tblRKFutureMarket_ysnOptMar]  DEFAULT ((0)) FOR [ysnOptMar]
GO

ALTER TABLE [dbo].[tblRKFutureMarket] ADD  CONSTRAINT [DF_tblRKFutureMarket_ysnOptApr]  DEFAULT ((0)) FOR [ysnOptApr]
GO

ALTER TABLE [dbo].[tblRKFutureMarket] ADD  CONSTRAINT [DF_tblRKFutureMarket_ysnOptMay]  DEFAULT ((0)) FOR [ysnOptMay]
GO

ALTER TABLE [dbo].[tblRKFutureMarket] ADD  CONSTRAINT [DF_tblRKFutureMarket_ysnOptJun]  DEFAULT ((0)) FOR [ysnOptJun]
GO

ALTER TABLE [dbo].[tblRKFutureMarket] ADD  CONSTRAINT [DF_tblRKFutureMarket_ysnOptJul]  DEFAULT ((0)) FOR [ysnOptJul]
GO

ALTER TABLE [dbo].[tblRKFutureMarket] ADD  CONSTRAINT [DF_tblRKFutureMarket_ysnOptAug]  DEFAULT ((0)) FOR [ysnOptAug]
GO

ALTER TABLE [dbo].[tblRKFutureMarket] ADD  CONSTRAINT [DF_tblRKFutureMarket_ysnOptSep]  DEFAULT ((0)) FOR [ysnOptSep]
GO

ALTER TABLE [dbo].[tblRKFutureMarket] ADD  CONSTRAINT [DF_tblRKFutureMarket_ysnOptOct]  DEFAULT ((0)) FOR [ysnOptOct]
GO

ALTER TABLE [dbo].[tblRKFutureMarket] ADD  CONSTRAINT [DF_tblRKFutureMarket_ysnOptNov]  DEFAULT ((0)) FOR [ysnOptNov]
GO

ALTER TABLE [dbo].[tblRKFutureMarket] ADD  CONSTRAINT [DF_tblRKFutureMarket_ysnOptDec]  DEFAULT ((0)) FOR [ysnOptDec]
GO


