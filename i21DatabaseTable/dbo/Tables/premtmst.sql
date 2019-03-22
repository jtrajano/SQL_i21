CREATE TABLE [dbo].[premtmst] (
    [premt_year]        SMALLINT        NOT NULL,
    [premt_qtrno]       TINYINT         NOT NULL,
    [premt_emp]         CHAR (10)       NOT NULL,
    [premt_tax_type]    TINYINT         NOT NULL,
    [premt_code]        CHAR (6)        NOT NULL,
    [premt_literal]     CHAR (10)       NULL,
    [premt_credit_yn]   CHAR (1)        NULL,
    [premt_taxable]     DECIMAL (11, 2) NULL,
    [premt_withheld]    DECIMAL (11, 2) NULL,
    [premt_total_wages] DECIMAL (11, 2) NULL,
    [premt_user_id]     CHAR (16)       NULL,
    [premt_user_rev_dt] INT             NULL,
    [A4GLIdentity]      NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_premtmst] PRIMARY KEY NONCLUSTERED ([premt_year] ASC, [premt_qtrno] ASC, [premt_emp] ASC, [premt_tax_type] ASC, [premt_code] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ipremtmst0]
    ON [dbo].[premtmst]([premt_year] ASC, [premt_qtrno] ASC, [premt_emp] ASC, [premt_tax_type] ASC, [premt_code] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Ipremtmst1]
    ON [dbo].[premtmst]([premt_year] ASC, [premt_emp] ASC, [premt_tax_type] ASC, [premt_code] ASC, [premt_qtrno] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Ipremtmst2]
    ON [dbo].[premtmst]([premt_emp] ASC, [premt_year] ASC, [premt_qtrno] ASC, [premt_tax_type] ASC, [premt_code] ASC);


GO
CREATE NONCLUSTERED INDEX [Ipremtmst3]
    ON [dbo].[premtmst]([premt_tax_type] ASC, [premt_code] ASC, [premt_emp] ASC, [premt_year] ASC);

