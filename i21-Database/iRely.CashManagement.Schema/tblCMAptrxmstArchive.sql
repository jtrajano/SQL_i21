CREATE TABLE [dbo].[tblCMAptrxmstArchive]
(
	[intAptrxmstId] INT NOT NULL PRIMARY KEY IDENTITY, 
	[intUndepositedFundId] INT NOT NULL,
    [aptrx_vnd_no] CHAR(10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL, 
    [aptrx_ivc_no] CHAR(18) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL, 
    [aptrx_sys_rev_dt] INT NOT NULL, 
    [aptrx_sys_time] INT NOT NULL, 
    [aptrx_cbk_no] CHAR(2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL, 
    [aptrx_chk_no] CHAR(8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL, 
    [aptrx_trans_type] CHAR COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [aptrx_batch_no] SMALLINT NULL, 
    [aptrx_pur_ord_no] CHAR(8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [aptrx_po_rcpt_seq] CHAR(4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [aptrx_ivc_rev_dt] INT NULL, 
    [aptrx_disc_rev_dt] INT NULL, 
    [aptrx_due_rev_dt] INT NULL, 
    [aptrx_chk_rev_dt] INT NULL, 
    [aptrx_gl_rev_dt] INT NULL, 
    [aptrx_disc_pct] DECIMAL(4, 2) NULL, 
    [aptrx_orig_amt] DECIMAL(11, 2) NULL, 
    [aptrx_disc_amt] DECIMAL(11, 2) NULL, 
    [aptrx_wthhld_amt] DECIMAL(11, 2) NULL, 
    [aptrx_net_amt] DECIMAL(11, 2) NULL, 
    [aptrx_1099_amt] DECIMAL(11, 2) NULL, 
    [aptrx_comment] CHAR(30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [aptrx_orig_type] CHAR COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [aptrx_name] CHAR(50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [aptrx_recur_yn] CHAR COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [aptrx_currency] CHAR(3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [aptrx_currency_rt] DECIMAL(15, 8) NULL, 
    [aptrx_currency_cnt] CHAR(8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [aptrx_user_id] CHAR(16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [aptrx_user_rev_dt] INT NULL, 
    [intCreatedUserId] INT NULL, 
    [dtmCreated] DATETIME NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1
)

GO
CREATE INDEX [IX_tblCMAptrxmstArchive_aptrx_vnd_no] ON [dbo].[tblCMAptrxmstArchive] ([aptrx_vnd_no])
GO
CREATE INDEX [IX_tblCMAptrxmstArchive_aptrx_ivc_no] ON [dbo].[tblCMAptrxmstArchive] ([aptrx_ivc_no])
GO
CREATE INDEX [IX_tblCMAptrxmstArchive_aptrx_cbk_no] ON [dbo].[tblCMAptrxmstArchive] ([aptrx_cbk_no])
GO
CREATE INDEX [IX_tblCMAptrxmstArchive_aptrx_chk_no] ON [dbo].[tblCMAptrxmstArchive] ([aptrx_chk_no])

