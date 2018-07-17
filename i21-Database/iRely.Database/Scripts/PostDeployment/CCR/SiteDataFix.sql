GO
	PRINT N'Start fixing Site data.'
GO

	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblCCDealerSite]') AND type in (N'U'))
	begin
		update a set a.intVendorDefaultId = b.intVendorDefaultId, a.strType = 'DEALER'
		from tblCCSite a, tblCCDealerSite b
		where a.intVendorDefaultId is null and a.intDealerSiteId  = b.intDealerSiteId
	end
	
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblCCCompanyOwnedSite]') AND type in (N'U'))
	begin
		update a set a.intVendorDefaultId = b.intVendorDefaultId, a.strType = 'COMPANY OWNED'
		from tblCCSite a, tblCCCompanyOwnedSite b
		where a.intVendorDefaultId is null and a.intCompanyOwnedSiteId  = b.intCompanyOwnedSiteId
	end

	update a set a.intCompanyLocationId = b.intCompanyLocationId from tblCCSiteHeader a, tblCCVendorDefault b where a.intCompanyLocationId is null and b.intVendorDefaultId = a.intVendorDefaultId

GO
	PRINT N'End fixing Site data.'
GO