CREATE TABLE [dbo].[tblAPapeglmst](
	[apegl_cbk_no] [char](2) NOT NULL,
	[apegl_trx_ind] [char](1) NOT NULL,
	[apegl_vnd_no] [char](10) NOT NULL,
	[apegl_ivc_no] [char](50) NOT NULL,
	[apegl_dist_no] [smallint] NOT NULL,
	[apegl_alt_cbk_no] [char](2) NOT NULL,
	[apegl_gl_acct] [decimal](16, 8) NOT NULL,
	[apegl_gl_amt] [decimal](11, 2) NULL,
	[apegl_gl_un] [decimal](13, 4) NULL,
	[A4GLIdentity] [numeric](9, 0) IDENTITY(1,1) NOT NULL,
	[intBillDetailId] INT
 CONSTRAINT [k_tblAPapeglmst] PRIMARY KEY NONCLUSTERED 
(
	[apegl_cbk_no] ASC,
	[apegl_trx_ind] ASC,
	[apegl_vnd_no] ASC,
	[apegl_ivc_no] ASC,
	[apegl_dist_no] ASC,
	[apegl_alt_cbk_no] ASC,
	[apegl_gl_acct] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY] 
) ON [PRIMARY]