CREATE TABLE [dbo].[tblSCTicketDirectAddPayable]
(
	[intTicketDirectAddPayableId] INT NOT NULL IDENTITY, 
    [intTicketId] INT NOT NULL, 
    [intEntityVendorId] INT NOT NULL, 
    [intItemId] INT NOT NULL, 
    [intContractDetailId] INT NULL, 
    [intLoadDetailId] INT NULL,
    
    CONSTRAINT [PK_tblSCTicketDirectAddPayable_intTicketDirectAddPayableId] PRIMARY KEY (intTicketDirectAddPayableId), 
)
GO

