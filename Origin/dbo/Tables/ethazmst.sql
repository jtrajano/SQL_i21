CREATE TABLE [dbo].[ethazmst] (
    [ethaz_epa]         CHAR (2)    NOT NULL,
    [ethaz_msg1]        CHAR (40)   NULL,
    [ethaz_msg2]        CHAR (40)   NULL,
    [ethaz_date_calc]   INT         NOT NULL,
    [ethaz_time_calc]   INT         NOT NULL,
    [ethaz_last_rev_dt] INT         NULL,
    [ethaz_last_time]   INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_ethazmst] PRIMARY KEY NONCLUSTERED ([ethaz_epa] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iethazmst0]
    ON [dbo].[ethazmst]([ethaz_epa] ASC);


GO
CREATE NONCLUSTERED INDEX [Iethazmst1]
    ON [dbo].[ethazmst]([ethaz_date_calc] ASC, [ethaz_time_calc] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[ethazmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ethazmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ethazmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ethazmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ethazmst] TO PUBLIC
    AS [dbo];

