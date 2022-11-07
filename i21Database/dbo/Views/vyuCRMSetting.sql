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
	,S.intFreightTermId
	,FT.strFreightTerm
FROM            
	[dbo].[tblCRMSetting] AS S
		LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = S.intFreightTermId,
    [dbo].[tblCRMHubspotConfig] AS HC,
	[dbo].[tblSMCompanyPreference] AS CF
