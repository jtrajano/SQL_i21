CREATE TABLE [dbo].[tblHDActivityRecipient]
(
	[intActivityRecipientId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketId] [int] NOT NULL,
	[strEmail] [nvarchar](255) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDActivityRecipient] PRIMARY KEY CLUSTERED ([intActivityRecipientId] ASC),
	CONSTRAINT [FK_tblHDActivityRecipient_tblHDTicket] FOREIGN KEY ([intTicketId]) REFERENCES [dbo].[tblHDTicket] ([intTicketId]) on delete cascade
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDActivityRecipient',
    @level2type = N'COLUMN',
    @level2name = N'intActivityRecipientId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reference Ticket Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDActivityRecipient',
    @level2type = N'COLUMN',
    @level2name = N'intTicketId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Email Address',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDActivityRecipient',
    @level2type = N'COLUMN',
    @level2name = N'strEmail'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDActivityRecipient',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'