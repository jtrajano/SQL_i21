CREATE TABLE [dbo].[glacxmst] (
    [glacx_id]          CHAR (3)    NOT NULL,
    [glacx_fgn_acct]    CHAR (30)   NOT NULL,
    [glacx_acct1_8]     INT         NOT NULL,
    [glacx_acct9_16]    INT         NOT NULL,
    [glacx_user_id]     CHAR (16)   NULL,
    [glacx_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_glacxmst] PRIMARY KEY NONCLUSTERED ([glacx_id] ASC, [glacx_fgn_acct] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iglacxmst0]
    ON [dbo].[glacxmst]([glacx_id] ASC, [glacx_fgn_acct] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iglacxmst1]
    ON [dbo].[glacxmst]([glacx_acct1_8] ASC, [glacx_acct9_16] ASC, [glacx_fgn_acct] ASC, [glacx_id] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[glacxmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[glacxmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[glacxmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[glacxmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[glacxmst] TO PUBLIC
    AS [dbo];

