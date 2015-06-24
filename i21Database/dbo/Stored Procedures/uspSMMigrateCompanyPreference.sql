CREATE PROCEDURE [dbo].[uspSMMigrateCompanyPreference]
AS
IF NOT EXISTS(SELECT TOP 1 1 FROM tblCFCompanyPreference)
BEGIN

	EXEC('INSERT INTO tblCFCompanyPreference
		  (strCFServiceReminderMessage,
		  ysnCFUseSpecialPrices,
		  strCFUsePrice,
		  ysnCFUseContracts,
		  ysnCFSummarizeInvoice,
		  strCFInvoiceSummarizationLocation,
		  intConcurrencyId)
		  SELECT strCFServiceReminderMessage,
		  ysnCFUseSpecialPrices,
		  strCFUsePrice,
		  ysnCFUseContracts,
		  ysnCFSummarizeInvoice,
		  strCFInvoiceSummarizationLocation,
		  intConcurrencyId
		  FROM tblTEMPCompanyPreference')

	EXEC('DROP TABLE tblTEMPCompanyPreference')

	TRUNCATE TABLE tblSMCompanyPreference

	INSERT INTO tblSMCompanyPreference(intDefaultCurrencyId, intDefaultReportingCurrencyId, intDefaultCountryId, ysnLegacyIntegration, 
	strAccountingMethod, strSMTPHost, intSMTPPort, strSMTPUserName, strSMTPPassword, strSMTPFromEmail, strSMTPFromName, ysnSMTPAuthentication,
	strSMTPSsl, intInterfaceSystemId, strQuotingSystemBatchUserID, strQuotingSystemBatchUserPassword, strInterfaceWebServicesURL, ysnAllowForContractPricing,
	ysnInterfaceToTargetOrders, ysnAllowUseForClosingPrices, ysnAllowUseForEndOfMonth, ysnInterfaceToScales, intSaveHistoryEveryId, strIntervalStartTime,
	strIntervalEndTime, strIntervalUpdatesMinutes, strQuotesDecimalsShown)
	SELECT 
	ISNULL(defaultCurrency, 0) AS intDefaultCurrencyId,
	ISNULL(defaultReporting, 0) AS intDefaultReportingCurrencyId, 
	ISNULL(defaultCountry, 0) AS intDefaultCountryId,
	ISNULL(isLegacyIntegration, 0) AS ysnLegacyIntegration,
	ISNULL(AccountingMethod, '') AS strAccountingMethod,
	ISNULL(SMTPHost, '') AS strSMTPHost,
	ISNULL(SMTPPort, 0) AS intSMTPPort,
	ISNULL(SMTPUserName, '') AS strSMTPUserName,
	ISNULL(SMTPPassword, '') AS strSMTPPassword,
	ISNULL(SMTPFromEmail, '') AS strSMTPFromEmail,
	ISNULL(SMTPFromName, '') AS strSMTPFromName,
	ISNULL(SMTPAuthentication, 0) AS ysnSMTPAuthentication,
	ISNULL(SMTPSsl, '') AS strSMTPSsl,
	ISNULL(InterfaceSystem, 0) AS intInterfaceSystemId,
	ISNULL(QuotingSystemBatchUserID, '') AS strQuotingSystemBatchUserID,
	ISNULL(QuotingSystemBatchUserPassword, '') AS strQuotingSystemBatchUserPassword,
	ISNULL(InterfaceWebServicesURL, '') AS strInterfaceWebServicesURL,
	ISNULL(AllowforContractPricing, 0) AS ysnAllowForContractPricing,
	ISNULL(InterfaceToTargetOrders, 0) AS ysnInterfaceToTargetOrders,
	ISNULL(AllowuseforClosingPrice, 0) AS ysnAllowUseForClosingPrices,
	ISNULL(AllowuseforEndofMonth, 0) AS ysnAllowUseForEndOfMonth,
	ISNULL(InterfacetoScales, 0) AS ysnInterfaceToScales,
	ISNULL(SaveHistoryEvery, 0) AS intSaveHistoryEveryId,
	ISNULL(IntervalStartTime, '') AS strIntervalStartTime,
	ISNULL(IntervalEndTime, '') AS strIntervalEndTime,
	ISNULL(IntervalUpdatesMinutes, '') AS strIntervalUpdatesMinutes,
	ISNULL(QuotesDecimalsShown, '') AS strQuotesDecimalsShown
	FROM
	(
	  SELECT strValue, strPreference
	  FROM tblSMPreferences
	  WHERE intUserID = 0
	) d
	pivot
	(
	  MAX(strValue)
	  FOR strPreference in (defaultCountry, defaultReporting, defaultCurrency, isLegacyIntegration, AccountingMethod, SMTPHost, SMTPPort, 
							SMTPUserName, SMTPPassword, SMTPFromEmail, SMTPFromName, SMTPAuthentication, SMTPSsl, InterfaceSystem, 
							QuotingSystemBatchUserID, QuotingSystemBatchUserPassword, InterfaceWebServicesURL, AllowforContractPricing, 
							InterfaceToTargetOrders, AllowuseforClosingPrice, AllowuseforEndofMonth, InterfacetoScales, SaveHistoryEvery, 
							IntervalStartTime, IntervalEndTime, IntervalUpdatesMinutes, QuotesDecimalsShown)
	) piv

	DELETE FROM tblSMPreferences
	WHERE strPreference 
	IN ('defaultCountry', 'defaultReporting', 'defaultCurrency', 'isLegacyIntegration', 'AccountingMethod', 'SMTPHost', 'SMTPPort', 
		'SMTPUserName', 'SMTPPassword', 'SMTPFromEmail', 'SMTPFromName', 'SMTPAuthentication', 'SMTPSsl', 'InterfaceSystem', 
		'QuotingSystemBatchUserID', 'QuotingSystemBatchUserPassword, InterfaceWebServicesURL, AllowforContractPricing', 
		'InterfaceToTargetOrders', 'AllowuseforClosingPrice', 'AllowuseforEndofMonth', 'InterfacetoScales', 'SaveHistoryEvery', 
		'IntervalStartTime', 'IntervalEndTime', 'IntervalUpdatesMinutes', 'QuotesDecimalsShown') 
	AND intUserID = 0
END
