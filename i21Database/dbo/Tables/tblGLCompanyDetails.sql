
CREATE TABLE [dbo].[tblGLCompanyDetails](
	[intAccountSegmentId] [int],
	[strCompanyName] [nvarchar](50) NULL,
	[strFEIN] [nvarchar](10) NULL,
	[strAddress] [nvarchar](300) NULL,
	CONSTRAINT [PK_tblGLCompanyDetails] PRIMARY KEY CLUSTERED ([intAccountSegmentId] ASC)
) 
GO