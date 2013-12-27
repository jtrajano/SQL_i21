CREATE TABLE [dbo].[prernmst] (
    [prern_code]              CHAR (3)        NOT NULL,
    [prern_description]       CHAR (25)       NULL,
    [prern_literal]           CHAR (10)       NULL,
    [prern_class]             CHAR (1)        NULL,
    [prern_rate_factor]       DECIMAL (5, 4)  NULL,
    [prern_std_yn]            CHAR (1)        NULL,
    [prern_vary_by_pc_yn]     CHAR (1)        NULL,
    [prern_tax_method]        CHAR (1)        NULL,
    [prern_ss_exempt_yn]      CHAR (1)        NULL,
    [prern_med_exempt_yn]     CHAR (1)        NULL,
    [prern_fwt_exempt_yn]     CHAR (1)        NULL,
    [prern_swt_exempt_yn]     CHAR (1)        NULL,
    [prern_fui_exempt_yn]     CHAR (1)        NULL,
    [prern_sui_exempt_yn]     CHAR (1)        NULL,
    [prern_city_exempt_yn]    CHAR (1)        NULL,
    [prern_cnty_exempt_yn]    CHAR (1)        NULL,
    [prern_schdist_exempt_yn] CHAR (1)        NULL,
    [prern_wcc_exempt_yn]     CHAR (1)        NULL,
    [prern_glexp_acct]        DECIMAL (16, 8) NULL,
    [prern_std_vsp_award_yn]  CHAR (1)        NULL,
    [prern_prwcc_code]        CHAR (6)        NULL,
    [prern_premium_rate]      DECIMAL (8, 4)  NULL,
    [prern_prem_code_fa]      CHAR (1)        NULL,
    [prern_memo_type_tw]      CHAR (1)        NULL,
    [prern_pension_exempt_yn] CHAR (1)        NULL,
    [prern_user_id]           CHAR (16)       NULL,
    [prern_user_rev_dt]       INT             NULL,
    [A4GLIdentity]            NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_prernmst] PRIMARY KEY NONCLUSTERED ([prern_code] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iprernmst0]
    ON [dbo].[prernmst]([prern_code] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[prernmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[prernmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[prernmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[prernmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[prernmst] TO PUBLIC
    AS [dbo];

