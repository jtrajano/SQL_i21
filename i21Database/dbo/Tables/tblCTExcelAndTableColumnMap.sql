CREATE TABLE [dbo].[tblCTExcelAndTableColumnMap]
(
	intExcelAndTableColumnMapId INT IDENTITY (1,1) PRIMARY KEY,
    strTableName				NVARCHAR(100) COLLATE Latin1_General_CI_AS,
    strExcelColumnName			NVARCHAR(100) COLLATE Latin1_General_CI_AS,
    strTableCoulmnName			NVARCHAR(100) COLLATE Latin1_General_CI_AS,
    strRefTable					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
    strRefTableIdCol			NVARCHAR(100) COLLATE Latin1_General_CI_AS,
    strRefCoulumnToCmpr			NVARCHAR(100) COLLATE Latin1_General_CI_AS,
    strJoinType					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
    strSpecialJoin				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
)
