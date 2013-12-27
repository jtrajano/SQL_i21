CREATE TABLE [dbo].[pxselmst] (
    [pxsel_rpt_state]           CHAR (2)    NOT NULL,
    [pxsel_rpt_form]            CHAR (6)    NOT NULL,
    [pxsel_rpt_sched]           CHAR (4)    NOT NULL,
    [pxsel_rpt_pgm_name]        CHAR (8)    NULL,
    [pxsel_rpt_sched_name]      CHAR (78)   NULL,
    [pxsel_rpt_license_no]      CHAR (15)   NULL,
    [pxsel_beg_cus_no]          CHAR (10)   NULL,
    [pxsel_end_cus_no]          CHAR (10)   NULL,
    [pxsel_beg_itm_no]          CHAR (10)   NULL,
    [pxsel_end_itm_no]          CHAR (10)   NULL,
    [pxsel_beg_slsmn_id]        CHAR (3)    NULL,
    [pxsel_end_slsmn_id]        CHAR (3)    NULL,
    [pxsel_beg_rev_dt]          INT         NULL,
    [pxsel_end_rev_dt]          INT         NULL,
    [cus_stats_incl]            CHAR (5)    NULL,
    [pxsel_cus_tax_id]          CHAR (1)    NULL,
    [pxsel_system_ind]          CHAR (1)    NULL,
    [pxsel_print_order]         CHAR (1)    NULL,
    [pxsel_beg_tax_cls_id_incl] CHAR (2)    NULL,
    [pxsel_end_tax_cls_id_incl] CHAR (2)    NULL,
    [pxsel_beg_vnd_no]          CHAR (10)   NULL,
    [pxsel_end_vnd_no]          CHAR (10)   NULL,
    [pxsel_number_copies]       TINYINT     NULL,
    [pxsel_sel_pgm_name]        CHAR (8)    NULL,
    [pxsel_in_outbound_ind]     CHAR (1)    NULL,
    [pxsel_fet_exempt_yno]      CHAR (1)    NULL,
    [pxsel_set_exempt_yno]      CHAR (1)    NULL,
    [pxsel_sst_exempt_yno]      CHAR (1)    NULL,
    [pxsel_lc1_exempt_yno]      CHAR (1)    NULL,
    [pxsel_lc2_exempt_yno]      CHAR (1)    NULL,
    [pxsel_lc3_exempt_yno]      CHAR (1)    NULL,
    [pxsel_lc4_exempt_yno]      CHAR (1)    NULL,
    [pxsel_lc5_exempt_yno]      CHAR (1)    NULL,
    [pxsel_lc6_exempt_yno]      CHAR (1)    NULL,
    [pxsel_lc7_exempt_yno]      CHAR (1)    NULL,
    [pxsel_lc8_exempt_yno]      CHAR (1)    NULL,
    [pxsel_lc9_exempt_yno]      CHAR (1)    NULL,
    [pxsel_lc10_exempt_yno]     CHAR (1)    NULL,
    [pxsel_lc11_exempt_yno]     CHAR (1)    NULL,
    [pxsel_lc12_exempt_yno]     CHAR (1)    NULL,
    [pxsel_if_exempt_yno]       CHAR (1)    NULL,
    [cus_stats_excl]            CHAR (5)    NULL,
    [pxsel_detl_summ_toto]      CHAR (1)    NULL,
    [beg_tax_excl]              CHAR (2)    NULL,
    [end_tax_excl]              CHAR (2)    NULL,
    [pxsel_dyed_fuel_ynb]       CHAR (1)    NULL,
    [pxsel_beg_local1]          CHAR (3)    NULL,
    [pxsel_end_local1]          CHAR (3)    NULL,
    [pxsel_beg_local2]          CHAR (3)    NULL,
    [pxsel_end_local2]          CHAR (3)    NULL,
    [beg_cus_st_incl]           CHAR (2)    NULL,
    [end_cus_st_incl]           CHAR (2)    NULL,
    [beg_cus_st_excl]           CHAR (2)    NULL,
    [end_cus_st_excl]           CHAR (2)    NULL,
    [beg_vnd_st_incl]           CHAR (2)    NULL,
    [end_vnd_st_incl]           CHAR (2)    NULL,
    [beg_vnd_st_excl]           CHAR (2)    NULL,
    [end_vnd_st_excl]           CHAR (2)    NULL,
    [pxsel_frt_yno]             CHAR (1)    NULL,
    [pxsel_system_ind_excl]     CHAR (1)    NULL,
    [pxsel_port_land_ind_pl]    CHAR (1)    NULL,
    [pxsel_beg_class]           CHAR (3)    NULL,
    [pxsel_end_class]           CHAR (3)    NULL,
    [vnd_stats_incl]            CHAR (5)    NULL,
    [vnd_stats_excl]            CHAR (5)    NULL,
    [pxsel_user_id]             CHAR (16)   NULL,
    [pxsel_user_rev_dt]         INT         NULL,
    [A4GLIdentity]              NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    [pxsel_i21_report_title]    CHAR (100)  NULL,
    CONSTRAINT [k_pxselmst] PRIMARY KEY NONCLUSTERED ([pxsel_rpt_state] ASC, [pxsel_rpt_form] ASC, [pxsel_rpt_sched] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Ipxselmst0]
    ON [dbo].[pxselmst]([pxsel_rpt_state] ASC, [pxsel_rpt_form] ASC, [pxsel_rpt_sched] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[pxselmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[pxselmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[pxselmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[pxselmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[pxselmst] TO PUBLIC
    AS [dbo];

