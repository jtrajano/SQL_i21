CREATE TABLE [dbo].[tblSMTooltip]
(
	[intTooltipId] INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[intScreenId] INT NULL,
	[strControlId] NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL,
	[strControlName] NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL,
	[strGroupName] NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL,
	[strContainer] NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL,
	[strControlType] NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL,
	[strScreenName] NVARCHAR(500)	COLLATE Latin1_General_CI_AS NULL,
	[strTooltip] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	[strParentScreen] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	[strPlacement] NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]  INT NOT NULL DEFAULT 1,
)
