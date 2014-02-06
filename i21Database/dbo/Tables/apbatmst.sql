CREATE TABLE [dbo].[apbatmst] (
    [apbat_batch_no]    SMALLINT    NOT NULL,
    [apbat_post_ind_yn] CHAR (1)    NULL,
    [apbat_user_id]     CHAR (16)   NULL,
    [apbat_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_apbatmst] PRIMARY KEY NONCLUSTERED ([apbat_batch_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iapbatmst0]
    ON [dbo].[apbatmst]([apbat_batch_no] ASC);

