CREATE TABLE tblLGShippingLineServiceContract
(
	[intShippingLineServiceContractId] INT NOT NULL PRIMARY KEY IDENTITY (1, 1),
	[intEntityId] INT NOT NULL,
	[intConcurrencyId] INT NOT NULL, 
	[dtmDate] DATETIME NULL, 

	CONSTRAINT [FK_tblLGShippingLineServiceContract_tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId])
)