CREATE TABLE [dbo].[tblGRUnPricedSpotTicket]
(
	[intUnPricedSpotTicketId] INT NOT NULL IDENTITY,
	[intConcurrencyId] INT NULL, 
	[intUnPricedId] INT NOT NULL,
    [intTicketId] INT NULL,
	[intBillId] INT NULL,
	[intInvoiceId] INT NULL,
	[dblUnits] DECIMAL(24, 10) NULL,
	CONSTRAINT [PK_tblGRUnPricedSpotTicket_intUnPricedSpotTicketId] PRIMARY KEY ([intUnPricedSpotTicketId]),
	CONSTRAINT [FK_tblGRUnPricedSpotTicket_tblGRUnPriced_intUnPricedId] FOREIGN KEY ([intUnPricedId]) REFERENCES [dbo].[tblGRUnPriced] ([intUnPricedId]) ON DELETE CASCADE,	
	CONSTRAINT [FK_tblGRUnPricedSpotTicket_tblSCTicket_intTicketId] FOREIGN KEY ([intTicketId]) REFERENCES [tblSCTicket]([intTicketId]),	
)
