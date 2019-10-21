CREATE TABLE [dbo].[tblCRMPriority]
(
	[intPriorityId] [int] IDENTITY(1,1) NOT NULL,
	[strPriority] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](150) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnActivity] [bit] NULL DEFAULT 0,
	[ysnOpportunity] [bit] NULL DEFAULT 0,
	[ysnDefaultActivity] [bit] NULL DEFAULT 0,
	[ysnDefaultOpportunity] [bit] NULL DEFAULT 0,
	[strJIRAPriority] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[strIcon] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strFontColor] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strBackColor] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intSort] [int] NULL,
	[intTurnAroundDays] [int] NULL,
	[ysnUpdated] [bit] NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblCRMPriority] PRIMARY KEY CLUSTERED ([intPriorityId] ASC),
 CONSTRAINT [UNQ_tblCRMPriority] UNIQUE ([strPriority])
)