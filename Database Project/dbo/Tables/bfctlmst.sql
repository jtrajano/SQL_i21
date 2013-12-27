CREATE TABLE [dbo].[bfctlmst] (
    [bfctl_key_n]            TINYINT        NOT NULL,
    [bfctl_password]         CHAR (8)       NULL,
    [bfctl_export_path]      CHAR (50)      NULL,
    [bfctl_loc_order_yn]     CHAR (1)       NULL,
    [bfctl_dflt_cash_prc_yn] CHAR (1)       NULL,
    [bfctl_dflt_fut_prc_yn]  CHAR (1)       NULL,
    [bfctl_cutoff_rev_dt]    INT            NULL,
    [bfctl_rev_dt_1]         INT            NULL,
    [bfctl_rev_dt_2]         INT            NULL,
    [bfctl_rev_dt_3]         INT            NULL,
    [bfctl_rev_dt_4]         INT            NULL,
    [bfctl_rev_dt_5]         INT            NULL,
    [bfctl_rev_dt_6]         INT            NULL,
    [bfctl_rev_dt_7]         INT            NULL,
    [bfctl_rev_dt_8]         INT            NULL,
    [bfctl_rev_dt_9]         INT            NULL,
    [bfctl_rev_dt_10]        INT            NULL,
    [bfctl_rev_dt_11]        INT            NULL,
    [bfctl_rev_dt_12]        INT            NULL,
    [bfctl_prod_com_cd]      CHAR (3)       NULL,
    [bfctl_prod_daily_gals]  INT            NULL,
    [bfctl_prod_yield]       DECIMAL (9, 6) NULL,
    [bfctl_in_com_cd]        CHAR (3)       NULL,
    [bfctl_out_com_cd]       CHAR (3)       NULL,
    [bfctl_out_yield]        DECIMAL (9, 6) NULL,
    [bfctl_out2_com_cd]      CHAR (3)       NULL,
    [bfctl_out2_yield]       DECIMAL (9, 6) NULL,
    [bfctl_exp_com_cd]       CHAR (3)       NULL,
    [bfctl_exp_daily_usage]  INT            NULL,
    [bfctl_exp2_com_cd]      CHAR (3)       NULL,
    [bfctl_exp2_daily_usage] INT            NULL,
    [A4GLIdentity]           NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_bfctlmst] PRIMARY KEY NONCLUSTERED ([bfctl_key_n] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Ibfctlmst0]
    ON [dbo].[bfctlmst]([bfctl_key_n] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[bfctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[bfctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[bfctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[bfctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[bfctlmst] TO PUBLIC
    AS [dbo];

