CREATE TABLE [dbo].[tblDBDistributionBurstGroupContact]
(
	[intDistributionBurstGroupContactId]				INT IDENTITY (1, 1) NOT NULL,
	[intDistributionBurstGroupId]						[int] NOT NULL,
	[intEntityId]										[int] NOT NULL,
	[intFilterId]										[int] NULL,
	[intConcurrencyId]									[int] DEFAULT 1,

	CONSTRAINT [PK_tblDBDistributionBurstGroupContact] PRIMARY KEY CLUSTERED ([intDistributionBurstGroupContactId] ASC),
    CONSTRAINT [FK_tblDBDistributionBurstGroupContact_tblDBDistributionBurstGroup] FOREIGN KEY ([intDistributionBurstGroupId]) REFERENCES [dbo].[tblDBDistributionBurstGroup] ([intDistributionBurstGroupId]) ON DELETE CASCADE
)
