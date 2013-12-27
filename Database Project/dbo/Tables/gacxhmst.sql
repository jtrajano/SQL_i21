CREATE TABLE [dbo].[gacxhmst] (
    [gacxh_card_no]        CHAR (16)   NOT NULL,
    [gacxh_cus_no]         CHAR (10)   NOT NULL,
    [gacxh_last_update_dt] INT         NULL,
    [gacxh_user_id]        CHAR (16)   NULL,
    [gacxh_user_rev_dt]    INT         NULL,
    [A4GLIdentity]         NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gacxhmst] PRIMARY KEY NONCLUSTERED ([gacxh_card_no] ASC, [gacxh_cus_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Igacxhmst0]
    ON [dbo].[gacxhmst]([gacxh_card_no] ASC, [gacxh_cus_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gacxhmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gacxhmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gacxhmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gacxhmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[gacxhmst] TO PUBLIC
    AS [dbo];

