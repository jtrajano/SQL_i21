CREATE TABLE [dbo].[cfnetmst] (
    [cfnet_network_id]               CHAR (3)        NOT NULL,
    [cfnet_network_type]             CHAR (1)        NULL,
    [cfnet_network_desc]             CHAR (30)       NULL,
    [cfnet_ar_cus_no]                CHAR (10)       NULL,
    [cfnet_ca_ar_cus_no]             CHAR (10)       NULL,
    [cfnet_db_gl_acct]               DECIMAL (16, 8) NULL,
    [cfnet_ft_loc_no]                CHAR (3)        NULL,
    [cfnet_rt_fee_amt]               DECIMAL (4, 2)  NULL,
    [cfnet_rt_fee_gal]               DECIMAL (6, 5)  NULL,
    [cfnet_ft_fee_gal]               DECIMAL (6, 5)  NULL,
    [cfnet_monthly_comm_fee_amt]     DECIMAL (5, 2)  NULL,
    [cfnet_variable_comm_fee_gal]    DECIMAL (6, 5)  NULL,
    [cfnet_import_path]              CHAR (50)       NULL,
    [cfnet_last_import_date]         INT             NULL,
    [cfnet_error_batch_no]           SMALLINT        NULL,
    [cfnet_pp_host_id]               CHAR (6)        NULL,
    [cfnet_pp_sub_dist_site]         CHAR (15)       NULL,
    [cfnet_pp_file_import_type]      CHAR (1)        NULL,
    [cfnet_export_card_rejects_yn]   CHAR (1)        NULL,
    [cfnet_reject_path]              CHAR (40)       NULL,
    [cfnet_participant]              CHAR (3)        NULL,
    [cfnet_cfn_file_version]         CHAR (1)        NULL,
    [cfnet_passon_sst_from_remotes]  CHAR (1)        NULL,
    [cfnet_exempt_fet_on_remotes_yn] CHAR (1)        NULL,
    [cfnet_exempt_set_on_remotes_yn] CHAR (1)        NULL,
    [cfnet_exempt_lc_on_remotes_yn]  CHAR (1)        NULL,
    [cfnet_exempt_lc_code]           CHAR (4)        NULL,
    [cfnet_user_id]                  CHAR (16)       NULL,
    [cfnet_user_rev_dt]              INT             NULL,
    [A4GLIdentity]                   NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_cfnetmst] PRIMARY KEY NONCLUSTERED ([cfnet_network_id] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Icfnetmst0]
    ON [dbo].[cfnetmst]([cfnet_network_id] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[cfnetmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[cfnetmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[cfnetmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[cfnetmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[cfnetmst] TO PUBLIC
    AS [dbo];

