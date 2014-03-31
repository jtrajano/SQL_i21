CREATE TABLE [dbo].[tblHDJobCode]
(
	[intJobCodeId] [int] IDENTITY(1,1) NOT NULL,
	[strJobCode] [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[ysnBillable] [bit] NOT NULL,
	[intRate] [numeric](18, 6) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblHDJobCode] PRIMARY KEY CLUSTERED 
(
	[intJobCodeId] ASC
)
)
