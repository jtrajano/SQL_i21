CREATE TABLE [dbo].[tblSMPowerBIReport]
(
	[intPowerBIReportId]		INT		NOT NULL	PRIMARY KEY IDENTITY, 
	[strName]					NVARCHAR(500) COLLATE Latin1_General_CI_AS NOT NULL,
	[strId]						NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDatasetId]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strEmbedUrl]				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[strWebUrl]					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[intPowerBICredentialId]	INT		NULL,
	[intConcurrencyId]			INT		NOT NULL	DEFAULT 1,


	CONSTRAINT [FK_tblSMPowerBIReport_tblSMPowerBICredential] FOREIGN KEY ([intPowerBICredentialId]) REFERENCES [tblSMPowerBICredential]([intPowerBICredentialId]), 
)
