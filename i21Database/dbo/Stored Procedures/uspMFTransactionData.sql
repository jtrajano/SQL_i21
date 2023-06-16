CREATE PROCEDURE uspMFTransactionData
(
	@dtmDateFrom	DATETIME = NULL
  , @dtmDateTo		DATETIME = NULL 
)
AS
/****************************************************************
	Title: Transaction Data Count
	Description: Retrieve Transaction Data Count for Approved Trial Blend Sheet & Drafted Blend Sheet
	JIRA: MFG-5190
	Created By: Jonathan Valenzuela
	Date: 06/16/2023
*****************************************************************/
BEGIN
	DECLARE @plainData TABLE
	(
		dtmDate				DATETIME
	  , intColumnValue		INT
	  , strTransactionType	NVARCHAR(MAX)
	  , strLocationName		NVARCHAR(MAX)
	)

	INSERT INTO @plainData
	/* Trial Blend Sheet Approved. */
	SELECT dtmApprovedDate						AS dtmDate
			, intWorkOrderId					AS intColumnValue
			, 'Approved Blend Sheet'			AS strTransactionType
			, CompanyLocation.strLocationName	AS strLocationName
	FROM tblMFWorkOrder AS WorkOrder
	JOIN tblSMCompanyLocation AS CompanyLocation ON WorkOrder.intLocationId = CompanyLocation.intCompanyLocationId
	WHERE intTrialBlendSheetStatusId = 17
	/* Draft Blend Sheet / Not Released. */
	UNION ALL
	SELECT dtmCreated						AS dtmDate
		 , intWorkOrderId					AS intColumnValue
		 , 'Draft Blend Sheet'				AS strTransactionType
		 , CompanyLocation.strLocationName	AS strLocationName
	FROM tblMFWorkOrder AS WorkOrder
	JOIN tblSMCompanyLocation AS CompanyLocation ON WorkOrder.intLocationId = CompanyLocation.intCompanyLocationId
	WHERE intStatusId	 = 2
	/* Production Orders from SAP */
	UNION ALL
	SELECT dtmCreated						AS dtmDate
		 , intBlendRequirementId			AS intColumnValue
		 , 'Production No'					AS strTransactionType
		 , CompanyLocation.strLocationName	AS strLocationName
	FROM tblMFBlendRequirement AS BlendRequirement
	JOIN tblSMCompanyLocation AS CompanyLocation ON BlendRequirement.intLocationId = CompanyLocation.intCompanyLocationId
	WHERE NULLIF(strReferenceNo, '') IS NOT NULL
	/* Confirmed Blend Sheets */
	UNION ALL
	SELECT dtmReleasedDate					AS dtmDate
	     , intBlendRequirementId			AS intColumnValue
		 , 'SAP Blend Sheet'				AS strTransactionType
		 , CompanyLocation.strLocationName	AS strLocationName
	FROM tblMFWorkOrder AS WorkOrder
	JOIN tblSMCompanyLocation AS CompanyLocation ON WorkOrder.intLocationId = CompanyLocation.intCompanyLocationId
	WHERE NULLIF(WorkOrder.dtmReleasedDate, '') IS NOT NULL;

	WITH CTE
	AS 
	(	SELECT *
		FROM
		(
			SELECT *
			FROM @plainData
			WHERE (
						/* filter from @dtmDateFrom up to this date. */
						((@dtmDateFrom IS NOT NULL AND @dtmDateTo IS NULL) AND dbo.fnRemoveTimeOnDate(dtmDate) >= @dtmDateFrom)
						/* filter from todays date to @dtmDateTo. */
					OR ((@dtmDateTo IS NOT NULL AND @dtmDateFrom IS NULL) AND dbo.fnRemoveTimeOnDate(dtmDate) <= dbo.fnRemoveTimeOnDate(@dtmDateTo))
						/* filter from @dtmDateFrom date to @dtmDateFrom. */
					OR ((@dtmDateFrom IS NOT NULL AND @dtmDateTo IS NOT NULL) AND dbo.fnRemoveTimeOnDate(dtmDate) BETWEEN dbo.fnRemoveTimeOnDate(@dtmDateFrom) AND dbo.fnRemoveTimeOnDate(@dtmDateTo))
						/* return all if both parameter null / empty. */
					OR ((@dtmDateFrom IS NULL AND @dtmDateTo IS NULL))
					)	
		) AS D
		PIVOT
		(
			COUNT(intColumnValue) FOR strTransactionType in ([Approved Blend Sheet], [Draft Blend Sheet], [Production No], [SAP Blend Sheet])
		) AS piv
	)
	SELECT strLocationName					AS [Location]
		 , SUM(CTE.[Approved Blend Sheet])	AS [Approved Blend Sheet]
		 , SUM(CTE.[Draft Blend Sheet])		AS [Draft Blend Sheet]
		 , SUM(CTE.[Production No])			AS [SAP Production No]
		 , SUM(CTE.[SAP Blend Sheet])		AS [SAP Blend Sheet (Confirmed/Released)]
		 , CASE WHEN (@dtmDateTo IS NOT NULL AND @dtmDateFrom IS NOT NULL) THEN FORMAT(@dtmDateFrom, 'dd MMM yy') + ' To ' + FORMAT(@dtmDateTo, 'dd MMM yy')
				ELSE  ''
		   END AS [Transaction Period]
	FROM CTE
	GROUP BY strLocationName

END
