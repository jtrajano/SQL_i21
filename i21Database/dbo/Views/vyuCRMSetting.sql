CREATE VIEW [dbo].[vyuCRMSetting]
AS 
SELECT
	S.intCrmSettingId
	,S.strSignatureFormat
	,HC.intHubspotConfigId
	,CF.ysnHubspotIntegration
	,HC.strHsClientId
	,HC.strHsClientSecret
	,HC.strHsRedirectUrl
	,HC.strHsRefreshToken
	,HC.strScopesId
FROM            
	[dbo].[tblCRMSetting] AS S,
    [dbo].[tblCRMHubspotConfig] AS HC,
	[dbo].[tblSMCompanyPreference] AS CF
