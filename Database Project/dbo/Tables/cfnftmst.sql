CREATE TABLE [dbo].[cfnftmst] (
    [cfnft_nwf_tax_type] SMALLINT    NOT NULL,
    [cfnft_nwf_tax_desc] CHAR (40)   NULL,
    [cfnft_ssi_tax_code] CHAR (3)    NULL,
    [cfnft_user_id]      CHAR (16)   NULL,
    [cfnft_user_rev_dt]  INT         NULL,
    [A4GLIdentity]       NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_cfnftmst] PRIMARY KEY NONCLUSTERED ([cfnft_nwf_tax_type] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Icfnftmst0]
    ON [dbo].[cfnftmst]([cfnft_nwf_tax_type] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[cfnftmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[cfnftmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[cfnftmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[cfnftmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[cfnftmst] TO PUBLIC
    AS [dbo];

