CREATE TABLE [dbo].[tblSCTicketDirectBasisContract]
(
	[intTicketDirectBasisContractId] INT NOT NULL  IDENTITY, 
    [intTicketId] INT NOT NULL, 
	[intContractDetailId] INT NOT NULL, 
    [dtmDistributedDateUTC] DATETIME NOT NULL DEFAULT GETUTCDATE(), 
    [ysnProcessed] BIT NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblSCTicketDirectBasisContract_intTicketTypeId] PRIMARY KEY ([intTicketDirectBasisContractId]), 
)

GO

CREATE NONCLUSTERED INDEX [IX_tblSCTicketDirectBasisContract] ON [dbo].[tblSCTicketDirectBasisContract]
(
	[ysnProcessed] ASC,
	[intTicketId] ASC,
	[intContractDetailId] ASC,
	[dtmDistributedDateUTC] DESC
)ON [PRIMARY]
GO


