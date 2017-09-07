CREATE TABLE [dbo].[tblGLOriginAccounts](
	[glact_acct1_8] [int] NOT NULL,
	[glact_acct9_16] [int] NOT NULL,
	[glact_desc] [char](30)   COLLATE Latin1_General_CI_AS NOT NULL,
	[glact_type] [char](1)   COLLATE Latin1_General_CI_AS NULL,
	[glact_normal_value] [char](1)   COLLATE Latin1_General_CI_AS NULL,
	[glact_saf_cat] [char](1)   COLLATE Latin1_General_CI_AS NULL,
	[glact_flow_cat] [char](1)   COLLATE Latin1_General_CI_AS NULL,
	[glact_uom] [char](6)   COLLATE Latin1_General_CI_AS NULL,
	[glact_verify_flag] [char](1)   COLLATE Latin1_General_CI_AS NULL,
	[glact_active_yn] [char](1)   COLLATE Latin1_General_CI_AS NULL,
	[glact_sys_acct_yn] [char](1)   COLLATE Latin1_General_CI_AS NULL,
	[glact_desc_lookup] [char](8) COLLATE Latin1_General_CI_AS NOT NULL,
	[glact_user_fld_1] [char](10)  COLLATE Latin1_General_CI_AS NULL,
	[glact_user_fld_2] [char](10) COLLATE Latin1_General_CI_AS NULL,
	[glact_user_id] [char](16) COLLATE Latin1_General_CI_AS NULL,
	[glact_user_rev_dt] [int] NULL,
	[A4GLIdentity] [numeric](9, 0) NOT NULL,
	[glact_acct1_8_new] [int] NULL
) ON [PRIMARY]

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'glact_acct1_8' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLOriginAccounts', @level2type=N'COLUMN',@level2name=N'glact_acct1_8' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'glact_acct9_16' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLOriginAccounts', @level2type=N'COLUMN',@level2name=N'glact_acct9_16' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'glact_desc' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLOriginAccounts', @level2type=N'COLUMN',@level2name=N'glact_desc' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'glact_type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLOriginAccounts', @level2type=N'COLUMN',@level2name=N'glact_type' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'glact_normal_value' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLOriginAccounts', @level2type=N'COLUMN',@level2name=N'glact_normal_value' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'glact_saf_cat' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLOriginAccounts', @level2type=N'COLUMN',@level2name=N'glact_saf_cat' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'glact_flow_cat' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLOriginAccounts', @level2type=N'COLUMN',@level2name=N'glact_flow_cat' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'glact_uom' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLOriginAccounts', @level2type=N'COLUMN',@level2name=N'glact_uom' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'glact_verify_flag' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLOriginAccounts', @level2type=N'COLUMN',@level2name=N'glact_verify_flag' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'glact_active_yn' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLOriginAccounts', @level2type=N'COLUMN',@level2name=N'glact_active_yn' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'glact_sys_acct_yn' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLOriginAccounts', @level2type=N'COLUMN',@level2name=N'glact_sys_acct_yn' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'glact_desc_lookup' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLOriginAccounts', @level2type=N'COLUMN',@level2name=N'glact_desc_lookup' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'glact_user_fld_1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLOriginAccounts', @level2type=N'COLUMN',@level2name=N'glact_user_fld_1' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'glact_user_fld_2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLOriginAccounts', @level2type=N'COLUMN',@level2name=N'glact_user_fld_2' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'glact_user_id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLOriginAccounts', @level2type=N'COLUMN',@level2name=N'glact_user_id' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'glact_user_rev_dt' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLOriginAccounts', @level2type=N'COLUMN',@level2name=N'glact_user_rev_dt' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'A4 G L Identity' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLOriginAccounts', @level2type=N'COLUMN',@level2name=N'A4GLIdentity' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'glact_acct1_8_new' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLOriginAccounts', @level2type=N'COLUMN',@level2name=N'glact_acct1_8_new' 
GO