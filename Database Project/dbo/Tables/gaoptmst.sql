CREATE TABLE [dbo].[gaoptmst] (
    [gaopt_pur_sls_ind]   CHAR (1)        NOT NULL,
    [gaopt_com_cd]        CHAR (3)        NOT NULL,
    [gaopt_cus_no]        CHAR (10)       NOT NULL,
    [gaopt_ref_no]        CHAR (8)        NOT NULL,
    [gaopt_ref_seq_no]    TINYINT         NOT NULL,
    [gaopt_seq_no]        SMALLINT        NOT NULL,
    [gaopt_bot]           CHAR (1)        NOT NULL,
    [gaopt_bot_opt]       CHAR (5)        NOT NULL,
    [gaopt_option]        TINYINT         NULL,
    [gaopt_loc_no]        CHAR (3)        NULL,
    [gaopt_mkt_zone]      CHAR (3)        NULL,
    [gaopt_no_un]         DECIMAL (11, 3) NULL,
    [gaopt_trans_rev_dt]  INT             NULL,
    [gaopt_comments]      CHAR (15)       NULL,
    [gaopt_buy_sell]      CHAR (1)        NULL,
    [gaopt_put_call]      CHAR (1)        NULL,
    [gaopt_un_strk_prc]   DECIMAL (9, 5)  NULL,
    [gaopt_un_prem]       DECIMAL (9, 5)  NULL,
    [gaopt_un_srvc_fee]   DECIMAL (9, 5)  NULL,
    [gaopt_un_target_prc] DECIMAL (9, 5)  NULL,
    [gaopt_exp_rev_dt]    INT             NULL,
    [gaopt_status_ind]    CHAR (1)        NULL,
    [gaopt_prem_srvc_ind] CHAR (1)        NULL,
    [gaopt_bot_un_prc]    DECIMAL (9, 5)  NULL,
    [gaopt_prcd_rev_dt]   INT             NULL,
    [gaopt_prcd_un_prc]   DECIMAL (9, 5)  NULL,
    [gaopt_prcd_no_un]    DECIMAL (11, 3) NULL,
    [gaopt_prcd_amt]      DECIMAL (11, 2) NULL,
    [gaopt_currency]      CHAR (3)        NULL,
    [gaopt_currency_rt]   DECIMAL (15, 8) NULL,
    [gaopt_currency_cnt]  CHAR (8)        NULL,
    [gaopt_user_id]       CHAR (16)       NULL,
    [gaopt_user_rev_dt]   INT             NULL,
    [A4GLIdentity]        NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gaoptmst] PRIMARY KEY NONCLUSTERED ([gaopt_pur_sls_ind] ASC, [gaopt_com_cd] ASC, [gaopt_cus_no] ASC, [gaopt_ref_no] ASC, [gaopt_ref_seq_no] ASC, [gaopt_seq_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Igaoptmst0]
    ON [dbo].[gaoptmst]([gaopt_pur_sls_ind] ASC, [gaopt_com_cd] ASC, [gaopt_cus_no] ASC, [gaopt_ref_no] ASC, [gaopt_ref_seq_no] ASC, [gaopt_seq_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Igaoptmst1]
    ON [dbo].[gaoptmst]([gaopt_com_cd] ASC, [gaopt_bot] ASC, [gaopt_bot_opt] ASC, [gaopt_cus_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Igaoptmst2]
    ON [dbo].[gaoptmst]([gaopt_cus_no] ASC, [gaopt_ref_no] ASC, [gaopt_ref_seq_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gaoptmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gaoptmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gaoptmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gaoptmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[gaoptmst] TO PUBLIC
    AS [dbo];

