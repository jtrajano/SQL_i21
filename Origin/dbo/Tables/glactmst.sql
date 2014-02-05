CREATE TABLE [dbo].[glactmst] (
    [glact_acct1_8]      INT         NOT NULL,
    [glact_acct9_16]     INT         NOT NULL,
    [glact_desc]         CHAR (30)   NOT NULL,
    [glact_type]         CHAR (1)    NULL,
    [glact_normal_value] CHAR (1)    NULL,
    [glact_saf_cat]      CHAR (1)    NULL,
    [glact_flow_cat]     CHAR (1)    NULL,
    [glact_uom]          CHAR (6)    NULL,
    [glact_verify_flag]  CHAR (1)    NULL,
    [glact_active_yn]    CHAR (1)    NULL,
    [glact_sys_acct_yn]  CHAR (1)    NULL,
    [glact_desc_lookup]  CHAR (8)    NOT NULL,
    [glact_user_fld_1]   CHAR (10)   NULL,
    [glact_user_fld_2]   CHAR (10)   NULL,
    [glact_user_id]      CHAR (16)   NULL,
    [glact_user_rev_dt]  INT         NULL,
    [A4GLIdentity]       NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_glactmst] PRIMARY KEY NONCLUSTERED ([glact_acct1_8] ASC, [glact_acct9_16] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iglactmst0]
    ON [dbo].[glactmst]([glact_acct1_8] ASC, [glact_acct9_16] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iglactmst1]
    ON [dbo].[glactmst]([glact_acct9_16] ASC, [glact_acct1_8] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iglactmst2]
    ON [dbo].[glactmst]([glact_desc] ASC, [glact_acct1_8] ASC, [glact_acct9_16] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iglactmst3]
    ON [dbo].[glactmst]([glact_desc_lookup] ASC, [glact_acct1_8] ASC, [glact_acct9_16] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[glactmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[glactmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[glactmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[glactmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[glactmst] TO PUBLIC
    AS [dbo];

