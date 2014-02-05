CREATE TABLE [dbo].[kklocmst] (
    [kkloc_loc_no]            CHAR (3)       NOT NULL,
    [kkloc_file_path]         CHAR (50)      NULL,
    [kkloc_release_no]        DECIMAL (4, 2) NULL,
    [kkloc_acct_stat_cd]      CHAR (10)      NULL,
    [kkloc_bill_cd_1]         TINYINT        NULL,
    [kkloc_bill_cd_2]         TINYINT        NULL,
    [kkloc_bill_cd_3]         TINYINT        NULL,
    [kkloc_bill_cd_4]         TINYINT        NULL,
    [kkloc_bill_cd_5]         TINYINT        NULL,
    [kkloc_bill_cd_6]         TINYINT        NULL,
    [kkloc_bill_cd_7]         TINYINT        NULL,
    [kkloc_bill_cd_8]         TINYINT        NULL,
    [kkloc_bill_cd_9]         TINYINT        NULL,
    [kkloc_bill_cd_10]        TINYINT        NULL,
    [kkloc_term_cd_1]         TINYINT        NULL,
    [kkloc_term_cd_2]         TINYINT        NULL,
    [kkloc_term_cd_3]         TINYINT        NULL,
    [kkloc_term_cd_4]         TINYINT        NULL,
    [kkloc_term_cd_5]         TINYINT        NULL,
    [kkloc_term_cd_6]         TINYINT        NULL,
    [kkloc_term_cd_7]         TINYINT        NULL,
    [kkloc_term_cd_8]         TINYINT        NULL,
    [kkloc_term_cd_9]         TINYINT        NULL,
    [kkloc_term_cd_10]        TINYINT        NULL,
    [kkloc_use_tic_as_inv_yn] CHAR (1)       NULL,
    [kkloc_user_id]           CHAR (16)      NULL,
    [kkloc_user_rev_dt]       INT            NULL,
    [A4GLIdentity]            NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_kklocmst] PRIMARY KEY NONCLUSTERED ([kkloc_loc_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ikklocmst0]
    ON [dbo].[kklocmst]([kkloc_loc_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[kklocmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[kklocmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[kklocmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[kklocmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[kklocmst] TO PUBLIC
    AS [dbo];

