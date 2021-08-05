CREATE TABLE [dbo].[tblApiMonthlyRequestUsage] (
	[guiApiMonthlyRequestUsageId] [uniqueidentifier] NOT NULL,
	[guiSubscriptionId] [uniqueidentifier] NOT NULL,
	[strName] NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL,
	[strMethod] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strPath] NVARCHAR(4000) COLLATE Latin1_General_CI_AS NULL,
	[strLastStatus] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intCount] [int] NULL,
	[intMonth] [int] NOT NULL,
	[strMonth] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intYear] [int] NOT NULL,
	[dtmDateLastUpdated] [datetime2](7) NULL,
	CONSTRAINT [PK_tblApiMonthlyRequestUsage] PRIMARY KEY CLUSTERED ([guiApiMonthlyRequestUsageId] ASC)
)