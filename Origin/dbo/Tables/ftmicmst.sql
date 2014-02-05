CREATE TABLE [dbo].[ftmicmst] (
    [ftmic_itm_no]               CHAR (13)       NOT NULL,
    [ftmic_loc_no]               CHAR (3)        NOT NULL,
    [ftmic_item_type]            CHAR (1)        NULL,
    [ftmic_density]              DECIMAL (6, 2)  NULL,
    [ftmic_nitrogen_pct]         DECIMAL (4, 2)  NULL,
    [ftmic_p205_pct]             DECIMAL (4, 2)  NULL,
    [ftmic_k20_pct]              DECIMAL (4, 2)  NULL,
    [ftmic_magnesium_pct]        DECIMAL (4, 2)  NULL,
    [ftmic_boron_pct]            DECIMAL (4, 2)  NULL,
    [ftmic_manganese_pct]        DECIMAL (4, 2)  NULL,
    [ftmic_zinc_pct]             DECIMAL (4, 2)  NULL,
    [ftmic_sulfur_pct]           DECIMAL (4, 2)  NULL,
    [ftmic_iron_pct]             DECIMAL (4, 2)  NULL,
    [ftmic_copper_pct]           DECIMAL (4, 2)  NULL,
    [ftmic_calcium_pct]          DECIMAL (4, 2)  NULL,
    [ftmic_lime_pct]             DECIMAL (4, 2)  NULL,
    [ftmic_min_app_rate]         DECIMAL (6, 2)  NULL,
    [ftmic_app_rate_un]          CHAR (3)        NULL,
    [ftmic_max_app_rate]         DECIMAL (6, 2)  NULL,
    [ftmic_max_app_rate_un]      CHAR (3)        NULL,
    [ftmic_no_reentry]           SMALLINT        NULL,
    [ftmic_mfg_name]             CHAR (20)       NULL,
    [ftmic_mfg_phone]            CHAR (15)       NULL,
    [ftmic_hazmat_mesg_id]       CHAR (8)        NULL,
    [ftmic_app_un_per_inv_un]    DECIMAL (10, 6) NULL,
    [ftmic_restrict_crop_yn]     CHAR (1)        NULL,
    [ftmic_use_min_amts_yn]      CHAR (1)        NULL,
    [ftmic_min_chg_amt]          DECIMAL (6, 2)  NULL,
    [ftmic_app_unit_weight]      DECIMAL (8, 4)  NULL,
    [ftmic_app_rate_per_100_gal] DECIMAL (6, 2)  NULL,
    [ftmic_user_id]              CHAR (13)       NULL,
    [ftmic_user_rev_dt]          CHAR (8)        NULL,
    [A4GLIdentity]               NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_ftmicmst] PRIMARY KEY NONCLUSTERED ([ftmic_itm_no] ASC, [ftmic_loc_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iftmicmst0]
    ON [dbo].[ftmicmst]([ftmic_itm_no] ASC, [ftmic_loc_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[ftmicmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ftmicmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ftmicmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ftmicmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ftmicmst] TO PUBLIC
    AS [dbo];

