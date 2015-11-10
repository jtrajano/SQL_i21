GO
PRINT 'Drop tblSMUserSecurity Trigger_tblSMUserSecurity'
IF OBJECTPROPERTY(OBJECT_ID('Trigger_tblSMUserSecurity'), 'IsTrigger') = 1
BEGIN
	PRINT 'Dropping tblSMUserSecurity Trigger_tblSMUserSecurity'
	EXEC('DROP TRIGGER Trigger_tblSMUserSecurity')
END
PRINT 'Dropped tblSMUserSecurity Trigger_tblSMUserSecurity'
GO