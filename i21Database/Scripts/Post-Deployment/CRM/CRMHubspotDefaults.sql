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
	PRINT N'Begin setting defaults for CRM Hubspot configs.';
GO

	IF NOT EXISTS (SELECT * FROM tblCRMHubspotConfig)
	BEGIN
		INSERT INTO tblCRMHubspotConfig VALUES (null, null, null, null, 1)
	END

	IF NOT EXISTS (SELECT * FROM tblCRMHubspotScope WHERE strScope = 'crm.objects.companies.read')
	BEGIN
		INSERT INTO tblCRMHubspotScope VALUES ('crm.objects.companies.read', 'Read companies', 1, 1)
	END

	IF NOT EXISTS (SELECT * FROM tblCRMHubspotScope WHERE strScope = 'crm.objects.companies.read')
	BEGIN
		INSERT INTO tblCRMHubspotScope VALUES ('crm.objects.contacts.read', 'Read contacts', 1, 1)
	END

GO
	PRINT N'End setting defaults for CRM Hubspot configs.';
GO