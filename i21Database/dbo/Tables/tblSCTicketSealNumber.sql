CREATE TABLE tblSCTicketSealNumber
(
	[intTicketSealNumberId] INT IDENTITY(1,1) NOT NULL,
	[intTicketId] INT NOT NULL,
	[intSealNumberId] INT NOT NULL,
	[intTruckDriverReferenceId] INT,
	[intUserId] INT NOT NULL,
	[intConcurrencyId] INT NULL DEFAULT((1)),
	CONSTRAINT [FK_tblSCTicketSealNumber_tblSCTicket_intTicketId] FOREIGN KEY ([intTicketId]) REFERENCES [tblSCTicket]([intTicketId]),
	CONSTRAINT [FK_tblSCTicketSealNumber_tblSCSealNumber_intSealNumberId] FOREIGN KEY ([intSealNumberId]) REFERENCES [tblSCSealNumber](intSealNumberId),
	CONSTRAINT [FK_tblSCTicketSealNumber_tblSCTruckDriverReference_intTruckDriverReferenceId] FOREIGN KEY ([intTruckDriverReferenceId]) REFERENCES [tblSCTruckDriverReference]([intTruckDriverReferenceId])
)