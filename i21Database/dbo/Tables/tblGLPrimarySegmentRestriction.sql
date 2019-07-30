CREATE TABLE [dbo].[tblGLPrimarySegmentRestriction](
	[intRestrictionId] [int] IDENTITY(1,1) NOT NULL,
	[intEntityId] [int] NOT NULL,
	[strCode] [nvarchar](20) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblGLPrimarySegmentRestriction] PRIMARY KEY CLUSTERED 
(
	[intRestrictionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
