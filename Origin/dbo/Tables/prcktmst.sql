CREATE TABLE [dbo].[prcktmst] (
    [prckt_emp_no]    CHAR (10)      NOT NULL,
    [prckt_chk_type]  CHAR (1)       NOT NULL,
    [prckt_seq_no]    INT            NOT NULL,
    [prckt_tax_type]  TINYINT        NOT NULL,
    [prckt_tax_code]  CHAR (6)       NOT NULL,
    [prckt_code]      CHAR (1)       NOT NULL,
    [prckt_no]        CHAR (8)       NOT NULL,
    [prckt_amt]       DECIMAL (9, 2) NULL,
    [prckt_credit_yn] CHAR (1)       NULL,
    [prckt_paid_by]   CHAR (1)       NULL,
    [prckt_literal]   CHAR (10)      NULL,
    [prckt_manual_yn] CHAR (1)       NULL,
    [A4GLIdentity]    NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_prcktmst] PRIMARY KEY NONCLUSTERED ([prckt_emp_no] ASC, [prckt_chk_type] ASC, [prckt_seq_no] ASC, [prckt_tax_type] ASC, [prckt_tax_code] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iprcktmst0]
    ON [dbo].[prcktmst]([prckt_emp_no] ASC, [prckt_chk_type] ASC, [prckt_seq_no] ASC, [prckt_tax_type] ASC, [prckt_tax_code] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iprcktmst1]
    ON [dbo].[prcktmst]([prckt_code] ASC, [prckt_no] ASC, [prckt_emp_no] ASC, [prckt_chk_type] ASC, [prckt_seq_no] ASC, [prckt_tax_type] ASC, [prckt_tax_code] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[prcktmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[prcktmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[prcktmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[prcktmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[prcktmst] TO PUBLIC
    AS [dbo];

