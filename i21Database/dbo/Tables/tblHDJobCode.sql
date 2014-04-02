CREATE TABLE [dbo].[tblHDJobCode]
(
	[intJobCodeId] [int] IDENTITY(1,1) NOT NULL,
	[strJobCode] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL,
	[ysnBillable] [bit] NOT NULL,
	[dblRate] [numeric](18, 6) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblHDJobCode] PRIMARY KEY CLUSTERED ([intJobCodeId] ASC),
 CONSTRAINT [UNQ_tblHDJobCode] UNIQUE ([strJobCode])
)
