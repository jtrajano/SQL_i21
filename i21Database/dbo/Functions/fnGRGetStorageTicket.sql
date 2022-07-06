CREATE FUNCTION [dbo].[fnGRGetStorageTicket]
(
	@intSettleStorageId int
)
RETURNS nvarchar(100)
AS
BEGIN
	
	declare @StorageTicket as nvarchar(100)
	select @StorageTicket = case when intTicketId is not null then 'TKT-' else '' end + [strStorageTicketNumber] COLLATE Latin1_General_CI_AS from tblGRSettleStorage Storage
		join tblGRSettleStorageTicket Ticket
			on Ticket.intSettleStorageId = Storage.intSettleStorageId
		join tblGRCustomerStorage CustomerStorage
			on Ticket.intCustomerStorageId = CustomerStorage.intCustomerStorageId
	where CustomerStorage.[ysnTransferStorage] = 0
		and Storage.intSettleStorageId = @intSettleStorageId

	return @StorageTicket		
END
