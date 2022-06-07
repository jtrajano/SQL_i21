CREATE VIEW [dbo].[vyuLGDispatchSupplier]
AS
SELECT 
	intKeyColumn = ROW_NUMBER() OVER (ORDER BY strEntityName ASC)
	,SUP.* 
FROM
   (SELECT 
		intEntityId = CL.intCompanyLocationId
		,strEntityName = CL.strLocationName
		,strLocationType = 'Bulk Location' COLLATE Latin1_General_CI_AS
	FROM tblSMCompanyLocation CL 
	UNION ALL
	SELECT 
		intEntityId = E.intEntityId
		,strEntityName = E.strName
		,strLocationType = 'Supplier Terminal' COLLATE Latin1_General_CI_AS
	FROM tblEMEntity E 
	INNER JOIN tblAPVendor V ON V.intEntityId = E.intEntityId AND V.ysnTransportTerminal = 1
	) SUP

GO