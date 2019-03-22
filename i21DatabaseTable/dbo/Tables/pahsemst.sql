CREATE TABLE [dbo].[pahsemst] (
    [pahse_cus_no]         CHAR (10)       NOT NULL,
    [pahse_ccyy]           SMALLINT        NOT NULL,
    [pahse_rfd_type]       TINYINT         NOT NULL,
    [pahse_seq_no]         SMALLINT        NOT NULL,
    [pahse_rfd_sls_amt]    DECIMAL (9, 2)  NULL,
    [pahse_rfd_pur_amt]    DECIMAL (11, 3) NULL,
    [pahse_undist_equity]  DECIMAL (9, 2)  NULL,
    [pahse_undist_res]     DECIMAL (9, 2)  NULL,
    [pahse_tot_rfd_amt]    DECIMAL (9, 2)  NULL,
    [pahse_alloc_res_amt]  DECIMAL (9, 2)  NULL,
    [pahse_cash_amt]       DECIMAL (9, 2)  NULL,
    [pahse_stk_eqty_amt]   DECIMAL (9, 2)  NULL,
    [pahse_eqty_pyr_amt]   DECIMAL (9, 2)  NULL,
    [pahse_frac_pyr_amt]   DECIMAL (5, 2)  NULL,
    [pahse_stk_iss_amt]    DECIMAL (9, 2)  NULL,
    [pahse_frac_tyr_amt]   DECIMAL (5, 2)  NULL,
    [pahse_stk_div_amt]    DECIMAL (7, 2)  NULL,
    [pahse_srv_chg_amt]    DECIMAL (5, 2)  NULL,
    [pahse_fwt_amt]        DECIMAL (9, 2)  NULL,
    [pahse_chk_amt]        DECIMAL (9, 2)  NULL,
    [pahse_chk_rev_dt]     INT             NULL,
    [pahse_chk_no]         CHAR (8)        NULL,
    [pahse_trx_ind]        CHAR (1)        NULL,
    [pahse_equity_qual_yn] CHAR (1)        NULL,
    [pahse_trx_type]       CHAR (1)        NULL,
    [pahse_xfer_cus]       CHAR (10)       NULL,
    [pahse_user_id]        CHAR (16)       NULL,
    [pahse_user_rev_dt]    INT             NULL,
    [A4GLIdentity]         NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_pahsemst] PRIMARY KEY NONCLUSTERED ([pahse_cus_no] ASC, [pahse_ccyy] ASC, [pahse_rfd_type] ASC, [pahse_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ipahsemst0]
    ON [dbo].[pahsemst]([pahse_cus_no] ASC, [pahse_ccyy] ASC, [pahse_rfd_type] ASC, [pahse_seq_no] ASC);

