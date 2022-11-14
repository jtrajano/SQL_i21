CREATE TABLE [dbo].[tblSTCompanyPreference] (
    [intCompanyPreferenceId]                INT            IDENTITY (1, 1) NOT NULL,
    [strDailySecurityCode]                  NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [dtmDateEntered]                        DATETIME       NULL,
    [ysnUnlockedLotteryModule]              BIT            NULL,
    [ysnEnableLotteryManagement]            BIT            NULL,
	[strStoreBasePath]			            NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,    
    [intConcurrencyId]                      INT            CONSTRAINT [DF_tblSTCompanyPreference_intConcurrencyId] DEFAULT ((1)) NULL,
    [strPollingStatusReportTime]			NVARCHAR (30)  COLLATE Latin1_General_CI_AS NULL,
    [strPollingStatusReportEmailAddress]	NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strPollingStatusReportEmailAddressSecond] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [strPollingStatusReportEmailAddressThird] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    CONSTRAINT [PK_tblSTCompanyPreference]  PRIMARY KEY CLUSTERED ([intCompanyPreferenceId] ASC) WITH (FILLFACTOR = 70)
);



