CREATE VIEW [dbo].[vyuHDEmailSetup]
	AS
	select top 1
		intEmailSetupId = tblSMCompanyPreference.intCompanyPreferenceId
		,strFromEmail = tblSMCompanyPreference.strSMTPFromEmail
		,strFromName = tblHDSetting.strFromName
		,strSubjectPrefix = tblHDSetting.strSubjectPrefix
		,strSMTPServer = tblSMCompanyPreference.strSMTPHost
		,intSMTPPort = tblSMCompanyPreference.intSMTPPort
		,strEncryptedConnection = tblSMCompanyPreference.strSMTPSsl
		,ysnRequiresAuthentication = convert(bit, 1)
		,strUserName = tblSMCompanyPreference.strSMTPUserName
		,strPassword = tblSMCompanyPreference.strSMTPPassword
		,intConcurrencyId = tblSMCompanyPreference.intConcurrencyId
	from
		tblHDSetting
		,tblSMCompanyPreference
