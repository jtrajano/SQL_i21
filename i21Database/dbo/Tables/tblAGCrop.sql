 CREATE TABLE [dbo].[tblAGCrop]
 (
	[intCropId] INT IDENTITY(1,1) NOT NULL,
	[strCrop] NVARCHAR(250) COLLATE Latin1_General_CI_AS  NOT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT(0),
	CONSTRAINT [UK_tblAGCrop_strCrop] UNIQUE ([strCrop]),
	CONSTRAINT [PK_dbo.tblAGCrop_intCropId] PRIMARY KEY CLUSTERED ([intCropId] ASC)
 )
