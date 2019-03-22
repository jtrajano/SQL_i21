CREATE TABLE [dbo].[glbatmst] (
    [glbat_type]         CHAR (1)    NOT NULL,
    [glbat_no]           CHAR (3)    NOT NULL,
    [glbat_post_yn]      CHAR (1)    NULL,
    [glbat_period]       INT         NULL,
    [glbat_entry_seq_no] SMALLINT    NULL,
    [glbat_in_use_yn]    CHAR (1)    NULL,
    [glbat_user_id]      CHAR (16)   NULL,
    [glbat_user_rev_dt]  INT         NULL,
    [A4GLIdentity]       NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_glbatmst] PRIMARY KEY NONCLUSTERED ([glbat_type] ASC, [glbat_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iglbatmst0]
    ON [dbo].[glbatmst]([glbat_type] ASC, [glbat_no] ASC);

