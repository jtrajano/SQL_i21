CREATE TABLE [dbo].[tblSTCompanyPreference] (
    [intCompanyPreferenceId]                            INT             IDENTITY (1, 1) NOT NULL,
    [strDailySecurityCode]                              NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dtmDateEntered]                                    DATETIME        NULL,
    [ysnUnlockedLotteryModule]                          BIT             NULL,
    [ysnEnableLotteryManagement]                        BIT             NULL,
	[strStoreBasePath]			                        NVARCHAR (250)  NULL,    
    [intConcurrencyId]                                  INT             CONSTRAINT [DF_tblSTCompanyPreference_intConcurrencyId] DEFAULT ((1)) NULL,
    [strPollingStatusReportTime]			            NVARCHAR (30)   NULL,
    [strPollingStatusReportEmailAddress]	            NVARCHAR (250)  NULL,
    [strPollingStatusReportEmailAddressSecond]          NVARCHAR(250)   NULL, 
    [strPollingStatusReportEmailAddressThird]           NVARCHAR(250)   NULL, 
    [strCompanyName]                                    NVARCHAR(20)    NULL, 
    [strApplicationRootPath]                            NVARCHAR(250)   NULL, 
    [ysnConsEnableAutomaticPollingStatusReportEmail]    BIT             NOT NULL DEFAULT 0,
    CONSTRAINT [PK_tblSTCompanyPreference]  PRIMARY KEY CLUSTERED ([intCompanyPreferenceId] ASC) WITH (FILLFACTOR = 70)
);



