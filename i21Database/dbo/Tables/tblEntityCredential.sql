CREATE TABLE [dbo].[tblEntityCredential] (
    [intEntityCredentialId] INT            IDENTITY (1, 1) NOT NULL,
    [intEntityId]           INT            NOT NULL,
    [strUserName]           NVARCHAR (100) NOT NULL,
    [strPassword]           NVARCHAR (100) NOT NULL,
    [intConcurrencyId]      INT            DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblEntityCredential] PRIMARY KEY CLUSTERED ([intEntityCredentialId] ASC),
    CONSTRAINT [FK_tblEntityCredential_tblEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId]),
    CONSTRAINT [AK_tblEntityCredential_strUserName] UNIQUE NONCLUSTERED ([strUserName] ASC)
);


