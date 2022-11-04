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
		INSERT INTO tblCRMHubspotConfig (
			strHsClientId,
			strHsClientSecret, 
			strHsInstallationUrl, 
			strHsTokenUrl,
			strHsApiUrl,
			strHsi21RedirectUrl, 
			strHsi21AuthorizeUrl, 
			strHsRefreshToken,
			strScopesId,
			intConcurrencyId
		) 
		VALUES (
			'9caabd67-35fa-4883-86f6-3a941d350439',
			'ea8ce734-02de-4224-9502-2d7499a2a687', 
			'https://app.hubspot.com/oauth/authorize', 
			'https://api.hubapi.com/oauth/v1/token',
			'https://api.hubapi.com',
			'https://helpdesk.irely.com/irelyi21Live/authenticatehubspot', 
			null,
			null, 
			'1,2',
			1
		)
	END

	IF NOT EXISTS (SELECT * FROM tblCRMHubspotScope WHERE strScope = 'crm.objects.companies.read')
	BEGIN
		INSERT INTO tblCRMHubspotScope (strScope, strDescription, ysnEnabled, intConcurrencyId) VALUES ('crm.objects.companies.read', 'Read companies', 1, 1)
	END

	IF NOT EXISTS (SELECT * FROM tblCRMHubspotScope WHERE strScope = 'crm.objects.companies.read')
	BEGIN
		INSERT INTO tblCRMHubspotScope (strScope, strDescription, ysnEnabled, intConcurrencyId) VALUES ('crm.objects.contacts.read', 'Read contacts', 1, 1)
	END

GO
	PRINT N'End setting defaults for CRM Hubspot configs.';
GO