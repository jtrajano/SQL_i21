CREATE TABLE [dbo].[tblCMApchkmstArchive]
(
	[intApchkmstId] INT NOT NULL PRIMARY KEY IDENTITY, 
	[intUndepositedFundId] INT NOT NULL,
    [apchk_cbk_no] CHAR(2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL, 
    [apchk_rev_dt] INT NOT NULL, 
    [apchk_trx_ind] CHAR COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL, 
    [apchk_chk_no] CHAR(8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL, 
    [apchk_alt_cbk_no] CHAR(2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL, 
    [apchk_alt_trx_ind] CHAR COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL, 
    [apchk_alt_chk_no] CHAR(8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL, 
    [apchk_vnd_no] CHAR(10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL, 
    [apchk_alt2_cbk_no] CHAR(2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL, 
    [apchk_name] CHAR(50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL, 
    [apchk_addr_1] CHAR(30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [apchk_addr_2] CHAR(30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [apchk_city] CHAR(20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [apchk_st] CHAR(2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [apchk_zip] CHAR(10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [apchk_chk_amt] DECIMAL(11, 2) NULL, 
    [apchk_disc_amt] DECIMAL(11, 2) NULL, 
    [apchk_wthhld_amt] DECIMAL(11, 2) NULL, 
    [apchk_1099_amt] DECIMAL(11, 2) NULL, 
    [apchk_gl_rev_dt] INT NULL, 
    [apchk_adv_chk_yn] CHAR COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [apchk_man_auto_ind] CHAR COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [apchk_void_ind] CHAR COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [apchk_void_rev_dt] INT NULL, 
    [apchk_cleared_ind] CHAR COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [apchk_clear_rev_dt] INT NULL, 
    [apchk_src_sys] CHAR(2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [apchk_comment_1] CHAR(40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [apchk_comment_2] CHAR(40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [apchk_comment_3] CHAR(40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [apchk_currency_rt] DECIMAL(15, 8) NULL, 
    [apchk_currency_cnt] CHAR(8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [apchk_payee_1] CHAR(50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [apchk_payee_2] CHAR(50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [apchk_payee_3] CHAR(50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [apchk_payee_4] CHAR(50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [apchk_user_id] CHAR(16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [apchk_user_rev_dt] INT NULL, 
    [apchk_chk_exp_yn] CHAR COLLATE SQL_Latin1_General_CP1_CS_AS NULL, 
    [intCreatedUserId] INT NULL, 
    [dtmCreated] DATETIME NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1
)

GO
CREATE INDEX [IX_tblCMApchkmstArchive_apchk_cbk_no] ON [dbo].[tblCMApchkmstArchive] ([apchk_cbk_no])
GO
CREATE INDEX [IX_tblCMApchkmstArchive_apchk_chk_no] ON [dbo].[tblCMApchkmstArchive] ([apchk_chk_no])
GO
CREATE INDEX [IX_tblCMApchkmstArchive_apchk_vnd_no] ON [dbo].[tblCMApchkmstArchive] ([apchk_vnd_no])
GO
CREATE INDEX [IX_tblCMApchkmstArchive_apchk_rev_dt] ON [dbo].[tblCMApchkmstArchive] ([apchk_rev_dt])
GO
CREATE INDEX [IX_tblCMApchkmstArchive_apchk_trx_ind] ON [dbo].[tblCMApchkmstArchive] ([apchk_trx_ind])
