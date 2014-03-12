CREATE TABLE [dbo].[tblGLCOACrossReference] (
    [intCrossReferenceId]  INT            IDENTITY (1, 1) NOT NULL,
    [inti21Id]             INT            NOT NULL,
    [stri21Id]             NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
    [strExternalId]        NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
    [strCurrentExternalId] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCompanyId]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]     INT            DEFAULT 1 NOT NULL,
    [intLegacyReferenceId] NUMERIC (9)    NULL,
    CONSTRAINT [PK_tblCrossReference] PRIMARY KEY CLUSTERED ([intCrossReferenceId] ASC),
    CONSTRAINT [FK_tblGLCOACrossReference_tblGLAccount] FOREIGN KEY ([inti21Id]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]) ON DELETE CASCADE
);

