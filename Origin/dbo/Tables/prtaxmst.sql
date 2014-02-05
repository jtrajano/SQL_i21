﻿CREATE TABLE [dbo].[prtaxmst] (
    [prtax_year]             SMALLINT        NOT NULL,
    [prtax_tax_type]         TINYINT         NOT NULL,
    [prtax_code]             CHAR (6)        NOT NULL,
    [prtax_desc]             CHAR (25)       NULL,
    [prtax_literal]          CHAR (10)       NULL,
    [prtax_exmpt_allow]      DECIMAL (7, 2)  NULL,
    [prtax_ded_allow]        DECIMAL (7, 2)  NULL,
    [prtax_exmpt_reduce]     CHAR (1)        NULL,
    [prtax_tax_sick]         CHAR (1)        NULL,
    [prtax_paid_by]          CHAR (1)        NULL,
    [prtax_comp_method_pt]   CHAR (1)        NULL,
    [prtax_credit_yn]        CHAR (1)        NULL,
    [prtax_gl_bs]            DECIMAL (16, 8) NULL,
    [prtax_gl_exp]           DECIMAL (16, 8) NULL,
    [prtax_percent]          DECIMAL (7, 4)  NULL,
    [prtax_wage_cutoff]      DECIMAL (9, 2)  NULL,
    [prtax_whld_cutoff]      DECIMAL (9, 2)  NULL,
    [prtax_wage_basis]       TINYINT         NULL,
    [prtax_supp_pct]         DECIMAL (7, 4)  NULL,
    [prtax_tbl_max_1]        INT             NULL,
    [prtax_tbl_max_2]        INT             NULL,
    [prtax_tbl_max_3]        INT             NULL,
    [prtax_tbl_max_4]        INT             NULL,
    [prtax_tbl_max_5]        INT             NULL,
    [prtax_tbl_max_6]        INT             NULL,
    [prtax_tbl_max_7]        INT             NULL,
    [prtax_tbl_max_8]        INT             NULL,
    [prtax_tbl_max_9]        INT             NULL,
    [prtax_tbl_max_10]       INT             NULL,
    [prtax_tbl_max_11]       INT             NULL,
    [prtax_tbl_max_12]       INT             NULL,
    [prtax_tbl_max_13]       INT             NULL,
    [prtax_tbl_max_14]       INT             NULL,
    [prtax_tbl_max_15]       INT             NULL,
    [prtax_tbl_max_16]       INT             NULL,
    [prtax_tbl_whld_1]       DECIMAL (9, 2)  NULL,
    [prtax_tbl_whld_2]       DECIMAL (9, 2)  NULL,
    [prtax_tbl_whld_3]       DECIMAL (9, 2)  NULL,
    [prtax_tbl_whld_4]       DECIMAL (9, 2)  NULL,
    [prtax_tbl_whld_5]       DECIMAL (9, 2)  NULL,
    [prtax_tbl_whld_6]       DECIMAL (9, 2)  NULL,
    [prtax_tbl_whld_7]       DECIMAL (9, 2)  NULL,
    [prtax_tbl_whld_8]       DECIMAL (9, 2)  NULL,
    [prtax_tbl_whld_9]       DECIMAL (9, 2)  NULL,
    [prtax_tbl_whld_10]      DECIMAL (9, 2)  NULL,
    [prtax_tbl_whld_11]      DECIMAL (9, 2)  NULL,
    [prtax_tbl_whld_12]      DECIMAL (9, 2)  NULL,
    [prtax_tbl_whld_13]      DECIMAL (9, 2)  NULL,
    [prtax_tbl_whld_14]      DECIMAL (9, 2)  NULL,
    [prtax_tbl_whld_15]      DECIMAL (9, 2)  NULL,
    [prtax_tbl_whld_16]      DECIMAL (9, 2)  NULL,
    [prtax_tbl_pct_1]        DECIMAL (7, 4)  NULL,
    [prtax_tbl_pct_2]        DECIMAL (7, 4)  NULL,
    [prtax_tbl_pct_3]        DECIMAL (7, 4)  NULL,
    [prtax_tbl_pct_4]        DECIMAL (7, 4)  NULL,
    [prtax_tbl_pct_5]        DECIMAL (7, 4)  NULL,
    [prtax_tbl_pct_6]        DECIMAL (7, 4)  NULL,
    [prtax_tbl_pct_7]        DECIMAL (7, 4)  NULL,
    [prtax_tbl_pct_8]        DECIMAL (7, 4)  NULL,
    [prtax_tbl_pct_9]        DECIMAL (7, 4)  NULL,
    [prtax_tbl_pct_10]       DECIMAL (7, 4)  NULL,
    [prtax_tbl_pct_11]       DECIMAL (7, 4)  NULL,
    [prtax_tbl_pct_12]       DECIMAL (7, 4)  NULL,
    [prtax_tbl_pct_13]       DECIMAL (7, 4)  NULL,
    [prtax_tbl_pct_14]       DECIMAL (7, 4)  NULL,
    [prtax_tbl_pct_15]       DECIMAL (7, 4)  NULL,
    [prtax_tbl_pct_16]       DECIMAL (7, 4)  NULL,
    [prtax_mag_media_id]     INT             NULL,
    [prtax_aptrx_yn]         CHAR (1)        NULL,
    [prtax_vendor]           CHAR (10)       NULL,
    [prtax_std_pct_of_wages] DECIMAL (5, 2)  NULL,
    [prtax_std_ded_min]      DECIMAL (9, 2)  NULL,
    [prtax_std_ded_max]      DECIMAL (9, 2)  NULL,
    [prtax_fwt_deduct_9]     TINYINT         NULL,
    [prtax_fwt_allow_max]    DECIMAL (9, 2)  NULL,
    [prtax_min_taxable_wage] DECIMAL (9, 2)  NULL,
    [prtax_pct_of_fwt]       TINYINT         NULL,
    [prtax_state_pct]        DECIMAL (5, 2)  NULL,
    [prtax_rnd_state_wh_yn]  CHAR (1)        NULL,
    [prtax_user_id]          CHAR (16)       NULL,
    [prtax_user_rev_dt]      INT             NULL,
    [A4GLIdentity]           NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    [prtax_med_supp_min]     DECIMAL (9, 2)  NULL,
    CONSTRAINT [k_prtaxmst] PRIMARY KEY NONCLUSTERED ([prtax_year] ASC, [prtax_tax_type] ASC, [prtax_code] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iprtaxmst0]
    ON [dbo].[prtaxmst]([prtax_year] ASC, [prtax_tax_type] ASC, [prtax_code] ASC);


GO
CREATE NONCLUSTERED INDEX [Iprtaxmst1]
    ON [dbo].[prtaxmst]([prtax_tax_type] ASC, [prtax_code] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[prtaxmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[prtaxmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[prtaxmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[prtaxmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[prtaxmst] TO PUBLIC
    AS [dbo];

