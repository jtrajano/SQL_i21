CREATE TABLE [dbo].[ftcdemst] (
    [ftcde_type]              CHAR (1)    NOT NULL,
    [ftcde_loc_no]            CHAR (3)    NOT NULL,
    [ftcde_code_id]           CHAR (2)    NOT NULL,
    [ftcde_itm_no]            CHAR (13)   NOT NULL,
    [ftcde_crop_name]         CHAR (15)   NULL,
    [ftcde_end_crop_month]    TINYINT     NULL,
    [ftcde_app_method]        CHAR (30)   NULL,
    [ftcde_equip_desc]        CHAR (30)   NULL,
    [ftcde_mixer_type_ldb]    CHAR (1)    NULL,
    [ftcde_mixer_size]        INT         NULL,
    [ftcde_mixer_volume]      INT         NULL,
    [ftcde_max_batch_size]    INT         NULL,
    [ftcde_notes]             CHAR (128)  NULL,
    [ftcde_mixer_oversize_yn] CHAR (1)    NULL,
    [ftcde_user_id]           CHAR (16)   NULL,
    [ftcde_user_rev_dt]       INT         NULL,
    [A4GLIdentity]            NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_ftcdemst] PRIMARY KEY NONCLUSTERED ([ftcde_type] ASC, [ftcde_loc_no] ASC, [ftcde_code_id] ASC, [ftcde_itm_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iftcdemst0]
    ON [dbo].[ftcdemst]([ftcde_type] ASC, [ftcde_loc_no] ASC, [ftcde_code_id] ASC, [ftcde_itm_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[ftcdemst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ftcdemst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ftcdemst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ftcdemst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ftcdemst] TO PUBLIC
    AS [dbo];

