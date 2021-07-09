CREATE TABLE [dbo].[tblSCTicketAttachmentRemoteExport]
(
	[intTicketAttachmentRemoteExportId] INT NOT NULL IDENTITY, 
    [intTicketId] INT NOT NULL, 
	[intAttachmentId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    [dtmDateExported] DATETIME NOT NULL DEFAULT getutcdate(), 
    CONSTRAINT [PK_tblSCTicketAttachmentRemoteExport_intTicketAttachmentRemoteExportId] PRIMARY KEY (intTicketAttachmentRemoteExportId), 
    CONSTRAINT [FK_tblSCTicketAttachmentRemoteExport_tblSCTicket_intTicketId] FOREIGN KEY (intTicketId) REFERENCES [tblSCTicket](intTicketId) ON DELETE CASCADE
    
)
GO
