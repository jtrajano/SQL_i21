CREATE TABLE [dbo].[fxdivmst] (
    [fxdiv_div]         CHAR (2)    NOT NULL,
    [fxdiv_desc]        CHAR (30)   NULL,
    [fxdiv_user_id]     CHAR (16)   NULL,
    [fxdiv_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_fxdivmst] PRIMARY KEY NONCLUSTERED ([fxdiv_div] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ifxdivmst0]
    ON [dbo].[fxdivmst]([fxdiv_div] ASC);

