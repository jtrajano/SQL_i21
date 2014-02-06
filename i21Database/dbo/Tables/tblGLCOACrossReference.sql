CREATE TABLE [dbo].[tblGLCOACrossReference] (
    [intCrossReferenceID]  INT            IDENTITY (1, 1) NOT NULL,
    [inti21ID]             INT            NOT NULL,
    [stri21ID]             NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
    [strExternalID]        NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
    [strCurrentExternalID] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCompanyID]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]     INT            DEFAULT 1 NOT NULL,
    [intLegacyReferenceID] NUMERIC (9)    NULL,
    CONSTRAINT [PK_tblCrossReference] PRIMARY KEY CLUSTERED ([intCrossReferenceID] ASC),
    CONSTRAINT [FK_tblGLCOACrossReference_tblGLAccount] FOREIGN KEY ([inti21ID]) REFERENCES [dbo].[tblGLAccount] ([intAccountID]) ON DELETE CASCADE
);

