CREATE PROCEDURE [dbo].[uspMFGetPickList]
	@intPickListId int
AS
Select pl.intPickListId,pl.strPickListNo,pl.strWorkOrderNo,pl.intKitStatusId,pl.intAssignedToId,pl.intLocationId,cl.strLocationName,pl.intConcurrencyId
From tblMFPickList pl Join tblSMCompanyLocation cl on pl.intLocationId=cl.intCompanyLocationId
Where pl.intPickListId=@intPickListId
