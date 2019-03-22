CREATE TABLE [dbo].[tblCTRailGrade](
	[intRailGradeId] [int] NOT NULL,
	[strRailGrade] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblCTRailGrade_intRailGradeId] PRIMARY KEY ([intRailGradeId])
 )
