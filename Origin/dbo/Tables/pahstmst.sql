CREATE TABLE [dbo].[pahstmst] (
    [pahst_cus_no]         CHAR (10)       NOT NULL,
    [pahst_ccyy]           SMALLINT        NOT NULL,
    [pahst_rfd_type]       TINYINT         NOT NULL,
    [pahst_seq_no]         SMALLINT        NOT NULL,
    [pahst_rfd_sls_amt]    DECIMAL (9, 2)  NULL,
    [pahst_rfd_pur_amt]    DECIMAL (11, 3) NULL,
    [pahst_undist_equity]  DECIMAL (9, 2)  NULL,
    [pahst_undist_res]     DECIMAL (9, 2)  NULL,
    [pahst_tot_rfd_amt]    DECIMAL (9, 2)  NULL,
    [pahst_alloc_res_amt]  DECIMAL (9, 2)  NULL,
    [pahst_cash_amt]       DECIMAL (9, 2)  NULL,
    [pahst_stk_eqty_amt]   DECIMAL (9, 2)  NULL,
    [pahst_eqty_pyr_amt]   DECIMAL (9, 2)  NULL,
    [pahst_frac_pyr_amt]   DECIMAL (5, 2)  NULL,
    [pahst_stk_iss_amt]    DECIMAL (9, 2)  NULL,
    [pahst_frac_tyr_amt]   DECIMAL (5, 2)  NULL,
    [pahst_stk_div_amt]    DECIMAL (7, 2)  NULL,
    [pahst_srv_chg_amt]    DECIMAL (5, 2)  NULL,
    [pahst_fwt_amt]        DECIMAL (9, 2)  NULL,
    [pahst_chk_amt]        DECIMAL (9, 2)  NULL,
    [pahst_chk_rev_dt]     INT             NULL,
    [pahst_chk_no]         CHAR (8)        NULL,
    [pahst_trx_ind]        CHAR (1)        NULL,
    [pahst_equity_qual_yn] CHAR (1)        NULL,
    [pahst_trx_type]       CHAR (1)        NULL,
    [pahst_xfer_cus]       CHAR (10)       NULL,
    [pahst_user_id]        CHAR (16)       NULL,
    [pahst_user_rev_dt]    INT             NULL,
    [A4GLIdentity]         NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    [pahst_xfer_rfd_type]  TINYINT         NULL,
    CONSTRAINT [k_pahstmst] PRIMARY KEY NONCLUSTERED ([pahst_cus_no] ASC, [pahst_ccyy] ASC, [pahst_rfd_type] ASC, [pahst_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ipahstmst0]
    ON [dbo].[pahstmst]([pahst_cus_no] ASC, [pahst_ccyy] ASC, [pahst_rfd_type] ASC, [pahst_seq_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[pahstmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[pahstmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[pahstmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[pahstmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[pahstmst] TO PUBLIC
    AS [dbo];

