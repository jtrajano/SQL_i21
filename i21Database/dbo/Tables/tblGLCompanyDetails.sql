
CREATE TABLE [dbo].[tblGLCompanyDetails](
	[intCompanyDetailsId] [int] IDENTITY(1,1),
	[intAccountSegmentId][int],
	[strCompanyName] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strFEIN] [nvarchar](10) COLLATE Latin1_General_CI_AS NULL,
	[strAddress] [nvarchar](300) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NULL,
	CONSTRAINT [PK_tblGLCompanyDetails] PRIMARY KEY CLUSTERED ([intCompanyDetailsId] ASC)
) 
GO