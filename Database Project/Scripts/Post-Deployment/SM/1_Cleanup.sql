
-- tblSMBuildNumber needs to be dropped on 13.4 because this will not be used until 14.1
-- dropping this ensures smooth 14.1 database update

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblSMBuildNumber]') AND type in (N'U'))
BEGIN
	DROP TABLE tblSMBuildNumber
END
