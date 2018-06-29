CREATE TABLE [dbo].[tblSMRemoteServer] (
    [intRemoteDBServerId]   INT IDENTITY(1,1) NOT NULL,
    [strDBServer]           NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    [strDatabase]           NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    [strUserId]             NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    [strPassword]           NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]      INT NOT NULL,
    CONSTRAINT [PK_tblSMRemoteServer] PRIMARY KEY CLUSTERED ([intRemoteDBServerId] ASC)
);

