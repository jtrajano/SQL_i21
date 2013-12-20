CREATE TABLE [dbo].[agpaymst] (
    [agpay_cus_no]       CHAR (10)       NOT NULL,
    [agpay_ivc_no]       CHAR (8)        NOT NULL,
    [agpay_ivc_loc_no]   CHAR (3)        NOT NULL,
    [agpay_seq_no]       SMALLINT        NOT NULL,
    [agpay_rev_dt]       INT             NULL,
    [agpay_chk_no]       CHAR (8)        NULL,
    [agpay_amt]          DECIMAL (11, 2) NULL,
    [agpay_acct_no]      DECIMAL (16, 8) NULL,
    [agpay_ref_no]       CHAR (8)        NULL,
    [agpay_orig_rev_dt]  INT             NULL,
    [agpay_cred_ind]     CHAR (1)        NULL,
    [agpay_cred_origin]  CHAR (1)        NULL,
    [agpay_batch_no]     SMALLINT        NULL,
    [agpay_pay_type]     CHAR (1)        NULL,
    [agpay_loc_no]       CHAR (3)        NULL,
    [agpay_note]         CHAR (15)       NULL,
    [agpay_audit_no]     CHAR (4)        NULL,
    [agpay_currency]     CHAR (3)        NULL,
    [agpay_currency_rt]  DECIMAL (15, 8) NULL,
    [agpay_currency_cnt] CHAR (8)        NULL,
    [agpay_user_id]      CHAR (16)       NULL,
    [agpay_user_rev_dt]  INT             NULL,
    [A4GLIdentity]       NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    [agpay_from_ord_yn]  CHAR (1)        NULL,
    CONSTRAINT [k_agpaymst] PRIMARY KEY NONCLUSTERED ([agpay_cus_no] ASC, [agpay_ivc_no] ASC, [agpay_ivc_loc_no] ASC, [agpay_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagpaymst0]
    ON [dbo].[agpaymst]([agpay_cus_no] ASC, [agpay_ivc_no] ASC, [agpay_ivc_loc_no] ASC, [agpay_seq_no] ASC);

