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
    [intConcurrencyId]     INT             NOT NULL,
    CONSTRAINT [PK_tblARPOSLog] PRIMARY KEY CLUSTERED ([intPOSLogId] ASC)
);

