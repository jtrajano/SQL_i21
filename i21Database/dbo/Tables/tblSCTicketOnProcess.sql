CREATE TABLE [dbo].[tblSCTicketOnProcess]
(
	[intTicketOnProcessId] INT NOT NULL IDENTITY, 
    [intTicketId] INT NOT NULL, 
    [intUserId] INT NOT NULL, 
    [ysnInProgress] BIT NOT NULL DEFAULT 0,
    [intConcurrencyId] INT NOT NULL DEFAULT 0
	CONSTRAINT [PK_tblSCTicketOnProcess_intTicketOnProcessId] PRIMARY KEY ([intTicketOnProcessId]) 
)
GO

CREATE NONCLUSTERED INDEX [IX_tblSCTicketLoadUsed_intLoadDetailId]
ON [dbo].[tblSCTicketOnProcess] ([intTicketId],[intUserId],[ysnInProgress])
GO

CREATE UNIQUE NONCLUSTERED INDEX [UK_tblSCTicketOnProcess_intTicketid] ON [dbo].[tblSCTicketOnProcess]
(
	[intTicketId] ASC
)
GO