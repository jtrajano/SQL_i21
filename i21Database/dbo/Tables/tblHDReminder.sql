CREATE TABLE [dbo].[tblHDReminder]
(
	[intReminderId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketId] [int] NOT NULL,
	[strSubject] [nvarchar](255) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmDate] [date] NOT NULL,
	[dtmTime] [date] NOT NULL,
	[intRemindAdvance] [int] NOT NULL DEFAULT 0,
	[ysnActive] [bit] NOT NULL DEFAULT 1,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDReminder] PRIMARY KEY CLUSTERED ([intReminderId] ASC),
    CONSTRAINT [FK_tblHDReminder_tblHDTicket] FOREIGN KEY ([intTicketId]) REFERENCES [dbo].[tblHDTicket] ([intTicketId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDReminder',
    @level2type = N'COLUMN',
    @level2name = N'intReminderId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDReminder',
    @level2type = N'COLUMN',
    @level2name = N'intTicketId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Subject',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDReminder',
    @level2type = N'COLUMN',
    @level2name = N'strSubject'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDReminder',
    @level2type = N'COLUMN',
    @level2name = N'dtmDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Time',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDReminder',
    @level2type = N'COLUMN',
    @level2name = N'dtmTime'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Remind in Advance',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDReminder',
    @level2type = N'COLUMN',
    @level2name = N'intRemindAdvance'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDReminder',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Active',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDReminder',
    @level2type = N'COLUMN',
    @level2name = N'ysnActive'