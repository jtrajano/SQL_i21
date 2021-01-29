 CREATE TABLE [dbo].[tblAGApplicationType]
 (
	[intApplicationTypeId] INT IDENTITY(1,1) NOT NULL,
	[strType] NVARCHAR(100) COLLATE Latin1_General_CI_AS  NOT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT(0),
	CONSTRAINT [UK_tblAGApplicationType_strType] UNIQUE([strType]),
	CONSTRAINT [PK_dbo.tblAGApplicationType_intApplicationTypeId] PRIMARY KEY CLUSTERED ([intApplicationTypeId] ASC)
 )