CREATE TABLE [dbo].[prememst] (
    [preme_year]         SMALLINT        NOT NULL,
    [preme_qtrno]        TINYINT         NOT NULL,
    [preme_emp]          CHAR (10)       NOT NULL,
    [preme_code]         CHAR (3)        NOT NULL,
    [preme_stid]         CHAR (2)        NOT NULL,
    [preme_literal]      CHAR (10)       NULL,
    [preme_reg_hrs]      DECIMAL (6, 2)  NULL,
    [preme_reg_earn]     DECIMAL (11, 2) NULL,
    [preme_last_chk_dt]  INT             NULL,
    [preme_prern_class]  CHAR (1)        NULL,
    [preme_memo_type_tw] CHAR (1)        NULL,
    [preme_user_id]      CHAR (16)       NULL,
    [preme_user_rev_dt]  INT             NULL,
    [A4GLIdentity]       NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_prememst] PRIMARY KEY NONCLUSTERED ([preme_year] ASC, [preme_qtrno] ASC, [preme_emp] ASC, [preme_code] ASC, [preme_stid] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iprememst0]
    ON [dbo].[prememst]([preme_year] ASC, [preme_qtrno] ASC, [preme_emp] ASC, [preme_code] ASC, [preme_stid] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iprememst1]
    ON [dbo].[prememst]([preme_year] ASC, [preme_emp] ASC, [preme_code] ASC, [preme_stid] ASC, [preme_qtrno] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iprememst2]
    ON [dbo].[prememst]([preme_emp] ASC, [preme_year] ASC, [preme_qtrno] ASC, [preme_code] ASC, [preme_stid] ASC);


GO
CREATE NONCLUSTERED INDEX [Iprememst3]
    ON [dbo].[prememst]([preme_code] ASC, [preme_stid] ASC, [preme_emp] ASC, [preme_year] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[prememst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[prememst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[prememst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[prememst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[prememst] TO PUBLIC
    AS [dbo];

