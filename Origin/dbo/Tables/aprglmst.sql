CREATE TABLE [dbo].[aprglmst] (
    [aprgl_cbk_no]     CHAR (2)        NOT NULL,
    [aprgl_trx_ind]    CHAR (1)        NOT NULL,
    [aprgl_vnd_no]     CHAR (10)       NOT NULL,
    [aprgl_ivc_no]     CHAR (18)       NOT NULL,
    [aprgl_dist_no]    SMALLINT        NOT NULL,
    [aprgl_alt_cbk_no] CHAR (2)        NOT NULL,
    [aprgl_gl_acct]    DECIMAL (16, 8) NOT NULL,
    [aprgl_gl_amt]     DECIMAL (11, 2) NULL,
    [aprgl_gl_un]      DECIMAL (13, 4) NULL,
    [A4GLIdentity]     NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_aprglmst] PRIMARY KEY NONCLUSTERED ([aprgl_cbk_no] ASC, [aprgl_trx_ind] ASC, [aprgl_vnd_no] ASC, [aprgl_ivc_no] ASC, [aprgl_dist_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iaprglmst0]
    ON [dbo].[aprglmst]([aprgl_cbk_no] ASC, [aprgl_trx_ind] ASC, [aprgl_vnd_no] ASC, [aprgl_ivc_no] ASC, [aprgl_dist_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iaprglmst1]
    ON [dbo].[aprglmst]([aprgl_alt_cbk_no] ASC, [aprgl_gl_acct] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[aprglmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[aprglmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[aprglmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[aprglmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[aprglmst] TO PUBLIC
    AS [dbo];

