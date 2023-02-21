CREATE VIEW [dbo].[vyuQMSearchStorageLocation]
AS
SELECT intCompanyLocationId					= CL.intCompanyLocationId 
	 , strLocationName						= CL.strLocationName
	 , intCompanyLocationSubLocationId		= CLSL.intCompanyLocationSubLocationId
	 , strSubLocationName					= CLSL.strSubLocationName
FROM tblSMCompanyLocation CL
LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CL.intCompanyLocationId = CLSL.intCompanyLocationId
WHERE intCompanyLocationSubLocationId IS NOT NULL
