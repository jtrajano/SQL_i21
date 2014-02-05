CREATE TABLE [dbo].[ftrstmst] (
    [ftrst_itm_no]        CHAR (13)      NOT NULL,
    [ftrst_loc_no]        CHAR (3)       NOT NULL,
    [ftrst_cus_no]        CHAR (10)      NOT NULL,
    [ftrst_farm_no]       CHAR (10)      NOT NULL,
    [ftrst_field_no]      CHAR (10)      NOT NULL,
    [ftrst_app_date]      INT            NOT NULL,
    [ftrst_applicator_no] CHAR (10)      NULL,
    [ftrst_crop]          CHAR (15)      NULL,
    [ftrst_acres]         DECIMAL (9, 2) NULL,
    [ftrst_ord_no]        INT            NULL,
    [ftrst_qty]           DECIMAL (9, 2) NULL,
    [ftrst_qty_uom]       CHAR (3)       NULL,
    [ftrst_user_id]       CHAR (16)      NULL,
    [ftrst_user_rev_dt]   INT            NULL,
    [A4GLIdentity]        NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_ftrstmst] PRIMARY KEY NONCLUSTERED ([ftrst_itm_no] ASC, [ftrst_loc_no] ASC, [ftrst_cus_no] ASC, [ftrst_farm_no] ASC, [ftrst_field_no] ASC, [ftrst_app_date] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iftrstmst0]
    ON [dbo].[ftrstmst]([ftrst_itm_no] ASC, [ftrst_loc_no] ASC, [ftrst_cus_no] ASC, [ftrst_farm_no] ASC, [ftrst_field_no] ASC, [ftrst_app_date] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iftrstmst1]
    ON [dbo].[ftrstmst]([ftrst_cus_no] ASC, [ftrst_farm_no] ASC, [ftrst_field_no] ASC, [ftrst_itm_no] ASC, [ftrst_app_date] ASC);

