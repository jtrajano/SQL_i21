CREATE TABLE [dbo].[gajddmst] (
    [gajdd_period]          INT             NOT NULL,
    [gajdd_acct1_8]         INT             NOT NULL,
    [gajdd_acct9_16]        INT             NOT NULL,
    [gajdd_src_no]          CHAR (3)        NOT NULL,
    [gajdd_src_seq]         CHAR (5)        NOT NULL,
    [gajdd_line_no]         INT             NOT NULL,
    [gajdd_dtl_line_no]     INT             NOT NULL,
    [gajdd_tran_amt]        DECIMAL (11, 2) NULL,
    [gajdd_tran_units]      DECIMAL (17, 4) NULL,
    [gajdd_tran_rev_dt]     INT             NULL,
    [gajdd_dr_cr_ind]       CHAR (1)        NULL,
    [gajdd_drill_rec_type]  CHAR (2)        NULL,
    [gajdd_pur_sls_ind]     CHAR (1)        NULL,
    [gajdd_cus_no]          CHAR (10)       NULL,
    [gajdd_com_cd]          CHAR (3)        NULL,
    [gajdd_tic_no]          CHAR (10)       NULL,
    [gajdd_rec_type]        CHAR (1)        NULL,
    [gajdd_tie_breaker]     SMALLINT        NULL,
    [gajdd_seq_no]          SMALLINT        NULL,
    [gajdd_loc_no]          CHAR (3)        NULL,
    [gajdd_xfr_pur_sls_ind] CHAR (1)        NULL,
    [gajdd_xfr_loc_no]      CHAR (3)        NULL,
    [gajdd_xfr_com_cd]      CHAR (3)        NULL,
    [gajdd_xfr_tic_no]      CHAR (10)       NULL,
    [gajdd_xfr_to_loc_no]   CHAR (3)        NULL,
    [gajdd_xfr_tie_breaker] SMALLINT        NULL,
    [gajdd_chk_pur_sls_ind] CHAR (1)        NULL,
    [gajdd_chk_cus_no]      CHAR (10)       NULL,
    [gajdd_chk_no]          CHAR (8)        NULL,
    [gajdd_chk_currency]    CHAR (3)        NULL,
    [gajdd_chk_tic_no]      CHAR (10)       NULL,
    [A4GLIdentity]          NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gajddmst] PRIMARY KEY NONCLUSTERED ([gajdd_period] ASC, [gajdd_acct1_8] ASC, [gajdd_acct9_16] ASC, [gajdd_src_no] ASC, [gajdd_src_seq] ASC, [gajdd_line_no] ASC, [gajdd_dtl_line_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igajddmst0]
    ON [dbo].[gajddmst]([gajdd_period] ASC, [gajdd_acct1_8] ASC, [gajdd_acct9_16] ASC, [gajdd_src_no] ASC, [gajdd_src_seq] ASC, [gajdd_line_no] ASC, [gajdd_dtl_line_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[gajddmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gajddmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gajddmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gajddmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gajddmst] TO PUBLIC
    AS [dbo];

