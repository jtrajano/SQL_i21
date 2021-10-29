
CREATE TYPE [dbo].ScaleDirectTicketCharge AS TABLE
(
		intAccountId INT NULL		
		,intItemId	INT NULL			
		,strMiscDescription	NVARCHAR(500)	
		,dblQuantity DECIMAL(38, 20)	NULL 
		,dblUnitQty	DECIMAL(38, 20)	NULL 					
		,dblRate DECIMAL(18, 6)	NULL 						
		,intScaleTicketId INT NULL		
		,intUnitOfMeasureId	INT NULL	
		,intCostItemUOMId INT NULL			
		,dblCostUnitQty	DECIMAL(38, 20)	NULL 					
		,intContractDetailId INT NULL	
		,intLoadDetailId INT NULL
		,intEntityId INT NULL
		,ysnAccrue BIT NOT NULL DEFAULT 0
		,ysnPrice BIT NOT NULL DEFAULT 0	
		,strCostMethod NVARCHAR(50) NULL
		,intChargeSource INT NOT NULL  ---Source of the charge 1 - Load Cost Tab, 2 - Contract Cost Tab
)
