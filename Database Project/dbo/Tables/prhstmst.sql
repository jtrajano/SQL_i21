CREATE TABLE [dbo].[prhstmst] (
    [prhst_emp_no]        CHAR (10)       NOT NULL,
    [prhst_code]          CHAR (1)        NOT NULL,
    [prhst_no]            CHAR (8)        NOT NULL,
    [prhst_chk_type]      CHAR (1)        NOT NULL,
    [prhst_tax_type]      TINYINT         NOT NULL,
    [prhst_tax]           CHAR (6)        NOT NULL,
    [prhst_dept]          CHAR (4)        NOT NULL,
    [prhst_amt]           DECIMAL (9, 2)  NULL,
    [prhst_credit_yn]     CHAR (1)        NULL,
    [prhst_paid_by]       CHAR (1)        NULL,
    [prhst_literal]       CHAR (10)       NULL,
    [prhst_taxable_wages] DECIMAL (9, 2)  NULL,
    [prhst_total_wages]   DECIMAL (11, 2) NULL,
    [prhst_user_id]       CHAR (16)       NULL,
    [prhst_user_rev_dt]   INT             NULL,
    [A4GLIdentity]        NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_prhstmst] PRIMARY KEY NONCLUSTERED ([prhst_emp_no] ASC, [prhst_code] ASC, [prhst_no] ASC, [prhst_chk_type] ASC, [prhst_tax_type] ASC, [prhst_tax] ASC, [prhst_dept] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iprhstmst0]
    ON [dbo].[prhstmst]([prhst_emp_no] ASC, [prhst_code] ASC, [prhst_no] ASC, [prhst_chk_type] ASC, [prhst_tax_type] ASC, [prhst_tax] ASC, [prhst_dept] ASC);


GO
CREATE NONCLUSTERED INDEX [Iprhstmst1]
    ON [dbo].[prhstmst]([prhst_code] ASC, [prhst_no] ASC, [prhst_chk_type] ASC, [prhst_emp_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[prhstmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[prhstmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[prhstmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[prhstmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[prhstmst] TO PUBLIC
    AS [dbo];

