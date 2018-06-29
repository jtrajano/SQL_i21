CREATE TABLE [dbo].[tblHDTicketGroup]
(
	[intTicketGroupId] INT             IDENTITY (1, 1) NOT NULL,
    [strGroup] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTicketGroup] PRIMARY KEY CLUSTERED ([intTicketGroupId] ASC),
	CONSTRAINT [UNQ_tblHDTicketGroup] UNIQUE ([strGroup])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketGroup',
    @level2type = N'COLUMN',
    @level2name = N'intTicketGroupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Group Name (Unique)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketGroup',
    @level2type = N'COLUMN',
    @level2name = N'strGroup'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketGroup',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Order',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketGroup',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketGroup',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'