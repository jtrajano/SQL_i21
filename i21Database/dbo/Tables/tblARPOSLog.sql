CREATE TABLE [dbo].[tblARPOSLog] (
    [intPOSLogId]          INT             IDENTITY (1, 1) NOT NULL,
    [intEntityId]	       INT             NOT NULL,
    [dtmLogin]             DATETIME        NULL,
    [dtmLogout]            DATETIME        NULL,
    [ysnLoggedIn]          BIT             NULL,
	[intPOSEndOfDayId]	   INT			   NOT NULL,
    [intConcurrencyId]     INT             NOT NULL,
    CONSTRAINT [PK_tblARPOSLog] PRIMARY KEY CLUSTERED ([intPOSLogId] ASC),
	CONSTRAINT [FK_tblARPOSLog_tblARPOSEndOfDay] FOREIGN KEY ([intPOSEndOfDayId]) REFERENCES [dbo].[tblARPOSEndOfDay] ([intPOSEndOfDayId])
);

