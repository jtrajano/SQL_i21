CREATE TABLE [dbo].[tblSCTicketUberScaleStatusUpdate]
(
	[intTicketUberScaleStatusUpdateId] INT NOT NULL IDENTITY,	
    [strUberStatusCode] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL,
    [dtmTransactionDate] DATETIME NULL, 
    [intTicketId] INT NOT NULL,

    CONSTRAINT [PK_tblSCTicketUberScaleStatusUpdate_intTicketUberScaleStatusUpdateId] PRIMARY KEY ([intTicketUberScaleStatusUpdateId]),
	CONSTRAINT [FK_tblSCTicketUberScaleStatusUpdate_tblSCTicket_intTicketId] FOREIGN KEY ([intTicketId]) REFERENCES [tblSCTicket]([intTicketId]),
)
