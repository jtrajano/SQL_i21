CREATE TABLE [dbo].[tblHDTicketStatus]
(
	[intTicketStatusId] [int] IDENTITY(1,1) NOT NULL,
	[strStatus] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](150) COLLATE Latin1_General_CI_AS NOT NULL,
	[strIcon] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strFontColor] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strBackColor] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[ysnSupported] [bit] NOT NULL DEFAULT 1,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblHDTicketStatus] PRIMARY KEY CLUSTERED ([intTicketStatusId] ASC),
 CONSTRAINT [UNQ_tblHDTicketStatus] UNIQUE ([strStatus])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketStatus',
    @level2type = N'COLUMN',
    @level2name = N'intTicketStatusId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Status Name (Unique)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketStatus',
    @level2type = N'COLUMN',
    @level2name = N'strStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketStatus',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Icon',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketStatus',
    @level2type = N'COLUMN',
    @level2name = N'strIcon'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Font Color',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketStatus',
    @level2type = N'COLUMN',
    @level2name = N'strFontColor'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Background Color',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketStatus',
    @level2type = N'COLUMN',
    @level2name = N'strBackColor'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Order',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketStatus',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketStatus',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'