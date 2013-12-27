CREATE TABLE [dbo].[premdmst] (
    [premd_year]                 SMALLINT        NOT NULL,
    [premd_qtrno]                TINYINT         NOT NULL,
    [premd_emp]                  CHAR (10)       NOT NULL,
    [premd_code]                 CHAR (3)        NOT NULL,
    [premd_type]                 CHAR (1)        NOT NULL,
    [premd_literal]              CHAR (10)       NULL,
    [premd_last_chk_dt]          INT             NULL,
    [premd_ytd_amt]              DECIMAL (11, 2) NULL,
    [premd_taxable_earn_to_date] DECIMAL (9, 2)  NULL,
    [premd_user_id]              CHAR (16)       NULL,
    [premd_user_rev_dt]          INT             NULL,
    [A4GLIdentity]               NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_premdmst] PRIMARY KEY NONCLUSTERED ([premd_year] ASC, [premd_qtrno] ASC, [premd_emp] ASC, [premd_code] ASC, [premd_type] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Ipremdmst0]
    ON [dbo].[premdmst]([premd_year] ASC, [premd_qtrno] ASC, [premd_emp] ASC, [premd_code] ASC, [premd_type] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Ipremdmst1]
    ON [dbo].[premdmst]([premd_year] ASC, [premd_emp] ASC, [premd_code] ASC, [premd_qtrno] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Ipremdmst2]
    ON [dbo].[premdmst]([premd_emp] ASC, [premd_year] ASC, [premd_qtrno] ASC, [premd_code] ASC);


GO
CREATE NONCLUSTERED INDEX [Ipremdmst3]
    ON [dbo].[premdmst]([premd_code] ASC, [premd_emp] ASC, [premd_year] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[premdmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[premdmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[premdmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[premdmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[premdmst] TO PUBLIC
    AS [dbo];

