CREATE VIEW [dbo].[vyuEMEntityVendorApproval]
	AS 

	select 
		za.intEntityId  
	from tblEMEntityRequireApprovalFor za 
		join tblSMScreen zb 
			on za.intScreenId  = zb.intScreenId 
				and strScreenName ='Voucher' 
