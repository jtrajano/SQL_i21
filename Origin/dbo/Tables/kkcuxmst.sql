CREATE TABLE [dbo].[kkcuxmst] (
    [kkcux_cus_no]      CHAR (10)   NOT NULL,
    [kkcux_bdg_cus_no]  CHAR (10)   NOT NULL,
    [kkcux_ef_acct_no]  BIGINT      NOT NULL,
    [kkcux_user_id]     CHAR (16)   NULL,
    [kkcux_user_rev_dt] CHAR (8)    NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_kkcuxmst] PRIMARY KEY NONCLUSTERED ([kkcux_cus_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ikkcuxmst0]
    ON [dbo].[kkcuxmst]([kkcux_cus_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Ikkcuxmst1]
    ON [dbo].[kkcuxmst]([kkcux_bdg_cus_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Ikkcuxmst2]
    ON [dbo].[kkcuxmst]([kkcux_ef_acct_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[kkcuxmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[kkcuxmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[kkcuxmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[kkcuxmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[kkcuxmst] TO PUBLIC
    AS [dbo];

