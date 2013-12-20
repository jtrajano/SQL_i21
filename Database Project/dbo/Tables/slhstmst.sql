CREATE TABLE [dbo].[slhstmst] (
    [slhst_slnam_key]       CHAR (10)      NOT NULL,
    [slhst_slloc_key]       CHAR (10)      NOT NULL,
    [slhst_rev_dt]          INT            NOT NULL,
    [slhst_tie_breaker]     SMALLINT       NOT NULL,
    [slhst_rec_type]        CHAR (1)       NULL,
    [slhst_call_origin_ut]  CHAR (1)       NULL,
    [slhst_who]             CHAR (25)      NULL,
    [slhst_contact_made_yn] CHAR (1)       NULL,
    [slhst_note_group]      CHAR (220)     NULL,
    [slhst_sls_cycle_cd]    TINYINT        NULL,
    [slhst_list_amt]        DECIMAL (9, 2) NULL,
    [slhst_sell_amt]        DECIMAL (9, 2) NULL,
    [slhst_est_gp_amt]      DECIMAL (9, 2) NULL,
    [slhst_wrk_slsmn_id]    CHAR (3)       NULL,
    [slhst_marketing_src]   CHAR (6)       NULL,
    [slhst_qte_exp_rev_dt]  INT            NULL,
    [slhst_logon_name]      CHAR (12)      NULL,
    [slhst_stamp_time_hhmm] SMALLINT       NULL,
    [slhst_for_rev_ser]     INT            NULL,
    [slhst_for_rev_sw]      INT            NULL,
    [slhst_for_rev_hw]      INT            NULL,
    [slhst_deal_stat_cmnt]  CHAR (36)      NULL,
    [slhst_sec_access_yn]   CHAR (1)       NULL,
    [slhst_user_id]         CHAR (16)      NULL,
    [slhst_user_rev_dt]     INT            NULL,
    [A4GLIdentity]          NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_slhstmst] PRIMARY KEY NONCLUSTERED ([slhst_slnam_key] ASC, [slhst_slloc_key] ASC, [slhst_rev_dt] ASC, [slhst_tie_breaker] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Islhstmst0]
    ON [dbo].[slhstmst]([slhst_slnam_key] ASC, [slhst_slloc_key] ASC, [slhst_rev_dt] ASC, [slhst_tie_breaker] ASC);

