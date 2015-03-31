CREATE TABLE [dbo].[tblHDTicketWatcher]
(
	[intTicketWatcherId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketId] [int] NOT NULL,
	[intUserId] [int] NOT NULL,
	[intUserEntityId] [int] NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTicketWatcher] PRIMARY KEY CLUSTERED ([intTicketWatcherId] ASC),
	CONSTRAINT [UNQ_tblHDTicketWatcher] UNIQUE ([intTicketId],[intUserId]),
    CONSTRAINT [FK_TicketWatcher_Ticket] FOREIGN KEY ([intTicketId]) REFERENCES [dbo].[tblHDTicket] ([intTicketId]) on delete cascade
)

GO
CREATE INDEX [IX_tblHDTicketWatcher_intTicketId] ON [dbo].[tblHDTicketWatcher] ([intTicketId])

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketWatcher',
    @level2type = N'COLUMN',
    @level2name = N'intTicketWatcherId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketWatcher',
    @level2type = N'COLUMN',
    @level2name = N'intTicketId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Id (User Id)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketWatcher',
    @level2type = N'COLUMN',
    @level2name = N'intUserId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Id (Entity Id)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketWatcher',
    @level2type = N'COLUMN',
    @level2name = N'intUserEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketWatcher',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'