CREATE TABLE [dbo].[tblGROldTransactionMapping]
(

	intId						int identity(1,1) primary key,
	intSettleStorageId			int not null,
	intSettleStorageTicketId	int not null,
	intSettleContractId			int not null
		
)
