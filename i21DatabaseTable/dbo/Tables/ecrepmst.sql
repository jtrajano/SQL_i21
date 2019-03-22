CREATE TABLE [dbo].[ecrepmst] (
    [ecrep_username]    CHAR (20)   NOT NULL,
    [ecrep_system]      CHAR (2)    NOT NULL,
    [ecrep_page_id]     SMALLINT    NOT NULL,
    [ecrep_user_id]     CHAR (16)   NULL,
    [ecrep_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_ecrepmst] PRIMARY KEY NONCLUSTERED ([ecrep_username] ASC, [ecrep_system] ASC, [ecrep_page_id] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iecrepmst0]
    ON [dbo].[ecrepmst]([ecrep_username] ASC, [ecrep_system] ASC, [ecrep_page_id] ASC);

