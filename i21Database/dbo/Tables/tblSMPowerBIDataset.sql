CREATE TABLE [dbo].[tblSMPowerBIDataset]
(
	[intPowerBIDatasetId]		INT		NOT NULL	PRIMARY KEY IDENTITY, 
	[strName]					NVARCHAR(500) COLLATE Latin1_General_CI_AS NOT NULL,
	[strId]						NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnIsRefreshable]			BIT		NULL,
	[strTargetStorageMode]		NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strCreateReportEmbedURL]	NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL,
	[strQnaEmbedURL]			NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL,
	[ysnSchemaMayNotBeUpToDate]	BIT		NULL,
	[intConcurrencyId]			INT		NOT NULL	DEFAULT 1,
)


