CREATE TABLE dbo.tblCTApiDollarContractDetailStaging
(
	intApiDollarContractDetailStagingId INT NOT NULL IDENTITY(1, 1),
	intApiItemContractStagingId INT NOT NULL,
	intCategoryId INT NOT NULL,
	CONSTRAINT PK_tblCTApiDollarContractDetailStaging_intApiDollarContractDetailStagingId PRIMARY KEY (intApiDollarContractDetailStagingId),
	CONSTRAINT FK_tblCTApiDollarContractDetailStaging_intApiItemContractStagingId FOREIGN KEY (intApiItemContractStagingId) 
		REFERENCES tblCTApiItemContractStaging (intApiItemContractStagingId) ON DELETE CASCADE
)