
--=====================================================================================================================================
-- 	UPDATE FIELDS OF REPORT CRITERIA TABLES
---------------------------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRMFilter]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFilterConcurrencyId' AND OBJECT_ID = OBJECT_ID(N'tblRMFilter')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDefaultFilterId' AND OBJECT_ID = OBJECT_ID(N'tblRMFilter'))
    BEGIN
        EXEC sp_rename 'tblRMFilter.intDefaultFilterId', 'intFilterConcurrencyId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRMOption]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intOptionConcurrencyId' AND OBJECT_ID = OBJECT_ID(N'tblRMOption')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDefaultOptionId' AND OBJECT_ID = OBJECT_ID(N'tblRMOption'))
    BEGIN
        EXEC sp_rename 'tblRMOption.intDefaultOptionId', 'intOptionConcurrencyId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRMSort]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intSortConcurrencyId' AND OBJECT_ID = OBJECT_ID(N'tblRMSort')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDefaultSortId' AND OBJECT_ID = OBJECT_ID(N'tblRMSort'))
    BEGIN
        EXEC sp_rename 'tblRMSort.intDefaultSortId', 'intSortConcurrencyId' , 'COLUMN'
    END
END
GO

--=====================MOTOR FUEL TAX CYCLE========================--
--This script will alter the data type for date fields from char(8) to int. This will also delete all records from pxcyctag table
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pxcyctag]') AND type in (N'U')) 
BEGIN
	DELETE FROM pxcyctag
	IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'pxcyctag_end_rev_dt' AND OBJECT_ID = OBJECT_ID(N'pxcyctag'))
    BEGIN
        ALTER TABLE pxcyctag 
		ALTER COLUMN pxcyctag_end_rev_dt int NULL 
    END
	IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'pxcyctag_beg_rev_dt' AND OBJECT_ID = OBJECT_ID(N'pxcyctag'))
    BEGIN
        ALTER TABLE pxcyctag 
		ALTER COLUMN pxcyctag_beg_rev_dt int NULL 
    END
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'A4GLIdentity' AND OBJECT_ID = OBJECT_ID(N'pxcyctag'))
    BEGIN
        ALTER TABLE pxcyctag 
		ADD A4GLIdentity NUMERIC(9, 0) NOT NULL IDENTITY
    END
END
GO

