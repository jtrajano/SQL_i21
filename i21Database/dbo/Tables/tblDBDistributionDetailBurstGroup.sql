CREATE TABLE [dbo].[tblDBDistributionDetailBurstGroup]
(
	[intDistributionDetailBurstGroupId]		INT				IDENTITY (1, 1) NOT NULL,
	[intDistributionId]						INT				NOT NULL,
	[intDistributionBurstGroupId]			INT				NOT NULL,
	[intConcurrencyId]						INT				NOT NULL,

    CONSTRAINT [PK_tblDBDistributionDetailBurstGroup] PRIMARY KEY CLUSTERED ([intDistributionDetailBurstGroupId] ASC),
    CONSTRAINT [FK_tblDBDistributionDetailBurstGroup_tblDBDistribution] FOREIGN KEY (intDistributionId) REFERENCES [dbo].[tblDBDistribution] ([intDistributionId]) ON DELETE CASCADE
)








