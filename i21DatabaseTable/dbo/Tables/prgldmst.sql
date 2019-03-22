CREATE TABLE [dbo].[prgldmst] (
    [prgld_rev_dt]     INT             NOT NULL,
    [prgld_source]     CHAR (3)        NOT NULL,
    [prgld_gl_acct_no] DECIMAL (16, 8) NOT NULL,
    [prgld_seq_no]     INT             NOT NULL,
    [prgld_reference]  CHAR (25)       NULL,
    [prgld_document]   CHAR (25)       NULL,
    [prgld_dr_cr_ind]  CHAR (1)        NULL,
    [prgld_amt]        DECIMAL (9, 2)  NULL,
    [prgld_hours]      DECIMAL (9, 2)  NULL,
    [A4GLIdentity]     NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_prgldmst] PRIMARY KEY NONCLUSTERED ([prgld_rev_dt] ASC, [prgld_source] ASC, [prgld_gl_acct_no] ASC, [prgld_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iprgldmst0]
    ON [dbo].[prgldmst]([prgld_rev_dt] ASC, [prgld_source] ASC, [prgld_gl_acct_no] ASC, [prgld_seq_no] ASC);

