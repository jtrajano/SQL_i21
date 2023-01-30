CREATE TABLE tblLGInsurancePremiumFactor
(
	[intInsurancePremiumFactorId] INT NOT NULL IDENTITY (1, 1),
	[intEntityId] INT NOT NULL,
	[intConcurrencyId] INT NOT NULL, 
	[dtmValidFrom] DATETIME NULL,
	intCommodityId INT NULL,
	intCommodityAttributeId INT NULL,
	strPolicyNumber NVARCHAR(100) NOT NULL,
	dblInboundWarehouse NUMERIC(18, 6) NULL DEFAULT((0)),	
	dtmValidTo DATETIME NULL,

	CONSTRAINT [FK_tblLGInsurancePremiumFactor_tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId]), 
    CONSTRAINT [PK_tblLGInsurancePremiumFactor] PRIMARY KEY ([intInsurancePremiumFactorId]), 
    CONSTRAINT [FK_tblLGInsurancePremiumFactor_tblICCommodity] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]), 
    CONSTRAINT [FK_tblLGInsurancePremiumFactor_tblICCommodityAttribute] FOREIGN KEY ([intCommodityAttributeId]) REFERENCES [tblICCommodityAttribute]([intCommodityAttributeId])
)