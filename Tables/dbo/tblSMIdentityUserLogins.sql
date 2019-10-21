CREATE TABLE [dbo].[tblSMIdentityUserLogins] (
    [strLoginProvider] NVARCHAR (128) COLLATE Latin1_General_CI_AS NOT NULL,
    [strProviderKey]   NVARCHAR (128) COLLATE Latin1_General_CI_AS NOT NULL,
    [intUserId]        INT            NOT NULL,
    CONSTRAINT [PK_dbo.tblSMIdentityUserLogins] PRIMARY KEY CLUSTERED ([strLoginProvider] ASC, [strProviderKey] ASC, [intUserId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_UserId]
    ON [dbo].[tblSMIdentityUserLogins]([intUserId] ASC);