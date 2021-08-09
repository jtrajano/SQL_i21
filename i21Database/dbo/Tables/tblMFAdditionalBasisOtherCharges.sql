CREATE TABLE tblMFAdditionalBasisOtherCharges
(
	intAdditionalBasisOtherChargesId INT NOT NULL IDENTITY, 
	intConcurrencyId INT CONSTRAINT [DF_tblMFAdditionalBasisOtherCharges_intConcurrencyId] DEFAULT 0,
	intAdditionalBasisDetailId INT NOT NULL,
	intItemId INT NOT NULL,
	dblBasis NUMERIC(18, 6) NOT NULL,

	CONSTRAINT [PK_tblMFAdditionalBasisOtherCharges] PRIMARY KEY (intAdditionalBasisOtherChargesId), 
	CONSTRAINT [AK_tblMFAdditionalBasisOtherCharges_intAdditionalBasisDetailId_intItemId] UNIQUE (intAdditionalBasisDetailId, intItemId),
	CONSTRAINT [FK_tblMFAdditionalBasisOtherCharges_tblMFAdditionalBasisDetail] FOREIGN KEY (intAdditionalBasisDetailId) REFERENCES [tblMFAdditionalBasisDetail](intAdditionalBasisDetailId) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblMFAdditionalBasisOtherCharges_tblICItem] FOREIGN KEY (intItemId) REFERENCES [tblICItem](intItemId)
)
