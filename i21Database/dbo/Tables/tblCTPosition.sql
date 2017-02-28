﻿CREATE TABLE [dbo].[tblCTPosition](
	[intPositionId] [int] IDENTITY(1,1) NOT NULL,
	[strPosition] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strPositionType] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnDefault] [bit] NULL,
	[intNoOfDays] [int],
	[intConcurrencyId] INT NOT NULL, 
	CONSTRAINT [PK_tblCTPosition_intPositionId] PRIMARY KEY CLUSTERED ([intPositionId] ASC),
	CONSTRAINT [UK_tblCTPosition_strPosition] UNIQUE ([strPosition]),
)