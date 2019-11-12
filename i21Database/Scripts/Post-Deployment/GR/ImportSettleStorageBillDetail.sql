
-- GRN-1834

IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSMCleanupLog') 
BEGIN

	-- Run Once
	IF NOT EXISTS(SELECT * FROM  tblSMCleanupLog WHERE strModuleName = 'GRN' AND strDesription = 'IMPORT-SETTTLE-STORAGE-BILL-DETAIL' AND ysnActive = 1) 
	BEGIN
		
		PRINT('GRN - Import Settle Storage to Settle Storage Bill Detail')

		IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblGRSettleStorageBillDetail') 
		BEGIN
			
			INSERT INTO tblGRSettleStorageBillDetail (intSettleStorageId, intBillId, ysnImport, intConcurrencyId)
			SELECT DISTINCT SS.intSettleStorageId, SH.intBillId, 1, 1  
			FROM tblGRSettleStorage SS 
			INNER JOIN tblGRStorageHistory SH ON SH.intSettleStorageId = SS.intSettleStorageId
			WHERE SS.intSettleStorageId NOT IN (SELECT DISTINCT intSettleStorageId FROM tblGRSettleStorageBillDetail)

		END

		INSERT INTO tblSMCleanupLog VALUES('GRN', 'IMPORT-SETTTLE-STORAGE-BILL-DETAIL', GETDATE(), GETUTCDATE(), 1)	

	END

END