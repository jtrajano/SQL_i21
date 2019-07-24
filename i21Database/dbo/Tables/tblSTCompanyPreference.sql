CREATE TABLE [dbo].[tblSTCompanyPreference] (
    [intCompanyPreferenceId]		INT            IDENTITY (1, 1) NOT NULL,
    [strDailySecurityCode]			NVARCHAR (MAX) NULL,
    [dtmDateEntered]				DATETIME	   NULL,
    [ysnEnableLotteryManagement]	BIT			   NULL,
	[ysnUnlockedLotteryModule]		BIT			   NULL,
    [intConcurrencyId] INT          CONSTRAINT [DF_tblSTCompanyPreference_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblSTCompanyPreference] PRIMARY KEY CLUSTERED ([intCompanyPreferenceId] ASC)
);

