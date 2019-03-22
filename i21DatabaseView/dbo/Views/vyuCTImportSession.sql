﻿CREATE VIEW [dbo].[vyuCTImportSession]

AS 
	SELECT CAST(ROW_NUMBER() OVER (ORDER BY dtmSession DESC) AS INT) intUniqueId,*
    FROM
    (
	   SELECT DISTINCT  CAST(SUBSTRING(CAST(intSession AS NVARCHAR(MAX)),1,4)  +
	   '-'+SUBSTRING(CAST(intSession AS NVARCHAR(MAX)),5,2) + 
	   '-'+SUBSTRING(CAST(intSession AS NVARCHAR(MAX)),7,2) +
	   ' '+SUBSTRING(CAST(intSession AS NVARCHAR(MAX)),9,2) +
	   ':'+SUBSTRING(CAST(intSession AS NVARCHAR(MAX)),11,2) +
	   ':'+SUBSTRING(CAST(intSession AS NVARCHAR(MAX)),13,2) AS DATETIME) dtmSession,
	   intSession,
	   'Contract' COLLATE Latin1_General_CI_AS AS strType
	   FROM tblCTContractImport

	   UNION 

	   SELECT DISTINCT  CAST(SUBSTRING(CAST(intSession AS NVARCHAR(MAX)),1,4)  +
	   '-'+SUBSTRING(CAST(intSession AS NVARCHAR(MAX)),5,2) + 
	   '-'+SUBSTRING(CAST(intSession AS NVARCHAR(MAX)),7,2) +
	   ' '+SUBSTRING(CAST(intSession AS NVARCHAR(MAX)),9,2) +
	   ':'+SUBSTRING(CAST(intSession AS NVARCHAR(MAX)),11,2) +
	   ':'+SUBSTRING(CAST(intSession AS NVARCHAR(MAX)),13,2) AS DATETIME) dtmSession,
	   intSession,
	   'Balance' AS strType

	   FROM tblCTImportBalance

	   UNION 

	   SELECT DISTINCT  CAST(SUBSTRING(CAST(intSession AS NVARCHAR(MAX)),1,4)  +
	   '-'+SUBSTRING(CAST(intSession AS NVARCHAR(MAX)),5,2) + 
	   '-'+SUBSTRING(CAST(intSession AS NVARCHAR(MAX)),7,2) +
	   ' '+SUBSTRING(CAST(intSession AS NVARCHAR(MAX)),9,2) +
	   ':'+SUBSTRING(CAST(intSession AS NVARCHAR(MAX)),11,2) +
	   ':'+SUBSTRING(CAST(intSession AS NVARCHAR(MAX)),13,2) AS DATETIME) dtmSession,
	   intSession,
	   'AOP' AS strType

	   FROM tblCTImportAOP
    )t
