CREATE TABLE [dbo].[tblGLTempAccountToBuild] (
    [cntId]               INT      IDENTITY (1, 1) NOT NULL,
    [intAccountSegmentId] INT      NOT NULL,
    [intUserId]           INT      NOT NULL,
    [dtmCreated]          DATETIME CONSTRAINT [DF_tblTempGLAccountToBuild_dtmCreated] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_tblTempGLAccountToBuild] PRIMARY KEY CLUSTERED ([cntId] ASC)
);
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLTempAccountToBuild', @level2type=N'COLUMN',@level2name=N'cntId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Segment Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLTempAccountToBuild', @level2type=N'COLUMN',@level2name=N'intAccountSegmentId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLTempAccountToBuild', @level2type=N'COLUMN',@level2name=N'intUserId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Created' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLTempAccountToBuild', @level2type=N'COLUMN',@level2name=N'dtmCreated' 
GO