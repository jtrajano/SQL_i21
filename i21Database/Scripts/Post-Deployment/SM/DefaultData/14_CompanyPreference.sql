IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCompanyPreference)
BEGIN
	INSERT INTO tblSMCompanyPreference(intDefaultCurrencyId, intDefaultReportingCurrencyId, intDefaultCountryId, ysnLegacyIntegration, 
	strAccountingMethod, strSMTPHost, intSMTPPort, strSMTPUserName, strSMTPPassword, strSMTPFromEmail, strSMTPFromName, ysnSMTPAuthentication,
	strSMTPSsl, intInterfaceSystemId, strQuotingSystemBatchUserID, strQuotingSystemBatchUserPassword, strInterfaceWebServicesURL, ysnAllowForContractPricing,
	ysnInterfaceToTargetOrders, ysnAllowUseForClosingPrices, ysnAllowUseForEndOfMonth, ysnInterfaceToScales, intSaveHistoryEveryId, strIntervalStartTime,
	strIntervalEndTime, strIntervalUpdatesMinutes, strQuotesDecimalsShown)
	VALUES(0, 0, 0, 0, '', '', 0, '', '', '', '', 0, '', 0, '', '', '', 0, 0, 0, 0, 0, 0, '','', '', '')
END

