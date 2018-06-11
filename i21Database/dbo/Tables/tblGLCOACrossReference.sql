CREATE TABLE [dbo].[tblGLCOACrossReference] (
    [intCrossReferenceId]		INT				IDENTITY (1, 1) NOT NULL,
    [inti21Id]					INT				NOT NULL,
    [stri21Id]					NVARCHAR(50)	COLLATE Latin1_General_CI_AS NOT NULL,
	[strOldId]					NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL,
	[stri21IdNumber]			NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL,
    [strExternalId]				NVARCHAR(50)	COLLATE Latin1_General_CI_AS NOT NULL,
    [strCurrentExternalId]		NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL,
    [strCompanyId]				NVARCHAR(30)	COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]			INT				DEFAULT 1 NOT NULL,
    [intLegacyReferenceId]		INT		NULL,
	[ysnOrigin]					BIT				NULL
    CONSTRAINT [PK_tblCrossReference] PRIMARY KEY CLUSTERED ([intCrossReferenceId] ASC),
    CONSTRAINT [FK_tblGLCOACrossReference_tblGLAccount] FOREIGN KEY ([inti21Id]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]) ON DELETE CASCADE
);
GO
