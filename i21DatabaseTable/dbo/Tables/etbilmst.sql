CREATE TABLE [dbo].[etbilmst] (
    [etbil_loc]                  CHAR (3)        NOT NULL,
    [etbil_tic_dt]               INT             NOT NULL,
    [etbil_cust]                 CHAR (10)       NOT NULL,
    [etbil_ticket]               CHAR (9)        NOT NULL,
    [etbil_rec_type]             CHAR (1)        NOT NULL,
    [etbil_seq]                  SMALLINT        NOT NULL,
    [etbilhdr_rlse_yn]           CHAR (1)        NULL,
    [etbilhdr_tic_type]          CHAR (1)        NULL,
    [etbilhdr_farm_no]           SMALLINT        NULL,
    [etbilhdr_field_no]          SMALLINT        NULL,
    [etbilhdr_booking_type]      CHAR (1)        NULL,
    [etbilhdr_blnkt_prepay_cat]  CHAR (1)        NULL,
    [etbilhdr_blnkt_excess_cat]  CHAR (1)        NULL,
    [etbilhdr_bln_nitr_pct]      TINYINT         NULL,
    [etbilhdr_bln_phos_pct]      TINYINT         NULL,
    [etbilhdr_bln_potass_pct]    TINYINT         NULL,
    [etbilhdr_bln_mic_nutr_yn]   CHAR (1)        NULL,
    [etbilhdr_bln_chem_yn]       CHAR (1)        NULL,
    [etbilhdr_bln_pkg_type]      CHAR (1)        NULL,
    [etbilhdr_bln_wgt]           DECIMAL (11, 4) NULL,
    [etbilhdr_bill_ok_yn]        CHAR (1)        NULL,
    [etbilhdr_slsmn_no]          CHAR (3)        NULL,
    [etbilhdr_comment]           CHAR (30)       NULL,
    [etbilitm_rlse_yn]           CHAR (1)        NULL,
    [etbilitm_itm_no]            CHAR (15)       NULL,
    [etbilitm_un_sold]           DECIMAL (12, 4) NULL,
    [etbilitm_tax_yn]            CHAR (1)        NULL,
    [etbilitm_terms_cd]          TINYINT         NULL,
    [etbilitm_prc_sched]         CHAR (1)        NULL,
    [etbilitm_un_prc]            DECIMAL (10, 5) NULL,
    [etbilitm_override_cus]      CHAR (10)       NULL,
    [etbilitm_override_itm_desc] CHAR (30)       NULL,
    [etbilitm_extra_comment]     CHAR (30)       NULL,
    [etbilitm_minor_no]          SMALLINT        NULL,
    [etbilitm_tank_no]           SMALLINT        NULL,
    [etbilitm_tank_pct_full]     DECIMAL (5, 2)  NULL,
    [etbilitm_nonblended_yn]     CHAR (1)        NULL,
    [etbilitm_detail_tax_type]   CHAR (1)        NULL,
    [etbilitm_status_code]       CHAR (1)        NULL,
    [A4GLIdentity]               NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_etbilmst] PRIMARY KEY NONCLUSTERED ([etbil_loc] ASC, [etbil_tic_dt] ASC, [etbil_cust] ASC, [etbil_ticket] ASC, [etbil_rec_type] ASC, [etbil_seq] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ietbilmst0]
    ON [dbo].[etbilmst]([etbil_loc] ASC, [etbil_tic_dt] ASC, [etbil_cust] ASC, [etbil_ticket] ASC, [etbil_rec_type] ASC, [etbil_seq] ASC);


GO
CREATE NONCLUSTERED INDEX [Ietbilmst1]
    ON [dbo].[etbilmst]([etbil_tic_dt] ASC);


GO
CREATE NONCLUSTERED INDEX [Ietbilmst2]
    ON [dbo].[etbilmst]([etbil_cust] ASC);


GO
CREATE NONCLUSTERED INDEX [Ietbilmst3]
    ON [dbo].[etbilmst]([etbil_ticket] ASC);


GO
CREATE NONCLUSTERED INDEX [Ietbilmst4]
    ON [dbo].[etbilmst]([etbil_rec_type] ASC);

