CREATE VIEW [dbo].[vyuAPStraussVendor]
AS
SELECT 
	isnull(b.strEntityNo,'') strEntityNo,
	isnull(b.strName,'') strName,
	isnull(d.strName,'') strContactName,
	isnull(d.strEmail,'') strEmail,
	isnull(pn.strPhone,'') strPhone,
	isnull(e.strAddress,'') strAddress,
	isnull(e.strCity,'') strCity,
	isnull(e.strState,'') strState,
	isnull(e.strZipCode,'') strZipCode,
	a.[intEntityId],
	isnull(b.strFederalTaxId,'') strFederalTaxId,
	isnull(a.strVendorAccountNum,'') strVendorAccountNum,
	isnull(i.strPaymentMethod, '') strPaymentMethod,
	isnull(g.strTerm, '') strTerm,
	isnull(f.strApprovalList, '') strApprovalList,
	isnull(a.strTaxState,'') strTaxState,
	isnull(h.strTaxCode,'') strTaxCode,
	isnull(a.strTaxNumber,'') strTaxNumber,
	isnull(d.strPhone2,'') strPhone2,
	isnull(b.strWebsite,'') strWebsite,
	isnull(e.strTimezone,'') strTimezone,
	a.ysnPymtCtrlActive as ysnActive,
	b.dtmOriginationDate,
	strVendorType = case when a.intVendorType = 1 then 'Person' when a.intVendorType = '0' then 'Company' else '' end,
	aa.strAccountId,
	ab.strCurrency,
	a.dblCreditLimit,
	a.strVendorPayToId AS strParentVendor,
	ac.strShipVia,
	ad.strLocationName AS strPayTo,
	ae.strLocationName AS strShipFrom,
	a.strFLOId, 
	a.strVendorId AS strLegacyVendorId,
	a.ysnTransportTerminal, --
	a.ysnWithholding, --
	a.ysnPymtCtrlAlwaysDiscount,
	a.ysnPymtCtrlEFTActive,
	a.ysnPymtCtrlHold,
	a.ysnOneBillPerPayment
	FROM tblAPVendor a
	join tblEMEntity b
		on b.intEntityId = a.[intEntityId]
	join tblEMEntityType etype
		on etype.intEntityId = b.intEntityId and strType = 'Vendor'
	left join [tblEMEntityToContact] c
		on c.intEntityId = b.intEntityId
			and c.ysnDefaultContact = 1
	left join tblEMEntity d
		on c.intEntityContactId = d.intEntityId
	join [tblEMEntityLocation] e
		on e.intEntityId = a.[intEntityId]
			and e.ysnDefaultLocation = 1
	left join tblSMApprovalList f
		on f.intApprovalListId = a.intApprovalListId
	left join tblSMTerm g
		on g.intTermID = a.intTermsId --WILL GET THE DEFAULT TERM VALUE OF THE VENDOR
	left join tblSMTerm g2
		on g2.intTermID = e.intTermsId --WILL GET THE DEFAULT TERM VALUE OF THE LOCATION
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
		on ac.[intEntityId] = e.intShipViaId
	left join tblEMEntityLocation ad
		on ad.intEntityLocationId = a.intBillToId
	left join tblEMEntityLocation ae
		on ae.intEntityLocationId = a.intShipFromId
	left join tblEMEntityPhoneNumber pn
		on pn.intEntityId = d.intEntityId
	LEFT JOIN tblEMEntityClass EC ON EC.intEntityClassId = b.intEntityClassId