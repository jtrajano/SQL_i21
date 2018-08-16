CREATE TABLE [dbo].[tblCTExcelAndTableColumnMap]
(
	intExcelAndTableColumnMapId INT IDENTITY (1,1) PRIMARY KEY,
    strTableName				NVARCHAR(100),
    strExcelColumnName			NVARCHAR(100),
    strTableCoulmnName			NVARCHAR(100),
    strRefTable					NVARCHAR(100),
    strRefTableIdCol			NVARCHAR(100),
    strRefCoulumnToCmpr			NVARCHAR(100),
    strJoinType					NVARCHAR(100),
    strSpecialJoin				NVARCHAR(MAX),
)
