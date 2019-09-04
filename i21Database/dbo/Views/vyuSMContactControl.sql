CREATE VIEW [dbo].[vyuSMContactControl]
AS 
SELECT intControlId
,cl.intScreenId
,strControlId
,strControlName
,ISNULL(sc.strGroupName,mm.strCategory) COLLATE Latin1_General_CI_AS AS strGroupName 
,CASE WHEN ISNULL(cl.strContainer, 0) <> 0 THEN cl.strContainer ELSE sc.strScreenName END AS strContainer
,strControlType
,cl.intConcurrencyId
,CASE WHEN ISNULL(mm.strMenuName,'') <> '' THEN REPLACE(mm.strMenuName, '(Portal)', '') ELSE sc.strScreenName END AS strScreenName
FROM tblSMControl cl
INNER JOIN tblSMScreen sc ON cl.intScreenId = sc.intScreenId
LEFT JOIN tblSMMasterMenu mm ON sc.strNamespace = LEFT(mm.strCommand, (CASE WHEN (CHARINDEX('?', mm.strCommand) - 1) < 0 THEN LEN(mm.strCommand) ELSE (CHARINDEX('?', mm.strCommand) - 1) END))
--LEFT JOIN tblSMContactMenu cm ON mm.intMenuID = cm.intMasterMenuId
where sc.strNamespace in (
	select 	LEFT(strCommand, (		CASE WHEN (CHARINDEX('?', strCommand) - 1) < 0 		THEN LEN(strCommand) 		ELSE (CHARINDEX('?', strCommand) - 1) 		END 	))
	from tblSMMasterMenu a
	inner join tblSMContactMenu b on b.intMasterMenuId = a.intMenuID
)
OR
 sc.strNamespace in (
	SELECT REPLACE(	LEFT(strCommand, (		CASE WHEN (CHARINDEX('?', strCommand) - 1) < 0 		THEN LEN(strCommand) 		ELSE (CHARINDEX('?', strCommand) - 1) 		END 	)), '.view.', '.search.')
	from tblSMMasterMenu a
	inner join tblSMContactMenu b on b.intMasterMenuId = a.intMenuID
)