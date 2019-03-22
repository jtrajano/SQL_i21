CREATE TABLE [dbo].[etdscmst] (
    [etdsc_loc]       SMALLINT        NOT NULL,
    [etdsc_itm]       CHAR (15)       NOT NULL,
    [etdsc_seq_no]    TINYINT         NOT NULL,
    [etdsc_qty]       DECIMAL (10, 2) NULL,
    [etdsc_qty_desc]  CHAR (8)        NULL,
    [etdsc_code]      CHAR (1)        NULL,
    [etdsc_amt]       DECIMAL (13, 4) NULL,
    [etdsc_print_yn]  CHAR (1)        NULL,
    [etdsc_acct_code] INT             NULL,
    [A4GLIdentity]    NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_etdscmst] PRIMARY KEY NONCLUSTERED ([etdsc_loc] ASC, [etdsc_itm] ASC, [etdsc_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ietdscmst0]
    ON [dbo].[etdscmst]([etdsc_loc] ASC, [etdsc_itm] ASC, [etdsc_seq_no] ASC);

