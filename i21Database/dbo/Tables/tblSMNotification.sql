CREATE TABLE [dbo].[tblSMNotification] (
    [intNotificationId] INT              IDENTITY (1, 1) NOT NULL,	
	[intCommentId]      INT              NULL,
    [strTitle]			NVARCHAR(255)	 COLLATE Latin1_General_CI_AS NULL, 
    [strMessage]        NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NULL,
    [strRoute]			NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NULL,
	[strAction]         NVARCHAR(255)    COLLATE Latin1_General_CI_AS NULL,
	[strType]           NVARCHAR(255)    COLLATE Latin1_General_CI_AS NULL,
    [dtmLastUpdated]    DATETIME         NULL,
	[ysnClosable]		BIT				 NULL,
	[ysnSent]			BIT				 DEFAULT ((0)) NULL,	
    [ysnSeen]			BIT				 NULL, 
	[intCounter]		INT				 NULL, 
    [intFromEntityId]	INT				 NULL, 
	[intToEntityId]     INT              NULL,
    [intConcurrencyId]  INT              NOT NULL,
    CONSTRAINT [PK_dbo.tblSMNotification] PRIMARY KEY CLUSTERED ([intNotificationId] ASC)
);