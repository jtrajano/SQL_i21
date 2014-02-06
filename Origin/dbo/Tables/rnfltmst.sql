CREATE TABLE [dbo].[rnfltmst] (
    [rnflt_char_cd]           CHAR (3)        NOT NULL,
    [rnflt_feed_stock]        SMALLINT        NOT NULL,
    [rnflt_batch_no]          INT             NULL,
    [rnflt_fuel_code]         TINYINT         NULL,
    [rnflt_eq_val]            TINYINT         NULL,
    [rnflt_end_gal]           INT             NULL,
    [rnflt_ded_den_yn]        CHAR (1)        NULL,
    [rnflt_pct_den]           DECIMAL (4, 2)  NULL,
    [rnflt_process_cd]        CHAR (4)        NULL,
    [rnflt_uom_cd]            CHAR (3)        NULL,
    [rnflt_renew_biomass_yn]  CHAR (1)        NULL,
    [rnflt_feed_stock_factor] DECIMAL (10, 5) NULL,
    [rnflt_run_no]            INT             NULL,
    [rnflt_user_id]           CHAR (16)       NULL,
    [rnflt_user_rev_dt]       INT             NULL,
    [A4GLIdentity]            NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_rnfltmst] PRIMARY KEY NONCLUSTERED ([rnflt_char_cd] ASC, [rnflt_feed_stock] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Irnfltmst0]
    ON [dbo].[rnfltmst]([rnflt_char_cd] ASC, [rnflt_feed_stock] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[rnfltmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[rnfltmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[rnfltmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[rnfltmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[rnfltmst] TO PUBLIC
    AS [dbo];

