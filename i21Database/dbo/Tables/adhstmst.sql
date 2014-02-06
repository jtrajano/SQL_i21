CREATE TABLE [dbo].[adhstmst] (
    [adhst_cus_no]        CHAR (10)      NOT NULL,
    [adhst_itm_no]        CHAR (13)      NOT NULL,
    [adhst_tank_no]       CHAR (4)       NOT NULL,
    [adhst_rev_dt]        INT            NOT NULL,
    [adhst_last_dd]       INT            NULL,
    [adhst_last_gals]     INT            NULL,
    [adhst_last_burn_rt]  DECIMAL (5, 2) NULL,
    [adhst_last_pct_full] SMALLINT       NULL,
    [adhst_elapsed_dd]    INT            NULL,
    [adhst_elapsed_days]  SMALLINT       NULL,
    [adhst_last_itm_no]   CHAR (13)      NULL,
    [adhst_last_ivc_no]   CHAR (8)       NULL,
    [adhst_last_loc_no]   CHAR (3)       NULL,
    [adhst_season_ind]    CHAR (1)       NULL,
    [adhst_user_id]       CHAR (16)      NULL,
    [adhst_user_rev_dt]   CHAR (8)       NULL,
    [A4GLIdentity]        NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_adhstmst] PRIMARY KEY NONCLUSTERED ([adhst_cus_no] ASC, [adhst_itm_no] ASC, [adhst_tank_no] ASC, [adhst_rev_dt] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iadhstmst0]
    ON [dbo].[adhstmst]([adhst_cus_no] ASC, [adhst_itm_no] ASC, [adhst_tank_no] ASC, [adhst_rev_dt] ASC);


GO
CREATE NONCLUSTERED INDEX [Iadhstmst1]
    ON [dbo].[adhstmst]([adhst_rev_dt] ASC);

