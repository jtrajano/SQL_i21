CREATE TABLE [dbo].[sstxtmst] (
    [sstxt_key_program] CHAR (8)    NOT NULL,
    [sstxt_pur_sls_ind] CHAR (1)    NOT NULL,
    [sstxt_type_ind]    CHAR (1)    NOT NULL,
    [sstxt_txt_id]      CHAR (2)    NOT NULL,
    [sstxt_key_rec_no]  SMALLINT    NOT NULL,
    [sstxt_desc]        CHAR (128)  NULL,
    [sstxt_user_id]     CHAR (16)   NULL,
    [sstxt_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_sstxtmst] PRIMARY KEY NONCLUSTERED ([sstxt_key_program] ASC, [sstxt_pur_sls_ind] ASC, [sstxt_type_ind] ASC, [sstxt_txt_id] ASC, [sstxt_key_rec_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Isstxtmst0]
    ON [dbo].[sstxtmst]([sstxt_key_program] ASC, [sstxt_pur_sls_ind] ASC, [sstxt_type_ind] ASC, [sstxt_txt_id] ASC, [sstxt_key_rec_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[sstxtmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[sstxtmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[sstxtmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[sstxtmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[sstxtmst] TO PUBLIC
    AS [dbo];

