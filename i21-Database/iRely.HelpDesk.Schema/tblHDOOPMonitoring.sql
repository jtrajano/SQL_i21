CREATE TABLE [dbo].[tblHDOOPMonitoring]
(
	[intOOPMonitoringId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketId] [int] NULL,
	[strTicketNumber] nvarchar(20) NULL,
	[intEntityId] [int] NOT NULL,
	[intDate] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDOOPMonitoring] PRIMARY KEY CLUSTERED ([intOOPMonitoringId] ASC),
	--CONSTRAINT [FK_tblHDOOPMonitoring_tblHDTicket_intTicketId] FOREIGN KEY ([intTicketId]) REFERENCES [dbo].[tblHDTicket] ([intTicketId]) on delete cascade,
	CONSTRAINT [FK_tblHDOOPMonitoring_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]) on delete cascade
)