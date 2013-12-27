CREATE TABLE [dbo].[jdprdmst] (
    [jdprd_product_line]     CHAR (10)   NOT NULL,
    [jdprd_prd_line_name]    CHAR (50)   NULL,
    [jdprd_start_acct_range] CHAR (16)   NULL,
    [jdprd_end_acct_range]   CHAR (16)   NULL,
    [jdprd_timestamp]        CHAR (25)   NULL,
    [jdprd_user_id]          CHAR (16)   NULL,
    [jdprd_user_rev_dt]      INT         NULL,
    [A4GLIdentity]           NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_jdprdmst] PRIMARY KEY NONCLUSTERED ([jdprd_product_line] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Ijdprdmst0]
    ON [dbo].[jdprdmst]([jdprd_product_line] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[jdprdmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[jdprdmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[jdprdmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[jdprdmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[jdprdmst] TO PUBLIC
    AS [dbo];

