PRINT N'BEGIN Dropping SQL Objects that are obsolete'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[vyuFRMColumnDescription]'))
	EXEC('DROP FUNCTION [dbo].[vyuFRMColumnDescription]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspFRMColumnDescription]'))
	EXEC('DROP FUNCTION [dbo].[uspFRMColumnDescription]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[vyuSMOriginColumn]'))
	EXEC('DROP FUNCTION [dbo].[vyuSMOriginColumn]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[vyuSMOriginTable]'))
	EXEC('DROP FUNCTION [dbo].[vyuSMOriginTable]')

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[uspSMMigrateUserEntity]'))
	EXEC('DROP FUNCTION [dbo].[uspSMMigrateUserEntity]')