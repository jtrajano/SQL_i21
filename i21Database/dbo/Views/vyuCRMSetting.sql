CREATE VIEW [dbo].[vyuCRMSetting]
AS 
SELECT
	S.intCrmSettingId
	,S.strSignatureFormat
	,HC.intHubspotConfigId
	,CF.ysnHubspotIntegration
	,HC.strHsClientId
	,HC.strHsClientSecret
	,HC.strHsInstallationUrl
	,HC.strHsTokenUrl
	,HC.strHsApiUrl
	,HC.strHsi21RedirectUrl
	,HC.strHsi21AuthorizeUrl
	,HC.strHsRefreshToken
	,HC.strScopesId
FROM            
	[dbo].[tblCRMSetting] AS S,
    [dbo].[tblCRMHubspotConfig] AS HC,
	[dbo].[tblSMCompanyPreference] AS CF
