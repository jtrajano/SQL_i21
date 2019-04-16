CREATE PROCEDURE [dbo].[uspSTstgInsertComboSalesFile]
	@strFilePrefix NVARCHAR(50)
	, @intStoreId INT
	, @intRegisterId INT
	, @ysnClearRegisterPromotion BIT
	, @strGeneratedXML NVARCHAR(MAX) OUTPUT
	, @intImportFileHeaderId INT OUTPUT
	, @ysnSuccessResult BIT OUTPUT
	, @strMessageResult NVARCHAR(1000) OUTPUT
AS
BEGIN
	BEGIN TRY
		SET @ysnSuccessResult = CAST(1 AS BIT) -- Set to true
		SET @strMessageResult = ''

		-- DECLARE @strFilePrefix AS NVARCHAR(10) = 'CBT'

		DECLARE @strRegister NVARCHAR(200)
				, @strRegisterClass NVARCHAR(200)
				, @strXmlVersion NVARCHAR(10)

		SELECT @strRegister = strRegisterName 
				, @strRegisterClass = strRegisterClass
				, @strXmlVersion = strXmlVersion
		FROM dbo.tblSTRegister 
		WHERE intRegisterId = @intRegisterId


		-- =========================================================================================================
		-- Check if register has intImportFileHeaderId
		IF EXISTS(SELECT * FROM tblSTRegisterFileConfiguration WHERE intRegisterId = @intRegisterId AND strFilePrefix = @strFilePrefix)
			BEGIN
					SELECT TOP 1 @intImportFileHeaderId = intImportFileHeaderId 
					FROM tblSTRegisterFileConfiguration 
					WHERE intRegisterId = @intRegisterId 
					AND strFilePrefix = @strFilePrefix
			END
		ELSE
			BEGIN
					SET @ysnSuccessResult = CAST(0 AS BIT) -- Set to false
					SET @strGeneratedXML = ''
					SET @intImportFileHeaderId = 0
					SET @strMessageResult = 'Register ' + @strRegister + ' has no Outbound setup for Promotion Sales List - Combo (' + @strFilePrefix + ')'

					RETURN
			END
		-- =========================================================================================================



		IF(@strRegisterClass = 'PASSPORT')
			BEGIN
				-- Create Unique Identifier
				-- Handles multiple Update of registers by different Stores
				DECLARE @strUniqueGuid AS NVARCHAR(50) = NEWID()

				-- Table and Condition
				DECLARE @strTableAndCondition AS NVARCHAR(250) = 'tblSTstgPassportPricebookComboCBT33~strUniqueGuid=''' + @strUniqueGuid + ''''

				IF(@strXmlVersion = '3.4')
					BEGIN					
						INSERT INTO tblSTstgPassportPricebookComboCBT33
						(
							[StoreLocationID], 
							[VendorName], 
							[VendorModelVersion], 
							[TableActionType], 
							[RecordActionType], 
							[CBTDetailRecordActionType], 
							[PromotionID], 
							[PromotionReason], 
							[ComboDescription],
							[ComboPrice],
							[ItemListID],
							[ComboItemQuantity],
							[ComboItemUnitPrice],
							[StartDate],
							[StartTime],
							[StopDate],
							[StopTime],
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
							, CASE 
								WHEN PSL.ysnDeleteFromRegister = CAST(0 AS BIT) 
									THEN 'addchange' 
								WHEN PSL.ysnDeleteFromRegister = CAST(1 AS BIT)  
									THEN 'delete' 
								ELSE 'addchange' 
							END [CBTDetailRecordActionType] 
							, PSL.intPromoSalesId AS [PromotionID]
							, PSL.strPromoReason AS [PromotionReason]
							, PSL.strPromoSalesDescription AS [ComboDescription]
							, PSL.dblPromoPrice AS [ComboPrice]
							, PIL.intPromoItemListNo AS [ItemListID]
							, PSLD.intQuantity AS [ComboItemQuantity]
							, PSLD.dblPrice AS [ComboItemUnitPrice]
							, CONVERT(nvarchar(10), PSL.dtmPromoBegPeriod, 126) AS [StartDate]
							, CONVERT(varchar, CAST('0:00:00' AS TIME), 108) AS [StartTime]
							, CONVERT(nvarchar(10), PSL.dtmPromoEndPeriod, 126) AS [StopDate]
							, CONVERT(varchar, CAST('23:59:59' AS TIME), 108) AS [StopTime] 
							, @strUniqueGuid AS [strUniqueGuid]
						FROM tblICItem I
						JOIN tblICItemLocation IL 
							ON IL.intItemId = I.intItemId
						JOIN tblSMCompanyLocation L 
							ON L.intCompanyLocationId = IL.intLocationId 
						JOIN tblSTStore ST 
							ON ST.intCompanyLocationId = L.intCompanyLocationId 
						JOIN tblSTRegister R 
							ON R.intStoreId = ST.intStoreId
						JOIN tblSTPromotionSalesList PSL 
							ON PSL.intStoreId = ST.intStoreId --AND Cat.intCategoryId = PSL.intCategoryId
						JOIN tblSTPromotionSalesListDetail PSLD 
							ON PSLD.intPromoSalesListId = PSL.intPromoSalesListId
						JOIN tblSTPromotionItemList PIL 
							ON PIL.intPromoItemListId = PSLD.intPromoItemListId
						JOIN tblSTPromotionItemListDetail PILD 
							ON PILD.intPromoItemListId = PIL.intPromoItemListId
						JOIN tblICItemUOM IUOM 
							ON IUOM.intItemUOMId = PILD.intItemUOMId 
						JOIN tblICUnitMeasure IUM 
							ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
						WHERE R.intRegisterId = @intRegisterId
						AND ST.intStoreId = @intStoreId
						AND PSL.strPromoType = 'C' -- <--- 'C' = Combo
						-- AND PSL.intPromoSalesId BETWEEN @BeginningComboId AND @EndingComboId



						IF EXISTS(SELECT StoreLocationID FROM tblSTstgPassportPricebookComboCBT33 WHERE strUniqueGuid = @strUniqueGuid)
							BEGIN
								--Generate XML for the pricebook data availavle in staging table
								EXEC dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, @strTableAndCondition, 0, @strGeneratedXML OUTPUT

								--Once XML is generated delete the data from pricebook staging table.
								DELETE 
								FROM tblSTstgPassportPricebookComboCBT33
								WHERE strUniqueGuid = @strUniqueGuid
							END
						ELSE 
							BEGIN
								SET @ysnSuccessResult = CAST(0 AS BIT)
								SET @strMessageResult = 'No result found to generate Combo - ' + @strFilePrefix + ' Outbound file'
							END
					
					END
			END
		ELSE IF(@strRegisterClass = 'RADIANT')
			BEGIN
				INSERT INTO tblSTstgComboSalesFile
				SELECT DISTINCT
				  ST.intStoreNo [StoreLocationID]
					, 'iRely' [VendorName]  	
					, 'Rel. 13.2.0' [VendorModelVersion]
					, 'update' [TableActionType]
					, 'addchange' [RecordActionType] 
					, CASE PSL.ysnDeleteFromRegister 
						WHEN 0 
							THEN 'addchange' 
						WHEN 1 
							THEN 'delete' 
						ELSE 'addchange' 
					END [CBTDetailRecordActionType] 
					, PSL.intPromoSalesId [PromotionID]
					, PSL.strPromoReason [PromotionReason]
					, NULL [SalesRestrictCode]
					, 2 [LinkCodeType]
					, NULL [LinkCodeValue]
					, PSL.strPromoSalesDescription [ComboDescription]
					, PSL.dblPromoPrice [ComboPrice]
					, PIL.intPromoItemListNo [ItemListID]
					, PSLD.intQuantity [ComboItemQuantity]
					, IUM.strUnitMeasure [ComboItemQuantityUOM]
					, PSLD.dblPrice [ComboItemUnitPrice]
					, CONVERT(nvarchar(10), PSL.dtmPromoBegPeriod, 126) [StartDate]
					, '0:00:01' [StartTime]
					, CONVERT(nvarchar(10), PSL.dtmPromoEndPeriod, 126) [StopDate]
					, '23:59:59' [StopTime]
					, PSL.intPurchaseLimit [TransactionLimit]
					, CASE 
						WHEN R.strRegisterClass = 'RADIANT' 
							THEN 0 
						ELSE NULL 
					END [Priority]
					, 'yes' [WeekdayAvailabilitySunday]
					, 'Sunday' [WeekdaySunday]
					, 'yes' [WeekdayAvailabilityMonday]
					, 'Monday' [WeekdayMonday]
					, 'yes' [WeekdayAvailabilityTuesday]
					, 'Tuesday' [WeekdayTuesday]
					, 'yes' [WeekdayAvailabilityWednesday]
					, 'Wednesday' [WeekdayWednesday]
					, 'yes' [WeekdayAvailabilityThursday]
					, 'Thursday' [WeekdayThursday]
					, 'yes' [WeekdayAvailabilityFriday]
					, 'Friday' [WeekdayFriday]
					, 'yes' [WeekdayAvailabilitySaturday]
					, 'Saturday' [WeekdaySaturday]
				FROM tblICItem I
				JOIN tblICItemLocation IL 
					ON IL.intItemId = I.intItemId
				JOIN tblSMCompanyLocation L 
					ON L.intCompanyLocationId = IL.intLocationId 
				JOIN tblSTStore ST 
					ON ST.intCompanyLocationId = L.intCompanyLocationId 
				JOIN tblSTRegister R 
					ON R.intStoreId = ST.intStoreId
				JOIN tblSTPromotionSalesList PSL 
					ON PSL.intStoreId = ST.intStoreId --AND Cat.intCategoryId = PSL.intCategoryId
				JOIN tblSTPromotionSalesListDetail PSLD 
					ON PSLD.intPromoSalesListId = PSL.intPromoSalesListId
				JOIN tblSTPromotionItemList PIL 
					ON PIL.intPromoItemListId = PSLD.intPromoItemListId
				JOIN tblSTPromotionItemListDetail PILD 
					ON PILD.intPromoItemListId = PIL.intPromoItemListId
				JOIN tblICItemUOM IUOM 
					ON IUOM.intItemUOMId = PILD.intItemUOMId 
				JOIN tblICUnitMeasure IUM 
					ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
				WHERE R.intRegisterId = @intRegisterId 
				AND ST.intStoreId = @intStoreId
				AND PSL.strPromoType = 'C' -- <--- 'C' = Combo
				-- AND PSL.intPromoSalesId BETWEEN @BeginningComboId AND @EndingComboId
	
				

				IF EXISTS(SELECT StoreLocationID FROM tblSTstgComboSalesFile)
					BEGIN
							--Generate XML for the pricebook data availavle in staging table
							Exec dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, 'tblSTstgComboSalesFile~intComboSalesFile > 0', 0, @strGeneratedXML OUTPUT

							--Once XML is generated delete the data from pricebook  staging table.
							DELETE FROM tblSTstgComboSalesFile	
					END
				ELSE 
					BEGIN
							SET @ysnSuccessResult = CAST(0 AS BIT)
							SET @strMessageResult = 'No result found to generate Combo - ' + @strFilePrefix + ' Outbound file'
					END
				
			END
		ELSE IF(@strRegisterClass = 'SAPPHIRE/COMMANDER')
			BEGIN

				DECLARE @tblTempSapphireCommanderCombos TABLE 
				(
					[intPrimaryId] INT,
					[strStoreNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
					[strVendorName] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL, 
					[strVendorModelVersion] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,

					[strRecordActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 

					[strPromotionID] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
					[strComboDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,

					[strItemListID] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
					[strComboItemQuantity] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
					[strComboItemUnitPrice] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,

					[strStartDate] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
					[strStartTime] NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL,
					[strStopDate] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
					[strStopTime] NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL
				)


				INSERT INTO @tblTempSapphireCommanderCombos
				SELECT
					[intPrimaryId]						=	CAST(SL.intPromoSalesListId AS NVARCHAR(50)), 
					[strStoreNo]						=	CAST(Store.intStoreNo AS NVARCHAR(50)), 
					[strVendorName]						=	'iRely', 
					[strVendorModelVersion]				=	(SELECT TOP (1) strVersionNo FROM tblSMBuildNumber ORDER BY intVersionID DESC),

					[strRecordActionType]				=	CASE
																WHEN (SL.ysnDeleteFromRegister = 1)
																	THEN 'delete'
																ELSE 'addchange'
														    END, 
					[strPromotionID]					=	CAST(SL.intPromoSalesId AS NVARCHAR(50)),
					[strComboDescription]				=	SL.strPromoSalesDescription,

					[strItemListID]						=	PIL.strPromoItemListId,
					[strComboItemQuantity]				=	CAST(SLD.intQuantity AS NVARCHAR(50)),
					[strComboItemUnitPrice]				=	CAST(CAST(SLD.dblPrice AS DECIMAL(18, 2)) AS NVARCHAR(50)),

					[strStartDate]						=	CAST(CONVERT(DATE, SL.dtmPromoBegPeriod) AS NVARCHAR(10)),
					[strStartTime]						=	CAST(CONVERT(TIME, SL.dtmPromoBegPeriod) AS NVARCHAR(8)),
					[strStopDate]						=	CAST(CONVERT(DATE, SL.dtmPromoEndPeriod) AS NVARCHAR(10)),
					[strStopTime]						=	CAST(CONVERT(TIME, SL.dtmPromoEndPeriod) AS NVARCHAR(8))
				FROM tblSTPromotionSalesListDetail SLD
				INNER JOIN tblSTPromotionSalesList SL
					ON SLD.intPromoSalesListId = SL.intPromoSalesListId
				INNER JOIN tblSTPromotionItemList PIL
					ON SLD.intPromoItemListId = PIL.intPromoItemListId
				INNER JOIN tblSTStore Store
					ON SL.intStoreId = Store.intStoreId
				WHERE SL.intStoreId = @intStoreId
					AND SL.strPromoType = 'C'


				IF EXISTS(SELECT TOP 1 1 FROM @tblTempSapphireCommanderCombos)
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
												Combo.strRecordActionType		AS [RecordAction/@type],
												(
													SELECT
														Promo.strPromotionID	AS [PromotionID]
													FROM 
													(
														SELECT DISTINCT
															strPromotionID
														FROM @tblTempSapphireCommanderCombos
													) Promo
													WHERE Combo.strPromotionID = Promo.strPromotionID
													ORDER BY Promo.strPromotionID ASC
													FOR XML PATH('Promotion'), TYPE
												),
												Combo.strComboDescription		AS [ComboDescription],
												(
													SELECT
														comboItem.strItemListID	AS [ItemListID],
														comboItem.strComboItemQuantity	AS [ComboItemQuantity],
														comboItem.strComboItemUnitPrice	AS [ComboItemUnitPrice]
													FROM 
													(
														SELECT DISTINCT
															strPromotionID
															, strItemListID
															, strComboItemQuantity
															, strComboItemUnitPrice
														FROM @tblTempSapphireCommanderCombos
													) comboItem
													WHERE Combo.strPromotionID = comboItem.strPromotionID
													ORDER BY comboItem.strPromotionID ASC
													FOR XML PATH('ComboItemList'),
													ROOT('ComboList'), TYPE
												),
												Combo.strStartDate		AS [StartDate],
												Combo.strStartTime		AS [StartTime],
												Combo.strStopDate		AS [StopDate],
												Combo.strStopTime		AS [StopTime]
											FROM 
											(
												SELECT DISTINCT
													strPromotionID
													, strRecordActionType
													, strComboDescription
													, strStartDate
													, strStartTime
													, strStopDate
													, strStopTime
												FROM @tblTempSapphireCommanderCombos
											) Combo
											ORDER BY Combo.strPromotionID ASC
											FOR XML PATH('CBTDetail'), TYPE
										)
									FOR XML PATH('ComboMaintenance'), TYPE		
								)
							FROM 
							(
								SELECT DISTINCT
									[strStoreNo], 
									[strVendorName], 
									[strVendorModelVersion]
								FROM @tblTempSapphireCommanderCombos
							) trans
							FOR XML PATH('NAXML-MaintenanceRequest'), TYPE
						);


						DECLARE @strXmlns AS NVARCHAR(50) = 'http://www.naxml.org/POSBO/Vocabulary/2003-10-16'
								, @strVersion NVARCHAR(50) = '3.4'

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
						SET @strMessageResult = 'No result found to generate Combo - ' + @strFilePrefix + ' Outbound file'
					END
			END

	END TRY

	BEGIN CATCH
		SET @ysnSuccessResult = CAST(0 AS BIT)
		SET @strMessageResult = ERROR_MESSAGE()
	END CATCH
END