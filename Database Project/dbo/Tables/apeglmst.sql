CREATE TABLE [dbo].[apeglmst] (
    [apegl_cbk_no]     CHAR (2)        NOT NULL,
    [apegl_trx_ind]    CHAR (1)        NOT NULL,
    [apegl_vnd_no]     CHAR (10)       NOT NULL,
    [apegl_ivc_no]     CHAR (18)       NOT NULL,
    [apegl_dist_no]    SMALLINT        NOT NULL,
    [apegl_alt_cbk_no] CHAR (2)        NOT NULL,
    [apegl_gl_acct]    DECIMAL (16, 8) NOT NULL,
    [apegl_gl_amt]     DECIMAL (11, 2) NULL,
    [apegl_gl_un]      DECIMAL (13, 4) NULL,
    [A4GLIdentity]     NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_apeglmst] PRIMARY KEY NONCLUSTERED ([apegl_cbk_no] ASC, [apegl_trx_ind] ASC, [apegl_vnd_no] ASC, [apegl_ivc_no] ASC, [apegl_dist_no] ASC, [apegl_alt_cbk_no] ASC, [apegl_gl_acct] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iapeglmst0]
    ON [dbo].[apeglmst]([apegl_cbk_no] ASC, [apegl_trx_ind] ASC, [apegl_vnd_no] ASC, [apegl_ivc_no] ASC, [apegl_dist_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iapeglmst1]
    ON [dbo].[apeglmst]([apegl_alt_cbk_no] ASC, [apegl_gl_acct] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[apeglmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[apeglmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[apeglmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[apeglmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[apeglmst] TO PUBLIC
    AS [dbo];

