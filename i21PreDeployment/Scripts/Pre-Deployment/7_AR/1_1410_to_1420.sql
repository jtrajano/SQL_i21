
PRINT N'BEGIN Rename for tblEntities'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEntities]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'tblEMEntity'))
    BEGIN
        EXEC sp_rename 'tblEntities', 'tblEMEntity'
    END
END
GO
PRINT N'END	 Rename for tblEntities'
GO

PRINT N'Begin Rename for tblEMEntityLocations'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEMEntityLocations]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'tblEMEntityLocation'))
    BEGIN
        EXEC sp_rename 'tblEMEntityLocations', 'tblEMEntityLocation'
    END
END
GO
PRINT N'END	 Rename for tblEMEntityLocations'
GO

PRINT N'BEGIN Rename for tblEMEntityTypes'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEMEntityTypes]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'tblEMEntityType'))
    BEGIN
        EXEC sp_rename 'tblEMEntityTypes', 'tblEMEntityType'
    END
END
GO
PRINT N'END	 Rename for tblEMEntityLocations'
GO
