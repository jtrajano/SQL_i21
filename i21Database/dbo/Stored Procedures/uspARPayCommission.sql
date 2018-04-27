CREATE PROCEDURE [dbo].[uspARPayCommission]
	@strCommissionIds		NVARCHAR(MAX),
	@intUserId				INT
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS ON  

DECLARE @tblCommissions TABLE (
	  intCommissionId		INT
	, ysnPayroll			BIT
	, ysnPayables			BIT
)

INSERT INTO @tblCommissions (
	  intCommissionId
    , ysnPayroll
	, ysnPayables
)
SELECT intCommissionId	= COMM.intCommissionId
	 , ysnPayroll		= COMM.ysnPayroll
	 , ysnPayables		= COMM.ysnPayables
FROM dbo.tblARCommission COMM WITH (NOLOCK)
INNER JOIN (
	SELECT intID 
	FROM dbo.fnGetRowsFromDelimitedValues(@strCommissionIds) 
	WHERE ISNULL(intID, 0) <> 0
) PCD ON COMM.intCommissionId = PCD.intID
WHERE COMM.ysnPosted = 1
	AND (COMM.ysnConditional = 0 OR (COMM.ysnConditional = 1 AND COMM.ysnApproved = 1))
	AND COMM.ysnPaid = 0
	AND COMM.dblTotalAmount <> 0.00
	
IF NOT EXISTS (SELECT TOP 1 NULL FROM @tblCommissions)
	BEGIN
		RAISERROR('There are no valid Commissions to pay!', 16, 1)
		RETURN;
	END
ELSE
	BEGIN
		UPDATE COMM
		SET COMM.ysnPaid = 1
		FROM dbo.tblARCommission COMM
		INNER JOIN @tblCommissions PCD ON COMM.intCommissionId = PCD.intCommissionId
	END