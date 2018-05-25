GO

-- This data will remove the vendor from other charges if ysnAccrue is not equal to true. 
-- Change in 18.3:
-- (1) The ysnAccrue field now is a hidden check box. 
-- (2) If the other charge is an accrue, it is expected to have a vendor. When the user selects a vendor, ysnAccrue is set to true. If it is deleted, the accrue is set to false. 
-- (3) However, ysnAccrue is still used as identifier if the other charge will be charged to the vendor. We can't remove it. 
UPDATE	tblICInventoryReceiptCharge
SET		intEntityVendorId = NULL 
WHERE	intEntityVendorId IS NOT NULL 
		AND ISNULL(ysnAccrue, 0) = 0

GO
