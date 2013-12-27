CREATE TABLE [dbo].[gahstmst] (
    [gahst_pur_sls_ind]    CHAR (1)        NOT NULL,
    [gahst_cus_no]         CHAR (10)       NOT NULL,
    [gahst_com_cd]         CHAR (3)        NOT NULL,
    [gahst_loc_no]         CHAR (3)        NOT NULL,
    [gahst_cnt_no]         CHAR (8)        NOT NULL,
    [gahst_cnt_seq_no]     SMALLINT        NOT NULL,
    [gahst_cnt_sub_no]     SMALLINT        NOT NULL,
    [gahst_hst_seq_no]     INT             NOT NULL,
    [gahst_dlvry_loc_no]   CHAR (3)        NULL,
    [gahst_dlvry_cus_no]   CHAR (10)       NULL,
    [gahst_farm_no]        CHAR (4)        NULL,
    [gahst_tic_no]         CHAR (10)       NULL,
    [gahst_dlvry_rev_dt]   INT             NULL,
    [gahst_no_un]          DECIMAL (11, 3) NULL,
    [gahst_adj_comment]    CHAR (30)       NULL,
    [gahst_adj_yn]         CHAR (1)        NULL,
    [gahst_adj_bal]        DECIMAL (11, 3) NULL,
    [gahst_rail_ref_no]    INT             NULL,
    [gahst_rail_load_seq]  SMALLINT        NULL,
    [gahst_rail_split_seq] TINYINT         NULL,
    [gahst_user_id]        CHAR (16)       NULL,
    [gahst_user_rev_dt]    INT             NULL,
    [A4GLIdentity]         NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gahstmst] PRIMARY KEY NONCLUSTERED ([gahst_pur_sls_ind] ASC, [gahst_cus_no] ASC, [gahst_com_cd] ASC, [gahst_loc_no] ASC, [gahst_cnt_no] ASC, [gahst_cnt_seq_no] ASC, [gahst_cnt_sub_no] ASC, [gahst_hst_seq_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Igahstmst0]
    ON [dbo].[gahstmst]([gahst_pur_sls_ind] ASC, [gahst_cus_no] ASC, [gahst_com_cd] ASC, [gahst_loc_no] ASC, [gahst_cnt_no] ASC, [gahst_cnt_seq_no] ASC, [gahst_cnt_sub_no] ASC, [gahst_hst_seq_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gahstmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gahstmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gahstmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gahstmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[gahstmst] TO PUBLIC
    AS [dbo];

