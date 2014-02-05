CREATE TABLE [dbo].[prhsmmst] (
    [prhsm_code]            CHAR (1)       NOT NULL,
    [prhsm_no]              CHAR (8)       NOT NULL,
    [prhsm_chk_type]        CHAR (1)       NOT NULL,
    [prhsm_emp]             CHAR (10)      NOT NULL,
    [prhsm_chk_date]        INT            NOT NULL,
    [prhsm_qtrno]           TINYINT        NULL,
    [prhsm_period_date]     INT            NULL,
    [prhsm_dir_dep_bank]    CHAR (4)       NULL,
    [prhsm_dir_dep_acct]    CHAR (17)      NULL,
    [prhsm_gross]           DECIMAL (9, 2) NULL,
    [prhsm_deductions]      DECIMAL (9, 2) NULL,
    [prhsm_taxes]           DECIMAL (9, 2) NULL,
    [prhsm_net_pay]         DECIMAL (9, 2) NULL,
    [prhsm_fed_taxable]     DECIMAL (9, 2) NULL,
    [prhsm_ss_taxable]      DECIMAL (9, 2) NULL,
    [prhsm_med_taxable]     DECIMAL (9, 2) NULL,
    [prhsm_fui_taxable]     DECIMAL (9, 2) NULL,
    [prhsm_sui_taxable]     DECIMAL (9, 2) NULL,
    [prhsm_state_taxable]   DECIMAL (9, 2) NULL,
    [prhsm_city_taxable]    DECIMAL (9, 2) NULL,
    [prhsm_cnty_taxable]    DECIMAL (9, 2) NULL,
    [prhsm_schdist_taxable] DECIMAL (9, 2) NULL,
    [prhsm_dept]            CHAR (4)       NULL,
    [prhsm_prenote_yn]      CHAR (1)       NULL,
    [prhsm_user_id]         CHAR (16)      NULL,
    [prhsm_user_rev_dt]     INT            NULL,
    [A4GLIdentity]          NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_prhsmmst] PRIMARY KEY NONCLUSTERED ([prhsm_code] ASC, [prhsm_no] ASC, [prhsm_chk_type] ASC, [prhsm_emp] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iprhsmmst0]
    ON [dbo].[prhsmmst]([prhsm_code] ASC, [prhsm_no] ASC, [prhsm_chk_type] ASC, [prhsm_emp] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iprhsmmst1]
    ON [dbo].[prhsmmst]([prhsm_emp] ASC, [prhsm_chk_date] ASC, [prhsm_code] ASC, [prhsm_no] ASC, [prhsm_chk_type] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iprhsmmst2]
    ON [dbo].[prhsmmst]([prhsm_chk_date] ASC, [prhsm_code] ASC, [prhsm_no] ASC, [prhsm_chk_type] ASC, [prhsm_emp] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[prhsmmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[prhsmmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[prhsmmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[prhsmmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[prhsmmst] TO PUBLIC
    AS [dbo];

