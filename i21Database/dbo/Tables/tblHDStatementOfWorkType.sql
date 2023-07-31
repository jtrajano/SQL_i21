CREATE TABLE [dbo].[tblHDStatementOfWorkType]
(
	[intTypeId]			INT IDENTITY(1,1) NOT NULL,
	[strType]			NVARCHAR(50)				COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription]	NVARCHAR(100)				COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]  INT NOT NULL,
	CONSTRAINT [PK_tblHDStatementOfWorkType_intTypeId] PRIMARY KEY CLUSTERED ([intTypeId] ASC),
	CONSTRAINT [UQ_tblHDStatementOfWorkType_strType] UNIQUE ([strType])
)
GO
