CREATE TABLE [dbo].[tblCTWeightGrade](
	[intWeightGradeId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[strWeightGradeDesc] [nvarchar](30) COLLATE Latin1_General_CI_AS NOT NULL,
	[intOriginDest] [int] NOT NULL CONSTRAINT [DF_tblCTWeightGrade_intOriginDest]  DEFAULT ((1)),
	[ysnActive] [bit] NOT NULL CONSTRAINT [DF_tblCTWeightGrade_ysnActive]  DEFAULT ((1)),
 CONSTRAINT [PK_tblCTWeightGrade_intWeightGradeId] PRIMARY KEY CLUSTERED 
(
	[intWeightGradeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY], 
    CONSTRAINT [UQ_tblCTWeightGrade_strWeightGradeDesc] UNIQUE ([strWeightGradeDesc])
) ON [PRIMARY]

GO

