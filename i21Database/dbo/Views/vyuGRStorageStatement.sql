CREATE VIEW [dbo].[vyuGRStorageStatement]
AS 
SELECT DISTINCT 1 AS intStorageStatementId,
strFormNumber,dtmIssueDate,strItemNo,strStorageType FROM tblGRStorageStatement
