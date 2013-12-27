CREATE TABLE [dbo].[agphymst] (
    [agphy_loc_no]        CHAR (3)        NOT NULL,
    [agphy_rec_no]        INT             NOT NULL,
    [agphy_binloc]        CHAR (5)        NULL,
    [agphy_class]         CHAR (3)        NULL,
    [agphy_itm_no]        CHAR (13)       NULL,
    [agphy_vnd_no]        CHAR (10)       NULL,
    [agphy_computed_qty]  DECIMAL (13, 4) NULL,
    [agphy_actual_qty]    DECIMAL (13, 4) NULL,
    [agphy_cutoff_rev_dt] INT             NULL,
    [agphy_book_un_cost]  DECIMAL (11, 5) NULL,
    [agphy_std_un_cost]   DECIMAL (11, 5) NULL,
    [agphy_avg_un_cost]   DECIMAL (11, 5) NULL,
    [agphy_last_un_cost]  DECIMAL (11, 5) NULL,
    [agphy_pkg_unit_ind]  CHAR (1)        NULL,
    [agphy_user_id]       CHAR (16)       NULL,
    [agphy_user_rev_dt]   INT             NULL,
    [A4GLIdentity]        NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agphymst] PRIMARY KEY NONCLUSTERED ([agphy_loc_no] ASC, [agphy_rec_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iagphymst0]
    ON [dbo].[agphymst]([agphy_loc_no] ASC, [agphy_rec_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agphymst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agphymst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agphymst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agphymst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[agphymst] TO PUBLIC
    AS [dbo];

