CREATE TABLE [dbo].[sstxcmst] (
    [sstxc_tax_cls_id]  CHAR (2)    NOT NULL,
    [sstxc_desc]        CHAR (15)   NULL,
    [sstxc_irs_tax_cd]  CHAR (2)    NULL,
    [sstxc_al_prod_cd]  CHAR (3)    NULL,
    [sstxc_ak_prod_cd]  CHAR (3)    NULL,
    [sstxc_ar_prod_cd]  CHAR (3)    NULL,
    [sstxc_az_prod_cd]  CHAR (3)    NULL,
    [sstxc_ca_prod_cd]  CHAR (3)    NULL,
    [sstxc_co_prod_cd]  CHAR (3)    NULL,
    [sstxc_ct_prod_cd]  CHAR (3)    NULL,
    [sstxc_dc_prod_cd]  CHAR (3)    NULL,
    [sstxc_de_prod_cd]  CHAR (3)    NULL,
    [sstxc_fl_prod_cd]  CHAR (3)    NULL,
    [sstxc_ga_prod_cd]  CHAR (3)    NULL,
    [sstxc_hi_prod_cd]  CHAR (3)    NULL,
    [sstxc_ia_prod_cd]  CHAR (3)    NULL,
    [sstxc_id_prod_cd]  CHAR (3)    NULL,
    [sstxc_il_prod_cd]  CHAR (3)    NULL,
    [sstxc_in_prod_cd]  CHAR (3)    NULL,
    [sstxc_ks_prod_cd]  CHAR (3)    NULL,
    [sstxc_ky_prod_cd]  CHAR (3)    NULL,
    [sstxc_la_prod_cd]  CHAR (3)    NULL,
    [sstxc_ma_prod_cd]  CHAR (3)    NULL,
    [sstxc_me_prod_cd]  CHAR (3)    NULL,
    [sstxc_md_prod_cd]  CHAR (3)    NULL,
    [sstxc_mi_prod_cd]  CHAR (3)    NULL,
    [sstxc_mn_prod_cd]  CHAR (3)    NULL,
    [sstxc_mo_prod_cd]  CHAR (3)    NULL,
    [sstxc_ms_prod_cd]  CHAR (3)    NULL,
    [sstxc_mt_prod_cd]  CHAR (3)    NULL,
    [sstxc_nc_prod_cd]  CHAR (3)    NULL,
    [sstxc_nd_prod_cd]  CHAR (3)    NULL,
    [sstxc_ne_prod_cd]  CHAR (3)    NULL,
    [sstxc_nh_prod_cd]  CHAR (3)    NULL,
    [sstxc_nj_prod_cd]  CHAR (3)    NULL,
    [sstxc_nm_prod_cd]  CHAR (3)    NULL,
    [sstxc_ny_prod_cd]  CHAR (3)    NULL,
    [sstxc_nv_prod_cd]  CHAR (3)    NULL,
    [sstxc_oh_prod_cd]  CHAR (3)    NULL,
    [sstxc_ok_prod_cd]  CHAR (3)    NULL,
    [sstxc_or_prod_cd]  CHAR (3)    NULL,
    [sstxc_pa_prod_cd]  CHAR (3)    NULL,
    [sstxc_ri_prod_cd]  CHAR (3)    NULL,
    [sstxc_sc_prod_cd]  CHAR (3)    NULL,
    [sstxc_sd_prod_cd]  CHAR (3)    NULL,
    [sstxc_tn_prod_cd]  CHAR (3)    NULL,
    [sstxc_tx_prod_cd]  CHAR (3)    NULL,
    [sstxc_ut_prod_cd]  CHAR (3)    NULL,
    [sstxc_va_prod_cd]  CHAR (3)    NULL,
    [sstxc_vt_prod_cd]  CHAR (3)    NULL,
    [sstxc_wa_prod_cd]  CHAR (3)    NULL,
    [sstxc_wi_prod_cd]  CHAR (3)    NULL,
    [sstxc_wv_prod_cd]  CHAR (3)    NULL,
    [sstxc_wy_prod_cd]  CHAR (3)    NULL,
    [sstxc_us_prod_cd]  CHAR (3)    NULL,
    [sstxc_user_id]     CHAR (16)   NULL,
    [sstxc_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_sstxcmst] PRIMARY KEY NONCLUSTERED ([sstxc_tax_cls_id] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Isstxcmst0]
    ON [dbo].[sstxcmst]([sstxc_tax_cls_id] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[sstxcmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[sstxcmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[sstxcmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[sstxcmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[sstxcmst] TO PUBLIC
    AS [dbo];

