CREATE TABLE [dbo].[gaeommst] (
    [gaeom_com_cd]           CHAR (3)        NOT NULL,
    [gaeom_currency]         CHAR (3)        NOT NULL,
    [gaeom_mkt_zone]         CHAR (3)        NOT NULL,
    [gaeom_loc_no]           CHAR (3)        NOT NULL,
    [gaeom_rev_dt]           INT             NOT NULL,
    [gaeom_bot]              CHAR (1)        NOT NULL,
    [gaeom_bot_opt]          CHAR (5)        NOT NULL,
    [gaeom_rec_id]           CHAR (1)        NOT NULL,
    [gaeom_pur_sls_ind]      CHAR (1)        NOT NULL,
    [gaeom_rec_sub_id]       CHAR (1)        NOT NULL,
    [gaeom_trk_rail_ind]     CHAR (1)        NOT NULL,
    [gaeom_no_un]            DECIMAL (11, 3) NULL,
    [gaeom_un_prc]           DECIMAL (9, 5)  NULL,
    [gaeom_un_basis_or_disc] DECIMAL (9, 5)  NULL,
    [gaeom_mois_disc_amt]    DECIMAL (11, 2) NULL,
    [gaeom_oth_disc_amt]     DECIMAL (11, 2) NULL,
    [gaeom_ext_amt]          DECIMAL (11, 2) NULL,
    [gaeom_last_eod_run_no]  SMALLINT        NULL,
    [A4GLIdentity]           NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gaeommst] PRIMARY KEY NONCLUSTERED ([gaeom_com_cd] ASC, [gaeom_currency] ASC, [gaeom_mkt_zone] ASC, [gaeom_loc_no] ASC, [gaeom_rev_dt] ASC, [gaeom_bot] ASC, [gaeom_bot_opt] ASC, [gaeom_rec_id] ASC, [gaeom_pur_sls_ind] ASC, [gaeom_rec_sub_id] ASC, [gaeom_trk_rail_ind] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igaeommst0]
    ON [dbo].[gaeommst]([gaeom_com_cd] ASC, [gaeom_currency] ASC, [gaeom_mkt_zone] ASC, [gaeom_loc_no] ASC, [gaeom_rev_dt] ASC, [gaeom_bot] ASC, [gaeom_bot_opt] ASC, [gaeom_rec_id] ASC, [gaeom_pur_sls_ind] ASC, [gaeom_rec_sub_id] ASC, [gaeom_trk_rail_ind] ASC);

