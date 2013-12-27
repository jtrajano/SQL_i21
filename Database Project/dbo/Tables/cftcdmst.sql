CREATE TABLE [dbo].[cftcdmst] (
    [cftcd_cfn_tax_code] SMALLINT    NOT NULL,
    [cftcd_cfn_tax_desc] CHAR (40)   NULL,
    [cftcd_ssi_tax_code] CHAR (3)    NULL,
    [cftcd_user_id]      CHAR (16)   NULL,
    [cftcd_user_rev_dt]  INT         NULL,
    [A4GLIdentity]       NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_cftcdmst] PRIMARY KEY NONCLUSTERED ([cftcd_cfn_tax_code] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Icftcdmst0]
    ON [dbo].[cftcdmst]([cftcd_cfn_tax_code] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[cftcdmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[cftcdmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[cftcdmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[cftcdmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[cftcdmst] TO PUBLIC
    AS [dbo];

