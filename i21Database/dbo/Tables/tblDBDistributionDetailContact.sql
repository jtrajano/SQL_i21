CREATE TABLE [dbo].[tblDBDistributionDetailContact]
(
	[intDistributionDetailContactId]		INT				IDENTITY (1, 1) NOT NULL,
	[intDistributionId]						INT				NOT NULL,
	[intEntityId]							INT				NOT NULL,
	[strEmail]								[nvarchar](500) COLLATE Latin1_General_CI_AS NULL,
	[intFilterId]							INT				NULL,
	[intConcurrencyId]						INT				NOT NULL,

    CONSTRAINT [PK_tblDBDistributionDetailContact] PRIMARY KEY CLUSTERED ([intDistributionDetailContactId] ASC),
    CONSTRAINT [FK_tblDBDistributionDetailContact_tblDBDistribution] FOREIGN KEY (intDistributionId) REFERENCES [dbo].[tblDBDistribution] ([intDistributionId]) ON DELETE CASCADE
)
