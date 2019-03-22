CREATE TABLE [dbo].[agclsmst] (
    [agcls_cd]              CHAR (3)        NOT NULL,
    [agcls_desc]            CHAR (18)       NULL,
    [agcls_sls_acct_no]     DECIMAL (16, 8) NULL,
    [agcls_pur_acct_no]     DECIMAL (16, 8) NULL,
    [agcls_var_acct_no]     DECIMAL (16, 8) NULL,
    [agcls_inv_acct_no]     DECIMAL (16, 8) NULL,
    [agcls_ppd_inv_acct_no] DECIMAL (16, 8) NULL,
    [agcls_beg_inv_acct_no] DECIMAL (16, 8) NULL,
    [agcls_end_inv_acct_no] DECIMAL (16, 8) NULL,
    [agcls_gl_div_no]       TINYINT         NULL,
    [agcls_sa_by_ton_yn]    CHAR (1)        NULL,
    [agcls_wn_transmit_yn]  CHAR (1)        NULL,
    [agcls_lob_code]        TINYINT         NULL,
    [agcls_agris_cat]       CHAR (2)        NULL,
    [agcls_dflt_prc_no_dec] TINYINT         NULL,
    [agcls_user_id]         CHAR (16)       NULL,
    [agcls_user_rev_dt]     INT             NULL,
    [A4GLIdentity]          NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agclsmst] PRIMARY KEY NONCLUSTERED ([agcls_cd] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagclsmst0]
    ON [dbo].[agclsmst]([agcls_cd] ASC);

