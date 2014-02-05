CREATE TABLE [dbo].[prwccmst] (
    [prwcc_code]         CHAR (6)       NOT NULL,
    [prwcc_desc]         CHAR (25)      NULL,
    [prwcc_desc2]        CHAR (25)      NULL,
    [prwcc_company_rate] DECIMAL (8, 6) NULL,
    [prwcc_rate_type]    CHAR (1)       NULL,
    [prwcc_user_id]      CHAR (16)      NULL,
    [prwcc_user_rev_dt]  INT            NULL,
    [A4GLIdentity]       NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_prwccmst] PRIMARY KEY NONCLUSTERED ([prwcc_code] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iprwccmst0]
    ON [dbo].[prwccmst]([prwcc_code] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[prwccmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[prwccmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[prwccmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[prwccmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[prwccmst] TO PUBLIC
    AS [dbo];

