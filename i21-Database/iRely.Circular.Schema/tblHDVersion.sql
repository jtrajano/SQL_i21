CREATE TABLE [dbo].[tblHDVersion]
(
	[intVersionId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketProductId] [int] NOT NULL,
	[strVersionNo] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](150) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmReleaseDate] [date] NULL,
	[ysnSupported] [bit] NULL,
	[dtmEOLDate] [date] NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblHDVersion] PRIMARY KEY CLUSTERED ([intVersionId] ASC),
	CONSTRAINT [UNQ_tblHDVersion] UNIQUE ([intTicketProductId],[strVersionNo]),
    CONSTRAINT [FK_Version_TicketProduct] FOREIGN KEY ([intTicketProductId]) REFERENCES [dbo].[tblHDTicketProduct] ([intTicketProductId]) on delete cascade
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDVersion',
    @level2type = N'COLUMN',
    @level2name = N'intVersionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Product Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDVersion',
    @level2type = N'COLUMN',
    @level2name = N'intTicketProductId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Version Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDVersion',
    @level2type = N'COLUMN',
    @level2name = N'strVersionNo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDVersion',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Release Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDVersion',
    @level2type = N'COLUMN',
    @level2name = N'dtmReleaseDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Supported?',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDVersion',
    @level2type = N'COLUMN',
    @level2name = N'ysnSupported'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'EOL Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDVersion',
    @level2type = N'COLUMN',
    @level2name = N'dtmEOLDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Order',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDVersion',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDVersion',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
