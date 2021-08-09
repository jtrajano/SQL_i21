CREATE TABLE tblMFAdditionalBasisDetail
(
	intAdditionalBasisDetailId INT NOT NULL IDENTITY, 
	intConcurrencyId INT CONSTRAINT [DF_tblMFAdditionalBasisDetail_intConcurrencyId] DEFAULT 0,
	intAdditionalBasisId INT NOT NULL,
	intItemId INT NOT NULL,
	intCurrencyId INT,
	intItemUOMId INT,
		
	CONSTRAINT [PK_tblMFAdditionalBasisDetail] PRIMARY KEY (intAdditionalBasisDetailId), 
	CONSTRAINT [AK_tblMFAdditionalBasisDetail_intAdditionalBasisId_intItemId] UNIQUE (intAdditionalBasisId, intItemId),
	CONSTRAINT [FK_tblMFAdditionalBasisDetail_tblMFAdditionalBasis] FOREIGN KEY (intAdditionalBasisId) REFERENCES [tblMFAdditionalBasis](intAdditionalBasisId) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblMFAdditionalBasisDetail_tblICItem] FOREIGN KEY (intItemId) REFERENCES [tblICItem](intItemId),
	CONSTRAINT [FK_tblMFAdditionalBasisDetail_tblSMCurrency] FOREIGN KEY (intCurrencyId) REFERENCES [tblSMCurrency](intCurrencyID),
	CONSTRAINT [FK_tblMFAdditionalBasisDetail_tblICItemUOM] FOREIGN KEY (intItemUOMId) REFERENCES [tblICItemUOM](intItemUOMId)
)
