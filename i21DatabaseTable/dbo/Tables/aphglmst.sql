CREATE TABLE [dbo].[aphglmst] (
    [aphgl_cbk_no]     CHAR (2)        NOT NULL,
    [aphgl_trx_ind]    CHAR (1)        NOT NULL,
    [aphgl_vnd_no]     CHAR (10)       NOT NULL,
    [aphgl_ivc_no]     CHAR (18)       NOT NULL,
    [aphgl_dist_no]    SMALLINT        NOT NULL,
    [aphgl_alt_cbk_no] CHAR (2)        NOT NULL,
    [aphgl_gl_acct]    DECIMAL (16, 8) NOT NULL,
    [aphgl_gl_amt]     DECIMAL (11, 2) NULL,
    [aphgl_gl_un]      DECIMAL (13, 4) NULL,
    [A4GLIdentity]     NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_aphglmst] PRIMARY KEY NONCLUSTERED ([aphgl_cbk_no] ASC, [aphgl_trx_ind] ASC, [aphgl_vnd_no] ASC, [aphgl_ivc_no] ASC, [aphgl_dist_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iaphglmst0]
    ON [dbo].[aphglmst]([aphgl_cbk_no] ASC, [aphgl_trx_ind] ASC, [aphgl_vnd_no] ASC, [aphgl_ivc_no] ASC, [aphgl_dist_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iaphglmst1]
    ON [dbo].[aphglmst]([aphgl_alt_cbk_no] ASC, [aphgl_gl_acct] ASC);

