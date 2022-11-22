CREATE VIEW [dbo].[vyuQMSearchStorageLocation]
AS
SELECT intStorageLocationId		= SL.intStorageLocationId
     , strName					= SL.strName
	 , strDescription			= SL.strDescription
     , intLocationId			= SL.intLocationId
	 , strLocationName			= CL.strLocationName
	 , intSubLocationId			= SL.intSubLocationId
	 , strSubLocationName		= CLSL.strSubLocationName
FROM tblICStorageLocation SL
LEFT JOIN tblSMCompanyLocation CL ON SL.intLocationId = CL.intCompanyLocationId 
LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON SL.intSubLocationId = CLSL.intCompanyLocationSubLocationId