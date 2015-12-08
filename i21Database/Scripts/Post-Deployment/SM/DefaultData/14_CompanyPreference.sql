IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCompanyPreference)
	BEGIN
		DECLARE @companySetupId INT
		SELECT TOP 1 @companySetupId = intCompanySetupID FROM tblSMCompanySetup ORDER BY intCompanySetupID ASC

		INSERT INTO tblSMCompanyPreference(intDefaultCurrencyId, intDefaultReportingCurrencyId, intDefaultCountryId, strEnvironmentType, ysnLegacyIntegration, 
		strSourceSystem, strAccountingMethod, strSMTPHost, intSMTPPort, strSMTPUserName, strSMTPPassword, strSMTPFromEmail, strSMTPFromName, ysnSMTPAuthentication,
		strSMTPSsl, intInterfaceSystemId, strQuotingSystemBatchUserID, strQuotingSystemBatchUserPassword, strInterfaceWebServicesURL, ysnAllowForContractPricing,
		ysnInterfaceToTargetOrders, ysnAllowUseForClosingPrices, ysnAllowUseForEndOfMonth, ysnInterfaceToScales, intSaveHistoryEveryId, strIntervalStartTime,
		strIntervalEndTime, strIntervalUpdatesMinutes, strQuotesDecimalsShown, strHelperUrlDomain, ysnEnableCreditCardProcessing, strMerchantId, strMerchantPassword, strPaymentServer, intCompanySetupId)
		VALUES(0, 0, 0, 'Production', 0, 'Summit', '', '', 0, '', '', '', '', 0, 'None', 0, '', '', '', 0, 0, 0, 0, 0, 0, '','', '', '', '', 0, '', '', '', @companySetupId)
	END
ELSE
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM tblSMCompanyPreference WHERE intDefaultCurrencyId = 0)
		BEGIN
			UPDATE tblSMCompanyPreference SET intDefaultCurrencyId = NULL WHERE intCompanyPreferenceId = 1
		END

		IF EXISTS(SELECT TOP 1 1 FROM tblSMCompanyPreference WHERE intDefaultReportingCurrencyId = 0)
		BEGIN
			UPDATE tblSMCompanyPreference SET intDefaultReportingCurrencyId = NULL WHERE intCompanyPreferenceId = 1
		END

		IF EXISTS(SELECT TOP 1 1 FROM tblSMCompanyPreference WHERE intDefaultCountryId = 0)
		BEGIN
			UPDATE tblSMCompanyPreference SET intDefaultCountryId = NULL WHERE intCompanyPreferenceId = 1
		END

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

		IF EXISTS(SELECT TOP 1 intCompanySetupID FROM tblSMCompanySetup)
		BEGIN
			UPDATE tblSMCompanyPreference SET intCompanySetupId = (SELECT TOP 1 intCompanySetupID FROM tblSMCompanySetup ORDER BY intCompanySetupID ASC)
		END
	END


