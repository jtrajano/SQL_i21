CREATE TABLE [dbo].[apivcmst] (
    [apivc_vnd_no]       CHAR (10)       NOT NULL,
    [apivc_ivc_no]       CHAR (18)       NOT NULL,
    [apivc_status_ind]   CHAR (1)        NOT NULL,
    [apivc_cbk_no]       CHAR (2)        NOT NULL,
    [apivc_chk_no]       CHAR (8)        NOT NULL,
    [apivc_trans_type]   CHAR (1)        NULL,
    [apivc_pay_ind]      CHAR (1)        NULL,
    [apivc_ap_audit_no]  SMALLINT        NULL,
    [apivc_pur_ord_no]   CHAR (8)        NULL,
    [apivc_po_rcpt_seq]  TINYINT         NULL,
    [apivc_ivc_rev_dt]   INT             NULL,
    [apivc_disc_rev_dt]  INT             NULL,
    [apivc_due_rev_dt]   INT             NULL,
    [apivc_chk_rev_dt]   INT             NULL,
    [apivc_gl_rev_dt]    INT             NULL,
    [apivc_orig_amt]     DECIMAL (11, 2) NULL,
    [apivc_disc_avail]   DECIMAL (11, 2) NULL,
    [apivc_disc_taken]   DECIMAL (11, 2) NULL,
    [apivc_wthhld_amt]   DECIMAL (11, 2) NULL,
    [apivc_net_amt]      DECIMAL (11, 2) NULL,
    [apivc_1099_amt]     DECIMAL (11, 2) NULL,
    [apivc_comment]      CHAR (30)       NULL,
    [apivc_adv_chk_no]   INT             NULL,
    [apivc_recur_yn]     CHAR (1)        NULL,
    [apivc_currency]     CHAR (3)        NULL,
    [apivc_currency_rt]  DECIMAL (15, 8) NULL,
    [apivc_currency_cnt] CHAR (8)        NULL,
    [apivc_user_id]      CHAR (16)       NULL,
    [apivc_user_rev_dt]  INT             NULL,
    [A4GLIdentity]       NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_apivcmst] PRIMARY KEY NONCLUSTERED ([apivc_vnd_no] ASC, [apivc_ivc_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iapivcmst0]
    ON [dbo].[apivcmst]([apivc_vnd_no] ASC, [apivc_ivc_no] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iapivcmst1]
    ON [dbo].[apivcmst]([apivc_status_ind] ASC, [apivc_vnd_no] ASC, [apivc_ivc_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iapivcmst2]
    ON [dbo].[apivcmst]([apivc_ivc_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iapivcmst3]
    ON [dbo].[apivcmst]([apivc_cbk_no] ASC, [apivc_chk_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[apivcmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[apivcmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[apivcmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[apivcmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[apivcmst] TO PUBLIC
    AS [dbo];

