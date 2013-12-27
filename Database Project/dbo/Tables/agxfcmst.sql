CREATE TABLE [dbo].[agxfcmst] (
    [agxfc_entry_seq_no] INT         NOT NULL,
    [agxfc_old_cus]      CHAR (10)   NOT NULL,
    [agxfc_new_cus]      CHAR (10)   NOT NULL,
    [A4GLIdentity]       NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agxfcmst] PRIMARY KEY NONCLUSTERED ([agxfc_entry_seq_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iagxfcmst0]
    ON [dbo].[agxfcmst]([agxfc_entry_seq_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagxfcmst1]
    ON [dbo].[agxfcmst]([agxfc_old_cus] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagxfcmst2]
    ON [dbo].[agxfcmst]([agxfc_new_cus] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agxfcmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agxfcmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agxfcmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agxfcmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[agxfcmst] TO PUBLIC
    AS [dbo];

