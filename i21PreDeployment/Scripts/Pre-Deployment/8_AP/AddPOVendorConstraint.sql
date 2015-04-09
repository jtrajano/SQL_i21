IF NOT EXISTS (SELECT * 
  FROM sys.foreign_keys 
   WHERE object_id = OBJECT_ID(N'dbo.[FK_dbo.tblPOPurchase_dbo.tblAPVendor_intVendorId]')
   AND parent_object_id = OBJECT_ID(N'dbo.tblPOPurchase')
) AND EXISTS(SELECT 1 FROM sys.columns WHERE name = N'intVendorId' and object_id = OBJECT_ID(N'tblAPVendor'))
BEGIN
EXEC('
ALTER TABLE tblPOPurchase 
ADD CONSTRAINT [FK_dbo.tblPOPurchase_dbo.tblAPVendor_intVendorId] FOREIGN KEY (intVendorId) 
    REFERENCES tblAPVendor (intVendorId) 
	')
END