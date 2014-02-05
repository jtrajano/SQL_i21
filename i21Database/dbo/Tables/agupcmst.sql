CREATE TABLE [dbo].[agupcmst] (
    [agupc_code_type]      CHAR (4)    NOT NULL,
    [agupc_item_no]        CHAR (13)   NOT NULL,
    [agupc_loc_no]         CHAR (3)    NOT NULL,
    [agupc_upc_cd]         CHAR (20)   NOT NULL,
    [agupc_vendor_no]      CHAR (10)   NULL,
    [agupc_uom_text]       CHAR (33)   NULL,
    [agupc_uom_agitm_mult] INT         NULL,
    [agupc_user_id]        CHAR (16)   NULL,
    [agupc_user_rev_dt]    INT         NULL,
    [A4GLIdentity]         NUMERIC (9) IDENTITY (1, 1) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagupcmst0]
    ON [dbo].[agupcmst]([agupc_code_type] ASC, [agupc_item_no] ASC, [agupc_loc_no] ASC, [agupc_upc_cd] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagupcmst1]
    ON [dbo].[agupcmst]([agupc_code_type] ASC, [agupc_loc_no] ASC, [agupc_upc_cd] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagupcmst2]
    ON [dbo].[agupcmst]([agupc_item_no] ASC, [agupc_loc_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagupcmst3]
    ON [dbo].[agupcmst]([agupc_loc_no] ASC, [agupc_upc_cd] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagupcmst4]
    ON [dbo].[agupcmst]([agupc_upc_cd] ASC);

