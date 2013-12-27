CREATE TABLE [dbo].[cfsd4mst] (
    [cfsd4_host_no]              CHAR (6)       NOT NULL,
    [cfsd4_site_type]            CHAR (1)       NOT NULL,
    [cfsd4_site_cd]              CHAR (15)      NOT NULL,
    [cfsd4_prod_no]              CHAR (4)       NOT NULL,
    [cfsd4_effective_yyyymmdd]   INT            NOT NULL,
    [cfsd4_fet_per_un]           DECIMAL (5, 5) NULL,
    [cfsd4_set1_per_un]          DECIMAL (5, 5) NULL,
    [cfsd4_cot_per_un]           DECIMAL (5, 5) NULL,
    [cfsd4_cit_per_un]           DECIMAL (5, 5) NULL,
    [cfsd4_sst_rt]               DECIMAL (5, 5) NULL,
    [cfsd4_sst_type]             CHAR (1)       NULL,
    [cfsd4_set2_per_un]          DECIMAL (5, 5) NULL,
    [cfsd4_fet_in_xfr_prc_ir]    CHAR (1)       NULL,
    [cfsd4_set1_in_xfr_prc_ir]   CHAR (1)       NULL,
    [cfsd4_cot_in_xfr_prc_ir]    CHAR (1)       NULL,
    [cfsd4_cit_in_xfr_prc_ir]    CHAR (1)       NULL,
    [cfsd4_set2_in_xfr_prc_ir]   CHAR (1)       NULL,
    [cfsd4_fet_in_prc_yn]        CHAR (1)       NULL,
    [cfsd4_set1_in_prc_yn]       CHAR (1)       NULL,
    [cfsd4_cot_in_prc_yn]        CHAR (1)       NULL,
    [cfsd4_cit_in_prc_yn]        CHAR (1)       NULL,
    [cfsd4_set2_in_prc_yn]       CHAR (1)       NULL,
    [cfsd4_sst_in_prc_yn]        CHAR (1)       NULL,
    [cfsd4_un_meas]              CHAR (1)       NULL,
    [cfsd4_cvt_to_gal]           DECIMAL (7, 6) NULL,
    [cfsd4_ppd_sst_rt]           DECIMAL (5, 5) NULL,
    [cfsd4_xfr_prc_beg_yyyymmdd] INT            NULL,
    [cfsd4_xfr_prc_end_yyyymmdd] INT            NULL,
    [cfsd4_xfr_prc]              DECIMAL (7, 5) NULL,
    [cfsd4_other_costs]          DECIMAL (7, 5) NULL,
    [cfsd4_freight_rt]           DECIMAL (7, 5) NULL,
    [cfsd4_icb_margin]           DECIMAL (6, 5) NULL,
    [cfsd4_user_id]              CHAR (16)      NULL,
    [cfsd4_user_rev_dt]          INT            NULL,
    [A4GLIdentity]               NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_cfsd4mst] PRIMARY KEY NONCLUSTERED ([cfsd4_host_no] ASC, [cfsd4_site_type] ASC, [cfsd4_site_cd] ASC, [cfsd4_prod_no] ASC, [cfsd4_effective_yyyymmdd] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Icfsd4mst0]
    ON [dbo].[cfsd4mst]([cfsd4_host_no] ASC, [cfsd4_site_type] ASC, [cfsd4_site_cd] ASC, [cfsd4_prod_no] ASC, [cfsd4_effective_yyyymmdd] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[cfsd4mst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[cfsd4mst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[cfsd4mst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[cfsd4mst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[cfsd4mst] TO PUBLIC
    AS [dbo];

