CREATE TABLE [dbo].[gaposmst] (
    [gapos_com_cd]             CHAR (3)        NOT NULL,
    [gapos_loc_no]             CHAR (3)        NOT NULL,
    [gapos_in_house]           DECIMAL (13, 3) NULL,
    [gapos_offsite]            DECIMAL (13, 3) NULL,
    [gapos_offsite_dp]         DECIMAL (13, 3) NULL,
    [gapos_pur_in_transit]     DECIMAL (13, 3) NULL,
    [gapos_sls_in_transit]     DECIMAL (13, 3) NULL,
    [gapos_stor_1]             DECIMAL (13, 3) NULL,
    [gapos_stor_2]             DECIMAL (13, 3) NULL,
    [gapos_stor_3]             DECIMAL (13, 3) NULL,
    [gapos_stor_4]             DECIMAL (13, 3) NULL,
    [gapos_stor_5]             DECIMAL (13, 3) NULL,
    [gapos_stor_6]             DECIMAL (13, 3) NULL,
    [gapos_stor_7]             DECIMAL (13, 3) NULL,
    [gapos_stor_8]             DECIMAL (13, 3) NULL,
    [gapos_pur_basis_dlvry]    DECIMAL (13, 3) NULL,
    [gapos_sls_basis_dlvry]    DECIMAL (13, 3) NULL,
    [gapos_pur_cb_bas_dlv]     DECIMAL (13, 3) NULL,
    [gapos_sls_cb_bas_dlv]     DECIMAL (13, 3) NULL,
    [gapos_pur_prc_cnt]        DECIMAL (13, 3) NULL,
    [gapos_pur_basis_cnt]      DECIMAL (13, 3) NULL,
    [gapos_pur_hta_cnt]        DECIMAL (13, 3) NULL,
    [gapos_pur_cb_cnt]         DECIMAL (13, 3) NULL,
    [gapos_sls_prc_cnt]        DECIMAL (13, 3) NULL,
    [gapos_sls_basis_cnt]      DECIMAL (13, 3) NULL,
    [gapos_sls_hta_cnt]        DECIMAL (13, 3) NULL,
    [gapos_sls_cb_cnt]         DECIMAL (13, 3) NULL,
    [gapos_hedge]              DECIMAL (13, 3) NULL,
    [gapos_net_pybl_amt]       DECIMAL (13, 2) NULL,
    [gapos_pybl_un]            DECIMAL (13, 3) NULL,
    [gapos_net_rcbl_amt]       DECIMAL (13, 2) NULL,
    [gapos_rcbl_un]            DECIMAL (13, 3) NULL,
    [gapos_pur_coll_rcpt]      DECIMAL (13, 3) NULL,
    [gapos_sls_coll_rcpt]      DECIMAL (13, 3) NULL,
    [gapos_stor_od]            DECIMAL (13, 3) NULL,
    [gapos_in_in_house]        DECIMAL (13, 3) NULL,
    [gapos_in_offsite]         DECIMAL (13, 3) NULL,
    [gapos_in_offsite_dp]      DECIMAL (13, 3) NULL,
    [gapos_in_pur_in_transit]  DECIMAL (13, 3) NULL,
    [gapos_in_sls_in_transit]  DECIMAL (13, 3) NULL,
    [gapos_in_stor_1]          DECIMAL (13, 3) NULL,
    [gapos_in_stor_2]          DECIMAL (13, 3) NULL,
    [gapos_in_stor_3]          DECIMAL (13, 3) NULL,
    [gapos_in_stor_4]          DECIMAL (13, 3) NULL,
    [gapos_in_stor_5]          DECIMAL (13, 3) NULL,
    [gapos_in_stor_6]          DECIMAL (13, 3) NULL,
    [gapos_in_stor_7]          DECIMAL (13, 3) NULL,
    [gapos_in_stor_8]          DECIMAL (13, 3) NULL,
    [gapos_in_p_basis_dlvry]   DECIMAL (13, 3) NULL,
    [gapos_in_s_basis_dlvry]   DECIMAL (13, 3) NULL,
    [gapos_in_pur_cb_bas_dlv]  DECIMAL (13, 3) NULL,
    [gapos_in_sls_cb_bas_dlv]  DECIMAL (13, 3) NULL,
    [gapos_in_pur_prc_cnt]     DECIMAL (13, 3) NULL,
    [gapos_in_pur_basis_cnt]   DECIMAL (13, 3) NULL,
    [gapos_in_pur_hta_cnt]     DECIMAL (13, 3) NULL,
    [gapos_in_pur_cb_cnt]      DECIMAL (13, 3) NULL,
    [gapos_in_sls_prc_cnt]     DECIMAL (13, 3) NULL,
    [gapos_in_sls_basis_cnt]   DECIMAL (13, 3) NULL,
    [gapos_in_sls_hta_cnt]     DECIMAL (13, 3) NULL,
    [gapos_in_sls_cb_cnt]      DECIMAL (13, 3) NULL,
    [gapos_in_hedge]           DECIMAL (13, 3) NULL,
    [gapos_in_net_pybl_amt]    DECIMAL (13, 2) NULL,
    [gapos_in_pybl_un]         DECIMAL (13, 3) NULL,
    [gapos_in_net_rcbl_amt]    DECIMAL (13, 2) NULL,
    [gapos_in_rcbl_un]         DECIMAL (13, 3) NULL,
    [gapos_in_pur_coll_rcpt]   DECIMAL (13, 3) NULL,
    [gapos_in_sls_coll_rcpt]   DECIMAL (13, 3) NULL,
    [gapos_in_stor_od]         DECIMAL (13, 3) NULL,
    [gapos_out_in_house]       DECIMAL (13, 3) NULL,
    [gapos_out_offsite]        DECIMAL (13, 3) NULL,
    [gapos_out_offsite_dp]     DECIMAL (13, 3) NULL,
    [gapos_out_pur_in_transit] DECIMAL (13, 3) NULL,
    [gapos_out_sls_in_transit] DECIMAL (13, 3) NULL,
    [gapos_out_stor_1]         DECIMAL (13, 3) NULL,
    [gapos_out_stor_2]         DECIMAL (13, 3) NULL,
    [gapos_out_stor_3]         DECIMAL (13, 3) NULL,
    [gapos_out_stor_4]         DECIMAL (13, 3) NULL,
    [gapos_out_stor_5]         DECIMAL (13, 3) NULL,
    [gapos_out_stor_6]         DECIMAL (13, 3) NULL,
    [gapos_out_stor_7]         DECIMAL (13, 3) NULL,
    [gapos_out_stor_8]         DECIMAL (13, 3) NULL,
    [gapos_out_p_basis_dlvry]  DECIMAL (13, 3) NULL,
    [gapos_out_s_basis_dlvry]  DECIMAL (13, 3) NULL,
    [gapos_out_pur_cb_bas_dlv] DECIMAL (13, 3) NULL,
    [gapos_out_sls_cb_bas_dlv] DECIMAL (13, 3) NULL,
    [gapos_out_pur_prc_cnt]    DECIMAL (13, 3) NULL,
    [gapos_out_pur_basis_cnt]  DECIMAL (13, 3) NULL,
    [gapos_out_pur_hta_cnt]    DECIMAL (13, 3) NULL,
    [gapos_out_pur_cb_cnt]     DECIMAL (13, 3) NULL,
    [gapos_out_sls_prc_cnt]    DECIMAL (13, 3) NULL,
    [gapos_out_sls_basis_cnt]  DECIMAL (13, 3) NULL,
    [gapos_out_sls_hta_cnt]    DECIMAL (13, 3) NULL,
    [gapos_out_sls_cb_cnt]     DECIMAL (13, 3) NULL,
    [gapos_out_hedge]          DECIMAL (13, 3) NULL,
    [gapos_out_net_pybl_amt]   DECIMAL (13, 2) NULL,
    [gapos_out_pybl_un]        DECIMAL (13, 3) NULL,
    [gapos_out_net_rcbl_amt]   DECIMAL (13, 2) NULL,
    [gapos_out_rcbl_un]        DECIMAL (13, 3) NULL,
    [gapos_out_pur_coll_rcpt]  DECIMAL (13, 3) NULL,
    [gapos_out_sls_coll_rcpt]  DECIMAL (13, 3) NULL,
    [gapos_out_stor_od]        DECIMAL (13, 3) NULL,
    [gapos_adj_in_house]       DECIMAL (13, 3) NULL,
    [gapos_adj_offsite]        DECIMAL (13, 3) NULL,
    [gapos_adj_offsite_dp]     DECIMAL (13, 3) NULL,
    [gapos_adj_pur_in_transit] DECIMAL (13, 3) NULL,
    [gapos_adj_sls_in_transit] DECIMAL (13, 3) NULL,
    [gapos_adj_stor_1]         DECIMAL (13, 3) NULL,
    [gapos_adj_stor_2]         DECIMAL (13, 3) NULL,
    [gapos_adj_stor_3]         DECIMAL (13, 3) NULL,
    [gapos_adj_stor_4]         DECIMAL (13, 3) NULL,
    [gapos_adj_stor_5]         DECIMAL (13, 3) NULL,
    [gapos_adj_stor_6]         DECIMAL (13, 3) NULL,
    [gapos_adj_stor_7]         DECIMAL (13, 3) NULL,
    [gapos_adj_stor_8]         DECIMAL (13, 3) NULL,
    [gapos_adj_p_basis_dlvry]  DECIMAL (13, 3) NULL,
    [gapos_adj_s_basis_dlvry]  DECIMAL (13, 3) NULL,
    [gapos_adj_pur_cb_bas_dlv] DECIMAL (13, 3) NULL,
    [gapos_adj_sls_cb_bas_dlv] DECIMAL (13, 3) NULL,
    [gapos_adj_pur_prc_cnt]    DECIMAL (13, 3) NULL,
    [gapos_adj_pur_basis_cnt]  DECIMAL (13, 3) NULL,
    [gapos_adj_pur_hta_cnt]    DECIMAL (13, 3) NULL,
    [gapos_adj_pur_cb_cnt]     DECIMAL (13, 3) NULL,
    [gapos_adj_sls_prc_cnt]    DECIMAL (13, 3) NULL,
    [gapos_adj_sls_basis_cnt]  DECIMAL (13, 3) NULL,
    [gapos_adj_sls_hta_cnt]    DECIMAL (13, 3) NULL,
    [gapos_adj_sls_cb_cnt]     DECIMAL (13, 3) NULL,
    [gapos_adj_hedge]          DECIMAL (13, 3) NULL,
    [gapos_adj_net_pybl_amt]   DECIMAL (13, 2) NULL,
    [gapos_adj_pybl_un]        DECIMAL (13, 3) NULL,
    [gapos_adj_net_rcbl_amt]   DECIMAL (13, 2) NULL,
    [gapos_adj_rcbl_un]        DECIMAL (13, 3) NULL,
    [gapos_adj_pur_coll_rcpt]  DECIMAL (13, 3) NULL,
    [gapos_adj_sls_coll_rcpt]  DECIMAL (13, 3) NULL,
    [gapos_adj_stor_od]        DECIMAL (13, 3) NULL,
    [gapos_ptd_cash]           DECIMAL (13, 3) NULL,
    [gapos_ptd_cnt_fill]       DECIMAL (13, 3) NULL,
    [gapos_ptd_stor_add_1]     DECIMAL (13, 3) NULL,
    [gapos_ptd_stor_add_2]     DECIMAL (13, 3) NULL,
    [gapos_ptd_stor_add_3]     DECIMAL (13, 3) NULL,
    [gapos_ptd_stor_add_4]     DECIMAL (13, 3) NULL,
    [gapos_ptd_stor_add_5]     DECIMAL (13, 3) NULL,
    [gapos_ptd_stor_add_6]     DECIMAL (13, 3) NULL,
    [gapos_ptd_stor_add_7]     DECIMAL (13, 3) NULL,
    [gapos_ptd_stor_add_8]     DECIMAL (13, 3) NULL,
    [gapos_last_eod_rev_dt]    INT             NULL,
    [A4GLIdentity]             NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gaposmst] PRIMARY KEY NONCLUSTERED ([gapos_com_cd] ASC, [gapos_loc_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Igaposmst0]
    ON [dbo].[gaposmst]([gapos_com_cd] ASC, [gapos_loc_no] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Igaposmst1]
    ON [dbo].[gaposmst]([gapos_loc_no] ASC, [gapos_com_cd] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gaposmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gaposmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gaposmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gaposmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[gaposmst] TO PUBLIC
    AS [dbo];

