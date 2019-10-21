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
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOACrossReference', @level2type=N'COLUMN',@level2name=N'intCrossReferenceId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'i21 Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOACrossReference', @level2type=N'COLUMN',@level2name=N'inti21Id' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'i21 Id (string)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOACrossReference', @level2type=N'COLUMN',@level2name=N'stri21Id' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Old Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOACrossReference', @level2type=N'COLUMN',@level2name=N'strOldId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'i21 Id Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOACrossReference', @level2type=N'COLUMN',@level2name=N'stri21IdNumber' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'External Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOACrossReference', @level2type=N'COLUMN',@level2name=N'strExternalId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Current External Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOACrossReference', @level2type=N'COLUMN',@level2name=N'strCurrentExternalId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Company Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOACrossReference', @level2type=N'COLUMN',@level2name=N'strCompanyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOACrossReference', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Legacy Reference Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOACrossReference', @level2type=N'COLUMN',@level2name=N'intLegacyReferenceId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Origin' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOACrossReference', @level2type=N'COLUMN',@level2name=N'ysnOrigin' 
GO
