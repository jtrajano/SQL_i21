CREATE TABLE [dbo].[gaprcmst] (
    [gaprc_com_cd]           CHAR (3)       NOT NULL,
    [gaprc_bot]              CHAR (1)       NOT NULL,
    [gaprc_loc_no]           CHAR (3)       NOT NULL,
    [gaprc_un_cash_prc]      DECIMAL (9, 5) NULL,
    [gaprc_un_bot_basis]     DECIMAL (9, 5) NULL,
    [gaprc_bot_option]       CHAR (5)       NULL,
    [gaprc_un_dlr_prc]       DECIMAL (9, 5) NULL,
    [gaprc_un_dlr_bot_basis] DECIMAL (9, 5) NULL,
    [gaprc_user_id]          CHAR (16)      NULL,
    [gaprc_user_rev_dt]      INT            NULL,
    [A4GLIdentity]           NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gaprcmst] PRIMARY KEY NONCLUSTERED ([gaprc_com_cd] ASC, [gaprc_bot] ASC, [gaprc_loc_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Igaprcmst0]
    ON [dbo].[gaprcmst]([gaprc_com_cd] ASC, [gaprc_bot] ASC, [gaprc_loc_no] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Igaprcmst1]
    ON [dbo].[gaprcmst]([gaprc_loc_no] ASC, [gaprc_com_cd] ASC, [gaprc_bot] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gaprcmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gaprcmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gaprcmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gaprcmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[gaprcmst] TO PUBLIC
    AS [dbo];

