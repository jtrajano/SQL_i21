CREATE TABLE [dbo].[glgjemst] (
    [glgje_batch]        CHAR (3)        NOT NULL,
    [glgje_src_sys]      CHAR (3)        NOT NULL,
    [glgje_src_no]       CHAR (5)        NOT NULL,
    [glgje_line_no]      INT             NOT NULL,
    [glgje_batch_seq_no] SMALLINT        NOT NULL,
    [glgje_period]       INT             NOT NULL,
    [glgje_jrnl_no]      CHAR (6)        NULL,
    [glgje_reverse_yn]   CHAR (1)        NULL,
    [glgje_ref]          CHAR (25)       NULL,
    [glgje_doc]          CHAR (25)       NULL,
    [glgje_date]         INT             NULL,
    [glgje_time]         INT             NULL,
    [glgje_acct1_8]      INT             NOT NULL,
    [glgje_acct9_16]     INT             NOT NULL,
    [glgje_dr_cr_ind]    CHAR (1)        NULL,
    [glgje_amt]          DECIMAL (12, 2) NULL,
    [glgje_units]        DECIMAL (16, 4) NULL,
    [glgje_comments]     CHAR (25)       NULL,
    [glgje_correcting]   CHAR (1)        NULL,
    [glgje_source_pgm]   CHAR (8)        NULL,
    [glgje_user_id]      CHAR (16)       NULL,
    [glgje_user_rev_dt]  INT             NULL,
    [A4GLIdentity]       NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_glgjemst] PRIMARY KEY NONCLUSTERED ([glgje_batch] ASC, [glgje_src_sys] ASC, [glgje_src_no] ASC, [glgje_line_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iglgjemst0]
    ON [dbo].[glgjemst]([glgje_batch] ASC, [glgje_src_sys] ASC, [glgje_src_no] ASC, [glgje_line_no] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iglgjemst1]
    ON [dbo].[glgjemst]([glgje_batch] ASC, [glgje_batch_seq_no] ASC, [glgje_src_sys] ASC, [glgje_src_no] ASC, [glgje_line_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iglgjemst2]
    ON [dbo].[glgjemst]([glgje_src_sys] ASC, [glgje_src_no] ASC, [glgje_line_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iglgjemst3]
    ON [dbo].[glgjemst]([glgje_acct1_8] ASC, [glgje_acct9_16] ASC, [glgje_period] ASC, [glgje_src_sys] ASC, [glgje_src_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[glgjemst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[glgjemst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[glgjemst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[glgjemst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[glgjemst] TO PUBLIC
    AS [dbo];

