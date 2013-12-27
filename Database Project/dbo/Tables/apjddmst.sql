CREATE TABLE [dbo].[apjddmst] (
    [apjdd_period]         INT             NOT NULL,
    [apjdd_acct1_8]        INT             NOT NULL,
    [apjdd_acct9_16]       INT             NOT NULL,
    [apjdd_src_no]         CHAR (3)        NOT NULL,
    [apjdd_src_seq]        CHAR (5)        NOT NULL,
    [apjdd_line_no]        INT             NOT NULL,
    [apjdd_dtl_line_no]    INT             NOT NULL,
    [apjdd_tran_amt]       DECIMAL (11, 2) NULL,
    [apjdd_tran_units]     DECIMAL (16, 4) NULL,
    [apjdd_tran_rev_dt]    INT             NULL,
    [apjdd_dr_cr_ind]      CHAR (1)        NULL,
    [apjdd_drill_rec_type] CHAR (2)        NULL,
    [apjdd_drill_area]     CHAR (50)       NULL,
    [apjdd_cw_cbk_no]      CHAR (2)        NULL,
    [apjdd_cw_rev_dt]      CHAR (8)        NULL,
    [apjdd_cw_trx_ind]     CHAR (1)        NULL,
    [apjdd_cw_chk_no]      CHAR (8)        NULL,
    [apjdd_cw_vnd_no]      CHAR (10)       NULL,
    [apjdd_ap_vnd_no]      CHAR (10)       NULL,
    [apjdd_ap_ivc_no]      CHAR (18)       NULL,
    [apjdd_ap_cbk_no]      CHAR (2)        NULL,
    [A4GLIdentity]         NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_apjddmst] PRIMARY KEY NONCLUSTERED ([apjdd_period] ASC, [apjdd_acct1_8] ASC, [apjdd_acct9_16] ASC, [apjdd_src_no] ASC, [apjdd_src_seq] ASC, [apjdd_line_no] ASC, [apjdd_dtl_line_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iapjddmst0]
    ON [dbo].[apjddmst]([apjdd_period] ASC, [apjdd_acct1_8] ASC, [apjdd_acct9_16] ASC, [apjdd_src_no] ASC, [apjdd_src_seq] ASC, [apjdd_line_no] ASC, [apjdd_dtl_line_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[apjddmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[apjddmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[apjddmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[apjddmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[apjddmst] TO PUBLIC
    AS [dbo];

