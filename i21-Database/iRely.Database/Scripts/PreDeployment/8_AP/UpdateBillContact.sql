--THIS WILL UPDATE THE tblAPBill.intContactId AND tblPOPurchase.intContactId
IF(EXISTS(SELECT 1 FROM sys.columns WHERE name = N'intContactId' and object_id = OBJECT_ID(N'tblAPBill')))
BEGIN
	IF EXISTS(SELECT 1 FROM tblAPBill WHERE NULLIF(intContactId,0) IS NULL 
	OR NOT EXISTS (
		SELECT 1 FROM tblEMEntity WHERE intContactId = intEntityId
	))
	BEGIN
		UPDATE vouchers
			SET vouchers.intContactId = defaultContact.intEntityContactId
		FROM tblAPBill vouchers
		OUTER APPLY (
			SELECT 
				entityToContact.intEntityContactId 
			FROM tblEMEntityToContact entityToContact 
			WHERE entityToContact.intEntityId = vouchers.intEntityId
			AND entityToContact.ysnDefaultContact = 1
		) defaultContact
		WHERE NULLIF(vouchers.intContactId,0) IS NULL 
		OR NOT EXISTS (
			SELECT 1 FROM tblEMEntity entity WHERE vouchers.intContactId = entity.intEntityId
		)
	END
END

IF(EXISTS(SELECT 1 FROM sys.columns WHERE name = N'intContactId' and object_id = OBJECT_ID(N'tblPOPurchase')))
BEGIN
	IF EXISTS(SELECT 1 FROM tblPOPurchase WHERE NULLIF(intContactId,0) IS NULL 
	OR NOT EXISTS (
		SELECT 1 FROM tblEMEntity WHERE intContactId = intEntityId
	))
	BEGIN
		UPDATE purchaseOrder
			SET purchaseOrder.intContactId = defaultContact.intEntityContactId
		FROM tblPOPurchase purchaseOrder
		OUTER APPLY (
			SELECT 
				entityToContact.intEntityContactId 
			FROM tblEMEntityToContact entityToContact 
			WHERE entityToContact.intEntityId = purchaseOrder.intEntityId
			AND entityToContact.ysnDefaultContact = 1
		) defaultContact
		WHERE NULLIF(purchaseOrder.intContactId,0) IS NULL 
		OR NOT EXISTS (
			SELECT 1 FROM tblEMEntity entity WHERE purchaseOrder.intContactId = entity.intEntityId
		)
	END
END

