CREATE TABLE [dbo].[agcommst] (
    [agcom_stmt_cd]           CHAR (1)       NOT NULL,
    [agcom_desc_1]            CHAR (60)      NULL,
    [agcom_desc_2]            CHAR (60)      NULL,
    [agcom_desc_3]            CHAR (60)      NULL,
    [agcom_desc_4]            CHAR (60)      NULL,
    [agcom_desc_5]            CHAR (60)      NULL,
    [agcom_comment_1]         CHAR (50)      NULL,
    [agcom_comment_2]         CHAR (50)      NULL,
    [agcom_comment_3]         CHAR (50)      NULL,
    [agcom_stm_disc_rev_dt]   INT            NULL,
    [agcom_stm_disc_pct]      DECIMAL (5, 2) NULL,
    [agcom_stm_srvch_rev_dt]  INT            NULL,
    [agcom_stm_srvch_per]     CHAR (1)       NULL,
    [agcom_stm_disc_reset_yn] CHAR (1)       NULL,
    [agcom_user_id]           CHAR (16)      NULL,
    [agcom_user_rev_dt]       INT            NULL,
    [A4GLIdentity]            NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agcommst] PRIMARY KEY NONCLUSTERED ([agcom_stmt_cd] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iagcommst0]
    ON [dbo].[agcommst]([agcom_stmt_cd] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agcommst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agcommst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agcommst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agcommst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[agcommst] TO PUBLIC
    AS [dbo];

