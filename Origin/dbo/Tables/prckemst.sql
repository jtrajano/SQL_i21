CREATE TABLE [dbo].[prckemst] (
    [prcke_emp_no]       CHAR (10)       NOT NULL,
    [prcke_chk_type]     CHAR (1)        NOT NULL,
    [prcke_seq_no]       INT             NOT NULL,
    [prcke_earn]         CHAR (3)        NOT NULL,
    [prcke_stid]         CHAR (2)        NOT NULL,
    [prcke_code]         CHAR (1)        NOT NULL,
    [prcke_no]           CHAR (8)        NOT NULL,
    [prcke_rate]         DECIMAL (11, 4) NULL,
    [prcke_reg_hrs]      DECIMAL (6, 2)  NULL,
    [prcke_reg_earn]     DECIMAL (11, 2) NULL,
    [prcke_prern_class]  CHAR (1)        NULL,
    [prcke_literal]      CHAR (10)       NULL,
    [prcke_dept]         CHAR (4)        NULL,
    [prcke_prwcc]        CHAR (6)        NULL,
    [prcke_memo_type_tw] CHAR (1)        NULL,
    [A4GLIdentity]       NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_prckemst] PRIMARY KEY NONCLUSTERED ([prcke_emp_no] ASC, [prcke_chk_type] ASC, [prcke_seq_no] ASC, [prcke_earn] ASC, [prcke_stid] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iprckemst0]
    ON [dbo].[prckemst]([prcke_emp_no] ASC, [prcke_chk_type] ASC, [prcke_seq_no] ASC, [prcke_earn] ASC, [prcke_stid] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iprckemst1]
    ON [dbo].[prckemst]([prcke_code] ASC, [prcke_no] ASC, [prcke_emp_no] ASC, [prcke_chk_type] ASC, [prcke_seq_no] ASC, [prcke_earn] ASC, [prcke_stid] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[prckemst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[prckemst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[prckemst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[prckemst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[prckemst] TO PUBLIC
    AS [dbo];

