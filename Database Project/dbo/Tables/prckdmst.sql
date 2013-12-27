CREATE TABLE [dbo].[prckdmst] (
    [prckd_emp_no]           CHAR (10)      NOT NULL,
    [prckd_chk_type]         CHAR (1)       NOT NULL,
    [prckd_seq_no]           INT            NOT NULL,
    [prckd_ded]              CHAR (3)       NOT NULL,
    [prckd_code]             CHAR (1)       NOT NULL,
    [prckd_no]               CHAR (8)       NOT NULL,
    [prckd_amt]              DECIMAL (9, 2) NULL,
    [prckd_acct_no]          CHAR (20)      NULL,
    [prckd_type]             CHAR (1)       NULL,
    [prckd_ddp_bnk_code]     CHAR (4)       NULL,
    [prckd_co_emp_cd]        CHAR (1)       NULL,
    [prckd_literal]          CHAR (10)      NULL,
    [prckd_arrears_amt]      DECIMAL (9, 2) NULL,
    [prckd_acct_type_cs]     CHAR (1)       NULL,
    [prckd_taxable_earnings] DECIMAL (9, 2) NULL,
    [A4GLIdentity]           NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_prckdmst] PRIMARY KEY NONCLUSTERED ([prckd_emp_no] ASC, [prckd_chk_type] ASC, [prckd_seq_no] ASC, [prckd_ded] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iprckdmst0]
    ON [dbo].[prckdmst]([prckd_emp_no] ASC, [prckd_chk_type] ASC, [prckd_seq_no] ASC, [prckd_ded] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iprckdmst1]
    ON [dbo].[prckdmst]([prckd_code] ASC, [prckd_no] ASC, [prckd_emp_no] ASC, [prckd_chk_type] ASC, [prckd_seq_no] ASC, [prckd_ded] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[prckdmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[prckdmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[prckdmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[prckdmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[prckdmst] TO PUBLIC
    AS [dbo];

