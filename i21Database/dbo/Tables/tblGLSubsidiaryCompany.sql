

CREATE TABLE [dbo].[tblGLSubsidiaryCompany](
	[intSubsidiaryCompanyId] [int] IDENTITY(1,1) NOT NULL,
	[strDatabase] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strCompany] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
    [strCompanySegment] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
    [ysnCompanySegment] BIT NULL,
 CONSTRAINT [PK_tblGLSubsidiaryCompany] PRIMARY KEY CLUSTERED 
(
	[intSubsidiaryCompanyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
