GO
UPDATE tblCTSequenceUsageHistory SET strFieldName = REPLACE(strFieldName,'Quantiy','Quantity')
GO

GO
UPDATE tblCTContractHeader SET dtmCreated = dtmContractDate WHERE dtmCreated IS NULL
GO