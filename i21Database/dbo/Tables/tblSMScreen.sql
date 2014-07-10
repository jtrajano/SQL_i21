CREATE TABLE [dbo].[tblSMScreen] (
    [intScreenId]      INT            IDENTITY (1, 1) NOT NULL,
    [strScreenId]      NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strScreenName]    NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strNamespace]     NVARCHAR (150) COLLATE Latin1_General_CI_AS NOT NULL,
    [strModule]        NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strTableName]     NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT            CONSTRAINT [DF__tblSMScre__intCo__381B131F] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK__tblSMScr__552B34714D4B3A2F] PRIMARY KEY CLUSTERED ([intScreenId] ASC)
);



GO

CREATE INDEX [IX_tblSMScreen_strScreenName] ON [dbo].[tblSMScreen] ([strScreenName])

GO

CREATE INDEX [IX_tblSMScreen_strModule] ON [dbo].[tblSMScreen] ([strModule])

GO

CREATE INDEX [IX_tblSMScreen_strScreenId] ON [dbo].[tblSMScreen] ([strScreenId])
