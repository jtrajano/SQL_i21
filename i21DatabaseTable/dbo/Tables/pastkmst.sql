CREATE TABLE [dbo].[pastkmst] (
    [pastk_cus_no]           CHAR (10)      NOT NULL,
    [pastk_cert_no]          CHAR (8)       NOT NULL,
    [pastk_stock_status]     CHAR (1)       NULL,
    [pastk_stock_type]       TINYINT        NULL,
    [pastk_no_shares]        DECIMAL (9, 2) NULL,
    [pastk_par_value]        SMALLINT       NULL,
    [pastk_issue_rev_dt]     INT            NULL,
    [pastk_activity_cd]      CHAR (1)       NULL,
    [pastk_chk_no]           CHAR (8)       NULL,
    [pastk_trx_ind]          CHAR (1)       NULL,
    [pastk_chk_rev_dt]       INT            NULL,
    [pastk_chk_amt]          DECIMAL (9, 2) NULL,
    [pastk_xfer_to_cus_no]   CHAR (10)      NULL,
    [pastk_xfer_to_rev_dt]   INT            NULL,
    [pastk_bond_no]          CHAR (10)      NULL,
    [pastk_bond_rev_dt]      INT            NULL,
    [pastk_xfer_from_cus_no] CHAR (10)      NULL,
    [pastk_xfer_from_rev_dt] INT            NULL,
    [pastk_user_id]          CHAR (16)      NULL,
    [pastk_user_rev_dt]      INT            NULL,
    [A4GLIdentity]           NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_pastkmst] PRIMARY KEY NONCLUSTERED ([pastk_cus_no] ASC, [pastk_cert_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ipastkmst0]
    ON [dbo].[pastkmst]([pastk_cus_no] ASC, [pastk_cert_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Ipastkmst1]
    ON [dbo].[pastkmst]([pastk_cert_no] ASC);

