CREATE TABLE [dbo].[gaphsmst] (
    [gaphs_pur_sls_ind]    CHAR (1)        NOT NULL,
    [gaphs_cus_no]         CHAR (10)       NOT NULL,
    [gaphs_com_cd]         CHAR (3)        NOT NULL,
    [gaphs_spl_no]         CHAR (4)        NOT NULL,
    [gaphs_dlvry_rev_dt]   INT             NOT NULL,
    [gaphs_loc_no]         CHAR (3)        NOT NULL,
    [gaphs_tic_no]         CHAR (10)       NOT NULL,
    [gaphs_tie_breaker]    SMALLINT        NOT NULL,
    [gaphs_cus_ref_no]     CHAR (15)       NOT NULL,
    [gaphs_gross_wgt]      DECIMAL (13, 3) NULL,
    [gaphs_tare_wgt]       DECIMAL (13, 3) NULL,
    [gaphs_gross_un]       DECIMAL (11, 3) NULL,
    [gaphs_wet_un]         DECIMAL (11, 3) NULL,
    [gaphs_net_un]         DECIMAL (11, 3) NULL,
    [gaphs_fees]           DECIMAL (7, 2)  NULL,
    [gaphs_disc_schd_no]   TINYINT         NULL,
    [gaphs_tic_comment]    CHAR (30)       NULL,
    [gaphs_disc_cd_1]      CHAR (2)        NULL,
    [gaphs_disc_cd_2]      CHAR (2)        NULL,
    [gaphs_disc_cd_3]      CHAR (2)        NULL,
    [gaphs_disc_cd_4]      CHAR (2)        NULL,
    [gaphs_disc_cd_5]      CHAR (2)        NULL,
    [gaphs_disc_cd_6]      CHAR (2)        NULL,
    [gaphs_disc_cd_7]      CHAR (2)        NULL,
    [gaphs_disc_cd_8]      CHAR (2)        NULL,
    [gaphs_disc_cd_9]      CHAR (2)        NULL,
    [gaphs_disc_cd_10]     CHAR (2)        NULL,
    [gaphs_disc_cd_11]     CHAR (2)        NULL,
    [gaphs_disc_cd_12]     CHAR (2)        NULL,
    [gaphs_reading_1]      DECIMAL (7, 3)  NULL,
    [gaphs_reading_2]      DECIMAL (7, 3)  NULL,
    [gaphs_reading_3]      DECIMAL (7, 3)  NULL,
    [gaphs_reading_4]      DECIMAL (7, 3)  NULL,
    [gaphs_reading_5]      DECIMAL (7, 3)  NULL,
    [gaphs_reading_6]      DECIMAL (7, 3)  NULL,
    [gaphs_reading_7]      DECIMAL (7, 3)  NULL,
    [gaphs_reading_8]      DECIMAL (7, 3)  NULL,
    [gaphs_reading_9]      DECIMAL (7, 3)  NULL,
    [gaphs_reading_10]     DECIMAL (7, 3)  NULL,
    [gaphs_reading_11]     DECIMAL (7, 3)  NULL,
    [gaphs_reading_12]     DECIMAL (7, 3)  NULL,
    [gaphs_disc_calc_1]    CHAR (1)        NULL,
    [gaphs_disc_calc_2]    CHAR (1)        NULL,
    [gaphs_disc_calc_3]    CHAR (1)        NULL,
    [gaphs_disc_calc_4]    CHAR (1)        NULL,
    [gaphs_disc_calc_5]    CHAR (1)        NULL,
    [gaphs_disc_calc_6]    CHAR (1)        NULL,
    [gaphs_disc_calc_7]    CHAR (1)        NULL,
    [gaphs_disc_calc_8]    CHAR (1)        NULL,
    [gaphs_disc_calc_9]    CHAR (1)        NULL,
    [gaphs_disc_calc_10]   CHAR (1)        NULL,
    [gaphs_disc_calc_11]   CHAR (1)        NULL,
    [gaphs_disc_calc_12]   CHAR (1)        NULL,
    [gaphs_un_disc_amt_1]  DECIMAL (9, 6)  NULL,
    [gaphs_un_disc_amt_2]  DECIMAL (9, 6)  NULL,
    [gaphs_un_disc_amt_3]  DECIMAL (9, 6)  NULL,
    [gaphs_un_disc_amt_4]  DECIMAL (9, 6)  NULL,
    [gaphs_un_disc_amt_5]  DECIMAL (9, 6)  NULL,
    [gaphs_un_disc_amt_6]  DECIMAL (9, 6)  NULL,
    [gaphs_un_disc_amt_7]  DECIMAL (9, 6)  NULL,
    [gaphs_un_disc_amt_8]  DECIMAL (9, 6)  NULL,
    [gaphs_un_disc_amt_9]  DECIMAL (9, 6)  NULL,
    [gaphs_un_disc_amt_10] DECIMAL (9, 6)  NULL,
    [gaphs_un_disc_amt_11] DECIMAL (9, 6)  NULL,
    [gaphs_un_disc_amt_12] DECIMAL (9, 6)  NULL,
    [gaphs_shrk_what_1]    CHAR (1)        NULL,
    [gaphs_shrk_what_2]    CHAR (1)        NULL,
    [gaphs_shrk_what_3]    CHAR (1)        NULL,
    [gaphs_shrk_what_4]    CHAR (1)        NULL,
    [gaphs_shrk_what_5]    CHAR (1)        NULL,
    [gaphs_shrk_what_6]    CHAR (1)        NULL,
    [gaphs_shrk_what_7]    CHAR (1)        NULL,
    [gaphs_shrk_what_8]    CHAR (1)        NULL,
    [gaphs_shrk_what_9]    CHAR (1)        NULL,
    [gaphs_shrk_what_10]   CHAR (1)        NULL,
    [gaphs_shrk_what_11]   CHAR (1)        NULL,
    [gaphs_shrk_what_12]   CHAR (1)        NULL,
    [gaphs_shrk_pct_1]     DECIMAL (7, 4)  NULL,
    [gaphs_shrk_pct_2]     DECIMAL (7, 4)  NULL,
    [gaphs_shrk_pct_3]     DECIMAL (7, 4)  NULL,
    [gaphs_shrk_pct_4]     DECIMAL (7, 4)  NULL,
    [gaphs_shrk_pct_5]     DECIMAL (7, 4)  NULL,
    [gaphs_shrk_pct_6]     DECIMAL (7, 4)  NULL,
    [gaphs_shrk_pct_7]     DECIMAL (7, 4)  NULL,
    [gaphs_shrk_pct_8]     DECIMAL (7, 4)  NULL,
    [gaphs_shrk_pct_9]     DECIMAL (7, 4)  NULL,
    [gaphs_shrk_pct_10]    DECIMAL (7, 4)  NULL,
    [gaphs_shrk_pct_11]    DECIMAL (7, 4)  NULL,
    [gaphs_shrk_pct_12]    DECIMAL (7, 4)  NULL,
    [gaphs_trkr_un_rt]     DECIMAL (9, 5)  NULL,
    [gaphs_trkr_no]        CHAR (10)       NULL,
    [gaphs_wgt_accepted]   DECIMAL (13, 3) NULL,
    [gaphs_bin_no]         CHAR (5)        NOT NULL,
    [gaphs_user_id]        CHAR (16)       NULL,
    [gaphs_user_rev_dt]    INT             NULL,
    [A4GLIdentity]         NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gaphsmst] PRIMARY KEY NONCLUSTERED ([gaphs_pur_sls_ind] ASC, [gaphs_cus_no] ASC, [gaphs_com_cd] ASC, [gaphs_spl_no] ASC, [gaphs_dlvry_rev_dt] ASC, [gaphs_loc_no] ASC, [gaphs_tic_no] ASC, [gaphs_tie_breaker] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igaphsmst0]
    ON [dbo].[gaphsmst]([gaphs_pur_sls_ind] ASC, [gaphs_cus_no] ASC, [gaphs_com_cd] ASC, [gaphs_spl_no] ASC, [gaphs_dlvry_rev_dt] ASC, [gaphs_loc_no] ASC, [gaphs_tic_no] ASC, [gaphs_tie_breaker] ASC);


GO
CREATE NONCLUSTERED INDEX [Igaphsmst1]
    ON [dbo].[gaphsmst]([gaphs_pur_sls_ind] ASC, [gaphs_tic_no] ASC, [gaphs_loc_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Igaphsmst2]
    ON [dbo].[gaphsmst]([gaphs_loc_no] ASC, [gaphs_com_cd] ASC, [gaphs_bin_no] ASC, [gaphs_dlvry_rev_dt] ASC, [gaphs_pur_sls_ind] ASC);


GO
CREATE NONCLUSTERED INDEX [Igaphsmst3]
    ON [dbo].[gaphsmst]([gaphs_cus_ref_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[gaphsmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gaphsmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gaphsmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gaphsmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gaphsmst] TO PUBLIC
    AS [dbo];

