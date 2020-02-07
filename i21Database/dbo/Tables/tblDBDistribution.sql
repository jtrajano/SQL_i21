CREATE TABLE [dbo].[tblDBDistribution]
(
	[intDistributionId]							INT IDENTITY (1, 1) NOT NULL,
	[strDescription]							[nvarchar](500) COLLATE Latin1_General_CI_AS NOT NULL,
	[intDashboardPanelId]						[int] NULL,
	[intScheduleId]								[int] NOT NULL,
	[strEmailBody]								[nvarchar](MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDateCondition]							[nvarchar](500) COLLATE Latin1_General_CI_AS NOT NULL,
	[strExportFormat]							[nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strPageBy]									[nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strGroupBy]								[nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strValues]									[nvarchar](MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnSendWithNoResults]						[bit] NULL,
	[ysnBasketAnalysisReport]					[bit] NULL,
	[strBasketComparison]						[nvarchar](500) COLLATE Latin1_General_CI_AS NOT NULL,
	[intBasketItemId]							[int] NULL,
	[intBasketCategoryId]						[int] NULL,
	[intStoreId]								[int] NULL,
	[strRegion]									[nvarchar](500) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDistrict]								[nvarchar](500) COLLATE Latin1_General_CI_AS NOT NULL,
	[intCategoryId]								[int] NULL,	
	[intConcurrencyId]							[int] DEFAULT 1,

	CONSTRAINT [PK_tblDBDistribution] PRIMARY KEY CLUSTERED ([intDistributionId] ASC),
	CONSTRAINT [UC_tblDBDistribution] UNIQUE (strDescription)
)
GO

CREATE INDEX [IX_tblDBDistribution_intDistributionId] ON [dbo].[tblDBDistribution] ([intDistributionId])
GO
