CREATE TABLE [dbo].[paonamst] (
    [paona_type_cs]     CHAR (1)    NOT NULL,
    [paona_cus_no]      CHAR (10)   NOT NULL,
    [paona_stock_type]  TINYINT     NOT NULL,
    [paona_name]        CHAR (50)   NULL,
    [paona_addr]        CHAR (30)   NULL,
    [paona_addr2]       CHAR (30)   NULL,
    [paona_city]        CHAR (20)   NULL,
    [paona_state]       CHAR (2)    NULL,
    [paona_zip]         CHAR (10)   NULL,
    [paona_user_id]     CHAR (16)   NULL,
    [paona_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_paonamst] PRIMARY KEY NONCLUSTERED ([paona_type_cs] ASC, [paona_cus_no] ASC, [paona_stock_type] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ipaonamst0]
    ON [dbo].[paonamst]([paona_type_cs] ASC, [paona_cus_no] ASC, [paona_stock_type] ASC);

