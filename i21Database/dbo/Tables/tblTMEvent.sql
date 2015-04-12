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
    [strDeviceSerialNumber] NVARCHAR (50)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strDeviceType]         NVARCHAR (70)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strDescription]        NVARCHAR (MAX) COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [intSiteID]             INT            DEFAULT 0 NULL,
    [strLevel]              NVARCHAR (20)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dtmTankMonitorReading] DATETIME NULL, 
    CONSTRAINT [PK_tblTMEvent] PRIMARY KEY CLUSTERED ([intEventID] ASC),
    CONSTRAINT [FK_tblTMEvent_tblTMEventType] FOREIGN KEY ([intEventTypeID]) REFERENCES [dbo].[tblTMEventType] ([intEventTypeID])
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMEvent',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMEvent',
    @level2type = N'COLUMN',
    @level2name = N'intEventID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMEvent',
    @level2type = N'COLUMN',
    @level2name = N'dtmDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Event Type ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMEvent',
    @level2type = N'COLUMN',
    @level2name = N'intEventTypeID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Performer ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMEvent',
    @level2type = N'COLUMN',
    @level2name = N'intPerformerID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMEvent',
    @level2type = N'COLUMN',
    @level2name = N'intUserID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Device ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMEvent',
    @level2type = N'COLUMN',
    @level2name = N'intDeviceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Updated Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMEvent',
    @level2type = N'COLUMN',
    @level2name = N'dtmLastUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Device Ownership',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMEvent',
    @level2type = N'COLUMN',
    @level2name = N'strDeviceOwnership'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Device Serial Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMEvent',
    @level2type = N'COLUMN',
    @level2name = N'strDeviceSerialNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Device Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMEvent',
    @level2type = N'COLUMN',
    @level2name = N'strDeviceType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMEvent',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMEvent',
    @level2type = N'COLUMN',
    @level2name = N'intSiteID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Level',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMEvent',
    @level2type = N'COLUMN',
    @level2name = N'strLevel'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tank Monitor Reading Date for tank monitor reading type event. Populated during import of tankmonitor reading.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMEvent',
    @level2type = N'COLUMN',
    @level2name = N'dtmTankMonitorReading'