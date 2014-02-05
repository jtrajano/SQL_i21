CREATE TABLE [dbo].[copramst] (
    [copra_rpt_type]    CHAR (1)    NOT NULL,
    [copra_user_id]     CHAR (16)   NOT NULL,
    [copra_cnv_date]    INT         NOT NULL,
    [copra_cnv_time]    INT         NOT NULL,
    [copra_seq_no]      INT         NOT NULL,
    [copra_filename]    CHAR (12)   NULL,
    [copra_pgm_title]   CHAR (40)   NULL,
    [copra_audit_no]    CHAR (8)    NULL,
    [copra_prog_id]     CHAR (15)   NULL,
    [copra_rpt_date]    INT         NOT NULL,
    [copra_rpt_time]    INT         NULL,
    [copra_num_lines]   INT         NULL,
    [copra_delete_date] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_copramst] PRIMARY KEY NONCLUSTERED ([copra_rpt_type] ASC, [copra_user_id] ASC, [copra_cnv_date] ASC, [copra_cnv_time] ASC, [copra_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Icopramst0]
    ON [dbo].[copramst]([copra_rpt_type] ASC, [copra_user_id] ASC, [copra_cnv_date] ASC, [copra_cnv_time] ASC, [copra_seq_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Icopramst1]
    ON [dbo].[copramst]([copra_rpt_type] ASC, [copra_user_id] ASC, [copra_rpt_date] ASC, [copra_cnv_time] ASC, [copra_seq_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Icopramst2]
    ON [dbo].[copramst]([copra_rpt_type] ASC, [copra_cnv_date] ASC, [copra_cnv_time] ASC, [copra_seq_no] ASC, [copra_user_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Icopramst3]
    ON [dbo].[copramst]([copra_rpt_type] ASC, [copra_rpt_date] ASC, [copra_cnv_time] ASC, [copra_seq_no] ASC, [copra_user_id] ASC);

