CREATE TABLE [dbo].[tblGLIjemst] (
    [glije_period]      INT             NOT NULL,
    [glije_acct_no]     DECIMAL (16, 8) NOT NULL,
    [glije_src_sys]     CHAR (3)        NOT NULL,
    [glije_src_no]      CHAR (5)        NOT NULL,
    [glije_line_no]     INT             NOT NULL,
    [glije_date]        INT             NULL,
    [glije_time]        INT             NULL,
    [glije_ref]         CHAR (25)       NULL,
    [glije_doc]         CHAR (25)       NULL,
    [glije_comments]    CHAR (25)       NULL,
    [glije_dr_cr_ind]   CHAR (1)        NULL,
    [glije_amt]         DECIMAL (12, 2) NULL,
    [glije_units]       DECIMAL (16, 4) NULL,
    [glije_correcting]  CHAR (1)        NULL,
    [glije_source_pgm]  CHAR (8)        NULL,
    [glije_work_area]   CHAR (40)       NULL,
    [glije_cbk_no]      CHAR (2)        NULL,
    [glije_user_id]     CHAR (16)       NULL,
    [glije_user_rev_dt] INT             NULL,
    [A4GLIdentity]      NUMERIC (9)     NOT NULL, 
	[glije_uid] [uniqueidentifier] NULL,
    [glije_postdate] DATE NULL, 
    [glije_id] INT NOT NULL IDENTITY, 
    [glije_dte] DATETIME NULL, 
    [glije_error_desc] NVARCHAR(300) NULL 
);
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'period' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLIjemst', @level2type=N'COLUMN',@level2name=N'glije_period' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'acct number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLIjemst', @level2type=N'COLUMN',@level2name=N'glije_acct_no' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'source system' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLIjemst', @level2type=N'COLUMN',@level2name=N'glije_src_sys' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'source number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLIjemst', @level2type=N'COLUMN',@level2name=N'glije_src_no' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'line number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLIjemst', @level2type=N'COLUMN',@level2name=N'glije_line_no' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLIjemst', @level2type=N'COLUMN',@level2name=N'glije_date' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'time' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLIjemst', @level2type=N'COLUMN',@level2name=N'glije_time' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'reference' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLIjemst', @level2type=N'COLUMN',@level2name=N'glije_ref' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'document' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLIjemst', @level2type=N'COLUMN',@level2name=N'glije_doc' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'comments' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLIjemst', @level2type=N'COLUMN',@level2name=N'glije_comments' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'debit /credit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLIjemst', @level2type=N'COLUMN',@level2name=N'glije_dr_cr_ind' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'amount' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLIjemst', @level2type=N'COLUMN',@level2name=N'glije_amt' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'units' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLIjemst', @level2type=N'COLUMN',@level2name=N'glije_units' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'is correcting?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLIjemst', @level2type=N'COLUMN',@level2name=N'glije_correcting' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'source program' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLIjemst', @level2type=N'COLUMN',@level2name=N'glije_source_pgm' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'work area' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLIjemst', @level2type=N'COLUMN',@level2name=N'glije_work_area' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'check book number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLIjemst', @level2type=N'COLUMN',@level2name=N'glije_cbk_no' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'user id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLIjemst', @level2type=N'COLUMN',@level2name=N'glije_user_id' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'user rev date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLIjemst', @level2type=N'COLUMN',@level2name=N'glije_user_rev_dt' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'GL Identity' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLIjemst', @level2type=N'COLUMN',@level2name=N'A4GLIdentity' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'user id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLIjemst', @level2type=N'COLUMN',@level2name=N'glije_uid' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'post date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLIjemst', @level2type=N'COLUMN',@level2name=N'glije_postdate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'primary key column' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLIjemst', @level2type=N'COLUMN',@level2name=N'glije_id' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'transaction date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLIjemst', @level2type=N'COLUMN',@level2name=N'glije_dte' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'error description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLIjemst', @level2type=N'COLUMN',@level2name=N'glije_error_desc' 
GO