CREATE TABLE [dbo].[tblAPaphglmst](
	[aphgl_cbk_no] [char](2) NOT NULL,
	[aphgl_trx_ind] [char](1) NOT NULL,
	[aphgl_vnd_no] [char](10) NOT NULL,
	[aphgl_ivc_no] [char](50) NOT NULL,
	[aphgl_dist_no] [smallint] NOT NULL,
	[aphgl_alt_cbk_no] [char](2) NOT NULL,
	[aphgl_gl_acct] [decimal](16, 8) NOT NULL,
	[aphgl_gl_amt] [decimal](11, 2) NULL,
	[aphgl_gl_un] [decimal](13, 4) NULL,
	[A4GLIdentity] [numeric](9, 0) NOT NULL,
	[intHeaderId]			INT NULL
)