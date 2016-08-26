INSERT INTO [dbo].[tblSMTaxClassXref]
 ([intTaxClassId], [strTaxClass])
 select [intTaxClassId], [strTaxClass]          
 from [tblSMTaxClass] tax 
 where not exists(select [intTaxClassId] from [tblSMTaxClassXref] where [intTaxClassId] = tax.[intTaxClassId])