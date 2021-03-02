﻿CREATE TABLE tblMFCommitmentPricing
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
	intM2MBasisId INT,
	intAdditionalBasisId INT,
	strERPNo NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	dblBalanceQty NUMERIC(18, 6),
	strComment NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dblMarketArbitrage NUMERIC(18, 6),
	ysnPost BIT CONSTRAINT [DF_tblMFCommitmentPricing_ysnPost] DEFAULT 0,

	[dtmCreated] DATETIME, 
    [intCreatedUserId] INT,
	[dtmLastModified] DATETIME, 
    [intLastModifiedUserId] INT,
	
	CONSTRAINT [PK_tblMFCommitmentPricing] PRIMARY KEY (intCommitmentPricingId),
	CONSTRAINT [FK_tblMFCommitmentPricing_tblEMEntity] FOREIGN KEY (intEntityId) REFERENCES tblEMEntity(intEntityId), 
	CONSTRAINT [FK_tblMFCommitmentPricing_tblICUnitMeasure] FOREIGN KEY (intUnitMeasureId) REFERENCES tblICUnitMeasure(intUnitMeasureId),
	CONSTRAINT [FK_tblMFCommitmentPricing_tblSMCurrency] FOREIGN KEY (intCurrencyId) REFERENCES tblSMCurrency(intCurrencyID),
	CONSTRAINT [FK_tblMFCommitmentPricing_tblRKM2MBasis] FOREIGN KEY (intM2MBasisId) REFERENCES tblRKM2MBasis(intM2MBasisId),
	CONSTRAINT [FK_tblMFCommitmentPricing_tblMFAdditionalBasis] FOREIGN KEY (intAdditionalBasisId) REFERENCES tblMFAdditionalBasis(intAdditionalBasisId)
)
