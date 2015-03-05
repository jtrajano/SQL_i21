CREATE TABLE [dbo].[tblCTWeightGrade]
(
	[intWeightGradeId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[strWeightGradeDesc] [nvarchar](30) COLLATE Latin1_General_CI_AS NOT NULL,
	[intOriginDest] [int] NOT NULL CONSTRAINT [DF_tblCTWeightGrade_intOriginDest]  DEFAULT ((1)),
	[ysnActive] [bit] NOT NULL CONSTRAINT [DF_tblCTWeightGrade_ysnActive]  DEFAULT ((1)),
	[ysnWeight] BIT NULL, 
    [ysnGrade] BIT NULL, 
    [dblFranchise] NUMERIC(4, 2) NULL, 
    [ysnSample] BIT NULL, 
	CONSTRAINT [PK_tblCTWeightGrade_intWeightGradeId] PRIMARY KEY CLUSTERED ([intWeightGradeId] ASC), 	
	CONSTRAINT [UQ_tblCTWeightGrade_strWeightGradeDesc] UNIQUE ([strWeightGradeDesc])
)


