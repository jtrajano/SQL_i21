CREATE TABLE [dbo].[gluommst] (
    [gluom_code]         CHAR (6)        NOT NULL,
    [gluom_desc]         CHAR (30)       NULL,
    [gluom_lbs_per_unit] DECIMAL (16, 4) NULL,
    [gluom_user_id]      CHAR (16)       NULL,
    [gluom_user_rev_dt]  INT             NULL,
    [A4GLIdentity]       NUMERIC (9)     IDENTITY (1, 1) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igluommst0]
    ON [dbo].[gluommst]([gluom_code] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[gluommst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gluommst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gluommst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gluommst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gluommst] TO PUBLIC
    AS [dbo];

