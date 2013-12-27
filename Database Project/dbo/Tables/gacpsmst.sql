CREATE TABLE [dbo].[gacpsmst] (
    [gacps_pur_sls_ind]     CHAR (1)        NOT NULL,
    [gacps_cus_no]          CHAR (10)       NOT NULL,
    [gacps_com_cd]          CHAR (3)        NOT NULL,
    [gacps_stor_1]          DECIMAL (11, 3) NULL,
    [gacps_stor_2]          DECIMAL (11, 3) NULL,
    [gacps_stor_3]          DECIMAL (11, 3) NULL,
    [gacps_stor_4]          DECIMAL (11, 3) NULL,
    [gacps_stor_5]          DECIMAL (11, 3) NULL,
    [gacps_stor_6]          DECIMAL (11, 3) NULL,
    [gacps_stor_7]          DECIMAL (11, 3) NULL,
    [gacps_stor_8]          DECIMAL (11, 3) NULL,
    [gacps_bas_dlvry]       DECIMAL (11, 3) NULL,
    [gacps_cb_dlvry]        DECIMAL (11, 3) NULL,
    [gacps_prc_cnt]         DECIMAL (11, 3) NULL,
    [gacps_bas_cnt]         DECIMAL (11, 3) NULL,
    [gacps_hta_cnt]         DECIMAL (11, 3) NULL,
    [gacps_cb_cnt]          DECIMAL (11, 3) NULL,
    [gacps_un_cnt]          DECIMAL (11, 3) NULL,
    [gacps_in_transit]      DECIMAL (11, 3) NULL,
    [gacps_coll_rcpt]       DECIMAL (11, 3) NULL,
    [gacps_pybl_rcbl_un]    DECIMAL (11, 3) NULL,
    [gacps_pybl_rcbl_amt]   DECIMAL (11, 2) NULL,
    [gacps_target_un]       DECIMAL (11, 3) NULL,
    [gacps_ytd_un]          DECIMAL (11, 3) NULL,
    [gacps_ytd_disc_amt]    DECIMAL (11, 2) NULL,
    [gacps_ytd_stor_amt]    DECIMAL (11, 2) NULL,
    [gacps_ytd_tax_amt]     DECIMAL (11, 2) NULL,
    [gacps_ytd_fees_amt]    DECIMAL (9, 2)  NULL,
    [gacps_ytd_stl_amt]     DECIMAL (11, 2) NULL,
    [gacps_ytd_int_amt]     DECIMAL (11, 2) NULL,
    [gacps_ytd_adj_amt]     DECIMAL (11, 2) NULL,
    [gacps_ytd_frt_amt]     DECIMAL (11, 2) NULL,
    [gacps_pending_takeout] DECIMAL (11, 3) NULL,
    [A4GLIdentity]          NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gacpsmst] PRIMARY KEY NONCLUSTERED ([gacps_pur_sls_ind] ASC, [gacps_cus_no] ASC, [gacps_com_cd] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Igacpsmst0]
    ON [dbo].[gacpsmst]([gacps_pur_sls_ind] ASC, [gacps_cus_no] ASC, [gacps_com_cd] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gacpsmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gacpsmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gacpsmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gacpsmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[gacpsmst] TO PUBLIC
    AS [dbo];

