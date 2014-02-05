CREATE TABLE [dbo].[glhstmst] (
    [glhst_acct1_8]       INT             NOT NULL,
    [glhst_acct9_16]      INT             NOT NULL,
    [glhst_period]        INT             NOT NULL,
    [glhst_trans_dt]      INT             NOT NULL,
    [glhst_src_id]        CHAR (3)        NOT NULL,
    [glhst_src_seq]       CHAR (5)        NOT NULL,
    [glhst_line_no]       INT             NOT NULL,
    [glhst_dr_cr_ind]     CHAR (1)        NULL,
    [glhst_batch_no]      CHAR (3)        NOT NULL,
    [glhst_jrnl_no]       CHAR (6)        NULL,
    [glhst_ref]           CHAR (25)       NULL,
    [glhst_doc]           CHAR (25)       NULL,
    [glhst_amt]           DECIMAL (12, 2) NULL,
    [glhst_units]         DECIMAL (16, 4) NULL,
    [glhst_date]          INT             NULL,
    [glhst_time]          INT             NULL,
    [glhst_comments]      CHAR (25)       NULL,
    [glhst_correcting]    CHAR (1)        NULL,
    [glhst_source_pgm]    CHAR (8)        NULL,
    [glhst_glgje_line_no] INT             NOT NULL,
    [glhst_user_id]       CHAR (16)       NULL,
    [glhst_user_rev_dt]   INT             NULL,
    [A4GLIdentity]        NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_glhstmst] PRIMARY KEY NONCLUSTERED ([glhst_acct1_8] ASC, [glhst_acct9_16] ASC, [glhst_period] ASC, [glhst_trans_dt] ASC, [glhst_src_id] ASC, [glhst_src_seq] ASC, [glhst_line_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iglhstmst0]
    ON [dbo].[glhstmst]([glhst_acct1_8] ASC, [glhst_acct9_16] ASC, [glhst_period] ASC, [glhst_trans_dt] ASC, [glhst_src_id] ASC, [glhst_src_seq] ASC, [glhst_line_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iglhstmst1]
    ON [dbo].[glhstmst]([glhst_period] ASC, [glhst_acct1_8] ASC, [glhst_acct9_16] ASC, [glhst_trans_dt] ASC, [glhst_batch_no] ASC, [glhst_src_id] ASC, [glhst_src_seq] ASC);


GO
CREATE NONCLUSTERED INDEX [Iglhstmst2]
    ON [dbo].[glhstmst]([glhst_period] ASC, [glhst_batch_no] ASC, [glhst_src_id] ASC, [glhst_src_seq] ASC, [glhst_glgje_line_no] ASC);

