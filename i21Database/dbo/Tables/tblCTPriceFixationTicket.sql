CREATE TABLE [dbo].[tblCTPriceFixationTicket]
(
	[intPriceFixationTicketId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intPriceFixationId] INT NOT NULL,
	[intPricingId] INT NOT NULL,
	[intTicketId] INT NOT NULL,
	[intInventoryReceiptId] INT NULL,
	[intInventoryShipmentId] INT NULL,
	[dblQuantity] NUMERIC(18, 6) NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [FK_tblCTPriceFixationTicket_tblSCTicket_intPriceFixationId] FOREIGN KEY (intTicketId) REFERENCES tblSCTicket(intTicketId),
	CONSTRAINT [FK_tblCTPriceFixationTicket_tblCTPriceFixation_intPriceFixationId] FOREIGN KEY (intPriceFixationId) REFERENCES tblCTPriceFixation(intPriceFixationId) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCTPriceFixationTicket_tblCTPriceFixationDetail_intPricingId] FOREIGN KEY (intPricingId) REFERENCES tblCTPriceFixationDetail(intPriceFixationDetailId)
)
