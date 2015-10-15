CREATE TABLE [dbo].[tblSMNotification] (
    [intNotificationId] INT              IDENTITY (1, 1) NOT NULL,	
    [strTitle]			NVARCHAR(255)	 COLLATE Latin1_General_CI_AS NULL, 
    [strMessage]        NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NULL,
    [strRoute]			NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NULL,
    [dtmLastUpdated]    DATETIME         NULL,
	[ysnClosable]		BIT				 NULL,
	[ysnCountable]		BIT			     NULL,
    [intFromEntityId]	INT				 NULL, 
	[intToEntityId]     INT              NULL,
    [intConcurrencyId]  INT              NOT NULL,
    CONSTRAINT [PK_dbo.tblSMNotification] PRIMARY KEY CLUSTERED ([intNotificationId] ASC)
);