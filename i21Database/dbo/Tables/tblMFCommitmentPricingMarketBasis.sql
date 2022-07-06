CREATE TABLE tblMFCommitmentPricingMarketBasis
(
	intCommitmentPricingMarketBasisId INT NOT NULL IDENTITY,
	intConcurrencyId INT CONSTRAINT [DF_tblMFCommitmentPricingMarketBasis_intConcurrencyId] DEFAULT 0,
	intCommitmentPricingId INT NOT NULL,
	intItemId INT NOT NULL,
	dblTotalCost NUMERIC(18, 6),
	dblBasis NUMERIC(18, 6),
	dblAdditionalBasis NUMERIC(18, 6),
	intCurrencyId INT,
	intUnitMeasureId INT,
	
	CONSTRAINT [PK_tblMFCommitmentPricingMarketBasis] PRIMARY KEY (intCommitmentPricingMarketBasisId),
	CONSTRAINT [FK_tblMFCommitmentPricingMarketBasis_tblMFCommitmentPricing] FOREIGN KEY (intCommitmentPricingId) REFERENCES tblMFCommitmentPricing(intCommitmentPricingId) ON DELETE CASCADE,
	CONSTRAINT [FK_tblMFCommitmentPricingMarketBasis_tblICItem] FOREIGN KEY (intItemId) REFERENCES tblICItem(intItemId),
	CONSTRAINT [FK_tblMFCommitmentPricingMarketBasis_tblSMCurrency] FOREIGN KEY (intCurrencyId) REFERENCES tblSMCurrency(intCurrencyID),
	CONSTRAINT [FK_tblMFCommitmentPricingMarketBasis_tblICUnitMeasure] FOREIGN KEY (intUnitMeasureId) REFERENCES tblICUnitMeasure(intUnitMeasureId)
)
