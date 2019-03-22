CREATE TABLE [dbo].[tblGRSellOffsiteTicket]
(
	[intSellOffsiteTicketId] INT NOT NULL IDENTITY,
	[intConcurrencyId] INT NULL, 
	[intSellOffsiteId] INT NOT NULL,
    [intCustomerStorageId] INT NULL,
	[dblUnits] DECIMAL(24, 10) NULL,	
	CONSTRAINT [PK_tblGRSellOffsiteTicket_intSellOffsiteTicketId] PRIMARY KEY ([intSellOffsiteTicketId]),
	CONSTRAINT [FK_tblGRSellOffsiteTicket_tblGRSellOffsite_intSellOffsiteId] FOREIGN KEY ([intSellOffsiteId]) REFERENCES [dbo].[tblGRSellOffsite] ([intSellOffsiteId]) ON DELETE CASCADE,	
	CONSTRAINT [FK_tblGRSellOffsiteTicket_tblGRCustomerStorage_intCustomerStorageId] FOREIGN KEY ([intCustomerStorageId]) REFERENCES [tblGRCustomerStorage]([intCustomerStorageId]),	
)