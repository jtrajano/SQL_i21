CREATE TABLE [dbo].[ededpmst] (
    [ededp_bill_to_cus] CHAR (10)    NOT NULL,
    [ededp_edi_prod_n]  DECIMAL (18) NOT NULL,
    [ededp_zone_n]      INT          NOT NULL,
    [ededp_itm_no]      CHAR (10)    NOT NULL,
    [ededp_itm_loc]     SMALLINT     NOT NULL,
    [ededp_export_yn]   CHAR (1)     NULL,
    [A4GLIdentity]      NUMERIC (9)  IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_ededpmst] PRIMARY KEY NONCLUSTERED ([ededp_bill_to_cus] ASC, [ededp_edi_prod_n] ASC, [ededp_zone_n] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iededpmst0]
    ON [dbo].[ededpmst]([ededp_bill_to_cus] ASC, [ededp_edi_prod_n] ASC, [ededp_zone_n] ASC);


GO
CREATE NONCLUSTERED INDEX [Iededpmst1]
    ON [dbo].[ededpmst]([ededp_itm_no] ASC, [ededp_itm_loc] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ededpmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ededpmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ededpmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ededpmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ededpmst] TO PUBLIC
    AS [dbo];

