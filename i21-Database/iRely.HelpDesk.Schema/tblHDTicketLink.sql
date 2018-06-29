CREATE TABLE [dbo].[tblHDTicketLink]
(
	[intTicketLinkId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketId] [int] NOT NULL,
	[intLinkToTicketId] [int] NOT NULL,
	[intTicketLinkTypeId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTicketLink] PRIMARY KEY CLUSTERED ([intTicketLinkId] ASC),
	CONSTRAINT [FK_tblHDTicketLink_tblHDTicket] FOREIGN KEY ([intTicketId]) REFERENCES [dbo].[tblHDTicket] ([intTicketId]),
	CONSTRAINT [FK_tblHDTicketLink_LinkTo_tblHDTicket] FOREIGN KEY ([intLinkToTicketId]) REFERENCES [dbo].[tblHDTicket] ([intTicketId]),
	CONSTRAINT [FK_tblHDTicketLink_tblHDTicketLinkType] FOREIGN KEY ([intTicketLinkTypeId]) REFERENCES [dbo].[tblHDTicketLinkType] ([intTicketLinkTypeId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketLink',
    @level2type = N'COLUMN',
    @level2name = N'intTicketLinkId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Id Reference',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketLink',
    @level2type = N'COLUMN',
    @level2name = N'intTicketId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Link to Ticket Id Reference',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketLink',
    @level2type = N'COLUMN',
    @level2name = N'intLinkToTicketId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Link Type Id Reference',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketLink',
    @level2type = N'COLUMN',
    @level2name = N'intTicketLinkTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketLink',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'