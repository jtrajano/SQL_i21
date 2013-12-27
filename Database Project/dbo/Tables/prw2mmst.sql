CREATE TABLE [dbo].[prw2mmst] (
    [prw2m_empid]                  CHAR (10)       NOT NULL,
    [prw2m_year]                   SMALLINT        NOT NULL,
    [prw2m_stid]                   CHAR (2)        NOT NULL,
    [prw2m_alloc_tips]             DECIMAL (12, 2) NULL,
    [prw2m_non_457_plan]           DECIMAL (12, 2) NULL,
    [prw2m_457_plan]               DECIMAL (12, 2) NULL,
    [prw2m_uncoll_sstax_tips]      DECIMAL (12, 2) NULL,
    [prw2m_uncoll_medtax_tips]     DECIMAL (12, 2) NULL,
    [prw2m_tax_on_excess_golds]    DECIMAL (12, 2) NULL,
    [prw2m_grp_term_ins_over_50k]  DECIMAL (12, 2) NULL,
    [prw2m_uncoll_sstax_term_ins]  DECIMAL (12, 2) NULL,
    [prw2m_uncoll_medtax_term_ins] DECIMAL (12, 2) NULL,
    [prw2m_box14_text_1]           CHAR (14)       NULL,
    [prw2m_box14_amt_1]            DECIMAL (12, 2) NULL,
    [prw2m_box14_text_2]           CHAR (14)       NULL,
    [prw2m_box14_amt_2]            DECIMAL (12, 2) NULL,
    [prw2m_409a_deferrals]         DECIMAL (12, 2) NULL,
    [prw2m_409a_income]            DECIMAL (12, 2) NULL,
    [prw2m_taxed_sickpay]          DECIMAL (9, 2)  NULL,
    [prw2m_untaxed_sickpay]        DECIMAL (9, 2)  NULL,
    [prw2m_sickpay_fica_wh]        DECIMAL (7, 2)  NULL,
    [prw2m_sickpay_med_wh]         DECIMAL (7, 2)  NULL,
    [prw2m_sickpay_fed_wh]         DECIMAL (7, 2)  NULL,
    [prw2m_stat_emp_yn]            CHAR (1)        NULL,
    [prw2m_user_id]                CHAR (16)       NULL,
    [prw2m_user_rev_dt]            INT             NULL,
    [A4GLIdentity]                 NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_prw2mmst] PRIMARY KEY NONCLUSTERED ([prw2m_empid] ASC, [prw2m_year] ASC, [prw2m_stid] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iprw2mmst0]
    ON [dbo].[prw2mmst]([prw2m_empid] ASC, [prw2m_year] ASC, [prw2m_stid] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[prw2mmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[prw2mmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[prw2mmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[prw2mmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[prw2mmst] TO PUBLIC
    AS [dbo];

