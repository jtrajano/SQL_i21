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
	,S.intFreightTermId
	,FT.strFreightTerm
FROM            
	[dbo].[tblCRMSetting] AS S
		LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = S.intFreightTermId,
    [dbo].[tblCRMHubspotConfig] AS HC,
	[dbo].[tblSMCompanyPreference] AS CF
