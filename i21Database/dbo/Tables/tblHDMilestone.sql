CREATE TABLE [dbo].[tblHDMilestone]
(
	[intMilestoneId] INT IDENTITY (1, 1) NOT NULL,
	[strMileStone] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] NVARCHAR(255) COLLATE Latin1_General_CI_AS NOT NULL,
	[intPriority] INT NOT NULL,
    [intSort] INT NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDMilestone] PRIMARY KEY CLUSTERED ([intMilestoneId] ASC),
    CONSTRAINT [UNQ_tblHDMilestone] UNIQUE ([strMileStone])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Milestone Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDMilestone',
    @level2type = N'COLUMN',
    @level2name = N'intMilestoneId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Milestone',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDMilestone',
    @level2type = N'COLUMN',
    @level2name = N'strMileStone'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDMilestone',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Priority',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDMilestone',
    @level2type = N'COLUMN',
    @level2name = N'intPriority'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Order',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDMilestone',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDMilestone',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'