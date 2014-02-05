CREATE TABLE [dbo].[cfponmst] (
    [cfpon_ar_cus_no]       CHAR (10)   NOT NULL,
    [cfpon_expiration_date] INT         NOT NULL,
    [cfpon_po_no]           CHAR (10)   NULL,
    [cfpon_user_id]         CHAR (16)   NULL,
    [cfpon_user_rev_dt]     INT         NULL,
    [A4GLIdentity]          NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_cfponmst] PRIMARY KEY NONCLUSTERED ([cfpon_ar_cus_no] ASC, [cfpon_expiration_date] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Icfponmst0]
    ON [dbo].[cfponmst]([cfpon_ar_cus_no] ASC, [cfpon_expiration_date] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[cfponmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[cfponmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[cfponmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[cfponmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[cfponmst] TO PUBLIC
    AS [dbo];

