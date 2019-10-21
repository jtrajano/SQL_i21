CREATE TABLE [dbo].[tblIPSAPProductType]
(
	[intProductTypeId] INT identity(1, 1),
	[strSAPProductType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[stri21ProductType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	CONSTRAINT [PK_tblIPSAPProductType_intProductTypeId] PRIMARY KEY ([intProductTypeId]) 
)
