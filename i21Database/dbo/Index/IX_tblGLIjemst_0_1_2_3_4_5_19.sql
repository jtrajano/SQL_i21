CREATE NONCLUSTERED INDEX [IX_tblGLIjemst_0_1_2_3_4_5_19] ON [dbo].[tblGLIjemst] 
(
	[A4GLIdentity] ASC,
	[glije_period] ASC,
	[glije_acct_no] ASC,
	[glije_date] ASC,
	[glije_src_sys] ASC,
	[glije_src_no] ASC,
	[glije_line_no] ASC
)WITH ( STATISTICS_NORECOMPUTE  = OFF,   IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
