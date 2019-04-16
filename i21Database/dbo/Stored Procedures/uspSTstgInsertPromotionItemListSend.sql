CREATE PROCEDURE [dbo].[uspSTstgInsertPromotionItemListSend]
	@strFilePrefix NVARCHAR(50)
	, @intStoreId INT
	, @intRegisterId INT
	, @ysnClearRegisterPromotion BIT
	, @dtmBeginningChangeDate DATETIME
	, @dtmEndingChangeDate DATETIME
	, @strGeneratedXML VARCHAR(MAX) OUTPUT
	, @intImportFileHeaderId INT OUTPUT
	, @ysnSuccessResult BIT OUTPUT
	, @strMessageResult NVARCHAR(1000) OUTPUT
AS
BEGIN
	BEGIN TRY
		SET @ysnSuccessResult = CAST(1 AS BIT) -- Set to true
		SET @strMessageResult = ''

		-- DECLARE @strFilePrefix AS NVARCHAR(10) = 'ILT'

		---- =========================================================================================================
		---- CONVERT DATE's to UTC
		---- =========================================================================================================
		--DECLARE @dtmBeginningChangeDateUTC AS DATETIME = dbo.fnSTConvertDateToUTC(@dtmBeginningChangeDate)
		--DECLARE @dtmEndingChangeDateUTC AS DATETIME = dbo.fnSTConvertDateToUTC(@dtmEndingChangeDate)
		---- =========================================================================================================
		---- END CONVERT DATE's to UTC
		---- =========================================================================================================

		---- Use table to get the list of items modified during change date range
		--DECLARE @Tab_UpdatedItems TABLE(intItemId int)

		---- Get those Item using given date range
		--INSERT INTO @Tab_UpdatedItems
		--SELECT DISTINCT ITR.intItemId
		--FROM vyuSTItemsToRegister ITR
		--WHERE (
		--		ITR.dtmDateModified BETWEEN @dtmBeginningChangeDateUTC AND @dtmEndingChangeDateUTC
		--		OR 
		--		ITR.dtmDateCreated BETWEEN @dtmEndingChangeDateUTC AND @dtmEndingChangeDateUTC
		--	  )
		--	AND intCompanyLocationId = 
		--	(
		--		SELECT TOP (1) intCompanyLocationId 
		--		FROM tblSTStore
		--		WHERE intStoreId = @intStoreId
		--	)

		---- =========================================================================================================

		-- Check if register has intImportFileHeaderId
		DECLARE @strRegisterName nvarchar(200)
				, @strRegisterClass NVARCHAR(200)
				, @strXmlVersion NVARCHAR(10)

		SELECT @strRegisterName = strRegisterName 
			   , @strRegisterClass = strRegisterClass
			   , @strXmlVersion = strXmlVersion
		FROM dbo.tblSTRegister 
		Where intRegisterId = @intRegisterId

		IF EXISTS(SELECT intImportFileHeaderId FROM tblSTRegisterFileConfiguration WHERE intRegisterId = @intRegisterId AND strFilePrefix = @strFilePrefix)
			BEGIN
				SELECT @intImportFileHeaderId = intImportFileHeaderId 
				FROM tblSTRegisterFileConfiguration 
				WHERE intRegisterId = @intRegisterId 
				AND strFilePrefix = @strFilePrefix
			END
		ELSE
			BEGIN
				SET @strGeneratedXML = ''
				SET @intImportFileHeaderId = 0
				SET @ysnSuccessResult = CAST(0 AS BIT) -- Set to false
				SET @strMessageResult = 'Register ' + @strRegisterClass + ' has no Outbound setup for Promotion Item List File (' + @strFilePrefix + ')'

				RETURN
			END	
		-- =========================================================================================================



		DECLARE @XMLGatewayVersion nvarchar(100)
		SELECT @XMLGatewayVersion = strXmlVersion FROM dbo.tblSTRegister WHERE intRegisterId = @intRegisterId

		IF(@strRegisterClass = 'PASSPORT')
			BEGIN
				IF(@strXmlVersion = '3.4')
					BEGIN
						-- Create Unique Identifier
						-- Handles multiple Update of registers by different Stores
						DECLARE @strUniqueGuid AS NVARCHAR(50) = NEWID()

						-- Table and Condition
						DECLARE @strTableAndCondition AS NVARCHAR(250) = 'tblSTstgPassportPricebookItemListILT33~strUniqueGuid=''' + @strUniqueGuid + ''' GROUP BY ItemListID'

						INSERT INTO tblSTstgPassportPricebookItemListILT33
						(
							[StoreLocationID] , 
							[VendorName], 
							[VendorModelVersion], 
							[TableActionType], 
							[RecordActionType], 
							[ItemListMaintenanceRecordActionType], 
							[ItemListID], 
							[ItemListDescription], 
							[POSCodeFormatFormat], 
							[POSCode],
							[strUniqueGuid]
						)
						SELECT DISTINCT
							ST.intStoreNo AS [StoreLocationID]
							, 'iRely' AS [VendorName]  	
							, (SELECT TOP (1) strVersionNo FROM tblSMBuildNumber ORDER BY intVersionID DESC) AS [VendorModelVersion]
							, CASE
									WHEN @ysnClearRegisterPromotion = CAST(1 AS BIT) THEN 'initialize'
									WHEN @ysnClearRegisterPromotion = CAST(0 AS BIT) THEN 'update'
							END AS [TableActionType]
							, 'addchange' AS [RecordActionType] 
							, CASE PIL.ysnDeleteFromRegister 
								WHEN 0 
									THEN 'addchange' 
								WHEN 1 
									THEN 'delete' 
								ELSE 'addchange' 
							END as [ItemListMaintenanceRecordActionType] 
							, PIL.intPromoItemListNo AS [ItemListID]
							, ISNULL(PIL.strPromoItemListDescription, '') AS [ItemListDescription]
							, PCF.strPosCodeFormat AS [POSCodeFormatFormat]
							, PCF.strUPCwthOrwthOutCheckDigit AS [POSCode]
							--, CASE 
							--		WHEN ISNULL(IUOM.strLongUPCCode,'') != '' AND ISNULL(IUOM.strLongUPCCode,'') NOT LIKE '%[^0-9]%'
							--			THEN CASE
							--					WHEN CONVERT(NUMERIC(32, 0),CAST(IUOM.strLongUPCCode AS FLOAT)) > ISNULL(ST.intMaxPlu,0)
							--						THEN 'upcA'
							--					ELSE 'plu'
							--				END
							--		ELSE 'plu' 
							--END AS [POSCodeFormatFormat]
							--, CASE 
							--		WHEN ISNULL(IUOM.strLongUPCCode,'') != '' AND ISNULL(IUOM.strLongUPCCode,'') NOT LIKE '%[^0-9]%'
							--			THEN CASE
							--					WHEN CONVERT(NUMERIC(32, 0),CAST(IUOM.strLongUPCCode AS FLOAT)) > ISNULL(ST.intMaxPlu,0)
							--							THEN CASE
							--									WHEN LEN(IUOM.strLongUPCCode) = 6
							--										THEN RIGHT('00000000000' + ISNULL(dbo.fnSTConvertUPCeToUPCa(IUOM.strLongUPCCode),''), 11) + CAST(dbo.fnSTGenerateCheckDigit(IUOM.strLongUPCCode) AS NVARCHAR(1))
							--									WHEN LEN(IUOM.strLongUPCCode) > 6	
							--										THEN RIGHT('00000000000' + ISNULL(IUOM.strLongUPCCode,''), 11) + CAST(dbo.fnSTGenerateCheckDigit(IUOM.strLongUPCCode) AS NVARCHAR(1))
							--										-- IUOM.strLongUPCCode + CAST(dbo.fnSTGenerateCheckDigit(IUOM.strLongUPCCode) AS NVARCHAR(15)) --RIGHT('0000000000000' + ISNULL(IUOM.strLongUPCCode,''),13)
							--							END
							--						ELSE IUOM.strLongUPCCode
							--				END
							--		ELSE '0000' 
							--END [POSCode]
							, @strUniqueGuid AS [strUniqueGuid]
						FROM tblICItem I
						INNER JOIN tblICItemLocation IL 
							ON IL.intItemId = I.intItemId
						INNER JOIN tblSMCompanyLocation CL 
							ON CL.intCompanyLocationId = IL.intLocationId
						INNER JOIN tblSTStore ST 
							ON ST.intCompanyLocationId = CL.intCompanyLocationId 
						INNER JOIN tblSTPromotionItemList PIL 
							ON PIL.intStoreId = ST.intStoreId 
						INNER JOIN tblICItemUOM IUOM 
							ON IUOM.intItemId = I.intItemId 
						INNER JOIN vyuSTItemUOMPosCodeFormat PCF
							ON IUOM.intItemUOMId = PCF.intItemUOMId
						INNER JOIN tblSTPromotionItemListDetail ILT
							ON ILT.intItemUOMId = IUOM.intItemUOMId
							AND PIL.intPromoItemListId = ILT.intPromoItemListId
						INNER JOIN tblICUnitMeasure IUM 
							ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
						INNER JOIN tblICCategory Cat 
							ON Cat.intCategoryId = I.intCategoryId
						LEFT JOIN tblSTSubcategoryRegProd SubCat 
							ON SubCat.intStoreId = ST.intStoreId
						INNER JOIN tblSTRegister R 
							ON R.intStoreId = ST.intStoreId
						WHERE I.ysnFuelItem = CAST(0 AS BIT) 
							-- AND R.intRegisterId = @intRegisterId 
							AND ST.intStoreId = @intStoreId
							AND IUOM.strLongUPCCode IS NOT NULL
							AND IUOM.strLongUPCCode <> ''
							AND IUOM.strLongUPCCode <> '0'
							AND IUOM.strLongUPCCode NOT LIKE '%[^0-9]%'
						ORDER BY PIL.intPromoItemListNo ASC
							-- AND PIL.intPromoItemListId BETWEEN @BeginningItemListId AND @EndingItemListId



						IF EXISTS(SELECT StoreLocationID FROM tblSTstgPassportPricebookItemListILT33 WHERE strUniqueGuid = @strUniqueGuid)
							BEGIN
								-- Generate XML for the pricebook data availavle in staging table
								--EXEC dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, @strTableAndCondition, 0, @strGeneratedXML OUTPUT

								-- =========================================================================================================
								-- MANUAL Query for ILT because of different format cannot handle by uspSMGenerateDynamicXML
								SET @strGeneratedXML = 
								CAST((
										SELECT 
											'3.4' AS '@version'
											,(
												SELECT TOP (1)
													  StoreLocationID
													  , VendorName
													  , VendorModelVersion
												FROM tblSTstgPassportPricebookItemListILT33
												WHERE strUniqueGuid = @strUniqueGuid
												FOR XML PATH('TransmissionHeader'),TYPE
											)
											,(
												SELECT TOP (1)
													TableActionType AS 'TableAction/@type'
													, RecordActionType AS 'RecordAction/@type'
													,(
														SELECT
															A.ItemListID
															, A.ItemListDescription
															, (
																SELECT 
																	POSCodeFormatFormat AS 'ItemCode/POSCodeFormat/@format'
																	, POSCode AS 'ItemCode/POSCode'
																FROM tblSTstgPassportPricebookItemListILT33
																WHERE strUniqueGuid = @strUniqueGuid
																	AND ItemListID = A.ItemListID
																ORDER BY POSCode ASC
																FOR XML PATH('ItemListEntry'), TYPE
															  )
														FROM tblSTstgPassportPricebookItemListILT33 A
														WHERE strUniqueGuid = @strUniqueGuid
														GROUP BY ItemListID, ItemListDescription
														ORDER BY ItemListID
														FOR XML PATH('ILTDetail'), TYPE
													)
												FROM tblSTstgPassportPricebookItemListILT33
												WHERE strUniqueGuid = @strUniqueGuid
												FOR XML PATH(''), TYPE
											) AS [ItemListMaintenance]
										FOR XML PATH('NAXML-MaintenanceRequest'),TYPE
								) AS VARCHAR(MAX))
								SET @strGeneratedXML = REPLACE(@strGeneratedXML, '><', '>' + CHAR(13) + '<')
								-- =========================================================================================================



								--Once XML is generated delete the data from pricebook  staging table.
								DELETE 
								FROM dbo.tblSTstgPassportPricebookItemListILT33
								WHERE strUniqueGuid = @strUniqueGuid
							END
						ELSE 
							BEGIN
								SET @ysnSuccessResult = CAST(0 AS BIT)
								SET @strMessageResult = 'No result found to generate Item List - ' + @strFilePrefix + ' Outbound file'
							END
					END
			END
		ELSE IF(@strRegisterClass = 'RADIANT')
			BEGIN
				INSERT INTO [tblSTstgPromotionItemListSend]
				SELECT DISTINCT
				 ST.intStoreNo [StoreLocationID]
					, 'iRely' [VendorName]  	
					, 'Rel. 13.2.0' [VendorModelVersion]
					, 'update' [TableActionType]
					, 'addchange' [RecordActionType] 
					, CASE PIL.ysnDeleteFromRegister 
						WHEN 0 
							THEN 'addchange' 
						WHEN 1 
							THEN 'delete' 
						ELSE 'addchange' 
					END as [ILTDetailRecordActionType] 
					, PIL.intPromoItemListNo [ItemListID]
					, PIL.strPromoItemListDescription [ItemListDescription]
					, CASE 
						WHEN ISNULL(ST.intMaxPlu,0) > ISNULL(CAST(IUOM.strUpcCode as bigint),0) 
							THEN 'PLU' 
						ELSE 'upcA' 
					END [POSCodeFormat]
					, CASE	
						WHEN ISNULL(ST.intMaxPlu,0) > ISNULL(CAST(IUOM.strUpcCode as bigint),0) 
							THEN RIGHT('0000'+ISNULL(IUOM.strUpcCode,''),4) 
						ELSE RIGHT('00000000000'+ISNULL(IUOM.strLongUPCCode,''),11) 
					END [POSCode]
					, IUM.strUnitMeasure [PosCodeModifierName] 
					, '0' [PosCodeModifierValue] 
					, Cat.strCategoryCode [MerchandiseCode]	
				FROM tblICItem I
				--JOIN @Tab_UpdatedItems tmpItem 
				--	ON tmpItem.intItemId = I.intItemId 
				JOIN tblICItemLocation IL 
					ON IL.intItemId = I.intItemId
				JOIN tblSMCompanyLocation L 
					ON L.intCompanyLocationId = IL.intLocationId
				JOIN tblICItemUOM IUOM 
					ON IUOM.intItemId = I.intItemId 
				JOIN tblICUnitMeasure IUM 
					ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
				JOIN tblSTStore ST 
					ON ST.intCompanyLocationId = L.intCompanyLocationId 
				JOIN tblICCategory Cat 
					ON Cat.intCategoryId = I.intCategoryId
				LEFT JOIN tblSTSubcategoryRegProd SubCat 
					ON SubCat.intStoreId = ST.intStoreId
				JOIN tblSTRegister R 
					ON R.intStoreId = ST.intStoreId
				JOIN tblSTPromotionItemList PIL 
					ON PIL.intStoreId = ST.intStoreId 
				WHERE I.ysnFuelItem = CAST(0 AS BIT) 
				AND R.intRegisterId = @intRegisterId 
				AND ST.intStoreId = @intStoreId 
				-- AND SaleList.strPromoType = 'M'
				-- AND PIL.intPromoItemListId BETWEEN @BeginningItemListId AND @EndingItemListId
	


				IF EXISTS(SELECT StoreLocationID FROM tblSTstgPromotionItemListSend)
					BEGIN
						--Generate XML for the pricebook data availavle in staging table
						Exec dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, 'tblSTstgPromotionItemListSend~intPromotionItemListSend > 0', 0, @strGeneratedXML OUTPUT

						--Once XML is generated delete the data from pricebook  staging table.
						DELETE FROM [tblSTstgPromotionItemListSend]	
					END
				ELSE 
					BEGIN
						SET @ysnSuccessResult = CAST(0 AS BIT)
						SET @strMessageResult = 'No result found to generate Item List - ' + @strFilePrefix + ' Outbound file'
					END
			END
		ELSE IF(@strRegisterClass = 'SAPPHIRE/COMMANDER')
			BEGIN

				DECLARE @tblTempSapphireCommanderItemLists TABLE 
				(
					[intItemLocationId] INT,
					[strStoreNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
					[strVendorName] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL, 
					[strVendorModelVersion] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,

					[strRecordActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
					[strItemListID] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
					[strItemListDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,

					[strPOSCodeFormatFormat] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
					[strPOSCode] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
					[strPOSCodeModifier] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL
				)



				INSERT INTO @tblTempSapphireCommanderItemLists
				SELECT
					[intItemLocationId]					=	IL.intItemLocationId, 
					[strStoreNo]						=	CAST(ST.intStoreNo AS NVARCHAR(50)), 
					[strVendorName]						=	'iRely', 
					[strVendorModelVersion]				=	(SELECT TOP (1) strVersionNo FROM tblSMBuildNumber ORDER BY intVersionID DESC),

					[strRecordActionType]				=	CASE
																WHEN (PIL.ysnDeleteFromRegister = 1)
																	THEN 'delete'
																ELSE 'addchange'
														    END, 
					[strItemListID]						=	PIL.strPromoItemListId,
					[strItemListDescription]			=	PIL.strPromoItemListDescription,

					[strPOSCodeFormatFormat]			=	PCF.strPosCodeFormat,
					[strPOSCode]						=	PCF.strUPCwthOrwthOutCheckDigit,
					[strPOSCodeModifier]				=	'000'
				FROM tblSTPromotionItemListDetail ILT
				INNER JOIN tblSTPromotionItemList PIL
					ON ILT.intPromoItemListId = PIL.intPromoItemListId
				INNER JOIN tblICItemUOM IUOM 
					ON IUOM.intItemUOMId = ILT.intItemUOMId
				INNER JOIN tblICItem I
					ON IUOM.intItemId = I.intItemId	
				INNER JOIN tblICItemLocation IL 
					ON IL.intItemId = I.intItemId
				INNER JOIN tblSMCompanyLocation CL 
					ON CL.intCompanyLocationId = IL.intLocationId
				INNER JOIN tblSTStore ST 
					ON  CL.intCompanyLocationId =	ST.intCompanyLocationId
					AND CL.intCompanyLocationId =	IL.intLocationId
					AND PIL.intStoreId			=	ST.intStoreId 
				INNER JOIN vyuSTItemUOMPosCodeFormat PCF
					ON I.intItemId = PCF.intItemId
					AND IL.intLocationId = PCF.intLocationId
					AND IUOM.intItemUOMId = PCF.intItemUOMId
				WHERE I.ysnFuelItem = CAST(0 AS BIT) 
					AND ST.intStoreId = @intStoreId
					AND IUOM.strLongUPCCode IS NOT NULL
					AND IUOM.strLongUPCCode <> ''
					AND IUOM.strLongUPCCode <> '0'
					AND IUOM.strLongUPCCode NOT LIKE '%[^0-9]%'
					AND IUOM.ysnStockUnit = 1
				ORDER BY PIL.intPromoItemListNo ASC


				IF EXISTS(SELECT TOP 1 1 FROM @tblTempSapphireCommanderItemLists)
					BEGIN
						
						DECLARE @xml XML = N''
				
						SELECT @xml =
						(
							SELECT
								trans.strStoreNo				AS 'TransmissionHeader/StoreLocationID',
								trans.strVendorName 			AS 'TransmissionHeader/VendorName',
								trans.strVendorModelVersion 	AS 'TransmissionHeader/VendorModelVersion'
								,(	
									SELECT
										'update' AS [TableAction/@type],
										'addchange' AS [RecordAction/@type],
										(	
											SELECT
												ILM.strRecordActionType		AS [RecordAction/@type],
												ILM.strItemListID			AS [ItemListID],
												ILM.strItemListDescription	AS [ItemListDescription],
												(
													SELECT
														IL.strPOSCodeFormatFormat	AS [ItemCode/POSCodeFormat/@format],
														IL.strPOSCode				AS [ItemCode/POSCode],
														IL.strPOSCodeModifier		AS [ItemCode/POSCodeModifier]
													FROM @tblTempSapphireCommanderItemLists IL
													WHERE ILM.strItemListID = IL.strItemListID
													ORDER BY IL.strPOSCode ASC
													FOR XML PATH('ItemListEntry'), TYPE
												)
											FROM 
											(
												SELECT DISTINCT
													strItemListID
													, strRecordActionType
													, strItemListDescription
												FROM @tblTempSapphireCommanderItemLists
											) ILM
											ORDER BY ILM.strItemListID ASC
											FOR XML PATH('ILTDetail'), TYPE
										)
									FOR XML PATH('ItemListMaintenance'), TYPE		
								)
							FROM 
							(
								SELECT DISTINCT
									[strStoreNo], 
									[strVendorName], 
									[strVendorModelVersion]
								FROM @tblTempSapphireCommanderItemLists
							) trans
							FOR XML PATH('NAXML-MaintenanceRequest'), TYPE
							--FOR XML PATH('TransmissionHeader'), 
							--ROOT('NAXML-MaintenanceRequest'), TYPE
						);


						DECLARE @strXmlns AS NVARCHAR(50) = 'http://www.naxml.org/POSBO/Vocabulary/2003-10-16'
								, @strVersion NVARCHAR(50) = '3.4'

						DECLARE @strNamesSpace AS NVARCHAR(150) = 'domain:PLU xmlns:domain="urn:vfi-sapphire:np.domain.2001-07-01" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
								, @strDomainPlu AS NVARCHAR(50) = 'domain:PLU'

						-- INSERT Attributes 'page' and 'ofpages' to Root header
						SET @xml.modify('insert 
									   (
											attribute version { 
																	sql:variable("@strVersion")
															  }		   
										) into (/*:NAXML-MaintenanceRequest)[1]');

						DECLARE @strXML AS NVARCHAR(MAX) = CAST(@xml AS NVARCHAR(MAX))
						SET @strXML = REPLACE(@strXML, '<NAXML-MaintenanceRequest', '<NAXML-MaintenanceRequest xmlns="http://www.naxml.org/POSBO/Vocabulary/2003-10-16"')
						
						SET @strGeneratedXML = REPLACE(@strXML, '><', '>' + CHAR(13) + '<')
					END
				ELSE 
					BEGIN
						SET @ysnSuccessResult = CAST(0 AS BIT)
						SET @strMessageResult = 'No result found to generate Item List - ' + @strFilePrefix + ' Outbound file'
					END
			END

	END TRY

	BEGIN CATCH
		SET @ysnSuccessResult = CAST(0 AS BIT)
		SET @strMessageResult = ERROR_MESSAGE()
	END CATCH
END