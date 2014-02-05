﻿CREATE TABLE [dbo].[cfccdmst] (
    [cfccd_site_no]           CHAR (15)   NOT NULL,
    [cfccd_visa_ar_cus_no]    CHAR (10)   NULL,
    [cfccd_mc_ar_cus_no]      CHAR (10)   NULL,
    [cfccd_disc_ar_cus_no]    CHAR (10)   NULL,
    [cfccd_ae_ar_cus_no]      CHAR (10)   NULL,
    [cfccd_we_ar_cus_no]      CHAR (10)   NULL,
    [cfccd_voy_ar_cus_no]     CHAR (10)   NULL,
    [cfccd_phh_ar_cus_no]     CHAR (10)   NULL,
    [cfccd_fm_ar_cus_no]      CHAR (10)   NULL,
    [cfccd_cenex_ar_cus_no]   CHAR (10)   NULL,
    [cfccd_syntex_ar_cus_no]  CHAR (10)   NULL,
    [cfccd_homegr_ar_cus_no]  CHAR (10)   NULL,
    [cfccd_comdata_ar_cus_no] CHAR (10)   NULL,
    [cfccd_undef_ar_cus_no]   CHAR (10)   NULL,
    [cfccd_user_id]           CHAR (16)   NULL,
    [cfccd_user_rev_dt]       INT         NULL,
    [A4GLIdentity]            NUMERIC (9) IDENTITY (1, 1) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Icfccdmst0]
    ON [dbo].[cfccdmst]([cfccd_site_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[cfccdmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[cfccdmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[cfccdmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[cfccdmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[cfccdmst] TO PUBLIC
    AS [dbo];

