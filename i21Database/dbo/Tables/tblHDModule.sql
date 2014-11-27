CREATE TABLE [dbo].[tblHDModule]
(
	[intModuleId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketProductId] [int] NOT NULL,
	[intTicketGroupId] [int] NOT NULL,
	[strModule] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](150) COLLATE Latin1_General_CI_AS NOT NULL,
	[strJIRAProject] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL,
	[intSort] [int] NULL,
	[ysnSupported] [bit] NOT NULL DEFAULT 1,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDModule] PRIMARY KEY CLUSTERED ([intModuleId] ASC),
	CONSTRAINT [UNQ_tblHDModule] UNIQUE ([intTicketProductId],[strModule]),
    CONSTRAINT [FK_Module_TicketProduct] FOREIGN KEY ([intTicketProductId]) REFERENCES [dbo].[tblHDTicketProduct] ([intTicketProductId]) on delete cascade,
    CONSTRAINT [FK_Module_TicketGroup] FOREIGN KEY ([intTicketGroupId]) REFERENCES [dbo].[tblHDTicketGroup] ([intTicketGroupId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDModule',
    @level2type = N'COLUMN',
    @level2name = N'intModuleId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Product Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDModule',
    @level2type = N'COLUMN',
    @level2name = N'intTicketProductId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Group Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDModule',
    @level2type = N'COLUMN',
    @level2name = N'intTicketGroupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Module Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDModule',
    @level2type = N'COLUMN',
    @level2name = N'strModule'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDModule',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Associated JIRA Project',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDModule',
    @level2type = N'COLUMN',
    @level2name = N'strJIRAProject'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Order',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDModule',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDModule',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'