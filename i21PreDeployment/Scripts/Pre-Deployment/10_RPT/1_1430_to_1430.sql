
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
