CREATE TABLE [dbo].[tblHDTicketHoursWorked]
(
	[intTicketHoursWorkedId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketId] [int] NOT NULL,
	[intAgentId] [int] NOT NULL,
	[intAgentEntityId] [int] NULL,
	[intHours] [numeric](18, 6) NOT NULL,
	[dtmDate] [datetime] NULL,
	[dblRate] [numeric](18, 6) NOT NULL,
	[strDescription] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strJIRALink] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[ysnBillable] [bit] NOT NULL,
	[ysnBilled] [bit] NULL,
	[dtmBilled] [datetime] NULL,
	[intCreatedUserId] [int] NULL,
	[intCreatedUserEntityId] [int] NULL,
	[dtmCreated] [datetime] NULL,
	[intJobCodeId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTicketHoursWorked] PRIMARY KEY CLUSTERED ([intTicketHoursWorkedId] ASC),
    CONSTRAINT [FK_TicketHoursWorked_Ticket] FOREIGN KEY ([intTicketId]) REFERENCES [dbo].[tblHDTicket] ([intTicketId])  on delete cascade,
    CONSTRAINT [FK_TicketHoursWorked_JobCode] FOREIGN KEY ([intJobCodeId]) REFERENCES [dbo].[tblHDJobCode] ([intJobCodeId])
)

GO
CREATE INDEX [IX_tblHDTicketHoursWorked_intTicketId] ON [dbo].[tblHDTicketHoursWorked] ([intTicketId])

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketHoursWorked',
    @level2type = N'COLUMN',
    @level2name = N'intTicketHoursWorkedId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketHoursWorked',
    @level2type = N'COLUMN',
    @level2name = N'intTicketId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Agent Id (User Id)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketHoursWorked',
    @level2type = N'COLUMN',
    @level2name = N'intAgentId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Agent Id (Entity Id)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketHoursWorked',
    @level2type = N'COLUMN',
    @level2name = N'intAgentEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Number of Hours',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketHoursWorked',
    @level2type = N'COLUMN',
    @level2name = N'intHours'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketHoursWorked',
    @level2type = N'COLUMN',
    @level2name = N'dtmDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketHoursWorked',
    @level2type = N'COLUMN',
    @level2name = N'dblRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketHoursWorked',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'JIRA Link',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketHoursWorked',
    @level2type = N'COLUMN',
    @level2name = N'strJIRALink'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Billable?',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketHoursWorked',
    @level2type = N'COLUMN',
    @level2name = N'ysnBillable'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Billed?',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketHoursWorked',
    @level2type = N'COLUMN',
    @level2name = N'ysnBilled'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Billed',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketHoursWorked',
    @level2type = N'COLUMN',
    @level2name = N'dtmBilled'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Created By (User Id)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketHoursWorked',
    @level2type = N'COLUMN',
    @level2name = N'intCreatedUserId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Created By (Entity Id)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketHoursWorked',
    @level2type = N'COLUMN',
    @level2name = N'intCreatedUserEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Created',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketHoursWorked',
    @level2type = N'COLUMN',
    @level2name = N'dtmCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Job Code Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketHoursWorked',
    @level2type = N'COLUMN',
    @level2name = N'intJobCodeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketHoursWorked',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'