CREATE TABLE [dbo].[slclsmst] (
    [slcls_name]        CHAR (8)    NOT NULL,
    [slcls_value]       CHAR (4)    NOT NULL,
    [slcls_short_desc]  CHAR (20)   NULL,
    [slcls_long_desc1]  CHAR (30)   NULL,
    [slcls_long_desc2]  CHAR (30)   NULL,
    [slcls_user_id]     CHAR (16)   NULL,
    [slcls_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_slclsmst] PRIMARY KEY NONCLUSTERED ([slcls_name] ASC, [slcls_value] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Islclsmst0]
    ON [dbo].[slclsmst]([slcls_name] ASC, [slcls_value] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[slclsmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[slclsmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[slclsmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[slclsmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[slclsmst] TO PUBLIC
    AS [dbo];

