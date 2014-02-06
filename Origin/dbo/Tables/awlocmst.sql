CREATE TABLE [dbo].[awlocmst] (
    [awloc_loc_no]            CHAR (3)        NOT NULL,
    [awloc_ovrd_err_password] CHAR (5)        NULL,
    [awloc_billing_rlse]      DECIMAL (4, 2)  NULL,
    [awloc_contract_rlse]     DECIMAL (4, 2)  NULL,
    [awloc_chem_tax_itm]      CHAR (13)       NULL,
    [awloc_fert_tax_itm]      CHAR (13)       NULL,
    [awloc_mixed_prod_itm]    CHAR (13)       NULL,
    [awloc_chem_tax_yn]       CHAR (1)        NULL,
    [awloc_fert_tax_yn]       CHAR (1)        NULL,
    [awloc_dflt_batch_no]     SMALLINT        NULL,
    [awloc_itm_prefix]        CHAR (2)        NULL,
    [awloc_clr_gl_acct]       DECIMAL (16, 8) NULL,
    [awloc_export_path]       CHAR (50)       NULL,
    [awloc_cost_from_rcvr_yn] CHAR (1)        NULL,
    [awloc_user_id]           CHAR (16)       NULL,
    [awloc_user_rev_dt]       INT             NULL,
    [A4GLIdentity]            NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_awlocmst] PRIMARY KEY NONCLUSTERED ([awloc_loc_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iawlocmst0]
    ON [dbo].[awlocmst]([awloc_loc_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[awlocmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[awlocmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[awlocmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[awlocmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[awlocmst] TO PUBLIC
    AS [dbo];

