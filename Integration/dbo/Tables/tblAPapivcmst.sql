CREATE TABLE [dbo].[tblAPapivcmst](
	[apivc_vnd_no] [char](10) NOT NULL,
	[apivc_ivc_no] [char](50) NOT NULL,
	[apivc_status_ind] [char](1) NOT NULL,
	[apivc_cbk_no] [char](2) NOT NULL,
	[apivc_chk_no] [char](8) NOT NULL,
	[apivc_trans_type] [char](1) NULL,
	[apivc_pay_ind] [char](1) NULL,
	[apivc_ap_audit_no] [smallint] NULL,
	[apivc_pur_ord_no] [char](8) NULL,
	[apivc_po_rcpt_seq] [char](4) NULL,
	[apivc_ivc_rev_dt] [int] NULL,
	[apivc_disc_rev_dt] [int] NULL,
	[apivc_due_rev_dt] [int] NULL,
	[apivc_chk_rev_dt] [int] NULL,
	[apivc_gl_rev_dt] [int] NULL,
	[apivc_orig_amt] [decimal](11, 2) NULL,
	[apivc_disc_avail] [decimal](11, 2) NULL,
	[apivc_disc_taken] [decimal](11, 2) NULL,
	[apivc_wthhld_amt] [decimal](11, 2) NULL,
	[apivc_net_amt] [decimal](11, 2) NULL,
	[apivc_1099_amt] [decimal](11, 2) NULL,
	[apivc_comment] [char](30) NULL,
	[apivc_adv_chk_no] [int] NULL,
	[apivc_recur_yn] [char](1) NULL,
	[apivc_currency] [char](3) NULL,
	[apivc_currency_rt] [decimal](15, 8) NULL,
	[apivc_currency_cnt] [char](8) NULL,
	[apivc_user_id] [char](16) NULL,
	[apivc_user_rev_dt] [int] NULL,
	[A4GLIdentity] [numeric](9, 0) IDENTITY(1,1) NOT NULL,
	[intBillId] INT
 CONSTRAINT [k_tblAPapivcmst] PRIMARY KEY NONCLUSTERED 
(
	[apivc_vnd_no] ASC,
	[apivc_ivc_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY], 
    [dtmDateImported] DATETIME NULL DEFAULT GETDATE()
) ON [PRIMARY]