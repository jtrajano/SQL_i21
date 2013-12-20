CREATE TABLE [dbo].[ssvndmst] (
    [ssvnd_vnd_no]              CHAR (10)       NOT NULL,
    [ssvnd_co_per_ind]          CHAR (1)        NULL,
    [ssvnd_name]                CHAR (50)       NOT NULL,
    [ssvnd_addr_1]              CHAR (30)       NULL,
    [ssvnd_addr_2]              CHAR (30)       NULL,
    [ssvnd_city]                CHAR (20)       NULL,
    [ssvnd_st]                  CHAR (2)        NULL,
    [ssvnd_zip]                 CHAR (10)       NULL,
    [ssvnd_tax_st]              CHAR (2)        NULL,
    [ssvnd_phone]               CHAR (15)       NOT NULL,
    [ssvnd_phone_ext]           CHAR (4)        NULL,
    [ssvnd_phone2]              CHAR (15)       NULL,
    [ssvnd_phone2_ext]          CHAR (4)        NULL,
    [ssvnd_contact]             CHAR (15)       NULL,
    [ssvnd_1099_yn]             CHAR (1)        NULL,
    [ssvnd_wthhld_yn]           CHAR (1)        NULL,
    [ssvnd_gl_pur]              DECIMAL (16, 8) NULL,
    [ssvnd_pay_ctl_ind]         CHAR (1)        NULL,
    [ssvnd_prev_ctl_ind]        CHAR (1)        NULL,
    [ssvnd_acct_stat]           CHAR (10)       NULL,
    [ssvnd_terms_type]          CHAR (1)        NULL,
    [ssvnd_terms_desc]          CHAR (15)       NULL,
    [ssvnd_terms_due_day]       TINYINT         NULL,
    [ssvnd_terms_disc_day]      TINYINT         NULL,
    [ssvnd_terms_disc_pct]      DECIMAL (4, 2)  NULL,
    [ssvnd_terms_cutoff_day]    TINYINT         NULL,
    [ssvnd_last_pur_rev_dt]     INT             NULL,
    [ssvnd_last_pay_rev_dt]     INT             NULL,
    [ssvnd_per1_bal]            DECIMAL (11, 2) NULL,
    [ssvnd_per2_bal]            DECIMAL (11, 2) NULL,
    [ssvnd_per3_bal]            DECIMAL (11, 2) NULL,
    [ssvnd_per4_bal]            DECIMAL (11, 2) NULL,
    [ssvnd_future_bal]          DECIMAL (11, 2) NULL,
    [ssvnd_our_cus_no]          CHAR (20)       NULL,
    [ssvnd_fed_tax_id]          CHAR (20)       NULL,
    [ssvnd_w9_signed_rev_dt]    INT             NULL,
    [ssvnd_currency]            CHAR (3)        NULL,
    [ssvnd_cstore_pay_type_ycn] CHAR (1)        NULL,
    [ssvnd_pay_to]              CHAR (10)       NULL,
    [ssvnd_1099_name]           CHAR (50)       NULL,
    [ssvnd_user_id]             CHAR (16)       NULL,
    [ssvnd_user_rev_dt]         INT             NULL,
    [A4GLIdentity]              NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    [ssvnd_dest_co_name]        CHAR (2)        NULL,
    [ssvnd_dest_ar_cus_no]      CHAR (10)       NULL,
    [ssvnd_dest_ar_cus_acc_no]  DECIMAL (16, 8) NULL,
    [ssvnd_dest_ap_pur_acc_no]  DECIMAL (16, 8) NULL,
    [ssvnd_dest_cbk_no]         CHAR (2)        NULL,
    [ssvnd_dest_batch_no]       TINYINT         NULL,
    CONSTRAINT [k_ssvndmst] PRIMARY KEY NONCLUSTERED ([ssvnd_vnd_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Issvndmst0]
    ON [dbo].[ssvndmst]([ssvnd_vnd_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Issvndmst1]
    ON [dbo].[ssvndmst]([ssvnd_name] ASC);


GO
CREATE NONCLUSTERED INDEX [Issvndmst2]
    ON [dbo].[ssvndmst]([ssvnd_phone] ASC);

