
-- Create a i21-only compliant stored procedure. 
-- There is another stored procedure of the same name in the Integration project. 
-- If there is no integration, this stored procedure will be used. 
-- Otherwise, the stored procedure in the integration will be used. 

CREATE PROCEDURE uspCMProcessUndepositedFunds
	@ysnPost AS BIT 
	,@intBankAccountId AS INT 
	,@strTransactionId NVARCHAR(40) = NULL 
	,@intUserId INT = NULL 
	,@isSuccessful BIT = 0 OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
--SET ANSI_WARNINGS OFF

--=====================================================================================================================================  
--  INITIALIZATION  
---------------------------------------------------------------------------------------------------------------------------------------  

		-- Create the variables   
		DECLARE @isValid AS BIT  
		DECLARE @intInvalidTransactionId AS INT  
		DECLARE @strInvalidTransactionId AS NVARCHAR(40)  

		-- Refresh the data in the undeposited fund table.   
		EXEC uspCMRefreshUndepositedFundsFromOrigin @intBankAccountId, @intUserId  

		--=====================================================================================================================================  
		--  VALIDATION   
		---------------------------------------------------------------------------------------------------------------------------------------  

		IF @ysnPost = 1  
		BEGIN   

			-- 1. Check any of the undeposited fund is missing   
			SELECT	@isValid = 0  
			FROM	tblCMBankTransaction h INNER JOIN tblCMBankTransactionDetail d  
						ON h.intTransactionId = d.intTransactionId  
			WHERE	h.strTransactionId = @strTransactionId  
					AND d.intUndepositedFundId IS NOT NULL  
					AND NOT EXISTS (  
						SELECT	intUndepositedFundId   
						FROM	tblCMUndepositedFund uf  
						WHERE	uf.intUndepositedFundId = d.intUndepositedFundId  
					)  
			
			IF @@ERROR <> 0 GOTO Exit_WithErrors  

			IF (ISNULL(@isValid, 1) = 0)  
			BEGIN   
				RAISERROR('There is an outdated Undeposited Fund record. It may have been deposited from a different deposit transaction.',11,1)  
				IF @@ERROR <> 0 GOTO Exit_WithErrors   
			END  

			-- 2. Check for outdated amounts.   
			SET @isValid = 1  

			SELECT	@isValid = 0  
			FROM	( 
						SELECT	v.intUndepositedFundId  
								,total = SUM(ISNULL(v.dblAmount, 0))  
						FROM	tblCMBankTransaction h INNER JOIN tblCMBankTransactionDetail d  
									ON h.intTransactionId = d.intTransactionId  
								INNER JOIN vyuCMOriginUndepositedFund v   
									ON d.intUndepositedFundId = v.intUndepositedFundId  
						WHERE	h.strTransactionId = @strTransactionId  
								AND d.intUndepositedFundId IS NOT NULL   
						GROUP BY v.intUndepositedFundId   
					) AS Q1 INNER JOIN (  
						SELECT	d.intUndepositedFundId  
								,total = SUM(ISNULL(d.dblCredit,0)) - SUM(ISNULL(d.dblDebit, 0))  
						FROM	tblCMBankTransaction h INNER JOIN tblCMBankTransactionDetail d  
									ON h.intTransactionId = d.intTransactionId  
						WHERE	h.strTransactionId = @strTransactionId  
								AND d.intUndepositedFundId IS NOT NULL   
						GROUP BY d.intUndepositedFundId  
					) AS Q2  
						ON Q1.intUndepositedFundId = Q1.intUndepositedFundId  
			WHERE	Q1.intUndepositedFundId = Q2.intUndepositedFundId  
					AND Q1.total <> Q2.total  

			IF @@ERROR <> 0 GOTO Exit_WithErrors    

			IF (ISNULL(@isValid, 1) = 0)  
			BEGIN   
				RAISERROR('The Undeposited Fund amount was changed. It does not match the values from the origin system.',11,1)  
				IF @@ERROR <> 0 GOTO Exit_WithErrors   
			END  

			-- 3. Check if any of the undeposited fund was used.    
			SELECT	TOP 1 
					@intInvalidTransactionId = uf.intBankDepositId  
			FROM	tblCMBankTransaction h INNER JOIN tblCMBankTransactionDetail d  
						ON h.intTransactionId = d.intTransactionId  
					INNER JOIN tblCMUndepositedFund uf  
						ON d.intUndepositedFundId = uf.intUndepositedFundId  
			WHERE	h.strTransactionId = @strTransactionId  
					AND uf.intBankDepositId IS NOT NULL  
					AND uf.intBankDepositId <> h.intTransactionId  
			IF @@ERROR <> 0 GOTO Exit_WithErrors  

			-- Get the string id  
			SELECT	@strInvalidTransactionId = strTransactionId  
			FROM	tblCMBankTransaction  
			WHERE	intTransactionId = @intInvalidTransactionId     

			IF (ISNULL(@strInvalidTransactionId, '') <> '')  
			BEGIN   
				RAISERROR('Please re-process the Undeposited Funds. It looks like one or more records of it is already posted in %s.',11,1, @strInvalidTransactionId)  
				IF @@ERROR <> 0 GOTO Exit_WithErrors   
			END 
		END   

				--=====================================================================================================================================  
		--  POST ROUTINE  
		---------------------------------------------------------------------------------------------------------------------------------------  
		IF @ysnPost = 1  
		BEGIN   
			

			-- Update the undeposited fund linking field  
			UPDATE	tblCMUndepositedFund  
			SET		intBankDepositId = h.intTransactionId  
			FROM	tblCMBankTransaction h INNER JOIN tblCMBankTransactionDetail d  
						ON h.intTransactionId = d.intTransactionId  
						AND d.intUndepositedFundId IS NOT NULL   
					INNER JOIN tblCMUndepositedFund uf  
						ON uf.intUndepositedFundId = d.intUndepositedFundId  
			WHERE	d.intUndepositedFundId IS NOT NULL   
					AND h.strTransactionId = @strTransactionId  

			
		END   

		--=====================================================================================================================================  
		--  UNPOST ROUTINE  
		---------------------------------------------------------------------------------------------------------------------------------------  
		IF @ysnPost = 0  
		BEGIN   
			
			-- Update the Undeposite Fund table. Remove the link to the deposit transaction  
			UPDATE	tblCMUndepositedFund  
			SET		intBankDepositId = NULL   
			FROM	tblCMBankTransaction h INNER JOIN tblCMBankTransactionDetail d  
						ON h.intTransactionId = d.intTransactionId  
						AND d.intUndepositedFundId IS NOT NULL   
					INNER JOIN tblCMUndepositedFund uf  
						ON uf.intUndepositedFundId = d.intUndepositedFundId  
			WHERE	h.strTransactionId = @strTransactionId  
		END  

--=====================================================================================================================================
-- 	EXIT ROUTINES 
---------------------------------------------------------------------------------------------------------------------------------------

Exit_Successfully:  
	SET @isSuccessful = 1  
	GOTO Exit_Routine  

Exit_WithErrors:  
	SET @isSuccessful = 0  

Exit_Routine:   


-- Clean up. Remove any disposable temporary tables here.
-- None