CREATE TABLE dbo.tblCTApiItemContractDetailStaging
(
	intApiItemContractDetailStagingId INT NOT NULL IDENTITY(1, 1),
	intApiItemContractStagingId INT NOT NULL,
	intItemId INT NULL,
	intLineNo INT NULL,
	strContractStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	dtmDeliveryDate DATETIME NULL,
	dtmLastDeliveryDate DATETIME NULL,
	dblContracted NUMERIC(18, 6) NULL,
	dblScheduled NUMERIC(18, 6) NULL,
	dblAvailable NUMERIC(18, 6) NULL,
	dblApplied NUMERIC(18, 6) NULL,
	dblBalance NUMERIC(18, 6) NULL,
	dblTax NUMERIC(18, 6) NULL,
	dblPrice NUMERIC(18, 6) NULL,
	dblTotal NUMERIC(18, 6) NULL,
	intItemUOMId INT NULL,
	intTaxGroupId INT NULL,
	CONSTRAINT PK_tblCTApiItemContractDetailStaging_intApiItemContractDetailStagingId PRIMARY KEY (intApiItemContractDetailStagingId),
	CONSTRAINT FK_tblCTApiItemContractDetailStaging_intApiItemContractStagingId FOREIGN KEY (intApiItemContractStagingId) 
		REFERENCES tblCTApiItemContractStaging (intApiItemContractStagingId) ON DELETE CASCADE
)