CREATE FUNCTION fnQMGetAllocatedSalesContracts(
    @intContractTypeId INT,
    @intPContractDetailId INT
)

RETURNS @t TABLE
(
    strSalesContracts NVARCHAR(MAX),
    strCustomers NVARCHAR(MAX)
)
AS
BEGIN
    IF @intContractTypeId <> 1 RETURN

    Declare @sContract Varchar(MAX), @sBuyer Varchar(MAX)

    SELECT   @sContract = COALESCE(@sContract + ', ' + strSalesContractNumber, strSalesContractNumber),
            @sBuyer = COALESCE(@sBuyer + ', ' + strBuyer, strBuyer)
    FROM vyuLGAllocatedContracts
    WHERE intPContractDetailId = @intPContractDetailId

    INSERT INTO @t VALUES(@sContract,@sBuyer  )

	RETURN

END