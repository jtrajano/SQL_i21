CREATE TABLE [dbo].[tblHDTicketSQLQuery]
(
	[intTicketSQLQueryId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketId] [int] NOT NULL,
	[strSQLQuery] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intCreatedByEntityId] [int] NULL,
	[dtmCreated] [datetime] NULL,
	[intLastModifiedByEntityId] [int] NULL,
	[dtmLastModified] [datetime] NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTicketSQLQuery_intTicketSQLQueryId] PRIMARY KEY CLUSTERED ([intTicketSQLQueryId] ASC),
    CONSTRAINT [FK_tblHDTicketSQLQuery_tblHDTicket_intTicketId] FOREIGN KEY ([intTicketId]) REFERENCES [dbo].[tblHDTicket] ([intTicketId]) on delete cascade
)
