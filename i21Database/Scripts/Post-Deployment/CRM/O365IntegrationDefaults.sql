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

GO
	PRINT N'Begin setting defaults for SM company preference on Office 365 integration.';
GO

	IF (SELECT strO365OnlineMeetingProvider FROM tblSMCompanyPreference) IS NULL
		BEGIN
			UPDATE tblSMCompanyPreference SET strO365OnlineMeetingProvider = 'teamsForBusiness'
		END

	IF (SELECT strO365TimeZone FROM tblSMCompanyPreference) IS NULL
		BEGIN
			UPDATE tblSMCompanyPreference SET strO365TimeZone = 'UTC'
		END

GO
	PRINT N'End setting defaults for SM company preference on Office 365 integration.';
GO