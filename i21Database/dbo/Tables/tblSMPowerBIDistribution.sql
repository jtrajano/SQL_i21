CREATE TABLE [dbo].[tblSMPowerBIDistribution]
(
	[intPowerBIDistributionId]		INT		NOT NULL	IDENTITY, 
	[intEntityId]					INT		NULL,
	[strSourceWorkspace]			NVARCHAR(500) COLLATE Latin1_General_CI_AS NOT NULL,
	[strSourceWorkspaceId]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intSourceTotalReports]			INT		NULL,
	[strDestinationWorkspace]		NVARCHAR(500) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDestinationWorkspaceId]		NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intDestinationTotalReports]	INT		NULL,
	[intConcurrencyId]				INT		NOT NULL	DEFAULT 1,

	CONSTRAINT [PK_tblSMPowerBIDistribution] PRIMARY KEY CLUSTERED ([intPowerBIDistributionId] ASC),
	CONSTRAINT [UC_tblSMPowerBIDistribution_intEntityId] UNIQUE ([intEntityId])
)
GO

CREATE INDEX [IX_tblSMPowerBIDistribution_intPowerBIDistributionId] ON [dbo].[tblSMPowerBIDistribution] ([intPowerBIDistributionId])
GO