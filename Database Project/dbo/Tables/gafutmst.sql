CREATE TABLE [dbo].[gafutmst] (
    [gafut_com_cd]        CHAR (3)       NOT NULL,
    [gafut_bot_opt]       CHAR (3)       NOT NULL,
    [gafut_bot_yy]        CHAR (2)       NOT NULL,
    [gafut_un_prc_fut]    DECIMAL (9, 5) NULL,
    [gafut_expire_rev_dt] INT            NULL,
    [gafut_user_id]       CHAR (16)      NULL,
    [gafut_user_rev_dt]   INT            NULL,
    [A4GLIdentity]        NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gafutmst] PRIMARY KEY NONCLUSTERED ([gafut_com_cd] ASC, [gafut_bot_opt] ASC, [gafut_bot_yy] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Igafutmst0]
    ON [dbo].[gafutmst]([gafut_com_cd] ASC, [gafut_bot_opt] ASC, [gafut_bot_yy] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Igafutmst1]
    ON [dbo].[gafutmst]([gafut_com_cd] ASC, [gafut_bot_yy] ASC, [gafut_bot_opt] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gafutmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gafutmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gafutmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gafutmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[gafutmst] TO PUBLIC
    AS [dbo];

