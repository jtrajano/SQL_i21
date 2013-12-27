CREATE TABLE [dbo].[prtrxmst] (
    [prtrx_emp]          CHAR (10)       NOT NULL,
    [prtrx_seq]          SMALLINT        NOT NULL,
    [prtrx_dept]         CHAR (4)        NOT NULL,
    [prtrx_type]         CHAR (1)        NULL,
    [prtrx_code]         CHAR (3)        NULL,
    [prtrx_ded_type]     CHAR (1)        NULL,
    [prtrx_reg_hrs]      DECIMAL (5, 2)  NULL,
    [prtrx_rate]         DECIMAL (11, 4) NULL,
    [prtrx_extended_amt] DECIMAL (11, 2) NULL,
    [prtrx_prwcc]        CHAR (6)        NULL,
    [prtrx_user_id]      CHAR (16)       NULL,
    [prtrx_user_rev_dt]  INT             NULL,
    [A4GLIdentity]       NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_prtrxmst] PRIMARY KEY NONCLUSTERED ([prtrx_emp] ASC, [prtrx_seq] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iprtrxmst0]
    ON [dbo].[prtrxmst]([prtrx_emp] ASC, [prtrx_seq] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iprtrxmst1]
    ON [dbo].[prtrxmst]([prtrx_dept] ASC, [prtrx_emp] ASC, [prtrx_seq] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[prtrxmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[prtrxmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[prtrxmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[prtrxmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[prtrxmst] TO PUBLIC
    AS [dbo];

