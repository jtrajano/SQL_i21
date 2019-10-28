CREATE PROCEDURE [dbo].[uspCTCreateBillForBasisContract]
	  @intBasisContractDetailId INT
	 ,@dblCashPrice DECIMAL(24, 10)
	 ,@dblQtyFromCt DECIMAL(24, 10) = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @SettleStorageKey INT
	DECLARE @intSettleStorageId INT
	DECLARE @intParentSettleStorageId INT
	DECLARE @intBasisContractHeaderId INT
	DECLARE @EntityId INT
	DECLARE @intCommodityStockUomId INT
	DECLARE @intCreatedUserId INT
	DECLARE @intCreatedBillId AS INT
	DECLARE @voucherDetailStorage AS [VoucherDetailStorage]
	DECLARE @dtmDate AS DATETIME
	
	DECLARE @TicketNo NVARCHAR(20)
	DECLARE @LocationId INT
	DECLARE @detailCreated AS Id
	DECLARE @strVoucher NVARCHAR(20)
	DECLARE @success AS BIT

	DECLARE @SettleStorage AS TABLE 
	(
		 intSettleStorageKey INT IDENTITY(1, 1)
		,intSettleStorageId INT
		,intParentSettleStorageId INT NULL
		,TicketNo  NVARCHAR(20)
	)
	
	DECLARE @SettleDiscountForContract AS TABLE 
	(
		 intSettleDiscountKey INT
		,[strType] NVARCHAR(40) COLLATE Latin1_General_CI_AS
		,intSettleStorageTicketId INT
		,intCustomerStorageId INT
		,[strStorageTicketNumber] NVARCHAR(40) COLLATE Latin1_General_CI_AS
		,[intItemId] INT
		,[strItem] NVARCHAR(40) COLLATE Latin1_General_CI_AS
		,[dblGradeReading] DECIMAL(24, 10) NULL
		,intContractDetailId INT
		,dblStorageUnits DECIMAL(24, 10)
		,dblDiscountUnPaid DECIMAL(24, 10)
		,intPricingTypeId INT
	)

	SET @dtmDate = GETDATE()

	SELECT
	  @EntityId					= CH.intEntityId
	 ,@intCreatedUserId			= ISNULL(CH.intLastModifiedById,CH.intCreatedById)  
	 ,@intBasisContractHeaderId = CH.intContractHeaderId
	FROM		tblCTContractDetail			CD
	JOIN		tblCTContractHeader         CH  ON  CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN	tblICItemUOM				PU	ON	PU.intItemUOMId		   = CD.intPriceItemUOMId		
	LEFT JOIN   tblICCommodityUnitMeasure	C1	ON	C1.intCommodityId	   = CH.intCommodityId
	WHERE       C1.ysnStockUnit=1 AND CD.intContractDetailId = @intBasisContractDetailId


	INSERT INTO @SettleStorage(intSettleStorageId,intParentSettleStorageId,TicketNo)
	SELECT SC.intSettleStorageId,SS.intParentSettleStorageId,SS.strStorageTicket 
	FROM tblGRSettleContract SC
	JOIN tblGRSettleStorage SS ON SS.intSettleStorageId = SC.intSettleStorageId
	WHERE SC.intContractDetailId = @intBasisContractDetailId
	AND SS.intParentSettleStorageId IS NOT NULL
	--AND NOT EXISTS(SELECT TOP 1 1 FROM tblAPBillDetail WHERE intContractDetailId = @intBasisContractDetailId)

	SELECT @SettleStorageKey = MIN(intSettleStorageKey)
	FROM @SettleStorage

	WHILE @SettleStorageKey > 0
	BEGIN
	
			SET    @intSettleStorageId     = NULL
			SET	   @intParentSettleStorageId	= NULL
			SET    @TicketNo		       = NULL
			SET    @LocationId		       = NULL
			SET    @intCommodityStockUomId = NULL

			SELECT @intSettleStorageId = intSettleStorageId, @intParentSettleStorageId = intParentSettleStorageId, @TicketNo = TicketNo  
			FROM @SettleStorage  
			WHERE intSettleStorageKey = @SettleStorageKey
			
			
			IF(ISNULL(@intParentSettleStorageId,0) > 0)
			BEGIN
				EXEC [dbo].[uspGRPostSettleStorage] @intSettleStorageId,1, 1,@dblCashPrice, @dblQtyFromCt
			END
			
			SELECT @SettleStorageKey = MIN(intSettleStorageKey)
			FROM @SettleStorage WHERE intSettleStorageKey > @SettleStorageKey
	END

	SettleStorage_Exit:

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH

