CREATE TABLE [dbo].[tblCTAOPDetail]
(
	intAOPDetailId int IDENTITY(1,1) NOT NULL,
	intAOPId int NOT NULL,
	intCommodityId INT,
	intItemId INT,
	intBasisItemId INT,
	dblVolume NUMERIC(18,6),
	dblCost NUMERIC(18,6),
	intVolumeUOMId INT,
    intCurrencyId int NULL,
	intWeightUOMId INT,
	intPriceUOMId INT,
	intConcurrencyId INT NOT NULL, 

	CONSTRAINT PK_tblCTAOPDetail_intAOPDetailId PRIMARY KEY CLUSTERED (intAOPDetailId ASC),
	CONSTRAINT UQ_tblCTAOPDetail_intAOPId_intItemId_intBasisItemId UNIQUE (intAOPId,intItemId,intBasisItemId),
	CONSTRAINT FK_tblCTAOPDetail_tblCTAOP_intAOPId FOREIGN KEY (intAOPId) REFERENCES tblCTAOP(intAOPId) ON DELETE CASCADE,
	
	CONSTRAINT FK_tblCTAOPDetail_tblICCommodity_intCommodityId FOREIGN KEY (intCommodityId) REFERENCES tblICCommodity(intCommodityId),
	CONSTRAINT FK_tblCTAOPDetail_tblICItem_intItemId FOREIGN KEY (intItemId) REFERENCES tblICItem(intItemId),
	CONSTRAINT FK_tblCTAOPDetail_tblICItem_intBasisItemId_intItemId FOREIGN KEY (intBasisItemId) REFERENCES tblICItem(intItemId),

	CONSTRAINT FK_tblCTAOPDetail_tblICItemUOM_intVolumeUOMId_intItemUOMId FOREIGN KEY (intVolumeUOMId) REFERENCES tblICItemUOM(intItemUOMId),
	CONSTRAINT [FK_tblCTAOPDetail_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT FK_tblCTAOPDetail_tblICItemUOM_intWeightUOMId_intItemUOMId FOREIGN KEY (intWeightUOMId) REFERENCES tblICItemUOM(intItemUOMId),
	CONSTRAINT FK_tblCTAOPDetail_tblICItemUOM_intPriceUOMId_intItemUOMId FOREIGN KEY (intPriceUOMId) REFERENCES tblICItemUOM(intItemUOMId)
)
