CREATE TABLE [dbo].[etstmmst] (
    [etstm_loc]                CHAR (3)        NOT NULL,
    [etstm_tic_dt]             INT             NOT NULL,
    [etstm_cust]               CHAR (10)       NOT NULL,
    [etstm_ticket]             CHAR (9)        NOT NULL,
    [etstm_rec_id]             CHAR (2)        NOT NULL,
    [etstm_seq]                SMALLINT        NOT NULL,
    [etstmdtl_rlse_yn]         CHAR (1)        NULL,
    [etstmdtl_rec_type]        CHAR (1)        NULL,
    [etstmdtl_tank_no]         SMALLINT        NULL,
    [etstmdtl_amt]             DECIMAL (15, 2) NULL,
    [etstmdtl_qty]             DECIMAL (15, 4) NULL,
    [etstmdtl_un_prc]          DECIMAL (15, 5) NULL,
    [etstmdtl_unit_meas]       CHAR (10)       NULL,
    [etstmdtl_item_desc]       CHAR (20)       NULL,
    [etstmdtl_tank_pct_full]   DECIMAL (6, 2)  NULL,
    [etstmdtl_pay_type]        CHAR (1)        NULL,
    [etstmdtl_disc_per_unit]   DECIMAL (15, 5) NULL,
    [etstmdtl_terms_code]      CHAR (2)        NULL,
    [etstmdtl_sales_acct_code] CHAR (8)        NULL,
    [etstmdtl_item_no]         CHAR (15)       NULL,
    [etstmdtl_card_no]         CHAR (19)       NULL,
    [etstmdtl_disc_desc_1]     CHAR (35)       NULL,
    [etstmdtl_disc_desc_2]     CHAR (35)       NULL,
    [etstmdtl_disc_desc_3]     CHAR (35)       NULL,
    [etstmdtl_disc_per_un_1]   DECIMAL (9, 4)  NULL,
    [etstmdtl_disc_per_un_2]   DECIMAL (9, 4)  NULL,
    [etstmdtl_disc_per_un_3]   DECIMAL (9, 4)  NULL,
    [etstmdtl_disc_amt_1]      DECIMAL (15, 2) NULL,
    [etstmdtl_disc_amt_2]      DECIMAL (15, 2) NULL,
    [etstmdtl_disc_amt_3]      DECIMAL (15, 2) NULL,
    [etstmdtl_disc_amt_avail]  DECIMAL (15, 2) NULL,
    [etstmdtl_sub_loc]         TINYINT         NULL,
    [etstmdtl_sub_lot]         CHAR (5)        NULL,
    [etstmdtl_detail_or_tax]   CHAR (1)        NULL,
    [etstmdtl_legend]          CHAR (2)        NULL,
    [etstmdtl_terms_desc]      CHAR (25)       NULL,
    [etstmdtl_prepaid_applied] DECIMAL (12, 2) NULL,
    [etstmdtl_slsmn_id]        CHAR (3)        NULL,
    [etstmdtl_copc_key]        BIGINT          NULL,
    [etstmdtl_status_code]     CHAR (1)        NULL,
    [etstmdtl_comment]         CHAR (30)       NULL,
    [etstmdtl_tax_cd]          CHAR (5)        NULL,
    [etstmpay_rlse_yn]         CHAR (1)        NULL,
    [etstmpay_rec_type]        CHAR (1)        NULL,
    [etstmpay_pay_amt]         DECIMAL (15, 2) NULL,
    [etstmpay_pay_desc]        CHAR (20)       NULL,
    [etstmpay_pay_type]        CHAR (1)        NULL,
    [etstmpay_terms]           CHAR (2)        NULL,
    [etstmpay_pay_acct_code]   CHAR (8)        NULL,
    [etstmpay_voided_yn]       CHAR (1)        NULL,
    [etstmpay_xmitted_yn]      CHAR (1)        NULL,
    [etstmpay_copc_key]        BIGINT          NULL,
    [etstmpay_slsmn_id]        CHAR (3)        NULL,
    [etstmpay_check_no]        CHAR (6)        NULL,
    [etstmdis_rlse_yn]         CHAR (1)        NULL,
    [etstmdis_rec_type]        CHAR (1)        NULL,
    [etstmdis_amt]             DECIMAL (15, 2) NULL,
    [etstmdis_desc]            CHAR (20)       NULL,
    [etstmdis_pay_type]        CHAR (1)        NULL,
    [etstmdis_terms]           CHAR (2)        NULL,
    [etstmdis_acct_code]       CHAR (8)        NULL,
    [etstmdis_xmitted_yn]      CHAR (1)        NULL,
    [etstmdis_slsmn_id]        CHAR (3)        NULL,
    [A4GLIdentity]             NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_etstmmst] PRIMARY KEY NONCLUSTERED ([etstm_loc] ASC, [etstm_tic_dt] ASC, [etstm_cust] ASC, [etstm_ticket] ASC, [etstm_rec_id] ASC, [etstm_seq] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Ietstmmst0]
    ON [dbo].[etstmmst]([etstm_loc] ASC, [etstm_tic_dt] ASC, [etstm_cust] ASC, [etstm_ticket] ASC, [etstm_rec_id] ASC, [etstm_seq] ASC);


GO
CREATE NONCLUSTERED INDEX [Ietstmmst1]
    ON [dbo].[etstmmst]([etstm_loc] ASC);


GO
CREATE NONCLUSTERED INDEX [Ietstmmst2]
    ON [dbo].[etstmmst]([etstm_tic_dt] ASC);


GO
CREATE NONCLUSTERED INDEX [Ietstmmst3]
    ON [dbo].[etstmmst]([etstm_cust] ASC);


GO
CREATE NONCLUSTERED INDEX [Ietstmmst4]
    ON [dbo].[etstmmst]([etstm_ticket] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[etstmmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[etstmmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[etstmmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[etstmmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[etstmmst] TO PUBLIC
    AS [dbo];

