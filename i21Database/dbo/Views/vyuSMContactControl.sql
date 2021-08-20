CREATE VIEW [dbo].[vyuSMContactControl]
AS 
SELECT DISTINCT
	intControlId,
	A.intScreenId,
	strControlId,
	strControlName,
	ISNULL(B.strGroupName, C.strCategory) COLLATE Latin1_General_CI_AS AS strGroupName,
	CASE 
		WHEN ISNULL(A.strContainer, 0) <> 0 THEN A.strContainer 
		ELSE B.strScreenName 
	END AS strContainer,
	strControlType,
	A.intConcurrencyId,
	CASE 
		WHEN ISNULL(C.strMenuName, '') <> '' THEN REPLACE(C.strMenuName, '(Portal)', '') 
		ELSE B.strScreenName 
	END AS strScreenName
FROM [tblSMControl] A
INNER JOIN [tblSMScreen] B ON B.intScreenId = A.intScreenId
LEFT JOIN [tblSMMasterMenu] C ON B.strNamespace = LEFT(C.strCommand, (CASE WHEN (CHARINDEX('?', C.strCommand) - 1) < 0 THEN LEN(C.strCommand) ELSE (CHARINDEX('?', C.strCommand) - 1) END))
WHERE B.strNamespace IN (
	SELECT LEFT(strCommand, (CASE WHEN (CHARINDEX('?', strCommand) - 1) < 0 THEN LEN(strCommand) ELSE (CHARINDEX('?', strCommand) - 1) END))
	FROM [tblSMMasterMenu] D
	INNER JOIN [tblSMContactMenu] E ON E.intMasterMenuId = D.intMenuID) 
OR B.strNamespace IN (
	SELECT REPLACE(LEFT(strCommand, (CASE WHEN (CHARINDEX('?', strCommand) - 1) < 0 THEN LEN(strCommand) ELSE (CHARINDEX('?', strCommand) - 1) END)), '.view', '.search')
	FROM [tblSMMasterMenu] F
	INNER JOIN [tblSMContactMenu] G ON G.intMasterMenuId = F.intMenuID)
