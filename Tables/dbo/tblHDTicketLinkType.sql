CREATE TABLE [dbo].[tblHDTicketLinkType]
(
	[intTicketLinkTypeId] [int] IDENTITY(1,1) NOT NULL,
	[strLinkType] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intTicketLinkTypeCounterId] [int] NOT NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
 CONSTRAINT [PK_tblHDTicketLinkType] PRIMARY KEY CLUSTERED ([intTicketLinkTypeId] ASC)
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketLinkType',
    @level2type = N'COLUMN',
    @level2name = N'intTicketLinkTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Link Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketLinkType',
    @level2type = N'COLUMN',
    @level2name = N'strLinkType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Counter Link Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketLinkType',
    @level2type = N'COLUMN',
    @level2name = N'intTicketLinkTypeCounterId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Order',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketLinkType',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketLinkType',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'