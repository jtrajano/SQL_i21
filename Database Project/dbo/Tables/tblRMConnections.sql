CREATE TABLE [dbo].[tblRMConnections] (
    [intConnectionId]       INT            IDENTITY (1, 1) NOT NULL,
    [strName]               NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConnectionType]     INT            NOT NULL,
    [strUserName]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strPassword]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strServerName]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intAuthenticationType] INT            NOT NULL,
    [strRemoteUri]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strDatabase]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strPort]               NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [ysnRemote]             BIT            NULL,
    CONSTRAINT [PK_dbo.Connections] PRIMARY KEY CLUSTERED ([intConnectionId] ASC)
);

