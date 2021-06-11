﻿CREATE VIEW [dbo].[vyuARCustomerGroup]
	AS 

	select a.intCustomerGroupId, 
		a.strGroupName,
		a.strDescription,
		c.strName,
		b.ysnSpecialPricing,
		b.ysnContract,
		b.ysnBuyback,
		b.ysnQuote,
		b.ysnVolumeDiscount,
		b.ysnAutomatedQuoting
	from tblARCustomerGroup a
		join tblARCustomerGroupDetail  b
			on a.intCustomerGroupId = b.intCustomerGroupId
		join tblEMEntity c
			on b.intEntityId = c.intEntityId
