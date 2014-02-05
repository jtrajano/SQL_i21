﻿CREATE TABLE [dbo].[cfvehmst] (
    [cfveh_ar_cus_no]         CHAR (10)      NOT NULL,
    [cfveh_vehl_no]           CHAR (10)      NOT NULL,
    [cfveh_cus_unit_no]       CHAR (18)      NULL,
    [cfveh_vehicle_desc]      CHAR (30)      NULL,
    [cfveh_days_between_serv] SMALLINT       NULL,
    [cfveh_mile_between_serv] INT            NULL,
    [cfveh_last_rmndr_odom]   INT            NULL,
    [cfveh_last_rmndr_date]   INT            NULL,
    [cfveh_last_serv_rev_dt]  INT            NULL,
    [cfveh_last_serv_odom]    INT            NULL,
    [cfveh_notice_msg1]       CHAR (60)      NULL,
    [cfveh_notice_msg2]       CHAR (60)      NULL,
    [cfveh_ar_itm_no_1]       CHAR (10)      NULL,
    [cfveh_ar_itm_no_2]       CHAR (10)      NULL,
    [cfveh_ar_itm_no_3]       CHAR (10)      NULL,
    [cfveh_ar_itm_no_4]       CHAR (10)      NULL,
    [cfveh_ar_itm_no_5]       CHAR (10)      NULL,
    [cfveh_ar_itm_no_6]       CHAR (10)      NULL,
    [cfveh_ar_itm_no_7]       CHAR (10)      NULL,
    [cfveh_ar_itm_no_8]       CHAR (10)      NULL,
    [cfveh_ar_itm_no_9]       CHAR (10)      NULL,
    [cfveh_ar_itm_no_10]      CHAR (10)      NULL,
    [cfveh_ar_itm_no_11]      CHAR (10)      NULL,
    [cfveh_ar_itm_no_12]      CHAR (10)      NULL,
    [cfveh_ar_itm_no_13]      CHAR (10)      NULL,
    [cfveh_ar_itm_no_14]      CHAR (10)      NULL,
    [cfveh_ar_itm_no_15]      CHAR (10)      NULL,
    [cfveh_ar_itm_no_16]      CHAR (10)      NULL,
    [cfveh_ar_itm_no_17]      CHAR (10)      NULL,
    [cfveh_ar_itm_no_18]      CHAR (10)      NULL,
    [cfveh_ar_itm_no_19]      CHAR (10)      NULL,
    [cfveh_ar_itm_no_20]      CHAR (10)      NULL,
    [cfveh_fet_yn_1]          CHAR (1)       NULL,
    [cfveh_fet_yn_2]          CHAR (1)       NULL,
    [cfveh_fet_yn_3]          CHAR (1)       NULL,
    [cfveh_fet_yn_4]          CHAR (1)       NULL,
    [cfveh_fet_yn_5]          CHAR (1)       NULL,
    [cfveh_fet_yn_6]          CHAR (1)       NULL,
    [cfveh_fet_yn_7]          CHAR (1)       NULL,
    [cfveh_fet_yn_8]          CHAR (1)       NULL,
    [cfveh_fet_yn_9]          CHAR (1)       NULL,
    [cfveh_fet_yn_10]         CHAR (1)       NULL,
    [cfveh_fet_yn_11]         CHAR (1)       NULL,
    [cfveh_fet_yn_12]         CHAR (1)       NULL,
    [cfveh_fet_yn_13]         CHAR (1)       NULL,
    [cfveh_fet_yn_14]         CHAR (1)       NULL,
    [cfveh_fet_yn_15]         CHAR (1)       NULL,
    [cfveh_fet_yn_16]         CHAR (1)       NULL,
    [cfveh_fet_yn_17]         CHAR (1)       NULL,
    [cfveh_fet_yn_18]         CHAR (1)       NULL,
    [cfveh_fet_yn_19]         CHAR (1)       NULL,
    [cfveh_fet_yn_20]         CHAR (1)       NULL,
    [cfveh_set_yn_1]          CHAR (1)       NULL,
    [cfveh_set_yn_2]          CHAR (1)       NULL,
    [cfveh_set_yn_3]          CHAR (1)       NULL,
    [cfveh_set_yn_4]          CHAR (1)       NULL,
    [cfveh_set_yn_5]          CHAR (1)       NULL,
    [cfveh_set_yn_6]          CHAR (1)       NULL,
    [cfveh_set_yn_7]          CHAR (1)       NULL,
    [cfveh_set_yn_8]          CHAR (1)       NULL,
    [cfveh_set_yn_9]          CHAR (1)       NULL,
    [cfveh_set_yn_10]         CHAR (1)       NULL,
    [cfveh_set_yn_11]         CHAR (1)       NULL,
    [cfveh_set_yn_12]         CHAR (1)       NULL,
    [cfveh_set_yn_13]         CHAR (1)       NULL,
    [cfveh_set_yn_14]         CHAR (1)       NULL,
    [cfveh_set_yn_15]         CHAR (1)       NULL,
    [cfveh_set_yn_16]         CHAR (1)       NULL,
    [cfveh_set_yn_17]         CHAR (1)       NULL,
    [cfveh_set_yn_18]         CHAR (1)       NULL,
    [cfveh_set_yn_19]         CHAR (1)       NULL,
    [cfveh_set_yn_20]         CHAR (1)       NULL,
    [cfveh_sst_yn_1]          CHAR (1)       NULL,
    [cfveh_sst_yn_2]          CHAR (1)       NULL,
    [cfveh_sst_yn_3]          CHAR (1)       NULL,
    [cfveh_sst_yn_4]          CHAR (1)       NULL,
    [cfveh_sst_yn_5]          CHAR (1)       NULL,
    [cfveh_sst_yn_6]          CHAR (1)       NULL,
    [cfveh_sst_yn_7]          CHAR (1)       NULL,
    [cfveh_sst_yn_8]          CHAR (1)       NULL,
    [cfveh_sst_yn_9]          CHAR (1)       NULL,
    [cfveh_sst_yn_10]         CHAR (1)       NULL,
    [cfveh_sst_yn_11]         CHAR (1)       NULL,
    [cfveh_sst_yn_12]         CHAR (1)       NULL,
    [cfveh_sst_yn_13]         CHAR (1)       NULL,
    [cfveh_sst_yn_14]         CHAR (1)       NULL,
    [cfveh_sst_yn_15]         CHAR (1)       NULL,
    [cfveh_sst_yn_16]         CHAR (1)       NULL,
    [cfveh_sst_yn_17]         CHAR (1)       NULL,
    [cfveh_sst_yn_18]         CHAR (1)       NULL,
    [cfveh_sst_yn_19]         CHAR (1)       NULL,
    [cfveh_sst_yn_20]         CHAR (1)       NULL,
    [cfveh_lc1_yn_1]          CHAR (1)       NULL,
    [cfveh_lc1_yn_2]          CHAR (1)       NULL,
    [cfveh_lc1_yn_3]          CHAR (1)       NULL,
    [cfveh_lc1_yn_4]          CHAR (1)       NULL,
    [cfveh_lc1_yn_5]          CHAR (1)       NULL,
    [cfveh_lc1_yn_6]          CHAR (1)       NULL,
    [cfveh_lc1_yn_7]          CHAR (1)       NULL,
    [cfveh_lc1_yn_8]          CHAR (1)       NULL,
    [cfveh_lc1_yn_9]          CHAR (1)       NULL,
    [cfveh_lc1_yn_10]         CHAR (1)       NULL,
    [cfveh_lc1_yn_11]         CHAR (1)       NULL,
    [cfveh_lc1_yn_12]         CHAR (1)       NULL,
    [cfveh_lc1_yn_13]         CHAR (1)       NULL,
    [cfveh_lc1_yn_14]         CHAR (1)       NULL,
    [cfveh_lc1_yn_15]         CHAR (1)       NULL,
    [cfveh_lc1_yn_16]         CHAR (1)       NULL,
    [cfveh_lc1_yn_17]         CHAR (1)       NULL,
    [cfveh_lc1_yn_18]         CHAR (1)       NULL,
    [cfveh_lc1_yn_19]         CHAR (1)       NULL,
    [cfveh_lc1_yn_20]         CHAR (1)       NULL,
    [cfveh_lc2_yn_1]          CHAR (1)       NULL,
    [cfveh_lc2_yn_2]          CHAR (1)       NULL,
    [cfveh_lc2_yn_3]          CHAR (1)       NULL,
    [cfveh_lc2_yn_4]          CHAR (1)       NULL,
    [cfveh_lc2_yn_5]          CHAR (1)       NULL,
    [cfveh_lc2_yn_6]          CHAR (1)       NULL,
    [cfveh_lc2_yn_7]          CHAR (1)       NULL,
    [cfveh_lc2_yn_8]          CHAR (1)       NULL,
    [cfveh_lc2_yn_9]          CHAR (1)       NULL,
    [cfveh_lc2_yn_10]         CHAR (1)       NULL,
    [cfveh_lc2_yn_11]         CHAR (1)       NULL,
    [cfveh_lc2_yn_12]         CHAR (1)       NULL,
    [cfveh_lc2_yn_13]         CHAR (1)       NULL,
    [cfveh_lc2_yn_14]         CHAR (1)       NULL,
    [cfveh_lc2_yn_15]         CHAR (1)       NULL,
    [cfveh_lc2_yn_16]         CHAR (1)       NULL,
    [cfveh_lc2_yn_17]         CHAR (1)       NULL,
    [cfveh_lc2_yn_18]         CHAR (1)       NULL,
    [cfveh_lc2_yn_19]         CHAR (1)       NULL,
    [cfveh_lc2_yn_20]         CHAR (1)       NULL,
    [cfveh_lc3_yn_1]          CHAR (1)       NULL,
    [cfveh_lc3_yn_2]          CHAR (1)       NULL,
    [cfveh_lc3_yn_3]          CHAR (1)       NULL,
    [cfveh_lc3_yn_4]          CHAR (1)       NULL,
    [cfveh_lc3_yn_5]          CHAR (1)       NULL,
    [cfveh_lc3_yn_6]          CHAR (1)       NULL,
    [cfveh_lc3_yn_7]          CHAR (1)       NULL,
    [cfveh_lc3_yn_8]          CHAR (1)       NULL,
    [cfveh_lc3_yn_9]          CHAR (1)       NULL,
    [cfveh_lc3_yn_10]         CHAR (1)       NULL,
    [cfveh_lc3_yn_11]         CHAR (1)       NULL,
    [cfveh_lc3_yn_12]         CHAR (1)       NULL,
    [cfveh_lc3_yn_13]         CHAR (1)       NULL,
    [cfveh_lc3_yn_14]         CHAR (1)       NULL,
    [cfveh_lc3_yn_15]         CHAR (1)       NULL,
    [cfveh_lc3_yn_16]         CHAR (1)       NULL,
    [cfveh_lc3_yn_17]         CHAR (1)       NULL,
    [cfveh_lc3_yn_18]         CHAR (1)       NULL,
    [cfveh_lc3_yn_19]         CHAR (1)       NULL,
    [cfveh_lc3_yn_20]         CHAR (1)       NULL,
    [cfveh_lc4_yn_1]          CHAR (1)       NULL,
    [cfveh_lc4_yn_2]          CHAR (1)       NULL,
    [cfveh_lc4_yn_3]          CHAR (1)       NULL,
    [cfveh_lc4_yn_4]          CHAR (1)       NULL,
    [cfveh_lc4_yn_5]          CHAR (1)       NULL,
    [cfveh_lc4_yn_6]          CHAR (1)       NULL,
    [cfveh_lc4_yn_7]          CHAR (1)       NULL,
    [cfveh_lc4_yn_8]          CHAR (1)       NULL,
    [cfveh_lc4_yn_9]          CHAR (1)       NULL,
    [cfveh_lc4_yn_10]         CHAR (1)       NULL,
    [cfveh_lc4_yn_11]         CHAR (1)       NULL,
    [cfveh_lc4_yn_12]         CHAR (1)       NULL,
    [cfveh_lc4_yn_13]         CHAR (1)       NULL,
    [cfveh_lc4_yn_14]         CHAR (1)       NULL,
    [cfveh_lc4_yn_15]         CHAR (1)       NULL,
    [cfveh_lc4_yn_16]         CHAR (1)       NULL,
    [cfveh_lc4_yn_17]         CHAR (1)       NULL,
    [cfveh_lc4_yn_18]         CHAR (1)       NULL,
    [cfveh_lc4_yn_19]         CHAR (1)       NULL,
    [cfveh_lc4_yn_20]         CHAR (1)       NULL,
    [cfveh_lc5_yn_1]          CHAR (1)       NULL,
    [cfveh_lc5_yn_2]          CHAR (1)       NULL,
    [cfveh_lc5_yn_3]          CHAR (1)       NULL,
    [cfveh_lc5_yn_4]          CHAR (1)       NULL,
    [cfveh_lc5_yn_5]          CHAR (1)       NULL,
    [cfveh_lc5_yn_6]          CHAR (1)       NULL,
    [cfveh_lc5_yn_7]          CHAR (1)       NULL,
    [cfveh_lc5_yn_8]          CHAR (1)       NULL,
    [cfveh_lc5_yn_9]          CHAR (1)       NULL,
    [cfveh_lc5_yn_10]         CHAR (1)       NULL,
    [cfveh_lc5_yn_11]         CHAR (1)       NULL,
    [cfveh_lc5_yn_12]         CHAR (1)       NULL,
    [cfveh_lc5_yn_13]         CHAR (1)       NULL,
    [cfveh_lc5_yn_14]         CHAR (1)       NULL,
    [cfveh_lc5_yn_15]         CHAR (1)       NULL,
    [cfveh_lc5_yn_16]         CHAR (1)       NULL,
    [cfveh_lc5_yn_17]         CHAR (1)       NULL,
    [cfveh_lc5_yn_18]         CHAR (1)       NULL,
    [cfveh_lc5_yn_19]         CHAR (1)       NULL,
    [cfveh_lc5_yn_20]         CHAR (1)       NULL,
    [cfveh_lc6_yn_1]          CHAR (1)       NULL,
    [cfveh_lc6_yn_2]          CHAR (1)       NULL,
    [cfveh_lc6_yn_3]          CHAR (1)       NULL,
    [cfveh_lc6_yn_4]          CHAR (1)       NULL,
    [cfveh_lc6_yn_5]          CHAR (1)       NULL,
    [cfveh_lc6_yn_6]          CHAR (1)       NULL,
    [cfveh_lc6_yn_7]          CHAR (1)       NULL,
    [cfveh_lc6_yn_8]          CHAR (1)       NULL,
    [cfveh_lc6_yn_9]          CHAR (1)       NULL,
    [cfveh_lc6_yn_10]         CHAR (1)       NULL,
    [cfveh_lc6_yn_11]         CHAR (1)       NULL,
    [cfveh_lc6_yn_12]         CHAR (1)       NULL,
    [cfveh_lc6_yn_13]         CHAR (1)       NULL,
    [cfveh_lc6_yn_14]         CHAR (1)       NULL,
    [cfveh_lc6_yn_15]         CHAR (1)       NULL,
    [cfveh_lc6_yn_16]         CHAR (1)       NULL,
    [cfveh_lc6_yn_17]         CHAR (1)       NULL,
    [cfveh_lc6_yn_18]         CHAR (1)       NULL,
    [cfveh_lc6_yn_19]         CHAR (1)       NULL,
    [cfveh_lc6_yn_20]         CHAR (1)       NULL,
    [cfveh_lc7_yn_1]          CHAR (1)       NULL,
    [cfveh_lc7_yn_2]          CHAR (1)       NULL,
    [cfveh_lc7_yn_3]          CHAR (1)       NULL,
    [cfveh_lc7_yn_4]          CHAR (1)       NULL,
    [cfveh_lc7_yn_5]          CHAR (1)       NULL,
    [cfveh_lc7_yn_6]          CHAR (1)       NULL,
    [cfveh_lc7_yn_7]          CHAR (1)       NULL,
    [cfveh_lc7_yn_8]          CHAR (1)       NULL,
    [cfveh_lc7_yn_9]          CHAR (1)       NULL,
    [cfveh_lc7_yn_10]         CHAR (1)       NULL,
    [cfveh_lc7_yn_11]         CHAR (1)       NULL,
    [cfveh_lc7_yn_12]         CHAR (1)       NULL,
    [cfveh_lc7_yn_13]         CHAR (1)       NULL,
    [cfveh_lc7_yn_14]         CHAR (1)       NULL,
    [cfveh_lc7_yn_15]         CHAR (1)       NULL,
    [cfveh_lc7_yn_16]         CHAR (1)       NULL,
    [cfveh_lc7_yn_17]         CHAR (1)       NULL,
    [cfveh_lc7_yn_18]         CHAR (1)       NULL,
    [cfveh_lc7_yn_19]         CHAR (1)       NULL,
    [cfveh_lc7_yn_20]         CHAR (1)       NULL,
    [cfveh_lc8_yn_1]          CHAR (1)       NULL,
    [cfveh_lc8_yn_2]          CHAR (1)       NULL,
    [cfveh_lc8_yn_3]          CHAR (1)       NULL,
    [cfveh_lc8_yn_4]          CHAR (1)       NULL,
    [cfveh_lc8_yn_5]          CHAR (1)       NULL,
    [cfveh_lc8_yn_6]          CHAR (1)       NULL,
    [cfveh_lc8_yn_7]          CHAR (1)       NULL,
    [cfveh_lc8_yn_8]          CHAR (1)       NULL,
    [cfveh_lc8_yn_9]          CHAR (1)       NULL,
    [cfveh_lc8_yn_10]         CHAR (1)       NULL,
    [cfveh_lc8_yn_11]         CHAR (1)       NULL,
    [cfveh_lc8_yn_12]         CHAR (1)       NULL,
    [cfveh_lc8_yn_13]         CHAR (1)       NULL,
    [cfveh_lc8_yn_14]         CHAR (1)       NULL,
    [cfveh_lc8_yn_15]         CHAR (1)       NULL,
    [cfveh_lc8_yn_16]         CHAR (1)       NULL,
    [cfveh_lc8_yn_17]         CHAR (1)       NULL,
    [cfveh_lc8_yn_18]         CHAR (1)       NULL,
    [cfveh_lc8_yn_19]         CHAR (1)       NULL,
    [cfveh_lc8_yn_20]         CHAR (1)       NULL,
    [cfveh_lc9_yn_1]          CHAR (1)       NULL,
    [cfveh_lc9_yn_2]          CHAR (1)       NULL,
    [cfveh_lc9_yn_3]          CHAR (1)       NULL,
    [cfveh_lc9_yn_4]          CHAR (1)       NULL,
    [cfveh_lc9_yn_5]          CHAR (1)       NULL,
    [cfveh_lc9_yn_6]          CHAR (1)       NULL,
    [cfveh_lc9_yn_7]          CHAR (1)       NULL,
    [cfveh_lc9_yn_8]          CHAR (1)       NULL,
    [cfveh_lc9_yn_9]          CHAR (1)       NULL,
    [cfveh_lc9_yn_10]         CHAR (1)       NULL,
    [cfveh_lc9_yn_11]         CHAR (1)       NULL,
    [cfveh_lc9_yn_12]         CHAR (1)       NULL,
    [cfveh_lc9_yn_13]         CHAR (1)       NULL,
    [cfveh_lc9_yn_14]         CHAR (1)       NULL,
    [cfveh_lc9_yn_15]         CHAR (1)       NULL,
    [cfveh_lc9_yn_16]         CHAR (1)       NULL,
    [cfveh_lc9_yn_17]         CHAR (1)       NULL,
    [cfveh_lc9_yn_18]         CHAR (1)       NULL,
    [cfveh_lc9_yn_19]         CHAR (1)       NULL,
    [cfveh_lc9_yn_20]         CHAR (1)       NULL,
    [cfveh_lc10_yn_1]         CHAR (1)       NULL,
    [cfveh_lc10_yn_2]         CHAR (1)       NULL,
    [cfveh_lc10_yn_3]         CHAR (1)       NULL,
    [cfveh_lc10_yn_4]         CHAR (1)       NULL,
    [cfveh_lc10_yn_5]         CHAR (1)       NULL,
    [cfveh_lc10_yn_6]         CHAR (1)       NULL,
    [cfveh_lc10_yn_7]         CHAR (1)       NULL,
    [cfveh_lc10_yn_8]         CHAR (1)       NULL,
    [cfveh_lc10_yn_9]         CHAR (1)       NULL,
    [cfveh_lc10_yn_10]        CHAR (1)       NULL,
    [cfveh_lc10_yn_11]        CHAR (1)       NULL,
    [cfveh_lc10_yn_12]        CHAR (1)       NULL,
    [cfveh_lc10_yn_13]        CHAR (1)       NULL,
    [cfveh_lc10_yn_14]        CHAR (1)       NULL,
    [cfveh_lc10_yn_15]        CHAR (1)       NULL,
    [cfveh_lc10_yn_16]        CHAR (1)       NULL,
    [cfveh_lc10_yn_17]        CHAR (1)       NULL,
    [cfveh_lc10_yn_18]        CHAR (1)       NULL,
    [cfveh_lc10_yn_19]        CHAR (1)       NULL,
    [cfveh_lc10_yn_20]        CHAR (1)       NULL,
    [cfveh_lc11_yn_1]         CHAR (1)       NULL,
    [cfveh_lc11_yn_2]         CHAR (1)       NULL,
    [cfveh_lc11_yn_3]         CHAR (1)       NULL,
    [cfveh_lc11_yn_4]         CHAR (1)       NULL,
    [cfveh_lc11_yn_5]         CHAR (1)       NULL,
    [cfveh_lc11_yn_6]         CHAR (1)       NULL,
    [cfveh_lc11_yn_7]         CHAR (1)       NULL,
    [cfveh_lc11_yn_8]         CHAR (1)       NULL,
    [cfveh_lc11_yn_9]         CHAR (1)       NULL,
    [cfveh_lc11_yn_10]        CHAR (1)       NULL,
    [cfveh_lc11_yn_11]        CHAR (1)       NULL,
    [cfveh_lc11_yn_12]        CHAR (1)       NULL,
    [cfveh_lc11_yn_13]        CHAR (1)       NULL,
    [cfveh_lc11_yn_14]        CHAR (1)       NULL,
    [cfveh_lc11_yn_15]        CHAR (1)       NULL,
    [cfveh_lc11_yn_16]        CHAR (1)       NULL,
    [cfveh_lc11_yn_17]        CHAR (1)       NULL,
    [cfveh_lc11_yn_18]        CHAR (1)       NULL,
    [cfveh_lc11_yn_19]        CHAR (1)       NULL,
    [cfveh_lc11_yn_20]        CHAR (1)       NULL,
    [cfveh_lc12_yn_1]         CHAR (1)       NULL,
    [cfveh_lc12_yn_2]         CHAR (1)       NULL,
    [cfveh_lc12_yn_3]         CHAR (1)       NULL,
    [cfveh_lc12_yn_4]         CHAR (1)       NULL,
    [cfveh_lc12_yn_5]         CHAR (1)       NULL,
    [cfveh_lc12_yn_6]         CHAR (1)       NULL,
    [cfveh_lc12_yn_7]         CHAR (1)       NULL,
    [cfveh_lc12_yn_8]         CHAR (1)       NULL,
    [cfveh_lc12_yn_9]         CHAR (1)       NULL,
    [cfveh_lc12_yn_10]        CHAR (1)       NULL,
    [cfveh_lc12_yn_11]        CHAR (1)       NULL,
    [cfveh_lc12_yn_12]        CHAR (1)       NULL,
    [cfveh_lc12_yn_13]        CHAR (1)       NULL,
    [cfveh_lc12_yn_14]        CHAR (1)       NULL,
    [cfveh_lc12_yn_15]        CHAR (1)       NULL,
    [cfveh_lc12_yn_16]        CHAR (1)       NULL,
    [cfveh_lc12_yn_17]        CHAR (1)       NULL,
    [cfveh_lc12_yn_18]        CHAR (1)       NULL,
    [cfveh_lc12_yn_19]        CHAR (1)       NULL,
    [cfveh_lc12_yn_20]        CHAR (1)       NULL,
    [cfveh_prc_var_1]         DECIMAL (6, 5) NULL,
    [cfveh_prc_var_2]         DECIMAL (6, 5) NULL,
    [cfveh_prc_var_3]         DECIMAL (6, 5) NULL,
    [cfveh_prc_var_4]         DECIMAL (6, 5) NULL,
    [cfveh_prc_var_5]         DECIMAL (6, 5) NULL,
    [cfveh_prc_var_6]         DECIMAL (6, 5) NULL,
    [cfveh_prc_var_7]         DECIMAL (6, 5) NULL,
    [cfveh_prc_var_8]         DECIMAL (6, 5) NULL,
    [cfveh_prc_var_9]         DECIMAL (6, 5) NULL,
    [cfveh_prc_var_10]        DECIMAL (6, 5) NULL,
    [cfveh_prc_var_11]        DECIMAL (6, 5) NULL,
    [cfveh_prc_var_12]        DECIMAL (6, 5) NULL,
    [cfveh_prc_var_13]        DECIMAL (6, 5) NULL,
    [cfveh_prc_var_14]        DECIMAL (6, 5) NULL,
    [cfveh_prc_var_15]        DECIMAL (6, 5) NULL,
    [cfveh_prc_var_16]        DECIMAL (6, 5) NULL,
    [cfveh_prc_var_17]        DECIMAL (6, 5) NULL,
    [cfveh_prc_var_18]        DECIMAL (6, 5) NULL,
    [cfveh_prc_var_19]        DECIMAL (6, 5) NULL,
    [cfveh_prc_var_20]        DECIMAL (6, 5) NULL,
    [cfveh_bill_itm_no_1]     CHAR (10)      NULL,
    [cfveh_bill_itm_no_2]     CHAR (10)      NULL,
    [cfveh_bill_itm_no_3]     CHAR (10)      NULL,
    [cfveh_bill_itm_no_4]     CHAR (10)      NULL,
    [cfveh_bill_itm_no_5]     CHAR (10)      NULL,
    [cfveh_bill_itm_no_6]     CHAR (10)      NULL,
    [cfveh_bill_itm_no_7]     CHAR (10)      NULL,
    [cfveh_bill_itm_no_8]     CHAR (10)      NULL,
    [cfveh_bill_itm_no_9]     CHAR (10)      NULL,
    [cfveh_bill_itm_no_10]    CHAR (10)      NULL,
    [cfveh_bill_itm_no_11]    CHAR (10)      NULL,
    [cfveh_bill_itm_no_12]    CHAR (10)      NULL,
    [cfveh_bill_itm_no_13]    CHAR (10)      NULL,
    [cfveh_bill_itm_no_14]    CHAR (10)      NULL,
    [cfveh_bill_itm_no_15]    CHAR (10)      NULL,
    [cfveh_bill_itm_no_16]    CHAR (10)      NULL,
    [cfveh_bill_itm_no_17]    CHAR (10)      NULL,
    [cfveh_bill_itm_no_18]    CHAR (10)      NULL,
    [cfveh_bill_itm_no_19]    CHAR (10)      NULL,
    [cfveh_bill_itm_no_20]    CHAR (10)      NULL,
    [cfveh_own_use_yn]        CHAR (1)       NULL,
    [cfveh_exp_itm_no]        CHAR (10)      NULL,
    [cfveh_user_id]           CHAR (16)      NULL,
    [cfveh_user_rev_dt]       INT            NULL,
    [A4GLIdentity]            NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_cfvehmst] PRIMARY KEY NONCLUSTERED ([cfveh_ar_cus_no] ASC, [cfveh_vehl_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Icfvehmst0]
    ON [dbo].[cfvehmst]([cfveh_ar_cus_no] ASC, [cfveh_vehl_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[cfvehmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[cfvehmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[cfvehmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[cfvehmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[cfvehmst] TO PUBLIC
    AS [dbo];

