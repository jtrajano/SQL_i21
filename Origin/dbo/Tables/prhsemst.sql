CREATE TABLE [dbo].[prhsemst] (
    [prhse_emp_no]       CHAR (10)       NOT NULL,
    [prhse_code]         CHAR (1)        NOT NULL,
    [prhse_no]           CHAR (8)        NOT NULL,
    [prhse_chk_type]     CHAR (1)        NOT NULL,
    [prhse_seq_no]       INT             NOT NULL,
    [prhse_earn]         CHAR (3)        NOT NULL,
    [prhse_stid]         CHAR (2)        NOT NULL,
    [prhse_dept]         CHAR (4)        NOT NULL,
    [prhse_rate]         DECIMAL (11, 4) NULL,
    [prhse_reg_hrs]      DECIMAL (6, 2)  NULL,
    [prhse_reg_earn]     DECIMAL (11, 2) NULL,
    [prhse_literal]      CHAR (10)       NULL,
    [prhse_prwcc]        CHAR (6)        NULL,
    [prhse_class]        CHAR (1)        NULL,
    [prhse_memo_type_tw] CHAR (1)        NULL,
    [prhse_user_id]      CHAR (16)       NULL,
    [prhse_user_rev_dt]  INT             NULL,
    [A4GLIdentity]       NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_prhsemst] PRIMARY KEY NONCLUSTERED ([prhse_emp_no] ASC, [prhse_code] ASC, [prhse_no] ASC, [prhse_chk_type] ASC, [prhse_seq_no] ASC, [prhse_earn] ASC, [prhse_stid] ASC, [prhse_dept] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iprhsemst0]
    ON [dbo].[prhsemst]([prhse_emp_no] ASC, [prhse_code] ASC, [prhse_no] ASC, [prhse_chk_type] ASC, [prhse_seq_no] ASC, [prhse_earn] ASC, [prhse_stid] ASC, [prhse_dept] ASC);


GO
CREATE NONCLUSTERED INDEX [Iprhsemst1]
    ON [dbo].[prhsemst]([prhse_code] ASC, [prhse_no] ASC, [prhse_chk_type] ASC, [prhse_emp_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[prhsemst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[prhsemst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[prhsemst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[prhsemst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[prhsemst] TO PUBLIC
    AS [dbo];

