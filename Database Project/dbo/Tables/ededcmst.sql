CREATE TABLE [dbo].[ededcmst] (
    [ededc_vics_cust_no_n]       BIGINT      NOT NULL,
    [ededc_vics_store_n]         BIGINT      NOT NULL,
    [ededc_ship_to_cus]          CHAR (10)   NOT NULL,
    [ededc_batch_no]             SMALLINT    NOT NULL,
    [ededc_zone_n]               INT         NULL,
    [ededc_ivc_exp_pgm]          CHAR (8)    NULL,
    [ededc_ord_imp_pgm]          CHAR (8)    NULL,
    [ededc_mobil_buyback_acct_n] BIGINT      NULL,
    [A4GLIdentity]               NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_ededcmst] PRIMARY KEY NONCLUSTERED ([ededc_vics_cust_no_n] ASC, [ededc_vics_store_n] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iededcmst0]
    ON [dbo].[ededcmst]([ededc_vics_cust_no_n] ASC, [ededc_vics_store_n] ASC);


GO
CREATE NONCLUSTERED INDEX [Iededcmst1]
    ON [dbo].[ededcmst]([ededc_ship_to_cus] ASC, [ededc_batch_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ededcmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ededcmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ededcmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ededcmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ededcmst] TO PUBLIC
    AS [dbo];

