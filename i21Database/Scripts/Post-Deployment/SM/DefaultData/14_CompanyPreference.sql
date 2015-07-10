IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCompanyPreference)
	BEGIN
		INSERT INTO tblSMCompanyPreference(intDefaultCurrencyId, intDefaultReportingCurrencyId, intDefaultCountryId, strEnvironmentType, ysnLegacyIntegration, 
		strSourceSystem, strAccountingMethod, strSMTPHost, intSMTPPort, strSMTPUserName, strSMTPPassword, strSMTPFromEmail, strSMTPFromName, ysnSMTPAuthentication,
		strSMTPSsl, intInterfaceSystemId, strQuotingSystemBatchUserID, strQuotingSystemBatchUserPassword, strInterfaceWebServicesURL, ysnAllowForContractPricing,
		ysnInterfaceToTargetOrders, ysnAllowUseForClosingPrices, ysnAllowUseForEndOfMonth, ysnInterfaceToScales, intSaveHistoryEveryId, strIntervalStartTime,
		strIntervalEndTime, strIntervalUpdatesMinutes, strQuotesDecimalsShown, strHelperUrlDomain)
		VALUES(0, 0, 0, 'Production', 0, 'Summit', '', '', 0, '', '', '', '', 0, 'None', 0, '', '', '', 0, 0, 0, 0, 0, 0, '','', '', '', '')
	END
ELSE
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM tblSMCompanyPreference WHERE strEnvironmentType = '')
		BEGIN
			UPDATE tblSMCompanyPreference SET strEnvironmentType = 'Production' WHERE intCompanyPreferenceId = 1
		END

		IF EXISTS(SELECT TOP 1 1 FROM tblSMCompanyPreference WHERE strSMTPSsl = '')
		BEGIN
			UPDATE tblSMCompanyPreference SET strSMTPSsl = 'None' WHERE intCompanyPreferenceId = 1
		END

		IF EXISTS(SELECT TOP 1 1 FROM tblSMCompanyPreference WHERE strSourceSystem = '')
		BEGIN
			UPDATE tblSMCompanyPreference SET strSourceSystem = 'Summit' WHERE intCompanyPreferenceId = 1
		END
	END


