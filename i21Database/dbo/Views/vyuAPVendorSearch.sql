CREATE VIEW [dbo].[vyuAPVendorSearch]
	AS 

SELECT 
	a.intEntityVendorId,
	b.intEntityId,
	a.strVendorAccountNum,
	i.strPaymentMethod,
	g.strTerm,
	f.strApprovalList,
	a.strTaxState,
	h.strTaxCode,
	a.strTaxNumber,
	b.str1099Name,
	b.str1099Form,
	b.str1099Type,
	b.strFederalTaxId,
	d.strEmail,
	d.strPhone2,
	d.strMobile,
	d.strTimezone,
	b.strWebsite,
	d.strPhone,
	b.strEntityNo,
	e.strAddress,
	e.strCity,
	b.strName,
	e.strZipCode,
	e.strState
	
	FROM tblAPVendor a
	join tblEntity b
		on b.intEntityId = a.intEntityVendorId
	join tblEntityToContact c
		on c.intEntityId = b.intEntityId
			and c.ysnDefaultContact = 1
	join tblEntity d
		on c.intEntityContactId = d.intEntityId
	join tblEntityLocation e
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
