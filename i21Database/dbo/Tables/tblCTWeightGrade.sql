CREATE TABLE [dbo].[tblCTWeightGrade]
(
	[intWeightGradeId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[strWeightGradeDesc] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	strWhereFinalized [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnActive] [bit] NOT NULL CONSTRAINT [DF_tblCTWeightGrade_ysnActive]  DEFAULT ((1)),
	[ysnWeight] BIT NULL, 
    [ysnGrade] BIT NULL, 
    [dblFranchise] NUMERIC(18, 6) NULL, 
    [ysnSample] BIT NULL, 
    [ysnPayablesOnShippedWeights] BIT NULL, 
	intAccountId INT,
	CONSTRAINT [PK_tblCTWeightGrade_intWeightGradeId] PRIMARY KEY CLUSTERED ([intWeightGradeId] ASC), 	
	CONSTRAINT [UQ_tblCTWeightGrade_strWeightGradeDesc] UNIQUE ([strWeightGradeDesc]),
	CONSTRAINT [FK_tblCTWeightGrade_tblGLAccount_intAccountId] FOREIGN KEY ([intAccountId]) REFERENCES [tblGLAccount]([intAccountId])
)
GO

CREATE NONCLUSTERED INDEX [IX_tblCTWeightGrade_intWeightGradeId]
		ON [dbo].[tblCTWeightGrade]([intWeightGradeId] ASC)
GO