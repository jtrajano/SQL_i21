CREATE TABLE [dbo].[gacarmst] (
    [gacar_pur_sls_ind]         CHAR (1)        NOT NULL,
    [gacar_rail_ref_no]         INT             NOT NULL,
    [gacar_load_seq]            SMALLINT        NOT NULL,
    [gacar_split_seq]           TINYINT         NOT NULL,
    [gacar_car_no]              CHAR (10)       NOT NULL,
    [gacar_ship_rev_dt]         INT             NOT NULL,
    [gacar_adv_ivc_no]          CHAR (8)        NULL,
    [gacar_final_ivc_no]        CHAR (8)        NULL,
    [gacar_bot_prc]             DECIMAL (9, 5)  NULL,
    [gacar_avg_prc]             DECIMAL (9, 5)  NULL,
    [gacar_tot_net_un]          DECIMAL (11, 3) NULL,
    [gacar_tot_shrk_un]         DECIMAL (11, 3) NULL,
    [gacar_tot_stl_amt]         DECIMAL (11, 2) NULL,
    [gacar_tot_disc_amt]        DECIMAL (9, 2)  NULL,
    [gacar_tot_shrk_pct_wgt]    DECIMAL (7, 4)  NULL,
    [gacar_tot_net_wgt]         INT             NULL,
    [gacar_adv_amt]             DECIMAL (11, 2) NULL,
    [gacar_adj_amt]             DECIMAL (11, 2) NULL,
    [gacar_adj_comment]         CHAR (30)       NULL,
    [gacar_final_due_amt]       DECIMAL (11, 2) NULL,
    [gacar_cnt_no_un]           DECIMAL (11, 3) NULL,
    [gacar_cnt_bot_basis]       DECIMAL (9, 5)  NULL,
    [gacar_cnt_as_is_disc]      DECIMAL (9, 5)  NULL,
    [gacar_broker_no]           CHAR (10)       NULL,
    [gacar_broker_un_rt]        DECIMAL (9, 5)  NULL,
    [gacar_frt_cus_1]           CHAR (10)       NULL,
    [gacar_frt_cus_2]           CHAR (10)       NULL,
    [gacar_frt_cus_3]           CHAR (10)       NULL,
    [gacar_frt_type_1]          CHAR (1)        NULL,
    [gacar_frt_type_2]          CHAR (1)        NULL,
    [gacar_frt_type_3]          CHAR (1)        NULL,
    [gacar_frt_rt_1]            DECIMAL (11, 5) NULL,
    [gacar_frt_rt_2]            DECIMAL (11, 5) NULL,
    [gacar_frt_rt_3]            DECIMAL (11, 5) NULL,
    [gacar_avg_reading_1]       DECIMAL (7, 3)  NULL,
    [gacar_avg_reading_2]       DECIMAL (7, 3)  NULL,
    [gacar_avg_reading_3]       DECIMAL (7, 3)  NULL,
    [gacar_avg_reading_4]       DECIMAL (7, 3)  NULL,
    [gacar_avg_reading_5]       DECIMAL (7, 3)  NULL,
    [gacar_avg_reading_6]       DECIMAL (7, 3)  NULL,
    [gacar_avg_reading_7]       DECIMAL (7, 3)  NULL,
    [gacar_avg_reading_8]       DECIMAL (7, 3)  NULL,
    [gacar_avg_reading_9]       DECIMAL (7, 3)  NULL,
    [gacar_avg_reading_10]      DECIMAL (7, 3)  NULL,
    [gacar_avg_reading_11]      DECIMAL (7, 3)  NULL,
    [gacar_avg_reading_12]      DECIMAL (7, 3)  NULL,
    [gacar_avg_un_disc_amt_1]   DECIMAL (9, 6)  NULL,
    [gacar_avg_un_disc_amt_2]   DECIMAL (9, 6)  NULL,
    [gacar_avg_un_disc_amt_3]   DECIMAL (9, 6)  NULL,
    [gacar_avg_un_disc_amt_4]   DECIMAL (9, 6)  NULL,
    [gacar_avg_un_disc_amt_5]   DECIMAL (9, 6)  NULL,
    [gacar_avg_un_disc_amt_6]   DECIMAL (9, 6)  NULL,
    [gacar_avg_un_disc_amt_7]   DECIMAL (9, 6)  NULL,
    [gacar_avg_un_disc_amt_8]   DECIMAL (9, 6)  NULL,
    [gacar_avg_un_disc_amt_9]   DECIMAL (9, 6)  NULL,
    [gacar_avg_un_disc_amt_10]  DECIMAL (9, 6)  NULL,
    [gacar_avg_un_disc_amt_11]  DECIMAL (9, 6)  NULL,
    [gacar_avg_un_disc_amt_12]  DECIMAL (9, 6)  NULL,
    [gacar_avg_shrk_what_1]     CHAR (1)        NULL,
    [gacar_avg_shrk_what_2]     CHAR (1)        NULL,
    [gacar_avg_shrk_what_3]     CHAR (1)        NULL,
    [gacar_avg_shrk_what_4]     CHAR (1)        NULL,
    [gacar_avg_shrk_what_5]     CHAR (1)        NULL,
    [gacar_avg_shrk_what_6]     CHAR (1)        NULL,
    [gacar_avg_shrk_what_7]     CHAR (1)        NULL,
    [gacar_avg_shrk_what_8]     CHAR (1)        NULL,
    [gacar_avg_shrk_what_9]     CHAR (1)        NULL,
    [gacar_avg_shrk_what_10]    CHAR (1)        NULL,
    [gacar_avg_shrk_what_11]    CHAR (1)        NULL,
    [gacar_avg_shrk_what_12]    CHAR (1)        NULL,
    [gacar_avg_shrk_pct_1]      DECIMAL (7, 4)  NULL,
    [gacar_avg_shrk_pct_2]      DECIMAL (7, 4)  NULL,
    [gacar_avg_shrk_pct_3]      DECIMAL (7, 4)  NULL,
    [gacar_avg_shrk_pct_4]      DECIMAL (7, 4)  NULL,
    [gacar_avg_shrk_pct_5]      DECIMAL (7, 4)  NULL,
    [gacar_avg_shrk_pct_6]      DECIMAL (7, 4)  NULL,
    [gacar_avg_shrk_pct_7]      DECIMAL (7, 4)  NULL,
    [gacar_avg_shrk_pct_8]      DECIMAL (7, 4)  NULL,
    [gacar_avg_shrk_pct_9]      DECIMAL (7, 4)  NULL,
    [gacar_avg_shrk_pct_10]     DECIMAL (7, 4)  NULL,
    [gacar_avg_shrk_pct_11]     DECIMAL (7, 4)  NULL,
    [gacar_avg_shrk_pct_12]     DECIMAL (7, 4)  NULL,
    [gacar_tot_fees]            DECIMAL (9, 2)  NULL,
    [gacar_adj_posted_yn]       CHAR (1)        NULL,
    [gacar_ivc_rev_dt]          INT             NULL,
    [gacar_hdr_currency]        CHAR (3)        NULL,
    [gacar_hdr_currency_rt]     DECIMAL (15, 8) NULL,
    [gacar_hdr_currency_cnt]    CHAR (8)        NULL,
    [gacar_direct_rail_xref_no] CHAR (8)        NULL,
    [gacar_frt_currency]        CHAR (3)        NULL,
    [gacar_frt_currency_rt]     DECIMAL (15, 8) NULL,
    [gacar_frt_currency_cnt]    CHAR (8)        NULL,
    [gacar_billed_adv_yn]       CHAR (1)        NULL,
    [gacar_origin_state]        CHAR (2)        NULL,
    [gacar_dest_state]          CHAR (2)        NULL,
    [gacar_user_id]             CHAR (16)       NULL,
    [gacar_user_rev_dt]         INT             NULL,
    [A4GLIdentity]              NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gacarmst] PRIMARY KEY NONCLUSTERED ([gacar_pur_sls_ind] ASC, [gacar_rail_ref_no] ASC, [gacar_load_seq] ASC, [gacar_split_seq] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Igacarmst0]
    ON [dbo].[gacarmst]([gacar_pur_sls_ind] ASC, [gacar_rail_ref_no] ASC, [gacar_load_seq] ASC, [gacar_split_seq] ASC);


GO
CREATE NONCLUSTERED INDEX [Igacarmst1]
    ON [dbo].[gacarmst]([gacar_car_no] ASC, [gacar_ship_rev_dt] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gacarmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gacarmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gacarmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gacarmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[gacarmst] TO PUBLIC
    AS [dbo];

