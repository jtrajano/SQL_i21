GO

PRINT ('*****BEGIN CHECKING Update storage history paid amount*****')
if not exists (select top 1 1 from tblEMEntityPreferences where strPreference = 'Update storage history paid amount')
begin
	PRINT ('*****RUNNING Update storage history paid amount*****')
	
	
	select intStorageHistoryId, dblPaidAmount into tblGRStorageHistory_BU_Paid_Amount from 
		tblGRStorageHistory StorageHistory
	join tblGRSettleStorage Storage
		on StorageHistory.intSettleStorageId = Storage.intSettleStorageId
	left join tblGRSettleContract StorageContract
		on Storage.intSettleStorageId = StorageContract.intSettleStorageId
	left join tblCTContractDetail ContractDetail
		on ContractDetail.intContractDetailId = StorageContract.intContractDetailId
	where abs(StorageHistory.dblPaidAmount -  isnull(ContractDetail.dblCashPrice, Storage.dblCashPrice) ) < 20
		and StorageHistory.dblPaidAmount > 0

	update StorageHistory set 
		dblPaidAmount = isnull(ContractDetail.dblCashPrice, Storage.dblCashPrice) * StorageHistory.dblUnits
		,dblCost = isnull(ContractDetail.dblCashPrice, Storage.dblCashPrice)
	from 
		tblGRStorageHistory StorageHistory
	join tblGRSettleStorage Storage
		on StorageHistory.intSettleStorageId = Storage.intSettleStorageId
	left join tblGRSettleContract StorageContract
		on Storage.intSettleStorageId = StorageContract.intSettleStorageId
	left join tblCTContractDetail ContractDetail
		on ContractDetail.intContractDetailId = StorageContract.intContractDetailId
	where abs(StorageHistory.dblPaidAmount -  isnull(ContractDetail.dblCashPrice, Storage.dblCashPrice) ) < 20
		and StorageHistory.dblPaidAmount > 0


	INSERT INTO tblEMEntityPreferences(strPreference,strValue)
	select 'Update storage history paid amount', '1'
	

end
PRINT ('*****END CHECKING Update storage history paid amount*****')

GO