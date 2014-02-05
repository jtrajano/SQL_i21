CREATE TABLE [dbo].[gapaxmst] (
    [gapax_pur_sls_ind]        CHAR (1)        NOT NULL,
    [gapax_loc_no]             CHAR (3)        NOT NULL,
    [gapax_com_cd]             CHAR (3)        NOT NULL,
    [gapax_rev_dt]             INT             NOT NULL,
    [gapax_tie_breaker]        SMALLINT        NOT NULL,
    [gapax_adj_comment]        CHAR (40)       NULL,
    [gapax_adj_in_house]       DECIMAL (13, 3) NULL,
    [gapax_adj_offsite]        DECIMAL (13, 3) NULL,
    [gapax_adj_offsite_dp]     DECIMAL (13, 3) NULL,
    [gapax_adj_pur_in_transit] DECIMAL (13, 3) NULL,
    [gapax_adj_sls_in_transit] DECIMAL (13, 3) NULL,
    [gapax_adj_stor_1]         DECIMAL (13, 3) NULL,
    [gapax_adj_stor_2]         DECIMAL (13, 3) NULL,
    [gapax_adj_stor_3]         DECIMAL (13, 3) NULL,
    [gapax_adj_stor_4]         DECIMAL (13, 3) NULL,
    [gapax_adj_stor_5]         DECIMAL (13, 3) NULL,
    [gapax_adj_stor_6]         DECIMAL (13, 3) NULL,
    [gapax_adj_stor_7]         DECIMAL (13, 3) NULL,
    [gapax_adj_stor_8]         DECIMAL (13, 3) NULL,
    [gapax_adj_pur_bas_dlv]    DECIMAL (13, 3) NULL,
    [gapax_adj_sls_bas_dlv]    DECIMAL (13, 3) NULL,
    [gapax_pur_cb_bas_dlv]     DECIMAL (13, 3) NULL,
    [gapax_sls_cb_bas_dlv]     DECIMAL (13, 3) NULL,
    [gapax_adj_pur_prc_cnt]    DECIMAL (13, 3) NULL,
    [gapax_adj_pur_bas_cnt]    DECIMAL (13, 3) NULL,
    [gapax_adj_pur_hta_cnt]    DECIMAL (13, 3) NULL,
    [gapax_adj_pur_cb_cnt]     DECIMAL (13, 3) NULL,
    [gapax_adj_sls_prc_cnt]    DECIMAL (13, 3) NULL,
    [gapax_adj_sls_bas_cnt]    DECIMAL (13, 3) NULL,
    [gapax_adj_sls_hta_cnt]    DECIMAL (13, 3) NULL,
    [gapax_adj_sls_cb_cnt]     DECIMAL (13, 3) NULL,
    [gapax_adj_hedge]          DECIMAL (13, 3) NULL,
    [gapax_adj_net_pybl_amt]   DECIMAL (13, 2) NULL,
    [gapax_adj_pybl_un]        DECIMAL (13, 3) NULL,
    [gapax_adj_net_rcbl_amt]   DECIMAL (13, 2) NULL,
    [gapax_adj_rcbl_un]        DECIMAL (13, 3) NULL,
    [gapax_adj_pur_coll_rcpt]  DECIMAL (13, 3) NULL,
    [gapax_adj_sls_coll_rcpt]  DECIMAL (13, 3) NULL,
    [gapax_adj_stor_od]        DECIMAL (13, 3) NULL,
    [gapax_adj_audit_no]       CHAR (4)        NULL,
    [gapax_adj_user_id]        CHAR (16)       NULL,
    [gapax_adj_user_rev_dt]    INT             NULL,
    [A4GLIdentity]             NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gapaxmst] PRIMARY KEY NONCLUSTERED ([gapax_pur_sls_ind] ASC, [gapax_loc_no] ASC, [gapax_com_cd] ASC, [gapax_rev_dt] ASC, [gapax_tie_breaker] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igapaxmst0]
    ON [dbo].[gapaxmst]([gapax_pur_sls_ind] ASC, [gapax_loc_no] ASC, [gapax_com_cd] ASC, [gapax_rev_dt] ASC, [gapax_tie_breaker] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[gapaxmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gapaxmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gapaxmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gapaxmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gapaxmst] TO PUBLIC
    AS [dbo];

