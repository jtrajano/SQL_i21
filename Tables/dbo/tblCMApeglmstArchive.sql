CREATE TABLE [dbo].[tblCMApeglmstArchive]
(
	[intApeglmstId] INT NOT NULL PRIMARY KEY IDENTITY,
	[intUndepositedFundId] INT NOT NULL,
    [apegl_cbk_no] CHAR(2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL, 
    [apegl_trx_ind] CHAR COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL, 
    [apegl_vnd_no] CHAR(10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL, 
    [apegl_ivc_no] CHAR(18) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL, 
    [apegl_dist_no] SMALLINT NOT NULL, 
    [apegl_alt_cbk_no] CHAR(2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL, 
    [apegl_gl_acct] DECIMAL(16, 8) NOT NULL, 
    [apegl_gl_amt] DECIMAL(11, 2) NULL, 
    [apegl_gl_un] DECIMAL(13, 4) NULL, 
    [intCreatedUserId] INT NULL, 
    [dtmCreated] DATETIME NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1
)

GO
CREATE INDEX [IX_tblCMApeglmstArchive_apegl_vnd_no] ON [dbo].[tblCMApeglmstArchive] ([apegl_vnd_no])
GO
CREATE INDEX [IX_tblCMApeglmstArchive_apegl_ivc_no] ON [dbo].[tblCMApeglmstArchive] ([apegl_ivc_no])
GO
CREATE INDEX [IX_tblCMApeglmstArchive_apegl_trx_ind] ON [dbo].[tblCMApeglmstArchive] ([apegl_trx_ind])
