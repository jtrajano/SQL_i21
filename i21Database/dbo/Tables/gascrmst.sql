CREATE TABLE [dbo].[gascrmst] (
    [gascr_loc_no]         CHAR (3)    NOT NULL,
    [gascr_scale_id]       CHAR (1)    NOT NULL,
    [gascr_scale_desc]     CHAR (30)   NULL,
    [gascr_gatmp_rec_size] SMALLINT    NULL,
    [gascr_gadev_rec_size] SMALLINT    NULL,
    [gascr_mo_det_yn]      CHAR (1)    NULL,
    [gascr_mo_fix_var_fv]  CHAR (1)    NULL,
    [gascr_mo_sz]          TINYINT     NULL,
    [gascr_mo_start_pos]   SMALLINT    NULL,
    [gascr_mo_desc]        CHAR (6)    NULL,
    [gascr_wp_det_yn]      CHAR (1)    NULL,
    [gascr_wp_fix_var_fv]  CHAR (1)    NULL,
    [gascr_wp_sz]          TINYINT     NULL,
    [gascr_wp_start_pos]   SMALLINT    NULL,
    [gascr_wp_desc]        CHAR (6)    NULL,
    [gascr_nu_det_yn]      CHAR (1)    NULL,
    [gascr_nu_fix_var_fv]  CHAR (1)    NULL,
    [gascr_nu_sz]          TINYINT     NULL,
    [gascr_nu_start_pos]   SMALLINT    NULL,
    [gascr_wv_det_yn]      CHAR (1)    NULL,
    [gascr_wv_fix_var_fv]  CHAR (1)    NULL,
    [gascr_wv_sz]          TINYINT     NULL,
    [gascr_wv_start_pos]   SMALLINT    NULL,
    [gascr_wv_desc]        CHAR (6)    NULL,
    [gascr_wr_fix_var_fv]  CHAR (1)    NULL,
    [gascr_wr_sz]          TINYINT     NULL,
    [gascr_wr_start_pos]   SMALLINT    NULL,
    [gascr_wr_desc]        CHAR (6)    NULL,
    [gascr_dt_det_yn]      CHAR (1)    NULL,
    [gascr_dt_fix_var_fv]  CHAR (1)    NULL,
    [gascr_dt_sz]          TINYINT     NULL,
    [gascr_dt_start_pos]   SMALLINT    NULL,
    [gascr_dt_desc]        CHAR (6)    NULL,
    [gascr_repeat_wgt]     TINYINT     NULL,
    [gascr_user_id]        CHAR (16)   NULL,
    [gascr_user_rev_dt]    INT         NULL,
    [A4GLIdentity]         NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gascrmst] PRIMARY KEY NONCLUSTERED ([gascr_loc_no] ASC, [gascr_scale_id] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igascrmst0]
    ON [dbo].[gascrmst]([gascr_loc_no] ASC, [gascr_scale_id] ASC);

