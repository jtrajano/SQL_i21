
CREATE TABLE [dbo].[tblGLCompanyDetails](
	[intCompanyDetailsId] [int] IDENTITY(1,1),
	[intAccountSegmentId][int],
	[strCompanyName] [nvarchar](50) NULL,
	[strFEIN] [nvarchar](10) NULL,
	[strAddress] [nvarchar](300) NULL,
	[intConcurrencyId] INT NULL,
	CONSTRAINT [PK_tblGLCompanyDetails] PRIMARY KEY CLUSTERED ([intCompanyDetailsId] ASC)
) 
GO