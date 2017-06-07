CREATE VIEW [dbo].[vyuEMSearchVendorMin]
	AS 

	select 
		a.intEntityId,
		b.ysnTransportTerminal
		from vyuEMEntityType a
			join tblAPVendor b
				on a.intEntityId = b.[intEntityId]	

	where Vendor = 1