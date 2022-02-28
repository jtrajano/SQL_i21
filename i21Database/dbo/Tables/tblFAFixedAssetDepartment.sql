CREATE TABLE [dbo].[tblFAFixedAssetDepartment]
(
	[intAssetDepartmentId]		INT IDENTITY (1, 1) NOT NULL,
	[strDepartmentName]			NVARCHAR (255) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId]			INT DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFAFixedAssetDepartment] PRIMARY KEY CLUSTERED ([intAssetDepartmentId] ASC)
)
