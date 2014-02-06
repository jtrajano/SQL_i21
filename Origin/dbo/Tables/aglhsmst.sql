CREATE TABLE [dbo].[aglhsmst] (
    [aglhs_itm_no]          CHAR (13)       NOT NULL,
    [aglhs_loc_no]          CHAR (3)        NOT NULL,
    [aglhs_lot_no]          CHAR (16)       NOT NULL,
    [aglhs_cnv_rev_dt]      INT             NOT NULL,
    [aglhs_seq_no]          INT             NOT NULL,
    [aglhs_type]            CHAR (2)        NULL,
    [aglhs_rev_dt]          INT             NULL,
    [aglhs_un]              DECIMAL (13, 4) NULL,
    [aglhs_xfr_itm_no]      CHAR (13)       NOT NULL,
    [aglhs_xfr_loc_no]      CHAR (3)        NOT NULL,
    [aglhs_xfr_lot_no]      CHAR (16)       NOT NULL,
    [aglhs_vnd_no]          CHAR (10)       NOT NULL,
    [aglhs_po_no]           CHAR (8)        NOT NULL,
    [aglhs_rct_seq_no]      TINYINT         NOT NULL,
    [aglhs_rct_line_no]     SMALLINT        NOT NULL,
    [aglhs_cus_no]          CHAR (10)       NOT NULL,
    [aglhs_ivc_no]          CHAR (8)        NOT NULL,
    [aglhs_ivc_loc_no]      CHAR (3)        NULL,
    [aglhs_bln_itm_no]      CHAR (13)       NOT NULL,
    [aglhs_bln_loc_no]      CHAR (3)        NOT NULL,
    [aglhs_bln_fml_seq_no]  TINYINT         NOT NULL,
    [aglhs_bln_rev_dt]      INT             NOT NULL,
    [aglhs_bln_tie_breaker] SMALLINT        NOT NULL,
    [aglhs_bln_lot_no]      CHAR (16)       NOT NULL,
    [aglhs_adj_audit_no]    CHAR (5)        NULL,
    [aglhs_ivc_line_no]     SMALLINT        NULL,
    [aglhs_user_id]         CHAR (16)       NULL,
    [aglhs_user_rev_dt]     INT             NULL,
    [A4GLIdentity]          NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_aglhsmst] PRIMARY KEY NONCLUSTERED ([aglhs_itm_no] ASC, [aglhs_loc_no] ASC, [aglhs_lot_no] ASC, [aglhs_cnv_rev_dt] ASC, [aglhs_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iaglhsmst0]
    ON [dbo].[aglhsmst]([aglhs_itm_no] ASC, [aglhs_loc_no] ASC, [aglhs_lot_no] ASC, [aglhs_cnv_rev_dt] ASC, [aglhs_seq_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iaglhsmst1]
    ON [dbo].[aglhsmst]([aglhs_xfr_itm_no] ASC, [aglhs_xfr_loc_no] ASC, [aglhs_xfr_lot_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iaglhsmst2]
    ON [dbo].[aglhsmst]([aglhs_vnd_no] ASC, [aglhs_po_no] ASC, [aglhs_rct_seq_no] ASC, [aglhs_rct_line_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iaglhsmst3]
    ON [dbo].[aglhsmst]([aglhs_cus_no] ASC, [aglhs_ivc_no] ASC, [aglhs_loc_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iaglhsmst4]
    ON [dbo].[aglhsmst]([aglhs_bln_itm_no] ASC, [aglhs_bln_loc_no] ASC, [aglhs_bln_fml_seq_no] ASC, [aglhs_bln_rev_dt] ASC, [aglhs_bln_tie_breaker] ASC, [aglhs_bln_lot_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[aglhsmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[aglhsmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[aglhsmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[aglhsmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[aglhsmst] TO PUBLIC
    AS [dbo];

