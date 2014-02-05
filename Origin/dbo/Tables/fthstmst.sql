CREATE TABLE [dbo].[fthstmst] (
    [fthst_cus_no]              CHAR (10)       NOT NULL,
    [fthst_farm_no]             CHAR (10)       NOT NULL,
    [fthst_field_no]            CHAR (10)       NOT NULL,
    [fthst_work_ord_no]         INT             NOT NULL,
    [fthst_loc_no]              CHAR (3)        NOT NULL,
    [fthst_line_no]             SMALLINT        NOT NULL,
    [fthst_rev_dt]              INT             NULL,
    [fthst_status]              CHAR (1)        NULL,
    [fthst_wksht_prtd_yn]       CHAR (1)        NULL,
    [fthst_batch_no]            SMALLINT        NULL,
    [fthst_type]                CHAR (1)        NULL,
    [fthst_terms]               TINYINT         NULL,
    [fthst_prod_grp]            CHAR (10)       NULL,
    [fthst_protect_yn]          CHAR (1)        NULL,
    [fthst_split_yn]            CHAR (1)        NULL,
    [fthst_acres]               DECIMAL (9, 2)  NULL,
    [fthst_crop]                CHAR (15)       NULL,
    [fthst_contract]            CHAR (1)        NULL,
    [fthst_applicator_no]       CHAR (10)       NULL,
    [fthst_un_per_acre]         DECIMAL (9, 2)  NULL,
    [fthst_un_desc]             CHAR (3)        NULL,
    [fthst_guar_analysis]       CHAR (40)       NULL,
    [fthst_plant_analysis]      CHAR (40)       NULL,
    [fthst_batch_size]          INT             NULL,
    [fthst_equal_batches_yn]    CHAR (1)        NULL,
    [fthst_no_batches]          SMALLINT        NULL,
    [fthst_mixer_oversize_yn]   CHAR (1)        NULL,
    [fthst_comments]            CHAR (30)       NULL,
    [fthst_pests]               CHAR (45)       NULL,
    [fthst_instructions]        CHAR (128)      NULL,
    [fthst_method_id]           CHAR (2)        NULL,
    [fthst_mixer_id]            TINYINT         NULL,
    [fthst_mix_rev_dt]          INT             NULL,
    [fthst_app_rev_dt]          INT             NULL,
    [fthst_app_start_time]      SMALLINT        NULL,
    [fthst_app_end_time]        SMALLINT        NULL,
    [fthst_app_wind_dir]        CHAR (3)        NULL,
    [fthst_app_wind_speed]      TINYINT         NULL,
    [fthst_app_temp]            DECIMAL (5, 2)  NULL,
    [fthst_wet_dry_wd]          CHAR (1)        NULL,
    [fthst_level_rough_lr]      CHAR (1)        NULL,
    [fthst_fine_cloddy_fc]      CHAR (1)        NULL,
    [fthst_app_speed]           DECIMAL (3, 1)  NULL,
    [fthst_app_psi]             SMALLINT        NULL,
    [fthst_app_nozzle_size]     DECIMAL (4, 2)  NULL,
    [fthst_order_taker]         CHAR (3)        NULL,
    [fthst_ord_taken_rev_dt]    INT             NULL,
    [fthst_anticip_app_rev_dt]  INT             NULL,
    [fthst_deflt_split]         CHAR (4)        NULL,
    [fthst_deflt_split_type]    CHAR (1)        NULL,
    [fthst_slsmn_id]            CHAR (3)        NULL,
    [fthst_tot_amt]             DECIMAL (9, 2)  NULL,
    [fthst_expire_rev_dt]       INT             NULL,
    [fthst_order_analysis]      CHAR (30)       NULL,
    [fthst_carrier_un_per_acre] DECIMAL (9, 2)  NULL,
    [fthst_crop_code]           CHAR (2)        NULL,
    [fthst_use_prepay_yn]       CHAR (1)        NULL,
    [fthst_prc_lvl]             TINYINT         NULL,
    [fthst_cubic_feet]          DECIMAL (9, 2)  NULL,
    [fthst_user_id]             CHAR (16)       NULL,
    [fthst_user_rev_dt]         INT             NULL,
    [fthst_itm_no]              CHAR (13)       NULL,
    [fthst_carrier_yn]          CHAR (1)        NULL,
    [fthst_units]               DECIMAL (11, 4) NULL,
    [fthst_ship_units]          DECIMAL (11, 4) NULL,
    [fthst_split_override]      CHAR (4)        NULL,
    [fthst_split_type]          CHAR (1)        NULL,
    [fthst_blended_yn]          CHAR (1)        NULL,
    [fthst_taxed_yn]            CHAR (1)        NULL,
    [fthst_disc_type_ap]        CHAR (1)        NULL,
    [fthst_disc_amt_rate]       DECIMAL (11, 5) NULL,
    [fthst_include_in_mix_yn]   CHAR (1)        NULL,
    [fthst_batch_prt_order]     TINYINT         NULL,
    [fthst_item_type]           CHAR (1)        NULL,
    [fthst_hand_add_yn]         CHAR (1)        NULL,
    [fthst_n_units]             DECIMAL (9, 2)  NULL,
    [fthst_p_units]             DECIMAL (9, 2)  NULL,
    [fthst_k_units]             DECIMAL (9, 2)  NULL,
    [fthst_mg_units]            DECIMAL (5, 2)  NULL,
    [fthst_b_units]             DECIMAL (5, 2)  NULL,
    [fthst_mn_units]            DECIMAL (5, 2)  NULL,
    [fthst_zn_units]            DECIMAL (5, 2)  NULL,
    [fthst_s_units]             DECIMAL (5, 2)  NULL,
    [fthst_fe_units]            DECIMAL (5, 2)  NULL,
    [fthst_cu_units]            DECIMAL (5, 2)  NULL,
    [fthst_ca_units]            DECIMAL (5, 2)  NULL,
    [fthst_lime_units]          DECIMAL (5, 2)  NULL,
    [fthst_nitrogen_pct]        DECIMAL (4, 2)  NULL,
    [fthst_p205_pct]            DECIMAL (4, 2)  NULL,
    [fthst_k20_pct]             DECIMAL (4, 2)  NULL,
    [fthst_mg_pct]              DECIMAL (4, 2)  NULL,
    [fthst_b_pct]               DECIMAL (4, 2)  NULL,
    [fthst_mn_pct]              DECIMAL (4, 2)  NULL,
    [fthst_zn_pct]              DECIMAL (4, 2)  NULL,
    [fthst_s_pct]               DECIMAL (4, 2)  NULL,
    [fthst_fe_pct]              DECIMAL (4, 2)  NULL,
    [fthst_cu_pct]              DECIMAL (4, 2)  NULL,
    [fthst_ca_pct]              DECIMAL (4, 2)  NULL,
    [fthst_lime_pct]            DECIMAL (4, 2)  NULL,
    [fthst_density]             DECIMAL (6, 2)  NULL,
    [fthst_comment]             CHAR (30)       NULL,
    [A4GLIdentity]              NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_fthstmst] PRIMARY KEY NONCLUSTERED ([fthst_cus_no] ASC, [fthst_farm_no] ASC, [fthst_field_no] ASC, [fthst_work_ord_no] ASC, [fthst_loc_no] ASC, [fthst_line_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ifthstmst0]
    ON [dbo].[fthstmst]([fthst_cus_no] ASC, [fthst_farm_no] ASC, [fthst_field_no] ASC, [fthst_work_ord_no] ASC, [fthst_loc_no] ASC, [fthst_line_no] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Ifthstmst1]
    ON [dbo].[fthstmst]([fthst_loc_no] ASC, [fthst_work_ord_no] ASC, [fthst_line_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[fthstmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[fthstmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[fthstmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[fthstmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[fthstmst] TO PUBLIC
    AS [dbo];

