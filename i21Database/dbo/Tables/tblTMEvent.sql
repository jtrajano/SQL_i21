CREATE TABLE [dbo].[tblTMEvent] (
    [intConcurrencyId]      INT            DEFAULT 1 NOT NULL,
    [intEventID]            INT            IDENTITY (1, 1) NOT NULL,
    [dtmDate]               DATETIME       DEFAULT 0 NULL,
    [intEventTypeID]        INT            DEFAULT 0 NOT NULL,
    [intPerformerID]        INT            DEFAULT 0 NULL,
    [intUserID]             INT            DEFAULT 0 NOT NULL,
    [intDeviceId]           INT            DEFAULT 0 NULL,
    [dtmLastUpdated]        DATETIME       DEFAULT 0 NULL,
    [strDeviceOwnership]    NVARCHAR (20)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strDeviceSerialNumber] NVARCHAR (20)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strDeviceType]         NVARCHAR (70)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strDescription]        NVARCHAR (MAX) COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [intSiteID]             INT            DEFAULT 0 NULL,
    [strLevel]              NVARCHAR (20)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    CONSTRAINT [PK_tblTMEvent] PRIMARY KEY CLUSTERED ([intEventID] ASC),
    CONSTRAINT [FK_tblTMEvent_tblTMEventType] FOREIGN KEY ([intEventTypeID]) REFERENCES [dbo].[tblTMEventType] ([intEventTypeID])
);

