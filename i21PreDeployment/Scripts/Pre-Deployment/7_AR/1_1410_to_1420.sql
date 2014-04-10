
PRINT N'BEGIN Rename for tblEntities'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEntities]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'tblEntity'))
    BEGIN
        EXEC sp_rename 'tblEntities', 'tblEntity'
    END
END
GO
PRINT N'END	 Rename for tblEntities'
GO

PRINT N'Begin Rename for tblEntityLocations'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEntityLocations]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'tblEntityLocation'))
    BEGIN
        EXEC sp_rename 'tblEntityLocations', 'tblEntityLocation'
    END
END
GO
PRINT N'END	 Rename for tblEntityLocations'
GO

PRINT N'BEGIN Rename for tblEntityTypes'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEntityTypes]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'tblEntityType'))
    BEGIN
        EXEC sp_rename 'tblEntityTypes', 'tblEntityType'
    END
END
GO
PRINT N'END	 Rename for tblEntityLocations'
GO
