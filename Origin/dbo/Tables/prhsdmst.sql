CREATE TABLE [dbo].[prhsdmst] (
    [prhsd_emp_no]           CHAR (10)      NOT NULL,
    [prhsd_code]             CHAR (1)       NOT NULL,
    [prhsd_no]               CHAR (8)       NOT NULL,
    [prhsd_chk_type]         CHAR (1)       NOT NULL,
    [prhsd_ded]              CHAR (3)       NOT NULL,
    [prhsd_type]             CHAR (1)       NOT NULL,
    [prhsd_dept]             CHAR (4)       NOT NULL,
    [prhsd_amt]              DECIMAL (9, 2) NULL,
    [prhsd_acct_no]          CHAR (20)      NULL,
    [prhsd_ddp_bnk_code]     CHAR (4)       NULL,
    [prhsd_co_emp_cd]        CHAR (1)       NULL,
    [prhsd_literal]          CHAR (10)      NULL,
    [prhsd_acct_type_cs]     CHAR (1)       NULL,
    [prhsd_taxable_earnings] DECIMAL (9, 2) NULL,
    [prhsd_user_id]          CHAR (16)      NULL,
    [prhsd_user_rev_dt]      INT            NULL,
    [A4GLIdentity]           NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_prhsdmst] PRIMARY KEY NONCLUSTERED ([prhsd_emp_no] ASC, [prhsd_code] ASC, [prhsd_no] ASC, [prhsd_chk_type] ASC, [prhsd_ded] ASC, [prhsd_type] ASC, [prhsd_dept] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iprhsdmst0]
    ON [dbo].[prhsdmst]([prhsd_emp_no] ASC, [prhsd_code] ASC, [prhsd_no] ASC, [prhsd_chk_type] ASC, [prhsd_ded] ASC, [prhsd_type] ASC, [prhsd_dept] ASC);


GO
CREATE NONCLUSTERED INDEX [Iprhsdmst1]
    ON [dbo].[prhsdmst]([prhsd_code] ASC, [prhsd_no] ASC, [prhsd_chk_type] ASC, [prhsd_emp_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[prhsdmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[prhsdmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[prhsdmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[prhsdmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[prhsdmst] TO PUBLIC
    AS [dbo];

