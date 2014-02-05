CREATE TABLE [dbo].[gatpomst] (
    [gatpo_pur_sls_ind] CHAR (1)        NOT NULL,
    [gatpo_com_cd]      CHAR (3)        NOT NULL,
    [gatpo_cus_no]      CHAR (10)       NOT NULL,
    [gatpo_ord_no]      CHAR (8)        NOT NULL,
    [gatpo_loc_no]      CHAR (3)        NULL,
    [gatpo_mkt_zone]    CHAR (3)        NULL,
    [gatpo_no_un]       INT             NULL,
    [gatpo_un_prc]      DECIMAL (9, 5)  NULL,
    [gatpo_comments]    CHAR (15)       NULL,
    [gatpo_due_yyyymm]  INT             NULL,
    [gatpo_ord_rev_dt]  INT             NULL,
    [gatpo_ord_hhmm]    INT             NULL,
    [gatpo_exp_rev_dt]  INT             NULL,
    [gatpo_del_pu_ind]  CHAR (1)        NULL,
    [gatpo_frt_rt]      DECIMAL (9, 5)  NULL,
    [gatpo_type]        CHAR (1)        NULL,
    [gatpo_printed_yn]  CHAR (1)        NULL,
    [gatpo_fill_yn]     CHAR (1)        NULL,
    [gatpo_spl_no]      CHAR (4)        NULL,
    [gatpo_text_no]     CHAR (2)        NULL,
    [gatpo_currency]    CHAR (3)        NULL,
    [gatpo_currency_rt] DECIMAL (15, 8) NULL,
    [gatpo_curr_un_prc] DECIMAL (11, 5) NULL,
    [gatpo_signed_yn]   CHAR (1)        NULL,
    [gatpo_buyer]       CHAR (15)       NULL,
    [gatpo_hit_rev_dt]  INT             NULL,
    [gatpo_hit_time]    SMALLINT        NULL,
    [gatpo_user_id]     CHAR (16)       NULL,
    [gatpo_user_rev_dt] CHAR (8)        NULL,
    [A4GLIdentity]      NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gatpomst] PRIMARY KEY NONCLUSTERED ([gatpo_pur_sls_ind] ASC, [gatpo_com_cd] ASC, [gatpo_cus_no] ASC, [gatpo_ord_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igatpomst0]
    ON [dbo].[gatpomst]([gatpo_pur_sls_ind] ASC, [gatpo_com_cd] ASC, [gatpo_cus_no] ASC, [gatpo_ord_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[gatpomst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gatpomst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gatpomst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gatpomst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gatpomst] TO PUBLIC
    AS [dbo];

