CREATE TABLE [dbo].[tblTMSyncOutOfRange] (
    [intSyncOutOfRangeID] INT      IDENTITY (1, 1) NOT NULL,
    [intSiteID]           INT      NOT NULL,
    [dtmDateSync]         DATETIME NOT NULL,
    [ysnCommit]           BIT      CONSTRAINT [DF_tblTMSyncOutOfRange_ysnCommit] DEFAULT ((0)) NOT NULL,
    [intConcurrencyID]    INT      NULL,
    CONSTRAINT [PK_tblTMSyncOutOfRange] PRIMARY KEY CLUSTERED ([intSyncOutOfRangeID] ASC)
);

