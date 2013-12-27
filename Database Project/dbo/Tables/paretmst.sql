CREATE TABLE [dbo].[paretmst] (
    [paret_cus_no]       CHAR (10)      NOT NULL,
    [paret_cert_no]      CHAR (8)       NOT NULL,
    [paret_stock_status] CHAR (1)       NULL,
    [paret_stock_type]   TINYINT        NULL,
    [paret_no_shares]    DECIMAL (9, 2) NULL,
    [paret_par_value]    SMALLINT       NULL,
    [paret_issue_rev_dt] INT            NULL,
    [paret_activity_cd]  CHAR (1)       NULL,
    [paret_ret_ind]      CHAR (1)       NULL,
    [paret_chk_no]       CHAR (8)       NULL,
    [paret_trx_ind]      CHAR (1)       NULL,
    [paret_chk_rev_dt]   INT            NULL,
    [paret_chk_amt]      DECIMAL (9, 2) NULL,
    [paret_ret_fracs_yn] CHAR (1)       NULL,
    [paret_user_id]      CHAR (16)      NULL,
    [paret_user_rev_dt]  INT            NULL,
    [A4GLIdentity]       NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_paretmst] PRIMARY KEY NONCLUSTERED ([paret_cus_no] ASC, [paret_cert_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iparetmst0]
    ON [dbo].[paretmst]([paret_cus_no] ASC, [paret_cert_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iparetmst1]
    ON [dbo].[paretmst]([paret_cert_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[paretmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[paretmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[paretmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[paretmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[paretmst] TO PUBLIC
    AS [dbo];

