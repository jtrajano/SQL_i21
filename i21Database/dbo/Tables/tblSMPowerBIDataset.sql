CREATE TABLE [dbo].[tblSMPowerBIDataset]
(
	[intPowerBIDatasetId]		INT		NOT NULL	IDENTITY, 
	[strName]					NVARCHAR(500) COLLATE Latin1_General_CI_AS NOT NULL,
	[strId]						NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strGroupId]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[ysnIsRefreshable]			BIT		NULL,
	[dtmLastRefresh]			[datetime] NULL, 
	[dtmNextRefresh]			[datetime] NULL, 
	[strTargetStorageMode]		NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strCreateReportEmbedURL]	NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL,
	[strQnaEmbedURL]			NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL,
	[ysnSchemaMayNotBeUpToDate]	BIT		NULL,
	[strFrequency]				[nvarchar](500) COLLATE Latin1_General_CI_AS NULL,
	[strTimezone]				[nvarchar](500) COLLATE Latin1_General_CI_AS NULL,
	[ysnMonday]					[bit] NULL,
	[ysnTuesday]				[bit] NULL,
	[ysnWednesday]				[bit] NULL,
	[ysnThursday]				[bit] NULL,
	[ysnFriday]					[bit] NULL,
	[ysnSaturday]				[bit] NULL,
	[ysnSunday]					[bit] NULL,
	[intDayOfMonth]				[int] NULL,
	[intConcurrencyId]			INT		NOT NULL	DEFAULT 1,

	CONSTRAINT [PK_tblSMPowerBIDataset] PRIMARY KEY CLUSTERED ([intPowerBIDatasetId] ASC),
	CONSTRAINT [UC_tblSMPowerBIDataset] UNIQUE ([strId])
)
GO

CREATE INDEX [IX_tblSMPowerBIDataset_intPowerBIDatasetId] ON [dbo].[tblSMPowerBIDataset] ([intPowerBIDatasetId])
GO


