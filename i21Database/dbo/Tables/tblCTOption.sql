CREATE TABLE [dbo].[tblCTOption]
(
	[intOptionId] [int] NOT NULL,
	[strOption] [nvarchar](100)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strControlName] [nvarchar](100)  COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL, 
    CONSTRAINT [PK_tblCTOption_intOptionId] PRIMARY KEY ([intOptionId])
)

