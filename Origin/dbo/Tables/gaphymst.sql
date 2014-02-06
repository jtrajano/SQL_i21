CREATE TABLE [dbo].[gaphymst] (
    [gaphy_loc_no]         CHAR (3)        NOT NULL,
    [gaphy_bin_no]         CHAR (5)        NOT NULL,
    [gaphy_desc]           CHAR (15)       NULL,
    [gaphy_eff_depth]      DECIMAL (7, 2)  NULL,
    [gaphy_com_cd]         CHAR (3)        NULL,
    [gaphy_un_per_ft]      DECIMAL (7, 3)  NULL,
    [gaphy_residual_un]    DECIMAL (9, 3)  NULL,
    [gaphy_pack_factor]    DECIMAL (7, 6)  NULL,
    [gaphy_air_space]      DECIMAL (7, 2)  NULL,
    [gaphy_disc_cd_1]      CHAR (2)        NULL,
    [gaphy_disc_cd_2]      CHAR (2)        NULL,
    [gaphy_disc_cd_3]      CHAR (2)        NULL,
    [gaphy_disc_cd_4]      CHAR (2)        NULL,
    [gaphy_disc_cd_5]      CHAR (2)        NULL,
    [gaphy_disc_cd_6]      CHAR (2)        NULL,
    [gaphy_disc_cd_7]      CHAR (2)        NULL,
    [gaphy_disc_cd_8]      CHAR (2)        NULL,
    [gaphy_disc_cd_9]      CHAR (2)        NULL,
    [gaphy_disc_cd_10]     CHAR (2)        NULL,
    [gaphy_disc_cd_11]     CHAR (2)        NULL,
    [gaphy_disc_cd_12]     CHAR (2)        NULL,
    [gaphy_reading_1]      DECIMAL (7, 3)  NULL,
    [gaphy_reading_2]      DECIMAL (7, 3)  NULL,
    [gaphy_reading_3]      DECIMAL (7, 3)  NULL,
    [gaphy_reading_4]      DECIMAL (7, 3)  NULL,
    [gaphy_reading_5]      DECIMAL (7, 3)  NULL,
    [gaphy_reading_6]      DECIMAL (7, 3)  NULL,
    [gaphy_reading_7]      DECIMAL (7, 3)  NULL,
    [gaphy_reading_8]      DECIMAL (7, 3)  NULL,
    [gaphy_reading_9]      DECIMAL (7, 3)  NULL,
    [gaphy_reading_10]     DECIMAL (7, 3)  NULL,
    [gaphy_reading_11]     DECIMAL (7, 3)  NULL,
    [gaphy_reading_12]     DECIMAL (7, 3)  NULL,
    [gaphy_un_disc_amt_1]  DECIMAL (9, 6)  NULL,
    [gaphy_un_disc_amt_2]  DECIMAL (9, 6)  NULL,
    [gaphy_un_disc_amt_3]  DECIMAL (9, 6)  NULL,
    [gaphy_un_disc_amt_4]  DECIMAL (9, 6)  NULL,
    [gaphy_un_disc_amt_5]  DECIMAL (9, 6)  NULL,
    [gaphy_un_disc_amt_6]  DECIMAL (9, 6)  NULL,
    [gaphy_un_disc_amt_7]  DECIMAL (9, 6)  NULL,
    [gaphy_un_disc_amt_8]  DECIMAL (9, 6)  NULL,
    [gaphy_un_disc_amt_9]  DECIMAL (9, 6)  NULL,
    [gaphy_un_disc_amt_10] DECIMAL (9, 6)  NULL,
    [gaphy_un_disc_amt_11] DECIMAL (9, 6)  NULL,
    [gaphy_un_disc_amt_12] DECIMAL (9, 6)  NULL,
    [gaphy_un_prc]         DECIMAL (9, 5)  NULL,
    [gaphy_disc_schd_no]   TINYINT         NULL,
    [gaphy_un_bal]         DECIMAL (13, 3) NULL,
    [gaphy_user_id]        CHAR (16)       NULL,
    [gaphy_user_rev_dt]    CHAR (8)        NULL,
    [A4GLIdentity]         NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gaphymst] PRIMARY KEY NONCLUSTERED ([gaphy_loc_no] ASC, [gaphy_bin_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igaphymst0]
    ON [dbo].[gaphymst]([gaphy_loc_no] ASC, [gaphy_bin_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[gaphymst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gaphymst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gaphymst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gaphymst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gaphymst] TO PUBLIC
    AS [dbo];

