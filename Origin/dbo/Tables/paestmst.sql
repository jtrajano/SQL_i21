CREATE TABLE [dbo].[paestmst] (
    [paest_corp_cus_no] CHAR (10)      NOT NULL,
    [paest_rfd_type]    TINYINT        NOT NULL,
    [paest_seq_no]      TINYINT        NOT NULL,
    [paest_cus_no]      CHAR (10)      NULL,
    [paest_owner_pct]   DECIMAL (6, 3) NULL,
    [paest_paid_rev_dt] INT            NULL,
    [paest_paid_amt]    DECIMAL (9, 2) NULL,
    [paest_paid_chk_no] CHAR (8)       NULL,
    [paest_user_id]     CHAR (16)      NULL,
    [paest_user_rev_dt] INT            NULL,
    [A4GLIdentity]      NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_paestmst] PRIMARY KEY NONCLUSTERED ([paest_corp_cus_no] ASC, [paest_rfd_type] ASC, [paest_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ipaestmst0]
    ON [dbo].[paestmst]([paest_corp_cus_no] ASC, [paest_rfd_type] ASC, [paest_seq_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[paestmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[paestmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[paestmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[paestmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[paestmst] TO PUBLIC
    AS [dbo];

