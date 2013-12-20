CREATE TABLE [dbo].[tblTMEvent] (
    [intConcurrencyID]      INT            CONSTRAINT [DEF_tblTMEvent_intConcurrencyID] DEFAULT ((0)) NULL,
    [intEventID]            INT            IDENTITY (1, 1) NOT NULL,
    [dtmDate]               DATETIME       CONSTRAINT [DEF_tblTMEvent_dtmDate] DEFAULT ((0)) NULL,
    [intEventTypeID]        INT            CONSTRAINT [DEF_tblTMEvent_intEventTypeID] DEFAULT ((0)) NOT NULL,
    [intPerformerID]        INT            CONSTRAINT [DEF_tblTMEvent_intPerformerID] DEFAULT ((0)) NULL,
    [intUserID]             INT            CONSTRAINT [DEF_tblTMEvent_intUserID] DEFAULT ((0)) NOT NULL,
    [intDeviceID]           INT            CONSTRAINT [DEF_tblTMEvent_intDeviceID] DEFAULT ((0)) NULL,
    [dtmLastUpdated]        DATETIME       CONSTRAINT [DEF_tblTMEvent_dtmLastUpdated] DEFAULT ((0)) NULL,
    [strDeviceOwnership]    NVARCHAR (20)  COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMEvent_strDeviceOwnership] DEFAULT ('') NULL,
    [strDeviceSerialNumber] NVARCHAR (20)  COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMEvent_strDeviceSerialNumber] DEFAULT ('') NULL,
    [strDeviceType]         NVARCHAR (70)  COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMEvent_strDeviceType] DEFAULT ('') NULL,
    [strDescription]        NVARCHAR (MAX) COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMEvent_strDescription] DEFAULT ('') NULL,
    [intSiteID]             INT            CONSTRAINT [DEF_tblTMEvent_intSiteID] DEFAULT ((0)) NULL,
    [strLevel]              NVARCHAR (20)  COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMEvent_strLevel] DEFAULT ('') NULL,
    CONSTRAINT [PK_tblTMEvent] PRIMARY KEY CLUSTERED ([intEventID] ASC),
    CONSTRAINT [FK_tblTMEvent_tblTMEventType] FOREIGN KEY ([intEventTypeID]) REFERENCES [dbo].[tblTMEventType] ([intEventTypeID])
);

