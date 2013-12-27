CREATE TABLE [dbo].[slhttmst] (
    [slhtt_hist_type]     CHAR (1)    NOT NULL,
    [slhtt_short_desc]    CHAR (8)    NULL,
    [slhtt_long_desc]     CHAR (25)   NULL,
    [slhtt_sec_access_yn] CHAR (1)    NULL,
    [slhtt_user_id]       CHAR (16)   NULL,
    [slhtt_user_rev_dt]   INT         NULL,
    [A4GLIdentity]        NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_slhttmst] PRIMARY KEY NONCLUSTERED ([slhtt_hist_type] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Islhttmst0]
    ON [dbo].[slhttmst]([slhtt_hist_type] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[slhttmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[slhttmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[slhttmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[slhttmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[slhttmst] TO PUBLIC
    AS [dbo];

