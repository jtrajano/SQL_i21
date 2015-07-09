CREATE TABLE [dbo].[tblSRFilterField]
(
	[intFilterFieldId] [int] NOT NULL IDENTITY(1, 1),
	[intUserId] [int] NULL,
	[strReportModule] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
	[strReportName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
	[strFieldName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
	[strDataType] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
	[strCondition] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
	[strFromValue] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
	[strToValue] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
	[strOperator] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
	[ysnIsActive] [bit] NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblSRFilterField] PRIMARY KEY CLUSTERED ([intFilterFieldId] ASC)
)
