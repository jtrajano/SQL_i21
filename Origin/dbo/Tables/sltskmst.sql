CREATE TABLE [dbo].[sltskmst] (
    [sltsk_id]            CHAR (1)    NOT NULL,
    [sltsk_desc]          CHAR (20)   NULL,
    [sltsk_sec_access_yn] CHAR (1)    NULL,
    [sltsk_user_id]       CHAR (16)   NULL,
    [sltsk_user_rev_dt]   INT         NULL,
    [A4GLIdentity]        NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_sltskmst] PRIMARY KEY NONCLUSTERED ([sltsk_id] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Isltskmst0]
    ON [dbo].[sltskmst]([sltsk_id] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[sltskmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[sltskmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[sltskmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[sltskmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[sltskmst] TO PUBLIC
    AS [dbo];

