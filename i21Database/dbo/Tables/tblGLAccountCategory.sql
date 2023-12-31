﻿CREATE TABLE [dbo].[tblGLAccountCategory]
(
	[intAccountCategoryId] [int] IDENTITY(1,1) NOT NULL,
	[strAccountCategory] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL ,
	[intConcurrencyId] [int] NOT NULL
    CONSTRAINT [PK_tblGLAccountCategory] PRIMARY KEY ([intAccountCategoryId]), 
    [strAccountGroupFilter] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL, 
    [ysnRestricted] BIT NULL,
)
