CREATE TABLE [dbo].[aglhemst] (
    [aglhe_type]          CHAR (2)        NOT NULL,
    [aglhe_cus_vnd_no]    CHAR (10)       NOT NULL,
    [aglhe_ord_po_no]     CHAR (8)        NOT NULL,
    [aglhe_ord_loc_no]    CHAR (3)        NOT NULL,
    [aglhe_rct_seq_no]    TINYINT         NOT NULL,
    [aglhe_line_no]       DECIMAL (15, 6) NOT NULL,
    [aglhe_seq_no]        INT             NOT NULL,
    [aglhe_bln_itm_no]    CHAR (13)       NULL,
    [aglhe_bln_loc_no]    CHAR (3)        NULL,
    [aglhe_bln_seq_no]    TINYINT         NULL,
    [aglhe_bln_date]      INT             NULL,
    [aglhe_bln_time]      INT             NULL,
    [aglhe_bln_ingr_line] INT             NULL,
    [aglhe_loc_no]        CHAR (3)        NULL,
    [aglhe_itm_no]        CHAR (13)       NULL,
    [aglhe_lot_no]        CHAR (16)       NULL,
    [aglhe_date]          INT             NULL,
    [aglhe_un]            DECIMAL (13, 4) NULL,
    [aglhe_blno_cus_no]   CHAR (10)       NULL,
    [aglhe_blno_ord_no]   CHAR (8)        NULL,
    [aglhe_blno_loc_no]   CHAR (3)        NULL,
    [aglhe_blno_line_no]  DECIMAL (15, 6) NULL,
    [A4GLIdentity]        NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_aglhemst] PRIMARY KEY NONCLUSTERED ([aglhe_type] ASC, [aglhe_cus_vnd_no] ASC, [aglhe_ord_po_no] ASC, [aglhe_ord_loc_no] ASC, [aglhe_rct_seq_no] ASC, [aglhe_line_no] ASC, [aglhe_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iaglhemst0]
    ON [dbo].[aglhemst]([aglhe_type] ASC, [aglhe_cus_vnd_no] ASC, [aglhe_ord_po_no] ASC, [aglhe_ord_loc_no] ASC, [aglhe_rct_seq_no] ASC, [aglhe_line_no] ASC, [aglhe_seq_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[aglhemst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[aglhemst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[aglhemst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[aglhemst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[aglhemst] TO PUBLIC
    AS [dbo];

