CREATE VIEW [dbo].[vyuARCompanyReportHeader]
AS
SELECT
	 CRH.intCompanyReportHeaderId
	,CRH.intCompanyLocationId
	,CL.strLocationName
	,CL.intCompanySegment
	,GLAS.strCode
	,GLAS.strDescription
	,GLCD.strCompanyName
	,GLCD.strFEIN
	,GLCD.strAddress
FROM tblARCompanyReportHeader CRH
INNER JOIN tblSMCompanyLocation CL ON CRH.intCompanyLocationId = CL.intCompanyLocationId
LEFT JOIN tblGLAccountSegment GLAS ON CL.intCompanySegment = GLAS.intAccountSegmentId
LEFT JOIN tblGLCompanyDetails GLCD ON GLAS.intAccountSegmentId = GLCD.intAccountSegmentId