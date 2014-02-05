CREATE TABLE [dbo].[prdedmst] (
    [prded_code]             CHAR (3)        NOT NULL,
    [prded_type]             CHAR (1)        NOT NULL,
    [prded_desc]             CHAR (25)       NULL,
    [prded_literal]          CHAR (10)       NULL,
    [prded_acct_req_yn]      CHAR (1)        NULL,
    [prded_keep_arrears_yn]  CHAR (1)        NULL,
    [prded_glbs_acct]        DECIMAL (16, 8) NULL,
    [prded_glexp_acct]       DECIMAL (16, 8) NULL,
    [prded_annual_max]       INT             NULL,
    [prded_ss_exempt]        CHAR (1)        NULL,
    [prded_med_exempt]       CHAR (1)        NULL,
    [prded_fed_exempt]       CHAR (1)        NULL,
    [prded_st_exempt]        CHAR (1)        NULL,
    [prded_fui_exempt]       CHAR (1)        NULL,
    [prded_sui_exempt]       CHAR (1)        NULL,
    [prded_city_exempt]      CHAR (1)        NULL,
    [prded_cnty_exempt]      CHAR (1)        NULL,
    [prded_schdist_exempt]   CHAR (1)        NULL,
    [prded_wcc_exempt]       CHAR (1)        NULL,
    [prded_co_emp_cd]        CHAR (1)        NULL,
    [prded_aptrx_yn]         CHAR (1)        NULL,
    [prded_vendor]           CHAR (10)       NULL,
    [prded_pct_basis_ga]     CHAR (1)        NULL,
    [prded_ytd_earn_limit]   INT             NULL,
    [prded_cycle_earn_limit] INT             NULL,
    [prded_user_id]          CHAR (16)       NULL,
    [prded_user_rev_dt]      INT             NULL,
    [A4GLIdentity]           NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_prdedmst] PRIMARY KEY NONCLUSTERED ([prded_code] ASC, [prded_type] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iprdedmst0]
    ON [dbo].[prdedmst]([prded_code] ASC, [prded_type] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[prdedmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[prdedmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[prdedmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[prdedmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[prdedmst] TO PUBLIC
    AS [dbo];

