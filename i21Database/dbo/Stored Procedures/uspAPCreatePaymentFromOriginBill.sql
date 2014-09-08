/*
 '====================================================================================================================================='
   Stub stored procedure
  -------------------------------------------------------------------------------------------------------------------------------------						
	A stub is created in case AP module is not enabled in origin. 
	The real stored procedure is in the integration project. 
*/
CREATE PROCEDURE [dbo].[uspAPCreatePaymentFromOriginBill]
	@billId NVARCHAR(50) = NULL
AS
