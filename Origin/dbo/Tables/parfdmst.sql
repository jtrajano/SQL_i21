CREATE TABLE [dbo].[parfdmst] (
    [parfd_key]                   TINYINT         NOT NULL,
    [parfd_description]           CHAR (20)       NULL,
    [parfd_gl_general_reserve]    DECIMAL (16, 8) NULL,
    [parfd_gl_alloc_reserve]      DECIMAL (16, 8) NULL,
    [parfd_gl_undist_rfd]         DECIMAL (16, 8) NULL,
    [parfd_cash_pct]              DECIMAL (5, 2)  NULL,
    [parfd_equity_cash_pct]       DECIMAL (5, 2)  NULL,
    [parfd_equity_ccyy]           SMALLINT        NULL,
    [parfd_alloc_res_pct_tyr]     DECIMAL (5, 2)  NULL,
    [parfd_alloc_res_pct_pyr]     DECIMAL (5, 2)  NULL,
    [parfd_alloc_res_redeem_ccyy] SMALLINT        NULL,
    [parfd_rate_1]                DECIMAL (9, 8)  NULL,
    [parfd_rate_2]                DECIMAL (9, 8)  NULL,
    [parfd_rate_3]                DECIMAL (9, 8)  NULL,
    [parfd_rate_4]                DECIMAL (9, 8)  NULL,
    [parfd_rate_5]                DECIMAL (9, 8)  NULL,
    [parfd_rate_6]                DECIMAL (9, 8)  NULL,
    [parfd_rate_7]                DECIMAL (9, 8)  NULL,
    [parfd_rate_8]                DECIMAL (9, 8)  NULL,
    [parfd_rate_9]                DECIMAL (9, 8)  NULL,
    [parfd_rate_10]               DECIMAL (9, 8)  NULL,
    [parfd_rate_11]               DECIMAL (9, 8)  NULL,
    [parfd_rate_12]               DECIMAL (9, 8)  NULL,
    [parfd_rate_13]               DECIMAL (9, 8)  NULL,
    [parfd_rate_14]               DECIMAL (9, 8)  NULL,
    [parfd_rate_15]               DECIMAL (9, 8)  NULL,
    [parfd_rate_16]               DECIMAL (9, 8)  NULL,
    [parfd_rate_17]               DECIMAL (9, 8)  NULL,
    [parfd_rate_18]               DECIMAL (9, 8)  NULL,
    [parfd_rate_19]               DECIMAL (9, 8)  NULL,
    [parfd_rate_20]               DECIMAL (9, 8)  NULL,
    [parfd_user_id]               CHAR (16)       NULL,
    [parfd_user_rev_dt]           INT             NULL,
    [A4GLIdentity]                NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_parfdmst] PRIMARY KEY NONCLUSTERED ([parfd_key] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iparfdmst0]
    ON [dbo].[parfdmst]([parfd_key] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[parfdmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[parfdmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[parfdmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[parfdmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[parfdmst] TO PUBLIC
    AS [dbo];

