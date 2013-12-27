CREATE TABLE [dbo].[glfsgmst] (
    [glfsg_code]             CHAR (10)   NOT NULL,
    [glfsg_seq]              SMALLINT    NOT NULL,
    [glfsg_desc]             CHAR (30)   NULL,
    [glfsg_suspend_yn]       CHAR (1)    NULL,
    [glfsg_selection_no]     SMALLINT    NULL,
    [glfsg_format_no]        SMALLINT    NULL,
    [glfsg_print_yn]         CHAR (1)    NULL,
    [glfsg_no_copies]        TINYINT     NULL,
    [glfsg_consolidate_yno]  CHAR (1)    NULL,
    [glfsg_use_prc_group_yn] CHAR (1)    NULL,
    [glfsg_glpcg_code]       CHAR (10)   NULL,
    [glfsg_beg_prc_n]        INT         NULL,
    [glfsg_end_prc_n]        INT         NULL,
    [glfsg_user_id]          CHAR (16)   NULL,
    [glfsg_user_rev_dt]      INT         NULL,
    [A4GLIdentity]           NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_glfsgmst] PRIMARY KEY NONCLUSTERED ([glfsg_code] ASC, [glfsg_seq] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iglfsgmst0]
    ON [dbo].[glfsgmst]([glfsg_code] ASC, [glfsg_seq] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[glfsgmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[glfsgmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[glfsgmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[glfsgmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[glfsgmst] TO PUBLIC
    AS [dbo];

