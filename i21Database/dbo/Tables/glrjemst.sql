CREATE TABLE [dbo].[glrjemst] (
    [glrje_batch]            CHAR (3)        NOT NULL,
    [glrje_src_sys]          CHAR (3)        NOT NULL,
    [glrje_src_no]           CHAR (5)        NOT NULL,
    [glrje_line_no]          INT             NOT NULL,
    [glrje_jrnl_no]          CHAR (6)        NULL,
    [glrje_reverse_yn]       CHAR (1)        NULL,
    [glrje_ref]              CHAR (25)       NULL,
    [glrje_doc]              CHAR (25)       NULL,
    [glrje_date]             INT             NULL,
    [glrje_time]             INT             NULL,
    [glrje_type]             CHAR (1)        NULL,
    [glrje_pct_yn]           CHAR (1)        NULL,
    [glrje_total_amt]        DECIMAL (12, 2) NULL,
    [glrje_beg_date]         INT             NULL,
    [glrje_end_date]         INT             NULL,
    [glrje_recur_freq]       SMALLINT        NULL,
    [glrje_recur_period]     CHAR (1)        NULL,
    [glrje_max_times]        SMALLINT        NULL,
    [glrje_times_used]       SMALLINT        NULL,
    [glrje_last_reference]   CHAR (25)       NULL,
    [glrje_last_document]    CHAR (25)       NULL,
    [glrje_last_post_date]   INT             NULL,
    [glrje_last_post_period] INT             NULL,
    [glrje_selected_yn]      CHAR (1)        NULL,
    [glrje_acct1_8]          INT             NULL,
    [glrje_acct9_16]         INT             NULL,
    [glrje_dr_cr_ind]        CHAR (1)        NULL,
    [glrje_pct]              DECIMAL (5, 2)  NULL,
    [glrje_amt]              DECIMAL (12, 2) NULL,
    [glrje_units]            DECIMAL (16, 4) NULL,
    [glrje_comments]         CHAR (25)       NULL,
    [glrje_user_id]          CHAR (16)       NULL,
    [glrje_user_rev_dt]      INT             NULL,
    [A4GLIdentity]           NUMERIC (9)     IDENTITY (1, 1) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iglrjemst0]
    ON [dbo].[glrjemst]([glrje_batch] ASC, [glrje_src_sys] ASC, [glrje_src_no] ASC, [glrje_line_no] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iglrjemst1]
    ON [dbo].[glrjemst]([glrje_src_sys] ASC, [glrje_src_no] ASC, [glrje_line_no] ASC);

