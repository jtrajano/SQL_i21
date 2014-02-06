CREATE TABLE [dbo].[tblTMSyncOutOfRange] (
    [intSyncOutOfRangeID] INT      IDENTITY (1, 1) NOT NULL,
    [intSiteID]           INT      NOT NULL,
    [dtmDateSync]         DATETIME NOT NULL,
    [ysnCommit]           BIT      DEFAULT 0 NOT NULL,
    [intConcurrencyId]    INT      DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblTMSyncOutOfRange] PRIMARY KEY CLUSTERED ([intSyncOutOfRangeID] ASC)
);

