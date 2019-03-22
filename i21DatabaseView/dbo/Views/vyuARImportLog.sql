CREATE VIEW [dbo].[vyuARImportLog]
AS
SELECT IL.*
	 , EM.strName
	 , ICI.strItemNo
	 , strCompanyLocation  = CL.strLocationName
 FROM tblARImportLog IL
	LEFT JOIN tblEMEntity EM ON IL.intEntityId = EM.intEntityId
	LEFT JOIN tblICItem ICI ON IL.intItemId = ICI.intItemId
	LEFT JOIN tblSMCompanyLocation CL ON IL.intCompanyLocationId = CL.intCompanyLocationId