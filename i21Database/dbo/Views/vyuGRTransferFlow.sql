CREATE VIEW [dbo].[vyuGRTransferFlow]
	AS 

with StartingLine as (
		select 
			FromStorage.intCustomerStorageId as intSourceCustomerStorageId
			,FromStorageType.ysnDPOwnedType as ysnSourceDPOwnedType
			,ToStorage.intCustomerStorageId as intToCustomerStorageId
			, ToStorageType.ysnDPOwnedType as ysnToDPOwnedType
			, 1 as Level		
			,ToStorage.intCustomerStorageId as intParentStorageId
			,cast(
					(
						( cast(
										case when FromStorageType.ysnDPOwnedType = 1 then 'DP' else 'OS' end 
										as nvarchar
									)
								+ 
								cast(
										case when ToStorageType.ysnDPOwnedType = 1 then ',DP' else ',OS' end 
										as nvarchar
									)
						)
					)
					as nvarchar
				) as strStorageType
			,TransferStorageReference.intTransferStorageId
		from tblGRTransferStorageReference TransferStorageReference
		join tblGRCustomerStorage ToStorage
			on TransferStorageReference.intToCustomerStorageId = ToStorage.intCustomerStorageId	
		join tblGRStorageType ToStorageType
			on ToStorageType.intStorageScheduleTypeId = ToStorage.intStorageTypeId
		join tblGRCustomerStorage FromStorage
			on TransferStorageReference.intSourceCustomerStorageId = FromStorage.intCustomerStorageId
		join tblGRStorageType FromStorageType
			on FromStorageType.intStorageScheduleTypeId = FromStorage.intStorageTypeId

		union all 


		select 
			FromStorage.intCustomerStorageId
			,FromStorageType.ysnDPOwnedType
			,ToStorage.intCustomerStorageId
			, ToStorageType.ysnDPOwnedType
			, (StartingLine.Level + 1) as Level
			, StartingLine.intParentStorageId
			,cast( case when FromStorageType.ysnDPOwnedType = 1 then ',DP' else ',OS' end  as nvarchar )
			,TransferStorageReference.intTransferStorageId
		from tblGRTransferStorageReference TransferStorageReference
		join StartingLine 
			on TransferStorageReference.intToCustomerStorageId = StartingLine.intSourceCustomerStorageId
		join tblGRCustomerStorage ToStorage
			on TransferStorageReference.intToCustomerStorageId = ToStorage.intCustomerStorageId	
		join tblGRStorageType ToStorageType
			on ToStorageType.intStorageScheduleTypeId = ToStorage.intStorageTypeId
		join tblGRCustomerStorage FromStorage
			on TransferStorageReference.intSourceCustomerStorageId = FromStorage.intCustomerStorageId
		join tblGRStorageType FromStorageType
			on FromStorageType.intStorageScheduleTypeId = FromStorage.intStorageTypeId
	)
	select * from StartingLine