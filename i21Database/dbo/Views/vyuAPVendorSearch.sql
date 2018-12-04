﻿CREATE VIEW [dbo].[vyuAPVendorSearch]
	AS 

SELECT 
	a.intEntityVendorId,
	b.intEntityId,
	isnull(a.strVendorAccountNum,'') strVendorAccountNum,
	isnull(i.strPaymentMethod, '') strPaymentMethod,
	isnull(g.strTerm, '') strTerm,
	isnull(f.strApprovalList, '') strApprovalList,
	isnull(a.strTaxState,'') strTaxState,
	isnull(h.strTaxCode,'') strTaxCode,
	isnull(a.strTaxNumber,'') strTaxNumber,
	isnull(b.str1099Name,'') str1099Name,
	isnull(b.str1099Form,'') str1099Form,
	isnull(b.str1099Type,'') str1099Type,
	isnull(b.strFederalTaxId,'') strFederalTaxId,
	isnull(d.strEmail,'') strEmail,
	isnull(d.strPhone2,'') strPhone2,
	isnull(d.strMobile,'') strMobile,
	isnull(e.strTimezone,'') strTimezone,
	isnull(b.strWebsite,'') strWebsite,
	isnull(d.strPhone,'') strPhone,
	isnull(d.strName,'') strContactName,
	isnull(b.strEntityNo,'') strEntityNo,
	isnull(e.strAddress,'') strAddress,
	isnull(e.strCity,'') strCity,
	isnull(b.strName,'') strName,
	isnull(e.strZipCode,'') strZipCode,
	isnull(e.strState,'') strState,
	a.ysnPymtCtrlActive as ysnActive
	---
	,
	a.intVendorType, --get the actual text
	strVendorType = case when a.intVendorType = 1 then 'Person' when a.intVendorType = '0' then 'Company' else '' end COLLATE Latin1_General_CI_AS,
	a.intGLAccountExpenseId, -- get the actual text
	aa.strAccountId,
	a.intCurrencyId, -- get the actual text,
	ab.strCurrency,
	a.dblCreditLimit,
	a.strVendorPayToId, --get the name of this entity, do a sub query here instead
	strVendorPayToEntityName = (select top 1 strName from tblEMEntity where strEntityNo = a.strVendorPayToId and strEntityNo <> ''),
	e.intShipViaId, --get the location for this one
	ac.strShipVia,
	a.intBillToId, --get the name
	strBillTo = ad.strLocationName,
	a.intShipFromId, --get the name
	strShipFrom = ae.strLocationName,
	a.ysnTransportTerminal, --
	a.ysnWithholding, --
	a.strFLOId, 
	a.strVendorId,
	a.ysnPymtCtrlAlwaysDiscount,
	a.ysnPymtCtrlEFTActive,
	a.ysnPymtCtrlHold,
	a.ysnOneBillPerPayment
	---
	FROM tblAPVendor a
	join tblEMEntity b
		on b.intEntityId = a.intEntityVendorId
	join tblEMEntityType etype
		on etype.intEntityId = b.intEntityId and strType = 'Vendor'
	join [tblEMEntityToContact] c
		on c.intEntityId = b.intEntityId
			and c.ysnDefaultContact = 1
	join tblEMEntity d
		on c.intEntityContactId = d.intEntityId
	join [tblEMEntityLocation] e
		on e.intEntityId = a.intEntityVendorId
			and e.ysnDefaultLocation = 1
	left join tblSMApprovalList f
		on f.intApprovalListId = a.intApprovalListId
	left join tblSMTerm g
		on g.intTermID = e.intTermsId
	left join tblSMTaxCode h
		on h.intTaxCodeId = a.intTaxCodeId
	left join tblSMPaymentMethod i
		on i.intPaymentMethodID = a.intPaymentMethodId
	--
	left join tblGLAccount aa
		on aa.intAccountId = a.intGLAccountExpenseId
	left join tblSMCurrency ab
		on ab.intCurrencyID = a.intCurrencyId
	left join tblSMShipVia ac
		on ac.intEntityShipViaId = e.intShipViaId
	left join tblEMEntityLocation ad
		on ad.intEntityLocationId = a.intBillToId
	left join tblEMEntityLocation ae
		on ae.intEntityLocationId = a.intShipFromId

	

