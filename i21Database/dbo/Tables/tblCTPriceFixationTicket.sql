CREATE TABLE [dbo].[tblCTPriceFixationTicket]
(
	[intPriceFixationTicketId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intPriceFixationId] INT NOT NULL,
	[intPricingId] INT NOT NULL,
	[intTicketId] INT NOT NULL,
	[intInventoryShipmentId] INT NOT NULL,
	[dblQuantity] NUMERIC(18, 6) NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [FK_tblCTPriceFixationTicket_tblSCTicket_intPriceFixationId] FOREIGN KEY (intTicketId) REFERENCES tblSCTicket(intTicketId),
	CONSTRAINT [FK_tblCTPriceFixationTicket_tblCTPriceFixation_intPriceFixationId] FOREIGN KEY (intPriceFixationId) REFERENCES tblCTPriceFixation(intPriceFixationId)
)
