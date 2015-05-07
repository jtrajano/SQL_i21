CREATE TABLE [dbo].[tblCTPosition](
	[intPositionId] [int] IDENTITY(1,1) NOT NULL,
	[strPosition] [nvarchar](30) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnDefault] [bit] NULL,
	[intSequence] [int] NULL,
	[intConcurrencyId] INT NOT NULL, 
	CONSTRAINT [PK_tblCTPosition_intPositionId] PRIMARY KEY CLUSTERED ([intPositionId] ASC)
)