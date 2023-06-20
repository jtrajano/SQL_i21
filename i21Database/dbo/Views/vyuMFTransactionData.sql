CREATE VIEW [dbo].[vyuMFTransactionData]
/****************************************************************
	Title: Transaction Data
	Description: Blend Sheet Transaction Data for Search Screen
	JIRA: MFG-5190
	Created By: Jonathan Valenzuela
	Date: 06/16/2023
*****************************************************************/
AS
/* Trial Blend Sheet Approved. */
SELECT dtmApprovedDate						AS dtmDate
	 , intWorkOrderId						AS intTransactionId
	 , strWorkOrderNo						AS strTransactionNo
	 , 'Approved Blend Sheet'				AS strTransactionType
	 , CompanyLocation.strLocationName		AS strLocationName
FROM tblMFWorkOrder AS WorkOrder
JOIN tblSMCompanyLocation AS CompanyLocation ON WorkOrder.intLocationId = CompanyLocation.intCompanyLocationId
WHERE intTrialBlendSheetStatusId = 17
/* Draft Blend Sheet / Not Released. */
UNION ALL
SELECT dtmCreated							AS dtmDate
		, intWorkOrderId					AS intTransactionId
		, strWorkOrderNo					AS strTransactionNo
		, 'Draft Blend Sheet'				AS strTransactionType
		, CompanyLocation.strLocationName	AS strLocationName
FROM tblMFWorkOrder AS WorkOrder
JOIN tblSMCompanyLocation AS CompanyLocation ON WorkOrder.intLocationId = CompanyLocation.intCompanyLocationId
WHERE intStatusId	 = 2
/* Production Orders from SAP */
UNION ALL
SELECT dtmCreated							AS dtmDate
	 , intBlendRequirementId				AS intTransactionId
	 , strDemandNo							AS strTransactionNo
	 , 'Production No'						AS strTransactionType
	 , CompanyLocation.strLocationName		AS strLocationName
FROM tblMFBlendRequirement AS BlendRequirement
JOIN tblSMCompanyLocation AS CompanyLocation ON BlendRequirement.intLocationId = CompanyLocation.intCompanyLocationId
WHERE NULLIF(strReferenceNo, '') IS NOT NULL
/* Confirmed Blend Sheets */
UNION ALL
SELECT dtmReleasedDate					AS dtmDate
	 , intWorkOrderId					AS intTransactionId
	 , strWorkOrderNo					AS strTransactionNo
	 , 'SAP Blend Sheet'				AS strTransactionType
	 , CompanyLocation.strLocationName	AS strLocationName
FROM tblMFWorkOrder AS WorkOrder
JOIN tblSMCompanyLocation AS CompanyLocation ON WorkOrder.intLocationId = CompanyLocation.intCompanyLocationId
WHERE NULLIF(WorkOrder.dtmReleasedDate, '') IS NOT NULL;
GO

