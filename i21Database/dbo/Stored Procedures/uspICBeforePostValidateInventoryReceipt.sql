CREATE PROCEDURE uspICBeforePostValidateInventoryReceipt  
	@intInventoryReceiptId INT 
	,@strContractIds NVARCHAR(1000) = NULL OUTPUT 
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS ON  
 
--------------------------------------------------------------------------------------------  
-- Validate  
--------------------------------------------------------------------------------------------  
BEGIN 
	
	-- Check if 'Price Fix warning' is enabled for IR
	IF EXISTS (SELECT TOP 1 1 FROM tblICCompanyPreference WHERE ysnPriceFixWarningInReceipt = 1) 
	BEGIN 
		-- Create a table to retrieve the list of contracts
		DECLARE @contracts AS TABLE (
			strContractNumber NVARCHAR(100) 
		)

		-- Get all the 'basis' contracts
		INSERT INTO @contracts (
			strContractNumber	
		)
		SELECT DISTINCT 
			ch.strContractNumber 
		FROM	
			tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
				ON r.intInventoryReceiptId = ri.intInventoryReceiptId			
			INNER JOIN (
				tblCTContractHeader ch INNER JOIN tblCTContractDetail cd
					ON ch.intContractHeaderId = cd.intContractHeaderId
			)
				ON	ch.intContractHeaderId = ISNULL(ri.intContractHeaderId, ri.intOrderId) 
					AND cd.intContractDetailId = ISNULL(ri.intContractDetailId, ri.intLineNo) 					
		WHERE	
			r.intInventoryReceiptId = @intInventoryReceiptId
			AND r.strReceiptType IN ('Purchase Contract', 'Direct')
			AND r.intSourceType IN (0, 2) -- (0): None (2): Inbound Shipment
			AND cd.intPricingTypeId = 2 -- (2): Basis


		IF EXISTS (SELECT TOP 1 1 FROM @contracts)
		BEGIN 
			-- Show only the top 10 contracts so that we don't mess up the UI. 
			SELECT TOP 10 
				@strContractIds = COALESCE(@strContractIds, '') + '<li>' + strContractNumber + '</li>'
			FROM
				@contracts			

			-- 'Unable to Post. The following contract(s) needs to be priced: <ul>%s</ul>'
			--EXEC uspICRaiseError 80262, @strContracts;
			GOTO With_Rollback_Exit; 
		END 
	END 
END


With_Rollback_Exit:
BEGIN 
	RETURN -1
END

Post_Exit:
RETURN 1