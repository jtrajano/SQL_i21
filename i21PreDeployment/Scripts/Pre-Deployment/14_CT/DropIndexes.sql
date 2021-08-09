-- Drop the following indexes to force the system to re-generate it during install. 
IF EXISTS (SELECT * FROM sys.indexes WHERE name='IX_tblCTPriceFixation_intPriceContractId' AND object_id = OBJECT_ID('dbo.tblCTPriceFixation'))
	DROP INDEX [IX_tblCTPriceFixation_intPriceContractId] ON tblCTPriceFixation 
GO