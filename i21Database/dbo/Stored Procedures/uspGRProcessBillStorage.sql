CREATE PROCEDURE [dbo].[uspGRProcessBillStorage]
(
	@dtmStorageChargeDate AS DATE,
	@strPostType AS NVARCHAR(30),
	@intUserId AS INT,
	@BillStorageDetails AS [dbo].[BillStorageTableType] READONLY
)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	
	DECLARE @intBillStorageKey INT
	DECLARE @ErrorMessage NVARCHAR(250)
	DECLARE @CreatedIvoices NVARCHAR(MAX)
	DECLARE @UpdatedIvoices NVARCHAR(MAX)		
	DECLARE @intInvoiceId INT	

	DECLARE @intCustomerStorageId INT
	DECLARE @intEntityId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @intTermsId INT
	DECLARE @intCommodityId INT
	DECLARE @intItemId INT
	DECLARE @intStorageChargeItemId INT
	DECLARE @strStorageChargeItemDesc NVARCHAR(100)
	DECLARE @intCurrencyId INT
	DECLARE @intItemUOMId INT
	DECLARE @intHistoryStorageId INT
	DECLARE @dblStorageDue DECIMAL(30,20)
	DECLARE @dblNewStorageDue DECIMAL(18,6)

	DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
	DECLARE @TaxDetails AS LineItemTaxDetailStagingTable
	DECLARE @StorageHistoryData AS StorageHistoryStagingTable
	
	DECLARE @BillStorages AS TABLE 
	(
		intBillStorageKey INT IDENTITY(1, 1)
		,intCustomerStorageId INT
		,intEntityId INT
		,intCompanyLocationId INT
		,intStorageTypeId INT
		,intStorageScheduleId INT
		,dblOpenBalance DECIMAL(24, 10)
		,dblNewStorageDue DECIMAL(24, 10)
		,intItemId INT
	)

	INSERT INTO @BillStorages 
	(
		intCustomerStorageId
		,intEntityId
		,intCompanyLocationId
		,intStorageTypeId
		,intStorageScheduleId
		,dblOpenBalance
		,dblNewStorageDue
		,intItemId
	)
	SELECT intCustomerStorageId
		,intEntityId
		,intCompanyLocationId
		,intStorageTypeId
		,intStorageScheduleId
		,dblOpenBalance
		,dblNewStorageDue
		,intItemId
	FROM @BillStorageDetails

	IF @strPostType = 'Bill Storage'
	BEGIN
		SELECT @intBillStorageKey = MIN(intBillStorageKey)
		FROM @BillStorages

		WHILE @intBillStorageKey > 0
		BEGIN				
			SET @intCustomerStorageId = NULL
			SET @intEntityId = NULL
			SET @intCompanyLocationId = NULL
			SET @intTermsId = NULL
			SET @intCommodityId = NULL
			SET @intItemId = NULL
			SET @intStorageChargeItemId = NULL
			SET @strStorageChargeItemDesc = NULL
			SET @intCurrencyId = NULL
			SET @intItemUOMId = NULL
			SET @intHistoryStorageId = NULL
			SET @dblStorageDue = NULL

			SELECT 
				@intCustomerStorageId	= intCustomerStorageId
				,@intEntityId			= intEntityId
				,@intCompanyLocationId	= intCompanyLocationId
				,@intItemId				= intItemId
				,@dblNewStorageDue		= dblNewStorageDue
			FROM @BillStorages 
			WHERE intBillStorageKey = @intBillStorageKey

			SELECT 
				@intCommodityId = intCommodityId
				,@intCurrencyId	= ISNULL(intCurrencyId, (SELECT intDefaultCurrencyId FROM tblSMCompanyPreference))
				,@intItemUOMId	= ISNULL(intItemUOMId, (SELECT intItemUOMId FROM tblICItemUOM WHERE intItemId = @intItemId AND ysnStockUnit = 1))
				,@dblStorageDue	= dblStorageDue
			FROM tblGRCustomerStorage 
			WHERE intCustomerStorageId = @intCustomerStorageId

			SELECT TOP 1
				@intStorageChargeItemId		= intItemId
				,@strStorageChargeItemDesc	= strDescription
			FROM tblICItem
			WHERE strType = 'Other Charge' 
				AND strCostType = 'Storage Charge' 
				AND (intCommodityId = @intCommodityId OR intCommodityId IS NULL)
			
			IF @intStorageChargeItemId IS NULL 
			BEGIN
				SET @ErrMsg = 'Invoice cannot be created. There is no Storage Charge Cost type item available.'
				RAISERROR(@ErrMsg,16, 1);
			END			

			SELECT @intTermsId = intTermsId FROM tblEMEntityLocation WHERE intEntityId = @intEntityId
			
			BEGIN TRANSACTION
				
				DELETE FROM @EntriesForInvoice
				
				INSERT INTO @EntriesForInvoice 
				(
					 [strTransactionType]
					,[strType]
					,[strSourceTransaction]
					,[intSourceId]
					,[strSourceId]
					,[intInvoiceId]
					,[intEntityCustomerId]
					,[intCompanyLocationId]
					,[intCurrencyId]
					,[intTermId]
					,[dtmDate]
					,[ysnTemplate]
					,[ysnForgiven]
					,[ysnCalculated]
					,[ysnSplitted]
					,[intEntityId]
					,[ysnResetDetails]
					,[intItemId]
					,[ysnInventory]
					,[strItemDescription]
					,[intOrderUOMId]
					,[intItemUOMId]
					,[dblQtyOrdered]
					,[dblQtyShipped]
					,[dblPrice]
					,[ysnRecomputeTax]
					,[intTicketId]
					,[intCustomerStorageId]
				)
				SELECT 
					 [strTransactionType]			= 'Invoice'
					,[strType]						= 'Standard'
					,[strSourceTransaction]			= 'Process Grain Storage'
					,[intSourceId]					= NULL
					,[strSourceId]					= ''
					,[intInvoiceId]					= @intInvoiceId --NULL Value will create new invoice
					,[intEntityCustomerId]			= @intEntityId
					,[intCompanyLocationId]			= @intCompanyLocationId
					,[intCurrencyId]				= @intCurrencyId
					,[intTermId]					= @intTermsId
					,[dtmDate]						= GETDATE()
					,[ysnTemplate]					= 0
					,[ysnForgiven]					= 0
					,[ysnCalculated]				= 0
					,[ysnSplitted]					= 0
					,[intEntityId]					= @intUserId
					,[ysnResetDetails]				= 0
					,[intItemId]					= @intStorageChargeItemId
					,[ysnInventory]					= 1
					,[strItemDescription]			= @strStorageChargeItemDesc
					,[intOrderUOMId]				= @intItemUOMId
					,[intItemUOMId]					= @intItemUOMId
					,[dblQtyOrdered]				= BD.dblOpenBalance
					,[dblQtyShipped]				= BD.dblOpenBalance
					,[dblPrice]						= BD.dblNewStorageDue
					,[ysnRecomputeTax]				= 1
					,[intTicketId]					= CS.intTicketId
					,[intCustomerStorageId]			= BD.intCustomerStorageId
					FROM @BillStorages BD
					INNER JOIN tblGRCustomerStorage CS 
						ON BD.intCustomerStorageId = CS.intCustomerStorageId

				EXEC [dbo].[uspARProcessInvoices] 
					 @InvoiceEntries = @EntriesForInvoice
					,@LineItemTaxEntries = @TaxDetails
					,@UserId = @intUserId
					,@GroupingOption = 11
					,@RaiseError = 1
					,@ErrorMessage = @ErrorMessage OUTPUT
					,@CreatedIvoices = @CreatedIvoices OUTPUT
					,@UpdatedIvoices = @UpdatedIvoices OUTPUT

				IF @ErrorMessage IS NULL
				BEGIN					
					COMMIT TRANSACTION
						DELETE FROM @StorageHistoryData

						INSERT INTO @StorageHistoryData
						(							 
							[intCustomerStorageId]
							,[intInvoiceId]
							,[dblUnits]
							,[dtmHistoryDate]
							,[dblPaidAmount]
							,[ysnPost]
							,[intTransactionTypeId]
							,[strType]
							,[strPaidDescription]
							,[intUserId]
						)
						SELECT 
							[intCustomerStorageId]		= ARD.intCustomerStorageId														
							,[intInvoiceId]				= AR.intInvoiceId							
							,[dblUnits]					= ARD.dblQtyOrdered
							,[dtmHistoryDate]			= @dtmStorageChargeDate
							,[dblPaidAmount]			= ARD.dblPrice
							,[ysnPost]					= 1
							,[intTransactionTypeId]		= 6
							,[strType]					= 'Invoice'
							,[strPaidDescription]		='Generated Storage Invoice'
							,[intUserId]				= @intUserId
							 FROM tblARInvoice AR
							 INNER JOIN tblARInvoiceDetail ARD 
								ON ARD.intInvoiceId = AR.intInvoiceId
							 WHERE AR.intInvoiceId = CONVERT(INT,@CreatedIvoices)
						
						EXEC uspGRInsertStorageHistoryRecord @StorageHistoryData, @intHistoryStorageId

						UPDATE CS
						SET CS.dtmLastStorageAccrueDate		= @dtmStorageChargeDate
							,CS.dblStoragePaid				= @dblNewStorageDue
							,CS.dblStorageDue				= 0
						FROM tblGRCustomerStorage CS
						WHERE intCustomerStorageId = @intCustomerStorageId
				END
				ELSE
				BEGIN
					ROLLBACK TRANSACTION
					RAISERROR(@ErrorMessage, 16, 1);					
				END
			
			SELECT @intBillStorageKey = MIN(intBillStorageKey)
			FROM @BillStorages
			WHERE intBillStorageKey > @intBillStorageKey
			
		END
	END
	ELSE --Accrue
	BEGIN
		SELECT @intBillStorageKey = MIN(intBillStorageKey)
		FROM @BillStorages

		WHILE @intBillStorageKey > 0
		BEGIN
			SET @dblNewStorageDue = NULL
			SET @intCustomerStorageId = NULL

			SELECT 
				@dblNewStorageDue		= dblNewStorageDue
				,@intCustomerStorageId	= intCustomerStorageId
			FROM @BillStorages WHERE intBillStorageKey = @intBillStorageKey

			DELETE FROM @StorageHistoryData

			INSERT INTO @StorageHistoryData
			(							 
				[intCustomerStorageId]				
				,[dblUnits]
				,[dtmHistoryDate]
				,[dblPaidAmount]
				,[ysnPost]
				,[intTransactionTypeId]
				,[strType]
				,[strPaidDescription]
				,[intUserId]
			)
			SELECT 
				[intCustomerStorageId]		= SD.intCustomerStorageId
				,[dblUnits]					= SD.dblOpenBalance
				,[dtmHistoryDate]			= @dtmStorageChargeDate
				,[dblPaidAmount]			= SD.dblNewStorageDue
				,[ysnPost]					= 1
				,[intTransactionTypeId]		= 2
				,[strType]					= 'Accrue Storage'
				,[strPaidDescription]		= 'Accrued Storage Due'
				,[intUserId]				= @intUserId
			FROM @BillStorages SD
			INNER JOIN tblGRCustomerStorage CS
				ON CS.intCustomerStorageId = SD.intCustomerStorageId
			WHERE SD.intBillStorageKey = @intBillStorageKey
						
			EXEC uspGRInsertStorageHistoryRecord @StorageHistoryData, @intHistoryStorageId

			UPDATE CS
			SET CS.dtmLastStorageAccrueDate	= @dtmStorageChargeDate
				,CS.dblStorageDue			= @dblNewStorageDue
			FROM tblGRCustomerStorage CS
			WHERE intCustomerStorageId = @intCustomerStorageId

			SELECT @intBillStorageKey = MIN(intBillStorageKey)
			FROM @BillStorages
			WHERE intBillStorageKey > @intBillStorageKey
		END		
	END

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
