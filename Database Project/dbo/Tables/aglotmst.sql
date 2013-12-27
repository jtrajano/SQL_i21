CREATE TABLE [dbo].[aglotmst] (
    [aglot_itm_no]           CHAR (13)       NOT NULL,
    [aglot_loc_no]           CHAR (3)        NOT NULL,
    [aglot_lot_no]           CHAR (16)       NOT NULL,
    [aglot_un_on_hand]       DECIMAL (13, 4) NULL,
    [aglot_comments]         CHAR (30)       NULL,
    [aglot_create_date]      INT             NOT NULL,
    [aglot_expire_date]      INT             NULL,
    [aglot_last_active_date] INT             NULL,
    [aglot_pend_committed]   DECIMAL (13, 4) NULL,
    [aglot_seed_info]        CHAR (100)      NULL,
    [aglot_user_id]          CHAR (16)       NULL,
    [aglot_user_rev_dt]      INT             NULL,
    [A4GLIdentity]           NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_aglotmst] PRIMARY KEY NONCLUSTERED ([aglot_itm_no] ASC, [aglot_loc_no] ASC, [aglot_lot_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iaglotmst0]
    ON [dbo].[aglotmst]([aglot_itm_no] ASC, [aglot_loc_no] ASC, [aglot_lot_no] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iaglotmst1]
    ON [dbo].[aglotmst]([aglot_itm_no] ASC, [aglot_loc_no] ASC, [aglot_create_date] ASC, [aglot_lot_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[aglotmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[aglotmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[aglotmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[aglotmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[aglotmst] TO PUBLIC
    AS [dbo];

