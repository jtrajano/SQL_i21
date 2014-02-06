CREATE TABLE [dbo].[ftordmst] (
    [ftord_cus_no]              CHAR (10)       NOT NULL,
    [ftord_work_ord_no]         INT             NOT NULL,
    [ftord_loc_no]              CHAR (3)        NOT NULL,
    [ftord_line_no]             SMALLINT        NOT NULL,
    [ftord_rev_dt]              INT             NULL,
    [ftord_status]              CHAR (1)        NULL,
    [ftord_wksht_prtd_yn]       CHAR (1)        NULL,
    [ftord_batch_no]            SMALLINT        NULL,
    [ftord_type]                CHAR (1)        NULL,
    [ftord_terms_9]             TINYINT         NULL,
    [ftord_farm_no]             CHAR (10)       NULL,
    [ftord_field_no]            CHAR (10)       NULL,
    [ftord_prod_grp]            CHAR (13)       NULL,
    [ftord_protect_yn]          CHAR (1)        NULL,
    [ftord_split_yn]            CHAR (1)        NULL,
    [ftord_acres]               DECIMAL (9, 2)  NULL,
    [ftord_crop]                CHAR (15)       NULL,
    [ftord_contract]            CHAR (1)        NULL,
    [ftord_applicator_no]       CHAR (10)       NULL,
    [ftord_un_per_acre]         DECIMAL (9, 2)  NULL,
    [ftord_un_desc]             CHAR (3)        NULL,
    [ftord_guar_analysis]       CHAR (40)       NULL,
    [ftord_plant_analysis]      CHAR (40)       NULL,
    [ftord_batch_size]          INT             NULL,
    [ftord_equal_batches_yn]    CHAR (1)        NULL,
    [ftord_no_batches]          SMALLINT        NULL,
    [ftord_mixer_oversize_yn]   CHAR (1)        NULL,
    [ftord_comments]            CHAR (30)       NULL,
    [ftord_pests]               CHAR (45)       NULL,
    [ftord_instructions]        CHAR (128)      NULL,
    [ftord_method_id]           CHAR (2)        NULL,
    [ftord_mixer_id_9]          TINYINT         NULL,
    [ftord_mix_rev_dt]          INT             NULL,
    [ftord_app_rev_dt]          INT             NULL,
    [ftord_app_start_time]      SMALLINT        NULL,
    [ftord_app_end_time]        SMALLINT        NULL,
    [ftord_app_wind_dir]        CHAR (3)        NULL,
    [ftord_app_wind_speed]      TINYINT         NULL,
    [ftord_app_temp]            DECIMAL (5, 2)  NULL,
    [ftord_wet_dry_wd]          CHAR (1)        NULL,
    [ftord_level_rough_lr]      CHAR (1)        NULL,
    [ftord_fine_cloddy_fc]      CHAR (1)        NULL,
    [ftord_app_speed]           DECIMAL (3, 1)  NULL,
    [ftord_app_psi]             SMALLINT        NULL,
    [ftord_app_nozzle_size]     DECIMAL (4, 2)  NULL,
    [ftord_order_taker]         CHAR (3)        NULL,
    [ftord_ord_taken_rev_dt]    INT             NULL,
    [ftord_anticip_app_rev_dt]  INT             NULL,
    [ftord_deflt_split]         CHAR (4)        NULL,
    [ftord_deflt_split_type]    CHAR (1)        NULL,
    [ftord_slsmn_id]            CHAR (3)        NULL,
    [ftord_expire_rev_dt]       INT             NULL,
    [ftord_order_analysis]      CHAR (30)       NULL,
    [ftord_carrier_un_per_acre] DECIMAL (9, 2)  NULL,
    [ftord_crop_code]           CHAR (2)        NULL,
    [ftord_use_prepay_yn]       CHAR (1)        NULL,
    [ftord_prc_lvl]             TINYINT         NULL,
    [ftord_cubic_feet]          DECIMAL (9, 2)  NULL,
    [ftord_carrier_itm_adj]     DECIMAL (11, 4) NULL,
    [ftord_user_id]             CHAR (16)       NULL,
    [ftord_user_rev_dt]         INT             NULL,
    [ftord_itm_no]              CHAR (13)       NULL,
    [ftord_carrier_yn]          CHAR (1)        NULL,
    [ftord_units]               DECIMAL (11, 4) NULL,
    [ftord_ship_units]          DECIMAL (11, 4) NULL,
    [ftord_split_override]      CHAR (4)        NULL,
    [ftord_split_type]          CHAR (1)        NULL,
    [ftord_blended_yn]          CHAR (1)        NULL,
    [ftord_taxed_yn]            CHAR (1)        NULL,
    [ftord_disc_type_ap]        CHAR (1)        NULL,
    [ftord_disc_amt_rate]       DECIMAL (11, 5) NULL,
    [ftord_include_in_mix_yn]   CHAR (1)        NULL,
    [ftord_batch_prt_order]     TINYINT         NULL,
    [ftord_item_type]           CHAR (1)        NULL,
    [ftord_hand_add_yn]         CHAR (1)        NULL,
    [ftord_n_units]             DECIMAL (9, 2)  NULL,
    [ftord_p_units]             DECIMAL (9, 2)  NULL,
    [ftord_k_units]             DECIMAL (9, 2)  NULL,
    [ftord_mg_units]            DECIMAL (5, 2)  NULL,
    [ftord_b_units]             DECIMAL (5, 2)  NULL,
    [ftord_mn_units]            DECIMAL (5, 2)  NULL,
    [ftord_zn_units]            DECIMAL (5, 2)  NULL,
    [ftord_s_units]             DECIMAL (5, 2)  NULL,
    [ftord_fe_units]            DECIMAL (5, 2)  NULL,
    [ftord_cu_units]            DECIMAL (5, 2)  NULL,
    [ftord_ca_units]            DECIMAL (5, 2)  NULL,
    [ftord_lime_units]          DECIMAL (5, 2)  NULL,
    [ftord_nitrogen_pct]        DECIMAL (4, 2)  NULL,
    [ftord_p205_pct]            DECIMAL (4, 2)  NULL,
    [ftord_k20_pct]             DECIMAL (4, 2)  NULL,
    [ftord_mg_pct]              DECIMAL (4, 2)  NULL,
    [ftord_b_pct]               DECIMAL (4, 2)  NULL,
    [ftord_mn_pct]              DECIMAL (4, 2)  NULL,
    [ftord_zn_pct]              DECIMAL (4, 2)  NULL,
    [ftord_s_pct]               DECIMAL (4, 2)  NULL,
    [ftord_fe_pct]              DECIMAL (4, 2)  NULL,
    [ftord_cu_pct]              DECIMAL (4, 2)  NULL,
    [ftord_ca_pct]              DECIMAL (4, 2)  NULL,
    [ftord_lime_pct]            DECIMAL (4, 2)  NULL,
    [ftord_density]             DECIMAL (6, 2)  NULL,
    [ftord_comment]             CHAR (30)       NULL,
    [A4GLIdentity]              NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_ftordmst] PRIMARY KEY NONCLUSTERED ([ftord_cus_no] ASC, [ftord_work_ord_no] ASC, [ftord_loc_no] ASC, [ftord_line_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iftordmst0]
    ON [dbo].[ftordmst]([ftord_cus_no] ASC, [ftord_work_ord_no] ASC, [ftord_loc_no] ASC, [ftord_line_no] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iftordmst1]
    ON [dbo].[ftordmst]([ftord_loc_no] ASC, [ftord_work_ord_no] ASC, [ftord_line_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[ftordmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ftordmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ftordmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ftordmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ftordmst] TO PUBLIC
    AS [dbo];

