CREATE TABLE [dbo].[pastemst] (
    [paste_cus_no]           CHAR (10)      NOT NULL,
    [paste_cert_no]          CHAR (8)       NOT NULL,
    [paste_stock_status]     CHAR (1)       NULL,
    [paste_stock_type]       TINYINT        NULL,
    [paste_no_shares]        DECIMAL (9, 2) NULL,
    [paste_par_value]        SMALLINT       NULL,
    [paste_issue_rev_dt]     INT            NULL,
    [paste_activity_cd]      CHAR (1)       NULL,
    [paste_chk_no]           CHAR (8)       NULL,
    [paste_trx_ind]          CHAR (1)       NULL,
    [paste_chk_rev_dt]       INT            NULL,
    [paste_chk_amt]          DECIMAL (9, 2) NULL,
    [paste_xfer_to_cus_no]   CHAR (10)      NULL,
    [paste_xfer_to_rev_dt]   INT            NULL,
    [paste_bond_no]          CHAR (10)      NULL,
    [paste_bond_rev_dt]      INT            NULL,
    [paste_xfer_from_cus_no] CHAR (10)      NULL,
    [paste_xfer_from_rev_dt] INT            NULL,
    [paste_user_id]          CHAR (16)      NULL,
    [paste_user_rev_dt]      INT            NULL,
    [A4GLIdentity]           NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_pastemst] PRIMARY KEY NONCLUSTERED ([paste_cus_no] ASC, [paste_cert_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ipastemst0]
    ON [dbo].[pastemst]([paste_cus_no] ASC, [paste_cert_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Ipastemst1]
    ON [dbo].[pastemst]([paste_cert_no] ASC);

