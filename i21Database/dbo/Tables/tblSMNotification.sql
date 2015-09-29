CREATE TABLE [dbo].[tblSMNotification] (
    [intNotificationId] INT              IDENTITY (1, 1) NOT NULL,	
    [strTitle]			NVARCHAR(100)	 COLLATE Latin1_General_CI_AS NULL, 
    [strMessage]        NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NULL,
    [strRoute]			NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NULL,
	[strAlertType]		NVARCHAR (50)    COLLATE Latin1_General_CI_AS NULL,
    [dtmDateCreated]    DATETIME         NULL,
	[ysnSeen]			BIT				 NULL,
	[ysnClosable]		BIT				 NULL,
	[dtmDateSeen]		DATETIME         NULL,
    [intFromEntityId]	INT				 NULL, 
	[intToEntityId]     INT              NULL,
    [intConcurrencyId]  INT              NOT NULL,
    CONSTRAINT [PK_dbo.tblSMNotification] PRIMARY KEY CLUSTERED ([intNotificationId] ASC)
);