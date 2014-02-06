CREATE TABLE [dbo].[glfypmst] (
    [glfyp_yr]          SMALLINT    NOT NULL,
    [glfyp_beg_date_1]  INT         NULL,
    [glfyp_beg_date_2]  INT         NULL,
    [glfyp_beg_date_3]  INT         NULL,
    [glfyp_beg_date_4]  INT         NULL,
    [glfyp_beg_date_5]  INT         NULL,
    [glfyp_beg_date_6]  INT         NULL,
    [glfyp_beg_date_7]  INT         NULL,
    [glfyp_beg_date_8]  INT         NULL,
    [glfyp_beg_date_9]  INT         NULL,
    [glfyp_beg_date_10] INT         NULL,
    [glfyp_beg_date_11] INT         NULL,
    [glfyp_beg_date_12] INT         NULL,
    [glfyp_beg_date_13] INT         NULL,
    [glfyp_end_date_1]  INT         NULL,
    [glfyp_end_date_2]  INT         NULL,
    [glfyp_end_date_3]  INT         NULL,
    [glfyp_end_date_4]  INT         NULL,
    [glfyp_end_date_5]  INT         NULL,
    [glfyp_end_date_6]  INT         NULL,
    [glfyp_end_date_7]  INT         NULL,
    [glfyp_end_date_8]  INT         NULL,
    [glfyp_end_date_9]  INT         NULL,
    [glfyp_end_date_10] INT         NULL,
    [glfyp_end_date_11] INT         NULL,
    [glfyp_end_date_12] INT         NULL,
    [glfyp_end_date_13] INT         NULL,
    [glfyp_closed_yn]   CHAR (1)    NULL,
    [glfyp_purged_yn]   CHAR (1)    NULL,
    [glfyp_user_id]     CHAR (16)   NULL,
    [glfyp_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_glfypmst] PRIMARY KEY NONCLUSTERED ([glfyp_yr] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iglfypmst0]
    ON [dbo].[glfypmst]([glfyp_yr] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[glfypmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[glfypmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[glfypmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[glfypmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[glfypmst] TO PUBLIC
    AS [dbo];

