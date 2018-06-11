CREATE TABLE [dbo].[tblSMTaxClassXref](
	[intTaxClassXrefId] [int] IDENTITY(1,1) NOT NULL,
	[intTaxClassId] [int] NOT NULL,
	[strTaxClass] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,		
	[strTaxClassType] char (3) COLLATE Latin1_General_CI_AS NULL ,
PRIMARY KEY CLUSTERED 
(
	[intTaxClassXrefId] ASC
)WITH ( STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)

GO


