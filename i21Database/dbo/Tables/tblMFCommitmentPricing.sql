CREATE TABLE tblMFCommitmentPricing
(
	intCommitmentPricingId INT IDENTITY(1,1) NOT NULL,
	intConcurrencyId INT CONSTRAINT [DF_tblMFCommitmentPricing_intConcurrencyId] DEFAULT 0,
	strPricingNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	intEntityId INT,
	dtmDeliveryFrom DATETIME,
	dtmDeliveryTo DATETIME,
	intUnitMeasureId INT,
	intCurrencyId INT,
	dtmDate DATETIME NOT NULL,
	dtmM2MBasisDate DATETIME,
	dtmAdditionalBasisDate DATETIME,
	strERPNo NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	dblBalanceQty NUMERIC(18, 6),
	strComment NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dblMarketArbitrage NUMERIC(18, 6),

	[dtmCreated] DATETIME, 
    [intCreatedUserId] INT,
	[dtmLastModified] DATETIME, 
    [intLastModifiedUserId] INT,
	
	CONSTRAINT [PK_tblMFCommitmentPricing] PRIMARY KEY (intCommitmentPricingId),
	CONSTRAINT [FK_tblMFCommitmentPricing_tblEMEntity] FOREIGN KEY (intEntityId) REFERENCES tblEMEntity(intEntityId), 
	CONSTRAINT [FK_tblMFCommitmentPricing_tblICUnitMeasure] FOREIGN KEY (intUnitMeasureId) REFERENCES tblICUnitMeasure(intUnitMeasureId),
	CONSTRAINT [FK_tblMFCommitmentPricing_tblSMCurrency] FOREIGN KEY (intCurrencyId) REFERENCES tblSMCurrency(intCurrencyID)
)
