CREATE TABLE [dbo].[cfitmmst] (
    [cfitm_site_no]                 CHAR (15)       NOT NULL,
    [cfitm_prod_no]                 CHAR (4)        NOT NULL,
    [cfitm_ar_itm_no]               CHAR (10)       NULL,
    [cfitm_opis1_average]           DECIMAL (11, 5) NULL,
    [cfitm_opis1_rev_dt]            INT             NULL,
    [cfitm_opis2_average]           DECIMAL (11, 5) NULL,
    [cfitm_opis2_rev_dt]            INT             NULL,
    [cfitm_opis3_average]           DECIMAL (11, 5) NULL,
    [cfitm_opis3_rev_dt]            INT             NULL,
    [cfitm_local_price]             DECIMAL (11, 5) NULL,
    [cfitm_pump_price]              DECIMAL (11, 5) NULL,
    [cfitm_carry_neg_bal_yn]        CHAR (1)        NULL,
    [cfitm_include_in_qty_disc_yn]  CHAR (1)        NULL,
    [cfitm_dept_type]               CHAR (1)        NULL,
    [cfitm_override_loc_sst_yn]     CHAR (1)        NULL,
    [cfitm_user_id]                 CHAR (16)       NULL,
    [cfitm_user_rev_dt]             INT             NULL,
    [A4GLIdentity]                  NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    [cfitm_remote_fee_per_tran]     DECIMAL (6, 5)  NULL,
    [cfitm_remote_fee_per_unit]     DECIMAL (6, 5)  NULL,
    [cfitm_ext_remote_fee_per_tran] DECIMAL (6, 5)  NULL,
    [cfitm_ext_remote_fee_per_unit] DECIMAL (6, 5)  NULL
);




GO
CREATE UNIQUE CLUSTERED INDEX [Icfitmmst0]
    ON [dbo].[cfitmmst]([cfitm_site_no] ASC, [cfitm_prod_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[cfitmmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[cfitmmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[cfitmmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[cfitmmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[cfitmmst] TO PUBLIC
    AS [dbo];

