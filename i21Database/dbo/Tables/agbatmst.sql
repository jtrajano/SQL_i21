CREATE TABLE [dbo].[agbatmst] (
    [agbat_batch_no]     SMALLINT    NOT NULL,
    [agbat_ord_post_ynz] CHAR (1)    NULL,
    [agbat_pye_post_ynz] CHAR (1)    NULL,
    [agbat_rct_post_ynz] CHAR (1)    NULL,
    [agbat_user_id]      CHAR (16)   NULL,
    [agbat_user_rev_dt]  INT         NULL,
    [A4GLIdentity]       NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agbatmst] PRIMARY KEY NONCLUSTERED ([agbat_batch_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagbatmst0]
    ON [dbo].[agbatmst]([agbat_batch_no] ASC);

