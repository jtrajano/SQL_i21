CREATE TABLE [dbo].[agothmst] (
    [agoth_inc_cd]      CHAR (2)        NOT NULL,
    [agoth_inc_desc]    CHAR (30)       NULL,
    [agoth_inc_ptd_amt] DECIMAL (11, 2) NULL,
    [agoth_inc_gl_acct] DECIMAL (16, 8) NULL,
    [agoth_user_id]     CHAR (16)       NULL,
    [agoth_user_rev_dt] INT             NULL,
    [A4GLIdentity]      NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agothmst] PRIMARY KEY NONCLUSTERED ([agoth_inc_cd] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iagothmst0]
    ON [dbo].[agothmst]([agoth_inc_cd] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agothmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agothmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agothmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agothmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[agothmst] TO PUBLIC
    AS [dbo];

