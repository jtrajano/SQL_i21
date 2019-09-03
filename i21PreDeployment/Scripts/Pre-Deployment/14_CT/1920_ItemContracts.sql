
--=====================================================================================================================================
-- 	DROP ysnPrepaid IN TBLCTCONTRACTHEADER
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN UPDATE'
GO


IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'ysnPrepaid' AND OBJECT_ID = OBJECT_ID(N'tblCTItemContractHeader')) 
BEGIN
     ALTER TABLE tblCTItemContractHeader DROP COLUMN ysnPrepaid
END

GO
	PRINT N'END UPDATE'
GO

PRINT('Contract 1_MasterTables End')