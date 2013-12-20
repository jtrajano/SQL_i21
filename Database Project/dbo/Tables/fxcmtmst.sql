CREATE TABLE [dbo].[fxcmtmst] (
    [fxcmt_div]         CHAR (2)    NOT NULL,
    [fxcmt_dept]        CHAR (3)    NOT NULL,
    [fxcmt_class]       CHAR (2)    NOT NULL,
    [fxcmt_id_no]       CHAR (6)    NOT NULL,
    [fxcmt_seq_no]      SMALLINT    NOT NULL,
    [fxcmt_comment]     CHAR (69)   NULL,
    [fxcmt_user_id]     CHAR (16)   NULL,
    [fxcmt_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_fxcmtmst] PRIMARY KEY NONCLUSTERED ([fxcmt_div] ASC, [fxcmt_dept] ASC, [fxcmt_class] ASC, [fxcmt_id_no] ASC, [fxcmt_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ifxcmtmst0]
    ON [dbo].[fxcmtmst]([fxcmt_div] ASC, [fxcmt_dept] ASC, [fxcmt_class] ASC, [fxcmt_id_no] ASC, [fxcmt_seq_no] ASC);

