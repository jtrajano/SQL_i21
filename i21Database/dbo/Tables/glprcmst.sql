CREATE TABLE [dbo].[glprcmst] (
    [glprc_sub_acct]    INT         NOT NULL,
    [glprc_desc]        CHAR (30)   NOT NULL,
    [glprc_user_id]     CHAR (16)   NULL,
    [glprc_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    [glprc_active_yn]   CHAR (1)    NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iglprcmst0]
    ON [dbo].[glprcmst]([glprc_sub_acct] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iglprcmst1]
    ON [dbo].[glprcmst]([glprc_desc] ASC, [glprc_sub_acct] ASC);

