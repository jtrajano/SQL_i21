CREATE TABLE [dbo].[tblHDTicketToActivity]
(
	[intTicketToActivityId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketId] [int] NOT NULL,
	[intActivityId] [int] NOT NULL,
	[strTicketNumber] [nvarchar](20) COLLATE Latin1_General_CI_AS NOT NULL,
	[strActivityNo] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strActivityType] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTicketToActivity_intTicketToActivityId] PRIMARY KEY CLUSTERED ([intTicketToActivityId] ASC),
	CONSTRAINT [FK_tblHDTicketToActivity_tblHDTicket_intTicketId] FOREIGN KEY ([intTicketId]) REFERENCES [dbo].[tblHDTicket] ([intTicketId]),
    CONSTRAINT [FK_tblHDTicketToActivity_tblSMActivity_intActivityId] FOREIGN KEY ([intActivityId]) REFERENCES [dbo].[tblSMActivity] ([intActivityId])
)
