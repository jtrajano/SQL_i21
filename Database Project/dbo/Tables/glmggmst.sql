CREATE TABLE [dbo].[glmggmst] (
    [glmgg_code]             CHAR (10)   NOT NULL,
    [glmgg_seq]              SMALLINT    NOT NULL,
    [glmgg_desc]             CHAR (30)   NULL,
    [glmgg_suspend_yn]       CHAR (1)    NULL,
    [glmgg_margin_no]        SMALLINT    NULL,
    [glmgg_print_yn]         CHAR (1)    NULL,
    [glmgg_no_copies]        TINYINT     NULL,
    [glmgg_use_prc_group_yn] CHAR (1)    NULL,
    [glmgg_glpcg_code]       CHAR (10)   NULL,
    [glmgg_beg_prc_n]        INT         NULL,
    [glmgg_end_prc_n]        INT         NULL,
    [glmgg_user_id]          CHAR (16)   NULL,
    [glmgg_user_rev_dt]      INT         NULL,
    [A4GLIdentity]           NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_glmggmst] PRIMARY KEY NONCLUSTERED ([glmgg_code] ASC, [glmgg_seq] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iglmggmst0]
    ON [dbo].[glmggmst]([glmgg_code] ASC, [glmgg_seq] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[glmggmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[glmggmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[glmggmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[glmggmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[glmggmst] TO PUBLIC
    AS [dbo];

