CREATE TABLE [dbo].[glijemst] (
    [glije_period]      INT             NOT NULL,
    [glije_acct_no]     DECIMAL (16, 8) NOT NULL,
    [glije_src_sys]     CHAR (3)        NOT NULL,
    [glije_src_no]      CHAR (5)        NOT NULL,
    [glije_line_no]     INT             NOT NULL,
    [glije_date]        INT             NULL,
    [glije_time]        INT             NULL,
    [glije_ref]         CHAR (25)       NULL,
    [glije_doc]         CHAR (25)       NULL,
    [glije_comments]    CHAR (25)       NULL,
    [glije_dr_cr_ind]   CHAR (1)        NULL,
    [glije_amt]         DECIMAL (12, 2) NULL,
    [glije_units]       DECIMAL (16, 4) NULL,
    [glije_correcting]  CHAR (1)        NULL,
    [glije_source_pgm]  CHAR (8)        NULL,
    [glije_work_area]   CHAR (40)       NULL,
    [glije_cbk_no]      CHAR (2)        NULL,
    [glije_user_id]     CHAR (16)       NULL,
    [glije_user_rev_dt] INT             NULL,
    [A4GLIdentity]      NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_glijemst] PRIMARY KEY NONCLUSTERED ([glije_period] ASC, [glije_acct_no] ASC, [glije_src_sys] ASC, [glije_src_no] ASC, [glije_line_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iglijemst0]
    ON [dbo].[glijemst]([glije_period] ASC, [glije_acct_no] ASC, [glije_src_sys] ASC, [glije_src_no] ASC, [glije_line_no] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iglijemst1]
    ON [dbo].[glijemst]([glije_period] ASC, [glije_src_sys] ASC, [glije_src_no] ASC, [glije_acct_no] ASC, [glije_line_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iglijemst2]
    ON [dbo].[glijemst]([glije_acct_no] ASC, [glije_period] ASC, [glije_src_sys] ASC, [glije_src_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[glijemst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[glijemst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[glijemst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[glijemst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[glijemst] TO PUBLIC
    AS [dbo];

