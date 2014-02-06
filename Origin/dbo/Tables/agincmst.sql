CREATE TABLE [dbo].[agincmst] (
    [aginc_oth_inc_cd]   CHAR (2)        NOT NULL,
    [aginc_cus_no]       CHAR (10)       NOT NULL,
    [aginc_ref_no]       CHAR (8)        NOT NULL,
    [aginc_loc_no]       CHAR (3)        NOT NULL,
    [aginc_line_no]      SMALLINT        NOT NULL,
    [aginc_rev_dt]       INT             NULL,
    [aginc_amt]          DECIMAL (11, 2) NULL,
    [aginc_gl_acct]      DECIMAL (16, 8) NULL,
    [aginc_pay_type]     CHAR (1)        NULL,
    [aginc_comment]      CHAR (30)       NULL,
    [aginc_batch_no]     SMALLINT        NULL,
    [aginc_audit_no]     CHAR (4)        NULL,
    [aginc_currency]     CHAR (3)        NULL,
    [aginc_currency_rt]  DECIMAL (15, 8) NULL,
    [aginc_currency_cnt] CHAR (8)        NULL,
    [aginc_user_id]      CHAR (16)       NULL,
    [aginc_user_rev_dt]  INT             NULL,
    [A4GLIdentity]       NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agincmst] PRIMARY KEY NONCLUSTERED ([aginc_oth_inc_cd] ASC, [aginc_cus_no] ASC, [aginc_ref_no] ASC, [aginc_loc_no] ASC, [aginc_line_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagincmst0]
    ON [dbo].[agincmst]([aginc_oth_inc_cd] ASC, [aginc_cus_no] ASC, [aginc_ref_no] ASC, [aginc_loc_no] ASC, [aginc_line_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagincmst1]
    ON [dbo].[agincmst]([aginc_cus_no] ASC, [aginc_ref_no] ASC, [aginc_loc_no] ASC, [aginc_line_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[agincmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agincmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agincmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agincmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agincmst] TO PUBLIC
    AS [dbo];

