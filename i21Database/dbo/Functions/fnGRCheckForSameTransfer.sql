CREATE FUNCTION [dbo].[fnGRCheckForSameTransfer]
(
	@intCustomerStorageId int
	,@strStorageType nvarchar(5)
)
returns bit
as
begin
	declare @StorageTypes nvarchar(max)
	set @StorageTypes = ''
		
	select @StorageTypes = @StorageTypes + strStorageType 
		from  vyuGRTransferFlow 
			where intParentStorageId = @intCustomerStorageId --14892--14893

	declare @ysnSameFlow bit = 1
	
	if exists(
		select top 1 1 
			from dbo.fnSplitString(@StorageTypes, ',')
				where Item <> @strStorageType

	)
		set @ysnSameFlow = 0


	return @ysnSameFlow

end