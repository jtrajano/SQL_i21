CREATE TABLE [dbo].[tblEMContactDetailType]
(
	[intContactDetailTypeId]		INT NOT NULL IDENTITY(1,1),
	[strField]						NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strType]						NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strMasking]					NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[ysnDefault]					BIT NOT NULL DEFAULT(0),
	[intConcurrencyId]				INT CONSTRAINT [DF_tblEMContactDetailType_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblEMContactDetailType] PRIMARY KEY CLUSTERED ([intContactDetailTypeId] ASC),	
	
)
