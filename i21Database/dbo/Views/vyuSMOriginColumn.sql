CREATE VIEW [dbo].[vyuSMOriginColumn]  
AS  
  
SELECT   
	A.[name]						AS strColumnName,  
	C.[name]						AS strTableName,
	A.[object_id]					AS intTableId,
	A.[column_id]					AS intColumnId,
	B.[name]						AS strDataType,
	A.[is_nullable]					AS ysnAllowNull,
	CAST(A.[max_length] AS INT)		AS intSize,
	CAST(A.[precision]	AS INT)		AS intPrecision,
	CAST(A.[scale]		AS INT)		AS intScale
FROM sys.columns  A 
	INNER JOIN sys.systypes B 
		ON A.system_type_id = B.xtype
	INNER JOIN sys.tables C
		ON A.object_id = C.object_id
WHERE A.object_id 
IN
(
	SELECT object_id 
	FROM sys.tables   
	WHERE name NOT LIKE 'tbl%' AND name  NOT LIKE 'cst%'
)