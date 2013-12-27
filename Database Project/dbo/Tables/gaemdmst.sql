CREATE TABLE [dbo].[gaemdmst] (
    [gaemd_com_cd]        CHAR (3)        NOT NULL,
    [gaemd_currency]      CHAR (3)        NOT NULL,
    [gaemd_mkt_zone]      CHAR (3)        NOT NULL,
    [gaemd_loc_no]        CHAR (3)        NOT NULL,
    [gaemd_rev_dt]        INT             NOT NULL,
    [gaemd_bot]           CHAR (1)        NOT NULL,
    [gaemd_bot_opt]       CHAR (5)        NOT NULL,
    [gaemd_rec_id]        CHAR (1)        NOT NULL,
    [gaemd_pur_sls_ind]   CHAR (1)        NOT NULL,
    [gaemd_rec_sub_id]    CHAR (1)        NOT NULL,
    [gaemd_trk_rail_ind]  CHAR (1)        NOT NULL,
    [gaemd_detail_key]    CHAR (38)       NOT NULL,
    [gaemd_no_un]         DECIMAL (11, 3) NULL,
    [gaemd_un_prc]        DECIMAL (9, 5)  NULL,
    [gaemd_un_basis]      DECIMAL (9, 5)  NULL,
    [gaemd_mois_disc_amt] DECIMAL (11, 2) NULL,
    [gaemd_oth_disc_amt]  DECIMAL (11, 2) NULL,
    [gaemd_ext_amt]       DECIMAL (11, 2) NULL,
    [gaemd_eom_prc]       DECIMAL (9, 5)  NULL,
    [gaemd_eom_basis]     DECIMAL (7, 5)  NULL,
    [gaemd_cus_no]        CHAR (10)       NULL,
    [gaemd_tic_no]        CHAR (10)       NULL,
    [gaemd_cnt_no]        CHAR (8)        NULL,
    [gaemd_cnt_seq_no]    SMALLINT        NULL,
    [gaemd_cnt_sub_seq]   SMALLINT        NULL,
    [gaemd_rec_type]      CHAR (1)        NULL,
    [gaemd_tie_breaker]   SMALLINT        NULL,
    [A4GLIdentity]        NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gaemdmst] PRIMARY KEY NONCLUSTERED ([gaemd_com_cd] ASC, [gaemd_currency] ASC, [gaemd_mkt_zone] ASC, [gaemd_loc_no] ASC, [gaemd_rev_dt] ASC, [gaemd_bot] ASC, [gaemd_bot_opt] ASC, [gaemd_rec_id] ASC, [gaemd_pur_sls_ind] ASC, [gaemd_rec_sub_id] ASC, [gaemd_trk_rail_ind] ASC, [gaemd_detail_key] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Igaemdmst0]
    ON [dbo].[gaemdmst]([gaemd_com_cd] ASC, [gaemd_currency] ASC, [gaemd_mkt_zone] ASC, [gaemd_loc_no] ASC, [gaemd_rev_dt] ASC, [gaemd_bot] ASC, [gaemd_bot_opt] ASC, [gaemd_rec_id] ASC, [gaemd_pur_sls_ind] ASC, [gaemd_rec_sub_id] ASC, [gaemd_trk_rail_ind] ASC, [gaemd_detail_key] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gaemdmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gaemdmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gaemdmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gaemdmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[gaemdmst] TO PUBLIC
    AS [dbo];

