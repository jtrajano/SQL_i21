CREATE PROCEDURE [dbo].[uspIPStageERPVoucher] @strInfo1 NVARCHAR(MAX) = '' OUTPUT
	,@strInfo2 NVARCHAR(MAX) = '' OUTPUT
	,@intNoOfRowsAffected INT = 0 OUTPUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @tblIPStorageLocation TABLE (strStorageLocation NVARCHAR(MAX))
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX) = ''
		,@intRowNo INT
		,@strXml NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''
		,@strVendorName NVARCHAR(50)
		,@strVendorAccountNo NVARCHAR(50)
		,@intBillStageId INT
		,@strContractNumber NVARCHAR(50)
		,@strContractSequenceNumber NVARCHAR(50)
		,@strERPProductionOrderNo NVARCHAR(50)
		,@strERPServicePONo NVARCHAR(50)
		,@intContractHeaderId INT
		,@intContractDetailId INT
		,@intLoadId INT
		,@intLoadDetailId INT
		,@strICOMarks NVARCHAR(100)
		,@strContainerNumber NVARCHAR(50)
		,@strQuantityUOM NVARCHAR(50)
		,@strUnitRatePerUOM NVARCHAR(50)
		,@strUnitRateCurrency NVARCHAR(50)
		,@strUOM NVARCHAR(50)
		,@intItemUOMId INT
		,@intWeightUnitMeasureId INT
		,@intPriceItemUOMId INT
		,@intCurrencyId INT
		,@intQuantityUOMId INT
		,@intPriceUOMId INT
		,@intItemId INT
		,@strItemNo NVARCHAR(50)
		,@strFileName NVARCHAR(50)
		,@intInventoryReceiptId INT
		,@intInventoryReceiptItemId INT
	DECLARE @VoucherDetail TABLE (
		Name NVARCHAR(50)
		,[Text] NVARCHAR(50)
		,Id INT identity(1, 1)
		)
	DECLARE @FinalVoucherDetail TABLE (
		Name NVARCHAR(50)
		,[Text] NVARCHAR(50)
		,RecId INT
		)

	DECLARE @tblIPIDOCXMLStage TABLE (intIDOCXMLStageId INT)

	INSERT INTO @tblIPIDOCXMLStage (intIDOCXMLStageId)
	SELECT intIDOCXMLStageId
	FROM tblIPIDOCXMLStage
	WHERE strType = 'Voucher'
	AND intStatusId IS NULL

	SELECT @intRowNo = MIN(intIDOCXMLStageId)
	FROM @tblIPIDOCXMLStage

	IF @intRowNo IS NULL
	BEGIN
		RETURN
	END

	UPDATE S
	SET S.intStatusId = - 1
	FROM tblIPIDOCXMLStage S
	JOIN @tblIPIDOCXMLStage TS ON TS.intIDOCXMLStageId = S.intIDOCXMLStageId

	WHILE (ISNULL(@intRowNo, 0) > 0)
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION

			SELECT @strXml = NULL
				,@idoc = NULL
				,@intNoOfRowsAffected = 1
				,@strVendorAccountNo = NULL
				,@strVendorName = NULL

			SELECT @strXml = strXml
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			SET @strXml = REPLACE(@strXml, 'utf-8' COLLATE Latin1_General_CI_AS, 'utf-16' COLLATE Latin1_General_CI_AS)

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strXml

			SELECT @strFileName = [Filename]
			FROM OPENXML(@idoc, 'Batches/Batch/Documents/Document', 2) WITH ([Filename] NVARCHAR(50))

			SELECT @strVendorAccountNo = ExternalId
				,@strVendorName = Name
			FROM OPENXML(@idoc, 'Batches/Batch/Documents/Document/Parties/Party', 2) WITH (
					[Type] NVARCHAR(50)
					,Name NVARCHAR(100)
					,ExternalId NVARCHAR(50)
					)
			WHERE [Type] = 'supplier'

			INSERT INTO dbo.tblIPBillStage (
				strVendorAccountNo
				,strVendorName
				,ysnInvoiceCredit
				,strInvoiceNo
				,dtmInvoiceDate
				,strPaymentTerms
				,dtmDueDate
				,strCurrency
				,strWeightTerms
				,strINCOTerms
				,strRemarks
				,dblTotalDiscount
				,dblTotalTax
				,dblVoucherTotal
				,strLIBORrate
				,dblFinanceChargeAmount
				,strSalesOrderReference
				,dblFreightCharges
				,strBLNumber
				,dblMiscCharges
				,strMiscChargesDescription
				,strFileName
				)
			SELECT @strVendorAccountNo
				,@strVendorName
				,CreditInvoice
				,InvoiceNumber
				,InvoiceDate
				,[Payment Term]
				,DueDate
				,Currency
				,[Weight Terms]
				,[INCO Terms]
				,Remarks
				,Convert(NUMERIC(18, 6), Discount)
				,Convert(NUMERIC(18, 6), TaxAmount)
				,Convert(NUMERIC(18, 6), TotalAmount)
				,[LIBOR Rate]
				,Convert(NUMERIC(18, 6), FinanceChargeAmount)
				,SalesOrderReference
				,Convert(NUMERIC(18, 6), DeliveryCost)
				,[BL Number]
				,Convert(NUMERIC(18, 6), CASE 
						WHEN [Misc Charges] = ''
							THEN NULL
						ELSE [Misc Charges]
						END)
				,[Misc Charges Description]
				,@strFileName
			FROM (
				SELECT *
				FROM OPENXML(@idoc, 'Batches/Batch/Documents/Document/HeaderFields/HeaderField', 2) WITH (
						Name NVARCHAR(50)
						,[Text] NVARCHAR(50)
						)
				) AS SourceTable
			PIVOT(MAX([Text]) FOR Name IN (
						CreditInvoice
						,InvoiceNumber
						,InvoiceDate
						,TaxAmount
						,TotalAmount
						,Currency
						,DeliveryCost
						,DueDate
						,Discount
						,[Weight Terms]
						,[INCO Terms]
						,[LIBOR Rate]
						,FinanceChargeAmount
						,SalesOrderReference
						,[Payment Term]
						,[BL Number]
						,Remarks
						,[Misc Charges]
						,[Misc Charges Description]
						)) AS PivotTable;

			SET @intBillStageId = SCOPE_IDENTITY();

			DELETE
			FROM @VoucherDetail

			INSERT INTO @VoucherDetail (
				Name
				,[Text]
				)
			SELECT *
			FROM OPENXML(@idoc, 'Batches/Batch/Documents/Document/Tables/Table/TableRows/TableRow/ItemFields/ItemField', 2) WITH (
					Name NVARCHAR(50)
					,[Text] NVARCHAR(50)
					)

			DELETE
			FROM @FinalVoucherDetail

			INSERT INTO @FinalVoucherDetail (
				Name
				,[Text]
				,RecId
				)
			SELECT Name
				,[Text]
				,ROW_NUMBER() OVER (
					PARTITION BY Name ORDER BY Id
					)
			FROM @VoucherDetail

			EXEC sp_xml_removedocument @idoc

			SELECT @strContractNumber = NULL
				,@strContractSequenceNumber = NULL
				,@strERPProductionOrderNo = NULL
				,@strERPServicePONo = NULL
				,@strICOMarks = NULL
				,@strContainerNumber = NULL
				,@strQuantityUOM = NULL
				,@strUnitRatePerUOM = NULL
				,@strUnitRateCurrency = NULL
				,@intContractDetailId = NULL
				,@intItemUOMId = NULL
				,@intWeightUnitMeasureId = NULL
				,@intPriceItemUOMId = NULL
				,@intCurrencyId = NULL
				,@intContractHeaderId = NULL
				,@intItemId = NULL
				,@strItemNo = NULL

			SELECT @strContractNumber = [Contract Number]
				,@strContractSequenceNumber = [Contract Sequence Number]
				,@strERPProductionOrderNo = LI_PONumber
				,@strERPServicePONo = [Service PO Number]
				,@strQuantityUOM = [Quantity UOM]
				,@strUnitRatePerUOM = [Unit Rate Per UOM]
				,@strUnitRateCurrency = [Unit Rate Currency]
				,@strUOM = Uom
				,@strItemNo = ArticleNumber
			FROM (
				SELECT Name
					,[Text]
					,RecId
				FROM @FinalVoucherDetail
				WHERE RecId = 1
				) AS SourceTable
			PIVOT(MAX([Text]) FOR Name IN (
						[Contract Number]
						,[Contract Sequence Number]
						,LI_PONumber
						,[Service PO Number]
						,[Quantity UOM]
						,[Unit Rate Per UOM]
						,[Unit Rate Currency]
						,Uom
						,ArticleNumber
						)) AS PivotTable;

			SELECT @strICOMarks = [ICO Marks]
				,@strContainerNumber = [Container Number]
			FROM (
				SELECT Name
					,[Text]
					,RecId
				FROM @FinalVoucherDetail
				WHERE RecId = 2
				) AS SourceTable
			PIVOT(MAX([Text]) FOR Name IN (
						[ICO Marks]
						,[Container Number]
						)) AS PivotTable;

			SELECT @intContractHeaderId = intContractHeaderId
			FROM tblCTContractHeader
			WHERE strContractNumber = @strContractNumber

			IF @strContractSequenceNumber = ''
				AND (
					SELECT Count(*)
					FROM tblCTContractDetail
					WHERE intContractHeaderId = @intContractHeaderId
					) = 1
			BEGIN
				SELECT @strContractSequenceNumber = intContractSeq
					,@intContractDetailId = intContractDetailId
					,@intItemUOMId = intItemUOMId
					,@intWeightUnitMeasureId = intUnitMeasureId
					,@intPriceItemUOMId = intPriceItemUOMId
					,@intCurrencyId = intCurrencyId
					,@intItemId = intItemId
				FROM tblCTContractDetail
				WHERE intContractHeaderId = @intContractHeaderId
			END

			IF @intContractDetailId IS NULL
			BEGIN
				SELECT @intContractDetailId = intContractDetailId
					,@intItemUOMId = intItemUOMId
					,@intWeightUnitMeasureId = intUnitMeasureId
					,@intPriceItemUOMId = intPriceItemUOMId
					,@intCurrencyId = intCurrencyId
					,@intItemId = intItemId
				FROM tblCTContractDetail
				WHERE intContractHeaderId = @intContractHeaderId
					AND intContractSeq = @strContractSequenceNumber
			END

			IF NOT EXISTS (
					SELECT *
					FROM tblICItem
					WHERE strItemNo = @strItemNo
					)
			BEGIN
				SELECT @strItemNo = strItemNo
				FROM tblICItem
				WHERE intItemId = @intItemId
			END

			IF NOT EXISTS (
					SELECT *
					FROM tblICUnitMeasure
					WHERE strUnitMeasure = @strQuantityUOM
					)
			BEGIN
				SELECT @intQuantityUOMId = intUnitMeasureId
				FROM tblICItemUOM
				WHERE intItemUOMId = @intItemUOMId

				SELECT @strQuantityUOM = strUnitMeasure
				FROM tblICUnitMeasure
				WHERE intUnitMeasureId = @intQuantityUOMId
			END

			IF NOT EXISTS (
					SELECT *
					FROM tblICUnitMeasure
					WHERE strUnitMeasure = @strUnitRatePerUOM
					)
			BEGIN
				SELECT @intPriceUOMId = intUnitMeasureId
				FROM tblICItemUOM
				WHERE intItemUOMId = @intPriceItemUOMId

				SELECT @strUnitRatePerUOM = strUnitMeasure
				FROM tblICUnitMeasure
				WHERE intUnitMeasureId = @intPriceUOMId
			END

			IF NOT EXISTS (
					SELECT *
					FROM tblSMCurrency
					WHERE strCurrency = @strUnitRateCurrency
					)
			BEGIN
				SELECT @strUnitRateCurrency = strCurrency
				FROM tblSMCurrency
				WHERE intCurrencyID = @intCurrencyId
			END

			IF NOT EXISTS (
					SELECT *
					FROM tblICUnitMeasure
					WHERE strUnitMeasure = @strUOM
					)
			BEGIN
				SELECT @strUOM = strUnitMeasure
				FROM tblICUnitMeasure
				WHERE intUnitMeasureId = @intWeightUnitMeasureId
			END

			IF (
					SELECT Count(*)
					FROM tblLGLoadDetail
					WHERE intPContractDetailId = @intContractDetailId
					) = 1
			BEGIN
				SELECT @intLoadId = NULL
					,@intLoadDetailId = NULL

				SELECT @intLoadId = intLoadId
					,@intLoadDetailId = intLoadDetailId
				FROM tblLGLoadDetail
				WHERE intPContractDetailId = @intContractDetailId
			END
			ELSE
			BEGIN
				SELECT @intLoadId = NULL
					,@intLoadDetailId = NULL

				SELECT @intLoadId = LD.intLoadId
					,@intLoadDetailId = LD.intLoadDetailId
				FROM tblLGLoadContainer LC
				JOIN tblLGLoadDetailContainerLink LCL ON LCL.intLoadContainerId = LC.intLoadContainerId
				JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = LCL.intLoadDetailId
				WHERE LD.intPContractDetailId = @intContractDetailId
					AND LC.strContainerNumber = @strContainerNumber
					AND LC.strMarks = @strICOMarks
			END

			SELECT @intInventoryReceiptId = NULL
				,@intInventoryReceiptItemId = NULL

			SELECT @intInventoryReceiptId = intInventoryReceiptId
				,@intInventoryReceiptItemId = intInventoryReceiptItemId
			FROM tblICInventoryReceiptItem
			WHERE intLoadShipmentDetailId = @intLoadDetailId

			IF @intInventoryReceiptId IS NULL
			BEGIN
				SELECT @intInventoryReceiptId = intInventoryReceiptId
					,@intInventoryReceiptItemId = intInventoryReceiptItemId
				FROM tblICInventoryReceiptItem
				WHERE intContractDetailId = @intContractDetailId
			END

			INSERT INTO tblIPBillDetailStage (
				intBillStageId
				,strContractNumber
				,strContractSequenceNumber
				,strERPProductionOrderNo
				,strERPServicePONo
				,strERPServicePOLineNo
				,strItemNo
				,strItemDescription
				,dblQuantity
				,strQuantityUOM
				,dblUnitRate
				,strUnitRatePerUOM
				,strUnitRateCurrency
				,dblAmount
				,strICOMarks
				,dblNetWeight
				,strWeightUOM
				,strContainerNumber
				,strLotNumber
				,intSeqNo
				,intContractHeaderId
				,intContractDetailId
				,intLoadId
				,intLoadDetailId
				,intInventoryReceiptId
				,intInventoryReceiptItemId
				)
			SELECT @intBillStageId
				,[Contract Number]
				,(
					CASE 
						WHEN [Contract Sequence Number] = ''
							THEN @strContractSequenceNumber
						ELSE [Contract Sequence Number]
						END
					)
				,LI_PONumber
				,[Service PO Number]
				,[Service PO Line number]
				,(
					CASE 
						WHEN ArticleNumber = ''
							THEN @strItemNo
						ELSE ArticleNumber
						END
					)
				,Description
				,Convert(NUMERIC(18, 6), (
						CASE 
							WHEN Qty = ''
								THEN NULL
							ELSE Replace(Qty, ',', '')
							END
						))
				,@strQuantityUOM
				,Convert(NUMERIC(18, 6), (
						CASE 
							WHEN UnitPrice = ''
								THEN NULL
							ELSE Replace(UnitPrice, ',', '')
							END
						))
				,(
					CASE 
						WHEN [Unit Rate Per UOM] = ''
							THEN @strUnitRatePerUOM
						ELSE [Unit Rate Per UOM]
						END
					)
				,(
					CASE 
						WHEN [Unit Rate Currency] = ''
							THEN @strUnitRateCurrency
						ELSE [Unit Rate Currency]
						END
					)
				,Convert(NUMERIC(18, 6), (
						CASE 
							WHEN ExtAmt = ''
								THEN NULL
							ELSE Replace(ExtAmt, ',', '')
							END
						))
				,[ICO Marks]
				,Convert(NUMERIC(18, 6), (
						CASE 
							WHEN [Net Weight] = ''
								THEN NULL
							ELSE Replace([Net Weight], ',', '')
							END
						))
				,@strUOM
				,[Container Number]
				,[Lot Number]
				,RecId
				,@intContractHeaderId
				,@intContractDetailId
				,@intLoadId
				,@intLoadDetailId
				,@intInventoryReceiptId
				,@intInventoryReceiptItemId
			FROM (
				SELECT Name
					,[Text]
					,RecId
				FROM @FinalVoucherDetail
				WHERE RecId = 1
				) AS SourceTable
			PIVOT(MAX([Text]) FOR Name IN (
						ArticleNumber
						,Description
						,Qty
						,Uom
						,UnitPrice
						,ExtAmt
						,LI_PONumber
						,[Contract Number]
						,[Contract Sequence Number]
						,[Quantity UOM]
						,[Unit Rate Per UOM]
						,[Unit Rate Currency]
						,[Service PO Number]
						,[Service PO Line number]
						,[ICO Marks]
						,[Net Weight]
						,[Container Number]
						,[Lot Number]
						)) AS PivotTable;

			SELECT @strInfo1 = @strInfo1 + @strContractNumber + '/' + @strContractSequenceNumber + ','

			--Move to Archive
			INSERT INTO tblIPIDOCXMLArchive (
				strXml
				,strType
				,dtmCreatedDate
				)
			SELECT strXml
				,strType
				,dtmCreatedDate
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			DELETE
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			INSERT INTO dbo.tblIPInitialAck (
				intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strCreatedBy
				,intMessageTypeId
				,intStatusId
				,strStatusText
				)
			SELECT TrxSequenceNo
				,CompanyLocation
				,CreatedDate
				,CreatedBy
				,7 AS intMessageTypeId
				,0 AS intStatusId
				,@ErrMsg AS strStatusText
			FROM OPENXML(@idoc, 'root/data/header', 2) WITH (
					TrxSequenceNo BIGINT
					,CompanyLocation NVARCHAR(6)
					,CreatedDate DATETIME
					,CreatedBy NVARCHAR(50)
					)

			--Move to Error
			INSERT INTO tblIPIDOCXMLError (
				strXml
				,strType
				,strMsg
				,dtmCreatedDate
				)
			SELECT strXml
				,strType
				,@ErrMsg
				,dtmCreatedDate
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			DELETE
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo
		END CATCH

		SELECT @intRowNo = MIN(intIDOCXMLStageId)
		FROM @tblIPIDOCXMLStage
		WHERE intIDOCXMLStageId > @intRowNo

	END

	UPDATE S
	SET S.intStatusId = NULL
	FROM tblIPIDOCXMLStage S
	JOIN @tblIPIDOCXMLStage TS ON TS.intIDOCXMLStageId = S.intIDOCXMLStageId
	Where S.intStatusId = - 1

	IF (ISNULL(@strInfo1, '')) <> ''
		SELECT @strInfo1 = LEFT(@strInfo1, LEN(@strInfo1) - 1)

	IF @strFinalErrMsg <> ''
		RAISERROR (
				@strFinalErrMsg
				,16
				,1
				)
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
