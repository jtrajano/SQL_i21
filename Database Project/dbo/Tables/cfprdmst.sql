CREATE TABLE [dbo].[cfprdmst] (
    [cfprd_site_no]     CHAR (15)   NOT NULL,
    [cfprd_prod_no]     CHAR (4)    NOT NULL,
    [cfprd_prod_desc]   CHAR (20)   NULL,
    [cfprd_user_id]     CHAR (16)   NULL,
    [cfprd_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_cfprdmst] PRIMARY KEY NONCLUSTERED ([cfprd_site_no] ASC, [cfprd_prod_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Icfprdmst0]
    ON [dbo].[cfprdmst]([cfprd_site_no] ASC, [cfprd_prod_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[cfprdmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[cfprdmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[cfprdmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[cfprdmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[cfprdmst] TO PUBLIC
    AS [dbo];

