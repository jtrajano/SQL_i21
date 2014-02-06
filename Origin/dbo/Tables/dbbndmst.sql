CREATE TABLE [dbo].[dbbndmst] (
    [dbbnd_cus_no]              CHAR (10)      NOT NULL,
    [dbbnd_series]              CHAR (4)       NOT NULL,
    [dbbnd_bond_no]             INT            NOT NULL,
    [dbbnd_face_amt]            DECIMAL (9, 2) NULL,
    [dbbnd_int_rt]              DECIMAL (7, 4) NULL,
    [dbbnd_issue_rev_dt]        INT            NULL,
    [dbbnd_maturity_rev_dt]     INT            NOT NULL,
    [dbbnd_withhold_yn]         CHAR (1)       NULL,
    [dbbnd_cyr_int_pd]          DECIMAL (9, 2) NULL,
    [dbbnd_cyr_withhold]        DECIMAL (9, 2) NULL,
    [dbbnd_lyr_int_pd]          DECIMAL (9, 2) NULL,
    [dbbnd_lyr_withhold]        DECIMAL (9, 2) NULL,
    [dbbnd_activity_cd]         CHAR (1)       NULL,
    [dbbnd_ret_chk_no]          CHAR (8)       NULL,
    [dbbnd_ret_trx_ind]         CHAR (1)       NULL,
    [dbbnd_ret_chk_rev_dt]      INT            NULL,
    [dbbnd_ret_chk_amt]         DECIMAL (9, 2) NULL,
    [dbbnd_xfer_to_cus_no]      CHAR (10)      NULL,
    [dbbnd_xfer_to_rev_dt]      INT            NULL,
    [dbbnd_roll_bond_no]        CHAR (10)      NULL,
    [dbbnd_roll_rev_dt]         INT            NULL,
    [dbbnd_xfer_from_cus_no]    CHAR (10)      NULL,
    [dbbnd_xfer_from_rev_dt]    INT            NULL,
    [dbbnd_calc_int_amt]        DECIMAL (9, 2) NULL,
    [dbbnd_calc_int_rev_dt]     INT            NULL,
    [dbbnd_calc_int_chk_no]     CHAR (8)       NULL,
    [dbbnd_calc_int_trx_ind]    CHAR (1)       NULL,
    [dbbnd_calc_withhold]       DECIMAL (9, 2) NULL,
    [dbbnd_calc_int_chk_amt]    DECIMAL (9, 2) NULL,
    [dbbnd_last_int_amt]        DECIMAL (9, 2) NULL,
    [dbbnd_last_int_rev_dt]     INT            NULL,
    [dbbnd_last_int_chk_no]     CHAR (8)       NULL,
    [dbbnd_last_int_trx_ind]    CHAR (1)       NULL,
    [dbbnd_last_withhold]       DECIMAL (9, 2) NULL,
    [dbbnd_last_int_chk_amt]    DECIMAL (9, 2) NULL,
    [dbbnd_xfer_from_bond_no]   CHAR (10)      NULL,
    [dbbnd_ltd_int_accr_amt]    DECIMAL (9, 2) NULL,
    [dbbnd_last_int_chk_rev_dt] INT            NULL,
    [dbbnd_cyr_penalties]       DECIMAL (9, 2) NULL,
    [dbbnd_lyr_penalties]       DECIMAL (9, 2) NULL,
    [dbbnd_user_id]             CHAR (16)      NULL,
    [dbbnd_user_rev_dt]         INT            NULL,
    [A4GLIdentity]              NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_dbbndmst] PRIMARY KEY NONCLUSTERED ([dbbnd_cus_no] ASC, [dbbnd_series] ASC, [dbbnd_bond_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Idbbndmst0]
    ON [dbo].[dbbndmst]([dbbnd_cus_no] ASC, [dbbnd_series] ASC, [dbbnd_bond_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Idbbndmst1]
    ON [dbo].[dbbndmst]([dbbnd_series] ASC, [dbbnd_bond_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Idbbndmst2]
    ON [dbo].[dbbndmst]([dbbnd_maturity_rev_dt] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[dbbndmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[dbbndmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[dbbndmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[dbbndmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[dbbndmst] TO PUBLIC
    AS [dbo];

