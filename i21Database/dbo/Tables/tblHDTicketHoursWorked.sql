CREATE TABLE [dbo].[tblHDTicketHoursWorked]
(
	[intTicketHoursWorkedId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketId] [int] NOT NULL,
	[intAgentId] [int] NOT NULL,
	[intHours] [numeric](18, 6) NOT NULL,
	[dtmDate] [datetime] NULL,
	[intRate] [numeric](18, 6) NOT NULL,
	[strDescription] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL,
	[strJIRALink] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[ysnBillable] [bit] NOT NULL,
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL,
	[intJobCodeId] [int] NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblHDTicketHoursWorked] PRIMARY KEY CLUSTERED ([intTicketHoursWorkedId] ASC),
    CONSTRAINT [FK_TicketHoursWorked_Ticket] FOREIGN KEY ([intTicketId]) REFERENCES [dbo].[tblHDTicket] ([intTicketId])
)
