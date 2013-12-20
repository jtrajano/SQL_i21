CREATE TABLE [dbo].[etctlmst] (
    [etctl_key]                  TINYINT        NOT NULL,
    [etctl_cus_acct_stat]        CHAR (10)      NULL,
    [etctl_import_max_copy]      SMALLINT       NULL,
    [etctl_import_next_copy]     SMALLINT       NULL,
    [etctl_last_cus_export_dt]   INT            NULL,
    [etctl_import_path]          CHAR (50)      NULL,
    [etctl_export_path]          CHAR (50)      NULL,
    [etctl_archive_path]         CHAR (50)      NULL,
    [etctl_upload_path]          CHAR (50)      NULL,
    [etctl_invoice_path]         CHAR (50)      NULL,
    [etctl_beg_cnt_cls_cd]       CHAR (3)       NULL,
    [etctl_end_cnt_cls_cd]       CHAR (3)       NULL,
    [etctl_wet_cus_acct_stat]    CHAR (10)      NULL,
    [etctl_cf_trans_yn]          CHAR (1)       NULL,
    [etctl_dlvry_pickup_ind]     CHAR (1)       NULL,
    [etctl_match_orders]         CHAR (1)       NULL,
    [etctl_unmatched_trans]      CHAR (1)       NULL,
    [etctl_export_interval]      TINYINT        NULL,
    [etctl_ae_sst_item]          CHAR (10)      NULL,
    [etctl_ae_csd_min]           DECIMAL (5, 2) NULL,
    [etctl_ovd_cnt_sst_yn]       CHAR (1)       NULL,
    [etctl_restrct_multi_loc_yn] CHAR (1)       NULL,
    [etctl_track_drvr_as_slsmn]  CHAR (1)       NULL,
    [A4GLIdentity]               NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_etctlmst] PRIMARY KEY NONCLUSTERED ([etctl_key] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ietctlmst0]
    ON [dbo].[etctlmst]([etctl_key] ASC);

