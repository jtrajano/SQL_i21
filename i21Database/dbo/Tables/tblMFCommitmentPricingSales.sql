CREATE TABLE tblMFCommitmentPricingSales
(
	intCommitmentPricingSalesId INT NOT NULL IDENTITY,
	intConcurrencyId INT CONSTRAINT [DF_tblMFCommitmentPricingSales_intConcurrencyId] DEFAULT 0,
	intCommitmentPricingId INT NOT NULL,
	intContractDetailId INT NOT NULL,
	dtmStartDate DATETIME NOT NULL,
	dtmEndDate DATETIME NOT NULL,
	intFutureMarketId INT,
	dblNoOfLots NUMERIC(18, 6),
	dblQuantity NUMERIC(18, 6),
	dblFutures NUMERIC(18, 6),
	dblFXPrice NUMERIC(18, 6),
	dblRefPrice NUMERIC(18, 6),
	dblRefPriceInPriceUOM NUMERIC(18, 6),
	intBookId INT,
	intSubBookId INT,
	intSequenceNo INT,
	
	CONSTRAINT [PK_tblMFCommitmentPricingSales] PRIMARY KEY (intCommitmentPricingSalesId),
	CONSTRAINT [FK_tblMFCommitmentPricingSales_tblMFCommitmentPricing] FOREIGN KEY (intCommitmentPricingId) REFERENCES tblMFCommitmentPricing(intCommitmentPricingId) ON DELETE CASCADE,
	CONSTRAINT [FK_tblMFCommitmentPricingSales_tblCTContractDetail] FOREIGN KEY (intContractDetailId) REFERENCES tblCTContractDetail(intContractDetailId),
	CONSTRAINT [FK_tblMFCommitmentPricingSales_tblRKFutureMarket] FOREIGN KEY (intFutureMarketId) REFERENCES tblRKFutureMarket(intFutureMarketId),
	CONSTRAINT [FK_tblMFCommitmentPricingSales_tblCTBook] FOREIGN KEY (intBookId) REFERENCES tblCTBook(intBookId),
	CONSTRAINT [FK_tblMFCommitmentPricingSales_tblCTSubBook] FOREIGN KEY (intSubBookId) REFERENCES tblCTSubBook(intSubBookId)
)
