CREATE TABLE [dbo].[tblLGEntityInsurer]
(
	intEntityId INT NOT NULL PRIMARY KEY,
	dtmValidFrom DATETIME NOT NULL,
	dtmValidTo DATETIME NOT NULL,
	dblCost NUMERIC(18,6) NOT NULL,
	intCostUOM INT NOT NULL, 
	dblInsurancePremiumFactor NUMERIC(18,6),
	dblProfitMarkup NUMERIC(18,6),

	CONSTRAINT [FK_tblLGEntityInsurer_tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId])
)

