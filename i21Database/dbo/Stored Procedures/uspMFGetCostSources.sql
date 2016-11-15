CREATE PROCEDURE [dbo].[uspMFGetCostSources]
	@intItemId int,
	@intEntityId int
AS

Declare @tblCostSource AS TABLE
(
	intCostSourceId int,
	strName nvarchar(50)
)

Insert Into @tblCostSource
Values(1,'Item')

If Exists (Select 1 From vyuCTContractDetailView Where intItemId=@intItemId AND intEntityId=@intEntityId AND strContractType='Sale' AND strContractStatus='Open')
Insert Into @tblCostSource
Values(2,'Sales Contract')

If Exists (Select 1 From vyuGRGetStorageTransferTicket Where intItemId=@intItemId AND intEntityId=@intEntityId)
Insert Into @tblCostSource
Values(3,'Customer Storage')

Select * from @tblCostSource