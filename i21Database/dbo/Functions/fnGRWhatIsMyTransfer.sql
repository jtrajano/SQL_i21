CREATE FUNCTION [dbo].[fnGRWhatIsMyTransfer]
(
	@TransferStorageTicket nvarchar(100),
	@TransferStorageId int
)
returns @TransferData table (
	KindOfTransfer nvarchar(500)
	, TransferStorageTicket nvarchar(100)
	, TransferStorageId int
	, TransferUnit decimal(24, 10)
	, DP_TO_OS bit
	, OS_TO_DP bit	
)
as 

begin 

declare @SourceTransfer nvarchar(5)
declare @DestinationTransfer nvarchar(5)
declare @TransferUnits decimal(24,10) 
	, @strTransferStorageTicket nvarchar(100)
	, @intTransferStorageId int

select @TransferUnits = TransferStorage.dblTotalUnits
	,@strTransferStorageTicket = TransferStorage.strTransferStorageTicket
	,@intTransferStorageId = TransferStorage.intTransferStorageId
	,@SourceTransfer = case when SourceStorageType.is_dp = 1 and SourceStorageType.is_customer = 0 then 'DP' 
		when SourceStorageType.is_dp = 0 and SourceStorageType.is_customer = 1 then 'OS'
	else 'N/A' end
	,@DestinationTransfer = case when DestinationStorageType.is_dp = 1 and DestinationStorageType.is_customer = 0 then 'DP' 
		when DestinationStorageType.is_dp = 0 and DestinationStorageType.is_customer = 1 then 'OS'
	else 'N/A' end
	
	
	from tblGRTransferStorage TransferStorage
	join tblGRTransferStorageReference Reference
		on TransferStorage.intTransferStorageId = Reference.intTransferStorageId
	cross apply(select 
						is_dp = ysnDPOwnedType
						, is_customer = case when strOwnedPhysicalStock = 'Customer' then 1 else 0 end  
					from tblGRCustomerStorage CustomerStorage
						join tblGRStorageType StorageType
							on StorageType.intStorageScheduleTypeId = CustomerStorage.intStorageTypeId
					where CustomerStorage.intCustomerStorageId = Reference.intSourceCustomerStorageId
		)SourceStorageType	
	cross apply(select 
					is_dp = ysnDPOwnedType
					, is_customer = case when strOwnedPhysicalStock = 'Customer' then 1 else 0 end  
				from tblGRCustomerStorage CustomerStorage
					join tblGRStorageType StorageType
						on StorageType.intStorageScheduleTypeId = CustomerStorage.intStorageTypeId
				where CustomerStorage.intCustomerStorageId = Reference.intToCustomerStorageId
	)DestinationStorageType
	where (@TransferStorageTicket is null or TransferStorage.strTransferStorageTicket = @TransferStorageTicket)
		and ( @TransferStorageId is null or TransferStorage.intTransferStorageId = @TransferStorageId) 








	insert into @TransferData(KindOfTransfer, TransferUnit, DP_TO_OS, OS_TO_DP, TransferStorageTicket, TransferStorageId)
	select 'Transfer ' + @SourceTransfer + ' to ' + @DestinationTransfer
		, @TransferUnits
		, case when @SourceTransfer = 'DP' and @DestinationTransfer = 'OS' then 1 else 0 end
		, case when @SourceTransfer = 'OS' and @DestinationTransfer = 'DP' then 1 else 0 end
		,@strTransferStorageTicket
		,@intTransferStorageId
		
	return
end