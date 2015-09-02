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
	[A4GLIdentity] [numeric](9, 0) IDENTITY(1,1) NOT NULL,
	[intBillDetailId] INT
 CONSTRAINT [k_tblAPaphglmst] PRIMARY KEY NONCLUSTERED 
(
	[aphgl_cbk_no] ASC,
	[aphgl_trx_ind] ASC,
	[aphgl_vnd_no] ASC,
	[aphgl_ivc_no] ASC,
	[aphgl_dist_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY] 
) ON [PRIMARY]