CREATE TABLE [dbo].[tblGLOriginAccounts](
	[glact_acct1_8] [int] NOT NULL,
	[glact_acct9_16] [int] NOT NULL,
	[glact_desc] [char](30)   COLLATE Latin1_General_CI_AS NOT NULL,
	[glact_type] [char](1)   COLLATE Latin1_General_CI_AS NOT NULL,
	[glact_normal_value] [char](1)   COLLATE Latin1_General_CI_AS NOT NULL,
	[glact_saf_cat] [char](1)   COLLATE Latin1_General_CI_AS NOT NULL,
	[glact_flow_cat] [char](1)   COLLATE Latin1_General_CI_AS NOT NULL,
	[glact_uom] [char](6)   COLLATE Latin1_General_CI_AS NOT NULL,
	[glact_verify_flag] [char](1)   COLLATE Latin1_General_CI_AS NOT NULL,
	[glact_active_yn] [char](1)   COLLATE Latin1_General_CI_AS NOT NULL,
	[glact_sys_acct_yn] [char](1)   COLLATE Latin1_General_CI_AS NOT NULL,
	[glact_desc_lookup] [char](8) COLLATE Latin1_General_CI_AS NOT NULL,
	[glact_user_fld_1] [char](10)  COLLATE Latin1_General_CI_AS NOT NULL,
	[glact_user_fld_2] [char](10) COLLATE Latin1_General_CI_AS NOT NULL,
	[glact_user_id] [char](16) COLLATE Latin1_General_CI_AS NOT NULL,
	[glact_user_rev_dt] [int] NULL,
	[A4GLIdentity] [numeric](9, 0) NOT NULL,
	[glact_acct1_8_new] [int] NOT NULL
) ON [PRIMARY]

GO

