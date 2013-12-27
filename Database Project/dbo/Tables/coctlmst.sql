﻿CREATE TABLE [dbo].[coctlmst] (
    [coctl_co]                  CHAR (2)    NOT NULL,
    [coctl_co_name]             CHAR (50)   NULL,
    [coctl_co_addr]             CHAR (30)   NULL,
    [coctl_co_addr2]            CHAR (30)   NULL,
    [coctl_co_city]             CHAR (20)   NULL,
    [coctl_co_state]            CHAR (2)    NULL,
    [coctl_co_zip]              CHAR (10)   NULL,
    [coctl_co_county]           CHAR (6)    NULL,
    [coctl_co_phone]            CHAR (12)   NULL,
    [coctl_co_fax]              CHAR (12)   NULL,
    [coctl_web_site]            CHAR (50)   NULL,
    [coctl_email_address]       CHAR (50)   NULL,
    [coctl_gl_dist_type]        CHAR (2)    NULL,
    [coctl_multi_currency_yn]   CHAR (1)    NULL,
    [coctl_base_currency]       CHAR (3)    NULL,
    [coctl_security_yn]         CHAR (1)    NULL,
    [coctl_password]            CHAR (16)   NULL,
    [coctl_fed_id]              CHAR (10)   NULL,
    [coctl_disp_freq]           INT         NULL,
    [coctl_sic_code]            CHAR (4)    NULL,
    [coctl_naics_code]          CHAR (6)    NULL,
    [coctl_duns_no]             CHAR (9)    NULL,
    [coctl_state_id]            CHAR (15)   NULL,
    [coctl_sui_id]              CHAR (15)   NULL,
    [coctl_gl]                  CHAR (1)    NULL,
    [coctl_ag]                  CHAR (1)    NULL,
    [coctl_ga]                  CHAR (1)    NULL,
    [coctl_ap]                  CHAR (1)    NULL,
    [coctl_pr]                  CHAR (1)    NULL,
    [coctl_fx]                  CHAR (1)    NULL,
    [coctl_ho]                  CHAR (1)    NULL,
    [coctl_sl]                  CHAR (1)    NULL,
    [coctl_pt]                  CHAR (1)    NULL,
    [coctl_te]                  CHAR (1)    NULL,
    [coctl_st]                  CHAR (1)    NULL,
    [coctl_cl]                  CHAR (1)    NULL,
    [coctl_eforms]              CHAR (1)    NULL,
    [coctl_esig]                CHAR (1)    NULL,
    [coctl_ec]                  CHAR (1)    NULL,
    [coctl_edist]               CHAR (1)    NULL,
    [coctl_ef]                  CHAR (1)    NULL,
    [coctl_gl_setup_mode_yn]    CHAR (1)    NULL,
    [coctl_gl_units_yn]         CHAR (1)    NULL,
    [coctl_consolidating_co_yn] CHAR (1)    NULL,
    [coctl_pr_setup_mode_yn]    CHAR (1)    NULL,
    [coctl_pr_ms_yn]            CHAR (1)    NULL,
    [coctl_ad_yn]               CHAR (1)    NULL,
    [coctl_ae_yn]               CHAR (1)    NULL,
    [coctl_aw_yn]               CHAR (1)    NULL,
    [coctl_bf_yn]               CHAR (1)    NULL,
    [coctl_cb_yn]               CHAR (1)    NULL,
    [coctl_cf_yn]               CHAR (1)    NULL,
    [coctl_cn_yn]               CHAR (1)    NULL,
    [coctl_cr_yn]               CHAR (1)    NULL,
    [coctl_db_yn]               CHAR (1)    NULL,
    [coctl_fm_yn]               CHAR (1)    NULL,
    [coctl_ft_yn]               CHAR (1)    NULL,
    [coctl_jd_yn]               CHAR (1)    NULL,
    [coctl_kk_yn]               CHAR (1)    NULL,
    [coctl_kl_yn]               CHAR (1)    NULL,
    [coctl_le_yn]               CHAR (1)    NULL,
    [coctl_ld_yn]               CHAR (1)    NULL,
    [coctl_mx_yn]               CHAR (1)    NULL,
    [coctl_pa_yn]               CHAR (1)    NULL,
    [coctl_pc_yn]               CHAR (1)    NULL,
    [coctl_pd_yn]               CHAR (1)    NULL,
    [coctl_pe_yn]               CHAR (1)    NULL,
    [coctl_ps_yn]               CHAR (1)    NULL,
    [coctl_px_yn]               CHAR (1)    NULL,
    [coctl_rn_yn]               CHAR (1)    NULL,
    [coctl_sc_yn]               CHAR (1)    NULL,
    [coctl_sp_yn]               CHAR (1)    NULL,
    [coctl_tp_yn]               CHAR (1)    NULL,
    [coctl_tr_yn]               CHAR (1)    NULL,
    [coctl_wn_yn]               CHAR (1)    NULL,
    [coctl_pbk_yn]              CHAR (1)    NULL,
    [coctl_pbh_yn]              CHAR (1)    NULL,
    [coctl_tnk_yn]              CHAR (1)    NULL,
    [coctl_te_host_yn]          CHAR (1)    NULL,
    [coctl_dflt_stno]           CHAR (3)    NULL,
    [coctl_vr_yn]               CHAR (1)    NULL,
    [coctl_bb_yn]               CHAR (1)    NULL,
    [coctl_sf_yn]               CHAR (1)    NULL,
    [coctl_ep_yn]               CHAR (1)    NULL,
    [coctl_gp_yn]               CHAR (1)    NULL,
    [coctl_ag_st_yn]            CHAR (1)    NULL,
    [coctl_tm_yn]               CHAR (1)    NULL,
    [coctl_sort_path]           CHAR (50)   NULL,
    [coctl_gl_dist_path]        CHAR (50)   NULL,
    [coctl_forms_path]          CHAR (50)   NULL,
    [coctl_user_id]             CHAR (16)   NULL,
    [coctl_user_rev_dt]         INT         NULL,
    [A4GLIdentity]              NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    [coctl_comp_type]           CHAR (1)    NULL,
    [coctl_gi_yn]               CHAR (1)    NULL,
    CONSTRAINT [k_coctlmst] PRIMARY KEY NONCLUSTERED ([coctl_co] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Icoctlmst0]
    ON [dbo].[coctlmst]([coctl_co] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[coctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[coctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[coctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[coctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[coctlmst] TO PUBLIC
    AS [dbo];

