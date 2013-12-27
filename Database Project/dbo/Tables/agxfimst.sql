CREATE TABLE [dbo].[agxfimst] (
    [agxfi_entry_seq_no] SMALLINT    NOT NULL,
    [agxfi_old_itm_no]   CHAR (13)   NOT NULL,
    [agxfi_old_loc_no]   CHAR (3)    NOT NULL,
    [agxfi_new_itm_no]   CHAR (13)   NOT NULL,
    [agxfi_new_loc_no]   CHAR (3)    NOT NULL,
    [agxfi_eff_dt]       INT         NULL,
    [A4GLIdentity]       NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agxfimst] PRIMARY KEY NONCLUSTERED ([agxfi_entry_seq_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iagxfimst0]
    ON [dbo].[agxfimst]([agxfi_entry_seq_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagxfimst1]
    ON [dbo].[agxfimst]([agxfi_old_itm_no] ASC, [agxfi_old_loc_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagxfimst2]
    ON [dbo].[agxfimst]([agxfi_new_itm_no] ASC, [agxfi_new_loc_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agxfimst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agxfimst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agxfimst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agxfimst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[agxfimst] TO PUBLIC
    AS [dbo];

