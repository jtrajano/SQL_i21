CREATE TABLE [dbo].[adrdgmst] (
    [adrdg_loc_no]      CHAR (3)    NOT NULL,
    [adrdg_rev_dt]      INT         NOT NULL,
    [adrdg_dd]          INT         NULL,
    [adrdg_accum_dd]    INT         NULL,
    [adrdg_season]      CHAR (1)    NULL,
    [adrdg_user_id]     CHAR (16)   NULL,
    [adrdg_user_rev_dt] CHAR (8)    NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_adrdgmst] PRIMARY KEY NONCLUSTERED ([adrdg_loc_no] ASC, [adrdg_rev_dt] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iadrdgmst0]
    ON [dbo].[adrdgmst]([adrdg_loc_no] ASC, [adrdg_rev_dt] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[adrdgmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[adrdgmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[adrdgmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[adrdgmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[adrdgmst] TO PUBLIC
    AS [dbo];

