CREATE TABLE [dbo].[agpyemst] (
    [agpye_cus_no]       CHAR (10)       NOT NULL,
    [agpye_inc_ref]      CHAR (8)        NOT NULL,
    [agpye_ivc_loc_no]   CHAR (3)        NOT NULL,
    [agpye_seq_no]       SMALLINT        NOT NULL,
    [agpye_rec_type]     CHAR (1)        NULL,
    [agpye_rev_dt]       INT             NULL,
    [agpye_chk_no]       CHAR (8)        NULL,
    [agpye_amt]          DECIMAL (11, 2) NULL,
    [agpye_acct_no]      DECIMAL (16, 8) NULL,
    [agpye_ref_no]       CHAR (8)        NULL,
    [agpye_orig_rev_dt]  INT             NULL,
    [agpye_cred_ind]     CHAR (1)        NULL,
    [agpye_cred_origin]  CHAR (1)        NULL,
    [agpye_batch_no]     SMALLINT        NULL,
    [agpye_oth_inc_cd]   CHAR (2)        NULL,
    [agpye_note]         CHAR (15)       NULL,
    [agpye_pay_type]     CHAR (1)        NULL,
    [agpye_loc_no]       CHAR (3)        NULL,
    [agpye_pay_seq_no]   SMALLINT        NULL,
    [agpye_cr_seq_no]    SMALLINT        NULL,
    [agpye_sys_rev_dt]   INT             NULL,
    [agpye_sys_time]     INT             NULL,
    [agpye_currency]     CHAR (3)        NULL,
    [agpye_currency_rt]  DECIMAL (15, 8) NULL,
    [agpye_currency_cnt] CHAR (8)        NULL,
    [agpye_user_id]      CHAR (16)       NULL,
    [agpye_user_rev_dt]  INT             NULL,
    [A4GLIdentity]       NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agpyemst] PRIMARY KEY NONCLUSTERED ([agpye_cus_no] ASC, [agpye_inc_ref] ASC, [agpye_ivc_loc_no] ASC, [agpye_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagpyemst0]
    ON [dbo].[agpyemst]([agpye_cus_no] ASC, [agpye_inc_ref] ASC, [agpye_ivc_loc_no] ASC, [agpye_seq_no] ASC);

