﻿CREATE TABLE [dbo].[pxrptmst] (
    [pxrpt_trans_rev_dt]           INT             NOT NULL,
    [pxrpt_ord_no]                 CHAR (8)        NOT NULL,
    [pxrpt_trans_type]             CHAR (1)        NOT NULL,
    [pxrpt_seq_no]                 SMALLINT        NOT NULL,
    [pxrpt_src_sys]                CHAR (1)        NULL,
    [pxrpt_itm_no]                 CHAR (10)       NOT NULL,
    [pxrpt_itm_loc_no]             CHAR (3)        NOT NULL,
    [pxrpt_itm_desc]               CHAR (33)       NULL,
    [pxrpt_itm_dyed_yn]            CHAR (1)        NULL,
    [pxrpt_itm_tax_cls_id]         CHAR (2)        NULL,
    [pxrpt_cus_no]                 CHAR (10)       NOT NULL,
    [pxrpt_cus_name]               CHAR (50)       NULL,
    [pxrpt_cus_addr]               CHAR (30)       NULL,
    [pxrpt_cus_addr2]              CHAR (30)       NULL,
    [pxrpt_cus_city]               CHAR (20)       NULL,
    [pxrpt_cus_state]              CHAR (2)        NULL,
    [pxrpt_cus_zip]                CHAR (10)       NULL,
    [pxrpt_cus_tax_id1]            CHAR (15)       NULL,
    [pxrpt_cus_tax_id2]            CHAR (15)       NULL,
    [pxrpt_cus_tax_id3]            CHAR (15)       NULL,
    [pxrpt_cus_sls_tax_id]         CHAR (15)       NULL,
    [pxrpt_cus_auth_id1]           CHAR (3)        NULL,
    [pxrpt_cus_auth_id2]           CHAR (3)        NULL,
    [pxrpt_cus_acct_stat]          CHAR (1)        NULL,
    [pxrpt_cus_pst_yn]             CHAR (1)        NULL,
    [pxrpt_cus_phone]              CHAR (15)       NULL,
    [pxrpt_cus_contact]            CHAR (30)       NULL,
    [pxrpt_vnd_no]                 CHAR (10)       NOT NULL,
    [pxrpt_vnd_name]               CHAR (50)       NULL,
    [pxrpt_vnd_addr1]              CHAR (30)       NULL,
    [pxrpt_vnd_addr]               CHAR (30)       NULL,
    [pxrpt_vnd_city]               CHAR (20)       NULL,
    [pxrpt_vnd_state]              CHAR (2)        NULL,
    [pxrpt_vnd_zip]                CHAR (10)       NULL,
    [pxrpt_vnd_g_or_n_ind]         CHAR (1)        NULL,
    [pxrpt_vnd_sales_tax_id]       CHAR (20)       NULL,
    [pxrpt_vnd_auth_id1]           CHAR (3)        NULL,
    [pxrpt_vnd_auth_id2]           CHAR (3)        NULL,
    [vnd_fuel_dlr_1]               CHAR (20)       NULL,
    [pxrpt_vnd_fet_id]             CHAR (20)       NULL,
    [vnd_fuel_dlr_2]               CHAR (20)       NULL,
    [pxrpt_vnd_tax_state]          CHAR (2)        NULL,
    [pxrpt_vnd_origin]             CHAR (20)       NULL,
    [pxrpt_vnd_type]               CHAR (5)        NULL,
    [pxrpt_vnd_terminal_no]        CHAR (15)       NULL,
    [pxrpt_vnd_phone]              CHAR (15)       NULL,
    [pxrpt_car_no]                 CHAR (10)       NOT NULL,
    [pxrpt_car_name]               CHAR (30)       NULL,
    [pxrpt_car_addr]               CHAR (30)       NULL,
    [pxrpt_car_city]               CHAR (20)       NULL,
    [pxrpt_car_state]              CHAR (2)        NULL,
    [pxrpt_car_zip]                CHAR (10)       NULL,
    [pxrpt_car_fed_id]             CHAR (15)       NULL,
    [pxrpt_car_trans_mode]         CHAR (2)        NULL,
    [pxrpt_car_in_sf401_yn]        CHAR (1)        NULL,
    [pxrpt_car_trans_lic_no]       CHAR (15)       NULL,
    [pxrpt_car_ifta_no]            CHAR (15)       NULL,
    [pxrpt_car_mi_c3859_yn]        CHAR (1)        NULL,
    [pxrpt_car_il_rpt_yn]          CHAR (1)        NULL,
    [pxrpt_car_fl_trans_mode]      CHAR (2)        NULL,
    [pxrpt_car_oh_cc22_yn]         CHAR (1)        NULL,
    [pxrpt_pur_txc_irs_tax_cd]     CHAR (2)        NULL,
    [pxrpt_pur_txc_al_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_ak_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_ar_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_az_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_ca_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_co_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_ct_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_dc_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_de_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_fl_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_ga_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_hi_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_ia_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_id_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_il_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_in_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_ks_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_ky_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_la_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_ma_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_me_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_md_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_mi_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_mn_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_mo_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_ms_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_mt_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_nc_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_nd_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_ne_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_nh_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_nj_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_nm_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_ny_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_nv_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_oh_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_ok_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_or_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_pa_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_ri_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_sc_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_sd_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_tn_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_tx_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_ut_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_va_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_vt_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_wa_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_wi_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_wv_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_txc_wy_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_irs_tax_cd]     CHAR (2)        NULL,
    [pxrpt_sls_txc_al_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_ak_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_ar_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_az_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_ca_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_co_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_ct_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_dc_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_de_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_fl_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_ga_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_hi_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_ia_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_id_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_il_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_in_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_ks_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_ky_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_la_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_ma_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_me_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_md_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_mi_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_mn_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_mo_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_ms_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_mt_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_nc_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_nd_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_ne_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_nh_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_nj_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_nm_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_ny_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_nv_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_oh_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_ok_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_or_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_pa_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_ri_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_sc_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_sd_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_tn_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_tx_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_ut_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_va_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_vt_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_wa_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_wi_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_wv_prod_cd]     CHAR (3)        NULL,
    [pxrpt_sls_txc_wy_prod_cd]     CHAR (3)        NULL,
    [pxrpt_pur_carrier]            CHAR (10)       NULL,
    [pxrpt_pur_bal_bulk_yn]        CHAR (1)        NULL,
    [pxrpt_pur_gross_un]           DECIMAL (11, 4) NULL,
    [pxrpt_pur_net_un]             DECIMAL (11, 4) NULL,
    [pxrpt_pur_bal_un]             DECIMAL (11, 4) NULL,
    [pxrpt_pur_fet_amt]            DECIMAL (11, 2) NULL,
    [pxrpt_pur_set_amt]            DECIMAL (11, 2) NULL,
    [pxrpt_pur_if_amt]             DECIMAL (11, 2) NULL,
    [pxrpt_pur_sst_amt]            DECIMAL (11, 2) NULL,
    [pur_sst_on_net]               DECIMAL (11, 2) NULL,
    [pur_sst_on_fet]               DECIMAL (11, 2) NULL,
    [pur_sst_on_set]               DECIMAL (11, 2) NULL,
    [pur_sst_on_lc1]               DECIMAL (11, 2) NULL,
    [pur_sst_on_lc2]               DECIMAL (11, 2) NULL,
    [pur_sst_on_lc3]               DECIMAL (11, 2) NULL,
    [pur_sst_on_lc4]               DECIMAL (11, 2) NULL,
    [pur_sst_on_lc5]               DECIMAL (11, 2) NULL,
    [pur_sst_on_lc6]               DECIMAL (11, 2) NULL,
    [pur_sst_on_lc7]               DECIMAL (11, 2) NULL,
    [pur_sst_on_lc8]               DECIMAL (11, 2) NULL,
    [pur_sst_on_lc9]               DECIMAL (11, 2) NULL,
    [pur_sst_on_lc10]              DECIMAL (11, 2) NULL,
    [pur_sst_on_lc11]              DECIMAL (11, 2) NULL,
    [pur_sst_on_lc12]              DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc1_amt]            DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc1_on_net]         DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc1_on_fet]         DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc2_amt]            DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc2_on_net]         DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc2_on_fet]         DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc3_amt]            DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc3_on_net]         DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc3_on_fet]         DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc4_amt]            DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc4_on_net]         DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc4_on_fet]         DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc5_amt]            DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc5_on_net]         DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc5_on_fet]         DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc6_amt]            DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc6_on_net]         DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc6_on_fet]         DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc7_amt]            DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc7_on_net]         DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc7_on_fet]         DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc8_amt]            DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc8_on_net]         DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc8_on_fet]         DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc9_amt]            DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc9_on_net]         DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc9_on_fet]         DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc10_amt]           DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc10_on_net]        DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc10_on_fet]        DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc11_amt]           DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc11_on_net]        DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc11_on_fet]        DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc12_amt]           DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc12_on_net]        DECIMAL (11, 2) NULL,
    [pxrpt_pur_lc12_on_fet]        DECIMAL (11, 2) NULL,
    [pxrpt_pur_lading_no]          CHAR (15)       NULL,
    [pxrpt_pur_origin]             CHAR (20)       NULL,
    [pxrpt_pur_fob]                CHAR (10)       NULL,
    [pxrpt_pur_g_or_n_ind]         CHAR (1)        NULL,
    [pxrpt_pur_frt_only_un]        DECIMAL (11, 4) NULL,
    [pxrpt_pur_seller]             CHAR (10)       NULL,
    [pxrpt_pur_del_point]          CHAR (10)       NULL,
    [pxrpt_pur_vnd_no]             CHAR (10)       NULL,
    [pxrpt_pur_vnd_ivc_no]         CHAR (15)       NULL,
    [pxrpt_pur_un_received]        DECIMAL (11, 4) NULL,
    [pxrpt_pur_pst_yn]             CHAR (1)        NULL,
    [pxrpt_pur_itm_tax_cls_id]     CHAR (2)        NULL,
    [pxrpt_sls_ivc_no]             CHAR (8)        NULL,
    [pxrpt_sls_itm_no]             CHAR (10)       NULL,
    [pxrpt_sls_itm_loc_no]         CHAR (3)        NULL,
    [pxrpt_sls_itm_tax_cls_id]     CHAR (2)        NULL,
    [pxrpt_sls_bln_yn]             CHAR (1)        NULL,
    [pxrpt_sls_un]                 DECIMAL (11, 4) NULL,
    [pxrpt_sls_fet_amt]            DECIMAL (11, 2) NULL,
    [pxrpt_sls_set_amt]            DECIMAL (11, 2) NULL,
    [pxrpt_sls_sst_amt]            DECIMAL (11, 2) NULL,
    [sls_sst_on_net]               DECIMAL (11, 2) NULL,
    [sls_sst_on_fet]               DECIMAL (11, 2) NULL,
    [sls_sst_on_set]               DECIMAL (11, 2) NULL,
    [sls_sst_on_lc1]               DECIMAL (11, 2) NULL,
    [sls_sst_on_lc2]               DECIMAL (11, 2) NULL,
    [sls_sst_on_lc3]               DECIMAL (11, 2) NULL,
    [sls_sst_on_lc4]               DECIMAL (11, 2) NULL,
    [sls_sst_on_lc5]               DECIMAL (11, 2) NULL,
    [sls_sst_on_lc6]               DECIMAL (11, 2) NULL,
    [sls_sst_on_lc7]               DECIMAL (11, 2) NULL,
    [sls_sst_on_lc8]               DECIMAL (11, 2) NULL,
    [sls_sst_on_lc9]               DECIMAL (11, 2) NULL,
    [sls_sst_on_lc10]              DECIMAL (11, 2) NULL,
    [sls_sst_on_lc11]              DECIMAL (11, 2) NULL,
    [sls_sst_on_lc12]              DECIMAL (11, 2) NULL,
    [pxrpt_sls_lc1_amt]            DECIMAL (11, 2) NULL,
    [sls_lc1_on_net]               DECIMAL (11, 2) NULL,
    [sls_lc1_on_fet]               DECIMAL (11, 2) NULL,
    [pxrpt_sls_lc2_amt]            DECIMAL (11, 2) NULL,
    [sls_lc2_on_net]               DECIMAL (11, 2) NULL,
    [sls_lc2_on_fet]               DECIMAL (11, 2) NULL,
    [pxrpt_sls_lc3_amt]            DECIMAL (11, 2) NULL,
    [sls_lc3_on_net]               DECIMAL (11, 2) NULL,
    [sls_lc3_on_fet]               DECIMAL (11, 2) NULL,
    [pxrpt_sls_lc4_amt]            DECIMAL (11, 2) NULL,
    [sls_lc4_on_net]               DECIMAL (11, 2) NULL,
    [sls_lc4_on_fet]               DECIMAL (11, 2) NULL,
    [pxrpt_sls_lc5_amt]            DECIMAL (11, 2) NULL,
    [sls_lc5_on_net]               DECIMAL (11, 2) NULL,
    [sls_lc5_on_fet]               DECIMAL (11, 2) NULL,
    [pxrpt_sls_lc6_amt]            DECIMAL (11, 2) NULL,
    [sls_lc6_on_net]               DECIMAL (11, 2) NULL,
    [sls_lc6_on_fet]               DECIMAL (11, 2) NULL,
    [pxrpt_sls_lc7_amt]            DECIMAL (11, 2) NULL,
    [sls_lc7_on_net]               DECIMAL (11, 2) NULL,
    [sls_lc7_on_fet]               DECIMAL (11, 2) NULL,
    [pxrpt_sls_lc8_amt]            DECIMAL (11, 2) NULL,
    [sls_lc8_on_net]               DECIMAL (11, 2) NULL,
    [sls_lc8_on_fet]               DECIMAL (11, 2) NULL,
    [pxrpt_sls_lc9_amt]            DECIMAL (11, 2) NULL,
    [sls_lc9_on_net]               DECIMAL (11, 2) NULL,
    [sls_lc9_on_fet]               DECIMAL (11, 2) NULL,
    [pxrpt_sls_lc10_amt]           DECIMAL (11, 2) NULL,
    [sls_lc10_on_net]              DECIMAL (11, 2) NULL,
    [sls_lc10_on_fet]              DECIMAL (11, 2) NULL,
    [pxrpt_sls_lc11_amt]           DECIMAL (11, 2) NULL,
    [sls_lc11_on_net]              DECIMAL (11, 2) NULL,
    [sls_lc11_on_fet]              DECIMAL (11, 2) NULL,
    [pxrpt_sls_lc12_amt]           DECIMAL (11, 2) NULL,
    [sls_lc12_on_net]              DECIMAL (11, 2) NULL,
    [sls_lc12_on_fet]              DECIMAL (11, 2) NULL,
    [pxrpt_sls_own_loc_yn]         CHAR (1)        NULL,
    [pxrpt_sls_cus_acct_stat]      CHAR (1)        NULL,
    [pxrpt_sls_cus_po_no]          CHAR (15)       NULL,
    [pxrpt_sls_trans_gals]         DECIMAL (11, 4) NULL,
    [pxrpt_sls_frt_yno]            CHAR (1)        NULL,
    [pxrpt_sls_net_gals]           DECIMAL (11, 4) NULL,
    [pxrpt_sls_pst_amt]            DECIMAL (11, 2) NULL,
    [pxrpt_sls_consg_invt_yn]      CHAR (1)        NULL,
    [pxrpt_sls_sst_exempt_pct]     DECIMAL (7, 5)  NULL,
    [pxrpt_sls_set_exempt_pct]     DECIMAL (7, 5)  NULL,
    [pxrpt_sls_sst_exempt_qty]     DECIMAL (11, 3) NULL,
    [pxrpt_sls_set_exempt_qty]     DECIMAL (11, 3) NULL,
    [pxrpt_import_verification_no] CHAR (15)       NULL,
    [pxrpt_diver_no1]              CHAR (1)        NULL,
    [pxrpt_diver_no2_6]            CHAR (5)        NULL,
    [pxrpt_diversion_orig_st]      CHAR (2)        NULL,
    [pxrpt_user_id]                CHAR (16)       NULL,
    [pxrpt_user_rev_dt]            INT             NULL,
    [A4GLIdentity]                 NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_pxrptmst] PRIMARY KEY NONCLUSTERED ([pxrpt_trans_rev_dt] ASC, [pxrpt_ord_no] ASC, [pxrpt_trans_type] ASC, [pxrpt_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ipxrptmst0]
    ON [dbo].[pxrptmst]([pxrpt_trans_rev_dt] ASC, [pxrpt_ord_no] ASC, [pxrpt_trans_type] ASC, [pxrpt_seq_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Ipxrptmst1]
    ON [dbo].[pxrptmst]([pxrpt_itm_no] ASC, [pxrpt_itm_loc_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Ipxrptmst2]
    ON [dbo].[pxrptmst]([pxrpt_cus_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Ipxrptmst3]
    ON [dbo].[pxrptmst]([pxrpt_vnd_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Ipxrptmst4]
    ON [dbo].[pxrptmst]([pxrpt_car_no] ASC);

