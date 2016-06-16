CREATE TABLE [dbo].[tblSMOfflineConfiguration] (
    [intOfflineConfigurationId]	INT IDENTITY(1,1) NOT NULL,
    [strOnlineServerUrl]		NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    [strDBServer]				NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    [strDatabase]				NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    [strDBUserId]				NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    [strDBPassword]				NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]			INT NOT NULL,
    CONSTRAINT [PK_tblSMOfflineConfiguration] PRIMARY KEY CLUSTERED ([intOfflineConfigurationId] ASC)
);

