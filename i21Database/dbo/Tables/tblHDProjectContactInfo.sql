CREATE TABLE [dbo].[tblHDProjectContactInfo]
(
	[intProjectContactInfoId] [int] IDENTITY(1,1) NOT NULL,
	[intProjectId] [int] NOT NULL,
	[intEntityId] [int] NOT NULL,
	[strDecisionRole] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strAttitude] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strExtent] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strConcerns] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strExpectations] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDProjectContactInfo] PRIMARY KEY CLUSTERED ([intProjectContactInfoId] ASC),
	CONSTRAINT [UNQ_intProjectId_intEnityId] UNIQUE ([intProjectId],[intEntityId]),
    CONSTRAINT [FK_tblHDProjectContactInfo_tblHDProject] FOREIGN KEY ([intProjectId]) REFERENCES [dbo].[tblHDProject] ([intProjectId]) on delete cascade,
	CONSTRAINT [FK_tblHDProjectContactInfo_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProjectContactInfo',
    @level2type = N'COLUMN',
    @level2name = N'intProjectContactInfoId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reference Project Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProjectContactInfo',
    @level2type = N'COLUMN',
    @level2name = N'intProjectId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reference Contact Entity Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProjectContactInfo',
    @level2type = N'COLUMN',
    @level2name = 'intEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Decision Role',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProjectContactInfo',
    @level2type = N'COLUMN',
    @level2name = N'strDecisionRole'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Attitude',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProjectContactInfo',
    @level2type = N'COLUMN',
    @level2name = N'strAttitude'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Extent',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProjectContactInfo',
    @level2type = N'COLUMN',
    @level2name = N'strExtent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concerns',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProjectContactInfo',
    @level2type = N'COLUMN',
    @level2name = N'strConcerns'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Expectations',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProjectContactInfo',
    @level2type = N'COLUMN',
    @level2name = N'strExpectations'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Order',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProjectContactInfo',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProjectContactInfo',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'