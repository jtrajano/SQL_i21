CREATE TABLE [dbo].[agitmmst] (
    [agitm_no]                   CHAR (13)       NOT NULL,
    [agitm_loc_no]               CHAR (3)        NOT NULL,
    [agitm_class]                CHAR (3)        NOT NULL,
    [agitm_search]               CHAR (13)       NOT NULL,
    [agitm_bar_code_ind]         CHAR (1)        NULL,
    [agitm_upc_code]             CHAR (20)       NOT NULL,
    [agitm_desc]                 CHAR (33)       NOT NULL,
    [agitm_binloc]               CHAR (5)        NULL,
    [agitm_vnd_no]               CHAR (10)       NULL,
    [agitm_fml_lvl]              TINYINT         NULL,
    [agitm_un_desc]              CHAR (3)        NULL,
    [agitm_lbs_per_un]           DECIMAL (9, 4)  NULL,
    [agitm_un_per_pak]           DECIMAL (11, 6) NULL,
    [agitm_pak_desc]             CHAR (6)        NULL,
    [agitm_phys_inv_ynbo]        CHAR (1)        NULL,
    [agitm_sls_acct]             DECIMAL (16, 8) NULL,
    [agitm_pur_acct]             DECIMAL (16, 8) NULL,
    [agitm_var_acct]             DECIMAL (16, 8) NULL,
    [agitm_std_un_cost]          DECIMAL (11, 5) NULL,
    [agitm_avg_un_cost]          DECIMAL (11, 5) NULL,
    [agitm_eom_un_cost]          DECIMAL (11, 5) NULL,
    [agitm_last_un_cost]         DECIMAL (11, 5) NULL,
    [agitm_last_cost_chg_rev_dt] INT             NULL,
    [agitm_un_prc1]              DECIMAL (11, 5) NULL,
    [agitm_un_prc2]              DECIMAL (11, 5) NULL,
    [agitm_un_prc3]              DECIMAL (11, 5) NULL,
    [agitm_un_prc4]              DECIMAL (11, 5) NULL,
    [agitm_un_prc5]              DECIMAL (11, 5) NULL,
    [agitm_un_prc6]              DECIMAL (11, 5) NULL,
    [agitm_un_prc7]              DECIMAL (11, 5) NULL,
    [agitm_un_prc8]              DECIMAL (11, 5) NULL,
    [agitm_un_prc9]              DECIMAL (11, 5) NULL,
    [agitm_prc_no_dec]           TINYINT         NULL,
    [agitm_prc_calc_ind]         CHAR (1)        NULL,
    [agitm_prc_lst_ind]          CHAR (1)        NULL,
    [agitm_prc_calc1]            DECIMAL (11, 5) NULL,
    [agitm_prc_calc2]            DECIMAL (11, 5) NULL,
    [agitm_prc_calc3]            DECIMAL (11, 5) NULL,
    [agitm_prc_calc4]            DECIMAL (11, 5) NULL,
    [agitm_prc_calc5]            DECIMAL (11, 5) NULL,
    [agitm_prc_calc6]            DECIMAL (11, 5) NULL,
    [agitm_prc_calc7]            DECIMAL (11, 5) NULL,
    [agitm_prc_calc8]            DECIMAL (11, 5) NULL,
    [agitm_prc_calc9]            DECIMAL (11, 5) NULL,
    [agitm_min_un_prc]           DECIMAL (11, 5) NULL,
    [agitm_max_un_prc]           DECIMAL (11, 5) NULL,
    [agitm_disc_cupn_ind]        CHAR (1)        NULL,
    [agitm_disc]                 DECIMAL (5, 2)  NULL,
    [agitm_un_on_hand]           DECIMAL (13, 4) NULL,
    [agitm_un_mfg_in_prs]        DECIMAL (13, 4) NULL,
    [agitm_un_ord_committed]     DECIMAL (13, 4) NULL,
    [agitm_un_cnt_committed]     DECIMAL (13, 4) NULL,
    [agitm_un_fert_committed]    DECIMAL (13, 4) NULL,
    [agitm_un_on_order]          DECIMAL (13, 4) NULL,
    [agitm_un_min_bal]           DECIMAL (13, 4) NULL,
    [agitm_un_max_bal]           DECIMAL (13, 4) NULL,
    [agitm_un_sold_ty_1]         DECIMAL (13, 4) NULL,
    [agitm_un_sold_ty_2]         DECIMAL (13, 4) NULL,
    [agitm_un_sold_ty_3]         DECIMAL (13, 4) NULL,
    [agitm_un_sold_ty_4]         DECIMAL (13, 4) NULL,
    [agitm_un_sold_ty_5]         DECIMAL (13, 4) NULL,
    [agitm_un_sold_ty_6]         DECIMAL (13, 4) NULL,
    [agitm_un_sold_ty_7]         DECIMAL (13, 4) NULL,
    [agitm_un_sold_ty_8]         DECIMAL (13, 4) NULL,
    [agitm_un_sold_ty_9]         DECIMAL (13, 4) NULL,
    [agitm_un_sold_ty_10]        DECIMAL (13, 4) NULL,
    [agitm_un_sold_ty_11]        DECIMAL (13, 4) NULL,
    [agitm_un_sold_ty_12]        DECIMAL (13, 4) NULL,
    [agitm_un_sold_ly_1]         DECIMAL (13, 4) NULL,
    [agitm_un_sold_ly_2]         DECIMAL (13, 4) NULL,
    [agitm_un_sold_ly_3]         DECIMAL (13, 4) NULL,
    [agitm_un_sold_ly_4]         DECIMAL (13, 4) NULL,
    [agitm_un_sold_ly_5]         DECIMAL (13, 4) NULL,
    [agitm_un_sold_ly_6]         DECIMAL (13, 4) NULL,
    [agitm_un_sold_ly_7]         DECIMAL (13, 4) NULL,
    [agitm_un_sold_ly_8]         DECIMAL (13, 4) NULL,
    [agitm_un_sold_ly_9]         DECIMAL (13, 4) NULL,
    [agitm_un_sold_ly_10]        DECIMAL (13, 4) NULL,
    [agitm_un_sold_ly_11]        DECIMAL (13, 4) NULL,
    [agitm_un_sold_ly_12]        DECIMAL (13, 4) NULL,
    [agitm_ytd_ivc_un]           DECIMAL (13, 4) NULL,
    [agitm_ytd_ivc_cost]         DECIMAL (13, 2) NULL,
    [agitm_un_pend_ivcs]         DECIMAL (13, 4) NULL,
    [agitm_last_purch_rev_dt]    INT             NULL,
    [agitm_last_sale_rev_dt]     INT             NULL,
    [agitm_intax_rpt_yn]         CHAR (1)        NULL,
    [agitm_outtax_rpt_yn]        CHAR (1)        NULL,
    [agitm_slstax_rpt_ynha]      CHAR (1)        NULL,
    [agitm_tontax_rpt_yn]        CHAR (1)        NULL,
    [agitm_rest_chem_rpt_yn]     CHAR (1)        NULL,
    [agitm_insp_fee_ynf]         CHAR (1)        NULL,
    [agitm_dyed_fuel_yn]         CHAR (1)        NULL,
    [agitm_tax_cls]              CHAR (2)        NULL,
    [agitm_pat_cat_code]         CHAR (1)        NULL,
    [agitm_last_phys_rev_dt]     INT             NULL,
    [agitm_last_price_rev_dt]    INT             NULL,
    [agitm_comments]             CHAR (10)       NULL,
    [agitm_msds_yn]              CHAR (1)        NULL,
    [agitm_epa_no]               CHAR (15)       NULL,
    [agitm_stk_yn]               CHAR (1)        NULL,
    [agitm_lot_yns]              CHAR (1)        NULL,
    [agitm_load_yn]              CHAR (1)        NULL,
    [agitm_hand_add_yn]          CHAR (1)        NULL,
    [agitm_mix_order]            SMALLINT        NULL,
    [agitm_comm_rt]              DECIMAL (7, 4)  NULL,
    [agitm_comm_ind_uag]         CHAR (1)        NULL,
    [agitm_rebate_grp]           CHAR (2)        NULL,
    [agitm_tank_req_yn]          CHAR (1)        NULL,
    [agitm_invc_tag]             CHAR (8)        NULL,
    [agitm_med_tag]              CHAR (8)        NULL,
    [agitm_ga_com_cd]            CHAR (3)        NULL,
    [agitm_ga_shrk_factor]       DECIMAL (7, 4)  NULL,
    [agitm_rin_req_nri]          CHAR (1)        NULL,
    [agitm_rin_char_cd]          CHAR (3)        NULL,
    [agitm_rin_feed_stock]       SMALLINT        NULL,
    [agitm_rin_pct_denaturant]   TINYINT         NULL,
    [agitm_avail_tm]             CHAR (1)        NULL,
    [agitm_deflt_percnt]         SMALLINT        NULL,
    [agitm_mfg_id]               CHAR (10)       NULL,
    [agitm_user_id]              CHAR (16)       NULL,
    [agitm_user_rev_dt]          INT             NULL,
    [A4GLIdentity]               NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agitmmst] PRIMARY KEY NONCLUSTERED ([agitm_class] ASC, [agitm_no] ASC, [agitm_loc_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagitmmst0]
    ON [dbo].[agitmmst]([agitm_no] ASC, [agitm_loc_no] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iagitmmst1]
    ON [dbo].[agitmmst]([agitm_class] ASC, [agitm_no] ASC, [agitm_loc_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagitmmst2]
    ON [dbo].[agitmmst]([agitm_loc_no] ASC, [agitm_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagitmmst3]
    ON [dbo].[agitmmst]([agitm_loc_no] ASC, [agitm_search] ASC, [agitm_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagitmmst4]
    ON [dbo].[agitmmst]([agitm_loc_no] ASC, [agitm_upc_code] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagitmmst5]
    ON [dbo].[agitmmst]([agitm_loc_no] ASC, [agitm_desc] ASC, [agitm_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagitmmst6]
    ON [dbo].[agitmmst]([agitm_search] ASC, [agitm_no] ASC, [agitm_loc_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagitmmst7]
    ON [dbo].[agitmmst]([agitm_upc_code] ASC, [agitm_loc_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagitmmst8]
    ON [dbo].[agitmmst]([agitm_desc] ASC, [agitm_no] ASC, [agitm_loc_no] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_agitmmst_A4GLIdentity]
    ON [dbo].[agitmmst]([A4GLIdentity] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[agitmmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agitmmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agitmmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agitmmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agitmmst] TO PUBLIC
    AS [dbo];

