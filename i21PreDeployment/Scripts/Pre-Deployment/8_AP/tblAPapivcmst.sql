BEGIN
	IF NOT EXISTS(select top 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tblAPapivcmst')
	BEGIN
	EXEC('CREATE TABLE [dbo].[tblAPapivcmst](
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
		[A4GLIdentity] [numeric](9, 0) NOT NULL,
		[apchk_A4GLIdentity] INT NULL,
		[intBillId] INT NULL,
		[dtmDateImported] DATETIME NULL DEFAULT GETDATE(),
		[intId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY
	) ON [PRIMARY] ') 
	END    
END
