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
	, dbo.fnTFCoalesceProductCode(RC.intReportingComponentId) strProductCodes
	, dbo.fnTFCoalesceOriginState(RC.intReportingComponentId, 'Include') strIncludeOriginStates
	, dbo.fnTFCoalesceOriginState(RC.intReportingComponentId, 'Exclude') strExcludeOriginStates
	, dbo.fnTFCoalesceDestinationState(RC.intReportingComponentId, 'Include') strIncludeDestinationStates
	, dbo.fnTFCoalesceDestinationState(RC.intReportingComponentId, 'Exclude') strExcludeDestinationStates
	, dbo.fnTFCoalesceAccountStatusCode(RC.intReportingComponentId, 1) strIncludeAccountStatusCodes
	, dbo.fnTFCoalesceAccountStatusCode(RC.intReportingComponentId, 0) strExcludeAccountStatusCodes
	, dbo.fnTFCoalesceVendor(RC.intReportingComponentId, 1) strIncludeVendors
	, dbo.fnTFCoalesceVendor(RC.intReportingComponentId, 0) strExcludeVendors
	, dbo.fnTFCoalesceCustomer(RC.intReportingComponentId, 1) strIncludeCustomers
	, dbo.fnTFCoalesceCustomer(RC.intReportingComponentId, 0) strExcludeCustomers
FROM tblTFReportingComponent RC
LEFT JOIN tblTFTaxAuthority TA ON TA.intTaxAuthorityId = RC.intTaxAuthorityId
LEFT JOIN tblTFComponentType CType ON CType.intComponentTypeId = RC.intComponentTypeId