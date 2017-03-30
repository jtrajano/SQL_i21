CREATE VIEW [dbo].[vyuEMSearchEntityEmployee]
AS

SELECT 
		a.intEntityId,   
		a.strEntityNo, 
		a.strName,  
		strPhone = j.strPhone,   
		e.strAddress,  
		e.strCity,  
		e.strState,  
		e.strZipCode,
		c.ysnActive,
		a.strTitle,
		c.strPayPeriod,
		strDepartment = dbo.fnEMGetEmployeeDepartment(a.intEntityId),
		strSupervisor = dbo.fnEMGetEmployeeSupervisor(a.intEntityId),
		c.strType,
		c.intRank,
		c.dtmReviewDate,
		c.dtmNextReview,
		c.dtmBirthDate,
		c.dtmOriginalDateHired,
		c.dtmDateHired,
		c.strMaritalStatus,
		c.strSpouse,
		c.strGender,
		strWorkCompCode = h.strWCCode,
		c.strEthnicity,
		strSocialSecurity = case when c.strSocialSecurity is null or c.strSocialSecurity = '' then '' else 'xxx-xx-' + substring(c.strSocialSecurity, len(c.strSocialSecurity) - 3, 4) end,
		c.strTerminatedReason,
		c.ysn1099Employee,
		strTimeEntryPassword = CASE WHEN c.strTimeEntryPassword IS NULL or c.strTimeEntryPassword = '' then '' else '****************' end,
		c.strEmergencyContact,
		c.strEmergencyRelation,
		c.strEmergencyPhone,
		c.strEmergencyPhone2

	FROM 		
			tblEMEntity a
		join [tblEMEntityType] b
			on b.intEntityId = a.intEntityId and b.strType = 'Employee'
		join tblPREmployee c
			on c.[intEntityId] = a.intEntityId
		left join [tblEMEntityLocation] e  
			on ( ysnDefaultLocation = 1 )AND a.intEntityId = e.intEntityId
		left join [tblEMEntityToContact] f  
			on f.intEntityId = a.intEntityId and f.ysnDefaultContact = 1  
		left join tblEMEntity g  
			on f.intEntityContactId = g.intEntityId  
		left join tblPRWorkersCompensation h
			on h.intWorkersCompensationId = c.intWorkersCompensationId
		left join tblEMEntityPhoneNumber j
			on g.intEntityId = j.intEntityId
