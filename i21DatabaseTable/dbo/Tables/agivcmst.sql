CREATE TABLE [dbo].[agivcmst] (
    [agivc_bill_to_cus]     CHAR (10)       NOT NULL,
    [agivc_ivc_no]          CHAR (8)        NOT NULL,
    [agivc_loc_no]          CHAR (3)        NOT NULL,
    [agivc_type]            CHAR (1)        NULL,
    [agivc_status]          CHAR (1)        NULL,
    [agivc_rev_dt]          INT             NULL,
    [agivc_comment]         CHAR (30)       NULL,
    [agivc_po_no]           CHAR (15)       NULL,
    [agivc_sold_to_cus]     CHAR (10)       NULL,
    [agivc_slsmn_no]        CHAR (3)        NULL,
    [agivc_slsmn_tot]       DECIMAL (11, 2) NULL,
    [agivc_net_amt]         DECIMAL (11, 2) NULL,
    [agivc_slstx_amt]       DECIMAL (9, 2)  NULL,
    [agivc_srvchr_amt]      DECIMAL (9, 2)  NULL,
    [agivc_disc_amt]        DECIMAL (9, 2)  NULL,
    [agivc_amt_paid]        DECIMAL (11, 2) NULL,
    [agivc_bal_due]         DECIMAL (11, 2) NULL,
    [agivc_pend_disc]       DECIMAL (9, 2)  NULL,
    [agivc_no_payments]     SMALLINT        NULL,
    [agivc_adj_inv_yn]      CHAR (1)        NULL,
    [agivc_srvchr_cd]       TINYINT         NULL,
    [agivc_disc_rev_dt]     INT             NULL,
    [agivc_net_rev_dt]      INT             NULL,
    [agivc_src_sys]         CHAR (3)        NULL,
    [agivc_orig_rev_dt]     INT             NULL,
    [agivc_split_no]        CHAR (4)        NULL,
    [agivc_pd_days_old]     SMALLINT        NULL,
    [agivc_currency]        CHAR (3)        NULL,
    [agivc_currency_rt]     DECIMAL (15, 8) NULL,
    [agivc_currency_cnt]    CHAR (8)        NULL,
    [agivc_eft_ivc_paid_yn] CHAR (1)        NULL,
    [agivc_terms_code]      CHAR (2)        NULL,
    [agivc_pay_type]        CHAR (1)        NULL,
    [agivc_user_id]         CHAR (16)       NULL,
    [agivc_user_rev_dt]     INT             NULL,
    [A4GLIdentity]          NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agivcmst] PRIMARY KEY NONCLUSTERED ([agivc_bill_to_cus] ASC, [agivc_ivc_no] ASC, [agivc_loc_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagivcmst0]
    ON [dbo].[agivcmst]([agivc_bill_to_cus] ASC, [agivc_ivc_no] ASC, [agivc_loc_no] ASC);

