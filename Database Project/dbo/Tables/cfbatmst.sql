CREATE TABLE [dbo].[cfbatmst] (
    [cfbat_batch_no]            SMALLINT    NOT NULL,
    [cfbat_ok_to_post_batch_yn] CHAR (1)    NULL,
    [cfbat_user_id]             CHAR (16)   NULL,
    [cfbat_user_rev_dt]         INT         NULL,
    [A4GLIdentity]              NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_cfbatmst] PRIMARY KEY NONCLUSTERED ([cfbat_batch_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Icfbatmst0]
    ON [dbo].[cfbatmst]([cfbat_batch_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[cfbatmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[cfbatmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[cfbatmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[cfbatmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[cfbatmst] TO PUBLIC
    AS [dbo];

