﻿CREATE TABLE [dbo].[tblAPaptrxmst] (
    [aptrx_vnd_no]       CHAR (10)       NOT NULL,
    [aptrx_ivc_no]       CHAR (26)       NOT NULL,
    [aptrx_sys_rev_dt]   INT             NOT NULL,
    [aptrx_sys_time]     INT             NOT NULL,
    [aptrx_cbk_no]       CHAR (2)        NOT NULL,
    [aptrx_chk_no]       CHAR (8)        NOT NULL,
    [aptrx_trans_type]   CHAR (1)        NULL,
    [aptrx_batch_no]     SMALLINT        NULL,
    [aptrx_pur_ord_no]   CHAR (8)        NULL,
    [aptrx_po_rcpt_seq]  TINYINT         NULL,
    [aptrx_ivc_rev_dt]   INT             NULL,
    [aptrx_disc_rev_dt]  INT             NULL,
    [aptrx_due_rev_dt]   INT             NULL,
    [aptrx_chk_rev_dt]   INT             NULL,
    [aptrx_gl_rev_dt]    INT             NULL,
    [aptrx_disc_pct]     DECIMAL (4, 2)  NULL,
    [aptrx_orig_amt]     DECIMAL (11, 2) NULL,
    [aptrx_disc_amt]     DECIMAL (11, 2) NULL,
    [aptrx_wthhld_amt]   DECIMAL (11, 2) NULL,
    [aptrx_net_amt]      DECIMAL (11, 2) NULL,
    [aptrx_1099_amt]     DECIMAL (11, 2) NULL,
    [aptrx_comment]      CHAR (30)       NULL,
    [aptrx_orig_type]    CHAR (1)        NULL,
    [aptrx_name]         CHAR (50)       NULL,
    [aptrx_recur_yn]     CHAR (1)        NULL,
    [aptrx_currency]     CHAR (3)        NULL,
    [aptrx_currency_rt]  DECIMAL (15, 8) NULL,
    [aptrx_currency_cnt] CHAR (8)        NULL,
    [aptrx_user_id]      CHAR (16)       NULL,
    [aptrx_user_rev_dt]  INT             NULL,
    [A4GLIdentity]       NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
	[intBillId] INT
    CONSTRAINT [APk_aptrxmst] PRIMARY KEY NONCLUSTERED ([aptrx_vnd_no] ASC, [aptrx_ivc_no] ASC), 
    [dtmDateImported] DATETIME NOT NULL DEFAULT GETDATE()
);


GO
CREATE UNIQUE CLUSTERED INDEX [APIaptrxmst0]
    ON [dbo].[tblAPaptrxmst]([aptrx_vnd_no] ASC, [aptrx_ivc_no] ASC);


GO
CREATE NONCLUSTERED INDEX [APIaptrxmst1]
    ON [dbo].[tblAPaptrxmst]([aptrx_sys_rev_dt] ASC, [aptrx_sys_time] ASC);


GO
CREATE NONCLUSTERED INDEX [APIaptrxmst2]
    ON [dbo].[tblAPaptrxmst]([aptrx_cbk_no] ASC, [aptrx_chk_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblAPaptrxmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblAPaptrxmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[tblAPaptrxmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblAPaptrxmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblAPaptrxmst] TO PUBLIC
    AS [dbo];

