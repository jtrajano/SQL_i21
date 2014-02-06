CREATE TABLE [dbo].[slmktmst] (
    [slmkt_src]         CHAR (6)    NOT NULL,
    [slmkt_desc]        CHAR (20)   NULL,
    [slmkt_user_id]     CHAR (16)   NULL,
    [slmkt_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_slmktmst] PRIMARY KEY NONCLUSTERED ([slmkt_src] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Islmktmst0]
    ON [dbo].[slmktmst]([slmkt_src] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[slmktmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[slmktmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[slmktmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[slmktmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[slmktmst] TO PUBLIC
    AS [dbo];

