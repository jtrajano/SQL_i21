CREATE TABLE [dbo].[agtaxmst] (
    [agtax_itm_no]        CHAR (13)       NOT NULL,
    [agtax_state]         CHAR (2)        NOT NULL,
    [agtax_auth_id1]      CHAR (3)        NOT NULL,
    [agtax_auth_id2]      CHAR (3)        NOT NULL,
    [agtax_if_rt]         DECIMAL (9, 6)  NULL,
    [agtax_if_gl_acct]    DECIMAL (16, 8) NULL,
    [agtax_fet_rt]        DECIMAL (9, 6)  NULL,
    [agtax_fet_sls_acct]  DECIMAL (16, 8) NULL,
    [agtax_fet_pur_acct]  DECIMAL (16, 8) NULL,
    [agtax_fet_eft_yn]    CHAR (1)        NULL,
    [agtax_set_rt]        DECIMAL (9, 6)  NULL,
    [agtax_set_sls_acct]  DECIMAL (16, 8) NULL,
    [agtax_set_pur_acct]  DECIMAL (16, 8) NULL,
    [agtax_set_eft_yn]    CHAR (1)        NULL,
    [agtax_sst_rt]        DECIMAL (9, 6)  NULL,
    [agtax_sst_sls_acct]  DECIMAL (16, 8) NULL,
    [agtax_sst_pur_acct]  DECIMAL (16, 8) NULL,
    [agtax_sst_pu]        CHAR (1)        NULL,
    [agtax_sst_on_fet_yn] CHAR (1)        NULL,
    [agtax_sst_on_set_yn] CHAR (1)        NULL,
    [agtax_sst_eft_yn]    CHAR (1)        NULL,
    [agtax_pst_rt]        DECIMAL (9, 6)  NULL,
    [agtax_pst_sls_acct]  DECIMAL (16, 8) NULL,
    [agtax_pst_pur_acct]  DECIMAL (16, 8) NULL,
    [agtax_pst_pu]        CHAR (1)        NULL,
    [agtax_pst_on_fet_yn] CHAR (1)        NULL,
    [agtax_pst_on_set_yn] CHAR (1)        NULL,
    [agtax_lc1_rt]        DECIMAL (9, 6)  NULL,
    [agtax_lc1_sls_acct]  DECIMAL (16, 8) NULL,
    [agtax_lc1_pur_acct]  DECIMAL (16, 8) NULL,
    [agtax_lc1_pu]        CHAR (1)        NULL,
    [agtax_sst_on_lc1_yn] CHAR (1)        NULL,
    [agtax_lc1_on_fet_yn] CHAR (1)        NULL,
    [agtax_lc1_eft_yn]    CHAR (1)        NULL,
    [agtax_lc1_scrn_desc] CHAR (3)        NULL,
    [agtax_lc2_rt]        DECIMAL (9, 6)  NULL,
    [agtax_lc2_sls_acct]  DECIMAL (16, 8) NULL,
    [agtax_lc2_pur_acct]  DECIMAL (16, 8) NULL,
    [agtax_lc2_pu]        CHAR (1)        NULL,
    [agtax_sst_on_lc2_yn] CHAR (1)        NULL,
    [agtax_lc2_on_fet_yn] CHAR (1)        NULL,
    [agtax_lc2_eft_yn]    CHAR (1)        NULL,
    [agtax_lc2_scrn_desc] CHAR (3)        NULL,
    [agtax_lc3_rt]        DECIMAL (9, 6)  NULL,
    [agtax_lc3_sls_acct]  DECIMAL (16, 8) NULL,
    [agtax_lc3_pur_acct]  DECIMAL (16, 8) NULL,
    [agtax_lc3_pu]        CHAR (1)        NULL,
    [agtax_sst_on_lc3_yn] CHAR (1)        NULL,
    [agtax_lc3_on_fet_yn] CHAR (1)        NULL,
    [agtax_lc3_eft_yn]    CHAR (1)        NULL,
    [agtax_lc3_scrn_desc] CHAR (3)        NULL,
    [agtax_lc4_rt]        DECIMAL (9, 6)  NULL,
    [agtax_lc4_sls_acct]  DECIMAL (16, 8) NULL,
    [agtax_lc4_pur_acct]  DECIMAL (16, 8) NULL,
    [agtax_lc4_pu]        CHAR (1)        NULL,
    [agtax_sst_on_lc4_yn] CHAR (1)        NULL,
    [agtax_lc4_on_fet_yn] CHAR (1)        NULL,
    [agtax_lc4_eft_yn]    CHAR (1)        NULL,
    [agtax_lc4_scrn_desc] CHAR (3)        NULL,
    [agtax_lc5_rt]        DECIMAL (9, 6)  NULL,
    [agtax_lc5_sls_acct]  DECIMAL (16, 8) NULL,
    [agtax_lc5_pur_acct]  DECIMAL (16, 8) NULL,
    [agtax_lc5_pu]        CHAR (1)        NULL,
    [agtax_sst_on_lc5_yn] CHAR (1)        NULL,
    [agtax_lc5_on_fet_yn] CHAR (1)        NULL,
    [agtax_lc5_eft_yn]    CHAR (1)        NULL,
    [agtax_lc5_scrn_desc] CHAR (3)        NULL,
    [agtax_lc6_rt]        DECIMAL (9, 6)  NULL,
    [agtax_lc6_sls_acct]  DECIMAL (16, 8) NULL,
    [agtax_lc6_pur_acct]  DECIMAL (16, 8) NULL,
    [agtax_lc6_pu]        CHAR (1)        NULL,
    [agtax_sst_on_lc6_yn] CHAR (1)        NULL,
    [agtax_lc6_on_fet_yn] CHAR (1)        NULL,
    [agtax_lc6_eft_yn]    CHAR (1)        NULL,
    [agtax_lc6_scrn_desc] CHAR (3)        NULL,
    [agtax_user_id]       CHAR (16)       NULL,
    [agtax_user_rev_dt]   INT             NULL,
    [A4GLIdentity]        NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agtaxmst] PRIMARY KEY NONCLUSTERED ([agtax_itm_no] ASC, [agtax_state] ASC, [agtax_auth_id1] ASC, [agtax_auth_id2] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iagtaxmst0]
    ON [dbo].[agtaxmst]([agtax_itm_no] ASC, [agtax_state] ASC, [agtax_auth_id1] ASC, [agtax_auth_id2] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agtaxmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agtaxmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agtaxmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agtaxmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[agtaxmst] TO PUBLIC
    AS [dbo];

