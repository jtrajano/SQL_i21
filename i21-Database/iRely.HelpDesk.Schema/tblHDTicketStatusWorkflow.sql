CREATE TABLE [dbo].[tblHDTicketStatusWorkflow]
(
	[intTicketStatusWorkflowId] [int] IDENTITY(1,1) NOT NULL,
	[intFromStatusId] [int] NOT NULL,
	[intToStatusId] [int] NOT NULL,
	[strTiggerBy] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL default 'Customer Responds',
	[ysnActive] [bit] null default 1,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTicketStatusWorkflow_intTicketStatusWorkflowId] PRIMARY KEY CLUSTERED ([intTicketStatusWorkflowId] ASC),
	CONSTRAINT [FK_tblHDTicketStatusWorkflow_tblHDTicketStatus_intFromStatusId] FOREIGN KEY ([intFromStatusId]) REFERENCES [dbo].[tblHDTicketStatus] ([intTicketStatusId]),
    CONSTRAINT [FK_tblHDTicketStatusWorkflow_tblHDTicketStatus_intToStatusId] FOREIGN KEY ([intToStatusId]) REFERENCES [dbo].[tblHDTicketStatus] ([intTicketStatusId]),
    CONSTRAINT [UQ_tblHDTicketStatusWorkflow_intFromStatusId] UNIQUE ([intFromStatusId]),
    CONSTRAINT [UQ_tblHDTicketStatusWorkflow] UNIQUE ([intFromStatusId],[intToStatusId],[strTiggerBy])
)