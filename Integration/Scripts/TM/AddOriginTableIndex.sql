PRINT N'BEGIN Adding of Index in Origin Tables'
GO

IF (NOT EXISTS (SELECT TOP 1 1 FROM sysindexes WHERE name = 'IX_ptcusmst_A4GLIdentity') AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'ptcusmst')) CREATE INDEX [IX_ptcusmst_A4GLIdentity] ON [dbo].[ptcusmst] ([A4GLIdentity])
GO

IF (NOT EXISTS (SELECT TOP 1 1 FROM sysindexes WHERE name = 'IX_agcusmst_A4GLIdentity') AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'agcusmst')) CREATE INDEX [IX_agcusmst_A4GLIdentity] ON [dbo].[agcusmst] ([A4GLIdentity])
GO

IF (NOT EXISTS (SELECT TOP 1 1 FROM sysindexes WHERE name = 'IX_agitmmst_A4GLIdentity') AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'agitmmst')) CREATE INDEX [IX_agitmmst_A4GLIdentity] ON [dbo].[agitmmst] ([A4GLIdentity])
GO

IF (NOT EXISTS (SELECT TOP 1 1 FROM sysindexes WHERE name = 'IX_agitmmst_agitm_loc_no') AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'agitmmst')) CREATE INDEX [IX_agitmmst_agitm_loc_no] ON [dbo].[agitmmst] ([agitm_loc_no])
GO

IF (NOT EXISTS (SELECT TOP 1 1 FROM sysindexes WHERE name = 'IX_ptitmmst_A4GLIdentity') AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'ptitmmst')) CREATE INDEX [IX_ptitmmst_A4GLIdentity] ON [dbo].[ptitmmst] ([A4GLIdentity])
GO

IF (NOT EXISTS (SELECT TOP 1 1 FROM sysindexes WHERE name = 'IX_ptitmmst_ptitm_loc_no') AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'ptitmmst')) CREATE INDEX [IX_ptitmmst_ptitm_loc_no] ON [dbo].[ptitmmst] ([ptitm_loc_no])
GO

IF (NOT EXISTS (SELECT TOP 1 1 FROM sysindexes WHERE name = 'IX_agslsmst_A4GLIdentity') AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'agslsmst')) CREATE INDEX [IX_agslsmst_A4GLIdentity] ON [dbo].[agslsmst] ([A4GLIdentity])
GO

IF (NOT EXISTS (SELECT TOP 1 1 FROM sysindexes WHERE name = 'IX_ptslsmst_A4GLIdentity') AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'ptslsmst')) CREATE INDEX [IX_ptslsmst_A4GLIdentity] ON [dbo].[ptslsmst] ([A4GLIdentity])
GO

IF (NOT EXISTS (SELECT TOP 1 1 FROM sysindexes WHERE name = 'IX_agslsmst_agsls_state') AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'agslsmst')) CREATE INDEX [IX_agslsmst_agsls_state] ON [dbo].[agslsmst] ([agsls_state])
GO

IF (NOT EXISTS (SELECT TOP 1 1 FROM sysindexes WHERE name = 'IX_ptslsmst_ptsls_state') AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'ptslsmst')) CREATE INDEX [IX_ptslsmst_ptsls_state] ON [dbo].[ptslsmst] ([ptsls_state])
GO

IF (NOT EXISTS (SELECT TOP 1 1 FROM sysindexes WHERE name = 'IX_aglclmst_A4GLIdentity') AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'aglclmst')) CREATE INDEX [IX_aglclmst_A4GLIdentity] ON [dbo].[aglclmst] ([A4GLIdentity])
GO

IF (NOT EXISTS (SELECT TOP 1 1 FROM sysindexes WHERE name = 'IX_ptlclmst_A4GLIdentity') AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'ptlclmst')) CREATE INDEX [IX_ptlclmst_A4GLIdentity] ON [dbo].[ptlclmst] ([A4GLIdentity])
GO

IF (NOT EXISTS (SELECT TOP 1 1 FROM sysindexes WHERE name = 'IX_agtrmmst_A4GLIdentity') AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'agtrmmst')) CREATE INDEX [IX_agtrmmst_A4GLIdentity] ON [dbo].[agtrmmst] ([A4GLIdentity])
GO

IF (NOT EXISTS (SELECT TOP 1 1 FROM sysindexes WHERE name = 'IX_pttrmmst_A4GLIdentity') AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'pttrmmst')) CREATE INDEX [IX_pttrmmst_A4GLIdentity] ON [dbo].[pttrmmst] ([A4GLIdentity])
GO

IF (NOT EXISTS (SELECT TOP 1 1 FROM sysindexes WHERE name = 'IX_spprcmst_A4GLIdentity') AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'spprcmst')) CREATE INDEX [IX_spprcmst_A4GLIdentity] ON [dbo].[spprcmst] ([A4GLIdentity])
GO

IF (NOT EXISTS (SELECT TOP 1 1 FROM sysindexes WHERE name = 'IX_spprcmst_spprc_cus_no') AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'spprcmst')) CREATE INDEX [IX_spprcmst_spprc_cus_no] ON [dbo].[spprcmst] ([spprc_cus_no])
GO

IF (NOT EXISTS (SELECT TOP 1 1 FROM sysindexes WHERE name = 'IX_spprcmst_spprc_itm_no') AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'spprcmst')) CREATE INDEX [IX_spprcmst_spprc_itm_no] ON [dbo].[spprcmst] ([spprc_itm_no])
GO

IF (NOT EXISTS (SELECT TOP 1 1 FROM sysindexes WHERE name = 'IX_ptpdvmst_A4GLIdentity') AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'ptpdvmst')) CREATE INDEX [IX_ptpdvmst_A4GLIdentity] ON [dbo].[ptpdvmst] ([A4GLIdentity])
GO

IF (NOT EXISTS (SELECT TOP 1 1 FROM sysindexes WHERE name = 'IX_ptpdvmst_ptpdv_cus_no') AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'ptpdvmst')) CREATE INDEX [IX_ptpdvmst_ptpdv_cus_no] ON [dbo].[ptpdvmst] ([ptpdv_cus_no])
GO

IF (NOT EXISTS (SELECT TOP 1 1 FROM sysindexes WHERE name = 'IX_ptpdvmst_ptpdv_itm_no') AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'ptpdvmst')) CREATE INDEX [IX_ptpdvmst_ptpdv_itm_no] ON [dbo].[ptpdvmst] ([ptpdv_itm_no])
GO

PRINT N'END Adding of Index in Origin Tables'
GO