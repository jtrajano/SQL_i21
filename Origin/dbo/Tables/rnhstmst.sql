CREATE TABLE [dbo].[rnhstmst] (
    [rnhst_yr_prod]          SMALLINT       NOT NULL,
    [rnhst_co_epa_id]        CHAR (4)       NOT NULL,
    [rnhst_fac_id]           CHAR (5)       NOT NULL,
    [rnhst_fuel_type]        CHAR (6)       NOT NULL,
    [rnhst_batch_no]         INT            NOT NULL,
    [rnhst_beg_gal]          INT            NOT NULL,
    [rnhst_end_gal]          INT            NOT NULL,
    [rnhst_seq_no]           SMALLINT       NOT NULL,
    [rnhst_kcode]            TINYINT        NULL,
    [rnhst_eq_val]           TINYINT        NULL,
    [rnhst_fuel_code]        TINYINT        NULL,
    [rnhst_rcvd_rev_dt]      INT            NULL,
    [rnhst_chgd_rev_dt]      INT            NULL,
    [rnhst_act_type]         CHAR (2)       NULL,
    [rnhst_ret_cat]          CHAR (3)       NULL,
    [rnhst_trading_partn]    CHAR (4)       NULL,
    [rnhst_trade_partn_name] CHAR (30)      NULL,
    [rnhst_vol]              INT            NULL,
    [rnhst_denaturant_vol]   INT            NULL,
    [rnhst_beg_rin_gal]      INT            NULL,
    [rnhst_end_rin_gal]      INT            NULL,
    [rnhst_submit_yn]        CHAR (1)       NULL,
    [rnhst_comment1]         CHAR (30)      NULL,
    [rnhst_comment2]         CHAR (30)      NULL,
    [rnhst_system_ind]       CHAR (2)       NULL,
    [rnhst_corrected_yn]     CHAR (1)       NULL,
    [rnhst_act_rev_dt]       INT            NULL,
    [rnhst_cus_no]           CHAR (10)      NOT NULL,
    [rnhst_ivc_no]           CHAR (8)       NOT NULL,
    [rnhst_loc_no]           CHAR (3)       NOT NULL,
    [rnhst_ivc_line_no]      SMALLINT       NOT NULL,
    [rnhst_vnd_no]           CHAR (10)      NOT NULL,
    [rnhst_po_no]            CHAR (8)       NOT NULL,
    [rnhst_receipt_seq]      TINYINT        NOT NULL,
    [rnhst_po_line_no]       SMALLINT       NOT NULL,
    [rnhst_submit_dt]        INT            NULL,
    [rnhst_submit_time]      INT            NULL,
    [rnhst_comp_cd]          CHAR (3)       NULL,
    [rnhst_bs_reason_cd]     CHAR (3)       NULL,
    [rnhst_sep_reason_cd]    CHAR (3)       NULL,
    [rnhst_un_prc]           DECIMAL (9, 4) NULL,
    [rnhst_comp_yr]          CHAR (4)       NULL,
    [rnhst_user_id]          CHAR (16)      NULL,
    [rnhst_user_rev_dt]      INT            NULL,
    [A4GLIdentity]           NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_rnhstmst] PRIMARY KEY NONCLUSTERED ([rnhst_yr_prod] ASC, [rnhst_co_epa_id] ASC, [rnhst_fac_id] ASC, [rnhst_fuel_type] ASC, [rnhst_batch_no] ASC, [rnhst_beg_gal] ASC, [rnhst_end_gal] ASC, [rnhst_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Irnhstmst0]
    ON [dbo].[rnhstmst]([rnhst_yr_prod] ASC, [rnhst_co_epa_id] ASC, [rnhst_fac_id] ASC, [rnhst_fuel_type] ASC, [rnhst_batch_no] ASC, [rnhst_beg_gal] ASC, [rnhst_end_gal] ASC, [rnhst_seq_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Irnhstmst1]
    ON [dbo].[rnhstmst]([rnhst_cus_no] ASC, [rnhst_ivc_no] ASC, [rnhst_loc_no] ASC, [rnhst_ivc_line_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Irnhstmst2]
    ON [dbo].[rnhstmst]([rnhst_vnd_no] ASC, [rnhst_po_no] ASC, [rnhst_receipt_seq] ASC, [rnhst_po_line_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[rnhstmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[rnhstmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[rnhstmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[rnhstmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[rnhstmst] TO PUBLIC
    AS [dbo];

