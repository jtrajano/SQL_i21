CREATE TABLE [dbo].[agtxcmst] (
    [agtxc_tax_type]          CHAR (4)        NOT NULL,
    [agtxc_seq_no]            INT             NOT NULL,
    [agtxc_old_tax_rt]        DECIMAL (9, 6)  NULL,
    [agtxc_old_tax_sls_acct]  DECIMAL (16, 8) NULL,
    [agtxc_old_tax_pur_acct]  DECIMAL (16, 8) NULL,
    [agtxc_old_calc_method]   CHAR (1)        NULL,
    [agtxc_old_tax_on_fet_yn] CHAR (1)        NULL,
    [agtxc_old_tax_on_set_yn] CHAR (1)        NULL,
    [agtxc_sst_on_old_tax_yn] CHAR (1)        NULL,
    [agtxc_new_tax_rt]        DECIMAL (9, 6)  NULL,
    [agtxc_new_tax_sls_acct]  DECIMAL (16, 8) NULL,
    [agtxc_new_tax_pur_acct]  DECIMAL (16, 8) NULL,
    [agtxc_new_calc_method]   CHAR (1)        NULL,
    [agtxc_new_tax_on_fet_yn] CHAR (1)        NULL,
    [agtxc_new_tax_on_set_yn] CHAR (1)        NULL,
    [agtxc_sst_on_new_tax_yn] CHAR (1)        NULL,
    [A4GLIdentity]            NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agtxcmst] PRIMARY KEY NONCLUSTERED ([agtxc_tax_type] ASC, [agtxc_seq_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iagtxcmst0]
    ON [dbo].[agtxcmst]([agtxc_tax_type] ASC, [agtxc_seq_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agtxcmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agtxcmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agtxcmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agtxcmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[agtxcmst] TO PUBLIC
    AS [dbo];

