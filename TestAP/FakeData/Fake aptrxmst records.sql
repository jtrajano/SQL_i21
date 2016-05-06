CREATE PROCEDURE [AP].[Fake aptrxmst records]
AS

EXEC tSQLt.FakeTable 'dbo.aptrxmst', @Identity = 1;
EXEC tSQLt.FakeTable 'dbo.apeglmst', @Identity = 1;

INSERT INTO [dbo].[aptrxmst] ([aptrx_vnd_no], [aptrx_ivc_no], [aptrx_sys_rev_dt], [aptrx_sys_time], [aptrx_cbk_no], [aptrx_chk_no], [aptrx_trans_type], [aptrx_batch_no], [aptrx_pur_ord_no], [aptrx_po_rcpt_seq], [aptrx_ivc_rev_dt], [aptrx_disc_rev_dt], [aptrx_due_rev_dt], [aptrx_chk_rev_dt], [aptrx_gl_rev_dt], [aptrx_disc_pct], [aptrx_orig_amt], [aptrx_disc_amt], [aptrx_wthhld_amt], [aptrx_net_amt], [aptrx_1099_amt], [aptrx_comment], [aptrx_orig_type], [aptrx_name], [aptrx_recur_yn], [aptrx_currency], [aptrx_currency_rt], [aptrx_currency_cnt], [aptrx_user_id], [aptrx_user_rev_dt]) 
VALUES (N'BELLMAN   ', N'79365A            ', 20160219, 82401, N'01', N'        ', N'I', 30, N'00617999', 2, 20160212, 20160303, 20160303, 0, 20160212, CAST(0.00 AS Decimal(4, 2)), CAST(73.48 AS Decimal(11, 2)), CAST(0.00 AS Decimal(11, 2)), CAST(0.00 AS Decimal(11, 2)), CAST(73.48 AS Decimal(11, 2)), CAST(0.00 AS Decimal(11, 2)), NULL, N'I', N'BELLMAN OIL CO., INC.                             ', NULL, NULL, CAST(0.00000000 AS Decimal(15, 8)), NULL, NULL, 0)

INSERT [dbo].[aptrxmst] ([aptrx_vnd_no], [aptrx_ivc_no], [aptrx_sys_rev_dt], [aptrx_sys_time], [aptrx_cbk_no], [aptrx_chk_no], [aptrx_trans_type], [aptrx_batch_no], [aptrx_pur_ord_no], [aptrx_po_rcpt_seq], [aptrx_ivc_rev_dt], [aptrx_disc_rev_dt], [aptrx_due_rev_dt], [aptrx_chk_rev_dt], [aptrx_gl_rev_dt], [aptrx_disc_pct], [aptrx_orig_amt], [aptrx_disc_amt], [aptrx_wthhld_amt], [aptrx_net_amt], [aptrx_1099_amt], [aptrx_comment], [aptrx_orig_type], [aptrx_name], [aptrx_recur_yn], [aptrx_currency], [aptrx_currency_rt], [aptrx_currency_cnt], [aptrx_user_id], [aptrx_user_rev_dt]) 
VALUES (N'BREWMASTER', N'218070235626      ', 20160218, 160939, N'01', N'        ', N'I', 27, N'00338099', 1, 20160212, 20160307, 20160307, 0, 20160212, CAST(0.00 AS Decimal(4, 2)), CAST(951.04 AS Decimal(11, 2)), CAST(0.00 AS Decimal(11, 2)), CAST(0.00 AS Decimal(11, 2)), CAST(951.04 AS Decimal(11, 2)), CAST(0.00 AS Decimal(11, 2)), NULL, N'I', N'CANTEEN REFRESHMENT SERVICE                       ', NULL, NULL, CAST(0.00000000 AS Decimal(15, 8)), NULL, NULL, 0)

INSERT INTO [dbo].[apeglmst] ([apegl_cbk_no], [apegl_trx_ind], [apegl_vnd_no], [apegl_ivc_no], [apegl_dist_no], [apegl_alt_cbk_no], [apegl_gl_acct], [apegl_gl_amt], [apegl_gl_un])
VALUES (N'01', N'I', N'BELLMAN   ', N'79365A            ', 1, N'01', CAST(500601.00000006 AS Decimal(16, 8)), CAST(73.48 AS Decimal(11, 2)), CAST(0.0000 AS Decimal(13, 4)))

INSERT [dbo].[apeglmst] ([apegl_cbk_no], [apegl_trx_ind], [apegl_vnd_no], [apegl_ivc_no], [apegl_dist_no], [apegl_alt_cbk_no], [apegl_gl_acct], [apegl_gl_amt], [apegl_gl_un]) 
VALUES (N'01', N'I', N'BREWMASTER', N'218070235626      ', 1, N'01', CAST(500609.00000003 AS Decimal(16, 8)), CAST(951.04 AS Decimal(11, 2)), CAST(0.0000 AS Decimal(13, 4)))
