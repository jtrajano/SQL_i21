CREATE TABLE [dbo].[etposmst] (
    [etpos_loc]          CHAR (3)        NOT NULL,
    [etpos_itm]          CHAR (15)       NOT NULL,
    [etpos_branch_prc]   DECIMAL (10, 5) NULL,
    [etpos_rack_prc]     DECIMAL (10, 5) NULL,
    [etpos_marg_dol]     DECIMAL (10, 5) NULL,
    [etpos_marg_pct]     DECIMAL (10, 5) NULL,
    [etpos_marg_flag_dp] CHAR (1)        NULL,
    [etpos_calc_flag_yn] CHAR (1)        NULL,
    [etpos_posted_prc]   DECIMAL (10, 5) NULL,
    [etpos_date_calc]    INT             NOT NULL,
    [etpos_time_calc]    INT             NOT NULL,
    [etpos_last_rev_dt]  INT             NULL,
    [etpos_last_time]    INT             NULL,
    [A4GLIdentity]       NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_etposmst] PRIMARY KEY NONCLUSTERED ([etpos_loc] ASC, [etpos_itm] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ietposmst0]
    ON [dbo].[etposmst]([etpos_loc] ASC, [etpos_itm] ASC);


GO
CREATE NONCLUSTERED INDEX [Ietposmst1]
    ON [dbo].[etposmst]([etpos_itm] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Ietposmst2]
    ON [dbo].[etposmst]([etpos_itm] ASC, [etpos_loc] ASC);


GO
CREATE NONCLUSTERED INDEX [Ietposmst3]
    ON [dbo].[etposmst]([etpos_date_calc] ASC, [etpos_time_calc] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[etposmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[etposmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[etposmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[etposmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[etposmst] TO PUBLIC
    AS [dbo];

