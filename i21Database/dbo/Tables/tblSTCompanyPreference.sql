CREATE TABLE [dbo].[tblSTCompanyPreference] (
    [intCompanyPreferenceId]     INT            IDENTITY (1, 1) NOT NULL,
    [strDailySecurityCode]       NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [dtmDateEntered]             DATETIME       NULL,
    [ysnUnlockedLotteryModule]   BIT            NULL,
    [ysnEnableLotteryManagement] BIT            NULL,
    [intConcurrencyId]           INT            CONSTRAINT [DF_tblSTCompanyPreference_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblSTCompanyPreference] PRIMARY KEY CLUSTERED ([intCompanyPreferenceId] ASC) WITH (FILLFACTOR = 70)
);



