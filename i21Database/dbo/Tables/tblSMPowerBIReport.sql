CREATE TABLE [dbo].[tblSMPowerBIReport]
(
	[intPowerBIReportId]		INT		NOT NULL	IDENTITY, 
	[strReportName]				NVARCHAR(500) COLLATE Latin1_General_CI_AS NOT NULL,
	[strName]					NVARCHAR(500) COLLATE Latin1_General_CI_AS NOT NULL,
	[strId]						NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strGroupId]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strDatasetId]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strEmbedUrl]				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[strWebUrl]					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[intPowerBICredentialId]	INT		NULL,
	[intModuleId]				INT		NULL,
	[strModule]					NVARCHAR(500) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId]			INT		NOT NULL	DEFAULT 1,


	CONSTRAINT [PK_tblSMPowerBIReport] PRIMARY KEY CLUSTERED ([intPowerBIReportId] ASC),
	CONSTRAINT [UC_tblSMPowerBIReport] UNIQUE ([strId])
)
GO

CREATE INDEX [IX_tblSMPowerBIReport_intPowerBIDatasetId] ON [dbo].[tblSMPowerBIReport] ([intPowerBIReportId])
GO