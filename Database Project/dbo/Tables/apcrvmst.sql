CREATE TABLE [dbo].[apcrvmst] (
    [apcrv_vnd_no]          CHAR (10)   NOT NULL,
    [apcrv_loc_no]          CHAR (3)    NULL,
    [apcrv_batch_no]        TINYINT     NULL,
    [apcrv_cbk_no]          CHAR (2)    NULL,
    [apcrv_ap_type]         CHAR (1)    NULL,
    [apcrv_import_type]     CHAR (1)    NULL,
    [apcrv_import_name]     CHAR (40)   NULL,
    [apcrv_import_path]     CHAR (60)   NULL,
    [apcrv_enter_totals_gn] CHAR (1)    NULL,
    [apcrv_aux_import_name] CHAR (40)   NULL,
    [apcrv_user_id]         CHAR (16)   NULL,
    [apcrv_user_rev_dt]     CHAR (8)    NULL,
    [apcrv_user_time]       SMALLINT    NULL,
    [A4GLIdentity]          NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_apcrvmst] PRIMARY KEY NONCLUSTERED ([apcrv_vnd_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iapcrvmst0]
    ON [dbo].[apcrvmst]([apcrv_vnd_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[apcrvmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[apcrvmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[apcrvmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[apcrvmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[apcrvmst] TO PUBLIC
    AS [dbo];

