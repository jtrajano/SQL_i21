CREATE VIEW vyuMFGetAdditionalBasis
AS
SELECT AB.intAdditionalBasisId
	,AB.dtmAdditionalBasisDate
	,AB.strComment
	,CL.strLocationName
	,AB.intConcurrencyId
FROM tblMFAdditionalBasis AB
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = AB.intLocationId
