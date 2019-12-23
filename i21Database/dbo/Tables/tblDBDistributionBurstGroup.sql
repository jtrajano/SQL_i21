CREATE TABLE [dbo].[tblDBDistributionBurstGroup]
(
	[intDistributionBurstGroupId]				INT IDENTITY (1, 1) NOT NULL,
	[strDescription]							[nvarchar](500) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId]							[int] DEFAULT 1,

	CONSTRAINT [PK_tblDBDistributionBurstGroup] PRIMARY KEY CLUSTERED ([intDistributionBurstGroupId] ASC),
	CONSTRAINT [UC_tblDBDistributionBurstGroup] UNIQUE (strDescription)
)
GO

CREATE INDEX [IX_tblDBDistributionBurstGroup_intDistributionBurstGroupId] ON [dbo].[tblDBDistributionBurstGroup] ([intDistributionBurstGroupId])
GO
