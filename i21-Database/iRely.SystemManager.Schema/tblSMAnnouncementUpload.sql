CREATE TABLE [dbo].[tblSMAnnouncementUpload]
(
	[intAnnouncementUploadId] [int] IDENTITY(1,1) NOT NULL,
	[strImageId] [nvarchar](36) COLLATE Latin1_General_CI_AS NULL,
	[strFileIdentifier] [uniqueidentifier] NOT NULL,
	[strFilename] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strFileLocation] [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL,
	[blbFile] [varbinary](max) NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1, 
	CONSTRAINT [PK_tblSMUpload] PRIMARY KEY CLUSTERED ([intAnnouncementUploadId] ASC)
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMAnnouncementUpload',
    @level2type = N'COLUMN',
    @level2name = N'intAnnouncementUploadId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Comment Image Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMAnnouncementUpload',
    @level2type = N'COLUMN',
    @level2name = N'strImageId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Field Identifier',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMAnnouncementUpload',
    @level2type = N'COLUMN',
    @level2name = N'strFileIdentifier'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Image File Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMAnnouncementUpload',
    @level2type = N'COLUMN',
    @level2name = N'strFilename'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'File Location',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMAnnouncementUpload',
    @level2type = N'COLUMN',
    @level2name = N'strFileLocation'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'File',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMAnnouncementUpload',
    @level2type = N'COLUMN',
    @level2name = N'blbFile'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMAnnouncementUpload',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'