CREATE TABLE [dbo].[slnammst] (
    [slnam_id]          CHAR (10)   NOT NULL,
    [slnam_name]        CHAR (50)   NOT NULL,
    [slnam_user_id]     CHAR (16)   NULL,
    [slnam_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_slnammst] PRIMARY KEY NONCLUSTERED ([slnam_id] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Islnammst0]
    ON [dbo].[slnammst]([slnam_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Islnammst1]
    ON [dbo].[slnammst]([slnam_name] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[slnammst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[slnammst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[slnammst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[slnammst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[slnammst] TO PUBLIC
    AS [dbo];

