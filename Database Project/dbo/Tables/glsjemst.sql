CREATE TABLE [dbo].[glsjemst] (
    [glsje_batch]         CHAR (3)        NOT NULL,
    [glsje_src_sys]       CHAR (3)        NOT NULL,
    [glsje_src_no]        CHAR (5)        NOT NULL,
    [glsje_line_no]       INT             NOT NULL,
    [glsje_jrnl_no]       CHAR (6)        NULL,
    [glsje_reverse_yn]    CHAR (1)        NULL,
    [glsje_ref]           CHAR (25)       NULL,
    [glsje_doc]           CHAR (25)       NULL,
    [glsje_date]          INT             NULL,
    [glsje_time]          INT             NULL,
    [glsje_type]          CHAR (1)        NULL,
    [glsje_pct_yn]        CHAR (1)        NULL,
    [glsje_total_amt]     DECIMAL (12, 2) NULL,
    [glsje_acct1_8]       INT             NULL,
    [glsje_acct9_16]      INT             NULL,
    [glsje_dr_cr_ind]     CHAR (1)        NULL,
    [glsje_pct]           DECIMAL (5, 2)  NULL,
    [glsje_amt]           DECIMAL (12, 2) NULL,
    [glsje_units]         DECIMAL (16, 4) NULL,
    [glsje_comments]      CHAR (25)       NULL,
    [glsje_last_period]   INT             NULL,
    [glsje_last_trans_dt] INT             NULL,
    [glsje_user_id]       CHAR (16)       NULL,
    [glsje_user_rev_dt]   INT             NULL,
    [A4GLIdentity]        NUMERIC (9)     IDENTITY (1, 1) NOT NULL
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iglsjemst0]
    ON [dbo].[glsjemst]([glsje_batch] ASC, [glsje_src_sys] ASC, [glsje_src_no] ASC, [glsje_line_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iglsjemst1]
    ON [dbo].[glsjemst]([glsje_src_sys] ASC, [glsje_src_no] ASC, [glsje_line_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[glsjemst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[glsjemst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[glsjemst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[glsjemst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[glsjemst] TO PUBLIC
    AS [dbo];

