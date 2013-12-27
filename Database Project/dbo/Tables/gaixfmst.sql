CREATE TABLE [dbo].[gaixfmst] (
    [gaixf_com_cd]         CHAR (3)        NOT NULL,
    [gaixf_tic_no]         CHAR (10)       NOT NULL,
    [gaixf_in_out_ind]     CHAR (1)        NOT NULL,
    [gaixf_loc_no]         CHAR (3)        NOT NULL,
    [gaixf_seq_no]         TINYINT         NOT NULL,
    [gaixf_match_yn]       CHAR (1)        NULL,
    [gaixf_match_tic_no]   CHAR (10)       NOT NULL,
    [gaixf_match_loc_no]   CHAR (3)        NOT NULL,
    [gaixf_match_seq_no]   TINYINT         NOT NULL,
    [gaixf_ship_rev_dt]    INT             NULL,
    [gaixf_gross_wgt]      DECIMAL (13, 3) NULL,
    [gaixf_tare_wgt]       DECIMAL (13, 3) NULL,
    [gaixf_un]             DECIMAL (13, 3) NULL,
    [gaixf_comment]        CHAR (30)       NULL,
    [gaixf_bin_no]         CHAR (5)        NULL,
    [gaixf_trkr_no]        CHAR (10)       NULL,
    [gaixf_disc_schd_no]   TINYINT         NULL,
    [gaixf_disc_cd_1]      CHAR (2)        NULL,
    [gaixf_disc_cd_2]      CHAR (2)        NULL,
    [gaixf_disc_cd_3]      CHAR (2)        NULL,
    [gaixf_disc_cd_4]      CHAR (2)        NULL,
    [gaixf_disc_cd_5]      CHAR (2)        NULL,
    [gaixf_disc_cd_6]      CHAR (2)        NULL,
    [gaixf_disc_cd_7]      CHAR (2)        NULL,
    [gaixf_disc_cd_8]      CHAR (2)        NULL,
    [gaixf_disc_cd_9]      CHAR (2)        NULL,
    [gaixf_disc_cd_10]     CHAR (2)        NULL,
    [gaixf_disc_cd_11]     CHAR (2)        NULL,
    [gaixf_disc_cd_12]     CHAR (2)        NULL,
    [gaixf_reading_1]      DECIMAL (7, 3)  NULL,
    [gaixf_reading_2]      DECIMAL (7, 3)  NULL,
    [gaixf_reading_3]      DECIMAL (7, 3)  NULL,
    [gaixf_reading_4]      DECIMAL (7, 3)  NULL,
    [gaixf_reading_5]      DECIMAL (7, 3)  NULL,
    [gaixf_reading_6]      DECIMAL (7, 3)  NULL,
    [gaixf_reading_7]      DECIMAL (7, 3)  NULL,
    [gaixf_reading_8]      DECIMAL (7, 3)  NULL,
    [gaixf_reading_9]      DECIMAL (7, 3)  NULL,
    [gaixf_reading_10]     DECIMAL (7, 3)  NULL,
    [gaixf_reading_11]     DECIMAL (7, 3)  NULL,
    [gaixf_reading_12]     DECIMAL (7, 3)  NULL,
    [gaixf_disc_calc_1]    CHAR (1)        NULL,
    [gaixf_disc_calc_2]    CHAR (1)        NULL,
    [gaixf_disc_calc_3]    CHAR (1)        NULL,
    [gaixf_disc_calc_4]    CHAR (1)        NULL,
    [gaixf_disc_calc_5]    CHAR (1)        NULL,
    [gaixf_disc_calc_6]    CHAR (1)        NULL,
    [gaixf_disc_calc_7]    CHAR (1)        NULL,
    [gaixf_disc_calc_8]    CHAR (1)        NULL,
    [gaixf_disc_calc_9]    CHAR (1)        NULL,
    [gaixf_disc_calc_10]   CHAR (1)        NULL,
    [gaixf_disc_calc_11]   CHAR (1)        NULL,
    [gaixf_disc_calc_12]   CHAR (1)        NULL,
    [gaixf_un_disc_amt_1]  DECIMAL (9, 6)  NULL,
    [gaixf_un_disc_amt_2]  DECIMAL (9, 6)  NULL,
    [gaixf_un_disc_amt_3]  DECIMAL (9, 6)  NULL,
    [gaixf_un_disc_amt_4]  DECIMAL (9, 6)  NULL,
    [gaixf_un_disc_amt_5]  DECIMAL (9, 6)  NULL,
    [gaixf_un_disc_amt_6]  DECIMAL (9, 6)  NULL,
    [gaixf_un_disc_amt_7]  DECIMAL (9, 6)  NULL,
    [gaixf_un_disc_amt_8]  DECIMAL (9, 6)  NULL,
    [gaixf_un_disc_amt_9]  DECIMAL (9, 6)  NULL,
    [gaixf_un_disc_amt_10] DECIMAL (9, 6)  NULL,
    [gaixf_un_disc_amt_11] DECIMAL (9, 6)  NULL,
    [gaixf_un_disc_amt_12] DECIMAL (9, 6)  NULL,
    [gaixf_shrk_what_1]    CHAR (1)        NULL,
    [gaixf_shrk_what_2]    CHAR (1)        NULL,
    [gaixf_shrk_what_3]    CHAR (1)        NULL,
    [gaixf_shrk_what_4]    CHAR (1)        NULL,
    [gaixf_shrk_what_5]    CHAR (1)        NULL,
    [gaixf_shrk_what_6]    CHAR (1)        NULL,
    [gaixf_shrk_what_7]    CHAR (1)        NULL,
    [gaixf_shrk_what_8]    CHAR (1)        NULL,
    [gaixf_shrk_what_9]    CHAR (1)        NULL,
    [gaixf_shrk_what_10]   CHAR (1)        NULL,
    [gaixf_shrk_what_11]   CHAR (1)        NULL,
    [gaixf_shrk_what_12]   CHAR (1)        NULL,
    [gaixf_shrk_pct_1]     DECIMAL (7, 4)  NULL,
    [gaixf_shrk_pct_2]     DECIMAL (7, 4)  NULL,
    [gaixf_shrk_pct_3]     DECIMAL (7, 4)  NULL,
    [gaixf_shrk_pct_4]     DECIMAL (7, 4)  NULL,
    [gaixf_shrk_pct_5]     DECIMAL (7, 4)  NULL,
    [gaixf_shrk_pct_6]     DECIMAL (7, 4)  NULL,
    [gaixf_shrk_pct_7]     DECIMAL (7, 4)  NULL,
    [gaixf_shrk_pct_8]     DECIMAL (7, 4)  NULL,
    [gaixf_shrk_pct_9]     DECIMAL (7, 4)  NULL,
    [gaixf_shrk_pct_10]    DECIMAL (7, 4)  NULL,
    [gaixf_shrk_pct_11]    DECIMAL (7, 4)  NULL,
    [gaixf_shrk_pct_12]    DECIMAL (7, 4)  NULL,
    [gaixf_user_id]        CHAR (16)       NULL,
    [gaixf_user_rev_dt]    INT             NULL,
    [A4GLIdentity]         NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gaixfmst] PRIMARY KEY NONCLUSTERED ([gaixf_com_cd] ASC, [gaixf_tic_no] ASC, [gaixf_in_out_ind] ASC, [gaixf_loc_no] ASC, [gaixf_seq_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Igaixfmst0]
    ON [dbo].[gaixfmst]([gaixf_com_cd] ASC, [gaixf_tic_no] ASC, [gaixf_in_out_ind] ASC, [gaixf_loc_no] ASC, [gaixf_seq_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Igaixfmst1]
    ON [dbo].[gaixfmst]([gaixf_com_cd] ASC, [gaixf_match_tic_no] ASC, [gaixf_match_loc_no] ASC, [gaixf_match_seq_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gaixfmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gaixfmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gaixfmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gaixfmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[gaixfmst] TO PUBLIC
    AS [dbo];

