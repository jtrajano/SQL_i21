CREATE TABLE [dbo].[agmfgmst] (
    [agmfg_loc_no]      CHAR (3)        NOT NULL,
    [agmfg_itm_no]      CHAR (13)       NOT NULL,
    [agmfg_rev_dt]      INT             NOT NULL,
    [agmfg_lbs]         DECIMAL (13, 4) NULL,
    [agmfg_comment_1]   CHAR (20)       NULL,
    [agmfg_comment_2]   CHAR (20)       NULL,
    [agmfg_lot_no]      CHAR (16)       NULL,
    [agmfg_user_id]     CHAR (16)       NULL,
    [agmfg_user_rev_dt] INT             NULL,
    [A4GLIdentity]      NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agmfgmst] PRIMARY KEY NONCLUSTERED ([agmfg_loc_no] ASC, [agmfg_itm_no] ASC, [agmfg_rev_dt] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iagmfgmst0]
    ON [dbo].[agmfgmst]([agmfg_loc_no] ASC, [agmfg_itm_no] ASC, [agmfg_rev_dt] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agmfgmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agmfgmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agmfgmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agmfgmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[agmfgmst] TO PUBLIC
    AS [dbo];

