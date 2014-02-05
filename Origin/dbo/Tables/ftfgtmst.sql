﻿CREATE TABLE [dbo].[ftfgtmst] (
    [ftfgt_cus_no]               CHAR (10)       NOT NULL,
    [ftfgt_farm_no]              CHAR (10)       NOT NULL,
    [ftfgt_field_no]             CHAR (10)       NOT NULL,
    [ftfgt_ftitm_no]             CHAR (13)       NOT NULL,
    [ftfgt_loc_no]               CHAR (3)        NOT NULL,
    [ftfgt_guide_id]             CHAR (10)       NOT NULL,
    [ftfgt_entry_rev_dt]         INT             NULL,
    [ftfgt_entry_time]           INT             NULL,
    [ftfgt_expire_rev_dt]        INT             NULL,
    [ftfgt_agitm_no_1]           CHAR (13)       NULL,
    [ftfgt_agitm_no_2]           CHAR (13)       NULL,
    [ftfgt_agitm_no_3]           CHAR (13)       NULL,
    [ftfgt_agitm_no_4]           CHAR (13)       NULL,
    [ftfgt_agitm_no_5]           CHAR (13)       NULL,
    [ftfgt_agitm_no_6]           CHAR (13)       NULL,
    [ftfgt_agitm_no_7]           CHAR (13)       NULL,
    [ftfgt_agitm_no_8]           CHAR (13)       NULL,
    [ftfgt_agitm_no_9]           CHAR (13)       NULL,
    [ftfgt_agitm_no_10]          CHAR (13)       NULL,
    [ftfgt_agitm_no_11]          CHAR (13)       NULL,
    [ftfgt_agitm_no_12]          CHAR (13)       NULL,
    [ftfgt_agitm_no_13]          CHAR (13)       NULL,
    [ftfgt_agitm_no_14]          CHAR (13)       NULL,
    [ftfgt_agitm_no_15]          CHAR (13)       NULL,
    [ftfgt_agitm_no_16]          CHAR (13)       NULL,
    [ftfgt_agitm_no_17]          CHAR (13)       NULL,
    [ftfgt_agitm_no_18]          CHAR (13)       NULL,
    [ftfgt_agitm_no_19]          CHAR (13)       NULL,
    [ftfgt_agitm_no_20]          CHAR (13)       NULL,
    [ftfgt_agitm_no_21]          CHAR (13)       NULL,
    [ftfgt_agitm_no_22]          CHAR (13)       NULL,
    [ftfgt_agitm_no_23]          CHAR (13)       NULL,
    [ftfgt_agitm_no_24]          CHAR (13)       NULL,
    [ftfgt_agitm_no_25]          CHAR (13)       NULL,
    [ftfgt_agitm_no_26]          CHAR (13)       NULL,
    [ftfgt_agitm_no_27]          CHAR (13)       NULL,
    [ftfgt_agitm_no_28]          CHAR (13)       NULL,
    [ftfgt_agitm_no_29]          CHAR (13)       NULL,
    [ftfgt_agitm_no_30]          CHAR (13)       NULL,
    [ftfgt_agitm_no_31]          CHAR (13)       NULL,
    [ftfgt_agitm_no_32]          CHAR (13)       NULL,
    [ftfgt_agitm_no_33]          CHAR (13)       NULL,
    [ftfgt_agitm_no_34]          CHAR (13)       NULL,
    [ftfgt_agitm_no_35]          CHAR (13)       NULL,
    [ftfgt_agitm_no_36]          CHAR (13)       NULL,
    [ftfgt_agitm_no_37]          CHAR (13)       NULL,
    [ftfgt_agitm_no_38]          CHAR (13)       NULL,
    [ftfgt_agitm_no_39]          CHAR (13)       NULL,
    [ftfgt_agitm_no_40]          CHAR (13)       NULL,
    [ftfgt_qty_1]                DECIMAL (11, 4) NULL,
    [ftfgt_qty_2]                DECIMAL (11, 4) NULL,
    [ftfgt_qty_3]                DECIMAL (11, 4) NULL,
    [ftfgt_qty_4]                DECIMAL (11, 4) NULL,
    [ftfgt_qty_5]                DECIMAL (11, 4) NULL,
    [ftfgt_qty_6]                DECIMAL (11, 4) NULL,
    [ftfgt_qty_7]                DECIMAL (11, 4) NULL,
    [ftfgt_qty_8]                DECIMAL (11, 4) NULL,
    [ftfgt_qty_9]                DECIMAL (11, 4) NULL,
    [ftfgt_qty_10]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_11]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_12]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_13]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_14]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_15]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_16]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_17]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_18]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_19]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_20]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_21]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_22]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_23]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_24]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_25]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_26]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_27]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_28]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_29]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_30]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_31]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_32]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_33]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_34]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_35]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_36]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_37]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_38]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_39]               DECIMAL (11, 4) NULL,
    [ftfgt_qty_40]               DECIMAL (11, 4) NULL,
    [ftfgt_include_in_mix_yn_1]  CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_2]  CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_3]  CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_4]  CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_5]  CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_6]  CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_7]  CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_8]  CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_9]  CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_10] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_11] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_12] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_13] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_14] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_15] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_16] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_17] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_18] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_19] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_20] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_21] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_22] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_23] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_24] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_25] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_26] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_27] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_28] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_29] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_30] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_31] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_32] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_33] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_34] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_35] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_36] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_37] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_38] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_39] CHAR (1)        NULL,
    [ftfgt_include_in_mix_yn_40] CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_1]      CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_2]      CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_3]      CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_4]      CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_5]      CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_6]      CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_7]      CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_8]      CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_9]      CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_10]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_11]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_12]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_13]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_14]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_15]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_16]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_17]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_18]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_19]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_20]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_21]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_22]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_23]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_24]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_25]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_26]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_27]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_28]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_29]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_30]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_31]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_32]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_33]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_34]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_35]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_36]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_37]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_38]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_39]     CHAR (1)        NULL,
    [ftfgt_carr_agent_yn_40]     CHAR (1)        NULL,
    [ftfgt_actual_yn_1]          CHAR (1)        NULL,
    [ftfgt_actual_yn_2]          CHAR (1)        NULL,
    [ftfgt_actual_yn_3]          CHAR (1)        NULL,
    [ftfgt_actual_yn_4]          CHAR (1)        NULL,
    [ftfgt_actual_yn_5]          CHAR (1)        NULL,
    [ftfgt_actual_yn_6]          CHAR (1)        NULL,
    [ftfgt_actual_yn_7]          CHAR (1)        NULL,
    [ftfgt_actual_yn_8]          CHAR (1)        NULL,
    [ftfgt_actual_yn_9]          CHAR (1)        NULL,
    [ftfgt_actual_yn_10]         CHAR (1)        NULL,
    [ftfgt_actual_yn_11]         CHAR (1)        NULL,
    [ftfgt_actual_yn_12]         CHAR (1)        NULL,
    [ftfgt_actual_yn_13]         CHAR (1)        NULL,
    [ftfgt_actual_yn_14]         CHAR (1)        NULL,
    [ftfgt_actual_yn_15]         CHAR (1)        NULL,
    [ftfgt_actual_yn_16]         CHAR (1)        NULL,
    [ftfgt_actual_yn_17]         CHAR (1)        NULL,
    [ftfgt_actual_yn_18]         CHAR (1)        NULL,
    [ftfgt_actual_yn_19]         CHAR (1)        NULL,
    [ftfgt_actual_yn_20]         CHAR (1)        NULL,
    [ftfgt_actual_yn_21]         CHAR (1)        NULL,
    [ftfgt_actual_yn_22]         CHAR (1)        NULL,
    [ftfgt_actual_yn_23]         CHAR (1)        NULL,
    [ftfgt_actual_yn_24]         CHAR (1)        NULL,
    [ftfgt_actual_yn_25]         CHAR (1)        NULL,
    [ftfgt_actual_yn_26]         CHAR (1)        NULL,
    [ftfgt_actual_yn_27]         CHAR (1)        NULL,
    [ftfgt_actual_yn_28]         CHAR (1)        NULL,
    [ftfgt_actual_yn_29]         CHAR (1)        NULL,
    [ftfgt_actual_yn_30]         CHAR (1)        NULL,
    [ftfgt_actual_yn_31]         CHAR (1)        NULL,
    [ftfgt_actual_yn_32]         CHAR (1)        NULL,
    [ftfgt_actual_yn_33]         CHAR (1)        NULL,
    [ftfgt_actual_yn_34]         CHAR (1)        NULL,
    [ftfgt_actual_yn_35]         CHAR (1)        NULL,
    [ftfgt_actual_yn_36]         CHAR (1)        NULL,
    [ftfgt_actual_yn_37]         CHAR (1)        NULL,
    [ftfgt_actual_yn_38]         CHAR (1)        NULL,
    [ftfgt_actual_yn_39]         CHAR (1)        NULL,
    [ftfgt_actual_yn_40]         CHAR (1)        NULL,
    [ftfgt_batch_prt_order_1]    TINYINT         NULL,
    [ftfgt_batch_prt_order_2]    TINYINT         NULL,
    [ftfgt_batch_prt_order_3]    TINYINT         NULL,
    [ftfgt_batch_prt_order_4]    TINYINT         NULL,
    [ftfgt_batch_prt_order_5]    TINYINT         NULL,
    [ftfgt_batch_prt_order_6]    TINYINT         NULL,
    [ftfgt_batch_prt_order_7]    TINYINT         NULL,
    [ftfgt_batch_prt_order_8]    TINYINT         NULL,
    [ftfgt_batch_prt_order_9]    TINYINT         NULL,
    [ftfgt_batch_prt_order_10]   TINYINT         NULL,
    [ftfgt_batch_prt_order_11]   TINYINT         NULL,
    [ftfgt_batch_prt_order_12]   TINYINT         NULL,
    [ftfgt_batch_prt_order_13]   TINYINT         NULL,
    [ftfgt_batch_prt_order_14]   TINYINT         NULL,
    [ftfgt_batch_prt_order_15]   TINYINT         NULL,
    [ftfgt_batch_prt_order_16]   TINYINT         NULL,
    [ftfgt_batch_prt_order_17]   TINYINT         NULL,
    [ftfgt_batch_prt_order_18]   TINYINT         NULL,
    [ftfgt_batch_prt_order_19]   TINYINT         NULL,
    [ftfgt_batch_prt_order_20]   TINYINT         NULL,
    [ftfgt_batch_prt_order_21]   TINYINT         NULL,
    [ftfgt_batch_prt_order_22]   TINYINT         NULL,
    [ftfgt_batch_prt_order_23]   TINYINT         NULL,
    [ftfgt_batch_prt_order_24]   TINYINT         NULL,
    [ftfgt_batch_prt_order_25]   TINYINT         NULL,
    [ftfgt_batch_prt_order_26]   TINYINT         NULL,
    [ftfgt_batch_prt_order_27]   TINYINT         NULL,
    [ftfgt_batch_prt_order_28]   TINYINT         NULL,
    [ftfgt_batch_prt_order_29]   TINYINT         NULL,
    [ftfgt_batch_prt_order_30]   TINYINT         NULL,
    [ftfgt_batch_prt_order_31]   TINYINT         NULL,
    [ftfgt_batch_prt_order_32]   TINYINT         NULL,
    [ftfgt_batch_prt_order_33]   TINYINT         NULL,
    [ftfgt_batch_prt_order_34]   TINYINT         NULL,
    [ftfgt_batch_prt_order_35]   TINYINT         NULL,
    [ftfgt_batch_prt_order_36]   TINYINT         NULL,
    [ftfgt_batch_prt_order_37]   TINYINT         NULL,
    [ftfgt_batch_prt_order_38]   TINYINT         NULL,
    [ftfgt_batch_prt_order_39]   TINYINT         NULL,
    [ftfgt_batch_prt_order_40]   TINYINT         NULL,
    [ftfgt_item_type_1]          CHAR (1)        NULL,
    [ftfgt_item_type_2]          CHAR (1)        NULL,
    [ftfgt_item_type_3]          CHAR (1)        NULL,
    [ftfgt_item_type_4]          CHAR (1)        NULL,
    [ftfgt_item_type_5]          CHAR (1)        NULL,
    [ftfgt_item_type_6]          CHAR (1)        NULL,
    [ftfgt_item_type_7]          CHAR (1)        NULL,
    [ftfgt_item_type_8]          CHAR (1)        NULL,
    [ftfgt_item_type_9]          CHAR (1)        NULL,
    [ftfgt_item_type_10]         CHAR (1)        NULL,
    [ftfgt_item_type_11]         CHAR (1)        NULL,
    [ftfgt_item_type_12]         CHAR (1)        NULL,
    [ftfgt_item_type_13]         CHAR (1)        NULL,
    [ftfgt_item_type_14]         CHAR (1)        NULL,
    [ftfgt_item_type_15]         CHAR (1)        NULL,
    [ftfgt_item_type_16]         CHAR (1)        NULL,
    [ftfgt_item_type_17]         CHAR (1)        NULL,
    [ftfgt_item_type_18]         CHAR (1)        NULL,
    [ftfgt_item_type_19]         CHAR (1)        NULL,
    [ftfgt_item_type_20]         CHAR (1)        NULL,
    [ftfgt_item_type_21]         CHAR (1)        NULL,
    [ftfgt_item_type_22]         CHAR (1)        NULL,
    [ftfgt_item_type_23]         CHAR (1)        NULL,
    [ftfgt_item_type_24]         CHAR (1)        NULL,
    [ftfgt_item_type_25]         CHAR (1)        NULL,
    [ftfgt_item_type_26]         CHAR (1)        NULL,
    [ftfgt_item_type_27]         CHAR (1)        NULL,
    [ftfgt_item_type_28]         CHAR (1)        NULL,
    [ftfgt_item_type_29]         CHAR (1)        NULL,
    [ftfgt_item_type_30]         CHAR (1)        NULL,
    [ftfgt_item_type_31]         CHAR (1)        NULL,
    [ftfgt_item_type_32]         CHAR (1)        NULL,
    [ftfgt_item_type_33]         CHAR (1)        NULL,
    [ftfgt_item_type_34]         CHAR (1)        NULL,
    [ftfgt_item_type_35]         CHAR (1)        NULL,
    [ftfgt_item_type_36]         CHAR (1)        NULL,
    [ftfgt_item_type_37]         CHAR (1)        NULL,
    [ftfgt_item_type_38]         CHAR (1)        NULL,
    [ftfgt_item_type_39]         CHAR (1)        NULL,
    [ftfgt_item_type_40]         CHAR (1)        NULL,
    [ftfgt_hand_add_yn_1]        CHAR (1)        NULL,
    [ftfgt_hand_add_yn_2]        CHAR (1)        NULL,
    [ftfgt_hand_add_yn_3]        CHAR (1)        NULL,
    [ftfgt_hand_add_yn_4]        CHAR (1)        NULL,
    [ftfgt_hand_add_yn_5]        CHAR (1)        NULL,
    [ftfgt_hand_add_yn_6]        CHAR (1)        NULL,
    [ftfgt_hand_add_yn_7]        CHAR (1)        NULL,
    [ftfgt_hand_add_yn_8]        CHAR (1)        NULL,
    [ftfgt_hand_add_yn_9]        CHAR (1)        NULL,
    [ftfgt_hand_add_yn_10]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_11]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_12]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_13]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_14]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_15]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_16]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_17]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_18]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_19]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_20]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_21]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_22]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_23]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_24]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_25]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_26]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_27]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_28]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_29]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_30]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_31]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_32]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_33]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_34]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_35]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_36]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_37]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_38]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_39]       CHAR (1)        NULL,
    [ftfgt_hand_add_yn_40]       CHAR (1)        NULL,
    [ftfgt_no_acres]             DECIMAL (9, 2)  NULL,
    [ftfgt_blend_units]          CHAR (3)        NULL,
    [ftfgt_crop]                 CHAR (15)       NULL,
    [ftfgt_comment]              CHAR (30)       NULL,
    [ftfgt_n_prop_units]         DECIMAL (9, 2)  NULL,
    [ftfgt_p_prop_units]         DECIMAL (9, 2)  NULL,
    [ftfgt_k_prop_units]         DECIMAL (9, 2)  NULL,
    [ftfgt_s_prop_units]         DECIMAL (7, 2)  NULL,
    [ftfgt_mg_prop_units]        DECIMAL (7, 2)  NULL,
    [ftfgt_b_prop_units]         DECIMAL (7, 2)  NULL,
    [ftfgt_mn_prop_units]        DECIMAL (7, 2)  NULL,
    [ftfgt_zn_prop_units]        DECIMAL (7, 2)  NULL,
    [ftfgt_fe_prop_units]        DECIMAL (7, 2)  NULL,
    [ftfgt_cu_prop_units]        DECIMAL (7, 2)  NULL,
    [ftfgt_ca_prop_units]        DECIMAL (7, 2)  NULL,
    [ftfgt_lime_prop_units]      DECIMAL (7, 2)  NULL,
    [ftfgt_n_act_units]          DECIMAL (9, 2)  NULL,
    [ftfgt_p_act_units]          DECIMAL (9, 2)  NULL,
    [ftfgt_k_act_units]          DECIMAL (9, 2)  NULL,
    [ftfgt_s_act_units]          DECIMAL (7, 2)  NULL,
    [ftfgt_mg_act_units]         DECIMAL (7, 2)  NULL,
    [ftfgt_b_act_units]          DECIMAL (7, 2)  NULL,
    [ftfgt_mn_act_units]         DECIMAL (7, 2)  NULL,
    [ftfgt_zn_act_units]         DECIMAL (7, 2)  NULL,
    [ftfgt_fe_act_units]         DECIMAL (7, 2)  NULL,
    [ftfgt_cu_act_units]         DECIMAL (7, 2)  NULL,
    [ftfgt_ca_act_units]         DECIMAL (7, 2)  NULL,
    [ftfgt_lime_act_units]       DECIMAL (7, 2)  NULL,
    [ftfgt_guar_analysis]        CHAR (40)       NULL,
    [ftfgt_plant_food_analysis]  CHAR (40)       NULL,
    [ftfgt_pct_n]                DECIMAL (4, 1)  NULL,
    [ftfgt_pct_p]                DECIMAL (4, 1)  NULL,
    [ftfgt_pct_k]                DECIMAL (4, 1)  NULL,
    [ftfgt_pct_mg]               DECIMAL (3, 1)  NULL,
    [ftfgt_pct_b]                DECIMAL (3, 1)  NULL,
    [ftfgt_pct_mn]               DECIMAL (3, 1)  NULL,
    [ftfgt_pct_zn]               DECIMAL (3, 1)  NULL,
    [ftfgt_pct_s]                DECIMAL (3, 1)  NULL,
    [ftfgt_pct_fe]               DECIMAL (3, 1)  NULL,
    [ftfgt_pct_cu]               DECIMAL (3, 1)  NULL,
    [ftfgt_pct_ca]               DECIMAL (3, 1)  NULL,
    [ftfgt_pct_lime]             DECIMAL (3, 1)  NULL,
    [ftfgt_anticip_app_rev_dt]   INT             NULL,
    [ftfgt_order_analysis]       CHAR (30)       NULL,
    [ftfgt_crop_code]            CHAR (2)        NULL,
    [ftfgt_user_id]              CHAR (16)       NULL,
    [ftfgt_user_rev_dt]          INT             NULL,
    [A4GLIdentity]               NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_ftfgtmst] PRIMARY KEY NONCLUSTERED ([ftfgt_cus_no] ASC, [ftfgt_farm_no] ASC, [ftfgt_field_no] ASC, [ftfgt_ftitm_no] ASC, [ftfgt_loc_no] ASC, [ftfgt_guide_id] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iftfgtmst0]
    ON [dbo].[ftfgtmst]([ftfgt_cus_no] ASC, [ftfgt_farm_no] ASC, [ftfgt_field_no] ASC, [ftfgt_ftitm_no] ASC, [ftfgt_loc_no] ASC, [ftfgt_guide_id] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[ftfgtmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ftfgtmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ftfgtmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ftfgtmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ftfgtmst] TO PUBLIC
    AS [dbo];

