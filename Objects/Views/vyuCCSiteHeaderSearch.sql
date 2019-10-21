CREATE VIEW [dbo].[vyuCCSiteHeaderSearch]
	AS
		SELECT SiteHeader.intSiteHeaderId
			, SiteHeader.intVendorDefaultId
			, intVendorId = v.intEntityId
			, strVendorName = e.strName
			,d.intBankAccountId
			, SiteHeader.strApType
			, l.intCompanyLocationId
			, l.strLocationName
			, SiteHeader.dtmDate
			, SiteHeader.strReference
			, SiteHeader.dblGross
			, SiteHeader.dblFees
			, SiteHeader.dblNet
			, SiteHeader.strCcdReference
			, SiteHeader.strInvoice
			, SiteHeader.strPayReference
			, SiteHeader.ysnPosted
			, SiteHeader.intCMBankTransactionId
		FROM tblCCSiteHeader SiteHeader
		LEFT join tblCCVendorDefault d on d.intVendorDefaultId = SiteHeader.intVendorDefaultId
		LEFT join tblAPVendor v on v.intEntityId = d.intVendorId
		LEFT join tblEMEntity e on e.intEntityId = v.intEntityId
		LEFT JOIN tblSMCompanyLocation l ON l.intCompanyLocationId = SiteHeader.intCompanyLocationId
