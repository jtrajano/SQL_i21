CREATE TABLE [dbo].[adcalmst] (
    [adcal_loc_no]          CHAR (3)        NOT NULL,
    [adcal_cus_no]          CHAR (10)       NOT NULL,
    [adcal_itm_no]          CHAR (13)       NOT NULL,
    [adcal_tank_no]         CHAR (4)        NOT NULL,
    [adcal_dlvry_qty]       DECIMAL (11, 4) NULL,
    [adcal_dlvry_terms_n]   TINYINT         NULL,
    [adcal_comment]         CHAR (30)       NULL,
    [adcal_load_no]         SMALLINT        NULL,
    [adcal_disp_rev_dt]     INT             NULL,
    [adcal_prc]             DECIMAL (11, 5) NULL,
    [adcal_total]           DECIMAL (9, 2)  NULL,
    [adcal_req_rev_dt]      INT             NOT NULL,
    [adcal_rte_id]          CHAR (3)        NOT NULL,
    [adcal_seq]             SMALLINT        NOT NULL,
    [adcal_priority]        TINYINT         NOT NULL,
    [adcal_selected_yn]     CHAR (1)        NULL,
    [adcal_dispatch_item]   CHAR (13)       NULL,
    [adcal_dispatch_driver] CHAR (3)        NULL,
    [adcal_sales_rep]       CHAR (3)        NULL,
    [adcal_user_id]         CHAR (16)       NULL,
    [adcal_user_rev_dt]     CHAR (8)        NULL,
    [adcal_user_time]       SMALLINT        NULL,
    [A4GLIdentity]          NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    [adcal_tax_amt]         DECIMAL (9, 2)  NULL,
    CONSTRAINT [k_adcalmst] PRIMARY KEY NONCLUSTERED ([adcal_loc_no] ASC, [adcal_cus_no] ASC, [adcal_itm_no] ASC, [adcal_tank_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iadcalmst0]
    ON [dbo].[adcalmst]([adcal_loc_no] ASC, [adcal_cus_no] ASC, [adcal_itm_no] ASC, [adcal_tank_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iadcalmst1]
    ON [dbo].[adcalmst]([adcal_cus_no] ASC, [adcal_itm_no] ASC, [adcal_tank_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iadcalmst2]
    ON [dbo].[adcalmst]([adcal_req_rev_dt] ASC, [adcal_rte_id] ASC, [adcal_seq] ASC, [adcal_priority] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[adcalmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[adcalmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[adcalmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[adcalmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[adcalmst] TO PUBLIC
    AS [dbo];

