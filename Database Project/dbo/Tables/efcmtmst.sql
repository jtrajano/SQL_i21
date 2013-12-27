CREATE TABLE [dbo].[efcmtmst] (
    [efcmt_src_sys]     CHAR (2)    NOT NULL,
    [efcmt_seq_no]      SMALLINT    NOT NULL,
    [efcmt_comment]     CHAR (60)   NULL,
    [efcmt_user_id]     CHAR (16)   NULL,
    [efcmt_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_efcmtmst] PRIMARY KEY NONCLUSTERED ([efcmt_src_sys] ASC, [efcmt_seq_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iefcmtmst0]
    ON [dbo].[efcmtmst]([efcmt_src_sys] ASC, [efcmt_seq_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[efcmtmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[efcmtmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[efcmtmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[efcmtmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[efcmtmst] TO PUBLIC
    AS [dbo];

