CREATE VIEW [dbo].[vyuCTItemXrefSetup]
	AS
	select  
		intItemXrefId = v.intItemVendorXrefId  
		,strItemXrefProduct = v.strVendorProduct  
		,v.strProductDescription  
		,intCompanyLocationId = il.intLocationId  
		,intEntityId = v.intVendorId  
		,intContractTypeId = 1  
		,i.intItemId  
		,i.strItemNo  
		,i.strDescription  
		,i.intCommodityId  
	from
		tblICItemVendorXref v  
		join tblICItem i on i.intItemId = v.intItemId  
		join tblICItemLocation il on il.intItemId = i.intItemId  
  
	union all  
  
	select  
		intItemXrefId = c.intItemCustomerXrefId  
		,strItemXrefProduct = c.strCustomerProduct  
		,c.strProductDescription  
		,intCompanyLocationId = il.intLocationId  
		,intEntityId = c.intCustomerId  
		,intContractTypeId = 2  
		,i.intItemId  
		,i.strItemNo  
		,i.strDescription  
		,i.intCommodityId  
	from
		tblICItemCustomerXref c  
		join tblICItem i on i.intItemId = c.intItemId  
		join tblICItemLocation il on il.intItemId = i.intItemId  
