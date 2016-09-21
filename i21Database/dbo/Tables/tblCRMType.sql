CREATE TABLE [dbo].[tblCRMType]
(
	[intTypeId] [int] IDENTITY(1,1) NOT NULL,
	[strType] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](150) COLLATE Latin1_General_CI_AS NOT NULL,
	[strJIRAType] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[strIcon] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[ysnActivity] [bit] NULL,
	[ysnOpportunity] [bit] NULL,
	[ysnCampaign] [bit] NULL,
	[ysnSupported] [bit] NOT NULL DEFAULT 1,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblCRMType] PRIMARY KEY CLUSTERED ([intTypeId] ASC),
 CONSTRAINT [UNQ_tblCRMType] UNIQUE ([strType])
)