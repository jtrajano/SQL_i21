CREATE TABLE [dbo].[ftcusmst] (
    [ftcus_cus_no]        CHAR (10)       NOT NULL,
    [ftcus_farm_no]       CHAR (10)       NOT NULL,
    [ftcus_field_no]      CHAR (10)       NOT NULL,
    [ftcus_farm_desc]     CHAR (30)       NULL,
    [ftcus_field_desc]    CHAR (30)       NULL,
    [ftcus_dflt_loc_no]   CHAR (3)        NULL,
    [ftcus_acres]         DECIMAL (11, 2) NULL,
    [ftcus_split]         CHAR (4)        NULL,
    [ftcus_split_type]    CHAR (1)        NULL,
    [ftcus_comments]      CHAR (30)       NULL,
    [ftcus_directions1]   CHAR (50)       NULL,
    [ftcus_directions2]   CHAR (50)       NULL,
    [ftcus_directions3]   CHAR (50)       NULL,
    [ftcus_directions4]   CHAR (50)       NULL,
    [ftcus_lat_deg]       DECIMAL (4, 2)  NULL,
    [ftcus_lat_ns]        CHAR (1)        NULL,
    [ftcus_long_deg]      DECIMAL (5, 2)  NULL,
    [ftcus_long_ew]       CHAR (1)        NULL,
    [ftcus_fsa_no]        CHAR (10)       NULL,
    [ftcus_obsolete_yn]   CHAR (1)        NULL,
    [ftcus_bmp_field_map] CHAR (60)       NULL,
    [ftcus_user_id]       CHAR (16)       NULL,
    [ftcus_user_rev_dt]   INT             NULL,
    [A4GLIdentity]        NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_ftcusmst] PRIMARY KEY NONCLUSTERED ([ftcus_cus_no] ASC, [ftcus_farm_no] ASC, [ftcus_field_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iftcusmst0]
    ON [dbo].[ftcusmst]([ftcus_cus_no] ASC, [ftcus_farm_no] ASC, [ftcus_field_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ftcusmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ftcusmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ftcusmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ftcusmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ftcusmst] TO PUBLIC
    AS [dbo];

