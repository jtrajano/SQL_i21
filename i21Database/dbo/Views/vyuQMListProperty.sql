CREATE VIEW [dbo].[vyuQMListProperty]
AS 
/****************************************************************
	Title: List Property
	Description: Returns Property that uses List
	JIRA: QC-1096
	Created By: Jonathan Valenzuela
	Date: 05/19/2023
*****************************************************************/
SELECT List.intListId
	 , ListItem.intListItemId
	 , PropertyValidity.strPropertyRangeText
FROM tblQMList AS List 
JOIN tblQMListItem AS ListItem ON ListItem.intListId = List.intListId 
JOIN tblQMProperty AS Property ON Property.intListId = List.intListId 
JOIN tblQMPropertyValidityPeriod AS PropertyValidity ON PropertyValidity.intPropertyId = Property.intPropertyId 
UNION 
SELECT List.intListId
	 , ListItem.intListItemId
	 , PropertyValidity.strPropertyRangeText
FROM tblQMList AS List 
JOIN tblQMListItem AS ListItem ON ListItem.intListId = List.intListId 
JOIN tblQMProperty AS Property ON Property.intListId = List.intListId 
JOIN tblQMProductProperty AS ProductProperty ON ProductProperty.intPropertyId = Property.intPropertyId
JOIN tblQMPropertyValidityPeriod AS PropertyValidity ON PropertyValidity.intPropertyId = Property.intPropertyId 
GO


