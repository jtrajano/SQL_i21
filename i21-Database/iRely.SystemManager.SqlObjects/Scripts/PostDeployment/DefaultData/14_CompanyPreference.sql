PRINT N'COMPANY PREFERENCE DEFAULT DATA'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCompanyPreference)
BEGIN
	DECLARE @companySetupId INT
	SELECT TOP 1 @companySetupId = intCompanySetupID FROM tblSMCompanySetup ORDER BY intCompanySetupID ASC

	DECLARE @multiCurrencyId INT
	SELECT TOP 1 @multiCurrencyId = intMultiCurrencyId FROM tblSMMultiCurrency ORDER BY intMultiCurrencyId ASC

	INSERT INTO tblSMCompanyPreference(intDefaultCurrencyId, intDefaultReportingCurrencyId, intDefaultCountryId, strEnvironmentType, ysnLegacyIntegration, 
	strSourceSystem, strAccountingMethod, strSMTPHost, intSMTPPort, strSMTPUserName, strSMTPPassword, strSMTPFromEmail, strSMTPFromName, ysnSMTPAuthentication,
	strSMTPSsl, intInterfaceSystemId, strQuotingSystemBatchUserID, strQuotingSystemBatchUserPassword, strInterfaceWebServicesURL, ysnAllowForContractPricing,
	ysnInterfaceToTargetOrders, ysnAllowUseForClosingPrices, ysnAllowUseForEndOfMonth, ysnInterfaceToScales, intSaveHistoryEveryId, strIntervalStartTime,
	strIntervalEndTime, strIntervalUpdatesMinutes, strQuotesDecimalsShown, strHelperUrlDomain, ysnEnableCreditCardProcessing, strMerchantId, strMerchantPassword, 
	strPaymentServer, [intCurrencyDecimal], [intLockedRecordExpiration], [ysnValidatePassword], [intMultiCurrencyId], intCompanySetupId)
	VALUES(0, 0, 0, 'Production', 0, 'Summit', '', '', 0, '', '', '', '', 0, 'None', 0, '', '', '', 0, 0, 0, 0, 0, 0, '','', '', '', '', 0, '', '', '', 2, '', '', @multiCurrencyId, @companySetupId)
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

	IF EXISTS(SELECT TOP 1 1 FROM tblSMCompanyPreference WHERE intCurrencyDecimal IS NULL)
	BEGIN
		UPDATE tblSMCompanyPreference SET intCurrencyDecimal = 2 WHERE intCurrencyDecimal IS NULL
	END

	IF EXISTS(SELECT TOP 1 intCompanySetupID FROM tblSMCompanySetup)
	BEGIN
		UPDATE tblSMCompanyPreference SET intCompanySetupId = (SELECT TOP 1 intCompanySetupID FROM tblSMCompanySetup ORDER BY intCompanySetupID ASC)
	END

	IF EXISTS(SELECT TOP 1 intMultiCurrencyId FROM tblSMMultiCurrency)
	BEGIN
		UPDATE tblSMCompanyPreference SET intMultiCurrencyId = (SELECT TOP 1 intMultiCurrencyId FROM tblSMMultiCurrency ORDER BY intMultiCurrencyId ASC)
	END
END


