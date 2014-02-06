CREATE TABLE [dbo].[pacusmst] (
    [pacus_no]                CHAR (10)       NOT NULL,
    [pacus_member_rev_dt]     INT             NULL,
    [pacus_birth_rev_dt]      INT             NULL,
    [pacus_deceased_rev_dt]   INT             NULL,
    [pacus_last_activ_rev_dt] INT             NULL,
    [pacus_stock_status]      CHAR (1)        NULL,
    [pacus_frac_shares]       DECIMAL (5, 2)  NULL,
    [pacus_undist_equity]     DECIMAL (9, 2)  NULL,
    [pacus_undist_res]        DECIMAL (9, 2)  NULL,
    [pacus_shares_1]          DECIMAL (9, 2)  NULL,
    [pacus_shares_2]          DECIMAL (9, 2)  NULL,
    [pacus_shares_3]          DECIMAL (9, 2)  NULL,
    [pacus_shares_4]          DECIMAL (9, 2)  NULL,
    [pacus_shares_5]          DECIMAL (9, 2)  NULL,
    [pacus_shares_6]          DECIMAL (9, 2)  NULL,
    [pacus_shares_7]          DECIMAL (9, 2)  NULL,
    [pacus_shares_8]          DECIMAL (9, 2)  NULL,
    [pacus_shares_9]          DECIMAL (9, 2)  NULL,
    [pacus_shares_10]         DECIMAL (9, 2)  NULL,
    [pacus_ytd_vol_amt_1]     DECIMAL (11, 3) NULL,
    [pacus_ytd_vol_amt_2]     DECIMAL (11, 3) NULL,
    [pacus_ytd_vol_amt_3]     DECIMAL (11, 3) NULL,
    [pacus_ytd_vol_amt_4]     DECIMAL (11, 3) NULL,
    [pacus_ytd_vol_amt_5]     DECIMAL (11, 3) NULL,
    [pacus_ytd_vol_amt_6]     DECIMAL (11, 3) NULL,
    [pacus_ytd_vol_amt_7]     DECIMAL (11, 3) NULL,
    [pacus_ytd_vol_amt_8]     DECIMAL (11, 3) NULL,
    [pacus_ytd_vol_amt_9]     DECIMAL (11, 3) NULL,
    [pacus_ytd_vol_amt_10]    DECIMAL (11, 3) NULL,
    [pacus_ytd_vol_amt_11]    DECIMAL (11, 3) NULL,
    [pacus_ytd_vol_amt_12]    DECIMAL (11, 3) NULL,
    [pacus_ytd_vol_amt_13]    DECIMAL (11, 3) NULL,
    [pacus_ytd_vol_amt_14]    DECIMAL (11, 3) NULL,
    [pacus_ytd_vol_amt_15]    DECIMAL (11, 3) NULL,
    [pacus_ytd_vol_amt_16]    DECIMAL (11, 3) NULL,
    [pacus_ytd_vol_amt_17]    DECIMAL (11, 3) NULL,
    [pacus_ytd_vol_amt_18]    DECIMAL (11, 3) NULL,
    [pacus_ytd_vol_amt_19]    DECIMAL (11, 3) NULL,
    [pacus_ytd_vol_amt_20]    DECIMAL (11, 3) NULL,
    [pacus_nyr_vol_amt_1]     DECIMAL (11, 3) NULL,
    [pacus_nyr_vol_amt_2]     DECIMAL (11, 3) NULL,
    [pacus_nyr_vol_amt_3]     DECIMAL (11, 3) NULL,
    [pacus_nyr_vol_amt_4]     DECIMAL (11, 3) NULL,
    [pacus_nyr_vol_amt_5]     DECIMAL (11, 3) NULL,
    [pacus_nyr_vol_amt_6]     DECIMAL (11, 3) NULL,
    [pacus_nyr_vol_amt_7]     DECIMAL (11, 3) NULL,
    [pacus_nyr_vol_amt_8]     DECIMAL (11, 3) NULL,
    [pacus_nyr_vol_amt_9]     DECIMAL (11, 3) NULL,
    [pacus_nyr_vol_amt_10]    DECIMAL (11, 3) NULL,
    [pacus_nyr_vol_amt_11]    DECIMAL (11, 3) NULL,
    [pacus_nyr_vol_amt_12]    DECIMAL (11, 3) NULL,
    [pacus_nyr_vol_amt_13]    DECIMAL (11, 3) NULL,
    [pacus_nyr_vol_amt_14]    DECIMAL (11, 3) NULL,
    [pacus_nyr_vol_amt_15]    DECIMAL (11, 3) NULL,
    [pacus_nyr_vol_amt_16]    DECIMAL (11, 3) NULL,
    [pacus_nyr_vol_amt_17]    DECIMAL (11, 3) NULL,
    [pacus_nyr_vol_amt_18]    DECIMAL (11, 3) NULL,
    [pacus_nyr_vol_amt_19]    DECIMAL (11, 3) NULL,
    [pacus_nyr_vol_amt_20]    DECIMAL (11, 3) NULL,
    [pacus_rfd_pur_amt]       DECIMAL (11, 3) NULL,
    [pacus_rfd_sls_amt]       DECIMAL (9, 2)  NULL,
    [pacus_rfd_tot_amt]       DECIMAL (9, 2)  NULL,
    [pacus_rfd_alloc_res_amt] DECIMAL (9, 2)  NULL,
    [pacus_rfd_cash_amt]      DECIMAL (9, 2)  NULL,
    [pacus_rfd_stk_eqty_amt]  DECIMAL (9, 2)  NULL,
    [pacus_rfd_eqty_pyr_amt]  DECIMAL (9, 2)  NULL,
    [pacus_rfd_res_pyr_amt]   DECIMAL (9, 2)  NULL,
    [pacus_rfd_frac_pyr_amt]  DECIMAL (5, 2)  NULL,
    [pacus_rfd_stk_cert_no]   INT             NULL,
    [pacus_rfd_stk_iss_amt]   DECIMAL (9, 2)  NULL,
    [pacus_rfd_frac_tyr_amt]  DECIMAL (5, 2)  NULL,
    [pacus_rfd_srv_chg_amt]   DECIMAL (5, 2)  NULL,
    [pacus_rfd_fwt_amt]       DECIMAL (9, 2)  NULL,
    [pacus_rfd_chk_amt]       DECIMAL (9, 2)  NULL,
    [pacus_rfd_chk_rev_dt]    INT             NULL,
    [pacus_rfd_chk_no]        CHAR (8)        NULL,
    [pacus_patron_class]      CHAR (1)        NULL,
    [pacus_cancel_equity_res] DECIMAL (9, 2)  NULL,
    [pacus_bkup_whld_yn]      CHAR (1)        NULL,
    [pacus_user_id]           CHAR (16)       NULL,
    [pacus_user_rev_dt]       INT             NULL,
    [A4GLIdentity]            NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_pacusmst] PRIMARY KEY NONCLUSTERED ([pacus_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ipacusmst0]
    ON [dbo].[pacusmst]([pacus_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[pacusmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[pacusmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[pacusmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[pacusmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[pacusmst] TO PUBLIC
    AS [dbo];

