CREATE TABLE [dbo].[glpcgmst] (
    [glpcg_code]        CHAR (10)   NOT NULL,
    [glpcg_seq]         SMALLINT    NOT NULL,
    [glpcg_desc]        CHAR (30)   NULL,
    [glpcg_print_yn]    CHAR (1)    NULL,
    [glpcg_prc_n]       INT         NULL,
    [glpcg_user_id]     CHAR (16)   NULL,
    [glpcg_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_glpcgmst] PRIMARY KEY NONCLUSTERED ([glpcg_code] ASC, [glpcg_seq] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iglpcgmst0]
    ON [dbo].[glpcgmst]([glpcg_code] ASC, [glpcg_seq] ASC);

