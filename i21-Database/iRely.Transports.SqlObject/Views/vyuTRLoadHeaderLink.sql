CREATE VIEW [dbo].[vyuTRLoadHeaderLink]
	AS
	SELECT
		a.*
		,strLoadNumber = isnull(b.strExternalLoadNumber, b.strLoadNumber)
		,strShipVia = c.strName
		,strSeller = d.strName
		,strDriver = e.strName
	FROM
		tblTRLoadHeader a
		left join tblLGLoad b on b.intLoadId = a.intLoadId
		left join tblEMEntity c on c.intEntityId = a.intShipViaId
		left join tblEMEntity d on d.intEntityId = a.intSellerId
		left join tblEMEntity e on e.intEntityId = a.intDriverId
