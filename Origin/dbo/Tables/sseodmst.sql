CREATE TABLE [dbo].[sseodmst] (
    [sseod_src_sys]     CHAR (2)    NOT NULL,
    [sseod_audit_no]    SMALLINT    NOT NULL,
    [sseod_seq_no]      SMALLINT    NOT NULL,
    [sseod_gl_rev_dt]   INT         NULL,
    [sseod_filler]      CHAR (38)   NULL,
    [sseod_user_id]     CHAR (16)   NULL,
    [sseod_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_sseodmst] PRIMARY KEY NONCLUSTERED ([sseod_src_sys] ASC, [sseod_audit_no] ASC, [sseod_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Isseodmst0]
    ON [dbo].[sseodmst]([sseod_src_sys] ASC, [sseod_audit_no] ASC, [sseod_seq_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[sseodmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[sseodmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[sseodmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[sseodmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[sseodmst] TO PUBLIC
    AS [dbo];

