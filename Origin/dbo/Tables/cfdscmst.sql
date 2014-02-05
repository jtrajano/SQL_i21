﻿CREATE TABLE [dbo].[cfdscmst] (
    [cfdsc_schd]         CHAR (2)       NOT NULL,
    [cfdsc_desc]         CHAR (20)      NULL,
    [cfdsc_from_qty_1]   INT            NULL,
    [cfdsc_from_qty_2]   INT            NULL,
    [cfdsc_from_qty_3]   INT            NULL,
    [cfdsc_from_qty_4]   INT            NULL,
    [cfdsc_from_qty_5]   INT            NULL,
    [cfdsc_from_qty_6]   INT            NULL,
    [cfdsc_from_qty_7]   INT            NULL,
    [cfdsc_from_qty_8]   INT            NULL,
    [cfdsc_from_qty_9]   INT            NULL,
    [cfdsc_from_qty_10]  INT            NULL,
    [cfdsc_from_qty_11]  INT            NULL,
    [cfdsc_from_qty_12]  INT            NULL,
    [cfdsc_from_qty_13]  INT            NULL,
    [cfdsc_from_qty_14]  INT            NULL,
    [cfdsc_from_qty_15]  INT            NULL,
    [cfdsc_from_qty_16]  INT            NULL,
    [cfdsc_from_qty_17]  INT            NULL,
    [cfdsc_from_qty_18]  INT            NULL,
    [cfdsc_from_qty_19]  INT            NULL,
    [cfdsc_from_qty_20]  INT            NULL,
    [cfdsc_thru_qty_1]   INT            NULL,
    [cfdsc_thru_qty_2]   INT            NULL,
    [cfdsc_thru_qty_3]   INT            NULL,
    [cfdsc_thru_qty_4]   INT            NULL,
    [cfdsc_thru_qty_5]   INT            NULL,
    [cfdsc_thru_qty_6]   INT            NULL,
    [cfdsc_thru_qty_7]   INT            NULL,
    [cfdsc_thru_qty_8]   INT            NULL,
    [cfdsc_thru_qty_9]   INT            NULL,
    [cfdsc_thru_qty_10]  INT            NULL,
    [cfdsc_thru_qty_11]  INT            NULL,
    [cfdsc_thru_qty_12]  INT            NULL,
    [cfdsc_thru_qty_13]  INT            NULL,
    [cfdsc_thru_qty_14]  INT            NULL,
    [cfdsc_thru_qty_15]  INT            NULL,
    [cfdsc_thru_qty_16]  INT            NULL,
    [cfdsc_thru_qty_17]  INT            NULL,
    [cfdsc_thru_qty_18]  INT            NULL,
    [cfdsc_thru_qty_19]  INT            NULL,
    [cfdsc_thru_qty_20]  INT            NULL,
    [cfdsc_rt_per_un_1]  DECIMAL (6, 5) NULL,
    [cfdsc_rt_per_un_2]  DECIMAL (6, 5) NULL,
    [cfdsc_rt_per_un_3]  DECIMAL (6, 5) NULL,
    [cfdsc_rt_per_un_4]  DECIMAL (6, 5) NULL,
    [cfdsc_rt_per_un_5]  DECIMAL (6, 5) NULL,
    [cfdsc_rt_per_un_6]  DECIMAL (6, 5) NULL,
    [cfdsc_rt_per_un_7]  DECIMAL (6, 5) NULL,
    [cfdsc_rt_per_un_8]  DECIMAL (6, 5) NULL,
    [cfdsc_rt_per_un_9]  DECIMAL (6, 5) NULL,
    [cfdsc_rt_per_un_10] DECIMAL (6, 5) NULL,
    [cfdsc_rt_per_un_11] DECIMAL (6, 5) NULL,
    [cfdsc_rt_per_un_12] DECIMAL (6, 5) NULL,
    [cfdsc_rt_per_un_13] DECIMAL (6, 5) NULL,
    [cfdsc_rt_per_un_14] DECIMAL (6, 5) NULL,
    [cfdsc_rt_per_un_15] DECIMAL (6, 5) NULL,
    [cfdsc_rt_per_un_16] DECIMAL (6, 5) NULL,
    [cfdsc_rt_per_un_17] DECIMAL (6, 5) NULL,
    [cfdsc_rt_per_un_18] DECIMAL (6, 5) NULL,
    [cfdsc_rt_per_un_19] DECIMAL (6, 5) NULL,
    [cfdsc_rt_per_un_20] DECIMAL (6, 5) NULL,
    [cfdsc_user_id]      CHAR (16)      NULL,
    [cfdsc_user_rev_dt]  INT            NULL,
    [A4GLIdentity]       NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_cfdscmst] PRIMARY KEY NONCLUSTERED ([cfdsc_schd] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Icfdscmst0]
    ON [dbo].[cfdscmst]([cfdsc_schd] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[cfdscmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[cfdscmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[cfdscmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[cfdscmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[cfdscmst] TO PUBLIC
    AS [dbo];

