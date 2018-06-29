CREATE TABLE [dbo].[tblGLTempAccount] (
    [cntId]               INT            IDENTITY (1, 1) NOT NULL,
    [strAccountId]        NVARCHAR (40)  COLLATE Latin1_General_CI_AS NULL,
    [strPrimary]          NVARCHAR (40)  COLLATE Latin1_General_CI_AS NULL,
    [strSegment]          NVARCHAR (40)  COLLATE Latin1_General_CI_AS NULL,
    [strDescription]      NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [strAccountGroup]     NVARCHAR (75)  COLLATE Latin1_General_CI_AS NULL,
    [intAccountGroupId]   INT            NULL,
    [strAccountSegmentId] NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intAccountUnitId]    INT            NULL,
    [ysnSystem]           BIT            NULL,
    [ysnActive]           BIT            NULL,
    [intUserId]           INT            NULL,
    [dtmCreated]          DATETIME       CONSTRAINT [DF_tblTempGLAccount_dtmCreated] DEFAULT (getdate()) NOT NULL,
    [intAccountCategoryId] INT NULL, 
    CONSTRAINT [PK_tblTempGLAccount] PRIMARY KEY CLUSTERED ([cntId] ASC)
);
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLTempAccount', @level2type=N'COLUMN',@level2name=N'cntId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLTempAccount', @level2type=N'COLUMN',@level2name=N'strAccountId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLTempAccount', @level2type=N'COLUMN',@level2name=N'strPrimary' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Segment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLTempAccount', @level2type=N'COLUMN',@level2name=N'strSegment' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLTempAccount', @level2type=N'COLUMN',@level2name=N'strDescription' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Group' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLTempAccount', @level2type=N'COLUMN',@level2name=N'strAccountGroup' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Group Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLTempAccount', @level2type=N'COLUMN',@level2name=N'intAccountGroupId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Segment Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLTempAccount', @level2type=N'COLUMN',@level2name=N'strAccountSegmentId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Unit Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLTempAccount', @level2type=N'COLUMN',@level2name=N'intAccountUnitId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLTempAccount', @level2type=N'COLUMN',@level2name=N'ysnSystem' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Active' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLTempAccount', @level2type=N'COLUMN',@level2name=N'ysnActive' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLTempAccount', @level2type=N'COLUMN',@level2name=N'intUserId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Created' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLTempAccount', @level2type=N'COLUMN',@level2name=N'dtmCreated' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Category Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLTempAccount', @level2type=N'COLUMN',@level2name=N'intAccountCategoryId' 
GO