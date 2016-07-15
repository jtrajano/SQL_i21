CREATE VIEW [dbo].[vyuEMSearchVendorMin]
	AS 

	select 
		a.intEntityId,
		b.ysnTransportTerminal
		from vyuEMEntityType a
			join tblAPVendor b
				on a.intEntityId = b.intEntityVendorId	

	where Vendor = 1