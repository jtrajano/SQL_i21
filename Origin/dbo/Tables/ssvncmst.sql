CREATE TABLE [dbo].[ssvncmst] (
    [ssvnc_vnd_no]                   CHAR (10)   NOT NULL,
    [ssvnc_type]                     CHAR (2)    NOT NULL,
    [ssvnc_seq_cd]                   CHAR (3)    NOT NULL,
    [ssvnc_ck_name]                  CHAR (50)   NULL,
    [ssvnc_ck_addr_1]                CHAR (30)   NULL,
    [ssvnc_ck_addr_2]                CHAR (30)   NULL,
    [ssvnc_ck_city]                  CHAR (20)   NULL,
    [ssvnc_ck_st]                    CHAR (2)    NULL,
    [ssvnc_ck_zip]                   CHAR (10)   NULL,
    [ssvnc_ed_trading_no]            CHAR (20)   NULL,
    [ssvnc_ed_xref_cus_no]           CHAR (20)   NULL,
    [ssvnc_ed_contact]               CHAR (20)   NULL,
    [ssvnc_ed_phone]                 CHAR (20)   NULL,
    [ssvnc_po_cost_yne]              CHAR (1)    NULL,
    [ssvnc_po_comment1]              CHAR (30)   NULL,
    [ssvnc_po_comment2]              CHAR (30)   NULL,
    [ssvnc_po_cost_ind]              CHAR (1)    NULL,
    [ssvnc_po_source_id]             CHAR (5)    NULL,
    [ssvnc_po_ic_vnd_yn]             CHAR (1)    NULL,
    [ssvnc_po_ic_co_id]              CHAR (2)    NULL,
    [ssvnc_po_ic_cus_no]             CHAR (10)   NULL,
    [ssvnc_po_ic_dflt_batch_no]      SMALLINT    NULL,
    [ssvnc_po_ic_loc_no]             CHAR (3)    NULL,
    [ssvnc_po_allow_frt_yn]          CHAR (1)    NULL,
    [ssvnc_tx_sales_id]              CHAR (20)   NULL,
    [ssvnc_tx_gross_net_ind]         CHAR (1)    NULL,
    [ssvnc_tx_dflt_origin]           CHAR (20)   NULL,
    [ssvnc_tx_auth_id1]              CHAR (3)    NULL,
    [ssvnc_tx_auth_id2]              CHAR (3)    NULL,
    [ssvnc_tx_terminal_no]           CHAR (15)   NULL,
    [ssvnc_tx_fuel_dlr_id]           CHAR (20)   NULL,
    [ssvnc_tx_fuel_dlr_id2]          CHAR (20)   NULL,
    [ssvnc_tx_insp_fee_yn]           CHAR (1)    NULL,
    [ssvnc_tx_ppd_tax_yn]            CHAR (1)    NULL,
    [ssvnc_tx_multi_pay_yn]          CHAR (1)    NULL,
    [ssvnc_tx_terminal_vnd_no]       CHAR (10)   NULL,
    [ssvnc_tx_multi_bol_ivc_yn]      CHAR (1)    NULL,
    [A4GLIdentity]                   NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    [ssvnc_tx_act_rack_prc_quote_yn] CHAR (1)    NULL,
    CONSTRAINT [k_ssvncmst] PRIMARY KEY NONCLUSTERED ([ssvnc_vnd_no] ASC, [ssvnc_type] ASC, [ssvnc_seq_cd] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Issvncmst0]
    ON [dbo].[ssvncmst]([ssvnc_vnd_no] ASC, [ssvnc_type] ASC, [ssvnc_seq_cd] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[ssvncmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ssvncmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ssvncmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ssvncmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ssvncmst] TO PUBLIC
    AS [dbo];

