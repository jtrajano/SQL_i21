CREATE TABLE [dbo].[galdsmst] (
    [galds_loc_no]             CHAR (3)        NOT NULL,
    [galds_load_no]            CHAR (8)        NOT NULL,
    [galds_pur_sls_ind]        CHAR (1)        NOT NULL,
    [galds_ag_ga_ind]          CHAR (1)        NULL,
    [galds_com_cd]             CHAR (3)        NOT NULL,
    [galds_itm_no]             CHAR (13)       NULL,
    [galds_cus_ref_no]         CHAR (15)       NULL,
    [galds_sched_un]           DECIMAL (11, 3) NULL,
    [galds_sched_rev_dt]       INT             NULL,
    [galds_frt_cus_no]         CHAR (10)       NOT NULL,
    [galds_frt_rt]             DECIMAL (9, 4)  NULL,
    [galds_bill_frt_rt]        DECIMAL (9, 4)  NULL,
    [galds_surcharge_pct]      DECIMAL (5, 2)  NULL,
    [galds_frt_miles]          SMALLINT        NULL,
    [galds_cus_no]             CHAR (10)       NOT NULL,
    [galds_ship_to]            CHAR (4)        NULL,
    [galds_cnt_no]             CHAR (8)        NOT NULL,
    [galds_cnt_seq_no]         SMALLINT        NULL,
    [galds_cnt_sub_no]         SMALLINT        NULL,
    [galds_cnt_loc]            CHAR (3)        NULL,
    [galds_tic_loc_no]         CHAR (3)        NULL,
    [galds_tic_no]             CHAR (10)       NULL,
    [galds_dlvd_rev_dt]        INT             NULL,
    [galds_dlvd_un]            DECIMAL (11, 3) NULL,
    [galds_dlvd_un_prc]        DECIMAL (9, 5)  NULL,
    [galds_printed_yn]         CHAR (1)        NULL,
    [galds_in_proc_ind]        CHAR (1)        NULL,
    [galds_in_proc_ticket]     CHAR (10)       NULL,
    [galds_in_proc_ticket_loc] CHAR (3)        NULL,
    [galds_equip_type]         TINYINT         NULL,
    [galds_dir_trans_ld_yn]    CHAR (1)        NULL,
    [galds_booking_no]         CHAR (15)       NULL,
    [galds_trans_ld_fees]      DECIMAL (7, 2)  NULL,
    [galds_cont_fees]          DECIMAL (7, 2)  NULL,
    [galds_broker_fees]        DECIMAL (7, 2)  NULL,
    [galds_bank_fees]          DECIMAL (7, 2)  NULL,
    [galds_phyto_fees]         DECIMAL (7, 2)  NULL,
    [galds_misc_fees]          DECIMAL (7, 2)  NULL,
    [galds_bill_surcharge_pct] DECIMAL (5, 2)  NULL,
    [galds_user_id]            CHAR (16)       NULL,
    [galds_user_rev_dt]        INT             NULL,
    [A4GLIdentity]             NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_galdsmst] PRIMARY KEY NONCLUSTERED ([galds_loc_no] ASC, [galds_load_no] ASC, [galds_pur_sls_ind] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igaldsmst0]
    ON [dbo].[galdsmst]([galds_loc_no] ASC, [galds_load_no] ASC, [galds_pur_sls_ind] ASC);


GO
CREATE NONCLUSTERED INDEX [Igaldsmst1]
    ON [dbo].[galdsmst]([galds_pur_sls_ind] ASC, [galds_com_cd] ASC, [galds_cus_no] ASC, [galds_cnt_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Igaldsmst2]
    ON [dbo].[galdsmst]([galds_frt_cus_no] ASC);

