CREATE VIEW vyuAPVendorToIPayables
as
WITH cte as(
select 
A.intEntityId,
A.strName VendorName,
ISNULL(strVendorId,'') COLLATE Latin1_General_CI_AS  VendorNbr ,
ISNULL(Address1.Street1, '') COLLATE Latin1_General_CI_AS  Street1,
ISNULL(Address2.Street2, '') COLLATE Latin1_General_CI_AS  Street2,
ISNULL(B.strCity,'') COLLATE Latin1_General_CI_AS  City,
ISNULL(B.strState,'') COLLATE Latin1_General_CI_AS  CountryCode,
ISNULL(B.strZipCode,'') COLLATE Latin1_General_CI_AS strZipCode ,
ISNULL(B.strCountry,'') COLLATE Latin1_General_CI_AS strCountry,
ISNULL(P.strPhone,'') COLLATE Latin1_General_CI_AS strPhone,
ISNULL(ContactDetails.strFax,'') COLLATE Latin1_General_CI_AS strFax,
ISNULL(A.strEmail,'') COLLATE Latin1_General_CI_AS  strEmail,
ISNULL(A.strTerm, '') COLLATE Latin1_General_CI_AS  strTerm,
ISNULL(EM.ysnActive, CAST (0 AS BIT) ) ysnActive,
EML.*
from vyuAPVendor A
outer apply (select top 1 strAddress, strCity,strState, strZipCode, strCountry from tblEMEntityLocation where A.intEntityId = intEntityId ) B
outer apply (select top 1 intEntityContactId from tblEMEntityToContact where intEntityId = A.intEntityId) E
left join tblEMEntityPhoneNumber P on P.intEntityId = E.intEntityContactId
OUTER APPLY(
	SELECT TOP 1 strValue strFax FROM tblEMContactDetail CD 
	WHERE intEntityId = E.intEntityContactId AND CD.intContactDetailTypeId = 3
)ContactDetails
left join tblEMEntity EM on A.intEntityId = EM.intEntityId
outer apply (select Item Street1 from  dbo.fnSplitStringWithRowId(B.strAddress, char(10))  where RowId = 1 ) Address1
outer apply (select Item Street2 from  dbo.fnSplitStringWithRowId(B.strAddress, char(10))  where RowId = 2 ) Address2
outer apply( 
	select TOP 1 
	ISNULL(strLocationName,'')  COLLATE Latin1_General_CI_AS EML_AddressType,  
	ISNULL(strAddress,'')  COLLATE Latin1_General_CI_AS EML_strAddress,
	ISNULL(strCity,'')  COLLATE Latin1_General_CI_AS EML_strCity,
	ISNULL(strState,'')  COLLATE Latin1_General_CI_AS EML_strState,
	ISNULL(strZipCode,'')  COLLATE Latin1_General_CI_AS EML_strZipCode,
	ISNULL(strCountry,'')  COLLATE Latin1_General_CI_AS EML_strCountry,
	ISNULL(Address1.Street1 ,'') COLLATE Latin1_General_CI_AS EML_Street1,
	ISNULL(Address2.Street2,'') COLLATE Latin1_General_CI_AS EML_Street2
	from  tblEMEntityLocation 
	outer apply (select Item Street1 from  dbo.fnSplitStringWithRowId(strAddress, char(10))  where RowId = 1 ) Address1
	outer apply (select Item Street2 from  dbo.fnSplitStringWithRowId(strAddress, char(10))  where RowId = 2 ) Address2
	where intEntityId = A.intEntityId
)EML

),
tag01 as(
select '01' strTag, intEntityId,
'01|C0000549|' + VendorNbr + '|' + Street1 + '|' + Street2 + '|' + City+ '|' +CountryCode+ '|' +strZipCode+ '|' +strCountry+ '|' +strPhone+ '|' +strFax+ '|' +strEmail  strData
from cte 
),
tag02 as(
select '02' strTag, intEntityId,
'02|C0000549|' + VendorNbr + '||' + strTerm   strData
from cte 
),
tag05 as(
	select '05' strTag, intEntityId,
	'05|C0000549|' + VendorNbr + '||' + CASE WHEN ysnActive = 1 THEN 'ACTV' ELSE 'IACTV' END + '|'   strData
	from cte 
),
tag06 as(
	select '06' strTag, intEntityId,
	'06|C0000549|' + VendorNbr + '|' + EML_AddressType + '||' 
	+ VendorName + '|' + EML_Street1 + '|' 
	+ EML_Street2 + '|' + EML_strCity + '|'
	+ EML_strState + '|' 
	+ EML_strZipCode + '|' + EML_strCountry   
	strData
	from cte
),
tag07 as(
	select '07' strTag, intEntityId,
	'07|C0000549|' + VendorNbr + '||CHCK'
	strData
	from cte
),

cteOrder as(

select strTag, intEntityId, strData from tag01
UNION ALL
select strTag, intEntityId, strData from tag02
UNION ALL
select strTag, intEntityId, strData from tag05
UNION ALL
select strTag, intEntityId, strData from tag06
UNION ALL
select strTag, intEntityId, strData from tag07
),

cteAllRecords AS (
	SELECT  strTag, intEntityId, strData from cteOrder
	UNION ALL
	select  '99', 999999, '99|C0000549|'+ cast( count(*) as nvarchar(10)) from cteOrder
)
select intEntityId, strTag,strData from cteAllRecords --order by intEntityId, strTag
