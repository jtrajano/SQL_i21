CREATE TABLE [dbo].[slslsmst] (
    [slsls_id]          CHAR (3)    NOT NULL,
    [slsls_name]        CHAR (50)   NULL,
    [slsls_title]       CHAR (30)   NULL,
    [slsls_login_name]  CHAR (40)   NULL,
    [slsls_user_id]     CHAR (16)   NULL,
    [slsls_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_slslsmst] PRIMARY KEY NONCLUSTERED ([slsls_id] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Islslsmst0]
    ON [dbo].[slslsmst]([slsls_id] ASC);

