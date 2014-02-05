﻿CREATE TABLE [dbo].[gaxfrmst] (
    [gaxfr_pur_sls_ind]      CHAR (1)        NOT NULL,
    [gaxfr_loc_no]           CHAR (3)        NOT NULL,
    [gaxfr_com_cd]           CHAR (3)        NOT NULL,
    [gaxfr_tic_no]           CHAR (10)       NOT NULL,
    [gaxfr_to_loc_no]        CHAR (3)        NOT NULL,
    [gaxfr_tie_breaker]      SMALLINT        NOT NULL,
    [gaxfr_comment]          CHAR (30)       NULL,
    [gaxfr_rev_dt]           INT             NULL,
    [gaxfr_no_un]            DECIMAL (11, 3) NULL,
    [gaxfr_frt_no]           CHAR (10)       NULL,
    [gaxfr_frt_no_un]        DECIMAL (11, 3) NULL,
    [gaxfr_frt_un_rt]        DECIMAL (9, 5)  NULL,
    [gaxfr_frt_gl_acct]      DECIMAL (16, 8) NULL,
    [gaxfr_un_prc]           DECIMAL (9, 5)  NULL,
    [gaxfr_cost]             DECIMAL (11, 2) NULL,
    [gaxfr_tic_comment]      CHAR (30)       NULL,
    [gaxfr_tot_shrk_pct_wgt] DECIMAL (7, 4)  NULL,
    [gaxfr_disc_schd_no]     TINYINT         NULL,
    [gaxfr_disc_cd_1]        CHAR (2)        NULL,
    [gaxfr_disc_cd_2]        CHAR (2)        NULL,
    [gaxfr_disc_cd_3]        CHAR (2)        NULL,
    [gaxfr_disc_cd_4]        CHAR (2)        NULL,
    [gaxfr_disc_cd_5]        CHAR (2)        NULL,
    [gaxfr_disc_cd_6]        CHAR (2)        NULL,
    [gaxfr_disc_cd_7]        CHAR (2)        NULL,
    [gaxfr_disc_cd_8]        CHAR (2)        NULL,
    [gaxfr_disc_cd_9]        CHAR (2)        NULL,
    [gaxfr_disc_cd_10]       CHAR (2)        NULL,
    [gaxfr_disc_cd_11]       CHAR (2)        NULL,
    [gaxfr_disc_cd_12]       CHAR (2)        NULL,
    [gaxfr_reading_1]        DECIMAL (7, 3)  NULL,
    [gaxfr_reading_2]        DECIMAL (7, 3)  NULL,
    [gaxfr_reading_3]        DECIMAL (7, 3)  NULL,
    [gaxfr_reading_4]        DECIMAL (7, 3)  NULL,
    [gaxfr_reading_5]        DECIMAL (7, 3)  NULL,
    [gaxfr_reading_6]        DECIMAL (7, 3)  NULL,
    [gaxfr_reading_7]        DECIMAL (7, 3)  NULL,
    [gaxfr_reading_8]        DECIMAL (7, 3)  NULL,
    [gaxfr_reading_9]        DECIMAL (7, 3)  NULL,
    [gaxfr_reading_10]       DECIMAL (7, 3)  NULL,
    [gaxfr_reading_11]       DECIMAL (7, 3)  NULL,
    [gaxfr_reading_12]       DECIMAL (7, 3)  NULL,
    [gaxfr_un_disc_amt_1]    DECIMAL (9, 6)  NULL,
    [gaxfr_un_disc_amt_2]    DECIMAL (9, 6)  NULL,
    [gaxfr_un_disc_amt_3]    DECIMAL (9, 6)  NULL,
    [gaxfr_un_disc_amt_4]    DECIMAL (9, 6)  NULL,
    [gaxfr_un_disc_amt_5]    DECIMAL (9, 6)  NULL,
    [gaxfr_un_disc_amt_6]    DECIMAL (9, 6)  NULL,
    [gaxfr_un_disc_amt_7]    DECIMAL (9, 6)  NULL,
    [gaxfr_un_disc_amt_8]    DECIMAL (9, 6)  NULL,
    [gaxfr_un_disc_amt_9]    DECIMAL (9, 6)  NULL,
    [gaxfr_un_disc_amt_10]   DECIMAL (9, 6)  NULL,
    [gaxfr_un_disc_amt_11]   DECIMAL (9, 6)  NULL,
    [gaxfr_un_disc_amt_12]   DECIMAL (9, 6)  NULL,
    [gaxfr_shrk_what_1]      CHAR (1)        NULL,
    [gaxfr_shrk_what_2]      CHAR (1)        NULL,
    [gaxfr_shrk_what_3]      CHAR (1)        NULL,
    [gaxfr_shrk_what_4]      CHAR (1)        NULL,
    [gaxfr_shrk_what_5]      CHAR (1)        NULL,
    [gaxfr_shrk_what_6]      CHAR (1)        NULL,
    [gaxfr_shrk_what_7]      CHAR (1)        NULL,
    [gaxfr_shrk_what_8]      CHAR (1)        NULL,
    [gaxfr_shrk_what_9]      CHAR (1)        NULL,
    [gaxfr_shrk_what_10]     CHAR (1)        NULL,
    [gaxfr_shrk_what_11]     CHAR (1)        NULL,
    [gaxfr_shrk_what_12]     CHAR (1)        NULL,
    [gaxfr_shrk_pct_1]       DECIMAL (7, 4)  NULL,
    [gaxfr_shrk_pct_2]       DECIMAL (7, 4)  NULL,
    [gaxfr_shrk_pct_3]       DECIMAL (7, 4)  NULL,
    [gaxfr_shrk_pct_4]       DECIMAL (7, 4)  NULL,
    [gaxfr_shrk_pct_5]       DECIMAL (7, 4)  NULL,
    [gaxfr_shrk_pct_6]       DECIMAL (7, 4)  NULL,
    [gaxfr_shrk_pct_7]       DECIMAL (7, 4)  NULL,
    [gaxfr_shrk_pct_8]       DECIMAL (7, 4)  NULL,
    [gaxfr_shrk_pct_9]       DECIMAL (7, 4)  NULL,
    [gaxfr_shrk_pct_10]      DECIMAL (7, 4)  NULL,
    [gaxfr_shrk_pct_11]      DECIMAL (7, 4)  NULL,
    [gaxfr_shrk_pct_12]      DECIMAL (7, 4)  NULL,
    [gaxfr_from_bin_no]      CHAR (5)        NULL,
    [gaxfr_to_bin_no]        CHAR (5)        NULL,
    [gaxfr_audit_no]         CHAR (4)        NULL,
    [gaxfr_user_id]          CHAR (16)       NULL,
    [gaxfr_user_rev_dt]      INT             NULL,
    [A4GLIdentity]           NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gaxfrmst] PRIMARY KEY NONCLUSTERED ([gaxfr_pur_sls_ind] ASC, [gaxfr_loc_no] ASC, [gaxfr_com_cd] ASC, [gaxfr_tic_no] ASC, [gaxfr_to_loc_no] ASC, [gaxfr_tie_breaker] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igaxfrmst0]
    ON [dbo].[gaxfrmst]([gaxfr_pur_sls_ind] ASC, [gaxfr_loc_no] ASC, [gaxfr_com_cd] ASC, [gaxfr_tic_no] ASC, [gaxfr_to_loc_no] ASC, [gaxfr_tie_breaker] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[gaxfrmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gaxfrmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gaxfrmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gaxfrmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gaxfrmst] TO PUBLIC
    AS [dbo];

