CREATE TABLE [dbo].[cfsitmst] (
    [cfsit_site_code]   CHAR (15)   NOT NULL,
    [cfsit_site_name]   CHAR (40)   NULL,
    [cfsit_user_id]     CHAR (16)   NULL,
    [cfsit_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_cfsitmst] PRIMARY KEY NONCLUSTERED ([cfsit_site_code] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Icfsitmst0]
    ON [dbo].[cfsitmst]([cfsit_site_code] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[cfsitmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[cfsitmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[cfsitmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[cfsitmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[cfsitmst] TO PUBLIC
    AS [dbo];

