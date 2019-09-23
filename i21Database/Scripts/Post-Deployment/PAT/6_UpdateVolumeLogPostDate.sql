PRINT N'*** BEGIN - UPDATE VolumeLog PostDate  PATRONAGE ***'
GO
	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblPATCustomerVolumeLog' AND [COLUMN_NAME] = 'dtmPostDate')
	BEGIN
		EXEC('
			UPDATE
				PVL
			SET
				dtmPostDate = VL.dtmPostDate
			 FROM tblPATCustomerVolumeLog PVL
			 INNER JOIN 
				(  SELECT dtmPostDate = INV.dtmPostDate,
						intCustomerVolumeLogId =  PCVL.intCustomerVolumeLogId
					from tblPATCustomerVolumeLog  PCVL
					 INNER JOIN tblARInvoice INV
					ON PCVL.intInvoiceId = INV.intInvoiceId
					UNION ALL
					SELECT dtmPostDate = BILL.dtmDate,
						intCustomerVolumeLogId =  PCVL.intCustomerVolumeLogId
					from tblPATCustomerVolumeLog  PCVL
					 INNER JOIN tblAPBill BILL
					ON PCVL.intBillId = BILL.intBillId
				) VL
			  ON PVL.intCustomerVolumeLogId = VL.intCustomerVolumeLogId
			WHERE PVL.dtmPostDate IS NULL
		');
	END
	
GO
PRINT N'*** END - UPDATE VolumeLog PostDate  PATRONAGE ***'