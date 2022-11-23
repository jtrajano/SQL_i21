﻿CREATE TABLE [dbo].[tblSMCompanyPreference]
(
	[intCompanyPreferenceId]						INT NOT NULL PRIMARY KEY IDENTITY,
    [intDefaultCurrencyId]							INT NULL,
    [intDefaultReportingCurrencyId]					INT NULL,
    [intDefaultCountryId]							INT NULL,
    [strEnvironmentType]							NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT (''),
    [ysnLegacyIntegration]							BIT NOT NULL,
	[ysnEasyAutomation]								BIT NOT NULL DEFAULT 0,
    [strSourceSystem]								NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT (''),
	[strAccountingMethod]							NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strSMTPHost]									NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
    [intSMTPPort]									INT NOT NULL,
    [strSMTPUserName]								NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
    [strSMTPPassword]								NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    [strSMTPFromEmail]								NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
    [strSMTPFromName]								NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
    [ysnSMTPAuthentication]							BIT NOT NULL,
    [strSMTPSsl]									NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [intInterfaceSystemId]							INT NOT NULL,
    [strQuotingSystemBatchUserID]					NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strQuotingSystemBatchUserPassword]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strAPIKey]										NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    [strInterfaceWebServicesURL]					NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
    [ysnAllowForContractPricing]					BIT NOT NULL,
	[ysnInterfaceToTargetOrders]					BIT NOT NULL,
    [ysnAllowUseForClosingPrices]					BIT NOT NULL,
    [ysnAllowUseForEndOfMonth]						BIT NOT NULL,
    [ysnInterfaceToScales]							BIT NOT NULL,
    [ysnInterCompany]								BIT NULL,
    [intSaveHistoryEveryId]							INT NOT NULL,
    [strIntervalStartTime]							NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strIntervalEndTime]							NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strIntervalUpdatesMinutes]						NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strQuotesDecimalsShown]						NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strHelperUrlDomain]							NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strNotificationEmailUrl]						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[ysnEnableCreditCardProcessing]					BIT NOT NULL DEFAULT 0,
	[strMerchantId]									NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strMerchantPassword]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strPaymentServer]								NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	[strCreditCardProcessingType]					NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
	[strPaymentExternalLink]						NVARCHAR(350) COLLATE Latin1_General_CI_AS NULL,
	[strPaymentPortal]								NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strCreditCardConvenienceFee]					NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL DEFAULT 'None',
	[dblVisaPercentage]								NUMERIC(18, 2),
	[dblMastercardPercentage]						NUMERIC(18, 2),
	[dblAmericanExpressPercentage]					NUMERIC(18, 2),
	[dblDiscoverPercentage]							NUMERIC(18, 2),
	[dblDinersClubPercentage]						NUMERIC(18, 2),
	[dblChinaUnionPayPercentage]					NUMERIC(18, 2),
	[dblVisaFixedAmount]							NUMERIC(18, 2),
	[dblMastercardFixedAmount]						NUMERIC(18, 2),
	[dblAmericanExpressFixedAmount]					NUMERIC(18, 2),
	[dblDiscoverFixedAmount]						NUMERIC(18, 2),
	[dblDinersClubFixedAmount]						NUMERIC(18, 2),
	[dblChinaUnionPayFixedAmount]					NUMERIC(18, 2),
	[intFeeGeneralLedgerAccountId]					INT NULL,
	[intPaymentsLocationId]							INT NULL,
	[intCurrencyDecimal]							INT NOT NULL DEFAULT 2,
	[intLockedRecordExpiration]						INT NOT NULL DEFAULT 60,
	[ysnValidatePassword]							BIT NOT NULL DEFAULT 0,
	[ysnAutoRefreshOnOpen]							BIT NOT NULL DEFAULT 0,
	[intAnnouncementFontColorId]					INT NULL,
	[intAnnouncementBackgroundColorId]				INT NULL,
	[intDefaultTermId]								INT NULL,
	[strReportDateFormat]							NVARCHAR(15) COLLATE Latin1_General_CI_AS NULL,
	[strReportNumberFormat]							NVARCHAR(15) COLLATE Latin1_General_CI_AS NULL,
    [strFTPHost]									NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [intFTPPort]									INT NULL,
    [strFTPProtocol]								NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strFTPLogOnType]								NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strFTPUser]									NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strFTPPassword]								NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strFTPKeyFilePath]								NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strFTPPassphrase]								NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strFTPHostKeyFingerPrint]						NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
	[strFTPExportValidURL]							NVARCHAR (MAX) NULL,
    [intCompanySetupId]								INT NOT NULL,
	[intMultiCurrencyId]							INT NULL,
    [intPDFExportLimit]								INT NOT NULL DEFAULT(10000),
	[ysnADEnabled]									BIT NOT NULL DEFAULT 0,
	[strADDomain]									NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strADGroup]									NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strADUserName]									NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    [strADPassword]									NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[ysnEnableUserActivityLog]						BIT NOT NULL DEFAULT 0,
	[strPowerBIAdminUsername]						NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	[strPowerBIAdminPassword]						NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	[strPowerBIClientId]							NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strPowerBISecretId]							NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strPowerBIWorkspaceId]							NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strPowerBITenantId]							NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strPowerBIProfileId]							NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strPowerBIProfileName]							NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	[strPowerBIProfileWorkspaceId]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strPowerBIProfileWorkspaceName]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strPowerBIServicePrincipalId]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strIDPDefaultModel]							NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	[strIDPDefaultModelId]							NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	[strIDPSasURI]									NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strIDPEndpointURI]								NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	[strIDPApiKey]									NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    [strAzureApplicationInsightsInstrumentationKey] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[ysnExportDataProcessEnabled]					BIT NOT NULL DEFAULT 0,
	[strExportFilePath]								NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
	[ysnUseAzureBlob]								BIT NOT NULL DEFAULT 0,
	[strAzureLink]									NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strAzureContainer]								NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strAzureReference]								NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
    [strApiHostUrl] 								NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL,
    [ysnLogPerformanceRuntime]                      BIT NOT NULL DEFAULT 0,
    [dtmPerformanceLoggingEffectivity]              DATETIME NULL,
    [strMonitorId] 				    				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [ysnHubspotIntegration]							BIT NOT NULL DEFAULT 0,
	[ysnEnableFrontEndMonitoring]                   BIT NOT NULL DEFAULT 0,
    [intConcurrencyId]								INT NOT NULL DEFAULT 1
)
