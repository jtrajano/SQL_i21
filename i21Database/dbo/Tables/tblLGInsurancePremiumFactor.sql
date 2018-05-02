CREATE TABLE tblLGInsurancePremiumFactor
(
	[intInsurancePremiumFactorId]  INT NOT NULL PRIMARY KEY IDENTITY (1, 1),
	[intEntityId] INT NOT NULL,
	[intConcurrencyId] INT NOT NULL, 
	[dtmDate] DATETIME NULL,

	CONSTRAINT [FK_tblLGInsurancePremiumFactor_tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId])
)