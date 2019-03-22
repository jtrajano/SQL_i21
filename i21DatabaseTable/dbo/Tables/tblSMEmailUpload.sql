CREATE TABLE [dbo].[tblSMEmailUpload]
(
	[intEmailUploadId] INT NOT NULL PRIMARY KEY IDENTITY, 
	[strImageId] [nvarchar](36) COLLATE Latin1_General_CI_AS NULL,
	[strFileIdentifier] [uniqueidentifier] NOT NULL,
	[strFilename] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strFileLocation] [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL,
	[blbFile] [varbinary](max) NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1
)
