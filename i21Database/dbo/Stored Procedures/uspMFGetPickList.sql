﻿CREATE PROCEDURE [dbo].[uspMFGetPickList]
	@intPickListId int
AS
Select pl.intPickListId
	 , pl.strPickListNo
	 , pl.strWorkOrderNo
	 , pl.intKitStatusId
	 , pl.intAssignedToId
	 , pl.intLocationId
	 , cl.strLocationName
	 , pl.intConcurrencyId
	 , pl.dblBatchSize
	 , u.strUserName AS strAssignedTo
	 , pl.dtmCreated
	 , pl.dtmLastModified
	 , pl.intCreatedUserId
	 , pl.intLastModifiedUserId
	 , pl.intSalesOrderId
	 , 0.00			AS dblItemRequiredQty
From tblMFPickList pl Join tblSMCompanyLocation cl on pl.intLocationId=cl.intCompanyLocationId
Left Join tblSMUserSecurity u on pl.intAssignedToId=u.intEntityId
Where pl.intPickListId=@intPickListId