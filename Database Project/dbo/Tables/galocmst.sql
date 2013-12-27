CREATE TABLE [dbo].[galocmst] (
    [galoc_loc_no]               CHAR (3)        NOT NULL,
    [galoc_desc]                 CHAR (20)       NULL,
    [galoc_gl_profit_center]     INT             NULL,
    [galoc_disc_schd_loc]        CHAR (3)        NULL,
    [galoc_stor_schd_loc]        CHAR (3)        NULL,
    [galoc_def_stor_type]        CHAR (1)        NULL,
    [galoc_gl_cash]              DECIMAL (16, 8) NULL,
    [galoc_gl_dep]               DECIMAL (16, 8) NULL,
    [galoc_gl_ar]                DECIMAL (16, 8) NULL,
    [galoc_gl_ap]                DECIMAL (16, 8) NULL,
    [galoc_gl_sls_adv]           DECIMAL (16, 8) NULL,
    [galoc_gl_pur_adv]           DECIMAL (16, 8) NULL,
    [galoc_gl_frt_ap]            DECIMAL (16, 8) NULL,
    [galoc_gl_wthhld]            DECIMAL (16, 8) NULL,
    [galoc_last_tic_no]          CHAR (10)       NULL,
    [galoc_last_load_no]         INT             NULL,
    [galoc_direct_ship_yn]       CHAR (1)        NULL,
    [galoc_scale_interfaced_yn]  CHAR (1)        NULL,
    [galoc_def_scale_id]         CHAR (1)        NULL,
    [galoc_state]                CHAR (2)        NULL,
    [galoc_dflt_batch_no]        SMALLINT        NULL,
    [galoc_cwb_co_cd]            CHAR (3)        NULL,
    [galoc_cwb_province]         CHAR (1)        NULL,
    [galoc_cwb_pur_cd]           CHAR (1)        NULL,
    [galoc_cwb_station_cd]       CHAR (6)        NULL,
    [galoc_dir_scale_tic_prt_yn] CHAR (1)        NULL,
    [galoc_dflt_cnt_prtr]        CHAR (80)       NULL,
    [galoc_dflt_inv_prtr]        CHAR (80)       NULL,
    [galoc_dflt_mkt_zone]        CHAR (3)        NULL,
    [galoc_user_id]              CHAR (16)       NULL,
    [galoc_user_rev_dt]          CHAR (8)        NULL,
    [A4GLIdentity]               NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    [galoc_active_yn]            CHAR (1)        NULL,
    CONSTRAINT [k_galocmst] PRIMARY KEY NONCLUSTERED ([galoc_loc_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Igalocmst0]
    ON [dbo].[galocmst]([galoc_loc_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[galocmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[galocmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[galocmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[galocmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[galocmst] TO PUBLIC
    AS [dbo];

