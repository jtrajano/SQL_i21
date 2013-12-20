CREATE TABLE [dbo].[cfflsmst] (
    [cffls_site]        CHAR (15)   NOT NULL,
    [cffls_desc]        CHAR (30)   NOT NULL,
    [cffls_addr]        CHAR (30)   NULL,
    [cffls_city]        CHAR (20)   NULL,
    [cffls_state]       CHAR (2)    NULL,
    [cffls_user_id]     CHAR (16)   NULL,
    [cffls_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_cfflsmst] PRIMARY KEY NONCLUSTERED ([cffls_site] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Icfflsmst0]
    ON [dbo].[cfflsmst]([cffls_site] ASC);


GO
CREATE NONCLUSTERED INDEX [Icfflsmst1]
    ON [dbo].[cfflsmst]([cffls_desc] ASC);

