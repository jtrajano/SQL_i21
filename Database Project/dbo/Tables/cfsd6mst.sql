CREATE TABLE [dbo].[cfsd6mst] (
    [cfsd6_host_no]              CHAR (6)       NOT NULL,
    [cfsd6_site_type]            CHAR (1)       NOT NULL,
    [cfsd6_site_cd]              CHAR (15)      NOT NULL,
    [cfsd6_prod_no]              CHAR (4)       NOT NULL,
    [cfsd6_effective_yyyymmdd]   INT            NOT NULL,
    [cfsd6_fet_per_un]           DECIMAL (5, 5) NULL,
    [cfsd6_set1_per_un]          DECIMAL (5, 5) NULL,
    [cfsd6_cot_per_un]           DECIMAL (5, 5) NULL,
    [cfsd6_cit_per_un]           DECIMAL (5, 5) NULL,
    [cfsd6_sst_rt]               DECIMAL (5, 5) NULL,
    [cfsd6_sst_type]             CHAR (1)       NULL,
    [cfsd6_set2_per_un]          DECIMAL (5, 5) NULL,
    [cfsd6_fet_in_xfr_prc_ir]    CHAR (1)       NULL,
    [cfsd6_set1_in_xfr_prc_ir]   CHAR (1)       NULL,
    [cfsd6_cot_in_xfr_prc_ir]    CHAR (1)       NULL,
    [cfsd6_cit_in_xfr_prc_ir]    CHAR (1)       NULL,
    [cfsd6_set2_in_xfr_prc_ir]   CHAR (1)       NULL,
    [cfsd6_fet_in_prc_yn]        CHAR (1)       NULL,
    [cfsd6_set1_in_prc_yn]       CHAR (1)       NULL,
    [cfsd6_cot_in_prc_yn]        CHAR (1)       NULL,
    [cfsd6_cit_in_prc_yn]        CHAR (1)       NULL,
    [cfsd6_set2_in_prc_yn]       CHAR (1)       NULL,
    [cfsd6_sst_in_prc_yn]        CHAR (1)       NULL,
    [cfsd6_un_meas]              CHAR (1)       NULL,
    [cfsd6_cvt_to_gal]           DECIMAL (7, 6) NULL,
    [cfsd6_ppd_sst_rt]           DECIMAL (5, 5) NULL,
    [cfsd6_xfr_prc_beg_yyyymmdd] INT            NULL,
    [cfsd6_xfr_prc_end_yyyymmdd] INT            NULL,
    [cfsd6_xfr_prc]              DECIMAL (9, 5) NULL,
    [cfsd6_other_costs]          DECIMAL (9, 5) NULL,
    [cfsd6_freight_rt]           DECIMAL (7, 5) NULL,
    [cfsd6_icb_margin]           DECIMAL (6, 5) NULL,
    [cfsd6_user_id]              CHAR (16)      NULL,
    [cfsd6_user_rev_dt]          INT            NULL,
    [A4GLIdentity]               NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_cfsd6mst] PRIMARY KEY NONCLUSTERED ([cfsd6_host_no] ASC, [cfsd6_site_type] ASC, [cfsd6_site_cd] ASC, [cfsd6_prod_no] ASC, [cfsd6_effective_yyyymmdd] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Icfsd6mst0]
    ON [dbo].[cfsd6mst]([cfsd6_host_no] ASC, [cfsd6_site_type] ASC, [cfsd6_site_cd] ASC, [cfsd6_prod_no] ASC, [cfsd6_effective_yyyymmdd] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[cfsd6mst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[cfsd6mst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[cfsd6mst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[cfsd6mst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[cfsd6mst] TO PUBLIC
    AS [dbo];

