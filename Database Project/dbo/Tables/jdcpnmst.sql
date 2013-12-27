CREATE TABLE [dbo].[jdcpnmst] (
    [jdcpn_product_line]   CHAR (10)      NOT NULL,
    [jdcpn_crd_plan_no]    INT            NOT NULL,
    [jdcpn_crd_plan_name]  CHAR (50)      NULL,
    [jdcpn_start_date]     CHAR (8)       NULL,
    [jdcpn_end_date]       CHAR (8)       NULL,
    [jdcpn_min_purch_amt]  DECIMAL (6, 2) NULL,
    [jdcpn_timestamp]      CHAR (25)      NULL,
    [jdcpn_budget_billing] CHAR (1)       NOT NULL,
    [jdcpn_alt_pl]         CHAR (10)      NOT NULL,
    [jdcpn_alt_cp]         INT            NOT NULL,
    [jdcpn_user_id]        CHAR (16)      NULL,
    [jdcpn_user_rev_dt]    INT            NULL,
    [A4GLIdentity]         NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_jdcpnmst] PRIMARY KEY NONCLUSTERED ([jdcpn_product_line] ASC, [jdcpn_crd_plan_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Ijdcpnmst0]
    ON [dbo].[jdcpnmst]([jdcpn_product_line] ASC, [jdcpn_crd_plan_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Ijdcpnmst1]
    ON [dbo].[jdcpnmst]([jdcpn_budget_billing] ASC, [jdcpn_alt_pl] ASC, [jdcpn_alt_cp] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[jdcpnmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[jdcpnmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[jdcpnmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[jdcpnmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[jdcpnmst] TO PUBLIC
    AS [dbo];

