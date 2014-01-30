CREATE TABLE [dbo].[apchkmst_origin] (
    [apchk_cbk_no]       CHAR (2)        NOT NULL,
    [apchk_rev_dt]       INT             NOT NULL,
    [apchk_trx_ind]      CHAR (1)        NOT NULL,
    [apchk_chk_no]       CHAR (8)        NOT NULL,
    [apchk_alt_cbk_no]   CHAR (2)        NOT NULL,
    [apchk_alt_trx_ind]  CHAR (1)        NOT NULL,
    [apchk_alt_chk_no]   CHAR (8)        NOT NULL,
    [apchk_vnd_no]       CHAR (10)       NOT NULL,
    [apchk_alt2_cbk_no]  CHAR (2)        NOT NULL,
    [apchk_name]         CHAR (50)       NOT NULL,
    [apchk_addr_1]       CHAR (30)       NULL,
    [apchk_addr_2]       CHAR (30)       NULL,
    [apchk_city]         CHAR (20)       NULL,
    [apchk_st]           CHAR (2)        NULL,
    [apchk_zip]          CHAR (10)       NULL,
    [apchk_chk_amt]      DECIMAL (11, 2) NULL,
    [apchk_disc_amt]     DECIMAL (11, 2) NULL,
    [apchk_wthhld_amt]   DECIMAL (11, 2) NULL,
    [apchk_1099_amt]     DECIMAL (11, 2) NULL,
    [apchk_gl_rev_dt]    INT             NULL,
    [apchk_adv_chk_yn]   CHAR (1)        NULL,
    [apchk_man_auto_ind] CHAR (1)        NULL,
    [apchk_void_ind]     CHAR (1)        NULL,
    [apchk_void_rev_dt]  INT             NULL,
    [apchk_cleared_ind]  CHAR (1)        NULL,
    [apchk_clear_rev_dt] INT             NULL,
    [apchk_src_sys]      CHAR (2)        NULL,
    [apchk_comment_1]    CHAR (40)       NULL,
    [apchk_comment_2]    CHAR (40)       NULL,
    [apchk_comment_3]    CHAR (40)       NULL,
    [apchk_currency_rt]  DECIMAL (15, 8) NULL,
    [apchk_currency_cnt] CHAR (8)        NULL,
    [apchk_payee_1]      CHAR (50)       NULL,
    [apchk_payee_2]      CHAR (50)       NULL,
    [apchk_payee_3]      CHAR (50)       NULL,
    [apchk_payee_4]      CHAR (50)       NULL,
    [apchk_user_id]      CHAR (16)       NULL,
    [apchk_user_rev_dt]  INT             NULL,
    [A4GLIdentity]       NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_apchkmst] PRIMARY KEY NONCLUSTERED ([apchk_cbk_no] ASC, [apchk_rev_dt] ASC, [apchk_trx_ind] ASC, [apchk_chk_no] ASC)
);




GO
CREATE NONCLUSTERED INDEX [Iapchkmst3]
    ON [dbo].[apchkmst_origin]([apchk_name] ASC);


GO
CREATE NONCLUSTERED INDEX [Iapchkmst2]
    ON [dbo].[apchkmst_origin]([apchk_vnd_no] ASC, [apchk_alt2_cbk_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iapchkmst1]
    ON [dbo].[apchkmst_origin]([apchk_alt_cbk_no] ASC, [apchk_alt_trx_ind] ASC, [apchk_alt_chk_no] ASC);


GO
CREATE UNIQUE CLUSTERED INDEX [Iapchkmst0]
    ON [dbo].[apchkmst_origin]([apchk_cbk_no] ASC, [apchk_rev_dt] ASC, [apchk_trx_ind] ASC, [apchk_chk_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[apchkmst_origin] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[apchkmst_origin] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[apchkmst_origin] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[apchkmst_origin] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[apchkmst_origin] TO PUBLIC
    AS [dbo];

