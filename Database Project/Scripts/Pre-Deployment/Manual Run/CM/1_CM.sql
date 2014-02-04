IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'apcbkmst' and TABLE_TYPE = N'BASE TABLE')
BEGIN
	EXEC sp_rename 'apcbkmst', 'apcbkmst_origin'
END

GO

IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'apchkmst' and TABLE_TYPE = N'BASE TABLE')
BEGIN
	EXEC sp_rename 'apchkmst', 'apchkmst_origin'
END
GO

