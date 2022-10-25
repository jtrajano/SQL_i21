CREATE VIEW [dbo].[vyuQMSearchCity]
AS
SELECT intCityId		= C.intCityId
     , strCity			= C.strCity
	 , intCountryId		= CR.intCountryID
     , strState			= C.strState
	 , ysnPort			= C.ysnPort

FROM tblSMCity C
LEFT JOIN tblSMCountry CR ON C.intCountryId = CR.intCountryID 