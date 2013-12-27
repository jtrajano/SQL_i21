CREATE TABLE [dbo].[copwdmst] (
    [copwd_user_id]         CHAR (16)   NOT NULL,
    [copwd_system]          CHAR (2)    NOT NULL,
    [copwd_pgm_id]          CHAR (15)   NOT NULL,
    [copwd_hide_yn]         CHAR (1)    NULL,
    [copwd_add_yn]          CHAR (1)    NULL,
    [copwd_change_yn]       CHAR (1)    NULL,
    [copwd_delete_yn]       CHAR (1)    NULL,
    [copwd_inquire_yn]      CHAR (1)    NULL,
    [copwd_print_yn]        CHAR (1)    NULL,
    [copwd_update_yn]       CHAR (1)    NULL,
    [copwd_chg_user_id]     CHAR (16)   NULL,
    [copwd_chg_user_rev_dt] INT         NULL,
    [A4GLIdentity]          NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_copwdmst] PRIMARY KEY NONCLUSTERED ([copwd_user_id] ASC, [copwd_system] ASC, [copwd_pgm_id] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Icopwdmst0]
    ON [dbo].[copwdmst]([copwd_user_id] ASC, [copwd_system] ASC, [copwd_pgm_id] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Icopwdmst1]
    ON [dbo].[copwdmst]([copwd_pgm_id] ASC, [copwd_user_id] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[copwdmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[copwdmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[copwdmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[copwdmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[copwdmst] TO PUBLIC
    AS [dbo];

