CREATE TABLE [dbo].[tblSCTicketDestinationOverageContract]
(
	[intTicketDestinationOverageContractId] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	[intTicketId] INT NOT NULL,
	[intContractDetailId] INT NOT NULL,
	[dblUnit] NUMERIC(38, 20),
	[intConcurrencyId] INT NOT NULL DEFAULT(1),
	

	CONSTRAINT [FK_TICKET_DESTINATION_OVERAGE_CONTRACT_TICKET] 
		FOREIGN KEY ([intTicketId]) 
		REFERENCES tblSCTicket(intTicketId) 
			ON DELETE CASCADE,	

	CONSTRAINT [FK_TICKET_DESTINATIO_OVERAGE_CONTRACT_CONTRACT] 
		FOREIGN KEY ([intContractDetailId]) 
		REFERENCES tblCTContractDetail(intContractDetailId),

	
)
