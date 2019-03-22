CREATE TABLE [dbo].[tblCTAction]
(
	[intActionId] [int] IDENTITY(1,1) NOT NULL,
	[strActionName] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strInternalCode] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strRoute] [nvarchar](MAX) COLLATE Latin1_General_CI_AS  NULL,
	[intConcurrencyId] INT NOT NULL, 
	CONSTRAINT [PK_tblCTAction_intActionId] PRIMARY KEY CLUSTERED ([intActionId] ASC),
	CONSTRAINT [UK_tblCTAction_strActionName] UNIQUE ([strActionName])
)
