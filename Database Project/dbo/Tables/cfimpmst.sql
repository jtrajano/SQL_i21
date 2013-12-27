﻿CREATE TABLE [dbo].[cfimpmst] (
    [cfimp_key_seq]           INT             NOT NULL,
    [cfimp_dtl_processed_ind] TINYINT         NOT NULL,
    [cfimp_site]              CHAR (15)       NOT NULL,
    [cfimp_prod_no]           CHAR (4)        NOT NULL,
    [cfimp_data]              CHAR (1000)     NULL,
    [cfimp_num_transactions]  INT             NULL,
    [cfimp_network_id]        CHAR (3)        NULL,
    [cfimp_file_type]         CHAR (1)        NULL,
    [cfimp_controller_type]   CHAR (1)        NULL,
    [cfimp_file_name]         CHAR (80)       NULL,
    [cfimp_club_sales]        DECIMAL (13, 2) NULL,
    [cfimp_visa_sales]        DECIMAL (13, 2) NULL,
    [cfimp_mc_sales]          DECIMAL (13, 2) NULL,
    [cfimp_discvr_sales]      DECIMAL (13, 2) NULL,
    [cfimp_amexp_sales]       DECIMAL (13, 2) NULL,
    [cfimp_wrexp_sales]       DECIMAL (13, 2) NULL,
    [cfimp_dc_sales]          DECIMAL (13, 2) NULL,
    [cfimp_voy_sales]         DECIMAL (13, 2) NULL,
    [cfimp_mc_flt_sales]      DECIMAL (13, 2) NULL,
    [cfimp_visa_flt_sales]    DECIMAL (13, 2) NULL,
    [cfimp_fman_sales]        DECIMAL (13, 2) NULL,
    [cfimp_cenex_sales]       DECIMAL (13, 2) NULL,
    [cfimp_other_sales]       DECIMAL (13, 2) NULL,
    [cfimp_rev_dt]            INT             NULL,
    [cfimp_time]              SMALLINT        NULL,
    [cfimp_seq_no]            CHAR (8)        NULL,
    [cfimp_sale_type]         CHAR (2)        NULL,
    [cfimp_tic_no]            CHAR (8)        NULL,
    [cfimp_card_no]           CHAR (16)       NULL,
    [cfimp_ar_cus_no]         CHAR (10)       NULL,
    [cfimp_iso_no_n]          INT             NULL,
    [cfimp_veh_no]            CHAR (10)       NULL,
    [cfimp_jobber_no]         CHAR (3)        NULL,
    [cfimp_odometer]          DECIMAL (8, 1)  NULL,
    [cfimp_pump_no]           TINYINT         NULL,
    [cfimp_auth_cd]           CHAR (10)       NULL,
    [cfimp_manual_entry]      INT             NULL,
    [cfimp_site_state]        TINYINT         NULL,
    [cfimp_site_county]       TINYINT         NULL,
    [cfimp_site_city]         TINYINT         NULL,
    [cfimp_ca_site_yn]        CHAR (1)        NULL,
    [cfimp_pump_price]        DECIMAL (11, 5) NULL,
    [cfimp_selling_host_id]   CHAR (6)        NULL,
    [cfimp_selling_site_type] CHAR (1)        NULL,
    [cfimp_buying_host_id]    CHAR (6)        NULL,
    [cfimp_qty]               DECIMAL (10, 3) NULL,
    [cfimp_prc]               DECIMAL (11, 5) NULL,
    [cfimp_network_cost]      DECIMAL (9, 7)  NULL,
    [cfimp_haul_rate]         DECIMAL (4, 4)  NULL,
    [cfimp_tot_amt]           DECIMAL (7, 2)  NULL,
    [cfimp_site_tax_code_1]   SMALLINT        NULL,
    [cfimp_site_tax_code_2]   SMALLINT        NULL,
    [cfimp_site_tax_code_3]   SMALLINT        NULL,
    [cfimp_site_tax_code_4]   SMALLINT        NULL,
    [cfimp_site_tax_code_5]   SMALLINT        NULL,
    [cfimp_site_tax_code_6]   SMALLINT        NULL,
    [cfimp_site_tax_code_7]   SMALLINT        NULL,
    [cfimp_site_tax_code_8]   SMALLINT        NULL,
    [cfimp_site_tax_code_9]   SMALLINT        NULL,
    [cfimp_site_tax_code_10]  SMALLINT        NULL,
    [cfimp_site_tax_code_11]  SMALLINT        NULL,
    [cfimp_site_tax_code_12]  SMALLINT        NULL,
    [cfimp_site_tax_code_13]  SMALLINT        NULL,
    [cfimp_site_tax_code_14]  SMALLINT        NULL,
    [cfimp_site_tax_code_15]  SMALLINT        NULL,
    [cfimp_site_tax_code_16]  SMALLINT        NULL,
    [cfimp_site_tax_code_17]  SMALLINT        NULL,
    [cfimp_site_tax_code_18]  SMALLINT        NULL,
    [cfimp_site_tax_code_19]  SMALLINT        NULL,
    [cfimp_site_tax_code_20]  SMALLINT        NULL,
    [cfimp_site_tax_amt_1]    DECIMAL (10, 5) NULL,
    [cfimp_site_tax_amt_2]    DECIMAL (10, 5) NULL,
    [cfimp_site_tax_amt_3]    DECIMAL (10, 5) NULL,
    [cfimp_site_tax_amt_4]    DECIMAL (10, 5) NULL,
    [cfimp_site_tax_amt_5]    DECIMAL (10, 5) NULL,
    [cfimp_site_tax_amt_6]    DECIMAL (10, 5) NULL,
    [cfimp_site_tax_amt_7]    DECIMAL (10, 5) NULL,
    [cfimp_site_tax_amt_8]    DECIMAL (10, 5) NULL,
    [cfimp_site_tax_amt_9]    DECIMAL (10, 5) NULL,
    [cfimp_site_tax_amt_10]   DECIMAL (10, 5) NULL,
    [cfimp_site_tax_amt_11]   DECIMAL (10, 5) NULL,
    [cfimp_site_tax_amt_12]   DECIMAL (10, 5) NULL,
    [cfimp_site_tax_amt_13]   DECIMAL (10, 5) NULL,
    [cfimp_site_tax_amt_14]   DECIMAL (10, 5) NULL,
    [cfimp_site_tax_amt_15]   DECIMAL (10, 5) NULL,
    [cfimp_site_tax_amt_16]   DECIMAL (10, 5) NULL,
    [cfimp_site_tax_amt_17]   DECIMAL (10, 5) NULL,
    [cfimp_site_tax_amt_18]   DECIMAL (10, 5) NULL,
    [cfimp_site_tax_amt_19]   DECIMAL (10, 5) NULL,
    [cfimp_site_tax_amt_20]   DECIMAL (10, 5) NULL,
    [cfimp_ccd_type]          CHAR (1)        NULL,
    [cfimp_reversal_yn]       CHAR (1)        NULL,
    [cfimp_hdr_tax_amt]       DECIMAL (11, 5) NULL,
    [cfimp_hdr_dsc_amt]       DECIMAL (11, 5) NULL,
    [cfimp_paid_out_amt]      DECIMAL (13, 2) NULL,
    [cfimp_payment_type_1]    TINYINT         NULL,
    [cfimp_payment_type_2]    TINYINT         NULL,
    [cfimp_payment_type_3]    TINYINT         NULL,
    [cfimp_payment_type_4]    TINYINT         NULL,
    [cfimp_payment_type_5]    TINYINT         NULL,
    [cfimp_payment_type_6]    TINYINT         NULL,
    [cfimp_payment_type_7]    TINYINT         NULL,
    [cfimp_payment_type_8]    TINYINT         NULL,
    [cfimp_payment_type_9]    TINYINT         NULL,
    [cfimp_payment_type_10]   TINYINT         NULL,
    [cfimp_payment_amt_1]     DECIMAL (9, 2)  NULL,
    [cfimp_payment_amt_2]     DECIMAL (9, 2)  NULL,
    [cfimp_payment_amt_3]     DECIMAL (9, 2)  NULL,
    [cfimp_payment_amt_4]     DECIMAL (9, 2)  NULL,
    [cfimp_payment_amt_5]     DECIMAL (9, 2)  NULL,
    [cfimp_payment_amt_6]     DECIMAL (9, 2)  NULL,
    [cfimp_payment_amt_7]     DECIMAL (9, 2)  NULL,
    [cfimp_payment_amt_8]     DECIMAL (9, 2)  NULL,
    [cfimp_payment_amt_9]     DECIMAL (9, 2)  NULL,
    [cfimp_payment_amt_10]    DECIMAL (9, 2)  NULL,
    [cfimp_payment_desc_1]    CHAR (10)       NULL,
    [cfimp_payment_desc_2]    CHAR (10)       NULL,
    [cfimp_payment_desc_3]    CHAR (10)       NULL,
    [cfimp_payment_desc_4]    CHAR (10)       NULL,
    [cfimp_payment_desc_5]    CHAR (10)       NULL,
    [cfimp_payment_desc_6]    CHAR (10)       NULL,
    [cfimp_payment_desc_7]    CHAR (10)       NULL,
    [cfimp_payment_desc_8]    CHAR (10)       NULL,
    [cfimp_payment_desc_9]    CHAR (10)       NULL,
    [cfimp_payment_desc_10]   CHAR (10)       NULL,
    [cfimp_rec_type]          CHAR (1)        NULL,
    [cfimp_network_ind]       CHAR (2)        NULL,
    [cfimp_merch_desc]        CHAR (26)       NULL,
    [A4GLIdentity]            NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_cfimpmst] PRIMARY KEY NONCLUSTERED ([cfimp_key_seq] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Icfimpmst0]
    ON [dbo].[cfimpmst]([cfimp_key_seq] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Icfimpmst1]
    ON [dbo].[cfimpmst]([cfimp_dtl_processed_ind] ASC, [cfimp_key_seq] ASC);


GO
CREATE NONCLUSTERED INDEX [Icfimpmst2]
    ON [dbo].[cfimpmst]([cfimp_site] ASC, [cfimp_prod_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[cfimpmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[cfimpmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[cfimpmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[cfimpmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[cfimpmst] TO PUBLIC
    AS [dbo];

