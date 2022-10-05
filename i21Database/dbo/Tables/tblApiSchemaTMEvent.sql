CREATE TABLE [dbo].[tblApiSchemaTMEvent]
(
	[intTMEventId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[guiApiUniqueId] UNIQUEIDENTIFIER NOT NULL,
    [intRowNumber] INT NULL,
	[strCustomer]  nvarchar(100) NOT NULL,
	[dtmDate]             DATETIME       NULL,
    [strEventType]        nvarchar(50)     NOT NULL,
    [strUserName]         nvarchar(50)     NOT NULL,
    [dtmLastUpdated]        DATETIME       NULL,
    [strDeviceOwnership]    NVARCHAR (20)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strDeviceSerialNumber] NVARCHAR (50)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strDeviceType]         NVARCHAR (70)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strDescription]        NVARCHAR (MAX) COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [intSiteNumber]             INT           NULL,
    [strLevel]              NVARCHAR (20)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dtmTankMonitorReading] DATETIME NULL, 
    [strDeviceDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS DEFAULT ('') NULL
)







