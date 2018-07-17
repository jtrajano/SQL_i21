/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

DECLARE @intScreenId INT;

--IF((SELECT COUNT(*) FROM tblSMScreen WHERE strScreenName = 'Load Schedule') > 0)
IF EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strScreenName = 'Load Schedule')
	BEGIN
		SET @intScreenId = (SELECT TOP 1 intScreenId FROM tblSMScreen WHERE strScreenName = 'Load Schedule')
		
		DELETE FROM tblSMCustomTabDetail WHERE intCustomTabId = (SELECT TOP 1 intCustomTabId FROM tblSMCustomTab WHERE intScreenId = @intScreenId)
		DELETE FROM tblSMCustomTab WHERE intScreenId = @intScreenId
		DELETE FROM tblSMTransaction WHERE intScreenId = @intScreenId
		DELETE FROM tblSMScreen WHERE intScreenId = @intScreenId
		PRINT 'Load Schedule Resources Deleted'
	END