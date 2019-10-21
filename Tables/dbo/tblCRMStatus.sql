CREATE TABLE [dbo].[tblCRMStatus]
(
	[intStatusId] [int] IDENTITY(1,1) NOT NULL,
	[strStatus] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](150) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnActivity] [bit] NULL DEFAULT 0,
	[ysnOpportunity] [bit] NULL DEFAULT 0,
	[ysnDefaultActivity] [bit] NULL DEFAULT 0,
	[ysnDefaultOpportunity] [bit] NULL DEFAULT 0,
	[strIcon] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strFontColor] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strBackColor] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[ysnSupported] [bit] NOT NULL DEFAULT 1,
	[intSort] [int] NULL,
	[ysnUpdated] [bit] NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
 CONSTRAINT [PK_tblCRMStatus] PRIMARY KEY CLUSTERED ([intStatusId] ASC),
 CONSTRAINT [UNQ_tblCRMStatus] UNIQUE ([strStatus])
)