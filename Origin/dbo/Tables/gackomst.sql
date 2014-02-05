CREATE TABLE [dbo].[gackomst] (
    [gacko_com_cd]        CHAR (3)        NOT NULL,
    [gacko_type_cio]      CHAR (1)        NOT NULL,
    [gacko_state]         CHAR (2)        NOT NULL,
    [gacko_desc]          CHAR (30)       NULL,
    [gacko_rate]          DECIMAL (10, 6) NULL,
    [gacko_calc_ind_pugs] CHAR (1)        NULL,
    [gacko_vol_ynd]       CHAR (1)        NULL,
    [gacko_lit]           CHAR (5)        NULL,
    [gacko_gl]            INT             NULL,
    [gacko_user_id]       CHAR (16)       NULL,
    [gacko_user_rev_dt]   INT             NULL,
    [A4GLIdentity]        NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gackomst] PRIMARY KEY NONCLUSTERED ([gacko_com_cd] ASC, [gacko_type_cio] ASC, [gacko_state] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igackomst0]
    ON [dbo].[gackomst]([gacko_com_cd] ASC, [gacko_type_cio] ASC, [gacko_state] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[gackomst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gackomst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gackomst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gackomst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gackomst] TO PUBLIC
    AS [dbo];

