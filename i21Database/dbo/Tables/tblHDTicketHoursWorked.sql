CREATE TABLE [dbo].[tblHDTicketHoursWorked]
(
	[intTicketHoursWorkedId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketId] [int] NOT NULL,
	[intAgentId] [int] NOT NULL,
	[intHours] [numeric](18, 6) NOT NULL,
	[dtmDate] [datetime] NULL,
	[dblRate] [numeric](18, 6) NOT NULL,
	[strDescription] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strJIRALink] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[ysnBillable] [bit] NOT NULL,
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL,
	[intJobCodeId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTicketHoursWorked] PRIMARY KEY CLUSTERED ([intTicketHoursWorkedId] ASC),
    CONSTRAINT [FK_TicketHoursWorked_Ticket] FOREIGN KEY ([intTicketId]) REFERENCES [dbo].[tblHDTicket] ([intTicketId])  on delete cascade,
    CONSTRAINT [FK_TicketHoursWorked_JobCode] FOREIGN KEY ([intJobCodeId]) REFERENCES [dbo].[tblHDJobCode] ([intJobCodeId])
)
