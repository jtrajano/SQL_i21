CREATE TABLE [dbo].[cflocmst] (
    [cfloc_site_no]                 CHAR (15)   NOT NULL,
    [cfloc_ar_itm_loc_no]           CHAR (3)    NULL,
    [cfloc_card_no]                 CHAR (16)   NULL,
    [cfloc_trans_lin]               TINYINT     NULL,
    [cfloc_trans_col]               SMALLINT    NULL,
    [cfloc_trans_char]              TINYINT     NULL,
    [cfloc_driver_lin]              TINYINT     NULL,
    [cfloc_driver_col]              SMALLINT    NULL,
    [cfloc_driver_char]             TINYINT     NULL,
    [cfloc_acct_lin]                TINYINT     NULL,
    [cfloc_acct_col]                SMALLINT    NULL,
    [cfloc_acct_char]               TINYINT     NULL,
    [cfloc_vehl_lin]                TINYINT     NULL,
    [cfloc_vehl_col]                SMALLINT    NULL,
    [cfloc_vehl_char]               TINYINT     NULL,
    [cfloc_month_lin]               TINYINT     NULL,
    [cfloc_month_col]               SMALLINT    NULL,
    [cfloc_month_char]              TINYINT     NULL,
    [cfloc_day_lin]                 TINYINT     NULL,
    [cfloc_day_col]                 SMALLINT    NULL,
    [cfloc_day_char]                TINYINT     NULL,
    [cfloc_year_lin]                TINYINT     NULL,
    [cfloc_year_col]                SMALLINT    NULL,
    [cfloc_year_char]               TINYINT     NULL,
    [cfloc_hour_lin]                TINYINT     NULL,
    [cfloc_hour_col]                SMALLINT    NULL,
    [cfloc_hour_char]               TINYINT     NULL,
    [cfloc_minute_lin]              TINYINT     NULL,
    [cfloc_minute_col]              SMALLINT    NULL,
    [cfloc_minute_char]             TINYINT     NULL,
    [cfloc_second_lin]              TINYINT     NULL,
    [cfloc_second_col]              SMALLINT    NULL,
    [cfloc_second_char]             TINYINT     NULL,
    [cfloc_pump_lin]                TINYINT     NULL,
    [cfloc_pump_col]                SMALLINT    NULL,
    [cfloc_pump_char]               TINYINT     NULL,
    [cfloc_prod_lin]                TINYINT     NULL,
    [cfloc_prod_col]                SMALLINT    NULL,
    [cfloc_prod_char]               TINYINT     NULL,
    [cfloc_qty_lin]                 TINYINT     NULL,
    [cfloc_qty_col]                 SMALLINT    NULL,
    [cfloc_qty_char]                TINYINT     NULL,
    [cfloc_prc_lin]                 TINYINT     NULL,
    [cfloc_prc_col]                 SMALLINT    NULL,
    [cfloc_prc_char]                TINYINT     NULL,
    [cfloc_tot_lin]                 TINYINT     NULL,
    [cfloc_tot_col]                 SMALLINT    NULL,
    [cfloc_tot_char]                TINYINT     NULL,
    [cfloc_odom_lin]                TINYINT     NULL,
    [cfloc_odom_col]                SMALLINT    NULL,
    [cfloc_odom_char]               TINYINT     NULL,
    [cfloc_error_lin]               TINYINT     NULL,
    [cfloc_error_col]               SMALLINT    NULL,
    [cfloc_error_char]              TINYINT     NULL,
    [cfloc_misc_lin]                TINYINT     NULL,
    [cfloc_misc_col]                SMALLINT    NULL,
    [cfloc_misc_char]               TINYINT     NULL,
    [cfloc_auth_lin]                TINYINT     NULL,
    [cfloc_auth_col]                SMALLINT    NULL,
    [cfloc_auth_char]               TINYINT     NULL,
    [cfloc_site_lin]                TINYINT     NULL,
    [cfloc_site_col]                SMALLINT    NULL,
    [cfloc_site_char]               TINYINT     NULL,
    [cfloc_state]                   CHAR (2)    NULL,
    [cfloc_auth_id1]                CHAR (3)    NULL,
    [cfloc_auth_id2]                CHAR (3)    NULL,
    [cfloc_fet_yn]                  CHAR (1)    NULL,
    [cfloc_set_yn]                  CHAR (1)    NULL,
    [cfloc_sst_yn]                  CHAR (1)    NULL,
    [cfloc_lc1_yn]                  CHAR (1)    NULL,
    [cfloc_lc2_yn]                  CHAR (1)    NULL,
    [cfloc_lc3_yn]                  CHAR (1)    NULL,
    [cfloc_lc4_yn]                  CHAR (1)    NULL,
    [cfloc_lc5_yn]                  CHAR (1)    NULL,
    [cfloc_lc6_yn]                  CHAR (1)    NULL,
    [cfloc_lc7_yn]                  CHAR (1)    NULL,
    [cfloc_lc8_yn]                  CHAR (1)    NULL,
    [cfloc_lc9_yn]                  CHAR (1)    NULL,
    [cfloc_lc10_yn]                 CHAR (1)    NULL,
    [cfloc_lc11_yn]                 CHAR (1)    NULL,
    [cfloc_lc12_yn]                 CHAR (1)    NULL,
    [cfloc_lines_per_trx]           TINYINT     NULL,
    [cfloc_ignore_card]             CHAR (8)    NULL,
    [cfloc_import_file]             CHAR (12)   NULL,
    [cfloc_import_path]             CHAR (50)   NULL,
    [cfloc_iso_lin]                 TINYINT     NULL,
    [cfloc_iso_col]                 SMALLINT    NULL,
    [cfloc_iso_char]                TINYINT     NULL,
    [cfloc_prc_dec]                 TINYINT     NULL,
    [cfloc_qty_dec]                 TINYINT     NULL,
    [cfloc_tot_dec]                 TINYINT     NULL,
    [cfloc_import_type]             CHAR (1)    NULL,
    [cfloc_controller_type]         CHAR (1)    NULL,
    [cfloc_network_yn]              CHAR (1)    NULL,
    [cfloc_pump_calc_yn]            CHAR (1)    NULL,
    [cfloc_major_ccd_yn]            CHAR (1)    NULL,
    [cfloc_cenex_site_yn]           CHAR (1)    NULL,
    [cfloc_use_cont_card_yn]        CHAR (1)    NULL,
    [cfloc_ar_cash_cus_no]          CHAR (10)   NULL,
    [cfloc_process_cash_sales_yn]   CHAR (1)    NULL,
    [cfloc_assign_batch_by_date_yn] CHAR (1)    NULL,
    [cfloc_multi_site_import_yn]    CHAR (1)    NULL,
    [cfloc_site_name]               CHAR (30)   NULL,
    [cfloc_user_id]                 CHAR (16)   NULL,
    [cfloc_user_rev_dt]             INT         NULL,
    [A4GLIdentity]                  NUMERIC (9) IDENTITY (1, 1) NOT NULL
);




GO
CREATE UNIQUE CLUSTERED INDEX [Icflocmst0]
    ON [dbo].[cflocmst]([cfloc_site_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[cflocmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[cflocmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[cflocmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[cflocmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[cflocmst] TO PUBLIC
    AS [dbo];

