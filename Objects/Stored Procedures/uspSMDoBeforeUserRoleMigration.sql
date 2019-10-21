CREATE PROCEDURE [dbo].[uspSMDoBeforeUserRoleMigration]
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

	declare @doingMigration bit
	declare @migrationStarted datetime


	select top 1 
		@doingMigration = ysnDoingMigration, 
		@migrationStarted = isnull(dtmMigrationStarted, getdate())
	from tblSMCompanySetup

	if @doingMigration = 1 and DATEDIFF(HOUR, @migrationStarted, getdate()) >= 5
	begin
		update tblSMCompanySetup set ysnDoingMigration = 0
	end

	if(isnull(@doingMigration,0) = 0)
	begin
		
		delete from tblSMInterDatabaseUserRole
		delete from tblSMInterDatabaseUserRoleMenu
		delete from tblSMInterDatabaseUserRoleScreenPermission
		delete from tblSMInterDatabaseUserRoleControlPermission
		delete from tblSMInterDatabaseScreen
		delete from tblSMInterDatabaseControl
		delete from tblSMInterDatabaseUserRoleSubRole
		
		update tblSMCompanySetup set ysnDoingMigration = 1, [dtmMigrationStarted] = getdate()
	end
	
    
END


