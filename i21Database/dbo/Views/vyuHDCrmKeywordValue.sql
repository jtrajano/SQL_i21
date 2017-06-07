CREATE VIEW [dbo].[vyuHDCrmKeywordValue]
	AS
		select
			intId = ROW_NUMBER() over (order by tblEMEntity.intEntityId)
			,intEntityId = tblEMEntity.intEntityId
			,strSalespersonName = tblEMEntity.strName
			,strCompanyName = tblSMCompanySetup.strCompanyName
			,strEnterpriseSoftwareSimplified = 'Enterprise Software Simplified'
			
			,intMobileNumberContactEntityId = mob.intEntityId
			,strMobileNumber = tblEMEntityMobileNumber.strPhone
			,strMobileNumberContact = mob.strPhone
			
			,intPhoneNumberContactEntityId = pho.intEntityId
			,strPhoneNumber = tblEMEntityPhoneNumber.strPhone
			,strPhoneNumberContact = pho.strPhone
			
			,intEmailContactEntityId = enmail.intEntityId
			,strEmail = tblEMEntity.strEmail
			,strEmailContact = enmail.strEmail

			,blbCompanyLogo = tblSMCompanySetup.imgCompanyLogo

			,strCompanyAddress = tblSMCompanySetup.strAddress + '<br>' + tblSMCompanySetup.strCity + ', ' + tblSMCompanySetup.strState + ' ' + tblSMCompanySetup.strZip
			
			,ysnActive = (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end)
		from
			tblEMEntity
			left outer join tblARSalesperson on tblARSalesperson.[intEntityId] = tblEMEntity.intEntityId
			
			left outer join tblSMCompanySetup on 1 = 1

			left outer join tblEMEntityMobileNumber on tblEMEntityMobileNumber.intEntityId = tblEMEntity.intEntityId
			left outer join tblEMEntityToContact on tblEMEntityToContact.intEntityId = tblEMEntity.intEntityId
			left outer join tblEMEntityMobileNumber  mob on mob.intEntityId = tblEMEntityToContact.intEntityContactId

			left outer join tblEMEntityPhoneNumber on tblEMEntityPhoneNumber.intEntityId = tblEMEntity.intEntityId
			left outer join tblEMEntityPhoneNumber  pho on pho.intEntityId = tblEMEntityToContact.intEntityContactId
			
			left outer join tblEMEntity enmail on enmail.intEntityId = tblEMEntityToContact.intEntityContactId
