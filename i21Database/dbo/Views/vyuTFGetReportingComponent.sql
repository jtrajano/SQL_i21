CREATE VIEW [dbo].[vyuTFGetReportingComponent]
	AS
	
SELECT RC.intReportingComponentId
	, RC.intTaxAuthorityId
	, TA.strTaxAuthorityCode
	, RC.strFormCode
	, RC.strFormName
	, RC.strScheduleCode
	, RC.strScheduleName
	, RC.strType
	, RC.strNote
	, RC.strTransactionType
	, CType.intComponentTypeId
	, CType.strComponentType
	, RC.intSort
	, RC.strStoredProcedure
	, RC.ysnIncludeSalesFreightOnly
	, dbo.fnTFCoalesceProductCode(RC.intReportingComponentId) COLLATE Latin1_General_CI_AS strProductCodes
	, dbo.fnTFCoalesceOriginState(RC.intReportingComponentId, 'Include') COLLATE Latin1_General_CI_AS strIncludeOriginStates
	, dbo.fnTFCoalesceOriginState(RC.intReportingComponentId, 'Exclude') COLLATE Latin1_General_CI_AS strExcludeOriginStates
	, dbo.fnTFCoalesceDestinationState(RC.intReportingComponentId, 'Include') COLLATE Latin1_General_CI_AS strIncludeDestinationStates
	, dbo.fnTFCoalesceDestinationState(RC.intReportingComponentId, 'Exclude') COLLATE Latin1_General_CI_AS strExcludeDestinationStates
	, dbo.fnTFCoalesceAccountStatusCode(RC.intReportingComponentId, 1) COLLATE Latin1_General_CI_AS strIncludeAccountStatusCodes
	, dbo.fnTFCoalesceAccountStatusCode(RC.intReportingComponentId, 0) COLLATE Latin1_General_CI_AS strExcludeAccountStatusCodes
	, dbo.fnTFCoalesceVendor(RC.intReportingComponentId, 1) COLLATE Latin1_General_CI_AS strIncludeVendors
	, dbo.fnTFCoalesceVendor(RC.intReportingComponentId, 0) COLLATE Latin1_General_CI_AS strExcludeVendors
	, dbo.fnTFCoalesceCustomer(RC.intReportingComponentId, 1) COLLATE Latin1_General_CI_AS strIncludeCustomers
	, dbo.fnTFCoalesceCustomer(RC.intReportingComponentId, 0) COLLATE Latin1_General_CI_AS strExcludeCustomers
	, dbo.fnTFCoalesceTransactionSource(RC.intReportingComponentId, 1) COLLATE Latin1_General_CI_AS strIncludeTransactionSource
	, dbo.fnTFCoalesceTransactionSource(RC.intReportingComponentId, 0) COLLATE Latin1_General_CI_AS strExcludeTransactionSource
	, dbo.fnTFCoalesceCardFuelingSite(RC.intReportingComponentId, 1) COLLATE Latin1_General_CI_AS strIncludeCardFuelingSites
	, dbo.fnTFCoalesceCardFuelingSite(RC.intReportingComponentId, 0) COLLATE Latin1_General_CI_AS strExcludeCardFuelingSites
FROM tblTFReportingComponent RC
LEFT JOIN tblTFTaxAuthority TA ON TA.intTaxAuthorityId = RC.intTaxAuthorityId
LEFT JOIN tblTFComponentType CType ON CType.intComponentTypeId = RC.intComponentTypeId