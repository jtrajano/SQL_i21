CREATE TABLE [dbo].[rnctlmst] (
    [rnctl_key]                TINYINT        NOT NULL,
    [rnctl_corp_epa_id]        CHAR (4)       NULL,
    [rnctl_yr_prod]            SMALLINT       NULL,
    [rnctl_co_name]            CHAR (30)      NULL,
    [rnctl_fac_id]             CHAR (5)       NULL,
    [rnctl_fac_name]           CHAR (30)      NULL,
    [rnctl_prior_yr_deficit]   BIGINT         NULL,
    [rnctl_cur_yr_deficit]     BIGINT         NULL,
    [rnctl_prior_yr_rins]      BIGINT         NULL,
    [rnctl_cur_yr_rins]        BIGINT         NULL,
    [rnctl_btch_amt_left]      INT            NULL,
    [rnctl_ethanol_yn]         CHAR (1)       NULL,
    [rnctl_blend_yn]           CHAR (1)       NULL,
    [rnctl_exporter_yn]        CHAR (1)       NULL,
    [rnctl_file_path]          CHAR (50)      NULL,
    [rnctl_retain_rin_yn]      CHAR (1)       NULL,
    [rnctl_curr_fuel_std]      DECIMAL (4, 2) NULL,
    [rnctl_last_submit_rev_dt] INT            NULL,
    [rnctl_emts_login_id]      CHAR (20)      NULL,
    [rnctl_iss_man_yn]         CHAR (1)       NULL,
    [rnctl_user_id]            CHAR (16)      NULL,
    [rnctl_user_rev_dt]        CHAR (8)       NULL,
    [A4GLIdentity]             NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_rnctlmst] PRIMARY KEY NONCLUSTERED ([rnctl_key] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Irnctlmst0]
    ON [dbo].[rnctlmst]([rnctl_key] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[rnctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[rnctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[rnctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[rnctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[rnctlmst] TO PUBLIC
    AS [dbo];

