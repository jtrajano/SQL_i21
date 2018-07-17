declare @build_m int
set @build_m = 0

if EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMBuildNumber' and [COLUMN_NAME] = 'strVersionNo')
BEGIN

	exec sp_executesql N'select top 1 @build_m = intVersionID from tblSMBuildNumber where cast(substring(strVersionNo,1,2) as float) >= 16 '  , 
		N'@build_m int output', @build_m output;
END
if @build_m = 0

BEGIN

	PRINT 'Drop tblSMUserSecurity Trigger_tblSMUserSecurity'
	IF OBJECTPROPERTY(OBJECT_ID('Trigger_tblSMUserSecurity'), 'IsTrigger') = 1
	BEGIN
		PRINT 'Dropping tblSMUserSecurity Trigger_tblSMUserSecurity'
		EXEC('DROP TRIGGER Trigger_tblSMUserSecurity')
	END
	PRINT 'Dropped tblSMUserSecurity Trigger_tblSMUserSecurity'

END
GO
