CREATE PROCEDURE [dbo].[uspMFGetEntitySplitDetailForReport]
	@intSalesOrderId INT = NULL
AS

select e.strEntityNo,e.strName,sd.dblSplitPercent
from tblEMEntitySplit s join tblEMEntitySplitDetail sd on s.intSplitId=sd.intSplitId
join tblEMEntity e on sd.intEntityId=e.intEntityId
Join tblSOSalesOrder so on so.intSplitId=s.intSplitId
Where so.intSalesOrderId=@intSalesOrderId


