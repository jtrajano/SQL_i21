CREATE TABLE [dbo].[tblARPOSLog] (
    [intPOSLogId]          INT             IDENTITY (1, 1) NOT NULL,
    [intEntityUserId]      INT             NOT NULL,
    [dblOpeningBalance]    NUMERIC (18, 6) NULL,
    [dblEndingBalance]     NUMERIC (18, 6) NULL,
    [dtmLogin]             DATETIME        NULL,
    [dtmLogout]            DATETIME        NULL,
    [intCompanyLocationId] INT             NOT NULL,
    [intStoreId]           INT             NULL,
    [ysnLoggedIn]          BIT             NULL,
	[intPOSLogOriginId]    INT             NULL,
    [intBankDepositId]     INT             NULL,
    [intConcurrencyId]     INT             NOT NULL,
	[intCompanyLocationPOSDrawerId] INT    NULL,
    CONSTRAINT [PK_tblARPOSLog] PRIMARY KEY CLUSTERED ([intPOSLogId] ASC),
	CONSTRAINT [FK_tblARPOSLog_tblSMCompanyLocationPOSDrawer] FOREIGN KEY ([intCompanyLocationPOSDrawerId]) REFERENCES [dbo].[tblSMCompanyLocationPOSDrawer] ([intCompanyLocationPOSDrawerId]),
    CONSTRAINT [FK_tblARPOSLog_tblCMBankTransaction] FOREIGN KEY ([intBankDepositId]) REFERENCES [dbo].[tblCMBankTransaction] ([intTransactionId]) 
);

