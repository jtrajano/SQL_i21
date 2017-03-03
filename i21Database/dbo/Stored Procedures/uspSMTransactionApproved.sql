CREATE PROCEDURE [dbo].[uspSMTransactionApproved]
  @type NVARCHAR(MAX),
  @recordId INT
AS
BEGIN

    IF @type = 'ContractManagement.view.Contract'
		BEGIN
			--Call your sp here
		RETURN
	END

 RETURN
END